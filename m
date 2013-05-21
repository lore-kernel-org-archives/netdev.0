From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH net-next 2/2] cxgb3: Check and handle the dma mapping errors
Date: Tue, 21 May 2013 19:51:29 +0530
Message-ID: <1369146089-19060-3-git-send-email-vipul@chelsio.com>
References: <1369146089-19060-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, divy@chelsio.com, dm@chelsio.com,
	santosh@chelsio.com, fenlason@redhat.com, vipul@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:3147 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754485Ab3EUO2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 10:28:00 -0400
In-Reply-To: <1369146089-19060-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santosh Rastapur <santosh@chelsio.com>

This patch adds checks at approprate places whether *dma_map*() call has
succeeded or not.

Signed-off-by: Santosh Rastapur <santosh@chelsio.com>
Reviewed-by: Jay Fenlason <fenlason@redhat.com>
---
 drivers/net/ethernet/chelsio/cxgb3/sge.c | 105 ++++++++++++++++++++++++-------
 1 file changed, 82 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/sge.c b/drivers/net/ethernet/chelsio/cxgb3/sge.c
index f12e6b8..2fd773e 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/sge.c
@@ -455,6 +455,11 @@ static int alloc_pg_chunk(struct adapter *adapter, struct sge_fl *q,
 		q->pg_chunk.offset = 0;
 		mapping = pci_map_page(adapter->pdev, q->pg_chunk.page,
 				       0, q->alloc_size, PCI_DMA_FROMDEVICE);
+		if (unlikely(pci_dma_mapping_error(adapter->pdev, mapping))) {
+			__free_pages(q->pg_chunk.page, order);
+			q->pg_chunk.page = NULL;
+			return -EIO;
+		}
 		q->pg_chunk.mapping = mapping;
 	}
 	sd->pg_chunk = q->pg_chunk;
@@ -949,40 +954,75 @@ static inline unsigned int calc_tx_descs(const struct sk_buff *skb)
 	return flits_to_desc(flits);
 }
 
+
+/*	map_skb - map a packet main body and its page fragments
+ *	@pdev: the PCI device
+ *	@skb: the packet
+ *	@addr: placeholder to save the mapped addresses
+ *
+ *	map the main body of an sk_buff and its page fragments, if any.
+ */
+static int map_skb(struct pci_dev *pdev, const struct sk_buff *skb,
+		   dma_addr_t *addr)
+{
+	const skb_frag_t *fp, *end;
+	const struct skb_shared_info *si;
+
+	*addr = pci_map_single(pdev, skb->data, skb_headlen(skb),
+			       PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(pdev, *addr))
+		goto out_err;
+
+	si = skb_shinfo(skb);
+	end = &si->frags[si->nr_frags];
+
+	for (fp = si->frags; fp < end; fp++) {
+		*++addr = skb_frag_dma_map(&pdev->dev, fp, 0, skb_frag_size(fp),
+					   DMA_TO_DEVICE);
+		if (pci_dma_mapping_error(pdev, *addr))
+			goto unwind;
+	}
+	return 0;
+
+unwind:
+	while (fp-- > si->frags)
+		dma_unmap_page(&pdev->dev, *--addr, skb_frag_size(fp),
+			       DMA_TO_DEVICE);
+
+	pci_unmap_single(pdev, addr[-1], skb_headlen(skb), PCI_DMA_TODEVICE);
+out_err:
+	return -ENOMEM;
+}
+
 /**
- *	make_sgl - populate a scatter/gather list for a packet
+ *	write_sgl - populate a scatter/gather list for a packet
  *	@skb: the packet
  *	@sgp: the SGL to populate
  *	@start: start address of skb main body data to include in the SGL
  *	@len: length of skb main body data to include in the SGL
- *	@pdev: the PCI device
+ *	@addr: the list of the mapped addresses
  *
- *	Generates a scatter/gather list for the buffers that make up a packet
+ *	Copies the scatter/gather list for the buffers that make up a packet
  *	and returns the SGL size in 8-byte words.  The caller must size the SGL
  *	appropriately.
  */
