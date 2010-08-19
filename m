From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: build_ehash_secret() and rt_bind_peer() cleanups
Date: Thu, 19 Aug 2010 23:58:03 +0800
Message-ID: <AANLkTinpqNa3cgEb=86H0sYXdLmo-RP1G2icJgWpfyN1@mail.gmail.com>
References: <1282232815.2549.61.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43977 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277Ab0HSP6Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 11:58:24 -0400
Received: by wwi17 with SMTP id 17so2627721wwi.1
        for <netdev@vger.kernel.org>; Thu, 19 Aug 2010 08:58:23 -0700 (PDT)
In-Reply-To: <1282232815.2549.61.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 19, 2010 at 11:46 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Now cmpxchg() is available on all arches, we can use it in
> build_ehash_secret() and rt_bind_peer() instead of using spinlocks.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
> ---
> =A0net/ipv4/af_inet.c | =A0 =A08 +++-----
> =A0net/ipv4/route.c =A0 | =A0 11 +++--------
> =A02 files changed, 6 insertions(+), 13 deletions(-)
>
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 6a1100c..f581f77 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -227,18 +227,16 @@ EXPORT_SYMBOL(inet_ehash_secret);
>
> =A0/*
> =A0* inet_ehash_secret must be set exactly once
> - * Instead of using a dedicated spinlock, we (ab)use inetsw_lock
> =A0*/
> =A0void build_ehash_secret(void)
> =A0{
> =A0 =A0 =A0 =A0u32 rnd;
> +
> =A0 =A0 =A0 =A0do {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0get_random_bytes(&rnd, sizeof(rnd));
> =A0 =A0 =A0 =A0} while (rnd =3D=3D 0);
> - =A0 =A0 =A0 spin_lock_bh(&inetsw_lock);
> - =A0 =A0 =A0 if (!inet_ehash_secret)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet_ehash_secret =3D rnd;
> - =A0 =A0 =A0 spin_unlock_bh(&inetsw_lock);
> +
> + =A0 =A0 =A0 cmpxchg(&inet_ehash_secret, 0, rnd);
> =A0}
> =A0EXPORT_SYMBOL(build_ehash_secret);
>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 3f56b6e..ae3dba7 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1268,18 +1268,13 @@ skip_hashing:
>
> =A0void rt_bind_peer(struct rtable *rt, int create)
> =A0{
> - =A0 =A0 =A0 static DEFINE_SPINLOCK(rt_peer_lock);
> =A0 =A0 =A0 =A0struct inet_peer *peer;
>
> =A0 =A0 =A0 =A0peer =3D inet_getpeer(rt->rt_dst, create);
>
> - =A0 =A0 =A0 spin_lock_bh(&rt_peer_lock);
> - =A0 =A0 =A0 if (rt->peer =3D=3D NULL) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rt->peer =3D peer;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 peer =3D NULL;
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 spin_unlock_bh(&rt_peer_lock);
> - =A0 =A0 =A0 if (peer)
> + =A0 =A0 =A0 peer =3D cmpxchg(&rt->peer, NULL, peer);
> +
> + =A0 =A0 =A0 if (unlikely(peer))

It isn't correct, and should be
     if (unlikely(cmpxchg(&rt->peer, NULL, peer) !=3D NULL))

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inet_putpeer(peer);
> =A0}


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
