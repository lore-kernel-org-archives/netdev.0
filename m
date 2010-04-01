From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next-2.6] ipv6 fib: Make rt6_info{} more cache-line aware.
Date: Thu, 01 Apr 2010 17:24:22 +0900
Message-ID: <4BB45836.2060104@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:58285 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754217Ab0DAIZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 04:25:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The head element of rt6_info{} is dst_entry{}, and
IPv6 specific elements follow.

Because elements at the end of dst_entry{} are frequently
updated, it is not good to put frequently-used static
elements, such as rt6i_idev, rt6i_dst or rt6i_flags in the
same cache line.

On the other hand, fib6_table, rt6i_node or rt6i_gateway are
rarely used, so it is okay to stay in the same cache line.

Let's rearrange rt6_info{}.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ip6_fib.h |   29 ++++++++++++++++-------------
 1 files changed, 16 insertions(+), 13 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 86f46c4..4b1dc11 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -88,34 +88,37 @@ struct rt6_info {
 		struct dst_entry	dst;
 	} u;
 
-	struct inet6_dev		*rt6i_idev;
-
 #define rt6i_dev			u.dst.dev
 #define rt6i_nexthop			u.dst.neighbour
 #define rt6i_expires			u.dst.expires
 
+	/*
+	 * Tail elements of dst_entry (__refcnt etc.)
+	 * and these elements (rarely used in hot path) are in
+	 * the same cache line.
+	 */
+	struct fib6_table		*rt6i_table;
 	struct fib6_node		*rt6i_node;
 
 	struct in6_addr			rt6i_gateway;
-	
-	u32				rt6i_flags;
-	u32				rt6i_metric;
-	atomic_t			rt6i_ref;
 
-	/* more non-fragment space at head required */
-	unsigned short			rt6i_nfheader_len;
-
-	u8				rt6i_protocol;
+	atomic_t			rt6i_ref;
 
-	struct fib6_table		*rt6i_table;
+	/* These are in a separate cache line. */
+	struct rt6key			rt6i_dst ____cacheline_aligned_in_smp;
+	u32				rt6i_flags;
+	struct rt6key			rt6i_src;
+	u32				rt6i_metric;
 
-	struct rt6key			rt6i_dst;
+	struct inet6_dev		*rt6i_idev;
 
 #ifdef CONFIG_XFRM
 	u32				rt6i_flow_cache_genid;
 #endif
+	/* more non-fragment space at head required */
+	unsigned short			rt6i_nfheader_len;
 
-	struct rt6key			rt6i_src;
+	u8				rt6i_protocol;
 };
 
 static inline struct inet6_dev *ip6_dst_idev(struct dst_entry *dst)
-- 
1.5.6.5

--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
