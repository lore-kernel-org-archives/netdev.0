From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 10/17 net-2.6.26] [NETNS]: Process ip_rt_redirect in the correct namespace.
Date: Tue, 19 Feb 2008 10:31:30 +0300
Message-ID: <1203406297-32725-10-git-send-email-den@openvz.org>
References: <1203406116.27296.1.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	devel@openvz.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:60012 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754475AbYBSHbP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 02:31:15 -0500
In-Reply-To: <1203406116.27296.1.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/route.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 525787b..44708ab 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1132,10 +1132,12 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 	__be32  skeys[2] = { saddr, 0 };
 	int  ikeys[2] = { dev->ifindex, 0 };
 	struct netevent_redirect netevent;
+	struct net *net;
 
 	if (!in_dev)
 		return;
 
+	net = dev->nd_net;
 	if (new_gw == old_gw || !IN_DEV_RX_REDIRECTS(in_dev)
 	    || ipv4_is_multicast(new_gw) || ipv4_is_lbcast(new_gw)
 	    || ipv4_is_zeronet(new_gw))
@@ -1147,7 +1149,7 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 		if (IN_DEV_SEC_REDIRECTS(in_dev) && ip_fib_check_default(new_gw, dev))
 			goto reject_redirect;
 	} else {
-		if (inet_addr_type(&init_net, new_gw) != RTN_UNICAST)
+		if (inet_addr_type(net, new_gw) != RTN_UNICAST)
 			goto reject_redirect;
 	}
 
@@ -1165,7 +1167,8 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 				    rth->fl.fl4_src != skeys[i] ||
 				    rth->fl.oif != ikeys[k] ||
 				    rth->fl.iif != 0 ||
-				    rth->rt_genid != atomic_read(&rt_genid)) {
+				    rth->rt_genid != atomic_read(&rt_genid) ||
+				    rth->u.dst.dev->nd_net != net) {
 					rthp = &rth->u.dst.rt_next;
 					continue;
 				}
-- 
1.5.3.rc5

