From: Greg Banks <gnb@sgi.com>
Subject: [PATCH] fix BUG in tg3_tx
Date: Mon, 24 May 2004 17:26:58 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040524072657.GC27177@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Network Development List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

G'day,

The tg3 transmit code assumes that tg3_tx() will never have to clean
up part of an skb queued for transmit.  This assumption is wrong;
sometimes tg3_tx() will be called partway through an skb, which trips
the first BUG() and drops the machine into kdb.  We've seen this happen
on 2.4 (rarely) and 2.6 (easy to reproduce, just run about 5 minutes'
worth of NFS or Samba load).

This patch against 2.6.6 fixes this problem by changing the shadow
transmit logic to put the non-NULL skb pointer in the *last* ring
entry instead of the first, so that it is freed only after all
parts have been DMAd onto the card, and can handle tg3_tx() being
called partway through.

SGI PV 903520 and PV 891640.



Index: linux/drivers/net/tg3.c
===================================================================
--- linux.orig/drivers/net/tg3.c	Mon May 10 12:32:38 2004
+++ linux/drivers/net/tg3.c	Mon May 24 17:23:12 2004
@@ -2103,10 +2103,6 @@
 	return err;
 }
 
-/* Tigon3 never reports partial packet sends.  So we do not
- * need special logic to handle SKBs that have not had all
- * of their frags sent yet, like SunGEM does.
- */
 static void tg3_tx(struct tg3 *tp)
 {
 	u32 hw_idx = tp->hw_status->idx[0].tx_consumer;
@@ -2115,37 +2111,26 @@
 	while (sw_idx != hw_idx) {
 		struct tx_ring_info *ri = &tp->tx_buffers[sw_idx];
 		struct sk_buff *skb = ri->skb;
-		int i;
-
-		if (unlikely(skb == NULL))
-			BUG();
-
-		pci_unmap_single(tp->pdev,
-				 pci_unmap_addr(ri, mapping),
-				 skb_headlen(skb),
-				 PCI_DMA_TODEVICE);
 
 		ri->skb = NULL;
-
-		sw_idx = NEXT_TX(sw_idx);
-
-		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-			if (unlikely(sw_idx == hw_idx))
-				BUG();
-
-			ri = &tp->tx_buffers[sw_idx];
-			if (unlikely(ri->skb != NULL))
-				BUG();
-
+		
+		if (ri->index == 0) {
+			pci_unmap_single(tp->pdev,
+					 pci_unmap_addr(ri, mapping),
+					 pci_unmap_len(ri, len),
+					 PCI_DMA_TODEVICE);
+		} else {
 			pci_unmap_page(tp->pdev,
 				       pci_unmap_addr(ri, mapping),
-				       skb_shinfo(skb)->frags[i].size,
+				       pci_unmap_len(ri, len),
 				       PCI_DMA_TODEVICE);
-
-			sw_idx = NEXT_TX(sw_idx);
 		}
-
-		dev_kfree_skb_irq(skb);
+		if (skb) {
+			if (unlikely(ri->index != skb_shinfo(skb)->nr_frags))
+				BUG();
+			dev_kfree_skb_irq(skb);
+		}
+		sw_idx = NEXT_TX(sw_idx);
 	}
 
 	tp->tx_cons = sw_idx;
@@ -2605,6 +2590,18 @@
 	schedule_work(&tp->reset_task);
 }
 
+static inline void tg3_set_txri(struct tg3 *tp, int entry, struct sk_buff *skb,
+				int index, dma_addr_t addr, int len)
+{
+	struct tx_ring_info *ri = &tp->tx_buffers[entry];
+
+	ri->skb = (index == skb_shinfo(skb)->nr_frags ? skb : NULL);
+	ri->index = index;
+	pci_unmap_addr_set(ri, mapping, addr);
+	pci_unmap_len_set(ri, len, len);
+}
+
+
 static void tg3_set_txd(struct tg3 *, int, dma_addr_t, int, u32, u32);
 
 static int tigon3_4gb_hwbug_workaround(struct tg3 *tp, struct sk_buff *skb,
@@ -2645,6 +2642,7 @@
 		if (i == 0) {
 			tp->tx_buffers[entry].skb = new_skb;
 			pci_unmap_addr_set(&tp->tx_buffers[entry], mapping, new_addr);
+			pci_unmap_len_set(&tp->tx_buffers[entry], len, new_skb->len);
 		} else {
 			tp->tx_buffers[entry].skb = NULL;
 		}
@@ -2804,8 +2802,7 @@
 	/* Queue skb data, a.k.a. the main skb fragment. */
 	mapping = pci_map_single(tp->pdev, skb->data, len, PCI_DMA_TODEVICE);
 
-	tp->tx_buffers[entry].skb = skb;
-	pci_unmap_addr_set(&tp->tx_buffers[entry], mapping, mapping);
+	tg3_set_txri(tp, entry, skb, 0, mapping, len);
 
 	would_hit_hwbug = 0;
 
@@ -2831,8 +2828,7 @@
 					       frag->page_offset,
 					       len, PCI_DMA_TODEVICE);
 
-			tp->tx_buffers[entry].skb = NULL;
-			pci_unmap_addr_set(&tp->tx_buffers[entry], mapping, mapping);
+			tg3_set_txri(tp, entry, skb, i+1, mapping, len);
 
 			if (tg3_4g_overflow_test(mapping, len)) {
 				/* Only one should match. */
@@ -3002,8 +2998,7 @@
 	/* Queue skb data, a.k.a. the main skb fragment. */
 	mapping = pci_map_single(tp->pdev, skb->data, len, PCI_DMA_TODEVICE);
 
-	tp->tx_buffers[entry].skb = skb;
-	pci_unmap_addr_set(&tp->tx_buffers[entry], mapping, mapping);
+	tg3_set_txri(tp, entry, skb, 0, mapping, len);
 
 	tg3_set_txd(tp, entry, mapping, len, base_flags,
 		    (skb_shinfo(skb)->nr_frags == 0) | (mss << 1));
@@ -3025,8 +3020,7 @@
 					       frag->page_offset,
 					       len, PCI_DMA_TODEVICE);
 
-			tp->tx_buffers[entry].skb = NULL;
-			pci_unmap_addr_set(&tp->tx_buffers[entry], mapping, mapping);
+			tg3_set_txri(tp, entry, skb, i+1, mapping, len);
 
 			tg3_set_txd(tp, entry, mapping, len,
 				    base_flags, (i == last));
Index: linux/drivers/net/tg3.h
===================================================================
--- linux.orig/drivers/net/tg3.h	Mon May 10 12:32:02 2004
+++ linux/drivers/net/tg3.h	Mon May 24 16:58:28 2004
@@ -1774,6 +1774,8 @@
 struct tx_ring_info {
 	struct sk_buff			*skb;
 	DECLARE_PCI_UNMAP_ADDR(mapping)
+	DECLARE_PCI_UNMAP_LEN(len)
+	u32				index;
 	u32				prev_vlan_tag;
 };
 




Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.
