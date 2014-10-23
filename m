From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net 2/2] cxgb4 : Handle dcb enable correctly
Date: Thu, 23 Oct 2014 14:37:31 -0700
Message-ID: <1414100251-15702-3-git-send-email-anish@chelsio.com>
References: <1414100251-15702-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com, leedom@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:33433
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751860AbaJWVh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 17:37:58 -0400
In-Reply-To: <1414100251-15702-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disabling DCBx in firmware automatically enables DCBx for control via host
lldp agents. Wait for an explicit setstate call from an lldp agents to enable
 DCBx instead.

Fixes: 76bcb31efc06 ("cxgb4 : Add DCBx support codebase and dcbnl_ops")

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c  | 7 ++++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 6 +++++-
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
index ee819fd..6fe300e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
@@ -116,7 +116,6 @@ void cxgb4_dcb_state_fsm(struct net_device *dev,
 			/* we're going to use Host DCB */
 			dcb->state = CXGB4_DCB_STATE_HOST;
 			dcb->supported = CXGB4_DCBX_HOST_SUPPORT;
-			dcb->enabled = 1;
 			break;
 		}
 
@@ -386,6 +385,12 @@ static u8 cxgb4_setstate(struct net_device *dev, u8 enabled)
 {
 	struct port_info *pi = netdev2pinfo(dev);
 
+	/* If DCBx is host-managed, dcb is enabled by outside lldp agents */
+	if (pi->dcb.state == CXGB4_DCB_STATE_HOST) {
+		pi->dcb.enabled = enabled;
+		return 0;
+	}
+
 	/* Firmware doesn't provide any mechanism to control the DCB state.
 	 */
 	if (enabled != (pi->dcb.state == CXGB4_DCB_STATE_FW_ALLSYNCED))
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 3f60070..97683c1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -694,7 +694,11 @@ int cxgb4_dcb_enabled(const struct net_device *dev)
 #ifdef CONFIG_CHELSIO_T4_DCB
 	struct port_info *pi = netdev_priv(dev);
 
-	return pi->dcb.state == CXGB4_DCB_STATE_FW_ALLSYNCED;
+	if (!pi->dcb.enabled)
+		return 0;
+
+	return ((pi->dcb.state == CXGB4_DCB_STATE_FW_ALLSYNCED) ||
+		(pi->dcb.state == CXGB4_DCB_STATE_HOST));
 #else
 	return 0;
 #endif
-- 
2.1.2
