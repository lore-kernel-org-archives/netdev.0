From: "I-Dawson, Peter A" <Peter.A.Dawson@boeing.com>
Subject: [PATCH] ip6_tunnel, ip6_gre: fix setting of DSCP on encapsulated
 packets
Date: Thu, 18 May 2017 01:11:01 +0000
Message-ID: <5fba416f3f644db2b1f51e54724ef6ba@XCH15-07-02.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ewa-mbsout-01.mbs.boeing.net ([130.76.20.194]:62361 "EHLO
        ewa-mbsout-01.mbs.boeing.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752971AbdERBLK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 21:11:10 -0400
Received: from XCH15-07-06.nw.nos.boeing.com (xch15-07-06.nw.nos.boeing.com [137.137.100.18])
        by ewa-mbsout-01.mbs.boeing.net (8.14.4/8.14.4/UPSTREAM_MBSOUT) with ESMTP id v4I1B26k062546
        (version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=FAIL)
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 18:11:02 -0700
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fix addresses two problems in the way the DSCP field is formulated on the
 encapsulating header of IPv6 tunnels.
This fix addresses Bug 195661. https://bugzilla.kernel.org/show_bug.cgi?id=195661 

1) The IPv6 tunneling code was manipulating the DSCP field of the encapsulating
 packet using the 32b flowlabel. Since the flowlabel is only the lower 20b it
 was incorrect to assume that the upper 12b containing the DSCP and ECN fields
 would remain intact when formulating the encapsulating header. This fix
 handles the 'inherit' and 'fixed-value' DSCP cases explicitly using the extant
 dsfield u8 variable.

2) The use of INET_ECN_encapsulate(0, dsfield) in ip6_tnl_xmit was incorrect
 and resulted in the DSCP value always being set to 0.
---
 net/ipv6/ip6_gre.c    | 18 ++++++++++--------
 net/ipv6/ip6_tunnel.c | 28 +++++++++++++++++-----------
 2 files changed, 27 insertions(+), 19 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 8d128ba..42f51fe 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -537,11 +537,11 @@ static inline int ip6gre_xmit_ipv4(struct sk_buff *skb, struct net_device *dev)
 
 	memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
 
-	dsfield = ipv4_get_dsfield(iph);
-
-	if (t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS)
-		fl6.flowlabel |= htonl((__u32)iph->tos << IPV6_TCLASS_SHIFT)
-					  & IPV6_TCLASS_MASK;
+	if (t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS) {
+		dsfield = ipv4_get_dsfield(iph);
+	} else {
+		dsfield = ip6_tclass(t->parms.flowinfo);
+	}
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
 		fl6.flowi6_mark = skb->mark;
 	else
@@ -598,9 +598,11 @@ static inline int ip6gre_xmit_ipv6(struct sk_buff *skb, struct net_device *dev)
 
 	memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
 
-	dsfield = ipv6_get_dsfield(ipv6h);
-	if (t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS)
-		fl6.flowlabel |= (*(__be32 *) ipv6h & IPV6_TCLASS_MASK);
+	if (t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS) {
+		dsfield = ipv6_get_dsfield(ipv6h);
+	} else {
+		dsfield = ip6_tclass(t->parms.flowinfo);
+        }
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_FLOWLABEL)
 		fl6.flowlabel |= ip6_flowlabel(ipv6h);
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 6eb2ae5..4d45195 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1196,8 +1196,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 	skb_push(skb, sizeof(struct ipv6hdr));
 	skb_reset_network_header(skb);
 	ipv6h = ipv6_hdr(skb);
-	ip6_flow_hdr(ipv6h, INET_ECN_encapsulate(0, dsfield),
-		     ip6_make_flowlabel(net, skb, fl6->flowlabel, true, fl6));
+	ip6_flow_hdr(ipv6h, dsfield, ip6_make_flowlabel(net, skb, fl6->flowlabel, true, fl6));
 	ipv6h->hop_limit = hop_limit;
 	ipv6h->nexthdr = proto;
 	ipv6h->saddr = fl6->saddr;
@@ -1231,8 +1230,6 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (tproto != IPPROTO_IPIP && tproto != 0)
 		return -1;
 
-	dsfield = ipv4_get_dsfield(iph);
-
 	if (t->parms.collect_md) {
 		struct ip_tunnel_info *tun_info;
 		const struct ip_tunnel_key *key;
@@ -1246,6 +1243,7 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 		fl6.flowi6_proto = IPPROTO_IPIP;
 		fl6.daddr = key->u.ipv6.dst;
 		fl6.flowlabel = key->label;
+		dsfield = ip6_tclass(key->label);
 	} else {
 		if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
 			encap_limit = t->parms.encap_limit;
@@ -1253,9 +1251,11 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 		memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
 		fl6.flowi6_proto = IPPROTO_IPIP;
 
-		if (t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS)
-			fl6.flowlabel |= htonl((__u32)iph->tos << IPV6_TCLASS_SHIFT)
-					 & IPV6_TCLASS_MASK;
+		if (t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS) {
+			dsfield = ipv4_get_dsfield(iph);
+		} else {
+			dsfield = ip6_tclass(t->parms.flowinfo);
+		}
 		if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
 			fl6.flowi6_mark = skb->mark;
 		else
@@ -1267,6 +1267,8 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (iptunnel_handle_offloads(skb, SKB_GSO_IPXIP6))
 		return -1;
 
+	dsfield = INET_ECN_encapsulate(dsfield, ipv4_get_dsfield(iph));
+
 	skb_set_inner_ipproto(skb, IPPROTO_IPIP);
 
 	err = ip6_tnl_xmit(skb, dev, dsfield, &fl6, encap_limit, &mtu,
@@ -1300,8 +1302,6 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	    ip6_tnl_addr_conflict(t, ipv6h))
 		return -1;
 
-	dsfield = ipv6_get_dsfield(ipv6h);
-
 	if (t->parms.collect_md) {
 		struct ip_tunnel_info *tun_info;
 		const struct ip_tunnel_key *key;
@@ -1315,6 +1315,7 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 		fl6.flowi6_proto = IPPROTO_IPV6;
 		fl6.daddr = key->u.ipv6.dst;
 		fl6.flowlabel = key->label;
+		dsfield = ip6_tclass(key->label);
 	} else {
 		offset = ip6_tnl_parse_tlv_enc_lim(skb, skb_network_header(skb));
 		/* ip6_tnl_parse_tlv_enc_lim() might have reallocated skb->head */
@@ -1336,8 +1337,11 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 		memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
 		fl6.flowi6_proto = IPPROTO_IPV6;
 
-		if (t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS)
-			fl6.flowlabel |= (*(__be32 *)ipv6h & IPV6_TCLASS_MASK);
+		if (t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS) {
+			dsfield = ipv6_get_dsfield(ipv6h);
+		} else {
+			dsfield = ip6_tclass(t->parms.flowinfo);
+                }
 		if (t->parms.flags & IP6_TNL_F_USE_ORIG_FLOWLABEL)
 			fl6.flowlabel |= ip6_flowlabel(ipv6h);
 		if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
@@ -1351,6 +1355,8 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (iptunnel_handle_offloads(skb, SKB_GSO_IPXIP6))
 		return -1;
 
+        dsfield = INET_ECN_encapsulate(dsfield, ipv6_get_dsfield(ipv6h));
+
 	skb_set_inner_ipproto(skb, IPPROTO_IPV6);
 
 	err = ip6_tnl_xmit(skb, dev, dsfield, &fl6, encap_limit, &mtu,
