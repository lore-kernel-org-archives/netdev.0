From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 2/9] tg3: Adjust rx prod ring bd replenish
 thresholds
Date: Wed, 20 Apr 2011 10:57:36 -0700
Message-ID: <1303322263-18991-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1814 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751216Ab1DTRsV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 13:48:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The oldest tg3 devices had large rx producer ring BD caches.  Back then,
it made sense to make the BD cache replenish threshold only a function
of the number of rx buffers posted by the driver.  Since then, the BD
cache sizes have shrunk to 25% of their original size and, in some
cases, the ring sizes have quadrupled in size.  Under such conditions,
static BD cache replenish thresholds no longer match the hardware
constraints.

This patch attempts to factor in the BD cache size into the bd cache
replenish strategy, taking the existing hardware bugs into account.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   67 ++++++++++++++++++++++++++++++++++++----------------
 drivers/net/tg3.h |    9 +++++-
 2 files changed, 53 insertions(+), 23 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 58787ea..4aecb0a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7952,6 +7952,48 @@ static void tg3_rings_reset(struct tg3 *tp)
 	}
 }
 
+static void tg3_setup_rxbd_thresholds(struct tg3 *tp)
+{
+	u32 val, bdcache_maxcnt, host_rep_thresh, nic_rep_thresh;
+
+	if (!(tp->tg3_flags2 & TG3_FLG2_5750_PLUS) ||
+	    (tp->tg3_flags2 & TG3_FLG2_5780_CLASS) ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752)
+		bdcache_maxcnt = TG3_SRAM_RX_STD_BDCACHE_SIZE_5700;
+	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
+		 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787)
+		bdcache_maxcnt = TG3_SRAM_RX_STD_BDCACHE_SIZE_5755;
+	else
+		bdcache_maxcnt = TG3_SRAM_RX_STD_BDCACHE_SIZE_5906;
+
+	nic_rep_thresh = min(bdcache_maxcnt / 2, tp->rx_std_max_post);
+	host_rep_thresh = max_t(u32, tp->rx_pending / 8, 1);
+
+	val = min(nic_rep_thresh, host_rep_thresh);
+	tw32(RCVBDI_STD_THRESH, val);
+
+	if (tp->tg3_flags3 & TG3_FLG3_57765_PLUS)
+		tw32(STD_REPLENISH_LWM, bdcache_maxcnt);
+
+	if (!(tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) ||
+		(tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
+		return;
+
+	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
+		bdcache_maxcnt = TG3_SRAM_RX_JMB_BDCACHE_SIZE_5700;
+	else
+		bdcache_maxcnt = TG3_SRAM_RX_JMB_BDCACHE_SIZE_5717;
+
+	host_rep_thresh = max_t(u32, tp->rx_jumbo_pending / 8, 1);
+
+	val = min(bdcache_maxcnt / 2, host_rep_thresh);
+	tw32(RCVBDI_JUMBO_THRESH, val);
+
+	if (tp->tg3_flags3 & TG3_FLG3_57765_PLUS)
+		tw32(JMB_REPLENISH_LWM, bdcache_maxcnt);
+}
+
 /* tp->lock is held. */
 static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 {
@@ -8223,21 +8265,10 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		return -ENODEV;
 	}
 
-	/* Setup replenish threshold. */
-	val = tp->rx_pending / 8;
-	if (val == 0)
-		val = 1;
-	else if (val > tp->rx_std_max_post)
-		val = tp->rx_std_max_post;
-	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
-		if (tp->pci_chip_rev_id == CHIPREV_ID_5906_A1)
-			tw32(ISO_PKT_TX, (tr32(ISO_PKT_TX) & ~0x3) | 0x2);
+	if (tp->pci_chip_rev_id == CHIPREV_ID_5906_A1)
+		tw32(ISO_PKT_TX, (tr32(ISO_PKT_TX) & ~0x3) | 0x2);
 
-		if (val > (TG3_RX_INTERNAL_RING_SZ_5906 / 2))
-			val = TG3_RX_INTERNAL_RING_SZ_5906 / 2;
-	}
-
-	tw32(RCVBDI_STD_THRESH, val);
+	tg3_setup_rxbd_thresholds(tp);
 
 	/* Initialize TG3_BDINFO's at:
 	 *  RCVDBDI_STD_BD:	standard eth size rx ring
@@ -8275,8 +8306,6 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
 	    ((tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) &&
 	    !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS))) {
-		/* Setup replenish threshold. */
-		tw32(RCVBDI_JUMBO_THRESH, tp->rx_jumbo_pending / 8);
 
 		if (tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE) {
 			tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_HOST_ADDR + TG3_64BIT_REG_HIGH,
@@ -8317,11 +8346,6 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 			  tp->rx_jumbo_pending : 0;
 	tw32_rx_mbox(TG3_RX_JMB_PROD_IDX_REG, tpr->rx_jmb_prod_idx);
 
-	if (tp->tg3_flags3 & TG3_FLG3_57765_PLUS) {
-		tw32(STD_REPLENISH_LWM, 32);
-		tw32(JMB_REPLENISH_LWM, 16);
-	}
-
 	tg3_rings_reset(tp);
 
 	/* Initialize MAC address and backoff seed. */
@@ -13599,6 +13623,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    (tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
 		tp->tg3_flags2 |= TG3_FLG2_5750_PLUS;
 
+
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) ||
 	    (tp->tg3_flags2 & TG3_FLG2_5750_PLUS))
 		tp->tg3_flags2 |= TG3_FLG2_5705_PLUS;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index db50bfe..dd331f8 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -23,8 +23,6 @@
 #define TG3_BDINFO_NIC_ADDR		0xcUL /* 32-bit */
 #define TG3_BDINFO_SIZE			0x10UL
 
-#define TG3_RX_INTERNAL_RING_SZ_5906	32
-
 #define TG3_RX_STD_MAX_SIZE_5700	512
 #define TG3_RX_STD_MAX_SIZE_5717	2048
 #define TG3_RX_JMB_MAX_SIZE_5700	256
@@ -2136,6 +2134,13 @@
 #define  NIC_SRAM_MBUF_POOL_BASE5705	0x00010000
 #define  NIC_SRAM_MBUF_POOL_SIZE5705	0x0000e000
 
+#define TG3_SRAM_RX_STD_BDCACHE_SIZE_5700	128
+#define TG3_SRAM_RX_STD_BDCACHE_SIZE_5755	64
+#define TG3_SRAM_RX_STD_BDCACHE_SIZE_5906	32
+
+#define TG3_SRAM_RX_JMB_BDCACHE_SIZE_5700	64
+#define TG3_SRAM_RX_JMB_BDCACHE_SIZE_5717	16
+
 
 /* Currently this is fixed. */
 #define TG3_PHY_MII_ADDR		0x01
-- 
1.7.3.4


