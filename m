From: dormando <dormando@rydia.net>
Subject: Re: [PATCH] ipv4: fix a race in ip4_datagram_release_cb()
Date: Mon, 23 Jun 2014 01:55:06 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406230151480.19472@dtop>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>    <1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>    <alpine.DEB.2.02.1406101726390.11647@dtop>    <1402448128.3645.437.camel@edumazet-glaptop2.roam.corp.google.com>
  <1402449173.3645.440.camel@edumazet-glaptop2.roam.corp.google.com>    <1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>    <alpine.DEB.2.10.1406102114520.28698@dinf>    <1402466090.3645.456.camel@edumazet-glaptop2.roam.corp.google.com>  
  <alpine.DEB.2.02.1406110011170.11647@dtop>    <alpine.DEB.2.02.1406110022550.11647@dtop>    <alpine.DEB.2.02.1406110036490.11647@dtop>    <1402490462.3645.463.camel@edumazet-glaptop2.roam.corp.google.com>   <1402492373.3645.466.camel@edumazet-glaptop2.roam.corp.google.com>
  <alpine.DEB.2.02.1406111851140.18470@dtop>  <1402544609.3645.473.camel@edumazet-glaptop2.roam.corp.google.com>  <alpine.DEB.2.02.1406221202460.14871@dtop> <1403512412.16682.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexey Preobrazhensky <preobr@google.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Lars Bull <larsbull@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Curtis <brutus@google.com>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rydia.net ([69.46.88.68]:53977 "EHLO mail.rydia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752191AbaFWIzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2014 04:55:08 -0400
In-Reply-To: <1403512412.16682.23.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Jun 2014, Eric Dumazet wrote:

> On Sun, 2014-06-22 at 12:07 -0700, dormando wrote:
>
> > Update on testing:
> >
> > I only have two machines that crash on their own frequently (more like
> > one, even). Unfortunately something happened to the datacenter it's in and
> > it was offline for a week. The machine normally crashes after 1.5-4d,
> > averaging 2d.
> >
> > It's done about three days total time without a new crash. I also have the
> > kernel running in another datacenter for ~10 days.. but it takes 30-150
> > days to crash in that one.
> >
> > So, inconclusive, but still promising. If the machine survives the week it
> > probably means it's fixed, or at least greatly reduced.
> >
> > I saw that one of your patches got queued for stable, but all three were
> > necessary to fix udpkill. What's your plan for cleanup/upstreaming?
> >
> > Did you folks end up running udpkill under the tester thing?
>
> I did not test udpkill, as the known problem is the DST_NOCACHE flag.
>
> We end up calling sk_dst_set(sk, dst) with a dst having this flag set.
>
> So maybe DST_NOCACHE should be renamed, if we _can _ cache a dst like
> this. Its meaning is really that dst_release() has to track when
> refcount reaches 0 so that last owner fress dst, but we need to respect
> rcu grace period.
>
> Fixing sk_dst_set() as I did is not enough, as it is only reducing race
> window.

Hrm. I'll have to spend more time trying to understand how to test this
(beyond just putting a kernel into production and seeing if it crashes).
Outside of udpkill it's been slightly hard to reproduce, and udpkill ran
for over five hours with your previous patches.

Do you or other folks have any methods for testing this?

thanks!

> Something like following :
>
>  include/net/sock.h   |    4 ++--
>  net/core/dst.c       |   16 +++++++++++-----
>  net/ipv4/ip_tunnel.c |    7 +------
>  3 files changed, 14 insertions(+), 13 deletions(-)
>
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 07b7fcd60d80..173cae485de1 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1730,8 +1730,8 @@ sk_dst_get(struct sock *sk)
>
>  	rcu_read_lock();
>  	dst = rcu_dereference(sk->sk_dst_cache);
> -	if (dst)
> -		dst_hold(dst);
> +	if (dst && !atomic_inc_not_zero(&dst->__refcnt))
> +		dst = NULL;
>  	rcu_read_unlock();
>  	return dst;
>  }
> diff --git a/net/core/dst.c b/net/core/dst.c
> index 80d6286c8b62..a028409ee438 100644
> --- a/net/core/dst.c
> +++ b/net/core/dst.c
> @@ -269,6 +269,15 @@ again:
>  }
>  EXPORT_SYMBOL(dst_destroy);
>
> +static void dst_destroy_rcu(struct rcu_head *head)
> +{
> +	struct dst_entry *dst = container_of(head, struct dst_entry, rcu_head);
> +
> +	dst = dst_destroy(dst);
> +	if (dst)
> +		__dst_free(dst);
> +}
> +
>  void dst_release(struct dst_entry *dst)
>  {
>  	if (dst) {
> @@ -276,11 +285,8 @@ void dst_release(struct dst_entry *dst)
>
>  		newrefcnt = atomic_dec_return(&dst->__refcnt);
>  		WARN_ON(newrefcnt < 0);
> -		if (unlikely(dst->flags & DST_NOCACHE) && !newrefcnt) {
> -			dst = dst_destroy(dst);
> -			if (dst)
> -				__dst_free(dst);
> -		}
> +		if (unlikely(dst->flags & DST_NOCACHE) && !newrefcnt)
> +			call_rcu(&dst->rcu_head, dst_destroy_rcu);
>  	}
>  }
>  EXPORT_SYMBOL(dst_release);
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index 097b3e7c1e8f..cc3b7fd34555 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -73,12 +73,7 @@ static void __tunnel_dst_set(struct ip_tunnel_dst *idst,
>  {
>  	struct dst_entry *old_dst;
>
> -	if (dst) {
> -		if (dst->flags & DST_NOCACHE)
> -			dst = NULL;
> -		else
> -			dst_clone(dst);
> -	}
> +	dst_clone(dst);
>  	old_dst = xchg((__force struct dst_entry **)&idst->dst, dst);
>  	dst_release(old_dst);
>  }
>
>
>
