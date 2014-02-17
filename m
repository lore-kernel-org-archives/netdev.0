From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] ipv4: fix counter in_slow_tot
Date: Mon, 17 Feb 2014 15:23:43 +0800
Message-ID: <5301B8FF.6030800@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:45152 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750903AbaBQHYr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Feb 2014 02:24:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


since commit 89aef8921bf("ipv4: Delete routing cache."), the counter
in_slow_tot can't work correctly.

The counter in_slow_tot increase by one when fib_lookup() return successfully
in ip_route_input_slow(), but actually the dst struct maybe not be created and
cached, so we can increase in_slow_tot after the dst struct is created.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv4/route.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 25071b4..9df3819 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1597,6 +1597,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_gateway	= 0;
 	rth->rt_uses_gateway = 0;
 	INIT_LIST_HEAD(&rth->rt_uncached);
+	RT_CACHE_STAT_INC(in_slow_tot);
 
 	rth->dst.input = ip_forward;
 	rth->dst.output = ip_output;
@@ -1698,8 +1699,6 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (err != 0)
 		goto no_route;
 
-	RT_CACHE_STAT_INC(in_slow_tot);
-
 	if (res.type == RTN_BROADCAST)
 		goto brd_input;
 
@@ -1768,6 +1767,7 @@ local_input:
 	rth->rt_gateway	= 0;
 	rth->rt_uses_gateway = 0;
 	INIT_LIST_HEAD(&rth->rt_uncached);
+	RT_CACHE_STAT_INC(in_slow_tot);
 	if (res.type == RTN_UNREACHABLE) {
 		rth->dst.input= ip_error;
 		rth->dst.error= -err;
-- 
1.8.3.1
