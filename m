From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 2/2] [SK_BUFF]: Convert skb->end to sk_buff_data_t
Date: Sun, 18 Mar 2007 18:50:49 -0300
Message-ID: <20070318215049.GD17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.228]:50334 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933305AbXCRVuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2007 17:50:55 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1064000wxd
        for <netdev@vger.kernel.org>; Sun, 18 Mar 2007 14:50:55 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now to convert the last one, skb->data, that will allow many simplifications
and removal of some of the offset helpers.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 arch/ia64/sn/kernel/xpnet.c                   |    6 +-
 drivers/atm/ambassador.c                      |    2 +-
 drivers/atm/idt77252.c                        |   24 +++++++----
 drivers/infiniband/hw/cxgb3/iwch_cm.c         |    2 +-
 drivers/net/cris/eth_v10.c                    |    3 +-
 drivers/net/forcedeth.c                       |   30 +++++++++-----
 drivers/net/macb.c                            |    2 +-
 drivers/net/wan/lmc/lmc_main.c                |    2 +-
 drivers/net/wireless/hostap/hostap_80211_rx.c |    2 +-
 drivers/usb/atm/usbatm.c                      |    4 +-
 include/linux/skbuff.h                        |   23 ++++++++--
 net/atm/lec.c                                 |    2 +-
 net/core/skbuff.c                             |   53 ++++++++++++++++---------
 net/ieee80211/ieee80211_rx.c                  |    2 +-
 net/netlink/af_netlink.c                      |    2 +-
 15 files changed, 102 insertions(+), 57 deletions(-)

diff --git a/arch/ia64/sn/kernel/xpnet.c b/arch/ia64/sn/kernel/xpnet.c
index eb416c9..98d7914 100644
--- a/arch/ia64/sn/kernel/xpnet.c
+++ b/arch/ia64/sn/kernel/xpnet.c
@@ -264,7 +264,7 @@ xpnet_receive(partid_t partid, int channel, struct xpnet_message *msg)
 
 	dev_dbg(xpnet, "<skb->head=0x%p skb->data=0x%p skb->tail=0x%p "
 		"skb->end=0x%p skb->len=%d\n", (void *) skb->head,
-		(void *)skb->data, skb_tail_pointer(skb), (void *)skb->end,
+		(void *)skb->data, skb_tail_pointer(skb), skb_end_pointer(skb),
 		skb->len);
 
 	skb->protocol = eth_type_trans(skb, xpnet_device);
@@ -273,7 +273,7 @@ xpnet_receive(partid_t partid, int channel, struct xpnet_message *msg)
 	dev_dbg(xpnet, "passing skb to network layer; \n\tskb->head=0x%p "
 		"skb->data=0x%p skb->tail=0x%p skb->end=0x%p skb->len=%d\n",
 		(void *)skb->head, (void *)skb->data, skb_tail_pointer(skb),
-		(void *) skb->end, skb->len);
+		skb_end_pointer(skb), skb->len);
 
 
 	xpnet_device->last_rx = jiffies;
@@ -475,7 +475,7 @@ xpnet_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev_dbg(xpnet, ">skb->head=0x%p skb->data=0x%p skb->tail=0x%p "
 		"skb->end=0x%p skb->len=%d\n", (void *) skb->head,
-		(void *)skb->data, skb_tail_pointer(skb), (void *)skb->end,
+		(void *)skb->data, skb_tail_pointer(skb), skb_end_pointer(skb),
 		skb->len);
 
 
diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
index 3c372e0..59651ab 100644
--- a/drivers/atm/ambassador.c
+++ b/drivers/atm/ambassador.c
@@ -821,7 +821,7 @@ static inline void fill_rx_pool (amb_dev * dev, unsigned char pool,
     }
     // cast needed as there is no %? for pointer differences
     PRINTD (DBG_SKB, "allocated skb at %p, head %p, area %li",
-	    skb, skb->head, (long) (skb->end - skb->head));
+	    skb, skb->head, (long) (skb_end_pointer(skb) - skb->head));
     rx.handle = virt_to_bus (skb);
     rx.host_address = cpu_to_be32 (virt_to_bus (skb->data));
     if (rx_give (dev, &rx, pool))
diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index 1e49799..20f2a3a 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -1065,7 +1065,8 @@ dequeue_rx(struct idt77252_dev *card, struct rsq_entry *rsqe)
 	vcc = vc->rx_vcc;
 
 	pci_dma_sync_single_for_cpu(card->pcidev, IDT77252_PRV_PADDR(skb),
-				    skb->end - skb->data, PCI_DMA_FROMDEVICE);
+				    skb_end_pointer(skb) - skb->data,
+				    PCI_DMA_FROMDEVICE);
 
 	if ((vcc->qos.aal == ATM_AAL0) ||
 	    (vcc->qos.aal == ATM_AAL34)) {
@@ -1194,7 +1195,8 @@ dequeue_rx(struct idt77252_dev *card, struct rsq_entry *rsqe)
 		}
 
 		pci_unmap_single(card->pcidev, IDT77252_PRV_PADDR(skb),
-				 skb->end - skb->data, PCI_DMA_FROMDEVICE);
+				 skb_end_pointer(skb) - skb->data,
+				 PCI_DMA_FROMDEVICE);
 		sb_pool_remove(card, skb);
 
 		skb_trim(skb, len);
@@ -1267,7 +1269,7 @@ idt77252_rx_raw(struct idt77252_dev *card)
 	tail = readl(SAR_REG_RAWCT);
 
 	pci_dma_sync_single_for_cpu(card->pcidev, IDT77252_PRV_PADDR(queue),
-				    queue->end - queue->head - 16,
+				    skb_end_pointer(queue) - queue->head - 16,
 				    PCI_DMA_FROMDEVICE);
 
 	while (head != tail) {
@@ -1363,7 +1365,8 @@ drop:
 				queue = card->raw_cell_head;
 				pci_dma_sync_single_for_cpu(card->pcidev,
 							    IDT77252_PRV_PADDR(queue),
-							    queue->end - queue->data,
+							    (skb_end_pointer(queue) -
+							     queue->data),
 							    PCI_DMA_FROMDEVICE);
 			} else {
 				card->raw_cell_head = NULL;
@@ -1875,7 +1878,7 @@ add_rx_skb(struct idt77252_dev *card, int queue,
 		}
 
 		paddr = pci_map_single(card->pcidev, skb->data,
-				       skb->end - skb->data,
+				       skb_end_pointer(skb) - skb->data,
 				       PCI_DMA_FROMDEVICE);
 		IDT77252_PRV_PADDR(skb) = paddr;
 
@@ -1889,7 +1892,7 @@ add_rx_skb(struct idt77252_dev *card, int queue,
 
 outunmap:
 	pci_unmap_single(card->pcidev, IDT77252_PRV_PADDR(skb),
-			 skb->end - skb->data, PCI_DMA_FROMDEVICE);
+			 skb_end_pointer(skb) - skb->data, PCI_DMA_FROMDEVICE);
 
 	handle = IDT77252_PRV_POOL(skb);
 	card->sbpool[POOL_QUEUE(handle)].skb[POOL_INDEX(handle)] = NULL;
@@ -1906,12 +1909,14 @@ recycle_rx_skb(struct idt77252_dev *card, struct sk_buff *skb)
 	int err;
 
 	pci_dma_sync_single_for_device(card->pcidev, IDT77252_PRV_PADDR(skb),
-				       skb->end - skb->data, PCI_DMA_FROMDEVICE);
+				       skb_end_pointer(skb) - skb->data,
+				       PCI_DMA_FROMDEVICE);
 
 	err = push_rx_skb(card, skb, POOL_QUEUE(handle));
 	if (err) {
 		pci_unmap_single(card->pcidev, IDT77252_PRV_PADDR(skb),
-				 skb->end - skb->data, PCI_DMA_FROMDEVICE);
+				 skb_end_pointer(skb) - skb->data,
+				 PCI_DMA_FROMDEVICE);
 		sb_pool_remove(card, skb);
 		dev_kfree_skb(skb);
 	}
