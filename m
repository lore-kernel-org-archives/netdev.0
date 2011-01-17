From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Mon, 17 Jan 2011 18:29:14 +0100
Message-ID: <1295285354.3335.10.camel@edumazet-laptop>
References: <1294919372-1904-1-git-send-email-ratbert.chuang@gmail.com>
	 <1295256060-2091-1-git-send-email-ratbert.chuang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ratbert@faraday-tech.com, bhutchings@solarflare.com,
	joe@perches.com, dilinger@queued.net
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:63300 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751938Ab1AQRd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 12:33:27 -0500
In-Reply-To: <1295256060-2091-1-git-send-email-ratbert.chuang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 17 janvier 2011 =C3=A0 17:21 +0800, Po-Yu Chuang a =C3=A9crit =
:


> +static int ftmac100_rx_packet(struct ftmac100 *priv, int *processed)
> +{
> +	struct net_device *netdev =3D priv->netdev;
> +	struct ftmac100_rxdes *rxdes;
> +	struct sk_buff *skb;
> +	int length;
> +	int copied =3D 0;
> +	int done =3D 0;
> +
> +	rxdes =3D ftmac100_rx_locate_first_segment(priv);
> +	if (!rxdes)
> +		return 0;
> +
> +	length =3D ftmac100_rxdes_frame_length(rxdes);
> +
> +	netdev->stats.rx_packets++;
> +	netdev->stats.rx_bytes +=3D length;
> +
> +	if (unlikely(ftmac100_rx_packet_error(priv, rxdes))) {
> +		ftmac100_rx_drop_packet(priv);
> +		return 1;
> +	}
> +
> +	/* start processing */
> +	skb =3D netdev_alloc_skb_ip_align(netdev, length);
> +	if (unlikely(!skb)) {
> +		if (net_ratelimit())
> +			netdev_err(netdev, "rx skb alloc failed\n");
> +
> +		ftmac100_rx_drop_packet(priv);
> +		return 1;
> +	}
> +

Please dont increase rx_packets/rx_bytes before the
netdev_alloc_skb_ip_align().

In case of mem allocation failure, it would be better not pretending we
handled a packet.

drivers/net/r8169.c for example does the rx_packets/rx_bytes only if
packet is delivered to upper stack.



