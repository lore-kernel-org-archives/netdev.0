From: CAI Qian <caiqian@redhat.com>
Subject: [PATCH stable] ipv4: do not cache looped multicasts
Date: Fri, 7 Dec 2012 10:58:54 -0500 (EST)
Message-ID: <1620782878.5271574.1354895934053.JavaMail.root@redhat.com>
References: <2138496357.5269916.1354895709722.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Maxime Bizon <mbizon@freebox.fr>, Julian Anastasov <ja@ssi.bg>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:52747 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932201Ab2LGP7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 10:59:07 -0500
In-Reply-To: <2138496357.5269916.1354895709722.JavaMail.root@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, this looks like applicable to the stable releases.

>From Maxime Bizon <mbizon@freebox.fr>,

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
Signed-off-by: David S. Miller <davem@davemloft.net>

Upstream-ID: 636174219b52b5a8bc51bc23bbcba97cd30a65e3
Stable-trees: 3.6.x
Signed-off-by: CAI Qian <caiqian@redhat.com>

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 200d287..df25142 100644
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