@@ -3123,7 +3128,8 @@ deinit_card(struct idt77252_dev *card)
 			if (skb) {
 				pci_unmap_single(card->pcidev,
 						 IDT77252_PRV_PADDR(skb),
-						 skb->end - skb->data,
+						 (skb_end_pointer(skb) -
+						  skb->data),
 						 PCI_DMA_FROMDEVICE);
 				card->sbpool[i].skb[j] = NULL;
 				dev_kfree_skb(skb);
diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index 5f7f482..f038c48 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -478,7 +478,7 @@ static void send_mpa_req(struct iwch_ep *ep, struct sk_buff *skb)
 	BUG_ON(skb_cloned(skb));
 
 	mpalen = sizeof(*mpa) + ep->plen;
-	if (skb->data + mpalen + sizeof(*req) > skb->end) {
+	if (skb->data + mpalen + sizeof(*req) > skb_end_pointer(skb)) {
 		kfree_skb(skb);
 		skb=alloc_skb(mpalen + sizeof(*req), GFP_KERNEL);
 		if (!skb) {
diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index 7feb9c5..5bdf5ca 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -1348,7 +1348,8 @@ e100_rx(struct net_device *dev)
 
 #ifdef ETHDEBUG
 		printk("head = 0x%x, data = 0x%x, tail = 0x%x, end = 0x%x\n",
-		  skb->head, skb->data, skb_tail_pointer(skb), skb->end);
+		       skb->head, skb->data, skb_tail_pointer(skb),
+		       skb_end_pointer(skb));
 		printk("copying packet to 0x%x.\n", skb_data_ptr);
 #endif
 
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index ce6e925..442f10e 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1386,9 +1386,13 @@ static int nv_alloc_rx(struct net_device *dev)
 		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz + NV_RX_ALLOC_PAD);
 		if (skb) {
 			np->put_rx_ctx->skb = skb;
-			np->put_rx_ctx->dma = pci_map_single(np->pci_dev, skb->data,
-							     skb->end-skb->data, PCI_DMA_FROMDEVICE);
-			np->put_rx_ctx->dma_len = skb->end-skb->data;
+			np->put_rx_ctx->dma = pci_map_single(np->pci_dev,
+							     skb->data,
+							(skb_end_pointer(skb) -
+							 skb->data),
+							     PCI_DMA_FROMDEVICE);
+			np->put_rx_ctx->dma_len = (skb_end_pointer(skb) -
+						   skb->data);
 			np->put_rx.orig->buf = cpu_to_le32(np->put_rx_ctx->dma);
 			wmb();
 			np->put_rx.orig->flaglen = cpu_to_le32(np->rx_buf_sz | NV_RX_AVAIL);
@@ -1416,9 +1420,13 @@ static int nv_alloc_rx_optimized(struct net_device *dev)
 		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz + NV_RX_ALLOC_PAD);
 		if (skb) {
 			np->put_rx_ctx->skb = skb;
-			np->put_rx_ctx->dma = pci_map_single(np->pci_dev, skb->data,
-							     skb->end-skb->data, PCI_DMA_FROMDEVICE);
-			np->put_rx_ctx->dma_len = skb->end-skb->data;
+			np->put_rx_ctx->dma = pci_map_single(np->pci_dev,
+							     skb->data,
+							     (skb_end_pointer(skb) -
+							      skb->data),
+							     PCI_DMA_FROMDEVICE);
+			np->put_rx_ctx->dma_len = (skb_end_pointer(skb) -
+						   skb->data);
 			np->put_rx.ex->bufhigh = cpu_to_le64(np->put_rx_ctx->dma) >> 32;
 			np->put_rx.ex->buflow = cpu_to_le64(np->put_rx_ctx->dma) & 0x0FFFFFFFF;
 			wmb();
@@ -1602,8 +1610,9 @@ static void nv_drain_rx(struct net_device *dev)
 		wmb();
 		if (np->rx_skb[i].skb) {
 			pci_unmap_single(np->pci_dev, np->rx_skb[i].dma,
-						np->rx_skb[i].skb->end-np->rx_skb[i].skb->data,
-						PCI_DMA_FROMDEVICE);
+					 (skb_end_pointer(np->rx_skb[i].skb) -
+					  np->rx_skb[i].skb->data),
+					 PCI_DMA_FROMDEVICE);
 			dev_kfree_skb(np->rx_skb[i].skb);
 			np->rx_skb[i].skb = NULL;
 		}
@@ -4374,7 +4383,8 @@ static int nv_loopback_test(struct net_device *dev)
 	for (i = 0; i < pkt_len; i++)
 		pkt_data[i] = (u8)(i & 0xff);
 	test_dma_addr = pci_map_single(np->pci_dev, tx_skb->data,
-				       tx_skb->end-tx_skb->data, PCI_DMA_FROMDEVICE);
+				       (skb_end_pointer(tx_skb) -
+					tx_skb->data), PCI_DMA_FROMDEVICE);
 
 	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
 		np->tx_ring.orig[0].buf = cpu_to_le32(test_dma_addr);
@@ -4431,7 +4441,7 @@ static int nv_loopback_test(struct net_device *dev)
 	}
 
 	pci_unmap_page(np->pci_dev, test_dma_addr,
-		       tx_skb->end-tx_skb->data,
+		       (skb_end_pointer(tx_skb) - tx_skb->data),
 		       PCI_DMA_TODEVICE);
 	dev_kfree_skb_any(tx_skb);
  out:
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 98bf51a..9e233f8 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -576,7 +576,7 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev_dbg(&bp->pdev->dev,
 		"start_xmit: len %u head %p data %p tail %p end %p\n",
 		skb->len, skb->head, skb->data,
-		skb_tail_pointer(skb), skb->end);
+		skb_tail_pointer(skb), skb_end_pointer(skb));
 	dev_dbg(&bp->pdev->dev,
 		"data:");
 	for (i = 0; i < 16; i++)
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index b731f3a..5bb18c0 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -1932,7 +1932,7 @@ static void lmc_softreset (lmc_softc_t * const sc) /*fold00*/
         sc->lmc_rxring[i].status = 0x80000000;
 
         /* used to be PKT_BUF_SZ now uses skb since we lose some to head room */
