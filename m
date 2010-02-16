From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 57/62: nf_conntrack: pass template to l4proto ->error() handler
Date: Tue, 16 Feb 2010 15:56:37 +0100 (MET)
Message-ID: <20100216145634.2796.30407.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 8fea97ec1772bbf553d89187340ef624d548e115
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Feb 15 17:45:08 2010 +0100

    netfilter: nf_conntrack: pass template to l4proto ->error() handler
    
    The error handlers might need the template to get the conntrack zone
    introduced in the next patches to perform a conntrack lookup.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index ca6dcf3..e3d3ee3 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -49,8 +49,8 @@ struct nf_conntrack_l4proto {
 	/* Called when a conntrack entry is destroyed */
 	void (*destroy)(struct nf_conn *ct);
 
-	int (*error)(struct net *net, struct sk_buff *skb, unsigned int dataoff,
-		     enum ip_conntrack_info *ctinfo,
+	int (*error)(struct net *net, struct nf_conn *tmpl, struct sk_buff *skb,
+		     unsigned int dataoff, enum ip_conntrack_info *ctinfo,
 		     u_int8_t pf, unsigned int hooknum);
 
 	/* Print out the per-protocol part of the tuple. Return like seq_* */
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 7afd39b..327826a 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -163,7 +163,8 @@ icmp_error_message(struct net *net, struct sk_buff *skb,
 
 /* Small and modified version of icmp_rcv */
 static int
-icmp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
+icmp_error(struct net *net, struct nf_conn *tmpl,
+	   struct sk_buff *skb, unsigned int dataoff,
 	   enum ip_conntrack_info *ctinfo, u_int8_t pf, unsigned int hooknum)
 {
 	const struct icmphdr *icmph;
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index c7b8bd1..d772dc2 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -179,7 +179,8 @@ icmpv6_error_message(struct net *net,
 }
 
 static int
-icmpv6_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
+icmpv6_error(struct net *net, struct nf_conn *tmpl,
+	     struct sk_buff *skb, unsigned int dataoff,
 	     enum ip_conntrack_info *ctinfo, u_int8_t pf, unsigned int hooknum)
 {
 	const struct icmp6hdr *icmp6h;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index bd83141..65351ed 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -799,7 +799,8 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	 * inverse of the return code tells to the netfilter
 	 * core what to do with the packet. */
 	if (l4proto->error != NULL) {
-		ret = l4proto->error(net, skb, dataoff, &ctinfo, pf, hooknum);
+		ret = l4proto->error(net, tmpl, skb, dataoff, &ctinfo,
+				     pf, hooknum);
 		if (ret <= 0) {
 			NF_CT_STAT_INC_ATOMIC(net, error);
 			NF_CT_STAT_INC_ATOMIC(net, invalid);
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index dd37550..9a28155 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -561,8 +561,9 @@ static int dccp_packet(struct nf_conn *ct, const struct sk_buff *skb,
 	return NF_ACCEPT;
 }
 
-static int dccp_error(struct net *net, struct sk_buff *skb,
-		      unsigned int dataoff, enum ip_conntrack_info *ctinfo,
+static int dccp_error(struct net *net, struct nf_conn *tmpl,
+		      struct sk_buff *skb, unsigned int dataoff,
+		      enum ip_conntrack_info *ctinfo,
 		      u_int8_t pf, unsigned int hooknum)
 {
 	struct dccp_hdr _dh, *dh;
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index ad11805..9dd8cd4 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -760,7 +760,7 @@ static const u8 tcp_valid_flags[(TH_FIN|TH_SYN|TH_RST|TH_ACK|TH_URG) + 1] =
 };
 
 /* Protect conntrack agaist broken packets. Code taken from ipt_unclean.c.  */
-static int tcp_error(struct net *net,
+static int tcp_error(struct net *net, struct nf_conn *tmpl,
 		     struct sk_buff *skb,
 		     unsigned int dataoff,
 		     enum ip_conntrack_info *ctinfo,
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 8d38f9a..8289088 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -91,8 +91,8 @@ static bool udp_new(struct nf_conn *ct, const struct sk_buff *skb,
 	return true;
 }
 
-static int udp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
-		     enum ip_conntrack_info *ctinfo,
+static int udp_error(struct net *net, struct nf_conn *tmpl, struct sk_buff *skb,
+		     unsigned int dataoff, enum ip_conntrack_info *ctinfo,
 		     u_int8_t pf,
 		     unsigned int hooknum)
 {
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 0b1bc9b..263b5a7 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -89,7 +89,7 @@ static bool udplite_new(struct nf_conn *ct, const struct sk_buff *skb,
 	return true;
 }
 
-static int udplite_error(struct net *net,
+static int udplite_error(struct net *net, struct nf_conn *tmpl,
 			 struct sk_buff *skb,
 			 unsigned int dataoff,
 			 enum ip_conntrack_info *ctinfo,
