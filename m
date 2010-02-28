From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH] cxgb4: Remove need_skb_unmap and adjust its callers.
Date: Sat, 27 Feb 2010 19:00:24 -0800
Message-ID: <1267326024-3610-1-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:20437 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966874Ab0B1DAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 22:00:24 -0500
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o1S30OFP025423
	for <netdev@vger.kernel.org>; Sat, 27 Feb 2010 19:00:24 -0800
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id o1S30O3L003632
	for <netdev@vger.kernel.org>; Sat, 27 Feb 2010 19:00:24 -0800
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id o1S30OH9003631
	for netdev@vger.kernel.org; Sat, 27 Feb 2010 19:00:24 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applies on top of the V3 patches.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/sge.c |   29 +++--------------------------
 1 files changed, 3 insertions(+), 26 deletions(-)

diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
index 34617f8..eb81d73 100644
--- a/drivers/net/cxgb4/sge.c
+++ b/drivers/net/cxgb4/sge.c
@@ -298,25 +298,6 @@ unmap:			dma_unmap_page(dev, be64_to_cpu(p->addr[0]),
 }
 
 /**
- *	need_skb_unmap - does the platform need unmapping of sk_buffs?
- *
- *	Returns true if the platfrom needs sk_buff unmapping.  The compiler
- *	optimizes away unecessary code if this returns true.
- */
-static inline int need_skb_unmap(void)
-{
-	/*
-	 * This structure is used to tell if the platfrom needs buffer
-	 * unmapping by checking if DECLARE_PCI_UNMAP_ADDR defines anything.
-	 */
-	struct dummy {
-		DECLARE_PCI_UNMAP_ADDR(addr);
-	};
-
-	return sizeof(struct dummy) != 0;
-}
-
-/**
  *	free_tx_desc - reclaims Tx descriptors and their buffers
  *	@adapter: the adapter
  *	@q: the Tx queue to reclaim descriptors from
@@ -333,12 +314,10 @@ static void free_tx_desc(struct adapter *adap, struct sge_txq *q,
 	unsigned int cidx = q->cidx;
 	struct device *dev = adap->pdev_dev;
 
-	const int need_unmap = need_skb_unmap() && unmap;
-
 	d = &q->sdesc[cidx];
 	while (n--) {
 		if (d->skb) {                       /* an SGL is present */
-			if (need_unmap)
+			if (unmap)
 				unmap_sgl(dev, d->skb, d->sgl, q);
 			kfree_skb(d->skb);
 			d->skb = NULL;
@@ -1300,10 +1279,8 @@ static void service_ofldq(struct sge_ofld_txq *q)
 				  pos + flits, hdr_len,
 				  (dma_addr_t *)skb->head);
 
-			if (need_skb_unmap()) {
-				skb->dev = q->adap->port[0];
-				skb->destructor = deferred_unmap_destructor;
-			}
+			skb->dev = q->adap->port[0];
+			skb->destructor = deferred_unmap_destructor;
 
 			last_desc = q->q.pidx + ndesc - 1;
 			if (last_desc >= q->q.size)
-- 
1.5.4

