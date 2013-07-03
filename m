From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: PROBLEM: Linux 3.9 more-specific ipv6 route ignored until next-hop is in neighbor cache
Date: Wed, 3 Jul 2013 20:45:04 +0200
Message-ID: <20130703184504.GD12615@order.stressinduktion.org>
References: <CA+PSOpyxWf2s_JscuBYfOAW9hVkSqqC1JwdRDQ4WtZrkneQf6A@mail.gmail.com> <20130703050007.GA11216@order.stressinduktion.org> <20130703181546.GC12615@order.stressinduktion.org> <51D46B9F.6050400@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Pierre Emeriaud <petrus.lt@gmail.com>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:52670 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933222Ab3GCSpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 14:45:05 -0400
Content-Disposition: inline
In-Reply-To: <51D46B9F.6050400@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 03, 2013 at 10:21:19PM +0400, Sergei Shtylyov wrote:
>    How about:
> 
> 	} else if (IS_ENABLED(CONFIG_IPV6_ROUTER_PREF)) {
> 
> >+		ret = true;
> >+#endif
> >  	}

Definitely an improvment, thanks!

[PATCH net v2] ipv6: rt6_check_neigh should successfully verify neigh if no NUD information are available

After the removal of rt->n we do not create a neighbour entry at route
insertion time (rt6_bind_neighbour is gone). As long as no neighbour is
created because of "useful traffic" we skip this routing entry because
rt6_check_neigh cannot pick up a valid neighbour (neigh == NULL) and
thus returns false.

This change was introduced by commit
887c95cc1da53f66a5890fdeab13414613010097 ("ipv6: Complete neighbour
entry removal from dst_entry.")

To quote RFC4191:
"If the host has no information about the router's reachability, then
the host assumes the router is reachable."

and also:
"A host MUST NOT probe a router's reachability in the absence of useful
traffic that the host would have sent to the router if it were reachable."

So, just assume the router is reachable and let's rt6_probe do the
rest. We don't need to create a neighbour on route insertion time.

If we don't compile with CONFIG_IPV6_ROUTER_PREF (RFC4191 support)
a neighbour is only valid if its nud_state is NUD_VALID. I did not find
any references that we should probe the router on route insertion time
via the other RFCs. So skip this route in that case.

v2:
a) use IS_ENABLED instead of #ifdefs (thanks to Sergei Shtylyov)

Reported-by: Pierre Emeriaud <petrus.lt@gmail.com>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/route.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ad0aa6b..7f1332f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -547,6 +547,8 @@ static inline bool rt6_check_neigh(struct rt6_info *rt)
 			ret = true;
 #endif
 		read_unlock(&neigh->lock);
+	} else if (IS_ENABLED(CONFIG_IPV6_ROUTER_PREF)) {
+		ret = true;
 	}
 	rcu_read_unlock_bh();
 
-- 
1.8.1.4
