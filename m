From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC(v2) net-next 01/13] ndisc: Refer/Update neigh->updated with
 write lock.
Date: Wed, 16 Jan 2013 01:44:39 +0900
Message-ID: <50F58777.7080209@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:41294 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756924Ab3AOQok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 11:44:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/route.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 7c34c01..1341f68 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -499,22 +499,26 @@ static void rt6_probe(struct rt6_info *rt)
 	 * to no more than one per minute.
 	 */
 	neigh = rt ? rt->n : NULL;
-	if (!neigh || (neigh->nud_state & NUD_VALID))
+	if (!neigh)
+		return;
+	write_lock_bh(&neigh->lock);
+	if (neigh->nud_state & NUD_VALID) {
+		write_unlock_bh(&neigh->lock);
 		return;
-	read_lock_bh(&neigh->lock);
+	}
 	if (!(neigh->nud_state & NUD_VALID) &&
 	    time_after(jiffies, neigh->updated + rt->rt6i_idev->cnf.rtr_probe_interval)) {
 		struct in6_addr mcaddr;
 		struct in6_addr *target;
 
 		neigh->updated = jiffies;
-		read_unlock_bh(&neigh->lock);
+		write_unlock_bh(&neigh->lock);
 
 		target = (struct in6_addr *)&neigh->primary_key;
 		addrconf_addr_solict_mult(target, &mcaddr);
 		ndisc_send_ns(rt->dst.dev, NULL, target, &mcaddr, NULL);
 	} else {
-		read_unlock_bh(&neigh->lock);
+		write_unlock_bh(&neigh->lock);
 	}
 }
 #else
-- 
1.7.9.5
