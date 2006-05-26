From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.18 2/3] tg3: Add recovery logic when MMIOs are
 re-ordered
Date: Fri, 26 May 2006 16:03:07 -0700
Message-ID: <1148684587.3930.9.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:34052 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1751743AbWE0AnJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 20:43:09 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add recovery logic when we suspect that the system is re-ordering
MMIOs. Re-ordered MMIOs to the send mailbox can cause bogus tx
completions and hit BUG_ON() in the tx completion path.

tg3 already has logic to handle re-ordered MMIOs by flushing the
MMIOs that must be strictly ordered (such as the send mailbox).
Determining when to enable the flush is currently a manual process
of adding known chipsets to a list.

The new code replaces the BUG_ON() in the tx completion path with the
call to tg3_tx_recover(). It will set the TG3_FLAG_MBOX_WRITE_REORDER
flag and reset the chip later in the workqueue to recover and start
flushing MMIOs to the mailbox.

A message to report the problem will be printed. We will then decide
whether or not to add the host bridge to the list of chipsets that do
re-ordering.

We may add some additional code later to print the host bridge's ID
so that the user can report it more easily.

The assumption that re-ordering can only happen on x86 systems is also
removed.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 3de5a62..bc3f884 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2967,6 +2967,29 @@ static int tg3_setup_phy(struct tg3 *tp,
 	return err;
 }
 
+/* This is called whenever we suspect that the system chipset is re-
+ * ordering the sequence of MMIO to the tx send mailbox. The symptom
+ * is bogus tx completions. We try to recover by setting the
+ * TG3_FLAG_MBOX_WRITE_REORDER flag and resetting the chip later
+ * in the workqueue.
+ */
+static void tg3_tx_recover(struct tg3 *tp)
+{
+	BUG_ON((tp->tg3_flags & TG3_FLAG_MBOX_WRITE_REORDER) ||
+	       tp->write32_tx_mbox == tg3_write_indirect_mbox);
+
+	printk(KERN_WARNING PFX "%s: The system may be re-ordering memory-"
+	       "mapped I/O cycles to the network device, attempting to "
+	       "recover. Please report the problem to the driver maintainer "
+	       "and include system chipset information.\n", tp->dev->name);
+
+	spin_lock(&tp->lock);
+	spin_lock(&tp->tx_lock);
+	tp->tg3_flags |= TG3_FLAG_TX_RECOVERY_PENDING;
+	spin_unlock(&tp->tx_lock);
+	spin_unlock(&tp->lock);
+}
+
 /* Tigon3 never reports partial packet sends.  So we do not
  * need special logic to handle SKBs that have not had all
  * of their frags sent yet, like SunGEM does.
@@ -2979,9 +3002,13 @@ static void tg3_tx(struct tg3 *tp)
 	while (sw_idx != hw_idx) {
 		struct tx_ring_info *ri = &tp->tx_buffers[sw_idx];
 		struct sk_buff *skb = ri->skb;
-		int i;
+		int i, tx_bug = 0;
+
+		if (unlikely(skb == NULL)) {
+			tg3_tx_recover(tp);
+			return;
+		}
 
-		BUG_ON(skb == NULL);
 		pci_unmap_single(tp->pdev,
 				 pci_unmap_addr(ri, mapping),
 				 skb_headlen(skb),
@@ -2992,10 +3019,9 @@ static void tg3_tx(struct tg3 *tp)
 		sw_idx = NEXT_TX(sw_idx);
 
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-			BUG_ON(sw_idx == hw_idx);
-
 			ri = &tp->tx_buffers[sw_idx];
-			BUG_ON(ri->skb != NULL);
+			if (unlikely(ri->skb != NULL || sw_idx == hw_idx))
+				tx_bug = 1;
 
 			pci_unmap_page(tp->pdev,
 				       pci_unmap_addr(ri, mapping),
@@ -3006,6 +3032,11 @@ static void tg3_tx(struct tg3 *tp)
 		}
 
 		dev_kfree_skb(skb);
+
+		if (unlikely(tx_bug)) {
+			tg3_tx_recover(tp);
+			return;
+		}
 	}
 
 	tp->tx_cons = sw_idx;
@@ -3333,6 +3364,11 @@ static int tg3_poll(struct net_device *n
 	/* run TX completion thread */
 	if (sblk->idx[0].tx_consumer != tp->tx_cons) {
 		tg3_tx(tp);
+		if (unlikely(tp->tg3_flags & TG3_FLAG_TX_RECOVERY_PENDING)) {
+			netif_rx_complete(netdev);
+			schedule_work(&tp->reset_task);
+			return 0;
+		}
 	}
 
 	/* run RX thread, within the bounds set by NAPI.
@@ -3581,6 +3617,13 @@ static void tg3_reset_task(void *_data)
 	restart_timer = tp->tg3_flags2 & TG3_FLG2_RESTART_TIMER;
 	tp->tg3_flags2 &= ~TG3_FLG2_RESTART_TIMER;
 
+	if (tp->tg3_flags & TG3_FLAG_TX_RECOVERY_PENDING) {
+		tp->write32_tx_mbox = tg3_write32_tx_mbox;
+		tp->write32_rx_mbox = tg3_write_flush_reg32;
+		tp->tg3_flags |= TG3_FLAG_MBOX_WRITE_REORDER;
+		tp->tg3_flags &= ~TG3_FLAG_TX_RECOVERY_PENDING;
+	}
+
 	tg3_halt(tp, RESET_KIND_SHUTDOWN, 0);
 	tg3_init_hw(tp, 1);
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 0e29b88..7f22559 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2155,11 +2155,7 @@ struct tg3 {
 #define TG3_FLAG_ENABLE_ASF		0x00000020
 #define TG3_FLAG_5701_REG_WRITE_BUG	0x00000040
 #define TG3_FLAG_POLL_SERDES		0x00000080
-#if defined(CONFIG_X86)
 #define TG3_FLAG_MBOX_WRITE_REORDER	0x00000100
-#else
-#define TG3_FLAG_MBOX_WRITE_REORDER	0	/* disables code too */
-#endif
 #define TG3_FLAG_PCIX_TARGET_HWBUG	0x00000200
 #define TG3_FLAG_WOL_SPEED_100MB	0x00000400
 #define TG3_FLAG_WOL_ENABLE		0x00000800
@@ -2172,6 +2168,7 @@ struct tg3 {
 #define TG3_FLAG_PCI_HIGH_SPEED		0x00040000
 #define TG3_FLAG_PCI_32BIT		0x00080000
 #define TG3_FLAG_SRAM_USE_CONFIG	0x00100000
+#define TG3_FLAG_TX_RECOVERY_PENDING	0x00200000
 #define TG3_FLAG_SERDES_WOL_CAP		0x00400000
 #define TG3_FLAG_JUMBO_RING_ENABLE	0x00800000
 #define TG3_FLAG_10_100_ONLY		0x01000000


