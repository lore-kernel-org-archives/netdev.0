From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net 1/6] ipv4: fix sending of redirects
Date: Sun,  7 Oct 2012 14:26:03 +0300
Message-ID: <1349609168-9848-2-git-send-email-ja@ssi.bg>
References: <1349609168-9848-1-git-send-email-ja@ssi.bg>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:50414 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752563Ab2JGLU4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Oct 2012 07:20:56 -0400
Received: from ja.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.14.4/8.14.4) with ESMTP id q97BQIVj009880
	for <netdev@vger.kernel.org>; Sun, 7 Oct 2012 14:26:18 +0300
Received: (from root@localhost)
	by ja.ssi.bg (8.14.4/8.14.4/Submit) id q97BQIkM009879
	for netdev@vger.kernel.org; Sun, 7 Oct 2012 14:26:18 +0300
In-Reply-To: <1349609168-9848-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	After "Cache input routes in fib_info nexthops" (commit
d2d68ba9fe) and "Elide fib_validate_source() completely when possible"
(commit 7a9bc9b81a) we can not send ICMP redirects. It seems we
should not cache the RTCF_DOREDIRECT flag in nh_rth_input because
the same fib_info can be used for traffic that is not redirected,
eg. from other input devices or from sources that are not in same subnet.

	As result, we have to disable the caching of RTCF_DOREDIRECT
flag and to force source validation for the case when forwarding
traffic to the input device. If traffic comes from directly connected
source we allow redirection as it was done before both changes.

	After the change "Adjust semantics of rt->rt_gateway"
(commit f8126f1d51) we should make sure our ICMP_REDIR_HOST messages
contain daddr instead of 0.0.0.0 when target is directly connected.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv4/fib_frontend.c |    3 ++-
 net/ipv4/route.c        |   28 +++++++++++++++-------------
 2 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 68c93d1..6dacae6 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -322,7 +322,8 @@ int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 {
 	int r = secpath_exists(skb) ? 0 : IN_DEV_RPFILTER(idev);
 
-	if (!r && !fib_num_tclassid_users(dev_net(dev))) {
+	if (!r && !fib_num_tclassid_users(dev_net(dev)) &&
+	    dev->ifindex != oif) {
 		*itag = 0;
 		return 0;
 	}
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ff62206..488a8bb 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -802,7 +802,8 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 	net = dev_net(rt->dst.dev);
 	peer = inet_getpeer_v4(net->ipv4.peers, ip_hdr(skb)->saddr, 1);
 	if (!peer) {
-		icmp_send(skb, ICMP_REDIRECT, ICMP_REDIR_HOST, rt->rt_gateway);
+		icmp_send(skb, ICMP_REDIRECT, ICMP_REDIR_HOST,
+			  rt->rt_gateway ? : ip_hdr(skb)->daddr);
 		return;
 	}
 
@@ -827,7 +828,9 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 	    time_after(jiffies,
 		       (peer->rate_last +
 			(ip_rt_redirect_load << peer->rate_tokens)))) {
-		icmp_send(skb, ICMP_REDIRECT, ICMP_REDIR_HOST, rt->rt_gateway);
+		__be32 gw = rt->rt_gateway ? : ip_hdr(skb)->daddr;
+
+		icmp_send(skb, ICMP_REDIRECT, ICMP_REDIR_HOST, gw);
 		peer->rate_last = jiffies;
 		++peer->rate_tokens;
 #ifdef CONFIG_IP_ROUTE_VERBOSE
@@ -835,7 +838,7 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 		    peer->rate_tokens == ip_rt_redirect_number)
 			net_warn_ratelimited("host %pI4/if%d ignores redirects for %pI4 to %pI4\n",
 					     &ip_hdr(skb)->saddr, inet_iif(skb),
-					     &ip_hdr(skb)->daddr, &rt->rt_gateway);
+					     &ip_hdr(skb)->daddr, &gw);
 #endif
 	}
 out_put_peer:
@@ -1439,10 +1442,13 @@ static int __mkroute_input(struct sk_buff *skb,
 		goto cleanup;
 	}
 
+	do_cache = res->fi && !itag;
 	if (out_dev == in_dev && err &&
 	    (IN_DEV_SHARED_MEDIA(out_dev) ||
-	     inet_addr_onlink(out_dev, saddr, FIB_RES_GW(*res))))
+	     inet_addr_onlink(out_dev, saddr, FIB_RES_GW(*res)))) {
 		flags |= RTCF_DOREDIRECT;
+		do_cache = false;
+	}
 
 	if (skb->protocol != htons(ETH_P_IP)) {
 		/* Not IP (i.e. ARP). Do not create route, if it is
@@ -1459,15 +1465,11 @@ static int __mkroute_input(struct sk_buff *skb,
 		}
 	}
 
-	do_cache = false;
-	if (res->fi) {
-		if (!itag) {
-			rth = rcu_dereference(FIB_RES_NH(*res).nh_rth_input);
-			if (rt_cache_valid(rth)) {
-				skb_dst_set_noref(skb, &rth->dst);
-				goto out;
-			}
-			do_cache = true;
+	if (do_cache) {
+		rth = rcu_dereference(FIB_RES_NH(*res).nh_rth_input);
+		if (rt_cache_valid(rth)) {
+			skb_dst_set_noref(skb, &rth->dst);
+			goto out;
 		}
 	}
 
-- 
1.7.3.4
