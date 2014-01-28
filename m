From: Annie Li <Annie.li@oracle.com>
Subject: [Xen-devel] [PATCH net v6] xen-netfront: fix resource leak in netfront
Date: Tue, 28 Jan 2014 11:35:42 +0800
Message-ID: <1390880142-4962-1-git-send-email-Annie.li@oracle.com>
Cc: konrad.wilk@oracle.com, ian.campbell@citrix.com,
	wei.liu2@citrix.com, david.vrabel@citrix.com, annie.li@oracle.com
To: xen-devel@lists.xen.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27461 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754064AbaA1Ddu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 22:33:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Annie Li <annie.li@oracle.com>

This patch removes grant transfer releasing code from netfront, and uses
gnttab_end_foreign_access to end grant access since
gnttab_end_foreign_access_ref may fail when the grant entry is
currently used for reading or writing.

* clean up grant transfer code kept from old netfront(2.6.18) which grants
pages for access/map and transfer. But grant transfer is deprecated in current
netfront, so remove corresponding release code for transfer.

* fix resource leak, release grant access (through gnttab_end_foreign_access)
and skb for tx/rx path, use get_page to ensure page is released when grant
access is completed successfully.

Xen-blkfront/xen-tpmfront/xen-pcifront also have similar issue, but patches
for them will be created separately.

V6: Correct subject line and commit message.

V5: Remove unecessary change in xennet_end_access.

V4: Revert put_page in gnttab_end_foreign_access, and keep netfront change in
single patch.

V3: Changes as suggestion from David Vrabel, ensure pages are not freed untill
grant acess is ended.

V2: Improve patch comments.

Signed-off-by: Annie Li <annie.li@oracle.com>
---
 drivers/net/xen-netfront.c |   88 +++++++++++++-------------------------------
 1 files changed, 26 insertions(+), 62 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index d7bee8a..6ddf1e6 100644
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
 
-		if (!xen_feature(XENFEAT_auto_translated_physmap)) {
-			/* Remap the page. */
-			const struct page *page =
-				skb_frag_page(&skb_shinfo(skb)->frags[0]);
-			unsigned long pfn = page_to_pfn(page);
-			void *vaddr = page_address(page);
+		ref = np->grant_rx_ref[id];
+		if (ref == GRANT_INVALID_REF)
+			continue;
 
-			MULTI_update_va_mapping(mcl, (unsigned long)vaddr,
-						mfn_pte(mfn, PAGE_KERNEL),
-						0);
-			mcl++;
-			mmu->ptr = ((u64)mfn << PAGE_SHIFT)
-				| MMU_MACHPHYS_UPDATE;
-			mmu->val = pfn;
-			mmu++;
+		page = skb_frag_page(&skb_shinfo(skb)->frags[0]);
 
-			set_phys_to_machine(pfn, mfn);
-		}
-		__skb_queue_tail(&free_list, skb);
-		xfer++;
-	}
-
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
-- 
1.7.3.4
