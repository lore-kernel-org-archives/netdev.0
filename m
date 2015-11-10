From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Tue, 10 Nov 2015 18:07:59 +0000
Message-ID: <yw1xmvulram8.fsf@unicorn.mansr.com>
References: <1447172063-27234-1-git-send-email-mans@mansr.com>
	<1447178287.17135.77.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	slash.tmp@free.fr
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447178287.17135.77.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Tue, 10 Nov 2015 09:58:07 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Tue, 2015-11-10 at 16:14 +0000, Mans Rullgard wrote:
>> This adds a driver for the Aurora VLSI NB8800 Ethernet controller.
>> It is an almost complete rewrite of a driver originally found in
>> a Sigma Designs 2.6.22 tree.
>
> ...
>
>> +
>> +static int nb8800_xmit(struct sk_buff *skb, struct net_device *dev)
>> +{
>> +	struct nb8800_priv *priv =3D netdev_priv(dev);
>> +	struct nb8800_tx_desc *txd;
>> +	struct nb8800_tx_buf *txb;
>> +	struct nb8800_dma_desc *dma;
>> +	dma_addr_t dma_addr;
>> +	unsigned int dma_len;
>> +	unsigned long flags;
>> +	int align;
>> +	int next;
>> +
>> +	if (atomic_read(&priv->tx_free) <=3D NB8800_DESC_LOW) {
>> +		netif_stop_queue(dev);
>> +		return NETDEV_TX_BUSY;
>> +	}
>> +
>> +	align =3D (8 - (uintptr_t)skb->data) & 7;
>> +
>> +	dma_len =3D skb->len - align;
>> +	dma_addr =3D dma_map_single(&dev->dev, skb->data + align,
>> +				  dma_len, DMA_TO_DEVICE);
>> +
>> +	if (dma_mapping_error(&dev->dev, dma_addr)) {
>> +		netdev_err(dev, "tx dma mapping error\n");
>> +		kfree_skb(skb);
>> +		dev->stats.tx_dropped++;
>> +		return NETDEV_TX_OK;
>> +	}
>> +
>> +	if (atomic_dec_return(&priv->tx_free) <=3D NB8800_DESC_LOW)
>> +		netif_stop_queue(dev);
>
> You probably also want to clear skb->xmit_more or risk a stall

Very true, will fix.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
