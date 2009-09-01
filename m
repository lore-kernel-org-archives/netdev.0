From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 02/18] tg3: Add per-int coalesce now member
Date: Tue, 1 Sep 2009 15:51:13 -0700
Message-ID: <1251867299.5917@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2530 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754097AbZIBEzF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 00:55:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each interrupt vector has its own bit in the host coalescing register to
force that vector's status block to be updated and generate an
interrupt.  This patch adds a member to the per-interrupt structure
that records which bit belongs to that vector.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   16 +++++++++-------
 drivers/net/tg3.h |    2 ++
 2 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 65ff286..ff65ae8 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -631,7 +631,7 @@ static void tg3_enable_ints(struct tg3 *tp)
 	if (tp->tg3_flags2 & TG3_FLG2_1SHOT_MSI)
 		tw32_mailbox_f(tnapi->int_mbox, tnapi->last_tag << 24);
 
-	coal_now = HOSTCC_MODE_NOW;
+	coal_now = tnapi->coal_now;
 
 	/* Force an initial interrupt */
 	if (!(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) &&
@@ -682,7 +682,7 @@ static void tg3_int_reenable(struct tg3_napi *tnapi)
 	if (!(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) &&
 	    tg3_has_work(tnapi))
 		tw32(HOSTCC_MODE, tp->coalesce_mode |
-		     (HOSTCC_MODE_ENABLE | HOSTCC_MODE_NOW));
+		     HOSTCC_MODE_ENABLE | tnapi->coal_now);
 }
 
 static inline void tg3_netif_stop(struct tg3 *tp)
@@ -7622,7 +7622,7 @@ static void tg3_timer(unsigned long __opaque)
 			     tp->grc_local_ctrl | GRC_LCLCTRL_SETINT);
 		} else {
 			tw32(HOSTCC_MODE, tp->coalesce_mode |
-			     (HOSTCC_MODE_ENABLE | HOSTCC_MODE_NOW));
+			     HOSTCC_MODE_ENABLE | HOSTCC_MODE_NOW);
 		}
 
 		if (!(tr32(WDMAC_MODE) & WDMAC_MODE_ENABLE)) {
@@ -7765,7 +7765,7 @@ static int tg3_test_interrupt(struct tg3 *tp)
 	tg3_enable_ints(tp);
 
 	tw32_f(HOSTCC_MODE, tp->coalesce_mode | HOSTCC_MODE_ENABLE |
-	       HOSTCC_MODE_NOW);
+	       tnapi->coal_now);
 
 	for (i = 0; i < 5; i++) {
 		u32 int_mbox, misc_host_ctrl;
@@ -9840,7 +9840,7 @@ static int tg3_test_memory(struct tg3 *tp)
 static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 {
 	u32 mac_mode, rx_start_idx, rx_idx, tx_idx, opaque_key;
-	u32 desc_idx;
+	u32 desc_idx, coal_now;
 	struct sk_buff *skb, *rx_skb;
 	u8 *tx_data;
 	dma_addr_t map;
@@ -9851,6 +9851,7 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 
 	tnapi = &tp->napi[0];
 	rnapi = &tp->napi[0];
+	coal_now = tnapi->coal_now | rnapi->coal_now;
 
 	if (loopback_mode == TG3_MAC_LOOPBACK) {
 		/* HW errata - mac loopback fails in some cases on 5780.
@@ -9929,7 +9930,7 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 	map = pci_map_single(tp->pdev, skb->data, tx_len, PCI_DMA_TODEVICE);
 
 	tw32_f(HOSTCC_MODE, tp->coalesce_mode | HOSTCC_MODE_ENABLE |
-	     HOSTCC_MODE_NOW);
+	       rnapi->coal_now);
 
 	udelay(10);
 
@@ -9950,7 +9951,7 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 	/* 250 usec to allow enough time on some 10/100 Mbps devices.  */
 	for (i = 0; i < 25; i++) {
 		tw32_f(HOSTCC_MODE, tp->coalesce_mode | HOSTCC_MODE_ENABLE |
-		       HOSTCC_MODE_NOW);
+		       coal_now);
 
 		udelay(10);
 
@@ -13428,6 +13429,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	tp->napi[0].int_mbox = MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW;
 	tp->napi[0].consmbox = MAILBOX_RCVRET_CON_IDX_0 + TG3_64BIT_REG_LOW;
 	tp->napi[0].prodmbox = MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW;
+	tp->napi[0].coal_now = HOSTCC_MODE_NOW;
 	tp->napi[0].tx_pending = TG3_DEF_TX_RING_PENDING;
 	netif_napi_add(dev, &tp->napi[0].napi, tg3_poll, 64);
 	dev->ethtool_ops = &tg3_ethtool_ops;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index a816b2c..626b968 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1031,6 +1031,7 @@
 #define  HOSTCC_MODE_CLRTICK_TXBD	 0x00000400
 #define  HOSTCC_MODE_NOINT_ON_NOW	 0x00000800
 #define  HOSTCC_MODE_NOINT_ON_FORCE	 0x00001000
+#define  HOSTCC_MODE_COAL_VEC1_NOW	 0x00002000
 #define HOSTCC_STATUS			0x00003c04
 #define  HOSTCC_STATUS_ERROR_ATTN	 0x00000004
 #define HOSTCC_RXCOL_TICKS		0x00003c08
@@ -2497,6 +2498,7 @@ struct tg3_napi {
 	u32				last_tag;
 	u32				last_irq_tag;
 	u32				int_mbox;
+	u32				coal_now;
 	u32				tx_prod;
 	u32				tx_cons;
 	u32				tx_pending;
-- 
1.6.3.3


