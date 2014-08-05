From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net-next] cxgb4 : Disable recursive mailbox commands when enabling vi
Date: Tue,  5 Aug 2014 16:05:23 -0700
Message-ID: <1407279923-9288-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com, leedom@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:60995
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751085AbaHEXGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 19:06:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enabling a Virtual Interface can result in an interrupt during the processing
 of the VI Enable command and, in some paths, result in an attempt to issue
another command in the interrupt context, eventually crashing the system. Thus,
 we disable interrupts during the course of the VI Enable command and ensure 
enable doesn't sleep.

Signed-off-by: Anish Bhatt <anish@chelsio.com>
Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 5 ++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      | 2 +-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 8b46534b06c1..4247356c16ff 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -673,9 +673,12 @@ static int link_start(struct net_device *dev)
 	if (ret == 0)
 		ret = t4_link_start(pi->adapter, mb, pi->tx_chan,
 				    &pi->link_cfg);
-	if (ret == 0)
+	if (ret == 0) {
+		local_bh_disable();
 		ret = t4_enable_vi_params(pi->adapter, mb, pi->viid, true,
 					  true, CXGB4_DCB_ENABLED);
+		local_bh_enable();
+	}
 
 	return ret;
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 448bec119c3c..a853133d8db8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -3558,7 +3558,7 @@ int t4_enable_vi_params(struct adapter *adap, unsigned int mbox,
 	c.ien_to_len16 = htonl(FW_VI_ENABLE_CMD_IEN(rx_en) |
 			       FW_VI_ENABLE_CMD_EEN(tx_en) | FW_LEN16(c) |
 			       FW_VI_ENABLE_CMD_DCB_INFO(dcb_en));
-	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
+	return t4_wr_mbox_ns(adap, mbox, &c, sizeof(c), NULL);
 }
 
 /**
-- 
2.0.3
