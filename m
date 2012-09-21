From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next] be2net: Ignore spurious UE indication from NIC
Date: Fri, 21 Sep 2012 11:36:20 -0500
Message-ID: <20120921163620.GA6147@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:34660 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751932Ab2IUQgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 12:36:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ignore spurious UE indication seen on some platforms.
Consider the error as un-recoverable only when the bits
stay high during second sampling.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    2 ++
 drivers/net/ethernet/emulex/benet/be_main.c |   18 +++++++++++++++---
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 5b622993..3d4a7bc 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -401,6 +401,8 @@ struct be_adapter {
 	bool eeh_error;
 	bool fw_timeout;
 	bool hw_error;
+	u32 ue_lo;
+	u32 ue_hi;
 
 	u32 port_num;
 	bool promiscuous;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 84379f4..e970f77 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2105,6 +2105,7 @@ void be_detect_error(struct be_adapter *adapter)
 	u32 ue_lo = 0, ue_hi = 0, ue_lo_mask = 0, ue_hi_mask = 0;
 	u32 sliport_status = 0, sliport_err1 = 0, sliport_err2 = 0;
 	u32 i;
+	struct device *dev = &adapter->pdev->dev;
 
 	if (be_crit_error(adapter))
 		return;
@@ -2129,13 +2130,22 @@ void be_detect_error(struct be_adapter *adapter)
 
 		ue_lo = (ue_lo & ~ue_lo_mask);
 		ue_hi = (ue_hi & ~ue_hi_mask);
+		if (ue_lo != adapter->ue_lo || ue_hi != adapter->ue_hi) {
+			dev_err(dev, "UE read: 0x%x/0x%x\n", ue_lo, ue_hi);
+			goto done;
+		}
+	}
+
+	if (ue_lo == 0xffffffff || ue_hi == 0xffffffff) {
+		adapter->eeh_error = true;
+		dev_err(dev, "PCI slot disconnected\n");
+		goto done;
 	}
 
 	if (ue_lo || ue_hi ||
 		sliport_status & SLIPORT_STATUS_ERR_MASK) {
 		adapter->hw_error = true;
-		dev_err(&adapter->pdev->dev,
-			"Error detected in the card\n");
+		dev_err(dev, "UE detected\n");
 	}
 
 	if (sliport_status & SLIPORT_STATUS_ERR_MASK) {
@@ -2162,7 +2172,9 @@ void be_detect_error(struct be_adapter *adapter)
 				"UE: %s bit set\n", ue_status_hi_desc[i]);
 		}
 	}
-
+done:
+	adapter->ue_lo = ue_lo;
+	adapter->ue_hi = ue_hi;
 }
 
 static void be_msix_disable(struct be_adapter *adapter)
-- 
1.7.9.5
