From: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
Subject: [RFC] ipv4: Do not cache routing failures due to disabled forwarding.
Date: Fri, 12 Sep 2014 16:14:20 +0200
Message-ID: <1410531260-13794-2-git-send-email-nicolas.cavallari@green-communications.fr>
References: <1410531260-13794-1-git-send-email-nicolas.cavallari@green-communications.fr>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:63715 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753637AbaILOPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 10:15:41 -0400
In-Reply-To: <1410531260-13794-1-git-send-email-nicolas.cavallari@green-communications.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we cache them, the kernel will reuse them, independently of
whether forwarding is enabled or not.  Which means that if forwarding is
disabled on the input interface where the first routing request comes
from, then that unreachable result will be cached and reused for
other interfaces, even if forwarding is enabled on them.

This can be verified with two interfaces A and B and an output interface
C, where B has forwarding enabled, but not A and trying
ip route get $dst iif A from $src && ip route get $dst iif B from $src

Signed-off-by: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
---
based on net-next, but not really tested on top of it.

 net/ipv4/route.c | 21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 234a43e..b537997 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1655,7 +1655,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	struct rtable	*rth;
 	int		err = -EINVAL;
 	struct net    *net = dev_net(dev);
-	bool do_cache;
+	bool do_cache = true;
 
 	/* IP on this device is disabled. */
 
@@ -1723,6 +1723,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 
 	if (!IN_DEV_FORWARD(in_dev)) {
 		err = -EHOSTUNREACH;
+		do_cache = false;
 		goto no_route;
 	}
 	if (res.type != RTN_UNICAST)
@@ -1746,16 +1747,14 @@ brd_input:
 	RT_CACHE_STAT_INC(in_brd);
 
 local_input:
-	do_cache = false;
-	if (res.fi) {
-		if (!itag) {
-			rth = rcu_dereference(FIB_RES_NH(res).nh_rth_input);
-			if (rt_cache_valid(rth)) {
-				skb_dst_set_noref(skb, &rth->dst);
-				err = 0;
-				goto out;
-			}
-			do_cache = true;
+	if (!res.fi || itag) {
+		do_cache = false;
+	} else if (do_cache) {
+		rth = rcu_dereference(FIB_RES_NH(res).nh_rth_input);
+		if (rt_cache_valid(rth)) {
+			skb_dst_set_noref(skb, &rth->dst);
+			err = 0;
+			goto out;
 		}
 	}
 
-- 
2.1.0
