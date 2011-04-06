From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH v2 net-next 1/9] tg3: Cleanup extended rx ring size code
Date: Tue, 5 Apr 2011 17:22:43 -0700
Message-ID: <1302049371-13799-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4641 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753159Ab1DFAQx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2011 20:16:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hardcoded values are used in multiple places to describe the maximum rx
ring sizes.  This patch replaces those values with preprocessor
constants.  This patch also introduces a new TG3_FLG3_LRG_PROD_RING_CAP
to determine if the device is capable of supporting larger ring sizes.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |   37 +++++++++++++++++++------------------
 drivers/net/tg3.h |   11 ++++++++---
 2 files changed, 27 insertions(+), 21 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index b7e03a6..8ffa5af 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -97,14 +97,12 @@
  * them in the NIC onboard memory.
  */
 #define TG3_RX_STD_RING_SIZE(tp) \
-	((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 || \
-	  GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) ? \
-	 RX_STD_MAX_SIZE_5717 : 512)
+	((tp->tg3_flags3 & TG3_FLG3_LRG_PROD_RING_CAP) ? \
+	 TG3_RX_STD_MAX_SIZE_5717 : TG3_RX_STD_MAX_SIZE_5700)
 #define TG3_DEF_RX_RING_PENDING		200
 #define TG3_RX_JMB_RING_SIZE(tp) \
-	((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 || \
-	  GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) ? \
-	 1024 : 256)
+	((tp->tg3_flags3 & TG3_FLG3_LRG_PROD_RING_CAP) ? \
+	 TG3_RX_JMB_MAX_SIZE_5717 : TG3_RX_JMB_MAX_SIZE_5700)
 #define TG3_DEF_RX_JUMBO_RING_PENDING	100
 #define TG3_RSS_INDIR_TBL_SIZE		128
 
@@ -8115,9 +8113,10 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 			     ((u64) tpr->rx_jmb_mapping >> 32));
 			tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_HOST_ADDR + TG3_64BIT_REG_LOW,
 			     ((u64) tpr->rx_jmb_mapping & 0xffffffff));
+			val = TG3_RX_JMB_RING_SIZE(tp) <<
+			      BDINFO_FLAGS_MAXLEN_SHIFT;
 			tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_MAXLEN_FLAGS,
-			     (RX_JUMBO_MAX_SIZE << BDINFO_FLAGS_MAXLEN_SHIFT) |
-			     BDINFO_FLAGS_USE_EXT_RECV);
+			     val | BDINFO_FLAGS_USE_EXT_RECV);
 			if (!(tp->tg3_flags3 & TG3_FLG3_USE_JUMBO_BDFLAG) ||
 			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
 				tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_NIC_ADDR,
@@ -8129,15 +8128,15 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 
 		if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS) {
 			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
-				val = RX_STD_MAX_SIZE_5705;
+				val = TG3_RX_STD_MAX_SIZE_5700;
 			else
-				val = RX_STD_MAX_SIZE_5717;
+				val = TG3_RX_STD_MAX_SIZE_5717;
 			val <<= BDINFO_FLAGS_MAXLEN_SHIFT;
 			val |= (TG3_RX_STD_DMA_SZ << 2);
 		} else
 			val = TG3_RX_STD_DMA_SZ << BDINFO_FLAGS_MAXLEN_SHIFT;
 	} else
-		val = RX_STD_MAX_SIZE_5705 << BDINFO_FLAGS_MAXLEN_SHIFT;
+		val = TG3_RX_STD_MAX_SIZE_5700 << BDINFO_FLAGS_MAXLEN_SHIFT;
 
 	tw32(RCVDBDI_STD_BD + TG3_BDINFO_MAXLEN_FLAGS, val);
 
@@ -8421,8 +8420,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32(SNDBDC_MODE, SNDBDC_MODE_ENABLE | SNDBDC_MODE_ATTN_ENABLE);
 	tw32(RCVBDI_MODE, RCVBDI_MODE_ENABLE | RCVBDI_MODE_RCB_ATTN_ENAB);
 	val = RCVDBDI_MODE_ENABLE | RCVDBDI_MODE_INV_RING_SZ;
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
+	if (tp->tg3_flags3 & TG3_FLG3_LRG_PROD_RING_CAP)
 		val |= RCVDBDI_MODE_LRG_RING_SZ;
 	tw32(RCVDBDI_MODE, val);
 	tw32(SNDDATAI_MODE, SNDDATAI_MODE_ENABLE);
@@ -13125,14 +13123,13 @@ static inline void vlan_features_add(struct net_device *dev, unsigned long flags
 
 static inline u32 tg3_rx_ret_ring_size(struct tg3 *tp)
 {
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
-		return 4096;
+	if (tp->tg3_flags3 & TG3_FLG3_LRG_PROD_RING_CAP)
+		return TG3_RX_RET_MAX_SIZE_5717;
 	else if ((tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) &&
 		 !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
-		return 1024;
+		return TG3_RX_RET_MAX_SIZE_5700;
 	else
-		return 512;
+		return TG3_RX_RET_MAX_SIZE_5705;
 }
 
 static DEFINE_PCI_DEVICE_TABLE(tg3_write_reorder_chipsets) = {
@@ -13430,6 +13427,10 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		tp->tg3_flags3 |= TG3_FLG3_40BIT_DMA_LIMIT_BUG;
 	}
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
+		tp->tg3_flags3 |= TG3_FLG3_LRG_PROD_RING_CAP;
+
 	if ((tp->tg3_flags3 & TG3_FLG3_5717_PLUS) &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5719)
 		tp->tg3_flags3 |= TG3_FLG3_USE_JUMBO_BDFLAG;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 73884b6..4c498ed 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -25,9 +25,13 @@
 
 #define TG3_RX_INTERNAL_RING_SZ_5906	32
 
-#define RX_STD_MAX_SIZE_5705		512
-#define RX_STD_MAX_SIZE_5717		2048
-#define RX_JUMBO_MAX_SIZE		0xdeadbeef /* XXX */
+#define TG3_RX_STD_MAX_SIZE_5700	512
+#define TG3_RX_STD_MAX_SIZE_5717	2048
+#define TG3_RX_JMB_MAX_SIZE_5700	256
+#define TG3_RX_JMB_MAX_SIZE_5717	1024
+#define TG3_RX_RET_MAX_SIZE_5700	1024
+#define TG3_RX_RET_MAX_SIZE_5705	512
+#define TG3_RX_RET_MAX_SIZE_5717	4096
 
 /* First 256 bytes are a mirror of PCI config space. */
 #define TG3PCI_VENDOR			0x00000000
@@ -2897,6 +2901,7 @@ struct tg3 {
 #define TG3_FLG3_5701_DMA_BUG		0x00000008
 #define TG3_FLG3_USE_PHYLIB		0x00000010
 #define TG3_FLG3_MDIOBUS_INITED		0x00000020
+#define TG3_FLG3_LRG_PROD_RING_CAP	0x00000080
 #define TG3_FLG3_RGMII_INBAND_DISABLE	0x00000100
 #define TG3_FLG3_RGMII_EXT_IBND_RX_EN	0x00000200
 #define TG3_FLG3_RGMII_EXT_IBND_TX_EN	0x00000400
-- 
1.7.3.4


