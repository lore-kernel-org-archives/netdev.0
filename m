From: Joby Poriyath <joby.poriyath@citrix.com>
Subject: [PATCH net-next] xen-netback: allocate xenvif arrays using vzalloc.
Date: Tue, 29 Oct 2013 15:27:13 +0000
Message-ID: <20131029152628.GA3065@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<xen-devel@lists.xen.org>, <andrew.bennieston@citrix.com>,
	<david.vrabel@citrix.com>, <malcolm.crossley@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:42664 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752086Ab3J2P1P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 11:27:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will reduce memory pressure when allocating struct xenvif.

The size of xenvif struct has increased from 168 to 36632 bytes (on x86-32).
See commit b3f980bd827e6e81a050c518d60ed7811a83061d. This resulted in
occasional netdev allocation failure in dom0 with 752MiB RAM, due to
fragmented memory.

Signed-off-by: Joby Poriyath <joby.poriyath@citrix.com>
Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
---
 drivers/net/xen-netback/common.h    |   10 +++---
 drivers/net/xen-netback/interface.c |   61 +++++++++++++++++++++++++++++++++++
 drivers/net/xen-netback/netback.c   |    6 ++--
 3 files changed, 69 insertions(+), 8 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 55b8dec..82515a3 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -114,17 +114,17 @@ struct xenvif {
 	char tx_irq_name[IFNAMSIZ+4]; /* DEVNAME-tx */
 	struct xen_netif_tx_back_ring tx;
 	struct sk_buff_head tx_queue;
-	struct page *mmap_pages[MAX_PENDING_REQS];
+	struct page **mmap_pages; /* [MAX_PENDING_REQS]; */
 	pending_ring_idx_t pending_prod;
 	pending_ring_idx_t pending_cons;
 	u16 pending_ring[MAX_PENDING_REQS];
-	struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
+	struct pending_tx_info *pending_tx_info; /* [MAX_PENDING_REQS]; */
 
 	/* Coalescing tx requests before copying makes number of grant
 	 * copy ops greater or equal to number of slots required. In
 	 * worst case a tx request consumes 2 gnttab_copy.
 	 */
-	struct gnttab_copy tx_copy_ops[2*MAX_PENDING_REQS];
+	struct gnttab_copy *tx_copy_ops; /* [2*MAX_PENDING_REQS]; */
 
 
 	/* Use kthread for guest RX */
@@ -147,8 +147,8 @@ struct xenvif {
 	 * head/fragment page uses 2 copy operations because it
 	 * straddles two buffers in the frontend.
 	 */
-	struct gnttab_copy grant_copy_op[2*XEN_NETIF_RX_RING_SIZE];
-	struct xenvif_rx_meta meta[2*XEN_NETIF_RX_RING_SIZE];
+	struct gnttab_copy *grant_copy_op; /* [2*XEN_NETIF_RX_RING_SIZE]; */
+	struct xenvif_rx_meta *meta; /* [2*XEN_NETIF_RX_RING_SIZE]; */
 
 
 	u8               fe_dev_addr[6];
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index e4aa267..d4a9807 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -288,6 +288,60 @@ static const struct net_device_ops xenvif_netdev_ops = {
 	.ndo_validate_addr   = eth_validate_addr,
 };
 
+static void deallocate_xenvif_arrays(struct xenvif *vif)
+{
+	vfree(vif->mmap_pages);
+	vif->mmap_pages = NULL;
+
+	vfree(vif->pending_tx_info);
+	vif->pending_tx_info = NULL;
+
+	vfree(vif->tx_copy_ops);
+	vif->tx_copy_ops = NULL;
+
+	vfree(vif->grant_copy_op);
+	vif->grant_copy_op = NULL;
+
+	vfree(vif->meta);
+	vif->meta = NULL;
+}
+
+static int allocate_xenvif_arrays(struct xenvif *vif)
+{
+	vif->mmap_pages = vif->pending_tx_info = NULL;
+	vif->tx_copy_ops = vif->grant_copy_op = vif->meta = NULL;
+
+	vif->mmap_pages = vzalloc(MAX_PENDING_REQS * sizeof(struct page *));
+	if (! vif->mmap_pages)
+		goto fail;
+
+	vif->pending_tx_info = vzalloc(MAX_PENDING_REQS * 
+					sizeof(struct pending_tx_info));
+	if (! vif->pending_tx_info)
+		goto fail;
+
+	vif->tx_copy_ops = vzalloc(2 * MAX_PENDING_REQS *
+					sizeof(struct gnttab_copy));
+	if (! vif->tx_copy_ops)
+		goto fail;
+
+	vif->grant_copy_op = vzalloc(2 * XEN_NETIF_RX_RING_SIZE *
+					sizeof(struct gnttab_copy));
+	if (! vif->grant_copy_op)
+		goto fail;
+
+	vif->meta = vzalloc(2 * XEN_NETIF_RX_RING_SIZE *
+					sizeof(struct xenvif_rx_meta));
+	if (! vif->meta)
+		goto fail;
+
+	return 0;
+
+fail:
+	deallocate_xenvif_arrays(vif);
+	return 1;
+}
+
 struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 			    unsigned int handle)
 {
@@ -313,6 +367,12 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	vif->ip_csum = 1;
 	vif->dev = dev;
 
+	if (allocate_xenvif_arrays(vif)) {
+		netdev_warn(dev, "Could not create device: out of memory\n");
+		free_netdev(dev);
+		return ERR_PTR(-ENOMEM);
+	}
+
 	vif->credit_bytes = vif->remaining_credit = ~0UL;
 	vif->credit_usec  = 0UL;
 	init_timer(&vif->credit_timeout);
@@ -484,6 +544,7 @@ void xenvif_free(struct xenvif *vif)
 
 	unregister_netdev(vif->dev);
 
+	deallocate_xenvif_arrays(vif);
 	free_netdev(vif->dev);
 
 	module_put(THIS_MODULE);
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 828fdab..34c0c05 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -602,12 +602,12 @@ void xenvif_rx_action(struct xenvif *vif)
 			break;
 	}
 
-	BUG_ON(npo.meta_prod > ARRAY_SIZE(vif->meta));
+	BUG_ON(npo.meta_prod > 2*XEN_NETIF_RX_RING_SIZE);
 
 	if (!npo.copy_prod)
 		return;
 
-	BUG_ON(npo.copy_prod > ARRAY_SIZE(vif->grant_copy_op));
+	BUG_ON(npo.copy_prod > 2*XEN_NETIF_RX_RING_SIZE);
 	gnttab_batch_copy(vif->grant_copy_op, npo.copy_prod);
 
 	while ((skb = __skb_dequeue(&rxq)) != NULL) {
@@ -1571,7 +1571,7 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif)
 
 		vif->tx.req_cons = idx;
 
-		if ((gop-vif->tx_copy_ops) >= ARRAY_SIZE(vif->tx_copy_ops))
+		if ((gop-vif->tx_copy_ops) >= 2*MAX_PENDING_REQS)
 			break;
 	}
 
-- 
1.7.10.4
