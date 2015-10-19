From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: Really fix vti6 with oif in dst lookups
Date: Mon, 19 Oct 2015 08:26:05 -0700
Message-ID: <1445268365-23414-1-git-send-email-dsa@cumulusnetworks.com>
Cc: steffen.klassert@secunet.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36379 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752758AbbJSP0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 11:26:13 -0400
Received: by pacfv9 with SMTP id fv9so98542610pac.3
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 08:26:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

6e28b000825d ("net: Fix vti use case with oif in dst lookups for IPv6")
is missing the checks on FLOWI_FLAG_SKIP_NH_OIF. Add them.

Fixes: 42a7b32b73d6 ("xfrm: Add oif to dst lookups")
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
This is needed for net in 4.3. 6e28b000825d was mistakenly created on
top of the VRF patches which had this change. Steffen has confirmed
VTI6 works with this change.

 net/ipv6/ip6_output.c | 3 ++-
 net/ipv6/route.c      | 3 +++
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 61d403ee1031..d03d6da772f3 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -877,7 +877,8 @@ static struct dst_entry *ip6_sk_dst_check(struct sock *sk,
 #ifdef CONFIG_IPV6_SUBTREES
 	    ip6_rt_check(&rt->rt6i_src, &fl6->saddr, np->saddr_cache) ||
 #endif
-	    (fl6->flowi6_oif && fl6->flowi6_oif != dst->dev->ifindex)) {
+	   (!(fl6->flowi6_flags & FLOWI_FLAG_SKIP_NH_OIF) &&
+	      (fl6->flowi6_oif && fl6->flowi6_oif != dst->dev->ifindex))) {
 		dst_release(dst);
 		dst = NULL;
 	}
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 968f31c01f89..be5d2879b5d8 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1068,6 +1068,9 @@ static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 	fn = fib6_lookup(&table->tb6_root, &fl6->daddr, &fl6->saddr);
 	saved_fn = fn;
 
+	if (fl6->flowi6_flags & FLOWI_FLAG_SKIP_NH_OIF)
+		oif = 0;
+
 redo_rt6_select:
 	rt = rt6_select(fn, oif, strict);
 	if (rt->rt6i_nsiblings)
-- 
1.9.1
