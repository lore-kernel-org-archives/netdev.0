From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH 3/3] skb: Add inline helper for getting the skb end offset
	from head
Date: Fri, 04 May 2012 17:26:56 -0700
Message-ID: <20120505002656.21292.89799.stgit@gitlad.jf.intel.com>
References: <20120505001059.21292.31647.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51781 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758571Ab2EEA04 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2012 20:26:56 -0400
In-Reply-To: <20120505001059.21292.31647.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the recent changes for how we compute the skb truesize it occurs to me
we are probably going to have a lot of calls to skb_end_pointer -
skb->head.  Instead of running all over the place doing that it would make
more sense to just make it a separate inline skb_end_offset(skb) that way
we can return the correct value without having gcc having to do all the
optimization to cancel out skb->head - skb->head.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/atm/ambassador.c             |    2 +-
 drivers/atm/idt77252.c               |    2 +-
 drivers/net/wimax/i2400m/usb-rx.c    |    2 +-
 drivers/staging/octeon/ethernet-tx.c |    2 +-
 include/linux/skbuff.h               |   12 +++++++++++-
 net/core/skbuff.c                    |   12 ++++++------
 6 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
index f8f41e0..89b30f3 100644
--- a/drivers/atm/ambassador.c
+++ b/drivers/atm/ambassador.c
@@ -802,7 +802,7 @@ static void fill_rx_pool (amb_dev * dev, unsigned char pool,
     }
     // cast needed as there is no %? for pointer differences
     PRINTD (DBG_SKB, "allocated skb at %p, head %p, area %li",
-	    skb, skb->head, (long) (skb_end_pointer(skb) - skb->head));
+	    skb, skb->head, (long) skb_end_offset(skb));
     rx.handle = virt_to_bus (skb);
     rx.host_address = cpu_to_be32 (virt_to_bus (skb->data));
     if (rx_give (dev, &rx, pool))
diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index 1c05212..8974bd2 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -1258,7 +1258,7 @@ idt77252_rx_raw(struct idt77252_dev *card)
 	tail = readl(SAR_REG_RAWCT);
 
 	pci_dma_sync_single_for_cpu(card->pcidev, IDT77252_PRV_PADDR(queue),
-				    skb_end_pointer(queue) - queue->head - 16,
+				    skb_end_offset(queue) - 16,
 				    PCI_DMA_FROMDEVICE);
 
 	while (head != tail) {
diff --git a/drivers/net/wimax/i2400m/usb-rx.c b/drivers/net/wimax/i2400m/usb-rx.c
index e325768..b78ee67 100644
--- a/drivers/net/wimax/i2400m/usb-rx.c
+++ b/drivers/net/wimax/i2400m/usb-rx.c
@@ -277,7 +277,7 @@ retry:
 		d_printf(1, dev, "RX: size changed to %d, received %d, "
 			 "copied %d, capacity %ld\n",
 			 rx_size, read_size, rx_skb->len,
-			 (long) (skb_end_pointer(new_skb) - new_skb->head));
+			 (long) skb_end_offset(new_skb));
 		goto retry;
 	}
 		/* In most cases, it happens due to the hardware scheduling a
diff --git a/drivers/staging/octeon/ethernet-tx.c b/drivers/staging/octeon/ethernet-tx.c
index 56d74dc..418ed03 100644
--- a/drivers/staging/octeon/ethernet-tx.c
+++ b/drivers/staging/octeon/ethernet-tx.c
@@ -344,7 +344,7 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 	if (unlikely
 	    (skb->truesize !=
-	     sizeof(*skb) + skb_end_pointer(skb) - skb->head)) {
+	     sizeof(*skb) + skb_end_offset(skb))) {
 		/*
 		   printk("TX buffer truesize has been changed\n");
 		 */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 37f5391..91ad5e2 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -645,11 +645,21 @@ static inline unsigned char *skb_end_pointer(const struct sk_buff *skb)
 {
 	return skb->head + skb->end;
 }
+
+static inline unsigned int skb_end_offset(const struct sk_buff *skb)
+{
+	return skb->end;
+}
 #else
 static inline unsigned char *skb_end_pointer(const struct sk_buff *skb)
 {
 	return skb->end;
 }
+
+static inline unsigned int skb_end_offset(const struct sk_buff *skb)
+{
+	return skb->end - skb->head;
+}
 #endif
 
 /* Internal */
@@ -2558,7 +2568,7 @@ static inline bool skb_is_recycleable(const struct sk_buff *skb, int skb_size)
 		return false;
 
 	skb_size = SKB_DATA_ALIGN(skb_size + NET_SKB_PAD);
-	if (skb_end_pointer(skb) - skb->head < skb_size)
+	if (skb_end_offset(skb) < skb_size)
 		return false;
 
 	if (skb_shared(skb) || skb_cloned(skb))
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 17e4b1e..2c35da8 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -829,7 +829,7 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 struct sk_buff *skb_copy(const struct sk_buff *skb, gfp_t gfp_mask)
 {
 	int headerlen = skb_headroom(skb);
-	unsigned int size = (skb_end_pointer(skb) - skb->head) + skb->data_len;
+	unsigned int size = skb_end_offset(skb) + skb->data_len;
 	struct sk_buff *n = alloc_skb(size, gfp_mask);
 
 	if (!n)
@@ -930,7 +930,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 {
 	int i;
 	u8 *data;
-	int size = nhead + (skb_end_pointer(skb) - skb->head) + ntail;
+	int size = nhead + skb_end_offset(skb) + ntail;
 	long off;
 
 	BUG_ON(nhead < 0);
@@ -2727,14 +2727,13 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 			if (unlikely(!nskb))
 				goto err;
 
-			hsize = skb_end_pointer(nskb) - nskb->head;
+			hsize = skb_end_offset(nskb);
 			if (skb_cow_head(nskb, doffset + headroom)) {
 				kfree_skb(nskb);
 				goto err;
 			}
 
-			nskb->truesize += skb_end_pointer(nskb) - nskb->head -
-					  hsize;
+			nskb->truesize += skb_end_offset(nskb) - hsize;
 			skb_release_head_state(nskb);
 			__skb_push(nskb, doffset);
 		} else {
@@ -2883,7 +2882,8 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		skb_frag_size_sub(frag, offset);
 
 		/* all fragments truesize : remove (head size + sk_buff) */
-		delta_truesize = skb->truesize - SKB_TRUESIZE(skb_end_pointer(skb) - skb->head);
+		delta_truesize = skb->truesize -
+				 SKB_TRUESIZE(skb_end_offset(skb));
 
 		skb->truesize -= skb->data_len;
 		skb->len -= skb->data_len;
