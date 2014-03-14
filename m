From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: Re: [PATCH net-next V5 6/9] Altera TSE: Add main and header file for
 Altera Ethernet Driver
Date: Fri, 14 Mar 2014 13:52:04 -0500
Message-ID: <CAOwfj2NosO9t-C6ArW6WX02nko-7fWyBS3vqYaDQ1-CpbGdH3A@mail.gmail.com>
References: <1394805887-22030-1-git-send-email-vbridgers2013@gmail.com>
	<1394805887-22030-7-git-send-email-vbridgers2013@gmail.com>
	<20140314143918.GA2253@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Rob Landley <rob@landley.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20140314143918.GA2253@netboy>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Richard,

On Fri, Mar 14, 2014 at 9:39 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Fri, Mar 14, 2014 at 09:04:44AM -0500, Vince Bridgers wrote:
>> +static int tse_start_xmit(struct sk_buff *skb, struct net_device *dev)
>> +{
>> +     struct altera_tse_private *priv = netdev_priv(dev);
>> +     unsigned int txsize = priv->tx_ring_size;
>> +     unsigned int entry;
>> +     struct tse_buffer *buffer = NULL;
>> +     int nfrags = skb_shinfo(skb)->nr_frags;
>> +     unsigned int nopaged_len = skb_headlen(skb);
>> +     enum netdev_tx ret = NETDEV_TX_OK;
>> +     dma_addr_t dma_addr;
>> +     int txcomplete = 0;
>> +
>> +     spin_lock_bh(&priv->tx_lock);
>> +
>> +     if (unlikely(tse_tx_avail(priv) < nfrags + 1)) {
>> +             if (!netif_queue_stopped(dev)) {
>> +                     netif_stop_queue(dev);
>> +                     /* This is a hard error, log it. */
>> +                     netdev_err(priv->dev,
>> +                                "%s: Tx list full when queue awake\n",
>> +                                __func__);
>> +             }
>> +             ret = NETDEV_TX_BUSY;
>> +             goto out;
>> +     }
>> +
>> +     /* Map the first skb fragment */
>> +     entry = priv->tx_prod % txsize;
>> +     buffer = &priv->tx_ring[entry];
>> +
>> +     dma_addr = dma_map_single(priv->device, skb->data, nopaged_len,
>> +                               DMA_TO_DEVICE);
>> +     if (dma_mapping_error(priv->device, dma_addr)) {
>> +             netdev_err(priv->dev, "%s: DMA mapping error\n", __func__);
>> +             ret = NETDEV_TX_OK;
>> +             goto out;
>> +     }
>> +
>> +     buffer->skb = skb;
>> +     buffer->dma_addr = dma_addr;
>> +     buffer->len = nopaged_len;
>> +
>> +     /* Push data out of the cache hierarchy into main memory */
>> +     dma_sync_single_for_device(priv->device, buffer->dma_addr,
>> +                                buffer->len, DMA_TO_DEVICE);
>> +
>> +     txcomplete = priv->dmaops->tx_buffer(priv, buffer);
>> +
>> +     priv->tx_prod++;
>> +     dev->stats.tx_bytes += skb->len;
>
> This could use a call to skb_tx_timestamp() somewhere around here.

Thank you, I'll add the call

>
>> +
>> +     if (unlikely(tse_tx_avail(priv) <= TXQUEUESTOP_THRESHHOLD)) {
>> +             if (netif_msg_hw(priv))
>> +                     netdev_dbg(priv->dev, "%s: stop transmitted packets\n",
>> +                                __func__);
>> +             netif_stop_queue(dev);
>> +     }
>> +
>> +out:
>> +     spin_unlock_bh(&priv->tx_lock);
>> +
>> +     return ret;
>> +}
>
> Thanks,
> Richard

All the best,

Vince
