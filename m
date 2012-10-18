From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH] ipv4: Fix flushing of cached routing informations
Date: Thu, 18 Oct 2012 07:27:31 +0200
Message-ID: <20121018052730.GB27385@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:37263 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753965Ab2JRF1d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2012 01:27:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we can not flush cached pmtu/redirect informations via
the ipv4_sysctl_rtcache_flush sysctl. We need to check the rt_genid
of the old route and reset the nh exeption if the old route is
expired when we bind a new route to a nh exeption.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/route.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 432f4bb..defb98d 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1163,8 +1163,17 @@ static bool rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe,
 	spin_lock_bh(&fnhe_lock);
 
 	if (daddr == fnhe->fnhe_daddr) {
-		struct rtable *orig;
+		struct rtable *orig = rcu_dereference(fnhe->fnhe_rth);
+		rcu_assign_pointer(fnhe->fnhe_rth, rt);
 
+		if (orig) {
+			if (rt_is_expired(orig)) {
+				fnhe->fnhe_gw = 0;
+				fnhe->fnhe_pmtu = 0;
+				fnhe->fnhe_expires = 0;
+			}
+			rt_free(orig);
+		}
 		if (fnhe->fnhe_pmtu) {
 			unsigned long expires = fnhe->fnhe_expires;
 			unsigned long diff = expires - jiffies;
@@ -1181,11 +1190,6 @@ static bool rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe,
 		} else if (!rt->rt_gateway)
 			rt->rt_gateway = daddr;
 
-		orig = rcu_dereference(fnhe->fnhe_rth);
-		rcu_assign_pointer(fnhe->fnhe_rth, rt);
-		if (orig)
-			rt_free(orig);
-
 		fnhe->fnhe_stamp = jiffies;
 		ret = true;
 	}
-- 
1.7.0.4