-        sc->lmc_rxring[i].length = skb->end - skb->data;
+        sc->lmc_rxring[i].length = skb_end_pointer(skb) - skb->data;
 
         /* use to be tail which is dumb since you're thinking why write
          * to the end of the packj,et but since there's nothing there tail == data
diff --git a/drivers/net/wireless/hostap/hostap_80211_rx.c b/drivers/net/wireless/hostap/hostap_80211_rx.c
index 5e3e9e2..35a3a50 100644
--- a/drivers/net/wireless/hostap/hostap_80211_rx.c
+++ b/drivers/net/wireless/hostap/hostap_80211_rx.c
@@ -922,7 +922,7 @@ void hostap_80211_rx(struct net_device *dev, struct sk_buff *skb,
 		if (frag != 0)
 			flen -= hdrlen;
 
-		if (skb_tail_pointer(frag_skb) + flen > frag_skb->end) {
+		if (frag_skb->tail + flen > frag_skb->end) {
 			printk(KERN_WARNING "%s: host decrypted and "
 			       "reassembled frame did not fit skb\n",
 			       dev->name);
diff --git a/drivers/usb/atm/usbatm.c b/drivers/usb/atm/usbatm.c
index 4d8f282..a076f73 100644
--- a/drivers/usb/atm/usbatm.c
+++ b/drivers/usb/atm/usbatm.c
@@ -335,12 +335,12 @@ static void usbatm_extract_one_cell(struct usbatm_data *instance, unsigned char
 
 	sarb = instance->cached_vcc->sarb;
 
-	if (skb_tail_pointer(sarb) + ATM_CELL_PAYLOAD > sarb->end) {
+	if (sarb->tail + ATM_CELL_PAYLOAD > sarb->end) {
 		atm_rldbg(instance, "%s: buffer overrun (sarb->len %u, vcc: 0x%p)!\n",
 				__func__, sarb->len, vcc);
 		/* discard cells already received */
 		skb_trim(sarb, 0);
-		UDSL_ASSERT(skb_tail_pointer(sarb) + ATM_CELL_PAYLOAD <= sarb->end);
+		UDSL_ASSERT(sarb->tail + ATM_CELL_PAYLOAD <= sarb->end);
 	}
 
 	memcpy(skb_tail_pointer(sarb), source + ATM_CELL_HEADER, ATM_CELL_PAYLOAD);
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 3b1b4cb..4803e4d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -307,9 +307,9 @@ struct sk_buff {
 	sk_buff_data_t		mac_header;
 	/* These elements must be at the end, see alloc_skb() for details.  */
 	sk_buff_data_t		tail;
+	sk_buff_data_t		end;
 	unsigned char		*head,
-				*data,
-				*end;
+				*data;
 	unsigned int		truesize;
 	atomic_t		users;
 };
@@ -397,8 +397,20 @@ extern unsigned int   skb_find_text(struct sk_buff *skb, unsigned int from,
 				    unsigned int to, struct ts_config *config,
 				    struct ts_state *state);
 
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+static inline unsigned char *skb_end_pointer(const struct sk_buff *skb)
+{
+	return skb->head + skb->end;
+}
+#else
+static inline unsigned char *skb_end_pointer(const struct sk_buff *skb)
+{
+	return skb->end;
+}
+#endif
+
 /* Internal */
