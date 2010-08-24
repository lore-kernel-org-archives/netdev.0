From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] net: save RX queue number in sock for
 dev_pick_tx() use
Date: Tue, 24 Aug 2010 15:06:13 +0200
Message-ID: <1282655173.2477.230.camel@edumazet-laptop>
References: <1282640519-15541-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>, Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50528 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585Ab0HXNGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 09:06:20 -0400
Received: by wwe15 with SMTP id 15so1861335wwe.1
        for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 06:06:18 -0700 (PDT)
In-Reply-To: <1282640519-15541-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 24 ao=C3=BBt 2010 =C3=A0 17:01 +0800, Changli Gao a =C3=A9crit=
 :
> For the packets sent out from a local server socket, we can use the q=
ueue
> from which the packets from the client socket are received.
>=20
> It may help on a TCP or UDP server. Because I don't have a multiqueue=
 NIC,
> I don't even test it.
>=20

It may help ? or it may not...

> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  include/net/sock.h  |   18 ++++++++++++++++++
>  net/core/dev.c      |   25 ++++++++++++++++++-------
>  net/ipv4/tcp_ipv4.c |    5 ++++-
>  net/ipv4/udp.c      |    4 +++-
>  4 files changed, 43 insertions(+), 9 deletions(-)
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 100e43b..4e5f2f4 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1231,6 +1231,24 @@ static inline int sk_tx_queue_get(const struct=
 sock *sk)
>  	return sk ? sk->sk_tx_queue_mapping : -1;
>  }
> =20
> +static inline void sk_rx_queue_save(struct sock *sk, struct sk_buff =
*skb)
> +{
> +	struct dst_entry *dst;
> +	int rxqueue;
> +
> +	if (!skb_rx_queue_recorded(skb))
> +		return;
> +	rcu_read_lock();
> +	dst =3D rcu_dereference_check(sk->sk_dst_cache, 1);

rcu_dereference(sk->sk_dst_cache) is fine here.

> +	if (dst && !dst->dev->netdev_ops->ndo_select_queue &&
> +	    dst->dev =3D=3D skb->dev) {
> +		rxqueue =3D skb_get_rx_queue(skb);
> +		if (rxqueue !=3D sk_tx_queue_get(sk))
> +			sk_tx_queue_set(sk, rxqueue);
> +	}
> +	rcu_read_unlock();
> +}
> +

ipv6 not handled

Anyway, should we store a queue number, a rxhash, a cpu number, all
values ?

Tom Herbert last patch (XPS) is about selecting a txqueue given a cpu
number at sending time. In its use, no need to add logic at receive tim=
e
to remember rxqueue. But logic is wide (for a given NIC)

I do think we should really clarify the needs before writing hundred of
lines of code that we have to maintain for next decade...

=46or example, storing the cpu number of the cpu that received a UDP/TC=
P
frame would probably be nice, and using it as a key for xmit path queue
selection would probably be faster...

Probably we want a selectable way... A multi threaded UDP application,
receiving frames on a single socket, might need to select a single
txqueue (socket property), or multiple queues (based on packet content,
or sender cpu, or last receive cpu number, ...)



