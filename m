From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH v2] ipv4: Fix flushing of cached routing informations
Date: Thu, 18 Oct 2012 09:17:44 +0200
Message-ID: <20121018071744.GD27385@secunet.com>
References: <20121018052730.GB27385@secunet.com>
 <alpine.LFD.2.00.1210180927230.1572@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:38443 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751259Ab2JRHRv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2012 03:17:51 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1210180927230.1572@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we can not flush cached pmtu/redirect informations via
the ipv4_sysctl_rtcache_flush sysctl. We need to check the rt_genid
of the old route and reset the nh exeption if the old route is
expired when we bind a new route to a nh exeption.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/route.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 432f4bb..a8c6512 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1163,8 +1163,12 @@ static bool rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe,
 	spin_lock_bh(&fnhe_lock);
 
 	if (daddr == fnhe->fnhe_daddr) {
-		struct rtable *orig;
-
+		struct rtable *orig = rcu_dereference(fnhe->fnhe_rth);
+		if (orig && rt_is_expired(orig)) {
+			fnhe->fnhe_gw = 0;
+			fnhe->fnhe_pmtu = 0;
+			fnhe->fnhe_expires = 0;
+		}
 		if (fnhe->fnhe_pmtu) {
 			unsigned long expires = fnhe->fnhe_expires;
 			unsigned long diff = expires - jiffies;
@@ -1181,7 +1185,6 @@ static bool rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe,
 		} else if (!rt->rt_gateway)
 			rt->rt_gateway = daddr;
 
-		orig = rcu_dereference(fnhe->fnhe_rth);
 		rcu_assign_pointer(fnhe->fnhe_rth, rt);
 		if (orig)
 			rt_free(orig);
-- 
1.7.0.4
