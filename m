From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next (V4) 06/11] ipv6: Do not depend on rt->n in rt6_check_neigh().
Date: Fri, 18 Jan 2013 07:53:38 +0900
Message-ID: <50F880F2.8030501@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, xiyou.wangcong@gmail.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:44767 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754284Ab3AQWxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 17:53:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/route.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 2839381..c7bcd77 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -546,20 +546,24 @@ static inline bool rt6_check_neigh(struct rt6_info *rt)
 	struct neighbour *neigh;
 	bool ret = false;
 
-	neigh = rt->n;
 	if (rt->rt6i_flags & RTF_NONEXTHOP ||
 	    !(rt->rt6i_flags & RTF_GATEWAY))
-		ret = true;
-	else if (neigh) {
-		read_lock_bh(&neigh->lock);
+		return true;
+
+	rcu_read_lock_bh();
+	neigh = __ipv6_neigh_lookup_noref(rt->dst.dev, &rt->rt6i_gateway);
+	if (neigh) {
+		read_lock(&neigh->lock);
 		if (neigh->nud_state & NUD_VALID)
 			ret = true;
 #ifdef CONFIG_IPV6_ROUTER_PREF
 		else if (!(neigh->nud_state & NUD_FAILED))
 			ret = true;
 #endif
-		read_unlock_bh(&neigh->lock);
+		read_unlock(&neigh->lock);
 	}
+	rcu_read_unlock_bh();
+
 	return ret;
 }
 
-- 
1.7.9.5
