From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 1/4] qed: Prevent MF link notifications
Date: Wed, 9 Mar 2016 09:16:23 +0200
Message-ID: <1457507786-6603-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1457507786-6603-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:53498 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751964AbcCIHQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 02:16:52 -0500
In-Reply-To: <1457507786-6603-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>

When device is configured for Multi-function mode, some older management
firmware might incorrectly notify interfaces of link changes while they
haven't requested the physical link configuration to be set.
This can create bizzare race conditions where unloading interfaces are
getting notified that the link is up.

Let the driver compensate - store the logical requested state of the link
and don't propagate notifications after protocol driver explicitly
requires the link to be unset.

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h     | 3 +++
 drivers/net/ethernet/qlogic/qed/qed_mcp.c | 7 ++++++-
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index e5604ee..fcb8e9b 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -303,6 +303,9 @@ struct qed_hwfn {
 	bool				b_int_enabled;
 	bool				b_int_requested;
 
+	/* True if the driver requests for the link */
+	bool				b_drv_link_init;
+
 	struct qed_mcp_info		*mcp_info;
 
 	struct qed_hw_cid_data		*p_tx_cids;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index f23ce73..2bf9824 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -390,7 +390,10 @@ static void qed_mcp_handle_link_change(struct qed_hwfn *p_hwfn,
 		return;
 	}
 
-	p_link->link_up = !!(status & LINK_STATUS_LINK_UP);
+	if (p_hwfn->b_drv_link_init)
+		p_link->link_up = !!(status & LINK_STATUS_LINK_UP);
+	else
+		p_link->link_up = false;
 
 	p_link->full_duplex = true;
 	switch ((status & LINK_STATUS_SPEED_AND_DUPLEX_MASK)) {
@@ -520,6 +523,8 @@ int qed_mcp_set_link(struct qed_hwfn *p_hwfn,
 		       offsetof(struct public_drv_mb, union_data) + i,
 		       ((u32 *)&phy_cfg)[i >> 2]);
 
+	p_hwfn->b_drv_link_init = b_up;
+
 	if (b_up) {
 		DP_VERBOSE(p_hwfn, NETIF_MSG_LINK,
 			   "Configuring Link: Speed 0x%08x, Pause 0x%08x, adv_speed 0x%08x, loopback 0x%08x, features 0x%08x\n",
-- 
1.9.3
