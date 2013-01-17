From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 07/11] ipv6: Do not depend on rt->n in rt6_probe().
Date: Fri, 18 Jan 2013 02:42:24 +0900
Message-ID: <50F83800.60103@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, xiyou.wangcong@gmail.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:44406 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755645Ab3AQRmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 12:42:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/route.c |   26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c7bcd77..afc8386 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -498,28 +498,34 @@ static void rt6_probe(struct rt6_info *rt)
 	 * Router Reachability Probe MUST be rate-limited
 	 * to no more than one per minute.
 	 */
-	neigh = rt ? rt->n : NULL;
-	if (!neigh)
-		return;
-	write_lock_bh(&neigh->lock);
-	if (neigh->nud_state & NUD_VALID) {
-		write_unlock_bh(&neigh->lock);
+	if (!rt || !(rt->rt6i_flags & RTF_GATEWAY))
 		return;
+	rcu_read_lock_bh();
+	neigh = __ipv6_neigh_lookup_noref(rt->dst.dev, &rt->rt6i_gateway);
+	if (neigh) {
+		write_lock(&neigh->lock);
+		if (neigh->nud_state & NUD_VALID)
+			goto out;
 	}
-	if (!(neigh->nud_state & NUD_VALID) &&
+
+	if (!neigh ||
 	    time_after(jiffies, neigh->updated + rt->rt6i_idev->cnf.rtr_probe_interval)) {
 		struct in6_addr mcaddr;
 		struct in6_addr *target;
 
 		neigh->updated = jiffies;
-		write_unlock_bh(&neigh->lock);
 
-		target = (struct in6_addr *)&neigh->primary_key;
+		if (neigh)
+			write_unlock(&neigh->lock);
+
+		target = (struct in6_addr *)&rt->rt6i_gateway;
 		addrconf_addr_solict_mult(target, &mcaddr);
 		ndisc_send_ns(rt->dst.dev, NULL, target, &mcaddr, NULL);
 	} else {
-		write_unlock_bh(&neigh->lock);
+out:
+		write_unlock(&neigh->lock);
 	}
+	rcu_read_unlock_bh();
 }
 #else
 static inline void rt6_probe(struct rt6_info *rt)
-- 
1.7.9.5
