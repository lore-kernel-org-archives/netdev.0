From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/21] ipv6: fib: Don't assume only nodes hold a reference on routes
Date: Thu,  3 Aug 2017 13:28:21 +0200
Message-ID: <20170803112831.1831-12-jiri@resnulli.us>
References: <20170803112831.1831-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36964 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752156AbdHCL2y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 07:28:54 -0400
Received: by mail-wr0-f193.google.com with SMTP id 12so798940wrb.4
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 04:28:54 -0700 (PDT)
In-Reply-To: <20170803112831.1831-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The code currently assumes that only FIB nodes can hold a reference on
routes. Therefore, after fib6_purge_rt() has run and the route is no
longer present in any intermediate nodes, it's assumed that its
reference count would be 1 - taken by the node where it's currently
stored.

However, we're going to allow users other than the FIB to take a
reference on a route, so this assumption is no longer valid and the
BUG_ON() needs to be removed.

Note that purging only takes place if the initial reference count is
different than 1. I've left that check intact, as in the majority of
systems (where routes are only referenced by the FIB), it does actually
mean the route is present in intermediate nodes.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/ipv6/ip6_fib.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 719c1048..fa27905 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -837,8 +837,6 @@ static void fib6_purge_rt(struct rt6_info *rt, struct fib6_node *fn,
 			}
 			fn = fn->parent;
 		}
-		/* No more references are possible at this point. */
-		BUG_ON(atomic_read(&rt->rt6i_ref) != 1);
 	}
 }
 
-- 
2.9.3
