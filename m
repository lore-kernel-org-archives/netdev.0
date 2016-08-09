From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Tue, 9 Aug 2016 13:25:05 -0500
Message-ID: <57AA2001.2010904@codeaurora.org>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
 <9ebb6cb7-c793-cd76-5283-c9a659d0398f@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	sdharia@codeaurora.org, shankerd@codeaurora.org,
	vikrams@codeaurora.org, cov@codeaurora.org, gavidov@codeaurora.org,
	robh+dt@kernel.org, andrew@lunn.ch, bjorn.andersson@linaro.org,
	mlangsdo@redhat.com, jcm@redhat.com, agross@codeaurora.org,
	davem@davemloft.net, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:44219 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751919AbcHIS0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 14:26:33 -0400
In-Reply-To: <9ebb6cb7-c793-cd76-5283-c9a659d0398f@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lino Sanfilippo wrote:

>> +/* Fill up transmit descriptors */
>> +static void emac_tx_fill_tpd(struct emac_adapter *adpt,
>> +			     struct emac_tx_queue *tx_q, struct sk_buff *skb,
>> +			     struct emac_tpd *tpd)
>> +{
>> +	u16 nr_frags = skb_shinfo(skb)->nr_frags;
>> +	unsigned int len = skb_headlen(skb);
>> +	struct emac_buffer *tpbuf = NULL;
>> +	unsigned int mapped_len = 0;
>> +	unsigned int i;
>> +	int ret;
>> +
>> +	/* if Large Segment Offload is (in TCP Segmentation Offload struct) */
>> +	if (TPD_LSO(tpd)) {
>> +		mapped_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
>> +
>> +		tpbuf = GET_TPD_BUFFER(tx_q, tx_q->tpd.produce_idx);
>> +		tpbuf->length = mapped_len;
>> +		tpbuf->dma_addr = dma_map_single(adpt->netdev->dev.parent,
>> +						 skb->data, mapped_len,
>> +						 DMA_TO_DEVICE);
>> +		ret = dma_mapping_error(adpt->netdev->dev.parent,
>> +					tpbuf->dma_addr);
>> +		if (ret) {
>> +			dev_kfree_skb(skb);
>> +			return;
>> +		}
>> +
>> +		TPD_BUFFER_ADDR_L_SET(tpd, lower_32_bits(tpbuf->dma_addr));
>> +		TPD_BUFFER_ADDR_H_SET(tpd, upper_32_bits(tpbuf->dma_addr));
>
> You should also take big endian systems into account. This means that if the multi-byte values
> in the descriptors require little-endian you have to convert from host byte order to le and
> vice versa. You can use cpu_to_le32() and friends for this.

I used to work on PowerPC, so I respect making things work for both 
endians.  However, even I think that this is overkill for my driver. 
First, there's no way this driver will ever be used on a big-endian 
system.  Second, I'm pretty sure there are lots of places that would 
need cpu_to_le32() in order to make this driver big-endian compatible. 
It would be a huge mess.

#define TPD_BUFFER_ADDR_H_SET(tpd, val)	BITS_SET((tpd)->word[3], 18, 30, 
val)

This macros sets specific bits based on the definition of the register. 
  I could change it to this:

#define TPD_BUFFER_ADDR_H_SET(tpd, val) BITS_SET((tpd)->word[3], 18, 30, 
cpu_to_le32(val))

But I honestly don't see what good that will do.  There are still 
thousands of other places that assume little-endian.

>> +		TPD_BUF_LEN_SET(tpd, tpbuf->length);
>> +		emac_tx_tpd_create(adpt, tx_q, tpd);
>> +	}
>> +
>> +	if (mapped_len < len) {
>> +		tpbuf = GET_TPD_BUFFER(tx_q, tx_q->tpd.produce_idx);
>> +		tpbuf->length = len - mapped_len;
>> +		tpbuf->dma_addr = dma_map_single(adpt->netdev->dev.parent,
>> +						 skb->data + mapped_len,
>> +						 tpbuf->length, DMA_TO_DEVICE);
>> +		ret = dma_mapping_error(adpt->netdev->dev.parent,
>> +					tpbuf->dma_addr);
>> +		if (ret) {
>> +			dev_kfree_skb(skb);
>> +			return;
>> +		}
>> +
>> +		TPD_BUFFER_ADDR_L_SET(tpd, lower_32_bits(tpbuf->dma_addr));
>> +		TPD_BUFFER_ADDR_H_SET(tpd, upper_32_bits(tpbuf->dma_addr));
>> +		TPD_BUF_LEN_SET(tpd, tpbuf->length);
>> +		emac_tx_tpd_create(adpt, tx_q, tpd);
>> +	}
>> +
>> +	for (i = 0; i < nr_frags; i++) {
>> +		struct skb_frag_struct *frag;
>> +
>> +		frag = &skb_shinfo(skb)->frags[i];
>> +
>> +		tpbuf = GET_TPD_BUFFER(tx_q, tx_q->tpd.produce_idx);
>> +		tpbuf->length = frag->size;
>> +		tpbuf->dma_addr = dma_map_page(adpt->netdev->dev.parent,
>> +					       frag->page.p, frag->page_offset,
>> +					       tpbuf->length, DMA_TO_DEVICE);
>> +		ret = dma_mapping_error(adpt->netdev->dev.parent,
>> +					tpbuf->dma_addr);
>> +		if (ret) {
>> +			dev_kfree_skb(skb);
>> +			return;
>> +		}
>
> In case of error you need to undo all mappings that you have done so far.

Ok.

>
>> +
>> +		TPD_BUFFER_ADDR_L_SET(tpd, lower_32_bits(tpbuf->dma_addr));
>> +		TPD_BUFFER_ADDR_H_SET(tpd, upper_32_bits(tpbuf->dma_addr));
>> +		TPD_BUF_LEN_SET(tpd, tpbuf->length);
>> +		emac_tx_tpd_create(adpt, tx_q, tpd);
>> +	}
>> +
>> +	/* The last tpd */
>> +	emac_tx_tpd_mark_last(adpt, tx_q);
>
> Use a wmb() here to make sure that all writes to the descriptors in dma memory
> are completed before you update the producer register (see memory-barriers.txt
> for the reason why this is needed)

