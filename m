From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 08/33] netns ct: pass netns pointer to L4 protocol's ->error hook
Date: Mon,  8 Sep 2008 07:02:45 +0400
Message-ID: <1220842990-30500-8-git-send-email-adobriyan@gmail.com>
References: <48C01046.2070704@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <48C01046.2070704@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Again, it's deducible from skb, but we're going to use it for
nf_conntrack_checksum and statistics, so just pass it from upper layer.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index d4376e9..97723d3 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -50,7 +50,7 @@ struct nf_conntrack_l4proto
 	/* Called when a conntrack entry is destroyed */
 	void (*destroy)(struct nf_conn *ct);
 
-	int (*error)(struct sk_buff *skb, unsigned int dataoff,
+	int (*error)(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 		     enum ip_conntrack_info *ctinfo,
 		     u_int8_t pf, unsigned int hooknum);
 
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index daf3463..8c7ed5b 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -123,7 +123,7 @@ static bool icmp_new(struct nf_conn *ct, const struct sk_buff *skb,
 
 /* Returns conntrack if it dealt with ICMP, and filled in skb fields */
 static int
-icmp_error_message(struct sk_buff *skb,
+icmp_error_message(struct net *net, struct sk_buff *skb,
 		 enum ip_conntrack_info *ctinfo,
 		 unsigned int hooknum)
 {
@@ -155,7 +155,7 @@ icmp_error_message(struct sk_buff *skb,
 
 	*ctinfo = IP_CT_RELATED;
 
-	h = nf_conntrack_find_get(&init_net, &innertuple);
+	h = nf_conntrack_find_get(net, &innertuple);
 	if (!h) {
 		pr_debug("icmp_error_message: no match\n");
 		return -NF_ACCEPT;
@@ -172,7 +172,7 @@ icmp_error_message(struct sk_buff *skb,
 
 /* Small and modified version of icmp_rcv */
 static int
-icmp_error(struct sk_buff *skb, unsigned int dataoff,
+icmp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 	   enum ip_conntrack_info *ctinfo, u_int8_t pf, unsigned int hooknum)
 {
 	const struct icmphdr *icmph;
@@ -217,7 +217,7 @@ icmp_error(struct sk_buff *skb, unsigned int dataoff,
 	    && icmph->type != ICMP_REDIRECT)
 		return NF_ACCEPT;
 
-	return icmp_error_message(skb, ctinfo, hooknum);
+	return icmp_error_message(net, skb, ctinfo, hooknum);
 }
 
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 548cf4f..aabddfe 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -122,7 +122,8 @@ static bool icmpv6_new(struct nf_conn *ct, const struct sk_buff *skb,
 }
 
 static int
-icmpv6_error_message(struct sk_buff *skb,
+icmpv6_error_message(struct net *net,
+		     struct sk_buff *skb,
 		     unsigned int icmp6off,
 		     enum ip_conntrack_info *ctinfo,
 		     unsigned int hooknum)
@@ -156,7 +157,7 @@ icmpv6_error_message(struct sk_buff *skb,
 
 	*ctinfo = IP_CT_RELATED;
 
-	h = nf_conntrack_find_get(&init_net, &intuple);
+	h = nf_conntrack_find_get(net, &intuple);
 	if (!h) {
 		pr_debug("icmpv6_error: no match\n");
 		return -NF_ACCEPT;
@@ -172,7 +173,7 @@ icmpv6_error_message(struct sk_buff *skb,
 }
 
 static int
-icmpv6_error(struct sk_buff *skb, unsigned int dataoff,
+icmpv6_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 	     enum ip_conntrack_info *ctinfo, u_int8_t pf, unsigned int hooknum)
 {
 	const struct icmp6hdr *icmp6h;
@@ -197,7 +198,7 @@ icmpv6_error(struct sk_buff *skb, unsigned int dataoff,
 	if (icmp6h->icmp6_type >= 128)
 		return NF_ACCEPT;
 
-	return icmpv6_error_message(skb, dataoff, ctinfo, hooknum);
+	return icmpv6_error_message(net, skb, dataoff, ctinfo, hooknum);
 }
 
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 5c96d97..251f020 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -703,11 +703,13 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	/* It may be an special packet, error, unclean...
 	 * inverse of the return code tells to the netfilter
 	 * core what to do with the packet. */
-	if (l4proto->error != NULL &&
-	    (ret = l4proto->error(skb, dataoff, &ctinfo, pf, hooknum)) <= 0) {
-		NF_CT_STAT_INC_ATOMIC(error);
-		NF_CT_STAT_INC_ATOMIC(invalid);
-		return -ret;
+	if (l4proto->error != NULL) {
+		ret = l4proto->error(net, skb, dataoff, &ctinfo, pf, hooknum);
+		if (ret <= 0) {
+			NF_CT_STAT_INC_ATOMIC(error);
+			NF_CT_STAT_INC_ATOMIC(invalid);
+			return -ret;
+		}
 	}
 
 	ct = resolve_normal_ct(net, skb, dataoff, pf, protonum,
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index edc3035..6ead8da 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -545,9 +545,9 @@ static int dccp_packet(struct nf_conn *ct, const struct sk_buff *skb,
 	return NF_ACCEPT;
 }
 
-static int dccp_error(struct sk_buff *skb, unsigned int dataoff,
-		      enum ip_conntrack_info *ctinfo, u_int8_t pf,
-		      unsigned int hooknum)
+static int dccp_error(struct net *net, struct sk_buff *skb,
+		      unsigned int dataoff, enum ip_conntrack_info *ctinfo,
+		      u_int8_t pf, unsigned int hooknum)
 {
 	struct dccp_hdr _dh, *dh;
 	unsigned int dccp_len = skb->len - dataoff;
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 539a820..4e71de2 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -746,7 +746,8 @@ static const u8 tcp_valid_flags[(TH_FIN|TH_SYN|TH_RST|TH_ACK|TH_URG) + 1] =
 };
 
 /* Protect conntrack agaist broken packets. Code taken from ipt_unclean.c.  */
-static int tcp_error(struct sk_buff *skb,
+static int tcp_error(struct net *net,
+		     struct sk_buff *skb,
 		     unsigned int dataoff,
 		     enum ip_conntrack_info *ctinfo,
 		     u_int8_t pf,
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 2a965c4..8a245be 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -89,7 +89,7 @@ static bool udp_new(struct nf_conn *ct, const struct sk_buff *skb,
 	return true;
 }
 
-static int udp_error(struct sk_buff *skb, unsigned int dataoff,
+static int udp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 		     enum ip_conntrack_info *ctinfo,
 		     u_int8_t pf,
 		     unsigned int hooknum)
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 4fb6c8d..9817019 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -89,7 +89,9 @@ static bool udplite_new(struct nf_conn *ct, const struct sk_buff *skb,
 	return true;
 }
 
-static int udplite_error(struct sk_buff *skb, unsigned int dataoff,
+static int udplite_error(struct net *net,
+			 struct sk_buff *skb,
+			 unsigned int dataoff,
 			 enum ip_conntrack_info *ctinfo,
 			 u_int8_t pf,
 			 unsigned int hooknum)
