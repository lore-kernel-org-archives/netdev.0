From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] ipv6: kill sk_dst_lock
Date: Thu, 03 Dec 2015 11:32:43 -0500 (EST)
Message-ID: <20151203.113243.972969856777923620.davem@davemloft.net>
References: <1448901315.24696.127.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151202.234216.1113392733011218992.davem@davemloft.net>
	<1449122037.6379.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, vyasevich@gmail.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41118 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932126AbbLCQcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 11:32:45 -0500
In-Reply-To: <1449122037.6379.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Dec 2015 21:53:57 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> While testing the np->opt RCU conversion, I found that UDP/IPv6 was
> using a mixture of xchg() and sk_dst_lock to protect concurrent changes
> to sk->sk_dst_cache, leading to possible corruptions and crashes.
> 
> ip6_sk_dst_lookup_flow() uses sk_dst_check() anyway, so the simplest
> way to fix the mess is to remove sk_dst_lock completely, as we did for
> IPv4.
> 
> __ip6_dst_store() and ip6_dst_store() share same implementation.
> 
> sk_setup_caps() being called with socket lock being held or not,
> we have to use sk_dst_set() instead of __sk_dst_set()
> 
> Note that I had to move the "np->dst_cookie = rt6_get_cookie(rt);"
> in ip6_dst_store() before the sk_setup_caps(sk, dst) call.
> 
> This is because ip6_dst_store() can be called from process context,
> without any lock held.
> 
> As soon as the dst is installed in sk->sk_dst_cache, dst can be freed
> from another cpu doing a concurrent ip6_dst_store()
> 
> Doing the dst dereference before doing the install is needed to make
> sure no use after free would trigger.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> ---
> v2: added the explanation about rt6_get_cookie(rt) called
> before sk_setup_caps()

Applied to 'net', with some fuzz... did you happen to generate this
against net-next by chance?
