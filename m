From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Mon, 17 Jan 2011 21:39:32 +0100
Message-ID: <1295296772.3362.7.camel@edumazet-laptop>
References: <1294919372-1904-1-git-send-email-ratbert.chuang@gmail.com>
	 <1295256060-2091-1-git-send-email-ratbert.chuang@gmail.com>
	 <1295285354.3335.10.camel@edumazet-laptop>
	 <1295290718.6264.19.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Po-Yu Chuang <ratbert.chuang@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ratbert@faraday-tech.com,
	joe@perches.com, dilinger@queued.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43878 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725Ab1AQUq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 15:46:59 -0500
In-Reply-To: <1295290718.6264.19.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 17 janvier 2011 =C3=A0 18:58 +0000, Ben Hutchings a =C3=A9crit=
 :
> On Mon, 2011-01-17 at 18:29 +0100, Eric Dumazet wrote:
> > Le lundi 17 janvier 2011 =C3=A0 17:21 +0800, Po-Yu Chuang a =C3=A9c=
rit :
> >=20
> >=20
> > > +static int ftmac100_rx_packet(struct ftmac100 *priv, int *proces=
sed)
> > > +{
> > > +	struct net_device *netdev =3D priv->netdev;
> > > +	struct ftmac100_rxdes *rxdes;
> > > +	struct sk_buff *skb;
> > > +	int length;
> > > +	int copied =3D 0;
> > > +	int done =3D 0;
> > > +
> > > +	rxdes =3D ftmac100_rx_locate_first_segment(priv);
> > > +	if (!rxdes)
> > > +		return 0;
> > > +
> > > +	length =3D ftmac100_rxdes_frame_length(rxdes);
> > > +
> > > +	netdev->stats.rx_packets++;
> > > +	netdev->stats.rx_bytes +=3D length;
> > > +
> > > +	if (unlikely(ftmac100_rx_packet_error(priv, rxdes))) {
> > > +		ftmac100_rx_drop_packet(priv);
> > > +		return 1;
> > > +	}
> > > +
> > > +	/* start processing */
> > > +	skb =3D netdev_alloc_skb_ip_align(netdev, length);
> > > +	if (unlikely(!skb)) {
> > > +		if (net_ratelimit())
> > > +			netdev_err(netdev, "rx skb alloc failed\n");
> > > +
> > > +		ftmac100_rx_drop_packet(priv);
> > > +		return 1;
> > > +	}
> > > +
> >=20
> > Please dont increase rx_packets/rx_bytes before the
> > netdev_alloc_skb_ip_align().
> >=20
> > In case of mem allocation failure, it would be better not pretendin=
g we
> > handled a packet.
> >
> > drivers/net/r8169.c for example does the rx_packets/rx_bytes only i=
f
> > packet is delivered to upper stack.
>=20
> That's news to me.  I specifically advised Po-Yu Chuang to increment
> these earlier because my understanding is that all packets/bytes shou=
ld
> be counted.  And drivers which use hardware MAC stats will generally =
do
> that, so I really don't think it makes sense to make other drivers
> different deliberately.
>=20

I see, but when one frame is dropped because of RX ring buffer
under/overflow we dont account for the lost packet/bytes.

Thats probably not very important, but would be good if all drivers
behave the same.



