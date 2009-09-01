From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 12/18] tg3: Add RSS support
Date: Tue, 1 Sep 2009 16:13:00 -0700
Message-ID: <1251867310.5947@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3691 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932134AbZIBEzV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 00:55:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code needed to enable RSS.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   53 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/tg3.h |   25 ++++++++++++++++++++++++-
 2 files changed, 76 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 8e9492b..39a8ead 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -102,6 +102,7 @@
 #define TG3_DEF_RX_RING_PENDING		200
 #define TG3_RX_JUMBO_RING_SIZE		256
 #define TG3_DEF_RX_JUMBO_RING_PENDING	100
+#define TG3_RSS_INDIR_TBL_SIZE 128
 
 /* Do not place this n-ring entries value into the tp struct itself,
  * we really want to expose these constants to GCC so that modulo et
@@ -7497,6 +7498,12 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32_f(GRC_LOCAL_CTRL, tp->grc_local_ctrl);
 	udelay(100);
 
+	if (tp->tg3_flags2 & TG3_FLG2_USING_MSIX) {
+		val = tr32(MSGINT_MODE);
+		val |= MSGINT_MODE_MULTIVEC_EN | MSGINT_MODE_ENABLE;
+		tw32(MSGINT_MODE, val);
+	}
+
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
 		tw32_f(DMAC_MODE, DMAC_MODE_ENABLE);
 		udelay(40);
@@ -7565,7 +7572,10 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32(SNDDATAI_MODE, SNDDATAI_MODE_ENABLE);
 	if (tp->tg3_flags2 & TG3_FLG2_HW_TSO)
 		tw32(SNDDATAI_MODE, SNDDATAI_MODE_ENABLE | 0x8);
-	tw32(SNDBDI_MODE, SNDBDI_MODE_ENABLE | SNDBDI_MODE_ATTN_ENABLE);
+	val = SNDBDI_MODE_ENABLE | SNDBDI_MODE_ATTN_ENABLE;
+	if (tp->tg3_flags2 & TG3_FLG2_USING_MSIX)
+		val |= SNDBDI_MODE_MULTI_TXQ_EN;
+	tw32(SNDBDI_MODE, val);
 	tw32(SNDBDS_MODE, SNDBDS_MODE_ENABLE | SNDBDS_MODE_ATTN_ENABLE);
 
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5701_A0) {
@@ -7584,10 +7594,46 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32_f(MAC_TX_MODE, tp->tx_mode);
 	udelay(100);
 
+	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_RSS) {
+		u32 reg = MAC_RSS_INDIR_TBL_0;
+		u8 *ent = (u8 *)&val;
+
+		/* Setup the indirection table */
+		for (i = 0; i < TG3_RSS_INDIR_TBL_SIZE; i++) {
+			int idx = i % sizeof(val);
+
+			ent[idx] = i % (tp->irq_cnt - 1);
+			if (idx == sizeof(val) - 1) {
+				tw32(reg, val);
+				reg += 4;
+			}
+		}
+
+		/* Setup the "secret" hash key. */
+		tw32(MAC_RSS_HASH_KEY_0, 0x5f865437);
+		tw32(MAC_RSS_HASH_KEY_1, 0xe4ac62cc);
+		tw32(MAC_RSS_HASH_KEY_2, 0x50103a45);
+		tw32(MAC_RSS_HASH_KEY_3, 0x36621985);
+		tw32(MAC_RSS_HASH_KEY_4, 0xbf14c0e8);
+		tw32(MAC_RSS_HASH_KEY_5, 0x1bc27a1e);
+		tw32(MAC_RSS_HASH_KEY_6, 0x84f4b556);
+		tw32(MAC_RSS_HASH_KEY_7, 0x094ea6fe);
+		tw32(MAC_RSS_HASH_KEY_8, 0x7dda01e7);
+		tw32(MAC_RSS_HASH_KEY_9, 0xc04d7481);
+	}
+
 	tp->rx_mode = RX_MODE_ENABLE;
 	if (tp->tg3_flags3 & TG3_FLG3_5755_PLUS)
 		tp->rx_mode |= RX_MODE_IPV6_CSUM_ENABLE;
 
+	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_RSS)
+		tp->rx_mode |= RX_MODE_RSS_ENABLE |
+			       RX_MODE_RSS_ITBL_HASH_BITS_7 |
+			       RX_MODE_RSS_IPV6_HASH_EN |
+			       RX_MODE_RSS_TCP_IPV6_HASH_EN |
+			       RX_MODE_RSS_IPV4_HASH_EN |
+			       RX_MODE_RSS_TCP_IPV4_HASH_EN;
+
 	tw32_f(MAC_RX_MODE, tp->rx_mode);
 	udelay(10);
 
