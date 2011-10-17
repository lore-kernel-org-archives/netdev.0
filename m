From: Elmar Vonlanthen <evonlanthen@gmail.com>
Subject: Re: PROBLEM: System call 'sendmsg' of process ospfd (quagga) causes
 kernel oops
Date: Mon, 17 Oct 2011 09:16:23 +0200
Message-ID: <CA+0Zf5A-8X5MaXC4+BbLKtMb8S8B-Ln_a3JNfz0jR4O-ruefuw@mail.gmail.com>
References: <CA+0Zf5Be5JUSvssH9CrDQq=jtETZr=veAPC7jriM8B-FZKbbpg@mail.gmail.com>
	<1318604266.2223.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:40997 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106Ab1JQHQZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 03:16:25 -0400
In-Reply-To: <1318604266.2223.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/10/14 Eric Dumazet <eric.dumazet@gmail.com>:
> Please try following patch :
>
> [PATCH] ip_gre: dont increase dev->needed_headroom on a live device
>
> It seems ip_gre is able to change dev->needed_headroom on the fly.
>
> Its is not legal unfortunately and triggers a BUG in raw_sendmsg()
>
> skb =3D sock_alloc_send_skb(sk, ... + LL_ALLOCATED_SPACE(rt->dst.dev)
>
> < another cpu change dev->needed_headromm (making it bigger)
>
> ...
> skb_reserve(skb, LL_RESERVED_SPACE(rt->dst.dev));
>
> We end with LL_RESERVED_SPACE() being bigger than LL_ALLOCATED_SPACE(=
)
> -> we crash later because skb head is exhausted.
>
> Bug introduced in commit 243aad83 in 2.6.34 (ip_gre: include route
> header_len in max_headroom calculation)
>
> Reported-by: Elmar Vonlanthen <evonlanthen@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Timo Ter=E4s <timo.teras@iki.fi>
> CC: Herbert Xu <herbert@gondor.apana.org.au>
> ---
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 8871067..1505dcf 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -835,8 +835,6 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_bu=
ff *skb, struct net_device *dev
> =A0 =A0 =A0 =A0if (skb_headroom(skb) < max_headroom || skb_shared(skb=
)||
> =A0 =A0 =A0 =A0 =A0 =A0(skb_cloned(skb) && !skb_clone_writable(skb, 0=
))) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct sk_buff *new_skb =3D skb_reallo=
c_headroom(skb, max_headroom);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (max_headroom > dev->needed_headroom=
)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->needed_headroom =3D=
 max_headroom;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!new_skb) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ip_rt_put(rt);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->stats.tx_dropped+=
+;

Hello

I tried this patch and I was not able anymore to reproduce the kernel
oops. So the patch solved the bug.
Thank you very much!

Would it be possible to add the patch to the long term kernel 2.6.35
as well? Because this is the one I use at the moment in production.

And sorry for posting to the wrong mailing list (linux-kernel).

Best regards
Elmar