-#define skb_shinfo(SKB)		((struct skb_shared_info *)((SKB)->end))
+#define skb_shinfo(SKB)	((struct skb_shared_info *)(skb_end_pointer(SKB)))
 
 /**
  *	skb_queue_empty - check if a queue is empty
@@ -841,6 +853,7 @@ static inline void skb_set_tail_pointer(struct sk_buff *skb, const int offset)
 {
 	skb->tail = skb->data + offset;
 }
+
 #endif /* NET_SKBUFF_DATA_USES_OFFSET */
 
 /*
@@ -870,7 +883,7 @@ static inline unsigned char *skb_put(struct sk_buff *skb, unsigned int len)
 	SKB_LINEAR_ASSERT(skb);
 	skb->tail += len;
 	skb->len  += len;
-	if (unlikely(skb_tail_pointer(skb) > skb->end))
+	if (unlikely(skb->tail > skb->end))
 		skb_over_panic(skb, len, current_text_addr());
 	return tmp;
 }
@@ -966,7 +979,7 @@ static inline int skb_headroom(const struct sk_buff *skb)
  */
 static inline int skb_tailroom(const struct sk_buff *skb)
 {
-	return skb_is_nonlinear(skb) ? 0 : skb->end - skb_tail_pointer(skb);
+	return skb_is_nonlinear(skb) ? 0 : skb->end - skb->tail;
 }
 
 /**
diff --git a/net/atm/lec.c b/net/atm/lec.c
index a8c6b28..4b3e72f 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -284,7 +284,7 @@ static int lec_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	DPRINTK("skbuff head:%lx data:%lx tail:%lx end:%lx\n",
 		(long)skb->head, (long)skb->data, (long)skb_tail_pointer(skb),
-		(long)skb->end);
+		(long)skb_end_pointer(skb));
 #if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
 	if (memcmp(skb->data, bridge_ula_lec, sizeof(bridge_ula_lec)) == 0)
 		lec_handle_bridge(skb, dev);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index a6ef2d7..c274ea3 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -87,9 +87,9 @@ static struct kmem_cache *skbuff_fclone_cache __read_mostly;
 void skb_over_panic(struct sk_buff *skb, int sz, void *here)
 {
 	printk(KERN_EMERG "skb_over_panic: text:%p len:%d put:%d head:%p "
-			  "data:%p tail:%#lx end:%p dev:%s\n",
+			  "data:%p tail:%#lx end:%#lx dev:%s\n",
 	       here, skb->len, sz, skb->head, skb->data,
-	       (unsigned long)skb->tail, skb->end,
+	       (unsigned long)skb->tail, (unsigned long)skb->end,
 	       skb->dev ? skb->dev->name : "<NULL>");
 	BUG();
 }
@@ -106,9 +106,9 @@ void skb_over_panic(struct sk_buff *skb, int sz, void *here)
 void skb_under_panic(struct sk_buff *skb, int sz, void *here)
 {
 	printk(KERN_EMERG "skb_under_panic: text:%p len:%d put:%d head:%p "
-			  "data:%p tail:%#lx end:%p dev:%s\n",
+			  "data:%p tail:%#lx end:%#lx dev:%s\n",
 	       here, skb->len, sz, skb->head, skb->data,
-	       (unsigned long)skb->tail, skb->end,
+	       (unsigned long)skb->tail, (unsigned long)skb->end,
 	       skb->dev ? skb->dev->name : "<NULL>");
 	BUG();
 }
@@ -170,7 +170,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	skb->head = data;
 	skb->data = data;
 	skb_reset_tail_pointer(skb);
-	skb->end  = data + size;
+	skb->end = skb->tail + size;
 	/* make sure we initialize shinfo sequentially */
 	shinfo = skb_shinfo(skb);
 	atomic_set(&shinfo->dataref, 1);
