From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Tue, 10 Nov 2015 18:05:15 +0000
Message-ID: <yw1xr3jxraqs.fsf@unicorn.mansr.com>
References: <1447172063-27234-1-git-send-email-mans@mansr.com>
	<1447178145.17135.75.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	slash.tmp@free.fr
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447178145.17135.75.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Tue, 10 Nov 2015 09:55:45 -0800")
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
>> +static void nb8800_receive(struct net_device *dev, int i, int len)
>> +{
>> +	struct nb8800_priv *priv =3D netdev_priv(dev);
>> +	struct nb8800_rx_desc *rxd =3D &priv->rx_descs[i];
>> +	struct page *page =3D priv->rx_bufs[i].page;
>> +	int offset =3D priv->rx_bufs[i].offset;
>> +	void *data =3D page_address(page) + offset;
>> +	dma_addr_t dma =3D rxd->desc.s_addr;
>> +	struct sk_buff *skb;
>> +	int size;
>> +	int err;
>> +
>> +	size =3D len <=3D RX_COPYBREAK ? len : RX_COPYHDR;
>> +
>> +	skb =3D napi_alloc_skb(&priv->napi, size);
>> +	if (!skb) {
>> +		netdev_err(dev, "rx skb allocation failed\n");
>> +		dev->stats.rx_dropped++;
>> +		return;
>> +	}
>> +
>> +	if (len <=3D RX_COPYBREAK) {
>> +		dma_sync_single_for_cpu(&dev->dev, dma, len, DMA_FROM_DEVICE);
>> +		memcpy(skb_put(skb, len), data, len);
>> +		dma_sync_single_for_device(&dev->dev, dma, len,
>> +					   DMA_FROM_DEVICE);
>> +	} else {
>> +		err =3D nb8800_alloc_rx(dev, i, true);
>> +		if (err) {
>> +			netdev_err(dev, "rx buffer allocation failed\n");
>> +			dev->stats.rx_dropped++;
>> +			return;
>> +		}
>> +
>> +		dma_unmap_page(&dev->dev, dma, RX_BUF_SIZE, DMA_FROM_DEVICE);
>> +		memcpy(skb_put(skb, RX_COPYHDR), data, RX_COPYHDR);
>> +		skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
>> +				offset + RX_COPYHDR, len - RX_COPYHDR,
>> +				RX_BUF_SIZE);
>> +	}
>> +
>> +	skb->protocol =3D eth_type_trans(skb, dev);
>> +	netif_receive_skb(skb);
>> +}
>> +
>
> Any reason you do not use napi_gro_receive(&priv->napi, skb) instead =
of
> netif_receive_skb() ?

Because I haven't been following the netdev list closely for the last
five years, and no documentation I read mentioned this function.  I can
certainly change it.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