Ok.

>> +/* Transmit the packet using specified transmit queue */
>> +int emac_mac_tx_buf_send(struct emac_adapter *adpt, struct emac_tx_queue *tx_q,
>> +			 struct sk_buff *skb)
>> +{
>> +	struct emac_tpd tpd;
>> +	u32 prod_idx;
>> +
>> +	memset(&tpd, 0, sizeof(tpd));
>> +
>> +	if (emac_tso_csum(adpt, tx_q, skb, &tpd) != 0) {
>> +		dev_kfree_skb_any(skb);
>> +		return NETDEV_TX_OK;
>> +	}
>> +
>> +	if (skb_vlan_tag_present(skb)) {
>> +		u16 tag;
>> +
>> +		EMAC_VLAN_TO_TAG(skb_vlan_tag_get(skb), tag);
>> +		TPD_CVLAN_TAG_SET(&tpd, tag);
>> +		TPD_INSTC_SET(&tpd, 1);
>> +	}
>> +
>> +	if (skb_network_offset(skb) != ETH_HLEN)
>> +		TPD_TYP_SET(&tpd, 1);
>> +
>> +	emac_tx_fill_tpd(adpt, tx_q, skb, &tpd);
>> +
>> +	netdev_sent_queue(adpt->netdev, skb->len);
>> +
>> +	if (emac_tpd_num_free_descs(tx_q) <= (MAX_SKB_FRAGS + 1))
>> +		netif_stop_queue(adpt->netdev);
>
> Is MAX_SKB_FRAGS + 1 really the max number of descriptors required by your driver?
> There seem to be further descriptors needed for TSO and checksumming.
> Please make sure that you really check against the _max_ possible number of
> descriptors for a transmission.

I need some help figuring that out.  Like I said, I didn't write this 
driver initially, so there are parts that I don't really understand.  I 
copied the above code from other drivers, but after studying your 
question, I think I understand what you're asking.  I just don't know 
how to fix it.

First of all, why do other drivers test MAX_SKB_FRAGS + 1?  Why the +1?

The driver originally used function emac_tx_has_enough_descs() to 
determine if there is enough room for the new packet.  Then I changed 
the code as you suggested, and now it guesses how many descriptors need 
to be free to support the next packet.

If I'm reading emac_tx_fill_tpd() correctly, there could be as many as 
(2 + skb_shinfo(skb)->nr_frags) descriptors for a given packet.  I don't 
know how big nr_frags could get, so I don't know how to calculate the 
number of descriptors I really need.  I'm assuming I need to do 
something like this:

unsigned int max_desc_per_skb = 2 + ????;
unsigned int num_desc_needed = (MAX_SKB_FRAGS + 1) * max_desc_per_skb;

if (emac_tpd_num_free_descs(tx_q) < num_desc_needed)
	netif_stop_queue(adpt->netdev);

>> +
>> +/* Change the Maximum Transfer Unit (MTU) */
>> +static int emac_change_mtu(struct net_device *netdev, int new_mtu)
>> +{
>> +	unsigned int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
>> +	struct emac_adapter *adpt = netdev_priv(netdev);
>> +
>> +	if ((max_frame < EMAC_MIN_ETH_FRAME_SIZE) ||
>> +	    (max_frame > EMAC_MAX_ETH_FRAME_SIZE)) {
>> +		netdev_err(adpt->netdev, "error: invalid MTU setting\n");
>> +		return -EINVAL;
>> +	}
>> +
>> +	netif_info(adpt, hw, adpt->netdev,
>> +		   "changing MTU from %d to %d\n", netdev->mtu,
>> +		   new_mtu);
>> +	netdev->mtu = new_mtu;
>> +	adpt->rxbuf_size = new_mtu > EMAC_DEF_RX_BUF_SIZE ?
>> +		ALIGN(max_frame, 8) : EMAC_DEF_RX_BUF_SIZE;
>> +
>> +	if (netif_running(netdev))
>> +		return emac_reinit_locked(adpt);
>
> This does still not look correct. The rxbuf_size is changed while the interface
> is still running. If the rx buffers are refilled now, the rx buffers size does
> not match the size that is configured in the mac, does it?
> You have to stop the rx path first, then change the rx buffer size and then
> restart the rx path.

Ok.  Thanks for catching that.  I didn't notice that adpt->rxbuf_size 
was used in emac_mac_rx_descs_refill().

However, I'm confused about one thing.  Almost every other driver just 
sets "netdev->mtu = new_mtu" and does nothing else.  I can't find any 
other driver that actually stops the RX path, reprograms the hardware, 
and then restarts the RX path.  I know this is a stupid question, but 
why is my driver doing that?

Can I get away with just calling netdev_update_features()?

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
