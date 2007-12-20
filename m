From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] [UDP]: fix send buffer check
Date: Thu, 20 Dec 2007 03:31:38 -0800 (PST)
Message-ID: <20071220.033138.157714241.davem@davemloft.net>
References: <47673195.80004@redhat.com>
	<4767328B.70601@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	tyasui@redhat.com, mhiramat@redhat.com,
	satoshi.oshima.fk@hitachi.com, billfink@mindspring.com,
	andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com
To: haoki@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58995
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754605AbXLTLbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 06:31:39 -0500
In-Reply-To: <4767328B.70601@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hideo AOKI <haoki@redhat.com>
Date: Mon, 17 Dec 2007 21:38:03 -0500

> This patch introduces sndbuf size check before memory allocation for
> send buffer.
> 
> signed-off-by: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
> signed-off-by: Hideo Aoki <haoki@redhat.com>
 ...
> diff -pruN net-2.6/net/ipv4/ip_output.c net-2.6-udp-take11a1-p1/net/ipv4/ip_output.c
> --- net-2.6/net/ipv4/ip_output.c	2007-12-11 10:54:55.000000000 -0500
> +++ net-2.6-udp-take11a1-p1/net/ipv4/ip_output.c	2007-12-17 14:42:31.000000000 -0500
> @@ -1004,6 +1004,11 @@ alloc_new_skb:
>  					frag = &skb_shinfo(skb)->frags[i];
>  				}
>  			} else if (i < MAX_SKB_FRAGS) {
> +				if (atomic_read(&sk->sk_wmem_alloc) + PAGE_SIZE
> +				    > 2 * sk->sk_sndbuf) {
> +					err = -ENOBUFS;
> +					goto error;
> +				}
>  				if (copy > PAGE_SIZE)
>  					copy = PAGE_SIZE;
>  				page = alloc_pages(sk->sk_allocation, 0);

If we are going to do this, we need to add the same check to
skb_append_datato_frags() which is invoked via ip_ufo_append_data().

We also have to be very careful in this area.  One problem we had a
long time ago was that we would socket account when fragmenting an
outgoing frame.  This was bogus because even if the socket had enough
space for one full sized frame, the packet send would fail because it
could not fit the space for both the original frame and the
fragmented copy of it.

This situation was cured by simply not enforcing accounting for the
fragmented copy.  It is valid because after we fragment, we keep
the fragmented copy but free the original.

This doesn't apply directly to this specific patch, but it is
something to keep in mind when doing these changes.
