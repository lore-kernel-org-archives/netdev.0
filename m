From: Divy Le ray <divy@chelsio.com>
Subject: Re: [PATCH] Revert "cxgb3: Check and handle the dma mapping errors"
Date: Wed, 14 Aug 2013 08:57:24 -0700
Message-ID: <520BA8E4.3010406@chelsio.com>
References: <1376471941-2914-1-git-send-email-aik@ozlabs.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Santosh Rastapur <santosh@chelsio.com>,
	Jay Fenlason <fenlason@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Alexey Kardashevskiy <aik@ozlabs.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376471941-2914-1-git-send-email-aik@ozlabs.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/14/2013 02:19 AM, Alexey Kardashevskiy wrote:
> This reverts commit f83331bab149e29fa2c49cf102c0cd8c3f1ce9f9.
>
> As the tests PPC64 (powernv platform) show, IOMMU pages are leaking
> when transferring big amount of small packets (<=64 bytes),
> "ping -f" and waiting for 15 seconds is the simplest way to confirm the bug.
>
> Cc: Linus Torvalds<torvalds@linux-foundation.org>
> Cc: Santosh Rastapur<santosh@chelsio.com>
> Cc: Jay Fenlason<fenlason@redhat.com>
> Cc: David S. Miller<davem@davemloft.net>
> Cc: Divy Le ray<divy@chelsio.com>
> Signed-off-by: Alexey Kardashevskiy<aik@ozlabs.ru>

Acked-by: Divy Le Ray <divy@chelsio.com>

We are revisiting this patch in the light of the leak, and will repost 
once fixed.

Cheers,
Divy

