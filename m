From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 3/6 net-2.6.25] [NETNS] Pass correct namespace in fib_validate_source.
Date: Mon, 21 Jan 2008 17:50:43 +0300
Message-ID: <1200927046-11354-3-git-send-email-den@openvz.org>
References: <4794B10E.7010703@sw.ru>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:53719 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754697AbYAUOup (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 09:50:45 -0500
In-Reply-To: <4794B10E.7010703@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct network namespace is available inside fib_validate_source. It can be
obtained from the device passed in. The device is not NULL as in_device is
obtained from it just above.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/fib_frontend.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index dcd3a28..39b8b35 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -243,6 +243,7 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 	struct fib_result res;
 	int no_addr, rpf;
 	int ret;
+	struct net *net;
 
 	no_addr = rpf = 0;
 	rcu_read_lock();
@@ -256,7 +257,8 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 	if (in_dev == NULL)
 		goto e_inval;
 
-	if (fib_lookup(&init_net, &fl, &res))
+	net = dev->nd_net;
+	if (fib_lookup(net, &fl, &res))
 		goto last_resort;
 	if (res.type != RTN_UNICAST)
 		goto e_inval_res;
@@ -280,7 +282,7 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 	fl.oif = dev->ifindex;
 
 	ret = 0;
-	if (fib_lookup(&init_net, &fl, &res) == 0) {
+	if (fib_lookup(net, &fl, &res) == 0) {
 		if (res.type == RTN_UNICAST) {
 			*spec_dst = FIB_RES_PREFSRC(res);
 			ret = FIB_RES_NH(res).nh_scope >= RT_SCOPE_HOST;
-- 
1.5.3.rc5

