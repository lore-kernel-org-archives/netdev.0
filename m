From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Thu, 21 Sep 2017 18:37:59 -0700 (PDT)
Message-ID: <20170921.183759.289331373985144347.davem@davemloft.net>
References: <20170922110355.6a631fc5@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org, pabeni@redhat.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922110355.6a631fc5@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 22 Sep 2017 11:03:55 +1000

> After merging the net-next tree, today's linux-next build (arm
> multi_v7_defconfig) failed like this:
> 
> net/ipv4/fib_frontend.c: In function 'fib_validate_source':
> net/ipv4/fib_frontend.c:411:16: error: 'struct netns_ipv4' has no member named 'fib_has_custom_local_routes'
>    if (net->ipv4.fib_has_custom_local_routes)
>                 ^
> net/ipv4/fib_frontend.c: In function 'inet_rtm_newroute':
> net/ipv4/fib_frontend.c:773:12: error: 'struct netns_ipv4' has no member named 'fib_has_custom_local_routes'
>    net->ipv4.fib_has_custom_local_routes = true;
>             ^
> 
> Caused by commit
> 
>   6e617de84e87 ("net: avoid a full fib lookup when rp_filter is disabled.")

Paolo, it seems this struct member should be placed outside of
IP_MULTIPLE_TABLES protection, since users can insert custom
local routes even without that set.

So I'm installing the following fix for this:

====================
[PATCH] ipv4: Move fib_has_custom_local_routes outside of IP_MULTIPLE_TABLES.

> net/ipv4/fib_frontend.c: In function 'fib_validate_source':
> net/ipv4/fib_frontend.c:411:16: error: 'struct netns_ipv4' has no member named 'fib_has_custom_local_routes'
>    if (net->ipv4.fib_has_custom_local_routes)
>                 ^
> net/ipv4/fib_frontend.c: In function 'inet_rtm_newroute':
> net/ipv4/fib_frontend.c:773:12: error: 'struct netns_ipv4' has no member named 'fib_has_custom_local_routes'
>    net->ipv4.fib_has_custom_local_routes = true;
>             ^

Fixes: 6e617de84e87 ("net: avoid a full fib lookup when rp_filter is disabled.")
Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/netns/ipv4.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 20720721da4b..8387f099115e 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -49,10 +49,10 @@ struct netns_ipv4 {
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	struct fib_rules_ops	*rules_ops;
 	bool			fib_has_custom_rules;
-	bool			fib_has_custom_local_routes;
 	struct fib_table __rcu	*fib_main;
 	struct fib_table __rcu	*fib_default;
 #endif
+	bool			fib_has_custom_local_routes;
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	int			fib_num_tclassid_users;
 #endif
-- 
2.13.5
