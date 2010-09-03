From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-2.6 2/3] be2net: fix a bug in UE detection logic
Date: Fri, 3 Sep 2010 21:53:30 +0530
Message-ID: <20100903162321.GA22812@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:41340 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754923Ab0ICQXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 12:23:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ONLINE registers can return 0xFFFFFFFF on more than one
occassion. On systems that care, reading these registers could
lead to problems.

So the new code decides that the ASIC has encountered and error
by reading the UE_STATUS_LOW/HIGH registers. AND them with
the mask values and a non-zero result indicates an error.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_cmds.c |    2 +-
 drivers/net/benet/be_cmds.h |    2 +-
 drivers/net/benet/be_main.c |   32 ++++++++------------------------
 3 files changed, 10 insertions(+), 26 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 3d30549..78f32fe 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -207,7 +207,7 @@ static int be_mbox_db_ready_wait(struct be_adapter *adapter, void __iomem *db)
 
 		if (msecs > 4000) {
 			dev_err(&adapter->pdev->dev, "mbox poll timed out\n");
-			be_dump_ue(adapter);
+			be_detect_dump_ue(adapter);
 			return -1;
 		}
 
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index bdc10a2..ad1e6fa 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -992,5 +992,5 @@ extern int be_cmd_set_loopback(struct be_adapter *adapter, u8 port_num,
 extern int be_cmd_get_phy_info(struct be_adapter *adapter,
 		struct be_dma_mem *cmd);
 extern int be_cmd_set_qos(struct be_adapter *adapter, u32 bps, u32 domain);
-extern void be_dump_ue(struct be_adapter *adapter);
+extern void be_detect_dump_ue(struct be_adapter *adapter);
 
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index a5a24e6..6eda7a0 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1750,26 +1750,7 @@ static int be_poll_tx_mcc(struct napi_struct *napi, int budget)
 	return 1;
 }
 
-static inline bool be_detect_ue(struct be_adapter *adapter)
-{
-	u32 online0 = 0, online1 = 0;
-
-	pci_read_config_dword(adapter->pdev, PCICFG_ONLINE0, &online0);
-
-	pci_read_config_dword(adapter->pdev, PCICFG_ONLINE1, &online1);
-
-	if (!online0 || !online1) {
-		adapter->ue_detected = true;
-		dev_err(&adapter->pdev->dev,
-			"UE Detected!! online0=%d online1=%d\n",
-			online0, online1);
-		return true;
-	}
-
-	return false;
-}
-
-void be_dump_ue(struct be_adapter *adapter)
+void be_detect_dump_ue(struct be_adapter *adapter)
 {
 	u32 ue_status_lo, ue_status_hi, ue_status_lo_mask, ue_status_hi_mask;
 	u32 i;
@@ -1786,6 +1767,11 @@ void be_dump_ue(struct be_adapter *adapter)
 	ue_status_lo = (ue_status_lo & (~ue_status_lo_mask));
 	ue_status_hi = (ue_status_hi & (~ue_status_hi_mask));
 
+	if (ue_status_lo || ue_status_hi) {
+		adapter->ue_detected = true;
+		dev_err(&adapter->pdev->dev, "UE Detected!!\n");
+	}
+
 	if (ue_status_lo) {
 		for (i = 0; ue_status_lo; ue_status_lo >>= 1, i++) {
 			if (ue_status_lo & 1)
@@ -1821,10 +1807,8 @@ static void be_worker(struct work_struct *work)
 		adapter->rx_post_starved = false;
 		be_post_rx_frags(adapter);
 	}
-	if (!adapter->ue_detected) {
-		if (be_detect_ue(adapter))
-			be_dump_ue(adapter);
-	}
+	if (!adapter->ue_detected)
+		be_detect_dump_ue(adapter);
 
 	schedule_delayed_work(&adapter->work, msecs_to_jiffies(1000));
 }
-- 
1.7.0.4

