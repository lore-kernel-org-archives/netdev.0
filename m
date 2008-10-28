From: David Miller <davem@davemloft.net>
Subject: Re: FYI - TCP/IP thin stream latency
Date: Tue, 28 Oct 2008 15:48:14 -0700 (PDT)
Message-ID: <20081028.154814.179119403.davem@davemloft.net>
References: <20081016095518.749ae6e9@speedy>
	<20081022.221410.139436406.davem@davemloft.net>
	<Pine.LNX.4.64.0810231516220.7072@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, doug.leith@nuim.ie, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52997
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751978AbYJ1Wsh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2008 18:48:37 -0400
In-Reply-To: <Pine.LNX.4.64.0810231516220.7072@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 23 Oct 2008 15:22:17 +0300 (EEST)

> [PATCH not-now :-)] tcp: collapse more than two on retransmission
>=20
> I always had thought that collapsing up to two at a time was
> intentional decision to avoid excessive processing if 1 byte
> sized skbs are to be combined for a full mtu, and consecutive
> retransmissions would make the size of the retransmittee
> double each round anyway.
>=20
> tcp_skb_is_last check is now provided by the loop.
>=20
> I tried to make the order of tests bit more sensible to make
> it break earlier for things which seem more common case
> (in favor of TSO and SG, though latter is a restriction which
> could be made less strict I think).
>=20
> Barely compile tested.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Small error:

> +static int tcp_can_collapse(struct sock *sk, struct sk_buff *skb)
> +{
> +	if (tcp_skb_pcount(skb) > 1)
> +		return 0;
> +	/* Once recombining for SACK completes this check could be made
> +	 * less strict by reusing those parts.
> +	 */
> +	if (skb_shinfo(skb)->nr_frags !=3D 0)
> +		return 0;
> +	if (skb_cloned(skb))
> +		return 0;
> +	if (skb =3D=3D tcp_send_head(sk))
> +		return 0;
> +	/* Some heurestics for collapsing over SACK'd could be invented */
> +	if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)
> +		return 0;
> +
> +	return 1;
> +}

=46or the "skb =3D=3D=3D tcp_send_head()" test, we're not interested if
"skb" is equal, but rather whether next_skb is equal.

But the structure looks fine and when you send me a tested version
of this patch I'll apply it to net-next-2.6, thanks!