-static inline unsigned int make_sgl(const struct sk_buff *skb,
+static inline unsigned int write_sgl(const struct sk_buff *skb,
 				    struct sg_ent *sgp, unsigned char *start,
-				    unsigned int len, struct pci_dev *pdev)
+				    unsigned int len, const dma_addr_t *addr)
 {
-	dma_addr_t mapping;
-	unsigned int i, j = 0, nfrags;
+	unsigned int i, j = 0, k = 0, nfrags;
 
 	if (len) {
-		mapping = pci_map_single(pdev, start, len, PCI_DMA_TODEVICE);
 		sgp->len[0] = cpu_to_be32(len);
-		sgp->addr[0] = cpu_to_be64(mapping);
-		j = 1;
+		sgp->addr[j++] = cpu_to_be64(addr[k++]);
 	}
 
 	nfrags = skb_shinfo(skb)->nr_frags;
 	for (i = 0; i < nfrags; i++) {
 		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-		mapping = skb_frag_dma_map(&pdev->dev, frag, 0, skb_frag_size(frag),
-					   DMA_TO_DEVICE);
 		sgp->len[j] = cpu_to_be32(skb_frag_size(frag));
-		sgp->addr[j] = cpu_to_be64(mapping);
+		sgp->addr[j] = cpu_to_be64(addr[k++]);
 		j ^= 1;
 		if (j == 0)
 			++sgp;
@@ -1138,7 +1178,7 @@ static void write_tx_pkt_wr(struct adapter *adap, struct sk_buff *skb,
 			    const struct port_info *pi,
 			    unsigned int pidx, unsigned int gen,
 			    struct sge_txq *q, unsigned int ndesc,
-			    unsigned int compl)
+			    unsigned int compl, const dma_addr_t *addr)
 {
 	unsigned int flits, sgl_flits, cntrl, tso_info;
 	struct sg_ent *sgp, sgl[MAX_SKB_FRAGS / 2 + 1];
@@ -1196,7 +1236,7 @@ static void write_tx_pkt_wr(struct adapter *adap, struct sk_buff *skb,
 	}
 
 	sgp = ndesc == 1 ? (struct sg_ent *)&d->flit[flits] : sgl;
-	sgl_flits = make_sgl(skb, sgp, skb->data, skb_headlen(skb), adap->pdev);
+	sgl_flits = write_sgl(skb, sgp, skb->data, skb_headlen(skb), addr);
 
 	write_wr_hdr_sgl(ndesc, skb, d, pidx, q, sgl, flits, sgl_flits, gen,
 			 htonl(V_WR_OP(FW_WROPCODE_TUNNEL_TX_PKT) | compl),
@@ -1227,6 +1267,7 @@ netdev_tx_t t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct netdev_queue *txq;
 	struct sge_qset *qs;
 	struct sge_txq *q;
+	dma_addr_t addr[MAX_SKB_FRAGS + 1];
 
 	/*
 	 * The chip min packet length is 9 octets but play safe and reject
@@ -1255,6 +1296,11 @@ netdev_tx_t t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 
+	if (unlikely(map_skb(adap->pdev, skb, addr) < 0)) {
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+
 	q->in_use += ndesc;
 	if (unlikely(credits - ndesc < q->stop_thres)) {
 		t3_stop_tx_queue(txq, qs, q);
@@ -1312,7 +1358,7 @@ netdev_tx_t t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (likely(!skb_shared(skb)))
 		skb_orphan(skb);
 
-	write_tx_pkt_wr(adap, skb, pi, pidx, gen, q, ndesc, compl);
+	write_tx_pkt_wr(adap, skb, pi, pidx, gen, q, ndesc, compl, addr);
 	check_ring_tx_db(adap, q);
 	return NETDEV_TX_OK;
 }
@@ -1578,7 +1624,8 @@ static void setup_deferred_unmapping(struct sk_buff *skb, struct pci_dev *pdev,
  */
 static void write_ofld_wr(struct adapter *adap, struct sk_buff *skb,
 			  struct sge_txq *q, unsigned int pidx,
-			  unsigned int gen, unsigned int ndesc)
+			  unsigned int gen, unsigned int ndesc,
+			  const dma_addr_t *addr)
 {
 	unsigned int sgl_flits, flits;
 	struct work_request_hdr *from;
@@ -1599,9 +1646,9 @@ static void write_ofld_wr(struct adapter *adap, struct sk_buff *skb,
 
 	flits = skb_transport_offset(skb) / 8;
 	sgp = ndesc == 1 ? (struct sg_ent *)&d->flit[flits] : sgl;
-	sgl_flits = make_sgl(skb, sgp, skb_transport_header(skb),
+	sgl_flits = write_sgl(skb, sgp, skb_transport_header(skb),
 			     skb->tail - skb->transport_header,
-			     adap->pdev);
+			     addr);
 	if (need_skb_unmap()) {
 		setup_deferred_unmapping(skb, adap->pdev, sgp, sgl_flits);
 		skb->destructor = deferred_unmap_destructor;
@@ -1659,6 +1706,11 @@ again:	reclaim_completed_tx(adap, q, TX_RECLAIM_CHUNK);
 		goto again;
 	}
 
+	if (map_skb(adap->pdev, skb, (dma_addr_t *)skb->head)) {
+		spin_unlock(&q->lock);
+		return NET_XMIT_SUCCESS;
+	}
+
 	gen = q->gen;
 	q->in_use += ndesc;
 	pidx = q->pidx;
@@ -1669,7 +1721,7 @@ again:	reclaim_completed_tx(adap, q, TX_RECLAIM_CHUNK);
 	}
 	spin_unlock(&q->lock);
 
-	write_ofld_wr(adap, skb, q, pidx, gen, ndesc);
+	write_ofld_wr(adap, skb, q, pidx, gen, ndesc, (dma_addr_t *)skb->head);
 	check_ring_tx_db(adap, q);
 	return NET_XMIT_SUCCESS;
 }
@@ -1687,6 +1739,7 @@ static void restart_offloadq(unsigned long data)
 	struct sge_txq *q = &qs->txq[TXQ_OFLD];
 	const struct port_info *pi = netdev_priv(qs->netdev);
 	struct adapter *adap = pi->adapter;
+	unsigned int written = 0;
 
 	spin_lock(&q->lock);
 again:	reclaim_completed_tx(adap, q, TX_RECLAIM_CHUNK);
@@ -1706,10 +1759,14 @@ again:	reclaim_completed_tx(adap, q, TX_RECLAIM_CHUNK);
 			break;
 		}
 
+		if (map_skb(adap->pdev, skb, (dma_addr_t *)skb->head))
+			break;
+
 		gen = q->gen;
 		q->in_use += ndesc;
 		pidx = q->pidx;
 		q->pidx += ndesc;
+		written += ndesc;
 		if (q->pidx >= q->size) {
 			q->pidx -= q->size;
 			q->gen ^= 1;
@@ -1717,7 +1774,8 @@ again:	reclaim_completed_tx(adap, q, TX_RECLAIM_CHUNK);
 		__skb_unlink(skb, &q->sendq);
 		spin_unlock(&q->lock);
 
-		write_ofld_wr(adap, skb, q, pidx, gen, ndesc);
+		write_ofld_wr(adap, skb, q, pidx, gen, ndesc,
+			     (dma_addr_t *)skb->head);
 		spin_lock(&q->lock);
 	}
 	spin_unlock(&q->lock);
@@ -1727,8 +1785,9 @@ again:	reclaim_completed_tx(adap, q, TX_RECLAIM_CHUNK);
 	set_bit(TXQ_LAST_PKT_DB, &q->flags);
 #endif
 	wmb();
-	t3_write_reg(adap, A_SG_KDOORBELL,
-		     F_SELEGRCNTX | V_EGRCNTX(q->cntxt_id));
+	if (likely(written))
+		t3_write_reg(adap, A_SG_KDOORBELL,
+			     F_SELEGRCNTX | V_EGRCNTX(q->cntxt_id));
 }
 
 /**
-- 
1.8.0
