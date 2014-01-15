From: Annie Li <Annie.li@oracle.com>
Subject: [Xen-devel][PATCH net-next v2] xen-netfront: clean up code in xennet_release_rx_bufs
Date: Thu, 16 Jan 2014 07:57:08 +0800
Message-ID: <1389830228-2381-1-git-send-email-Annie.li@oracle.com>
Cc: davem@davemloft.net, konrad.wilk@oracle.com,
	ian.campbell@citrix.com, wei.liu2@citrix.com,
	david.vrabel@citrix.com, andrew.bennieston@citrix.com,
	annie.li@oracle.com, Annie Li <Annie.li@oracle.com>
To: xen-devel@lists.xen.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:22943 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544AbaAPHwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 02:52:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements two things:

* release grant reference and skb for rx path, this fixex resource leaking.
* clean up grant transfer code kept from old netfront(2.6.18) which grants
pages for access/map and transfer. But grant transfer is deprecated in current
netfront, so remove corresponding release code for transfer.

gnttab_end_foreign_access_ref may fail when the grant entry is currently used
for reading or writing. But this patch does not cover this and improvement for
this failure may be implemented in a separate patch.

Test has been run with this patch.

V2: improve patch comments.

Signed-off-by: Annie Li <Annie.li@oracle.com>
---
 drivers/net/xen-netfront.c |   60 ++-----------------------------------------
 1 files changed, 3 insertions(+), 57 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index e59acb1..692589e 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1134,78 +1134,24 @@ static void xennet_release_tx_bufs(struct netfront_info *np)
 
 static void xennet_release_rx_bufs(struct netfront_info *np)
 {
-	struct mmu_update      *mmu = np->rx_mmu;
-	struct multicall_entry *mcl = np->rx_mcl;
-	struct sk_buff_head free_list;
 	struct sk_buff *skb;
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
 		ref = np->grant_rx_ref[id];
-		if (ref == GRANT_INVALID_REF) {
-			unused++;
+		if (ref == GRANT_INVALID_REF)
 			continue;
-		}
 
 		skb = np->rx_skbs[id];
-		mfn = gnttab_end_foreign_transfer_ref(ref);
+		gnttab_end_foreign_access_ref(ref, 0);
 		gnttab_release_grant_reference(&np->gref_rx_head, ref);
 		np->grant_rx_ref[id] = GRANT_INVALID_REF;
 
-		if (0 == mfn) {
-			skb_shinfo(skb)->nr_frags = 0;
-			dev_kfree_skb(skb);
-			noxfer++;
-			continue;
-		}
-
-		if (!xen_feature(XENFEAT_auto_translated_physmap)) {
-			/* Remap the page. */
-			const struct page *page =
-				skb_frag_page(&skb_shinfo(skb)->frags[0]);
-			unsigned long pfn = page_to_pfn(page);
-			void *vaddr = page_address(page);
-
-			MULTI_update_va_mapping(mcl, (unsigned long)vaddr,
-						mfn_pte(mfn, PAGE_KERNEL),
-						0);
-			mcl++;
-			mmu->ptr = ((u64)mfn << PAGE_SHIFT)
-				| MMU_MACHPHYS_UPDATE;
-			mmu->val = pfn;
-			mmu++;
-
-			set_phys_to_machine(pfn, mfn);
-		}
-		__skb_queue_tail(&free_list, skb);
-		xfer++;
-	}
-
-	dev_info(&np->netdev->dev, "%s: %d xfer, %d noxfer, %d unused\n",
-		 __func__, xfer, noxfer, unused);
-
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
 
-- 
1.7.6.5
