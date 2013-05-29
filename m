From: Simon Horman <horms@verge.net.au>
Subject: [PATCH net-next v2 2/7] cxgb3: Correct comparisons and calculations using skb->tail and skb-transport_header
Date: Wed, 29 May 2013 15:34:24 +0900
Message-ID: <1369809269-13130-3-git-send-email-horms@verge.net.au>
References: <1369809269-13130-1-git-send-email-horms@verge.net.au>
Cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:53139 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753589Ab3E2Gds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 02:33:48 -0400
In-Reply-To: <1369809269-13130-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This corrects an regression introduced by "net: Use 16bits for *_headers
fields of struct skbuff" when NET_SKBUFF_DATA_USES_OFFSET is not set. In
that case skb->tail will be a pointer whereas skb->transport_header
will be an offset from head. This is corrected by using wrappers that
ensure that comparisons and calculations are always made using pointers.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 drivers/net/ethernet/chelsio/cxgb3/sge.c |   11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/sge.c b/drivers/net/ethernet/chelsio/cxgb3/sge.c
index 2fd773e..46d1efc 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/sge.c
@@ -1584,9 +1584,8 @@ static void deferred_unmap_destructor(struct sk_buff *skb)
 	p = dui->addr;
 
 	if (skb->tail - skb->transport_header)
-		pci_unmap_single(dui->pdev, *p++,
-				 skb->tail - skb->transport_header,
-				 PCI_DMA_TODEVICE);
+		pci_unmap_single(dui->pdev, *p++, skb_tail_pointer(skb) -
+				 skb_transport_header(skb), PCI_DMA_TODEVICE);
 
 	si = skb_shinfo(skb);
 	for (i = 0; i < si->nr_frags; i++)
@@ -1647,8 +1646,8 @@ static void write_ofld_wr(struct adapter *adap, struct sk_buff *skb,
 	flits = skb_transport_offset(skb) / 8;
 	sgp = ndesc == 1 ? (struct sg_ent *)&d->flit[flits] : sgl;
 	sgl_flits = write_sgl(skb, sgp, skb_transport_header(skb),
-			     skb->tail - skb->transport_header,
-			     addr);
+			     skb_tail_pointer(skb) -
+			     skb_transport_header(skb), addr);
 	if (need_skb_unmap()) {
 		setup_deferred_unmapping(skb, adap->pdev, sgp, sgl_flits);
 		skb->destructor = deferred_unmap_destructor;
@@ -1674,7 +1673,7 @@ static inline unsigned int calc_tx_descs_ofld(const struct sk_buff *skb)
 
 	flits = skb_transport_offset(skb) / 8;	/* headers */
 	cnt = skb_shinfo(skb)->nr_frags;
-	if (skb->tail != skb->transport_header)
+	if (skb_tail_pointer(skb) != skb_transport_header(skb))
 		cnt++;
 	return flits_to_desc(flits + sgl_len(cnt));
 }
-- 
1.7.10.4
