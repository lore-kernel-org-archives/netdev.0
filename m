From: Annie Li <annie.li@oracle.com>
Subject: [PATCH 1/4] xen/netback: implements persistent grant with one page pool.
Date: Thu, 15 Nov 2012 15:04:26 +0800
Message-ID: <1352963066-570-1-git-send-email-annie.li@oracle.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com>
Cc: annie.li@oracle.com
To: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	konrad.wilk@oracle.com, Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:48803 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751970Ab2KOHFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 02:05:36 -0500
In-Reply-To: <1352962987-541-1-git-send-email-annie.li@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements persistent grant in netback driver. Tx and rx
share the same page pool, this pool will be split into two parts
in next patch.

Signed-off-by: Annie Li <annie.li@oracle.com>
---
 drivers/net/xen-netback/common.h    |   18 +++-
 drivers/net/xen-netback/interface.c |   22 ++++
 drivers/net/xen-netback/netback.c   |  212 +++++++++++++++++++++++++++++++----
 drivers/net/xen-netback/xenbus.c    |   14 ++-
 4 files changed, 239 insertions(+), 27 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 94b79c3..a85cac6 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -45,8 +45,19 @@
 #include <xen/grant_table.h>
 #include <xen/xenbus.h>
 
+#define XEN_NETIF_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
+#define XEN_NETIF_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
+#define MAXIMUM_OUTSTANDING_BLOCK_REQS \
+			(XEN_NETIF_TX_RING_SIZE + XEN_NETIF_RX_RING_SIZE)
+
 struct xen_netbk;
 
