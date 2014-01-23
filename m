From: Annie Li <Annie.li@oracle.com>
Subject: [[Xen-devel] [PATCH net-next v3] xen-netfront: clean up code in xennet_release_rx_bufs
Date: Thu, 23 Jan 2014 09:36:51 +0800
Message-ID: <1390441011-3816-1-git-send-email-Annie.li@oracle.com>
Cc: konrad.wilk@oracle.com, ian.campbell@citrix.com,
	wei.liu2@citrix.com, david.vrabel@citrix.com, annie.li@oracle.com
To: xen-devel@lists.xen.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25836 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101AbaAWJcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 04:32:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Annie Li <annie.li@oracle.com>

This patch removes grant transfer code from netfront, and improves ending
grant acess mechanism since gnttab_end_foreign_access_ref may fail when
the grant entry is currently used for reading or writing.

* release grant reference and skb for tx/rx path, use get_page/put_page to
ensure page is released when grant access is completed successfully.
* change corresponding code in xen-blkfront/xen-tpmfront/xen-pcifront because
of code change for put_page in gnttab_end_foreign_access.
* clean up grant transfer code kept from old netfront(2.6.18) which grants
pages for access/map and transfer. But grant transfer is deprecated in current
netfront, so remove corresponding release code for transfer.

V3: Changes as suggestion from David Vrabel, ensure pages are not freed untill
grant acess is ended.

V2: improve patch comments.
Signed-off-by: Annie Li <annie.li@oracle.com>
---
 drivers/block/xen-blkfront.c    |   25 ++++++++---
 drivers/char/tpm/xen-tpmfront.c |    7 +++-
 drivers/net/xen-netfront.c      |   93 ++++++++++++--------------------------
 drivers/pci/xen-pcifront.c      |    7 +++-
 drivers/xen/grant-table.c       |    4 +-
 5 files changed, 63 insertions(+), 73 deletions(-)

diff --git a/drivers/block/xen-blkfront.c b/drivers/block/xen-blkfront.c
index c4a4c90..c300bfd 100644
--- a/drivers/block/xen-blkfront.c
+++ b/drivers/block/xen-blkfront.c
@@ -918,6 +918,7 @@ static void blkif_free(struct blkfront_info *info, int suspend)
 	struct grant *persistent_gnt;
 	struct grant *n;
 	int i, j, segs;
+	struct page *page;
 
 	/* Prevent new requests being issued until we fix things up. */
 	spin_lock_irq(&info->io_lock);
@@ -932,13 +933,16 @@ static void blkif_free(struct blkfront_info *info, int suspend)
 		list_for_each_entry_safe(persistent_gnt, n,
 		                         &info->grants, node) {
 			list_del(&persistent_gnt->node);
+			page = pfn_to_page(persistent_gnt->pfn);
 			if (persistent_gnt->gref != GRANT_INVALID_REF) {
+				get_page(page);
 				gnttab_end_foreign_access(persistent_gnt->gref,
-				                          0, 0UL);
+							  0,
+							 (unsigned long)page_address(page));
 				info->persistent_gnts_c--;
 			}
 			if (info->feature_persistent)
-				__free_page(pfn_to_page(persistent_gnt->pfn));
+				__free_page(page);
 			kfree(persistent_gnt);
 		}
 	}
@@ -971,9 +975,12 @@ static void blkif_free(struct blkfront_info *info, int suspend)
 		       info->shadow[i].req.u.rw.nr_segments;
 		for (j = 0; j < segs; j++) {
 			persistent_gnt = info->shadow[i].grants_used[j];
-			gnttab_end_foreign_access(persistent_gnt->gref, 0, 0UL);
+			page = pfn_to_page(persistent_gnt->pfn);
+			get_page(page);
+			gnttab_end_foreign_access(persistent_gnt->gref, 0,
+						 (unsigned long)page_address(page));
 			if (info->feature_persistent)
-				__free_page(pfn_to_page(persistent_gnt->pfn));
+				__free_page(page);
 			kfree(persistent_gnt);
 		}
 
