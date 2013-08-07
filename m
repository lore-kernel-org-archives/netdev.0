From: Teco Boot <teco@inf-net.nl>
Subject: Re: [PATCH net] ipv6: don't stop backtracking in fib6_lookup_1 if subtree does not match
Date: Wed, 7 Aug 2013 21:58:31 +0200
Message-ID: <EF96A1CB-549E-474A-AF58-10F2D2F2BF4A@inf-net.nl>
References: <20130807003431.GD16410@order.stressinduktion.org>
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	equinox@diac24.net, boutier@pps.univ-paris-diderot.fr
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:54547 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752759Ab3HGT6h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 15:58:37 -0400
Received: by mail-ea0-f181.google.com with SMTP id d10so1050169eaj.40
        for <netdev@vger.kernel.org>; Wed, 07 Aug 2013 12:58:35 -0700 (PDT)
In-Reply-To: <20130807003431.GD16410@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Seems to work!!

babe has one entry less than cafe, this is correct.
Tomorrow I'll test with real traffic.

Teco


root@ubuntu:~# ./ipv6-sadr.sh 
this is my system:
Linux ubuntu 3.8.0-28-generic #41 SMP Wed Aug 7 11:36:10 PDT 2013 i686 i686 i686 GNU/Linux
CONFIG_IPV6_SUBTREES=y
... clean up for our experiment
... add a link-local
... add default
... add some source address specific defaults
====> now I have this routing table
default from 2001:db8:10::/48 via fe80::10 dev eth0  metric 1024 
default from 2001:db8:11::/48 via fe80::11 dev eth0  metric 1024 
default from 2001:db8:12::/48 via fe80::12 dev eth0  metric 1024 
fe80::1 dev eth0  proto kernel  metric 256 
default via fe80::ff dev eth0  metric 1024 
====> show route to same destination
2001:db8:babe::1 from 2001:db8:10::1 via fe80::10 dev eth0  src ::1  metric 0 \    cache 
2001:db8:babe::1 from 2001:db8:11::1 via fe80::11 dev eth0  src ::1  metric 0 \    cache 
2001:db8:babe::1 from 2001:db8:12::1 via fe80::12 dev eth0  src ::1  metric 0 \    cache 
2001:db8:babe::1 from 2001:db8:1::1 via fe80::ff dev eth0  src ::1  metric 0 \    cache 
2001:db8:babe::1 from :: via fe80::ff dev eth0  src ::1  metric 0 \    cache 
====> show route to different destinations
2001:db8:cafe::10 from 2001:db8:10::1 via fe80::10 dev eth0  src ::1  metric 0 \    cache 
2001:db8:cafe::11 from 2001:db8:11::1 via fe80::11 dev eth0  src ::1  metric 0 \    cache 
2001:db8:cafe::12 from 2001:db8:12::1 via fe80::12 dev eth0  src ::1  metric 0 \    cache 
2001:db8:cafe::21 from 2001:db8:1::1 via fe80::ff dev eth0  src ::1  metric 0 \    cache 
2001:db8:cafe::22 from :: via fe80::ff dev eth0  src ::1  metric 0 \    cache 
====> now the route cache is
2001:db8:babe::1 from 2001:db8:10::/48 via fe80::10 dev eth0  metric 0 \    cache 
2001:db8:babe::1 from 2001:db8:11::/48 via fe80::11 dev eth0  metric 0 \    cache 
2001:db8:babe::1 from 2001:db8:12::/48 via fe80::12 dev eth0  metric 0 \    cache 
2001:db8:babe::1 via fe80::ff dev eth0  metric 0 \    cache 
2001:db8:cafe::10 from 2001:db8:10::/48 via fe80::10 dev eth0  metric 0 \    cache 
2001:db8:cafe::11 from 2001:db8:11::/48 via fe80::11 dev eth0  metric 0 \    cache 
2001:db8:cafe::12 from 2001:db8:12::/48 via fe80::12 dev eth0  metric 0 \    cache 
2001:db8:cafe::21 via fe80::ff dev eth0  metric 0 \    cache 
2001:db8:cafe::22 via fe80::ff dev eth0  metric 0 \    cache 
root@ubuntu:~# 




Op 7 aug. 2013, om 02:34 heeft Hannes Frederic Sowa <hannes@stressinduktion.org> het volgende geschreven:

> In case a subtree did not match we currently stop backtracking and return
> NULL (root table from fib_lookup). This could yield in invalid routing
> table lookups when using subtrees.
> 
> Instead continue to backtrack until a valid subtree or node is found
> and return this match.
> 
> Also remove unneeded NULL check.
> 
> Reported-by: Teco Boot <teco@inf-net.nl>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Cc: David Lamparter <equinox@diac24.net>
> Cc: <boutier@pps.univ-paris-diderot.fr>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> net/ipv6/ip6_fib.c | 16 ++++++++++++----
> 1 file changed, 12 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
> index ed828d6..73db48e 100644
> --- a/net/ipv6/ip6_fib.c
> +++ b/net/ipv6/ip6_fib.c
> @@ -993,14 +993,22 @@ static struct fib6_node * fib6_lookup_1(struct fib6_node *root,
> 
> 			if (ipv6_prefix_equal(&key->addr, args->addr, key->plen)) {
> #ifdef CONFIG_IPV6_SUBTREES
> -				if (fn->subtree)
> -					fn = fib6_lookup_1(fn->subtree, args + 1);
> +				if (fn->subtree) {
> +					struct fib6_node *sfn;
> +					sfn = fib6_lookup_1(fn->subtree,
> +							    args + 1);
> +					if (!sfn)
> +						goto backtrack;
> +					fn = sfn;
> +				}
> #endif
> -				if (!fn || fn->fn_flags & RTN_RTINFO)
> +				if (fn->fn_flags & RTN_RTINFO)
> 					return fn;
> 			}
> 		}
> -
> +#ifdef CONFIG_IPV6_SUBTREES
> +backtrack:
> +#endif
> 		if (fn->fn_flags & RTN_ROOT)
> 			break;
> 
> -- 
> 1.8.3.1
> 