+struct persistent_entry {
+	grant_ref_t forgranted;
+	struct page *fpage;
+	struct gnttab_map_grant_ref map;
+};
+
 struct xenvif {
 	/* Unique identifier for this interface. */
 	domid_t          domid;
@@ -75,6 +86,7 @@ struct xenvif {
 
 	/* Internal feature information. */
 	u8 can_queue:1;	    /* can queue packets for receiver? */
+	u8 persistent_grant:1;
 
 	/*
 	 * Allow xenvif_start_xmit() to peek ahead in the rx request
@@ -98,6 +110,9 @@ struct xenvif {
 	struct net_device *dev;
 
 	wait_queue_head_t waiting_to_free;
+
+	struct persistent_entry *persistent_gnt[MAXIMUM_OUTSTANDING_BLOCK_REQS];
+	unsigned int persistent_gntcnt;
 };
 
 static inline struct xenbus_device *xenvif_to_xenbus_device(struct xenvif *vif)
@@ -105,9 +120,6 @@ static inline struct xenbus_device *xenvif_to_xenbus_device(struct xenvif *vif)
 	return to_xenbus_device(vif->dev->dev.parent);
 }
 
-#define XEN_NETIF_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
-#define XEN_NETIF_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
-
 struct xenvif *xenvif_alloc(struct device *parent,
 			    domid_t domid,
 			    unsigned int handle);
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index b7d41f8..226d159 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -300,6 +300,8 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 		return ERR_PTR(err);
 	}
 
+	vif->persistent_gntcnt = 0;
+
 	netdev_dbg(dev, "Successfully created xenvif\n");
 	return vif;
 }
@@ -343,6 +345,23 @@ err:
 	return err;
 }
 
+void xenvif_free_grants(struct persistent_entry **pers_entry,
+			unsigned int count)
+{
+	int i, ret;
+	struct gnttab_unmap_grant_ref unmap;
+
+	for (i = 0; i < count; i++) {
+		gnttab_set_unmap_op(&unmap,
+			(unsigned long)page_to_pfn(pers_entry[i]->fpage),
+			GNTMAP_host_map,
+			pers_entry[i]->map.handle);
+		ret = gnttab_unmap_refs(&unmap, &pers_entry[i]->fpage,
+					1, false);
+		BUG_ON(ret);
+	}
+}
+
 void xenvif_disconnect(struct xenvif *vif)
 {
 	struct net_device *dev = vif->dev;
@@ -366,6 +385,9 @@ void xenvif_disconnect(struct xenvif *vif)
 	unregister_netdev(vif->dev);
 
 	xen_netbk_unmap_frontend_rings(vif);
+	if (vif->persistent_grant)
+		xenvif_free_grants(vif->persistent_gnt,
+				   vif->persistent_gntcnt);
 
 	free_netdev(vif->dev);
 }
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 2596401..a26d3fc 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -80,6 +80,8 @@ union page_ext {
 	void *mapping;
 };
 
+struct xenvif;
+
 struct xen_netbk {
 	wait_queue_head_t wq;
 	struct task_struct *task;
@@ -102,6 +104,7 @@ struct xen_netbk {
 
 	struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
 	struct gnttab_copy tx_copy_ops[MAX_PENDING_REQS];
+	struct xenvif *gnttab_tx_vif[MAX_PENDING_REQS];
 
 	u16 pending_ring[MAX_PENDING_REQS];
 
@@ -111,12 +114,139 @@ struct xen_netbk {
 	 * straddles two buffers in the frontend.
 	 */
 	struct gnttab_copy grant_copy_op[2*XEN_NETIF_RX_RING_SIZE];
+	struct xenvif *gnttab_rx_vif[2*XEN_NETIF_RX_RING_SIZE];
 	struct netbk_rx_meta meta[2*XEN_NETIF_RX_RING_SIZE];
 };
 
 static struct xen_netbk *xen_netbk;
 static int xen_netbk_group_nr;
 
+static struct persistent_entry*
+get_per_gnt(struct persistent_entry **pers_entry,
+	    unsigned int count, grant_ref_t gref)
+{
+	int i;
+
+	for (i = 0; i < count; i++)
+		if (gref == pers_entry[i]->forgranted)
+			return pers_entry[i];
+
+	return NULL;
+}
+
+static void*
+map_new_gnt(struct persistent_entry **pers_entry, unsigned int count,
+	    grant_ref_t ref, domid_t domid)
+{
+	struct gnttab_map_grant_ref *map;
+	struct page *page;
+	unsigned long vaddr;
+	unsigned long pfn;
+	uint32_t flags;
+	int ret = 0;
+
+	pers_entry[count] = (struct persistent_entry *)
+			    kmalloc(sizeof(struct persistent_entry),
+				    GFP_KERNEL);
+	if (!pers_entry[count])
+		return ERR_PTR(-ENOMEM);
+
+	map = &pers_entry[count]->map;
+	page = alloc_page(GFP_KERNEL);
+	if (!page) {
+		kfree(pers_entry[count]);
+		pers_entry[count] = NULL;
+		return ERR_PTR(-ENOMEM);
+	}
+
+	pers_entry[count]->fpage = page;
+	pfn = page_to_pfn(page);
+	vaddr = (unsigned long)pfn_to_kaddr(pfn);
+	flags = GNTMAP_host_map;
+
+	gnttab_set_map_op(map, vaddr, flags, ref, domid);
+	ret = gnttab_map_refs(map, NULL, &page, 1);
+	BUG_ON(ret);
+
+	pers_entry[count]->forgranted = ref;
+
+	return page_address(page);
+}
+
+static void*
+get_ref_page(struct persistent_entry **pers_entry, unsigned int *count,
+	     grant_ref_t ref, domid_t domid, unsigned int total)
+{
+	struct persistent_entry *per_gnt;
+	void *vaddr;
+
+	per_gnt = get_per_gnt(pers_entry, *count, ref);
+
+	if (per_gnt != NULL)
+		return page_address(per_gnt->fpage);
+	else {
+		BUG_ON(*count >= total);
+		vaddr = map_new_gnt(pers_entry, *count, ref, domid);
+		if (IS_ERR_OR_NULL(vaddr))
+			return vaddr;
+		*count += 1;
+		return vaddr;
+	}
+}
+
+static int
+grant_memory_copy_op(unsigned int cmd, void *vuop, unsigned int count,
+		     struct xen_netbk *netbk, bool tx_pool)
+{
+	int i;
+	struct xenvif *vif;
+	struct gnttab_copy *uop = vuop;
+	unsigned int *gnt_count;
+	unsigned int gnt_total;
+	struct persistent_entry **pers_entry;
+	int ret = 0;
+
+	BUG_ON(cmd != GNTTABOP_copy);
+	for (i = 0; i < count; i++) {
+		if (tx_pool)
+			vif = netbk->gnttab_tx_vif[i];
+		else
+			vif = netbk->gnttab_rx_vif[i];
+
+		pers_entry = vif->persistent_gnt;
+		gnt_count = &vif->persistent_gntcnt;
+		gnt_total = MAXIMUM_OUTSTANDING_BLOCK_REQS;
+
+		if (vif->persistent_grant) {
+			void *saddr, *daddr;
+
+			saddr = uop[i].source.domid == DOMID_SELF ?
+				(void *) uop[i].source.u.gmfn :
+				get_ref_page(pers_entry, gnt_count,
+					     uop[i].source.u.ref,
+					     uop[i].source.domid,
+					     gnt_total);
+			if (IS_ERR_OR_NULL(saddr))
+				return -ENOMEM;
+
+			daddr = uop[i].dest.domid == DOMID_SELF ?
+				(void *) uop[i].dest.u.gmfn :
+				get_ref_page(pers_entry, gnt_count,
+					     uop[i].dest.u.ref,
+					     uop[i].dest.domid,
+					     gnt_total);
+			if (IS_ERR_OR_NULL(daddr))
+				return -ENOMEM;
+
+			memcpy(daddr+uop[i].dest.offset,
+			       saddr+uop[i].source.offset, uop[i].len);
+		} else
+			ret = HYPERVISOR_grant_table_op(cmd, &uop[i], 1);
+	}
+
+	return ret;
+}
+
 void xen_netbk_add_xenvif(struct xenvif *vif)
 {
 	int i;
@@ -387,13 +517,15 @@ static struct netbk_rx_meta *get_next_rx_buffer(struct xenvif *vif,
  * Set up the grant operations for this fragment. If it's a flipping
  * interface, we also set up the unmap request from here.
  */
-static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
-				struct netrx_pending_operations *npo,
-				struct page *page, unsigned long size,
-				unsigned long offset, int *head)
+static int netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
+			       struct netrx_pending_operations *npo,
+			       struct page *page, unsigned long size,
+			       unsigned long offset, int *head,
+			       struct xenvif **grxvif)
 {
 	struct gnttab_copy *copy_gop;
 	struct netbk_rx_meta *meta;
+	int count = 0;
 	/*
 	 * These variables are used iff get_page_ext returns true,
 	 * in which case they are guaranteed to be initialized.
@@ -425,6 +557,10 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 			bytes = MAX_BUFFER_OFFSET - npo->copy_off;
 
 		copy_gop = npo->copy + npo->copy_prod++;
+		*grxvif = vif;
+		grxvif++;
+		count++;
+
 		copy_gop->flags = GNTCOPY_dest_gref;
 		if (foreign) {
 			struct xen_netbk *netbk = &xen_netbk[group];
@@ -438,7 +574,10 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 		} else {
 			void *vaddr = page_address(page);
 			copy_gop->source.domid = DOMID_SELF;
-			copy_gop->source.u.gmfn = virt_to_mfn(vaddr);
+			if (!vif->persistent_grant)
+				copy_gop->source.u.gmfn = virt_to_mfn(vaddr);
+			else
+				copy_gop->source.u.gmfn = (unsigned long)vaddr;
 		}
 		copy_gop->source.offset = offset;
 		copy_gop->dest.domid = vif->domid;
@@ -460,6 +599,7 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 		*head = 0; /* There must be something in this buffer now. */
 
 	}
+	return count;
 }
 
 /*
@@ -474,8 +614,10 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
  * zero GSO descriptors (for non-GSO packets) or one descriptor (for
  * frontend-side LRO).
  */
