From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] ipv4: distinguish EHOSTUNREACH from the ENETUNREACH
Date: Fri, 14 Feb 2014 18:26:22 +0800
Message-ID: <52FDEF4E.3010806@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:1545 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750975AbaBNK10 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 05:27:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


since commit 251da413("ipv4: Cache ip_error() routes even when not forwarding."),
the counter IPSTATS_MIB_INADDRERRORS can't work correctly, because the value of
err was always set to ENETUNREACH.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv4/route.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 25071b4..6f6dd85 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1695,8 +1695,11 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	fl4.daddr = daddr;
 	fl4.saddr = saddr;
 	err = fib_lookup(net, &fl4, &res);
-	if (err != 0)
+	if (err != 0) {
+		if (!IN_DEV_FORWARD(in_dev))
+			err = -EHOSTUNREACH;
 		goto no_route;
+	}
 
 	RT_CACHE_STAT_INC(in_slow_tot);
 
@@ -1712,8 +1715,10 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		goto local_input;
 	}
 
-	if (!IN_DEV_FORWARD(in_dev))
+	if (!IN_DEV_FORWARD(in_dev)) {
+		err = -EHOSTUNREACH;
 		goto no_route;
+	}
 	if (res.type != RTN_UNICAST)
 		goto martian_destination;
 
-- 
1.8.3.1
