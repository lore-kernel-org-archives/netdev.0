From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH ref0] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Thu, 24 Feb 2011 18:39:39 +0100
Message-ID: <1298569179.2814.11.camel@edumazet-laptop>
References: <1298535761.2814.1.camel@edumazet-laptop>
	 <1298539762-2242-1-git-send-email-ratbert.chuang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, joe@perches.com, dilinger@queued.net,
	mirqus@gmail.com, davem@davemloft.net,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298539762-2242-1-git-send-email-ratbert.chuang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 24 f=C3=A9vrier 2011 =C3=A0 17:29 +0800, Po-Yu Chuang a =C3=A9=
crit :
> From: Po-Yu Chuang <ratbert@faraday-tech.com>
>=20


> +
> +static bool ftmac100_rx_packet(struct ftmac100 *priv, int *processed=
)
> +{
> +	struct net_device *netdev =3D priv->netdev;
> +	struct ftmac100_rxdes *rxdes;
> +	struct sk_buff *skb;
> +	struct page *page;
> +	dma_addr_t map;
> +	int length;
> +
> +	rxdes =3D ftmac100_rx_locate_first_segment(priv);
> +	if (!rxdes)
> +		return false;
> +
> +	if (unlikely(ftmac100_rx_packet_error(priv, rxdes))) {
> +		ftmac100_rx_drop_packet(priv);
> +		return true;
> +	}
> +
> +	/*
> +	 * It is impossible to get multi-segment packets
> +	 * because we always provide big enough receive buffers.
> +	 */
> +	if (unlikely(!ftmac100_rxdes_last_segment(rxdes)))
> +		BUG();
> +
> +	/* start processing */
> +	skb =3D netdev_alloc_skb_ip_align(netdev, ETH_HLEN);

Oh I see... You should allocate a bigger head (say... 128 bytes)

And copy in it up to 128 bytes of first part... this to avoid upper
stack to reallocate skb head (because IP/TCP processing need to get
their headers in skb head)

> +	if (unlikely(!skb)) {
> +		if (net_ratelimit())
> +			netdev_err(netdev, "rx skb alloc failed\n");
> +
> +		ftmac100_rx_drop_packet(priv);
> +		return true;
> +	}
> +
> +	if (unlikely(ftmac100_rxdes_multicast(rxdes)))
> +		netdev->stats.multicast++;
> +
> +	map =3D ftmac100_rxdes_get_dma_addr(rxdes);
> +	dma_unmap_page(priv->dev, map, RX_BUF_SIZE, DMA_FROM_DEVICE);
> +
> +	length =3D ftmac100_rxdes_frame_length(rxdes);
> +	page =3D ftmac100_rxdes_get_page(rxdes);
> +	skb_fill_page_desc(skb, 0, page, 0, length);
> +	skb->len +=3D length;
> +	skb->data_len +=3D length;
> +	skb->truesize +=3D length;
> +	__pskb_pull_tail(skb, ETH_HLEN);
> +
> +	ftmac100_alloc_rx_page(priv, rxdes);
> +
> +	ftmac100_rx_pointer_advance(priv);
> +
> +	skb->protocol =3D eth_type_trans(skb, netdev);
> +
> +	netdev->stats.rx_packets++;
> +	netdev->stats.rx_bytes +=3D skb->len;
> +
> +	/* push packet to protocol stack */
> +	netif_receive_skb(skb);
> +
> +	(*processed)++;
> +	return true;
> +}
> +
