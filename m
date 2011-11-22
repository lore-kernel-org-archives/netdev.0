From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: remove netdev_alloc_page and use __GFP_COLD
Date: Tue, 22 Nov 2011 21:57:41 +0100
Message-ID: <1321995461.19663.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Dimitris Michailidis <dm@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:60579 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714Ab1KVU6C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 15:58:02 -0500
Received: by bke11 with SMTP id 11so724484bke.19
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 12:58:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Given we dont use anymore the struct net_device *dev argument, and this
interface brings litle benefit, remove netdev_{alloc|free}_page(), to
debloat include/linux/skbuff.h a bit.

(Some drivers used a mix of these interfaces and alloc_pages())

When allocating a page given to device for DMA transfert (device to
memory), it makes sense to use a cold one (__GFP_COLD)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c          |    6 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c        |    5 -
 drivers/net/ethernet/intel/igb/igb_main.c         |    2 
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    2 
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    2 
 drivers/net/usb/cdc-phonet.c                      |   10 +--
 drivers/usb/gadget/f_phonet.c                     |   11 +---
 include/linux/skbuff.h                            |   32 ------------
 8 files changed, 18 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 140254c..2dae795 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -491,7 +491,7 @@ static unsigned int refill_fl(struct adapter *adap, struct sge_fl *q, int n,
 	__be64 *d = &q->desc[q->pidx];
 	struct rx_sw_desc *sd = &q->sdesc[q->pidx];
 
-	gfp |= __GFP_NOWARN;         /* failures are expected */
+	gfp |= __GFP_NOWARN | __GFP_COLD;
 
 #if FL_PG_ORDER > 0
 	/*
@@ -528,7 +528,7 @@ static unsigned int refill_fl(struct adapter *adap, struct sge_fl *q, int n,
 #endif
 
 	while (n--) {
-		pg = __netdev_alloc_page(adap->port[0], gfp);
+		pg = alloc_page(gfp);
 		if (unlikely(!pg)) {
 			q->alloc_failed++;
 			break;
@@ -537,7 +537,7 @@ static unsigned int refill_fl(struct adapter *adap, struct sge_fl *q, int n,
 		mapping = dma_map_page(adap->pdev_dev, pg, 0, PAGE_SIZE,
 				       PCI_DMA_FROMDEVICE);
 		if (unlikely(dma_mapping_error(adap->pdev_dev, mapping))) {
-			netdev_free_page(adap->port[0], pg);
+			put_page(pg);
 			goto out;
 		}
 		*d++ = cpu_to_be64(mapping);
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 8d5d55a..c381db2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -653,8 +653,7 @@ static unsigned int refill_fl(struct adapter *adapter, struct sge_fl *fl,
 
 alloc_small_pages:
 	while (n--) {
-		page = __netdev_alloc_page(adapter->port[0],
-					   gfp | __GFP_NOWARN);
+		page = alloc_page(gfp | __GFP_NOWARN | __GFP_COLD);
 		if (unlikely(!page)) {
 			fl->alloc_failed++;
 			break;
@@ -664,7 +663,7 @@ alloc_small_pages:
 		dma_addr = dma_map_page(adapter->pdev_dev, page, 0, PAGE_SIZE,
 				       PCI_DMA_FROMDEVICE);
 		if (unlikely(dma_mapping_error(adapter->pdev_dev, dma_addr))) {
-			netdev_free_page(adapter->port[0], page);
+			put_page(page);
 			break;
 		}
 		*d++ = cpu_to_be64(dma_addr);
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index bd9b30e..b66b8aa 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6135,7 +6135,7 @@ static bool igb_alloc_mapped_page(struct igb_ring *rx_ring,
 		return true;
 
 	if (!page) {
-		page = netdev_alloc_page(rx_ring->netdev);
+		page = alloc_page(GFP_ATOMIC | __GFP_COLD);
 		bi->page = page;
 		if (unlikely(!page)) {
 			rx_ring->rx_stats.alloc_failed++;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 820fc04..1b28ed9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1140,7 +1140,7 @@ void ixgbe_alloc_rx_buffers(struct ixgbe_ring *rx_ring, u16 cleaned_count)
 
 		if (ring_is_ps_enabled(rx_ring)) {
 			if (!bi->page) {
-				bi->page = netdev_alloc_page(rx_ring->netdev);
+				bi->page = alloc_page(GFP_ATOMIC | __GFP_COLD);
 				if (!bi->page) {
 					rx_ring->rx_stats.alloc_rx_page_failed++;
 					goto no_buffers;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 0c39bb1..5d1a643 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -366,7 +366,7 @@ static void ixgbevf_alloc_rx_buffers(struct ixgbevf_adapter *adapter,
 		if (!bi->page_dma &&
 		    (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED)) {
 			if (!bi->page) {
-				bi->page = netdev_alloc_page(adapter->netdev);
+				bi->page = alloc_page(GFP_ATOMIC | __GFP_COLD);
 				if (!bi->page) {
 					adapter->alloc_rx_page_failed++;
 					goto no_buffers;
diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.c
index a60d006..331e440 100644
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -130,7 +130,7 @@ static int rx_submit(struct usbpn_dev *pnd, struct urb *req, gfp_t gfp_flags)
 	struct page *page;
 	int err;
 
-	page = __netdev_alloc_page(dev, gfp_flags);
+	page = alloc_page(gfp_flags);
 	if (!page)
 		return -ENOMEM;
 
@@ -140,7 +140,7 @@ static int rx_submit(struct usbpn_dev *pnd, struct urb *req, gfp_t gfp_flags)
 	err = usb_submit_urb(req, gfp_flags);
 	if (unlikely(err)) {
 		dev_dbg(&dev->dev, "RX submit error (%d)\n", err);
-		netdev_free_page(dev, page);
+		put_page(page);
 	}
 	return err;
 }
@@ -208,9 +208,9 @@ static void rx_complete(struct urb *req)
 	dev->stats.rx_errors++;
 resubmit:
 	if (page)
-		netdev_free_page(dev, page);
+		put_page(page);
 	if (req)
-		rx_submit(pnd, req, GFP_ATOMIC);
+		rx_submit(pnd, req, GFP_ATOMIC | __GFP_COLD);
 }
 
 static int usbpn_close(struct net_device *dev);
@@ -229,7 +229,7 @@ static int usbpn_open(struct net_device *dev)
 	for (i = 0; i < rxq_size; i++) {
 		struct urb *req = usb_alloc_urb(0, GFP_KERNEL);
 
-		if (!req || rx_submit(pnd, req, GFP_KERNEL)) {
+		if (!req || rx_submit(pnd, req, GFP_KERNEL | __GFP_COLD)) {
 			usbpn_close(dev);
 			return -ENOMEM;
 		}
diff --git a/drivers/usb/gadget/f_phonet.c b/drivers/usb/gadget/f_phonet.c
index 16a509a..7cdcb63 100644
--- a/drivers/usb/gadget/f_phonet.c
+++ b/drivers/usb/gadget/f_phonet.c
@@ -298,11 +298,10 @@ static void pn_net_setup(struct net_device *dev)
 static int
 pn_rx_submit(struct f_phonet *fp, struct usb_request *req, gfp_t gfp_flags)
 {
-	struct net_device *dev = fp->dev;
 	struct page *page;
 	int err;
 
-	page = __netdev_alloc_page(dev, gfp_flags);
+	page = alloc_page(gfp_flags);
 	if (!page)
 		return -ENOMEM;
 
@@ -312,7 +311,7 @@ pn_rx_submit(struct f_phonet *fp, struct usb_request *req, gfp_t gfp_flags)
 
 	err = usb_ep_queue(fp->out_ep, req, gfp_flags);
 	if (unlikely(err))
-		netdev_free_page(dev, page);
+		put_page(page);
 	return err;
 }
 
@@ -374,9 +373,9 @@ static void pn_rx_complete(struct usb_ep *ep, struct usb_request *req)
 	}
 
 	if (page)
-		netdev_free_page(dev, page);
+		put_page(page);
 	if (req)
-		pn_rx_submit(fp, req, GFP_ATOMIC);
+		pn_rx_submit(fp, req, GFP_ATOMIC | __GFP_COLD);
 }
 
 /*-------------------------------------------------------------------------*/
@@ -436,7 +435,7 @@ static int pn_set_alt(struct usb_function *f, unsigned intf, unsigned alt)
 
 			netif_carrier_on(dev);
 			for (i = 0; i < phonet_rxq_size; i++)
-				pn_rx_submit(fp, fp->out_reqv[i], GFP_ATOMIC);
+				pn_rx_submit(fp, fp->out_reqv[i], GFP_ATOMIC | __GFP_COLD);
 		}
 		spin_unlock(&port->lock);
 		return 0;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 09b7ea5..cec0657 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1669,38 +1669,6 @@ static inline struct sk_buff *netdev_alloc_skb_ip_align(struct net_device *dev,
 }
 
 /**
- *	__netdev_alloc_page - allocate a page for ps-rx on a specific device
- *	@dev: network device to receive on
- *	@gfp_mask: alloc_pages_node mask
- *
- * 	Allocate a new page. dev currently unused.
- *
- * 	%NULL is returned if there is no free memory.
- */
-static inline struct page *__netdev_alloc_page(struct net_device *dev, gfp_t gfp_mask)
-{
-	return alloc_pages_node(NUMA_NO_NODE, gfp_mask, 0);
-}
-
-/**
- *	netdev_alloc_page - allocate a page for ps-rx on a specific device
- *	@dev: network device to receive on
- *
- * 	Allocate a new page. dev currently unused.
- *
- * 	%NULL is returned if there is no free memory.
- */
-static inline struct page *netdev_alloc_page(struct net_device *dev)
-{
-	return __netdev_alloc_page(dev, GFP_ATOMIC);
-}
-
-static inline void netdev_free_page(struct net_device *dev, struct page *page)
-{
-	__free_page(page);
-}
-
-/**
  * skb_frag_page - retrieve the page refered to by a paged fragment
  * @frag: the paged fragment
  *
