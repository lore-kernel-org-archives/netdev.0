From: David Miller <davem@davemloft.net>
Subject: Re: Problems with /proc/net/tcp6 - possible bug - ipv6
Date: Mon, 24 Jan 2011 16:02:23 -0800 (PST)
Message-ID: <20110124.160223.15249309.davem@davemloft.net>
References: <1295686781.2609.37.camel@edumazet-laptop>
	<1295709344.2651.55.camel@edumazet-laptop>
	<115440.16148.qm@web63902.mail.re1.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: runningdoglackey@yahoo.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <115440.16148.qm@web63902.mail.re1.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: PK <runningdoglackey@yahoo.com>
Date: Sat, 22 Jan 2011 11:42:54 -0800 (PST)

> These warnings show up when I run the script (or I presume any tcp6 connection 
> flooder) with /proc/sys/net/tcp/ipv4/tcp_tw_recycle enabled.  There's textual 
> corruption of the traces a lot of the time.  Here's a sample trace that doesn't 
> appear to be corrupt.  All the warnings I've seen are from route.c:209, and I 
> don't see how that would cause memory corruption.

Please give this patch a try:

--------------------
>From d80bc0fd262ef840ed4e82593ad6416fa1ba3fc4 Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@davemloft.net>
Date: Mon, 24 Jan 2011 16:01:58 -0800
Subject: [PATCH] ipv6: Always clone offlink routes.

Do not handle PMTU vs. route lookup creation any differently
wrt. offlink routes, always clone them.

Reported-by: PK <runningdoglackey@yahoo.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/route.c |    9 +--------
 1 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 373bd04..1534508 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -72,8 +72,6 @@
 #define RT6_TRACE(x...) do { ; } while (0)
 #endif
 
-#define CLONE_OFFLINK_ROUTE 0
-
 static struct rt6_info * ip6_rt_copy(struct rt6_info *ort);
 static struct dst_entry	*ip6_dst_check(struct dst_entry *dst, u32 cookie);
 static unsigned int	 ip6_default_advmss(const struct dst_entry *dst);
@@ -738,13 +736,8 @@ restart:
 
 	if (!rt->rt6i_nexthop && !(rt->rt6i_flags & RTF_NONEXTHOP))
 		nrt = rt6_alloc_cow(rt, &fl->fl6_dst, &fl->fl6_src);
-	else {
-#if CLONE_OFFLINK_ROUTE
+	else
 		nrt = rt6_alloc_clone(rt, &fl->fl6_dst);
-#else
-		goto out2;
-#endif
-	}
 
 	dst_release(&rt->dst);
 	rt = nrt ? : net->ipv6.ip6_null_entry;
-- 
1.7.3.4
