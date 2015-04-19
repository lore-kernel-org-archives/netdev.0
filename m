From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH v3] Renesas Ethernet AVB driver
Date: Mon, 20 Apr 2015 01:45:23 +0200
Message-ID: <55343E13.9090301@gmx.de>
References: <32501816.HtkLenWQpn@wasted.cogentembedded.com> <552C63FD.9010005@gmx.de> <553427C9.7030605@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	richardcochran@gmail.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <553427C9.7030605@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 20.04.2015 00:10, Sergei Shtylyov wrote:
> 
>> I recall a thread in which the use of bitfields for structs that are
>> shared with the hardware was considered a bad idea (because the compiler
>> is free to reorder the fields). Shift operations are probably a better
>> choice here.
> 
>     Well, it looks as the compiler is not free to reorder bit fields, and the 
> order is determined by the ABI. Will look into getting rid of them anyway...

I think that thread I was referring to was this one:
http://thread.gmane.org/gmane.linux.kernel/182862/focus=182986
(See the first comment from Benjamin Herrenschmidt).

>>> +/* Packet transmit function for Ethernet AVB */
>>> +static int ravb_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>>> +{
>>> +	struct ravb_private *priv = netdev_priv(ndev);
>>> +	struct ravb_tstamp_skb *ts_skb = NULL;
>>> +	struct ravb_tx_desc *desc;
>>> +	unsigned long flags;
>>> +	void *buffer;
>>> +	u32 entry;
>>> +	u32 tccr;
>>> +	int q;
>>> +
>>> +	/* If skb needs TX timestamp, it is handled in network control queue */
>>> +	q = (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) ? RAVB_NC : RAVB_BE;
>>> +
>>> +	spin_lock_irqsave(&priv->lock, flags);
>>> +	if (priv->cur_tx[q] - priv->dirty_tx[q] >= priv->num_tx_ring[q] - 4) {
>>> +		if (!ravb_tx_free(ndev, q)) {
>>> +			netif_warn(priv, tx_queued, ndev, "TX FD exhausted.\n");
>>> +			netif_stop_queue(ndev);
>>> +			spin_unlock_irqrestore(&priv->lock, flags);
>>> +			return NETDEV_TX_BUSY;
>>> +		}
>>> +	}
>>> +	entry = priv->cur_tx[q] % priv->num_tx_ring[q];
>>> +	priv->cur_tx[q]++;
>>> +	spin_unlock_irqrestore(&priv->lock, flags);
>>> +
>>> +	if (skb_put_padto(skb, ETH_ZLEN))
>>> +		return NETDEV_TX_OK;
>>> +
>>> +	priv->tx_skb[q][entry] = skb;
>>> +	buffer = PTR_ALIGN(priv->tx_buffers[q][entry], RAVB_ALIGN);
>>> +	memcpy(buffer, skb->data, skb->len);
>>> +	desc = &priv->tx_ring[q][entry];
>>> +	desc->ds = skb->len;
>>> +	desc->dptr = dma_map_single(&ndev->dev, buffer, skb->len,
>>> +				    DMA_TO_DEVICE);
>>> +	if (dma_mapping_error(&ndev->dev, desc->dptr)) {
>>> +		dev_kfree_skb_any(skb);
>>> +		priv->tx_skb[q][entry] = NULL;
>>> +		return NETDEV_TX_OK;
>>> +	}
>>> +
>>> +	/* TX timestamp required */
>>> +	if (q == RAVB_NC) {
>>> +		ts_skb = kmalloc(sizeof(*ts_skb), GFP_ATOMIC);
>>> +		if (!ts_skb)
>>> +			return -ENOMEM;
> 
>> Dma mapping has to be undone.
> 
>     OK, fixed. Not sure what we should return in this case: error code or
> NETDEV_TX_OK...

NETDEV_TX_OK is the correct return value even in error case. The only
exception is NETDEV_TX_BUSY when the tx queue has been stopped. However
returning NETDEV_TX_OK also means that the skb has to be consumed (so
beside unmapping dma also the skb has to be freed in case that kmalloc
fails in ravb_start_xmit).

>> example all ptp related code could be put into its own file.
> 
>     OK, will try to split the driver back... Perhaps I should also split the 
> patch accordingly?

Yes, sounds like a good idea.

Regards,
Lino

