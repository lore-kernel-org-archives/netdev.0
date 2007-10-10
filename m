From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: [PATCH 3/3] xen-netfront: remove dead code
Date: Tue, 09 Oct 2007 18:13:41 -0700
Message-ID: <470C2745.2060505@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@stusta.de>,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:47766 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756808AbXJJBOZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 21:14:25 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes some residual dead code left over from removing the
"flip" receive mode.  This patch doesn't change the generated output
at all, since gcc already realized it was dead.

This resolves the "regression" reported by Adrian.

Signed-off-by: Jeremy Fitzhardinge <jeremy@xensource.com>
Cc: Adrian Bunk <bunk@stusta.de>
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

---
 drivers/net/xen-netfront.c |   37 ++-----------------------------------
 1 file changed, 2 insertions(+), 35 deletions(-)

===================================================================
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -209,11 +209,9 @@ static void xennet_alloc_rx_buffers(stru
 	struct page *page;
 	int i, batch_target, notify;
 	RING_IDX req_prod = np->rx.req_prod_pvt;
-	struct xen_memory_reservation reservation;
 	grant_ref_t ref;
 	unsigned long pfn;
 	void *vaddr;
-	int nr_flips;
 	struct xen_netif_rx_request *req;
 
 	if (unlikely(!netif_carrier_ok(dev)))
@@ -263,7 +261,7 @@ no_skb:
 		np->rx_target = np->rx_max_target;
 
  refill:
-	for (nr_flips = i = 0; ; i++) {
+	for (i = 0; ; i++) {
 		skb = __skb_dequeue(&np->rx_batch);
 		if (skb == NULL)
 			break;
@@ -292,38 +290,7 @@ no_skb:
 		req->gref = ref;
 	}
 
-	if (nr_flips != 0) {
-		reservation.extent_start = np->rx_pfn_array;
-		reservation.nr_extents   = nr_flips;
-		reservation.extent_order = 0;
-		reservation.address_bits = 0;
-		reservation.domid        = DOMID_SELF;
-
-		if (!xen_feature(XENFEAT_auto_translated_physmap)) {
-			/* After all PTEs have been zapped, flush the TLB. */
-			np->rx_mcl[i-1].args[MULTI_UVMFLAGS_INDEX] =
-				UVMF_TLB_FLUSH|UVMF_ALL;
-
-			/* Give away a batch of pages. */
-			np->rx_mcl[i].op = __HYPERVISOR_memory_op;
-			np->rx_mcl[i].args[0] = XENMEM_decrease_reservation;
-			np->rx_mcl[i].args[1] = (unsigned long)&reservation;
-
-			/* Zap PTEs and give away pages in one big
-			 * multicall. */
-			(void)HYPERVISOR_multicall(np->rx_mcl, i+1);
-
-			/* Check return status of HYPERVISOR_memory_op(). */
-			if (unlikely(np->rx_mcl[i].result != i))
-				panic("Unable to reduce memory reservation\n");
-		} else {
-			if (HYPERVISOR_memory_op(XENMEM_decrease_reservation,
-						 &reservation) != i)
-				panic("Unable to reduce memory reservation\n");
-		}
-	} else {
-		wmb();		/* barrier so backend seens requests */
-	}
+	wmb();		/* barrier so backend seens requests */
 
 	/* Above is a suitable barrier to ensure backend will see requests. */
 	np->rx.req_prod_pvt = req_prod + i;

