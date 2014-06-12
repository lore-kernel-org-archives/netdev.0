From: dormando <dormando@rydia.net>
Subject: Re: [PATCH] ipv4: fix a race in ip4_datagram_release_cb()
Date: Wed, 11 Jun 2014 18:55:20 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406111851140.18470@dtop>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>  <1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>  <alpine.DEB.2.02.1406101726390.11647@dtop>  <1402448128.3645.437.camel@edumazet-glaptop2.roam.corp.google.com>
  <1402449173.3645.440.camel@edumazet-glaptop2.roam.corp.google.com>  <1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>  <alpine.DEB.2.10.1406102114520.28698@dinf>  <1402466090.3645.456.camel@edumazet-glaptop2.roam.corp.google.com>
 <alpine.DEB.2.02.1406110011170.11647@dtop>  <alpine.DEB.2.02.1406110022550.11647@dtop>  <alpine.DEB.2.02.1406110036490.11647@dtop>  <1402490462.3645.463.camel@edumazet-glaptop2.roam.corp.google.com>
 <1402492373.3645.466.camel@edumazet-glaptop2.roam.corp.google.com>
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
Received: from rydia.net ([69.46.88.68]:55167 "EHLO mail.rydia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754411AbaFLBzV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 21:55:21 -0400
In-Reply-To: <1402492373.3645.466.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Jun 2014, Eric Dumazet wrote:

> On Wed, 2014-06-11 at 05:41 -0700, Eric Dumazet wrote:
>
> >
> > OK then we probably have another bug in UDP, which is that we call
> > sk_dst_set(sk, dst_clone(&rt->dst)); with a dst having DST_NOCACHE set
> >
> > Its a problem, because sk_dst_get() cannot deal safely with such dst.
>
> You could try this in top of other patches.
>
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 21569cf456ed..427ac7cc50fc 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1728,8 +1728,8 @@ sk_dst_get(struct sock *sk)
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
>
>
>

I sent the udpkill utility in an off-list mail (in case that got binned by
anyone).

Just threw this patch on top of the other two, on 3.10.42. udpkill's been
running for an hour without fault. I've just put traffic back onto the
machine am leaving udpkill enabled for a while longer.

So, this is an improvement :)

I have exactly one machine which (for whatever lucky reason) is really
prone to hitting this problem without needing udpkill. It'll take a few
days to get it going there though. I've not been able to reproduce the
crash from other angles yet.
