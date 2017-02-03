From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 19/27] netfilter: conntrack: no need to pass ctinfo to error handler
Date: Fri,  3 Feb 2017 13:25:30 +0100
Message-ID: <1486124738-3013-20-git-send-email-pablo@netfilter.org>
References: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58892 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753299AbdBCM2t (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 07:28:49 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id BEE5FC5142
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:42 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id ABCF4DA84C
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:42 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 37282DA7FA
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:40 +0100 (CET)
In-Reply-To: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

It is never accessed for reading and the only places that write to it
are the icmp(6) handlers, which also set skb->nfct (and skb->nfctinfo).

The conntrack core specifically checks for attached skb->nfct after
->error() invocation and returns early in this case.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_l4proto.h   |  2 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   | 12 ++++++------
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c | 12 ++++++------
 net/netfilter/nf_conntrack_core.c              |  3 +--
 net/netfilter/nf_conntrack_proto_dccp.c        |  1 -
 net/netfilter/nf_conntrack_proto_sctp.c        |  2 +-
 net/netfilter/nf_conntrack_proto_tcp.c         |  1 -
 net/netfilter/nf_conntrack_proto_udp.c         |  3 +--
 8 files changed, 16 insertions(+), 20 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index e7b836590f0b..85e993e278d5 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -55,7 +55,7 @@ struct nf_conntrack_l4proto {
 	void (*destroy)(struct nf_conn *ct);
 
 	int (*error)(struct net *net, struct nf_conn *tmpl, struct sk_buff *skb,
-		     unsigned int dataoff, enum ip_conntrack_info *ctinfo,
+		     unsigned int dataoff,
 		     u_int8_t pf, unsigned int hooknum);
 
 	/* Print out the per-protocol part of the tuple. Return like seq_* */
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index d075b3cf2400..566afac98a88 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -128,13 +128,13 @@ static bool icmp_new(struct nf_conn *ct, const struct sk_buff *skb,
 /* Returns conntrack if it dealt with ICMP, and filled in skb fields */
 static int
 icmp_error_message(struct net *net, struct nf_conn *tmpl, struct sk_buff *skb,
-		 enum ip_conntrack_info *ctinfo,
 		 unsigned int hooknum)
 {
 	struct nf_conntrack_tuple innertuple, origtuple;
 	const struct nf_conntrack_l4proto *innerproto;
 	const struct nf_conntrack_tuple_hash *h;
 	const struct nf_conntrack_zone *zone;
+	enum ip_conntrack_info ctinfo;
 	struct nf_conntrack_zone tmp;
 
 	NF_CT_ASSERT(skb->nfct == NULL);
@@ -160,7 +160,7 @@ icmp_error_message(struct net *net, struct nf_conn *tmpl, struct sk_buff *skb,
 		return -NF_ACCEPT;
 	}
 
-	*ctinfo = IP_CT_RELATED;
+	ctinfo = IP_CT_RELATED;
 
 	h = nf_conntrack_find_get(net, zone, &innertuple);
 	if (!h) {
@@ -169,11 +169,11 @@ icmp_error_message(struct net *net, struct nf_conn *tmpl, struct sk_buff *skb,
 	}
 
 	if (NF_CT_DIRECTION(h) == IP_CT_DIR_REPLY)
-		*ctinfo += IP_CT_IS_REPLY;
+		ctinfo += IP_CT_IS_REPLY;
 
 	/* Update skb to refer to this connection */
 	skb->nfct = &nf_ct_tuplehash_to_ctrack(h)->ct_general;
-	skb->nfctinfo = *ctinfo;
+	skb->nfctinfo = ctinfo;
 	return NF_ACCEPT;
 }
 
@@ -181,7 +181,7 @@ icmp_error_message(struct net *net, struct nf_conn *tmpl, struct sk_buff *skb,
 static int
 icmp_error(struct net *net, struct nf_conn *tmpl,
 	   struct sk_buff *skb, unsigned int dataoff,
-	   enum ip_conntrack_info *ctinfo, u_int8_t pf, unsigned int hooknum)
+	   u8 pf, unsigned int hooknum)
 {
 	const struct icmphdr *icmph;
 	struct icmphdr _ih;
@@ -225,7 +225,7 @@ icmp_error(struct net *net, struct nf_conn *tmpl,
 	    icmph->type != ICMP_REDIRECT)
 		return NF_ACCEPT;
 
-	return icmp_error_message(net, tmpl, skb, ctinfo, hooknum);
+	return icmp_error_message(net, tmpl, skb, hooknum);
 }
 
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index f5a61bc3ec2b..44b9af3f813e 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -145,12 +145,12 @@ static int
 icmpv6_error_message(struct net *net, struct nf_conn *tmpl,
 		     struct sk_buff *skb,
 		     unsigned int icmp6off,
-		     enum ip_conntrack_info *ctinfo,
 		     unsigned int hooknum)
 {
 	struct nf_conntrack_tuple intuple, origtuple;
 	const struct nf_conntrack_tuple_hash *h;
 	const struct nf_conntrack_l4proto *inproto;
+	enum ip_conntrack_info ctinfo;
 	struct nf_conntrack_zone tmp;
 
 	NF_CT_ASSERT(skb->nfct == NULL);
@@ -176,7 +176,7 @@ icmpv6_error_message(struct net *net, struct nf_conn *tmpl,
 		return -NF_ACCEPT;
 	}
 
-	*ctinfo = IP_CT_RELATED;
+	ctinfo = IP_CT_RELATED;
 
 	h = nf_conntrack_find_get(net, nf_ct_zone_tmpl(tmpl, skb, &tmp),
 				  &intuple);
@@ -185,19 +185,19 @@ icmpv6_error_message(struct net *net, struct nf_conn *tmpl,
 		return -NF_ACCEPT;
 	} else {
 		if (NF_CT_DIRECTION(h) == IP_CT_DIR_REPLY)
-			*ctinfo += IP_CT_IS_REPLY;
+			ctinfo += IP_CT_IS_REPLY;
 	}
 
 	/* Update skb to refer to this connection */
 	skb->nfct = &nf_ct_tuplehash_to_ctrack(h)->ct_general;
-	skb->nfctinfo = *ctinfo;
+	skb->nfctinfo = ctinfo;
 	return NF_ACCEPT;
 }
 
 static int
 icmpv6_error(struct net *net, struct nf_conn *tmpl,
 	     struct sk_buff *skb, unsigned int dataoff,
-	     enum ip_conntrack_info *ctinfo, u_int8_t pf, unsigned int hooknum)
+	     u8 pf, unsigned int hooknum)
 {
 	const struct icmp6hdr *icmp6h;
 	struct icmp6hdr _ih;
@@ -232,7 +232,7 @@ icmpv6_error(struct net *net, struct nf_conn *tmpl,
 	if (icmp6h->icmp6_type >= 128)
 		return NF_ACCEPT;
 
-	return icmpv6_error_message(net, tmpl, skb, dataoff, ctinfo, hooknum);
+	return icmpv6_error_message(net, tmpl, skb, dataoff, hooknum);
 }
 
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 3a073cd9fcf4..86186a2e2715 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1326,8 +1326,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	 * inverse of the return code tells to the netfilter
 	 * core what to do with the packet. */
 	if (l4proto->error != NULL) {
-		ret = l4proto->error(net, tmpl, skb, dataoff, &ctinfo,
-				     pf, hooknum);
+		ret = l4proto->error(net, tmpl, skb, dataoff, pf, hooknum);
 		if (ret <= 0) {
 			NF_CT_STAT_INC_ATOMIC(net, error);
 			NF_CT_STAT_INC_ATOMIC(net, invalid);
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index b68ce6ac13b3..93dd1c5b7bff 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -561,7 +561,6 @@ static int dccp_packet(struct nf_conn *ct, const struct sk_buff *skb,
 
 static int dccp_error(struct net *net, struct nf_conn *tmpl,
 		      struct sk_buff *skb, unsigned int dataoff,
-		      enum ip_conntrack_info *ctinfo,
 		      u_int8_t pf, unsigned int hooknum)
 {
 	struct dccp_hdr _dh, *dh;
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 44a647418948..33279aab583d 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -508,7 +508,7 @@ static bool sctp_new(struct nf_conn *ct, const struct sk_buff *skb,
 }
 
 static int sctp_error(struct net *net, struct nf_conn *tpl, struct sk_buff *skb,
-		      unsigned int dataoff, enum ip_conntrack_info *ctinfo,
+		      unsigned int dataoff,
 		      u8 pf, unsigned int hooknum)
 {
 	const struct sctphdr *sh;
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 69f687740c76..b122e9dacfed 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -750,7 +750,6 @@ static const u8 tcp_valid_flags[(TCPHDR_FIN|TCPHDR_SYN|TCPHDR_RST|TCPHDR_ACK|
 static int tcp_error(struct net *net, struct nf_conn *tmpl,
 		     struct sk_buff *skb,
 		     unsigned int dataoff,
-		     enum ip_conntrack_info *ctinfo,
 		     u_int8_t pf,
 		     unsigned int hooknum)
 {
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index ae63944c9dc4..f6ebce6178ca 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -112,7 +112,6 @@ static bool udp_new(struct nf_conn *ct, const struct sk_buff *skb,
 static int udplite_error(struct net *net, struct nf_conn *tmpl,
 			 struct sk_buff *skb,
 			 unsigned int dataoff,
-			 enum ip_conntrack_info *ctinfo,
 			 u8 pf, unsigned int hooknum)
 {
 	unsigned int udplen = skb->len - dataoff;
@@ -162,7 +161,7 @@ static int udplite_error(struct net *net, struct nf_conn *tmpl,
 #endif
 
 static int udp_error(struct net *net, struct nf_conn *tmpl, struct sk_buff *skb,
-		     unsigned int dataoff, enum ip_conntrack_info *ctinfo,
+		     unsigned int dataoff,
 		     u_int8_t pf,
 		     unsigned int hooknum)
 {
-- 
2.1.4