-static int netbk_gop_skb(struct sk_buff *skb,
-			 struct netrx_pending_operations *npo)
+static int netbk_gop_skb(struct xen_netbk *netbk,
+			 struct sk_buff *skb,
+			 struct netrx_pending_operations *npo,
+			 struct xenvif **grxvif)
 {
 	struct xenvif *vif = netdev_priv(skb->dev);
 	int nr_frags = skb_shinfo(skb)->nr_frags;
@@ -518,17 +660,19 @@ static int netbk_gop_skb(struct sk_buff *skb,
 		if (data + len > skb_tail_pointer(skb))
 			len = skb_tail_pointer(skb) - data;
 
-		netbk_gop_frag_copy(vif, skb, npo,
-				    virt_to_page(data), len, offset, &head);
+		grxvif += netbk_gop_frag_copy(vif, skb, npo,
+					      virt_to_page(data), len,
+					      offset, &head, grxvif);
+
 		data += len;
 	}
 
 	for (i = 0; i < nr_frags; i++) {
-		netbk_gop_frag_copy(vif, skb, npo,
-				    skb_frag_page(&skb_shinfo(skb)->frags[i]),
-				    skb_frag_size(&skb_shinfo(skb)->frags[i]),
-				    skb_shinfo(skb)->frags[i].page_offset,
-				    &head);
+		grxvif += netbk_gop_frag_copy(vif, skb, npo,
+				skb_frag_page(&skb_shinfo(skb)->frags[i]),
+				skb_frag_size(&skb_shinfo(skb)->frags[i]),
+				skb_shinfo(skb)->frags[i].page_offset,
+				&head, grxvif);
 	}
 
 	return npo->meta_prod - old_meta_prod;
@@ -593,6 +737,8 @@ struct skb_cb_overlay {
 static void xen_netbk_rx_action(struct xen_netbk *netbk)
 {
 	struct xenvif *vif = NULL, *tmp;
+	struct xenvif **grxvif = netbk->gnttab_rx_vif;
+	int old_copy_prod = 0;
 	s8 status;
 	u16 irq, flags;
 	struct xen_netif_rx_response *resp;
@@ -619,7 +765,9 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
 		nr_frags = skb_shinfo(skb)->nr_frags;
 
 		sco = (struct skb_cb_overlay *)skb->cb;
-		sco->meta_slots_used = netbk_gop_skb(skb, &npo);
+		sco->meta_slots_used = netbk_gop_skb(netbk, skb, &npo, grxvif);
+		grxvif += npo.copy_prod - old_copy_prod;
+		old_copy_prod = npo.copy_prod;
 
 		count += nr_frags + 1;
 
@@ -636,8 +784,10 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
 		return;
 
 	BUG_ON(npo.copy_prod > ARRAY_SIZE(netbk->grant_copy_op));
-	ret = HYPERVISOR_grant_table_op(GNTTABOP_copy, &netbk->grant_copy_op,
-					npo.copy_prod);
+	ret = grant_memory_copy_op(GNTTABOP_copy,
+				   &netbk->grant_copy_op,
+				   npo.copy_prod, netbk,
+				   false);
 	BUG_ON(ret != 0);
 
 	while ((skb = __skb_dequeue(&rxq)) != NULL) {
@@ -918,7 +1068,8 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 						  struct xenvif *vif,
 						  struct sk_buff *skb,
 						  struct xen_netif_tx_request *txp,
-						  struct gnttab_copy *gop)
+						  struct gnttab_copy *gop,
+						  struct xenvif **gtxvif)
 {
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	skb_frag_t *frags = shinfo->frags;
@@ -944,7 +1095,11 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 		gop->source.domid = vif->domid;
 		gop->source.offset = txp->offset;
 
-		gop->dest.u.gmfn = virt_to_mfn(page_address(page));
+		if (!vif->persistent_grant)
+			gop->dest.u.gmfn = virt_to_mfn(page_address(page));
+		else
+			gop->dest.u.gmfn = (unsigned long)page_address(page);
+
 		gop->dest.domid = DOMID_SELF;
 		gop->dest.offset = txp->offset;
 
@@ -952,6 +1107,9 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 		gop->flags = GNTCOPY_source_gref;
 
 		gop++;
+		*gtxvif = vif;
+		gtxvif++;
+
 
 		memcpy(&pending_tx_info[pending_idx].req, txp, sizeof(*txp));
 		xenvif_get(vif);
@@ -1218,6 +1376,7 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
 static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 {
 	struct gnttab_copy *gop = netbk->tx_copy_ops, *request_gop;
+	struct xenvif **gtxvif = netbk->gnttab_tx_vif;
 	struct sk_buff *skb;
 	int ret;
 
@@ -1338,7 +1497,11 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 		gop->source.domid = vif->domid;
 		gop->source.offset = txreq.offset;
 
-		gop->dest.u.gmfn = virt_to_mfn(page_address(page));
+		if (!vif->persistent_grant)
+			gop->dest.u.gmfn = virt_to_mfn(page_address(page));
+		else
+			gop->dest.u.gmfn = (unsigned long)page_address(page);
+
 		gop->dest.domid = DOMID_SELF;
 		gop->dest.offset = txreq.offset;
 
@@ -1346,6 +1509,7 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 		gop->flags = GNTCOPY_source_gref;
 
 		gop++;
+		*gtxvif++ = vif;
 
 		memcpy(&netbk->pending_tx_info[pending_idx].req,
 		       &txreq, sizeof(txreq));
@@ -1369,12 +1533,13 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 		netbk->pending_cons++;
 
 		request_gop = xen_netbk_get_requests(netbk, vif,
-						     skb, txfrags, gop);
+						     skb, txfrags, gop, gtxvif);
 		if (request_gop == NULL) {
 			kfree_skb(skb);
 			netbk_tx_err(vif, &txreq, idx);
 			continue;
 		}
+		gtxvif += request_gop - gop;
 		gop = request_gop;
 
 		vif->tx.req_cons = idx;
@@ -1467,8 +1632,9 @@ static void xen_netbk_tx_action(struct xen_netbk *netbk)
 
 	if (nr_gops == 0)
 		return;
-	ret = HYPERVISOR_grant_table_op(GNTTABOP_copy,
-					netbk->tx_copy_ops, nr_gops);
+	ret = grant_memory_copy_op(GNTTABOP_copy,
+				   netbk->tx_copy_ops, nr_gops,
+				   netbk, true);
 	BUG_ON(ret);
 
 	xen_netbk_tx_submit(netbk);
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 410018c..938e908 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -114,6 +114,13 @@ static int netback_probe(struct xenbus_device *dev,
 			goto abort_transaction;
 		}
 
+		err = xenbus_printf(xbt, dev->nodename,
+				    "feature-persistent-grants", "%u", 1);
+		if (err) {
+			message = "writing feature-persistent-grants";
+			goto abort_transaction;
+		}
+
 		err = xenbus_transaction_end(xbt, 0);
 	} while (err == -EAGAIN);
 
@@ -453,7 +460,12 @@ static int connect_rings(struct backend_info *be)
 		val = 0;
 	vif->csum = !val;
 
-	/* Map the shared frame, irq etc. */
+	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-persistent-grants",
+			 "%u", &val) < 0)
+		val = 0;
+	vif->persistent_grant = !!val;
+
+/* Map the shared frame, irq etc. */
 	err = xenvif_connect(vif, tx_ring_ref, rx_ring_ref, evtchn);
 	if (err) {
 		xenbus_dev_fatal(dev, err,
-- 
1.7.3.4
