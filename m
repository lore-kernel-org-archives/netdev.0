From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipv4: do not cache looped multicasts
Date: Thu, 22 Nov 2012 23:04:14 +0200
Message-ID: <1353618254-1874-1-git-send-email-ja@ssi.bg>
Cc: Maxime Bizon <mbizon@freebox.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:50446 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754777Ab2KVVDL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2012 16:03:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Starting from 3.6 we cache output routes for
multicasts only when using route to 224/4. For local receivers
we can set RTCF_LOCAL flag depending on the membership but
in such case we use maddr and saddr which are not caching
keys as before. Additionally, we can not use same place to
cache routes that differ in RTCF_LOCAL flag value.

	Fix it by caching only RTCF_MULTICAST entries
without RTCF_LOCAL (send-only, no loopback). As a side effect,
we avoid unneeded lookup for fnhe when not caching because
multicasts are not redirected and they do not learn PMTU.

	Thanks to Maxime Bizon for showing the caching
problems in __mkroute_output for 3.6 kernels: different
RTCF_LOCAL flag in cache can lead to wrong ip_mc_output or
ip_output call and the visible problem is that traffic can
not reach local receivers via loopback.

Reported-by: Maxime Bizon <mbizon@freebox.fr>
Tested-by: Maxime Bizon <mbizon@freebox.fr>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

	Patch applies to both trees but should go
to net tree.

 net/ipv4/route.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 5b58788..0d73f86 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1785,6 +1785,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	if (dev_out->flags & IFF_LOOPBACK)
 		flags |= RTCF_LOCAL;
 
+	do_cache = true;
 	if (type == RTN_BROADCAST) {
 		flags |= RTCF_BROADCAST | RTCF_LOCAL;
 		fi = NULL;
@@ -1793,6 +1794,8 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 		if (!ip_check_mc_rcu(in_dev, fl4->daddr, fl4->saddr,
 				     fl4->flowi4_proto))
 			flags &= ~RTCF_LOCAL;
+		else
+			do_cache = false;
 		/* If multicast route do not exist use
 		 * default one, but do not gateway in this case.
 		 * Yes, it is hack.
@@ -1802,8 +1805,8 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	}
 
 	fnhe = NULL;
-	do_cache = fi != NULL;
-	if (fi) {
+	do_cache &= fi != NULL;
+	if (do_cache) {
 		struct rtable __rcu **prth;
 		struct fib_nh *nh = &FIB_RES_NH(*res);
 
-- 
1.7.3.4
