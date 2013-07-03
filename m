From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: PROBLEM: Linux 3.9 more-specific ipv6 route ignored until next-hop is in neighbor cache
Date: Wed, 3 Jul 2013 07:00:07 +0200
Message-ID: <20130703050007.GA11216@order.stressinduktion.org>
References: <CA+PSOpyxWf2s_JscuBYfOAW9hVkSqqC1JwdRDQ4WtZrkneQf6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Pierre Emeriaud <petrus.lt@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:51291 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512Ab3GCFAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 01:00:09 -0400
Content-Disposition: inline
In-Reply-To: <CA+PSOpyxWf2s_JscuBYfOAW9hVkSqqC1JwdRDQ4WtZrkneQf6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Cc YOSHIFUJI Hideaki because of commit
887c95cc1da53f66a5890fdeab13414613010097 ("ipv6: Complete neighbour entry
removal from dst_entry.")]

On Wed, Jul 03, 2013 at 12:04:33AM +0200, Pierre Emeriaud wrote:
> Linux 3.9 more-specific ipv6 route ignored until next-hop is in neighbor cache.
> 
> When adding a route to 2000::/3 with a next-hop that is not in the
> neighbor cache, the route is not preferred over the default.

Thanks for the report!

Well.

We ignore this route because of rt6_score_route returning -1 in this case.
This traces down to rt6_check_neigh returning false.

Before the above mentioned commit we kicked off some logic to create a
neighbour entry in ip6_route_add. Now we end up with neigh == NULL.

This is a hotfix but I need to do more research regarding
CONFIG_IPV6_ROUTER_PREF and further expectations of neigh != NULL (you
can try this at your own risk ;):

--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -547,6 +547,10 @@ static inline bool rt6_check_neigh(struct rt6_info *rt)
                        ret = true;
 #endif
                read_unlock(&neigh->lock);
+       } else {
+#ifdef CONFIG_IPV6_ROUTER_PREF
+               ret = true;
+#endif
        }
        rcu_read_unlock_bh();
 

Greetings,

  Hannes