@@ -239,7 +239,7 @@ struct sk_buff *alloc_skb_from_cache(struct kmem_cache *cp,
 	skb->head = data;
 	skb->data = data;
 	skb_reset_tail_pointer(skb);
-	skb->end  = data + size;
+	skb->end  = skb->tail + size;
 
 	atomic_set(&(skb_shinfo(skb)->dataref), 1);
 	skb_shinfo(skb)->nr_frags  = 0;
@@ -576,8 +576,12 @@ struct sk_buff *skb_copy(const struct sk_buff *skb, gfp_t gfp_mask)
 	/*
 	 *	Allocate the copy buffer
 	 */
-	struct sk_buff *n = alloc_skb(skb->end - skb->head + skb->data_len,
-				      gfp_mask);
+	struct sk_buff *n;
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+	n = alloc_skb(skb->end + skb->data_len, gfp_mask);
+#else
+	n = alloc_skb(skb->end - skb->head + skb->data_len, gfp_mask);
+#endif
 	if (!n)
 		return NULL;
 
@@ -614,8 +618,12 @@ struct sk_buff *pskb_copy(struct sk_buff *skb, gfp_t gfp_mask)
 	/*
 	 *	Allocate the copy buffer
 	 */
-	struct sk_buff *n = alloc_skb(skb->end - skb->head, gfp_mask);
-
+	struct sk_buff *n;
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+	n = alloc_skb(skb->end, gfp_mask);
+#else
+	n = alloc_skb(skb->end - skb->head, gfp_mask);
+#endif
 	if (!n)
 		goto out;
 
@@ -673,7 +681,11 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 {
 	int i;
 	u8 *data;
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+	int size = nhead + skb->end + ntail;
+#else
 	int size = nhead + (skb->end - skb->head) + ntail;
+#endif
 	long off;
 
 	if (skb_shared(skb))
@@ -688,12 +700,13 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	/* Copy only real data... and, alas, header. This should be
 	 * optimized for the cases when header is void. */
 	memcpy(data + nhead, skb->head,
-		skb->tail
-#ifndef NET_SKBUFF_DATA_USES_OFFSET
-		- skb->head
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+		skb->tail);
+#else
+		skb->tail - skb->head);
 #endif
-		);
-	memcpy(data + size, skb->end, sizeof(struct skb_shared_info));
+	memcpy(data + size, skb_end_pointer(skb),
+	       sizeof(struct skb_shared_info));
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
 		get_page(skb_shinfo(skb)->frags[i].page);
@@ -706,9 +719,11 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	off = (data + nhead) - skb->head;
 
 	skb->head     = data;
-	skb->end      = data + size;
 	skb->data    += off;
-#ifndef NET_SKBUFF_DATA_USES_OFFSET
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+	skb->end      = size;
+#else
+	skb->end      = skb->head + size;
 	/* {transport,network,mac}_header and tail are relative to skb->head */
 	skb->tail	      += off;
 	skb->transport_header += off;
@@ -825,7 +840,7 @@ int skb_pad(struct sk_buff *skb, int pad)
 		return 0;
 	}
 
-	ntail = skb->data_len + pad - (skb->end - skb_tail_pointer(skb));
+	ntail = skb->data_len + pad - (skb->end - skb->tail);
 	if (likely(skb_cloned(skb) || ntail > 0)) {
 		err = pskb_expand_head(skb, 0, ntail, GFP_ATOMIC);
 		if (unlikely(err))
@@ -963,7 +978,7 @@ unsigned char *__pskb_pull_tail(struct sk_buff *skb, int delta)
 	 * plus 128 bytes for future expansions. If we have enough
 	 * room at tail, reallocate without expansion only if skb is cloned.
 	 */
-	int i, k, eat = (skb_tail_pointer(skb) + delta) - skb->end;
+	int i, k, eat = (skb->tail + delta) - skb->end;
 
 	if (eat > 0 || skb_cloned(skb)) {
 		if (pskb_expand_head(skb, 0, eat > 0 ? eat + 128 : 0,
diff --git a/net/ieee80211/ieee80211_rx.c b/net/ieee80211/ieee80211_rx.c
index 2b85494..59a765c 100644
--- a/net/ieee80211/ieee80211_rx.c
+++ b/net/ieee80211/ieee80211_rx.c
@@ -595,7 +595,7 @@ int ieee80211_rx(struct ieee80211_device *ieee, struct sk_buff *skb,
 		if (frag != 0)
 			flen -= hdrlen;
 
-		if (skb_tail_pointer(frag_skb) + flen > frag_skb->end) {
+		if (frag_skb->tail + flen > frag_skb->end) {
 			printk(KERN_WARNING "%s: host decrypted and "
 			       "reassembled frame did not fit skb\n",
 			       dev->name);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index e0b1985..b7bfab1 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -785,7 +785,7 @@ static inline struct sk_buff *netlink_trim(struct sk_buff *skb,
 
 	skb_orphan(skb);
 
-	delta = skb->end - skb_tail_pointer(skb);
+	delta = skb->end - skb->tail;
 	if (delta * 2 < skb->truesize)
 		return skb;
 
-- 
1.5.0.3

