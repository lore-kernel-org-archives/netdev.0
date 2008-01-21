From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 4/6 net-2.6.25] [NETNS] Pass correct namespace in context fib_check_nh.
Date: Mon, 21 Jan 2008 17:50:44 +0300
Message-ID: <1200927046-11354-4-git-send-email-den@openvz.org>
References: <4794B10E.7010703@sw.ru>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:59353 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754701AbYAUOuq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 09:50:46 -0500
In-Reply-To: <4794B10E.7010703@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct network namespace is already used in fib_check_nh. Re-work its usage
for better readability and pass into fib_lookup & inetdev_by_index.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/fib_semantics.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 8b47e11..c791286 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -519,7 +519,9 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 			struct fib_nh *nh)
 {
 	int err;
+	struct net *net;
 
+	net = cfg->fc_nlinfo.nl_net;
 	if (nh->nh_gw) {
 		struct fib_result res;
 
@@ -532,11 +534,9 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 
 			if (cfg->fc_scope >= RT_SCOPE_LINK)
 				return -EINVAL;
-			if (inet_addr_type(cfg->fc_nlinfo.nl_net,
-					   nh->nh_gw) != RTN_UNICAST)
+			if (inet_addr_type(net, nh->nh_gw) != RTN_UNICAST)
 				return -EINVAL;
-			if ((dev = __dev_get_by_index(cfg->fc_nlinfo.nl_net,
-						      nh->nh_oif)) == NULL)
+			if ((dev = __dev_get_by_index(net, nh->nh_oif)) == NULL)
 				return -ENODEV;
 			if (!(dev->flags&IFF_UP))
 				return -ENETDOWN;
@@ -559,7 +559,7 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 			/* It is not necessary, but requires a bit of thinking */
 			if (fl.fl4_scope < RT_SCOPE_LINK)
 				fl.fl4_scope = RT_SCOPE_LINK;
-			if ((err = fib_lookup(&init_net, &fl, &res)) != 0)
+			if ((err = fib_lookup(net, &fl, &res)) != 0)
 				return err;
 		}
 		err = -EINVAL;
@@ -583,7 +583,7 @@ out:
 		if (nh->nh_flags&(RTNH_F_PERVASIVE|RTNH_F_ONLINK))
 			return -EINVAL;
 
-		in_dev = inetdev_by_index(&init_net, nh->nh_oif);
+		in_dev = inetdev_by_index(net, nh->nh_oif);
 		if (in_dev == NULL)
 			return -ENODEV;
 		if (!(in_dev->dev->flags&IFF_UP)) {
-- 
1.5.3.rc5