@@ -8112,6 +8158,8 @@ static bool tg3_enable_msix(struct tg3 *tp)
 		tp->irq_cnt = rc;
 	}
 
+	tp->tg3_flags3 |= TG3_FLG3_ENABLE_RSS;
+
 	for (i = 0; i < tp->irq_max; i++)
 		tp->napi[i].irq_vec = msix_ent[i].vector;
 
@@ -8140,6 +8188,8 @@ static void tg3_ints_init(struct tg3 *tp)
 
 	if (tp->tg3_flags2 & TG3_FLG2_USING_MSI_OR_MSIX) {
 		u32 msi_mode = tr32(MSGINT_MODE);
+		if (tp->tg3_flags2 & TG3_FLG2_USING_MSIX)
+			msi_mode |= MSGINT_MODE_MULTIVEC_EN;
 		tw32(MSGINT_MODE, msi_mode | MSGINT_MODE_ENABLE);
 	}
 defcfg:
@@ -8157,6 +8207,7 @@ static void tg3_ints_fini(struct tg3 *tp)
 	else if (tp->tg3_flags2 & TG3_FLG2_USING_MSI)
 		pci_disable_msi(tp->pdev);
 	tp->tg3_flags2 &= ~TG3_FLG2_USING_MSI_OR_MSIX;
+	tp->tg3_flags3 &= ~TG3_FLG3_ENABLE_RSS;
 }
 
 static int tg3_open(struct net_device *dev)
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 978b6d9..348add2 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -446,6 +446,12 @@
 #define  RX_MODE_PROMISC		 0x00000100
 #define  RX_MODE_NO_CRC_CHECK		 0x00000200
 #define  RX_MODE_KEEP_VLAN_TAG		 0x00000400
+#define  RX_MODE_RSS_IPV4_HASH_EN	 0x00010000
+#define  RX_MODE_RSS_TCP_IPV4_HASH_EN	 0x00020000
+#define  RX_MODE_RSS_IPV6_HASH_EN	 0x00040000
+#define  RX_MODE_RSS_TCP_IPV6_HASH_EN	 0x00080000
+#define  RX_MODE_RSS_ITBL_HASH_BITS_7	 0x00700000
+#define  RX_MODE_RSS_ENABLE		 0x00800000
 #define  RX_MODE_IPV6_CSUM_ENABLE	 0x01000000
 #define MAC_RX_STATUS			0x0000046c
 #define  RX_STATUS_REMOTE_TX_XOFFED	 0x00000001
@@ -690,7 +696,22 @@
 /* 0x5b8 --> 0x600 unused */
 #define MAC_TX_MAC_STATE_BASE		0x00000600 /* 16 bytes */
 #define MAC_RX_MAC_STATE_BASE		0x00000610 /* 20 bytes */
-/* 0x624 --> 0x800 unused */
+/* 0x624 --> 0x670 unused */
+
+#define MAC_RSS_INDIR_TBL_0		0x00000630
+
+#define MAC_RSS_HASH_KEY_0		0x00000670
+#define MAC_RSS_HASH_KEY_1		0x00000674
+#define MAC_RSS_HASH_KEY_2		0x00000678
+#define MAC_RSS_HASH_KEY_3		0x0000067c
+#define MAC_RSS_HASH_KEY_4		0x00000680
+#define MAC_RSS_HASH_KEY_5		0x00000684
+#define MAC_RSS_HASH_KEY_6		0x00000688
+#define MAC_RSS_HASH_KEY_7		0x0000068c
+#define MAC_RSS_HASH_KEY_8		0x00000690
+#define MAC_RSS_HASH_KEY_9		0x00000694
+/* 0x698 --> 0x800 unused */
+
 #define MAC_TX_STATS_OCTETS		0x00000800
 #define MAC_TX_STATS_RESV1		0x00000804
 #define MAC_TX_STATS_COLLISIONS		0x00000808
@@ -1465,6 +1486,7 @@
 #define MSGINT_MODE			0x00006000
 #define  MSGINT_MODE_RESET		 0x00000001
 #define  MSGINT_MODE_ENABLE		 0x00000002
+#define  MSGINT_MODE_MULTIVEC_EN	 0x00000080
 #define MSGINT_STATUS			0x00006004
 #define MSGINT_FIFO			0x00006008
 /* 0x600c --> 0x6400 unused */
@@ -2704,6 +2726,7 @@ struct tg3 {
 #define TG3_FLG3_NO_NVRAM		0x00004000
 #define TG3_FLG3_TOGGLE_10_100_L1PLLPD	0x00008000
 #define TG3_FLG3_PHY_IS_FET		0x00010000
+#define TG3_FLG3_ENABLE_RSS		0x00020000
 
 	struct timer_list		timer;
 	u16				timer_counter;
-- 
1.6.3.3


