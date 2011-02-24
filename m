From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH ref0] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Thu, 24 Feb 2011 18:48:05 +0100
Message-ID: <1298569685.2814.16.camel@edumazet-laptop>
References: <1298535761.2814.1.camel@edumazet-laptop>
	 <1298539762-2242-1-git-send-email-ratbert.chuang@gmail.com>
	 <1298569179.2814.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, joe@perches.com, dilinger@queued.net,
	mirqus@gmail.com, davem@davemloft.net,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298569179.2814.11.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 24 f=C3=A9vrier 2011 =C3=A0 18:39 +0100, Eric Dumazet a =C3=A9=
crit :
> Le jeudi 24 f=C3=A9vrier 2011 =C3=A0 17:29 +0800, Po-Yu Chuang a =C3=A9=
crit :
> > From: Po-Yu Chuang <ratbert@faraday-tech.com>
> >=20
>=20
>=20
> > +
> > +static bool ftmac100_rx_packet(struct ftmac100 *priv, int *process=
ed)
> > +{
> > +	struct net_device *netdev =3D priv->netdev;
> > +	struct ftmac100_rxdes *rxdes;
> > +	struct sk_buff *skb;
> > +	struct page *page;
> > +	dma_addr_t map;
> > +	int length;
> > +
> > +	rxdes =3D ftmac100_rx_locate_first_segment(priv);
> > +	if (!rxdes)
> > +		return false;
> > +
> > +	if (unlikely(ftmac100_rx_packet_error(priv, rxdes))) {
> > +		ftmac100_rx_drop_packet(priv);
> > +		return true;
> > +	}
> > +
> > +	/*
> > +	 * It is impossible to get multi-segment packets
> > +	 * because we always provide big enough receive buffers.
> > +	 */
> > +	if (unlikely(!ftmac100_rxdes_last_segment(rxdes)))
> > +		BUG();
> > +
> > +	/* start processing */
> > +	skb =3D netdev_alloc_skb_ip_align(netdev, ETH_HLEN);
>=20
> Oh I see... You should allocate a bigger head (say... 128 bytes)
>=20
> And copy in it up to 128 bytes of first part... this to avoid upper
> stack to reallocate skb head (because IP/TCP processing need to get
> their headers in skb head)

Take a look at drivers/net/niu.c :

#define RX_SKB_ALLOC_SIZE   128 + NET_IP_ALIGN

static int niu_process_rx_pkt(...)
{
	...
	skb =3D netdev_alloc_skb(np->dev, RX_SKB_ALLOC_SIZE);
	...
	while (1) {
	 	...
		niu_rx_skb_append(skb, page, off, append_size);
	}
}