> ---
>   drivers/net/ethernet/chelsio/cxgb3/sge.c | 107 +++++++------------------------
>   1 file changed, 24 insertions(+), 83 deletions(-)
>
> diff --git a/drivers/net/ethernet/chelsio/cxgb3/sge.c b/drivers/net/ethernet/chelsio/cxgb3/sge.c
> index 687ec4a..9c89dc8 100644
> --- a/drivers/net/ethernet/chelsio/cxgb3/sge.c
> +++ b/drivers/net/ethernet/chelsio/cxgb3/sge.c
> @@ -455,11 +455,6 @@ static int alloc_pg_chunk(struct adapter *adapter, struct sge_fl *q,
>   		q->pg_chunk.offset = 0;
>   		mapping = pci_map_page(adapter->pdev, q->pg_chunk.page,
>   				       0, q->alloc_size, PCI_DMA_FROMDEVICE);
> -		if (unlikely(pci_dma_mapping_error(adapter->pdev, mapping))) {
> -			__free_pages(q->pg_chunk.page, order);
> -			q->pg_chunk.page = NULL;
> -			return -EIO;
> -		}
>   		q->pg_chunk.mapping = mapping;
>   	}
>   	sd->pg_chunk = q->pg_chunk;
> @@ -954,75 +949,40 @@ static inline unsigned int calc_tx_descs(const struct sk_buff *skb)
>   	return flits_to_desc(flits);
>   }
>   
> -
> -/*	map_skb - map a packet main body and its page fragments
> - *	@pdev: the PCI device
> - *	@skb: the packet
> - *	@addr: placeholder to save the mapped addresses
> - *
> - *	map the main body of an sk_buff and its page fragments, if any.
> - */
> -static int map_skb(struct pci_dev *pdev, const struct sk_buff *skb,
> -		   dma_addr_t *addr)
> -{
> -	const skb_frag_t *fp, *end;
> -	const struct skb_shared_info *si;
> -
> -	*addr = pci_map_single(pdev, skb->data, skb_headlen(skb),
> -			       PCI_DMA_TODEVICE);
> -	if (pci_dma_mapping_error(pdev, *addr))
> -		goto out_err;
> -
> -	si = skb_shinfo(skb);
> -	end = &si->frags[si->nr_frags];
> -
> -	for (fp = si->frags; fp < end; fp++) {
> -		*++addr = skb_frag_dma_map(&pdev->dev, fp, 0, skb_frag_size(fp),
> -					   DMA_TO_DEVICE);
> -		if (pci_dma_mapping_error(pdev, *addr))
> -			goto unwind;
> -	}
> -	return 0;
> -
> -unwind:
> -	while (fp-- > si->frags)
> -		dma_unmap_page(&pdev->dev, *--addr, skb_frag_size(fp),
> -			       DMA_TO_DEVICE);
> -
> -	pci_unmap_single(pdev, addr[-1], skb_headlen(skb), PCI_DMA_TODEVICE);
> -out_err:
> -	return -ENOMEM;
> -}
> -
>   /**
> - *	write_sgl - populate a scatter/gather list for a packet
> + *	make_sgl - populate a scatter/gather list for a packet
>    *	@skb: the packet
>    *	@sgp: the SGL to populate
>    *	@start: start address of skb main body data to include in the SGL
>    *	@len: length of skb main body data to include in the SGL
> - *	@addr: the list of the mapped addresses
> + *	@pdev: the PCI device
>    *
> - *	Copies the scatter/gather list for the buffers that make up a packet
> + *	Generates a scatter/gather list for the buffers that make up a packet
>    *	and returns the SGL size in 8-byte words.  The caller must size the SGL
>    *	appropriately.
>    */
> -static inline unsigned int write_sgl(const struct sk_buff *skb,
> +static inline unsigned int make_sgl(const struct sk_buff *skb,
>   				    struct sg_ent *sgp, unsigned char *start,
> -				    unsigned int len, const dma_addr_t *addr)
> +				    unsigned int len, struct pci_dev *pdev)
>   {
> -	unsigned int i, j = 0, k = 0, nfrags;
> +	dma_addr_t mapping;
> +	unsigned int i, j = 0, nfrags;
>   
>   	if (len) {
> +		mapping = pci_map_single(pdev, start, len, PCI_DMA_TODEVICE);
>   		sgp->len[0] = cpu_to_be32(len);
> -		sgp->addr[j++] = cpu_to_be64(addr[k++]);
> +		sgp->addr[0] = cpu_to_be64(mapping);
> +		j = 1;
>   	}
>   
>   	nfrags = skb_shinfo(skb)->nr_frags;
>   	for (i = 0; i < nfrags; i++) {
>   		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
>   
> +		mapping = skb_frag_dma_map(&pdev->dev, frag, 0, skb_frag_size(frag),
> +					   DMA_TO_DEVICE);
>   		sgp->len[j] = cpu_to_be32(skb_frag_size(frag));
> -		sgp->addr[j] = cpu_to_be64(addr[k++]);
> +		sgp->addr[j] = cpu_to_be64(mapping);
>   		j ^= 1;
>   		if (j == 0)
>   			++sgp;
> @@ -1178,7 +1138,7 @@ static void write_tx_pkt_wr(struct adapter *adap, struct sk_buff *skb,
>   			    const struct port_info *pi,
>   			    unsigned int pidx, unsigned int gen,
>   			    struct sge_txq *q, unsigned int ndesc,
> -			    unsigned int compl, const dma_addr_t *addr)
> +			    unsigned int compl)
>   {
>   	unsigned int flits, sgl_flits, cntrl, tso_info;
>   	struct sg_ent *sgp, sgl[MAX_SKB_FRAGS / 2 + 1];
> @@ -1236,7 +1196,7 @@ static void write_tx_pkt_wr(struct adapter *adap, struct sk_buff *skb,
>   	}
>   
>   	sgp = ndesc == 1 ? (struct sg_ent *)&d->flit[flits] : sgl;
> -	sgl_flits = write_sgl(skb, sgp, skb->data, skb_headlen(skb), addr);
> +	sgl_flits = make_sgl(skb, sgp, skb->data, skb_headlen(skb), adap->pdev);
>   
>   	write_wr_hdr_sgl(ndesc, skb, d, pidx, q, sgl, flits, sgl_flits, gen,
>   			 htonl(V_WR_OP(FW_WROPCODE_TUNNEL_TX_PKT) | compl),
> @@ -1267,7 +1227,6 @@ netdev_tx_t t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
>   	struct netdev_queue *txq;
>   	struct sge_qset *qs;
>   	struct sge_txq *q;
> -	dma_addr_t addr[MAX_SKB_FRAGS + 1];
>   
>   	/*
>   	 * The chip min packet length is 9 octets but play safe and reject
> @@ -1296,11 +1255,6 @@ netdev_tx_t t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
>   		return NETDEV_TX_BUSY;
>   	}
>   
> -	if (unlikely(map_skb(adap->pdev, skb, addr) < 0)) {
> -		dev_kfree_skb(skb);
> -		return NETDEV_TX_OK;
> -	}
> -
>   	q->in_use += ndesc;
>   	if (unlikely(credits - ndesc < q->stop_thres)) {
>   		t3_stop_tx_queue(txq, qs, q);
> @@ -1358,7 +1312,7 @@ netdev_tx_t t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
>   	if (likely(!skb_shared(skb)))
>   		skb_orphan(skb);
>   
> -	write_tx_pkt_wr(adap, skb, pi, pidx, gen, q, ndesc, compl, addr);
> +	write_tx_pkt_wr(adap, skb, pi, pidx, gen, q, ndesc, compl);
>   	check_ring_tx_db(adap, q);
>   	return NETDEV_TX_OK;
>   }
> @@ -1623,8 +1577,7 @@ static void setup_deferred_unmapping(struct sk_buff *skb, struct pci_dev *pdev,
>    */
>   static void write_ofld_wr(struct adapter *adap, struct sk_buff *skb,
>   			  struct sge_txq *q, unsigned int pidx,
> -			  unsigned int gen, unsigned int ndesc,
> -			  const dma_addr_t *addr)
> +			  unsigned int gen, unsigned int ndesc)
>   {
>   	unsigned int sgl_flits, flits;
>   	struct work_request_hdr *from;
> @@ -1645,9 +1598,9 @@ static void write_ofld_wr(struct adapter *adap, struct sk_buff *skb,
>   
>   	flits = skb_transport_offset(skb) / 8;
>   	sgp = ndesc == 1 ? (struct sg_ent *)&d->flit[flits] : sgl;
> -	sgl_flits = write_sgl(skb, sgp, skb_transport_header(skb),
> -			     skb_tail_pointer(skb) -
> -			     skb_transport_header(skb), addr);
> +	sgl_flits = make_sgl(skb, sgp, skb_transport_header(skb),
> +			     skb->tail - skb->transport_header,
> +			     adap->pdev);
>   	if (need_skb_unmap()) {
>   		setup_deferred_unmapping(skb, adap->pdev, sgp, sgl_flits);
>   		skb->destructor = deferred_unmap_destructor;
> @@ -1705,11 +1658,6 @@ again:	reclaim_completed_tx(adap, q, TX_RECLAIM_CHUNK);
>   		goto again;
>   	}
>   
> -	if (map_skb(adap->pdev, skb, (dma_addr_t *)skb->head)) {
> -		spin_unlock(&q->lock);
> -		return NET_XMIT_SUCCESS;
> -	}
> -
>   	gen = q->gen;
>   	q->in_use += ndesc;
>   	pidx = q->pidx;
> @@ -1720,7 +1668,7 @@ again:	reclaim_completed_tx(adap, q, TX_RECLAIM_CHUNK);
>   	}
>   	spin_unlock(&q->lock);
>   
> -	write_ofld_wr(adap, skb, q, pidx, gen, ndesc, (dma_addr_t *)skb->head);
> +	write_ofld_wr(adap, skb, q, pidx, gen, ndesc);
>   	check_ring_tx_db(adap, q);
>   	return NET_XMIT_SUCCESS;
>   }
> @@ -1738,7 +1686,6 @@ static void restart_offloadq(unsigned long data)
>   	struct sge_txq *q = &qs->txq[TXQ_OFLD];
>   	const struct port_info *pi = netdev_priv(qs->netdev);
>   	struct adapter *adap = pi->adapter;
> -	unsigned int written = 0;
>   
>   	spin_lock(&q->lock);
>   again:	reclaim_completed_tx(adap, q, TX_RECLAIM_CHUNK);
> @@ -1758,14 +1705,10 @@ again:	reclaim_completed_tx(adap, q, TX_RECLAIM_CHUNK);
>   			break;
>   		}
>   
> -		if (map_skb(adap->pdev, skb, (dma_addr_t *)skb->head))
> -			break;
> -
>   		gen = q->gen;
>   		q->in_use += ndesc;
>   		pidx = q->pidx;
>   		q->pidx += ndesc;
> -		written += ndesc;
>   		if (q->pidx >= q->size) {
>   			q->pidx -= q->size;
>   			q->gen ^= 1;
> @@ -1773,8 +1716,7 @@ again:	reclaim_completed_tx(adap, q, TX_RECLAIM_CHUNK);
>   		__skb_unlink(skb, &q->sendq);
>   		spin_unlock(&q->lock);
>   
> -		write_ofld_wr(adap, skb, q, pidx, gen, ndesc,
> -			     (dma_addr_t *)skb->head);
> +		write_ofld_wr(adap, skb, q, pidx, gen, ndesc);
>   		spin_lock(&q->lock);
>   	}
>   	spin_unlock(&q->lock);
> @@ -1784,9 +1726,8 @@ again:	reclaim_completed_tx(adap, q, TX_RECLAIM_CHUNK);
>   	set_bit(TXQ_LAST_PKT_DB, &q->flags);
>   #endif
>   	wmb();
> -	if (likely(written))
> -		t3_write_reg(adap, A_SG_KDOORBELL,
> -			     F_SELEGRCNTX | V_EGRCNTX(q->cntxt_id));
> +	t3_write_reg(adap, A_SG_KDOORBELL,
> +		     F_SELEGRCNTX | V_EGRCNTX(q->cntxt_id));
>   }
>   
>   /**
