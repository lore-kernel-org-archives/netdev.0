From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: refresh rt6i_genid in ip6_pol_route()
Date: Sun, 07 Sep 2014 15:54:46 -0700 (PDT)
Message-ID: <20140907.155446.2293591154334558042.davem@davemloft.net>
References: <1410021507.11872.35.camel@edumazet-glaptop2.roam.corp.google.com>
	<1410027712.11872.40.camel@edumazet-glaptop2.roam.corp.google.com>
	<1410116703.11872.55.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, therbert@google.com,
	alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56341 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947AbaIGWyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2014 18:54:49 -0400
In-Reply-To: <1410116703.11872.55.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 07 Sep 2014 12:05:03 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> While tracking IPv6 poor performance, I found that IPv6 early demux
> was broken in recent kernels. perf profiles show inet6_sk_rx_dst_set()
> being called for every incoming TCP segment :
> 
>   20.95%      netserver  [kernel.kallsyms]    [k] dst_release     
>   19.33%      netserver  [kernel.kallsyms]    [k] ip6_pol_route
>   11.75%      netserver  [kernel.kallsyms]    [k] inet6_sk_rx_dst_set
>    3.72%      netserver  [kernel.kallsyms]    [k] ip6_input_finish
> 
> Regression came in linux-3.6 with commit 6f3118b571b8 ("ipv6: use
> net->rt_genid to check dst validity")
> 
> When a route found in ip6_pol_route() is cloned (either using
> rt6_alloc_cow() or rt6_alloc_clone()), copy gets an updated rt6i_genid.
> 
> But when original route is selected, we need to refresh its rt6i_genid
> that could be obsolete. If we do not refresh rt6i_genid, ip6_dst_check()
> will fail.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 6f3118b571b8 ("ipv6: use net->rt_genid to check dst validity")

This might be broken.

We are dealing here with persistent entries in the ipv6 routine trie.

If you just bump the genid on the next person to look it up, other
sockets and cached entities might not have validated the route yet,
and now will falsely see the route as valid.  We have to ensure that
they too drop this route and perform a relookup.