@@ -986,8 +993,11 @@ static void blkif_free(struct blkfront_info *info, int suspend)
 
 		for (j = 0; j < INDIRECT_GREFS(segs); j++) {
 			persistent_gnt = info->shadow[i].indirect_grants[j];
-			gnttab_end_foreign_access(persistent_gnt->gref, 0, 0UL);
-			__free_page(pfn_to_page(persistent_gnt->pfn));
+			page = pfn_to_page(persistent_gnt->pfn);
+			get_page(page);
+			gnttab_end_foreign_access(persistent_gnt->gref, 0,
+						 (unsigned long)page_address(page));
+			__free_page(page);
 			kfree(persistent_gnt);
 		}
 
@@ -1009,8 +1019,11 @@ free_shadow:
 
 	/* Free resources associated with old device channel. */
 	if (info->ring_ref != GRANT_INVALID_REF) {
+		page = virt_to_page(info->ring.sring);
+		get_page(page);
 		gnttab_end_foreign_access(info->ring_ref, 0,
 					  (unsigned long)info->ring.sring);
+		__free_page(page);
 		info->ring_ref = GRANT_INVALID_REF;
 		info->ring.sring = NULL;
 	}
diff --git a/drivers/char/tpm/xen-tpmfront.c b/drivers/char/tpm/xen-tpmfront.c
index c8ff4df..3e83585 100644
--- a/drivers/char/tpm/xen-tpmfront.c
+++ b/drivers/char/tpm/xen-tpmfront.c
@@ -312,9 +312,14 @@ static void ring_free(struct tpm_private *priv)
 	if (!priv)
 		return;
 
-	if (priv->ring_ref)
+	if (priv->ring_ref) {
+		struct page *page;
+		page = virt_to_page(priv->shr);
+		get_page(page);
 		gnttab_end_foreign_access(priv->ring_ref, 0,
 				(unsigned long)priv->shr);
+		__free_page(page);
+	}
 	else
 		free_page((unsigned long)priv->shr);
 
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index d7bee8a..a22adaa 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -117,6 +117,7 @@ struct netfront_info {
 	} tx_skbs[NET_TX_RING_SIZE];
 	grant_ref_t gref_tx_head;
 	grant_ref_t grant_tx_ref[NET_TX_RING_SIZE];
+	struct page *grant_tx_page[NET_TX_RING_SIZE];
 	unsigned tx_skb_freelist;
 
 	spinlock_t   rx_lock ____cacheline_aligned_in_smp;
@@ -396,6 +397,7 @@ static void xennet_tx_buf_gc(struct net_device *dev)
 			gnttab_release_grant_reference(
 				&np->gref_tx_head, np->grant_tx_ref[id]);
 			np->grant_tx_ref[id] = GRANT_INVALID_REF;
+			np->grant_tx_page[id] = NULL;
 			add_id_to_freelist(&np->tx_skb_freelist, np->tx_skbs, id);
 			dev_kfree_skb_irq(skb);
 		}
