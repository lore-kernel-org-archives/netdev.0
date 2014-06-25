From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: question on ipv6 support for duplicate nexthops
Date: Wed, 25 Jun 2014 14:40:03 -0700
Message-ID: <53AB41B3.1020201@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Walton <dwalton@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:36230 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753174AbaFYVkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 17:40:06 -0400
Received: from localhost (localhost [127.0.0.1])
	by ext3.cumulusnetworks.com (Postfix) with ESMTP id 44023160042A
	for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 14:40:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv4 allows duplicate nexthops. Multiple instances of same
  nexthops maybe used to give higher weights to some nexthops
(though the "weight" attribute can be used for the same purpose).

ipv6 does not seem to support duplicate nexthops.

Example: The below ipv6 route is rejected by the kernel
#ip -6 route add 2001:10:1:3::/64 nexthop via 2001:10:1:2::99 nexthop 
via 2001:10:1:2::99

The below patch points to the code that is preventing the addition of 
duplicate nexthops.

I am not sure yet if there are other side effects to the patch below.
If there is interest in making ipv6 consistent with ipv4 for duplicate 
nexthop handling, i can submit a patch.


diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index cb4459b..afecc87 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -698,20 +698,6 @@ static int fib6_add_rt2node(struct fib6_node *fn, 
struct rt6_info *rt,
                                 break;
                         }

-                       if (iter->dst.dev == rt->dst.dev &&
-                           iter->rt6i_idev == rt->rt6i_idev &&
- ipv6_addr_equal(&iter->rt6i_gateway,
- &rt->rt6i_gateway)) {
-                               if (rt->rt6i_nsiblings)
-                                       rt->rt6i_nsiblings = 0;
-                               if (!(iter->rt6i_flags & RTF_EXPIRES))
-                                       return -EEXIST;
-                               if (!(rt->rt6i_flags & RTF_EXPIRES))
-                                       rt6_clean_expires(iter);
-                               else
-                                       rt6_set_expires(iter, 
rt->dst.expires);
-                               return -EEXIST;
-                       }
                         /* If we have the same destination and the same 
metric,
                          * but not the same gateway, then the route we 
try to
                          * add is sibling to this route, increment our 
counter
