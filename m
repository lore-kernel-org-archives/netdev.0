From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 1/3] ipv6: Allow to connections to opt-out of flow labels
Date: Thu, 30 Jul 2015 09:54:20 -0700
Message-ID: <1438275262-3708460-2-git-send-email-tom@herbertland.com>
References: <1438275262-3708460-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33922 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750789AbbG3QzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 12:55:07 -0400
Received: from pps.filterd (m0004346 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6UGsQIg017022
	for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 09:55:07 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1vyq6mr35d-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 09:55:07 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 baa50b6436db11e5adff0002c99293a0-3c7f22b0 for <netdev@vger.kernel.org>;	Thu,
 30 Jul 2015 09:55:06 -0700
In-Reply-To: <1438275262-3708460-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently connections can opt-in to using flow labels by setsockopt.
This patch changes that to be opt-out. That is when the
auto_flowlabels sysctl is set, auto flow labels may be disabled
for specific connections.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/ipv6.h    | 2 +-
 net/ipv6/af_inet6.c   | 1 +
 net/ipv6/ip6_gre.c    | 4 ++--
 net/ipv6/ip6_tunnel.c | 2 +-
 4 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 7c79798..13d1983 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -710,7 +710,7 @@ static inline void iph_to_flow_copy_v6addrs(struct flow_keys *flow,
 static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
 					__be32 flowlabel, bool autolabel)
 {
-	if (!flowlabel && (autolabel || net->ipv6.sysctl.auto_flowlabels)) {
+	if (!flowlabel && autolabel && net->ipv6.sysctl.auto_flowlabels) {
 		u32 hash;
 
 		hash = skb_get_hash(skb);
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 7bc92ea..b98be8e 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -197,6 +197,7 @@ lookup_protocol:
 	np->mcast_hops	= IPV6_DEFAULT_MCASTHOPS;
 	np->mc_loop	= 1;
 	np->pmtudisc	= IPV6_PMTUDISC_WANT;
+	np->autoflowlabel = 1;
 	sk->sk_ipv6only	= net->ipv6.sysctl.bindv6only;
 
 	/* Init the ipv4 part of the socket since we can have sockets
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index a38d3ac..a4a65d8 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -728,7 +728,7 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 	 */
 	ipv6h = ipv6_hdr(skb);
 	ip6_flow_hdr(ipv6h, INET_ECN_encapsulate(0, dsfield),
-		     ip6_make_flowlabel(net, skb, fl6->flowlabel, false));
+		     ip6_make_flowlabel(net, skb, fl6->flowlabel, true));
 	ipv6h->hop_limit = tunnel->parms.hop_limit;
 	ipv6h->nexthdr = proto;
 	ipv6h->saddr = fl6->saddr;
@@ -1182,7 +1182,7 @@ static int ip6gre_header(struct sk_buff *skb, struct net_device *dev,
 
 	ip6_flow_hdr(ipv6h, 0,
 		     ip6_make_flowlabel(dev_net(dev), skb,
-					t->fl.u.ip6.flowlabel, false));
+					t->fl.u.ip6.flowlabel, true));
 	ipv6h->hop_limit = t->parms.hop_limit;
 	ipv6h->nexthdr = NEXTHDR_GRE;
 	ipv6h->saddr = t->parms.laddr;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 2e67b66..2037930 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1095,7 +1095,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	skb_reset_network_header(skb);
 	ipv6h = ipv6_hdr(skb);
 	ip6_flow_hdr(ipv6h, INET_ECN_encapsulate(0, dsfield),
-		     ip6_make_flowlabel(net, skb, fl6->flowlabel, false));
+		     ip6_make_flowlabel(net, skb, fl6->flowlabel, true));
 	ipv6h->hop_limit = t->parms.hop_limit;
 	ipv6h->nexthdr = proto;
 	ipv6h->saddr = fl6->saddr;
-- 
1.8.5.6
