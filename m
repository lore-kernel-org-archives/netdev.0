From: Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Fri, 5 Aug 2016 01:29:02 +0200
Message-ID: <9ebb6cb7-c793-cd76-5283-c9a659d0398f@gmx.de>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sdharia-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, shankerd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	vikrams-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, gavidov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	mlangsdo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agross-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1470255143-3979-1-git-send-email-timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Timur,

On 03.08.2016 22:12, Timur Tabi wrote:


> +/* Fill up transmit descriptors */
> +static void emac_tx_fill_tpd(struct emac_adapter *adpt,
> +			     struct emac_tx_queue *tx_q, struct sk_buff *skb,
> +			     struct emac_tpd *tpd)
> +{
> +	u16 nr_frags = skb_shinfo(skb)->nr_frags;
> +	unsigned int len = skb_headlen(skb);
> +	struct emac_buffer *tpbuf = NULL;
> +	unsigned int mapped_len = 0;
> +	unsigned int i;
> +	int ret;
> +
> +	/* if Large Segment Offload is (in TCP Segmentation Offload struct) */
> +	if (TPD_LSO(tpd)) {
> +		mapped_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
> +
> +		tpbuf = GET_TPD_BUFFER(tx_q, tx_q->tpd.produce_idx);
> +		tpbuf->length = mapped_len;
> +		tpbuf->dma_addr = dma_map_single(adpt->netdev->dev.parent,
> +						 skb->data, mapped_len,
> +						 DMA_TO_DEVICE);
> +		ret = dma_mapping_error(adpt->netdev->dev.parent,
> +					tpbuf->dma_addr);
> +		if (ret) {
> +			dev_kfree_skb(skb);
> +			return;
> +		}
> +
> +		TPD_BUFFER_ADDR_L_SET(tpd, lower_32_bits(tpbuf->dma_addr));
> +		TPD_BUFFER_ADDR_H_SET(tpd, upper_32_bits(tpbuf->dma_addr));

You should also take big endian systems into account. This means that if the multi-byte values
in the descriptors require little-endian you have to convert from host byte order to le and
vice versa. You can use cpu_to_le32() and friends for this. 


> +		TPD_BUF_LEN_SET(tpd, tpbuf->length);
> +		emac_tx_tpd_create(adpt, tx_q, tpd);
> +	}
> +
> +	if (mapped_len < len) {
> +		tpbuf = GET_TPD_BUFFER(tx_q, tx_q->tpd.produce_idx);
> +		tpbuf->length = len - mapped_len;
> +		tpbuf->dma_addr = dma_map_single(adpt->netdev->dev.parent,
> +						 skb->data + mapped_len,
> +						 tpbuf->length, DMA_TO_DEVICE);
> +		ret = dma_mapping_error(adpt->netdev->dev.parent,
> +					tpbuf->dma_addr);
> +		if (ret) {
> +			dev_kfree_skb(skb);
> +			return;
> +		}
> +
> +		TPD_BUFFER_ADDR_L_SET(tpd, lower_32_bits(tpbuf->dma_addr));
> +		TPD_BUFFER_ADDR_H_SET(tpd, upper_32_bits(tpbuf->dma_addr));
> +		TPD_BUF_LEN_SET(tpd, tpbuf->length);
> +		emac_tx_tpd_create(adpt, tx_q, tpd);
> +	}
> +
> +	for (i = 0; i < nr_frags; i++) {
> +		struct skb_frag_struct *frag;
> +
> +		frag = &skb_shinfo(skb)->frags[i];
> +
> +		tpbuf = GET_TPD_BUFFER(tx_q, tx_q->tpd.produce_idx);
> +		tpbuf->length = frag->size;
> +		tpbuf->dma_addr = dma_map_page(adpt->netdev->dev.parent,
> +					       frag->page.p, frag->page_offset,
> +					       tpbuf->length, DMA_TO_DEVICE);
> +		ret = dma_mapping_error(adpt->netdev->dev.parent,
> +					tpbuf->dma_addr);
> +		if (ret) {
> +			dev_kfree_skb(skb);
> +			return;
> +		}

In case of error you need to undo all mappings that you have done so far.

> +
> +		TPD_BUFFER_ADDR_L_SET(tpd, lower_32_bits(tpbuf->dma_addr));
> +		TPD_BUFFER_ADDR_H_SET(tpd, upper_32_bits(tpbuf->dma_addr));
> +		TPD_BUF_LEN_SET(tpd, tpbuf->length);
> +		emac_tx_tpd_create(adpt, tx_q, tpd);
> +	}
> +
> +	/* The last tpd */
> +	emac_tx_tpd_mark_last(adpt, tx_q);

Use a wmb() here to make sure that all writes to the descriptors in dma memory
are completed before you update the producer register (see memory-barriers.txt
for the reason why this is needed)

> +	/* The last buffer info contain the skb address,
> +	 * so it will be freed after unmap
> +	 */
> +	tpbuf->skb = skb;
> +}
> +
> +/* Transmit the packet using specified transmit queue */
> +int emac_mac_tx_buf_send(struct emac_adapter *adpt, struct emac_tx_queue *tx_q,
> +			 struct sk_buff *skb)
> +{
> +	struct emac_tpd tpd;
> +	u32 prod_idx;
> +
> +	memset(&tpd, 0, sizeof(tpd));
> +
> +	if (emac_tso_csum(adpt, tx_q, skb, &tpd) != 0) {
> +		dev_kfree_skb_any(skb);
> +		return NETDEV_TX_OK;
> +	}
> +
> +	if (skb_vlan_tag_present(skb)) {
> +		u16 tag;
> +
> +		EMAC_VLAN_TO_TAG(skb_vlan_tag_get(skb), tag);
> +		TPD_CVLAN_TAG_SET(&tpd, tag);
> +		TPD_INSTC_SET(&tpd, 1);
> +	}
> +
> +	if (skb_network_offset(skb) != ETH_HLEN)
> +		TPD_TYP_SET(&tpd, 1);
> +
> +	emac_tx_fill_tpd(adpt, tx_q, skb, &tpd);
> +
> +	netdev_sent_queue(adpt->netdev, skb->len);
> +
> +	if (emac_tpd_num_free_descs(tx_q) <= (MAX_SKB_FRAGS + 1))
> +		netif_stop_queue(adpt->netdev);

Is MAX_SKB_FRAGS + 1 really the max number of descriptors required by your driver?
There seem to be further descriptors needed for TSO and checksumming.
Please make sure that you really check against the _max_ possible number of 
descriptors for a transmission.


> +
> +/* Change the Maximum Transfer Unit (MTU) */
> +static int emac_change_mtu(struct net_device *netdev, int new_mtu)
> +{
> +	unsigned int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
> +	struct emac_adapter *adpt = netdev_priv(netdev);
> +
> +	if ((max_frame < EMAC_MIN_ETH_FRAME_SIZE) ||
> +	    (max_frame > EMAC_MAX_ETH_FRAME_SIZE)) {
> +		netdev_err(adpt->netdev, "error: invalid MTU setting\n");
> +		return -EINVAL;
> +	}
> +
> +	netif_info(adpt, hw, adpt->netdev,
> +		   "changing MTU from %d to %d\n", netdev->mtu,
> +		   new_mtu);
> +	netdev->mtu = new_mtu;
> +	adpt->rxbuf_size = new_mtu > EMAC_DEF_RX_BUF_SIZE ?
> +		ALIGN(max_frame, 8) : EMAC_DEF_RX_BUF_SIZE;
> +
> +	if (netif_running(netdev))
> +		return emac_reinit_locked(adpt);

This does still not look correct. The rxbuf_size is changed while the interface
is still running. If the rx buffers are refilled now, the rx buffers size does
not match the size that is configured in the mac, does it?
You have to stop the rx path first, then change the rx buffer size and then 
restart the rx path.

Regards,
Lino



--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
