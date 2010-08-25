From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-2.6 2/3] be2net: fix a bug in UE detection logic
Date: Wed, 25 Aug 2010 15:57:31 +0530
Message-ID: <20100825102720.GA14925@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:36537 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751968Ab0HYK10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 06:27:26 -0400
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
 drivers/net/benet/be_main.c |   32 ++++++++------------------------
 1 files changed, 8 insertions(+), 24 deletions(-)

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

