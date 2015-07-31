From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 2/5] ipv6: Call skb_get_hash_flowi6 to get skb->hash in ip6_make_flowlabel
Date: Fri, 31 Jul 2015 16:52:11 -0700
Message-ID: <1438386734-1942188-3-git-send-email-tom@herbertland.com>
References: <1438386734-1942188-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:17504 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752531AbbGaX6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 19:58:39 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6VNwbqO018059
	for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 16:58:38 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1w0hd9gdpx-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 16:58:38 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 aa9aa8fa37df11e5bd8d0002c99293a0-397ec2b0 for <netdev@vger.kernel.org>;	Fri,
 31 Jul 2015 16:55:48 -0700
In-Reply-To: <1438386734-1942188-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can't call skb_get_hash here since the packet is not complete to do
flow_dissector. Create hash based on flowi6 instead.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/ipv6.h    | 5 +++--
 net/ipv6/ip6_gre.c    | 5 +++--
 net/ipv6/ip6_output.c | 4 ++--
 net/ipv6/ip6_tunnel.c | 2 +-
 4 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 7c79798..d6bf7f1 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -708,12 +708,13 @@ static inline void iph_to_flow_copy_v6addrs(struct flow_keys *flow,
 
 #if IS_ENABLED(CONFIG_IPV6)
 static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
-					__be32 flowlabel, bool autolabel)
+					__be32 flowlabel, bool autolabel,
+					struct flowi6 *fl6)
 {
 	if (!flowlabel && (autolabel || net->ipv6.sysctl.auto_flowlabels)) {
 		u32 hash;
 
-		hash = skb_get_hash(skb);
+		hash = skb_get_hash_flowi6(skb, fl6);
 
 		/* Since this is being sent on the wire obfuscate hash a bit
 		 * to minimize possbility that any useful information to an
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index a38d3ac..a7d1ca2 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -728,7 +728,7 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 	 */
 	ipv6h = ipv6_hdr(skb);
 	ip6_flow_hdr(ipv6h, INET_ECN_encapsulate(0, dsfield),
-		     ip6_make_flowlabel(net, skb, fl6->flowlabel, false));
+		     ip6_make_flowlabel(net, skb, fl6->flowlabel, false, fl6));
 	ipv6h->hop_limit = tunnel->parms.hop_limit;
 	ipv6h->nexthdr = proto;
 	ipv6h->saddr = fl6->saddr;
@@ -1182,7 +1182,8 @@ static int ip6gre_header(struct sk_buff *skb, struct net_device *dev,
 
 	ip6_flow_hdr(ipv6h, 0,
 		     ip6_make_flowlabel(dev_net(dev), skb,
-					t->fl.u.ip6.flowlabel, false));
+					t->fl.u.ip6.flowlabel, false,
+					&t->fl.u.ip6));
 	ipv6h->hop_limit = t->parms.hop_limit;
 	ipv6h->nexthdr = NEXTHDR_GRE;
 	ipv6h->saddr = t->parms.laddr;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index c5fc852..5f512b8 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -207,7 +207,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 		hlimit = ip6_dst_hoplimit(dst);
 
 	ip6_flow_hdr(hdr, tclass, ip6_make_flowlabel(net, skb, fl6->flowlabel,
-						     np->autoflowlabel));
+						     np->autoflowlabel, fl6));
 
 	hdr->payload_len = htons(seg_len);
 	hdr->nexthdr = proto;
@@ -1649,7 +1649,7 @@ struct sk_buff *__ip6_make_skb(struct sock *sk,
 
 	ip6_flow_hdr(hdr, v6_cork->tclass,
 		     ip6_make_flowlabel(net, skb, fl6->flowlabel,
-					np->autoflowlabel));
+					np->autoflowlabel, fl6));
 	hdr->hop_limit = v6_cork->hop_limit;
 	hdr->nexthdr = proto;
 	hdr->saddr = fl6->saddr;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 2e67b66..54e694c 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1095,7 +1095,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	skb_reset_network_header(skb);
 	ipv6h = ipv6_hdr(skb);
 	ip6_flow_hdr(ipv6h, INET_ECN_encapsulate(0, dsfield),
-		     ip6_make_flowlabel(net, skb, fl6->flowlabel, false));
+		     ip6_make_flowlabel(net, skb, fl6->flowlabel, false, fl6));
 	ipv6h->hop_limit = t->parms.hop_limit;
 	ipv6h->nexthdr = proto;
 	ipv6h->saddr = fl6->saddr;
-- 
1.8.5.6