@@ -452,6 +454,7 @@ static void xennet_make_frags(struct sk_buff *skb, struct net_device *dev,
 		gnttab_grant_foreign_access_ref(ref, np->xbdev->otherend_id,
 						mfn, GNTMAP_readonly);
 
+		np->grant_tx_page[id] = virt_to_page(data);
 		tx->gref = np->grant_tx_ref[id] = ref;
 		tx->offset = offset;
 		tx->size = len;
@@ -497,6 +500,7 @@ static void xennet_make_frags(struct sk_buff *skb, struct net_device *dev,
 							np->xbdev->otherend_id,
 							mfn, GNTMAP_readonly);
 
+			np->grant_tx_page[id] = page;
 			tx->gref = np->grant_tx_ref[id] = ref;
 			tx->offset = offset;
 			tx->size = bytes;
@@ -596,6 +600,7 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	mfn = virt_to_mfn(data);
 	gnttab_grant_foreign_access_ref(
 		ref, np->xbdev->otherend_id, mfn, GNTMAP_readonly);
+	np->grant_tx_page[id] = virt_to_page(data);
 	tx->gref = np->grant_tx_ref[id] = ref;
 	tx->offset = offset;
 	tx->size = len;
@@ -1085,10 +1090,11 @@ static void xennet_release_tx_bufs(struct netfront_info *np)
 			continue;
 
 		skb = np->tx_skbs[i].skb;
-		gnttab_end_foreign_access_ref(np->grant_tx_ref[i],
-					      GNTMAP_readonly);
-		gnttab_release_grant_reference(&np->gref_tx_head,
-					       np->grant_tx_ref[i]);
+		get_page(np->grant_tx_page[i]);
+		gnttab_end_foreign_access(np->grant_tx_ref[i],
+					  GNTMAP_readonly,
+					  (unsigned long)page_address(np->grant_tx_page[i]));
+		np->grant_tx_page[i] = NULL;
 		np->grant_tx_ref[i] = GRANT_INVALID_REF;
 		add_id_to_freelist(&np->tx_skb_freelist, np->tx_skbs, i);
 		dev_kfree_skb_irq(skb);
@@ -1097,78 +1103,35 @@ static void xennet_release_tx_bufs(struct netfront_info *np)
 
 static void xennet_release_rx_bufs(struct netfront_info *np)
 {
-	struct mmu_update      *mmu = np->rx_mmu;
-	struct multicall_entry *mcl = np->rx_mcl;
-	struct sk_buff_head free_list;
-	struct sk_buff *skb;
-	unsigned long mfn;
-	int xfer = 0, noxfer = 0, unused = 0;
 	int id, ref;
 
-	dev_warn(&np->netdev->dev, "%s: fix me for copying receiver.\n",
-			 __func__);
-	return;
-
-	skb_queue_head_init(&free_list);
-
 	spin_lock_bh(&np->rx_lock);
 
 	for (id = 0; id < NET_RX_RING_SIZE; id++) {
-		ref = np->grant_rx_ref[id];
-		if (ref == GRANT_INVALID_REF) {
-			unused++;
-			continue;
-		}
+		struct sk_buff *skb;
+		struct page *page;
 
 		skb = np->rx_skbs[id];
-		mfn = gnttab_end_foreign_transfer_ref(ref);
-		gnttab_release_grant_reference(&np->gref_rx_head, ref);
-		np->grant_rx_ref[id] = GRANT_INVALID_REF;
-
-		if (0 == mfn) {
-			skb_shinfo(skb)->nr_frags = 0;
-			dev_kfree_skb(skb);
-			noxfer++;
+		if (!skb)
 			continue;
-		}
-
-		if (!xen_feature(XENFEAT_auto_translated_physmap)) {
-			/* Remap the page. */
-			const struct page *page =
-				skb_frag_page(&skb_shinfo(skb)->frags[0]);
-			unsigned long pfn = page_to_pfn(page);
-			void *vaddr = page_address(page);
 
-			MULTI_update_va_mapping(mcl, (unsigned long)vaddr,
-						mfn_pte(mfn, PAGE_KERNEL),
-						0);
-			mcl++;
-			mmu->ptr = ((u64)mfn << PAGE_SHIFT)
-				| MMU_MACHPHYS_UPDATE;
-			mmu->val = pfn;
-			mmu++;
+		ref = np->grant_rx_ref[id];
+		if (ref == GRANT_INVALID_REF)
+			continue;
 
-			set_phys_to_machine(pfn, mfn);
-		}
-		__skb_queue_tail(&free_list, skb);
-		xfer++;
-	}
+		page = skb_frag_page(&skb_shinfo(skb)->frags[0]);
 
-	dev_info(&np->netdev->dev, "%s: %d xfer, %d noxfer, %d unused\n",
-		 __func__, xfer, noxfer, unused);
+		/* gnttab_end_foreign_access() needs a page ref until
+		 * foreign access is ended (which may be deferred).
+		 */
+		get_page(page);
+		gnttab_end_foreign_access(ref, 0,
+					  (unsigned long)page_address(page));
+		np->grant_rx_ref[id] = GRANT_INVALID_REF;
 
-	if (xfer) {
-		if (!xen_feature(XENFEAT_auto_translated_physmap)) {
-			/* Do all the remapping work and M2P updates. */
-			MULTI_mmu_update(mcl, np->rx_mmu, mmu - np->rx_mmu,
-					 NULL, DOMID_SELF);
-			mcl++;
-			HYPERVISOR_multicall(np->rx_mcl, mcl - np->rx_mcl);
-		}
+		kfree_skb(skb);
 	}
 
-	__skb_queue_purge(&free_list);
-
 	spin_unlock_bh(&np->rx_lock);
 }
 
@@ -1339,6 +1302,7 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
 	for (i = 0; i < NET_RX_RING_SIZE; i++) {
 		np->rx_skbs[i] = NULL;
 		np->grant_rx_ref[i] = GRANT_INVALID_REF;
+		np->grant_tx_page[i] = NULL;
 	}
 
 	/* A grant for every tx ring slot */
@@ -1439,8 +1403,11 @@ static int netfront_probe(struct xenbus_device *dev,
 static void xennet_end_access(int ref, void *page)
 {
 	/* This frees the page as a side-effect */
-	if (ref != GRANT_INVALID_REF)
+	if (ref != GRANT_INVALID_REF) {
+		get_page(virt_to_page(page));
 		gnttab_end_foreign_access(ref, 0, (unsigned long)page);
+		free_page((unsigned long)page);
+	}
 }
 
 static void xennet_disconnect_backend(struct netfront_info *info)
diff --git a/drivers/pci/xen-pcifront.c b/drivers/pci/xen-pcifront.c
index f7197a7..ed732e5 100644
--- a/drivers/pci/xen-pcifront.c
+++ b/drivers/pci/xen-pcifront.c
@@ -756,9 +756,14 @@ static void free_pdev(struct pcifront_device *pdev)
 	if (pdev->evtchn != INVALID_EVTCHN)
 		xenbus_free_evtchn(pdev->xdev, pdev->evtchn);
 
-	if (pdev->gnt_ref != INVALID_GRANT_REF)
+	if (pdev->gnt_ref != INVALID_GRANT_REF) {
+		struct page *page;
+		page = virt_to_page(pdev->sh_info);
+		get_page(page);
 		gnttab_end_foreign_access(pdev->gnt_ref, 0 /* r/w page */,
 					  (unsigned long)pdev->sh_info);
+		__free_page(page);
+	}
 	else
 		free_page((unsigned long)pdev->sh_info);
 
diff --git a/drivers/xen/grant-table.c b/drivers/xen/grant-table.c
index aa846a4..b64a32e 100644
--- a/drivers/xen/grant-table.c
+++ b/drivers/xen/grant-table.c
@@ -504,7 +504,7 @@ static void gnttab_handle_deferred(unsigned long unused)
 			if (entry->page) {
 				pr_debug("freeing g.e. %#x (pfn %#lx)\n",
 					 entry->ref, page_to_pfn(entry->page));
-				__free_page(entry->page);
+				put_page(entry->page);
 			} else
 				pr_info("freeing g.e. %#x\n", entry->ref);
 			kfree(entry);
@@ -560,7 +560,7 @@ void gnttab_end_foreign_access(grant_ref_t ref, int readonly,
 	if (gnttab_end_foreign_access_ref(ref, readonly)) {
 		put_free_entry(ref);
 		if (page != 0)
-			free_page(page);
+			put_page(virt_to_page(page));
 	} else
 		gnttab_add_deferred(ref, readonly,
 				    page ? virt_to_page(page) : NULL);
-- 
1.7.3.4
