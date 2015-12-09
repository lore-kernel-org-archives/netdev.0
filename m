From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Handle clip return values
Date: Wed,  9 Dec 2015 17:16:35 +0530
Message-ID: <1449661595-5745-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:47948 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752120AbbLILpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 06:45:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a warn message when clip table overflows. If clip table isn't
allocated, return from cxgb4_clip_release() to avoid panic.
Disable offload if clip isn't enabled in the hardware.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c   | 11 +++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 22 ++++++++++++++++------
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |  4 ++++
 3 files changed, 31 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c b/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
index c308429..d288dcf 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
@@ -118,6 +118,11 @@ int cxgb4_clip_get(const struct net_device *dev, const u32 *lip, u8 v6)
 			ret = clip6_get_mbox(dev, (const struct in6_addr *)lip);
 			if (ret) {
 				write_unlock_bh(&ctbl->lock);
+				dev_err(adap->pdev_dev,
+					"CLIP FW cmd failed with error %d, "
+					"Connections using %pI6c wont be "
+					"offloaded",
+					ret, ce->addr6.sin6_addr.s6_addr);
 				return ret;
 			}
 		} else {
@@ -127,6 +132,9 @@ int cxgb4_clip_get(const struct net_device *dev, const u32 *lip, u8 v6)
 		}
 	} else {
 		write_unlock_bh(&ctbl->lock);
+		dev_info(adap->pdev_dev, "CLIP table overflow, "
+			 "Connections using %pI6c wont be offloaded",
+			 (void *)lip);
 		return -ENOMEM;
 	}
 	write_unlock_bh(&ctbl->lock);
@@ -146,6 +154,9 @@ void cxgb4_clip_release(const struct net_device *dev, const u32 *lip, u8 v6)
 	int hash;
 	int ret = -1;
 
+	if (!ctbl)
+		return;
+
 	hash = clip_addr_hash(ctbl, addr, v6);
 
 	read_lock_bh(&ctbl->lock);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 0d14761..edd706e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4865,15 +4865,25 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 #if IS_ENABLED(CONFIG_IPV6)
-	adapter->clipt = t4_init_clip_tbl(adapter->clipt_start,
-					  adapter->clipt_end);
-	if (!adapter->clipt) {
-		/* We tolerate a lack of clip_table, giving up
-		 * some functionality
+	if ((CHELSIO_CHIP_VERSION(adapter->params.chip) <= CHELSIO_T5) &&
+	    (!(t4_read_reg(adapter, LE_DB_CONFIG_A) & ASLIPCOMPEN_F))) {
+		/* CLIP functionality is not present in hardware,
+		 * hence disable all offload features
 		 */
 		dev_warn(&pdev->dev,
-			 "could not allocate Clip table, continuing\n");
+			 "CLIP not enabled in hardware, continuing\n");
 		adapter->params.offload = 0;
+	} else {
+		adapter->clipt = t4_init_clip_tbl(adapter->clipt_start,
+						  adapter->clipt_end);
+		if (!adapter->clipt) {
+			/* We tolerate a lack of clip_table, giving up
+			 * some functionality
+			 */
+			dev_warn(&pdev->dev,
+				 "could not allocate Clip table, continuing\n");
+			adapter->params.offload = 0;
+		}
 	}
 #endif
 	if (is_offload(adapter) && tid_init(&adapter->tids) < 0) {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index fc3044c..91b52a2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -2802,6 +2802,10 @@
 #define HASHEN_V(x) ((x) << HASHEN_S)
 #define HASHEN_F    HASHEN_V(1U)
 
+#define ASLIPCOMPEN_S    17
+#define ASLIPCOMPEN_V(x) ((x) << ASLIPCOMPEN_S)
+#define ASLIPCOMPEN_F    ASLIPCOMPEN_V(1U)
+
 #define REQQPARERR_S    16
 #define REQQPARERR_V(x) ((x) << REQQPARERR_S)
 #define REQQPARERR_F    REQQPARERR_V(1U)
-- 
2.3.4
