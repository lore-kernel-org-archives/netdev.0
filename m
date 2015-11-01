From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: [PATCH net] ipv6: fix crash on ICMPv6 redirects with prohibited/blackholed source
Date: Mon,  2 Nov 2015 00:10:35 +0100
Message-ID: <bf7886537e41d9e9ac1a0d901283daf22b0b5df1.1446419326.git.mschiffer@universe-factory.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from chaos.universe-factory.net ([37.72.148.22]:37662 "EHLO
	chaos.universe-factory.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753087AbbKAXTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 18:19:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are other error values besides ip6_null_entry that can be returned by
ip6_route_redirect(): fib6_rule_action() can also result in
ip6_blk_hole_entry and ip6_prohibit_entry if such ip rules are installed.

Only checking for ip6_null_entry in rt6_do_redirect() causes ip6_ins_rt()
to be called with rt->rt6i_table == NULL in these cases, making the kernel
crash.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
---

This bug exists pretty much forever, please queue up for all -stable
kernels.


 net/ipv6/route.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 946880a..c196ed7 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2160,7 +2160,7 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 	}
 
 	rt = (struct rt6_info *) dst;
-	if (rt == net->ipv6.ip6_null_entry) {
+	if (rt->rt6i_flags & RTF_REJECT) {
 		net_dbg_ratelimited("rt6_redirect: source isn't a valid nexthop for redirect target\n");
 		return;
 	}
-- 
2.6.2
