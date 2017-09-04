From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/12] netfilter: remove unused hooknum arg from packet functions
Date: Mon,  4 Sep 2017 22:11:07 +0200
Message-ID: <1504555874-4168-6-git-send-email-pablo@netfilter.org>
References: <1504555874-4168-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1504555874-4168-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

tested with allmodconfig build.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/netfilter/nf_conntrack_l4proto.h   | 1 -
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   | 1 -
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c | 6 ++----
 net/netfilter/nf_conntrack_core.c              | 2 +-
 net/netfilter/nf_conntrack_proto_dccp.c        | 2 +-
 net/netfilter/nf_conntrack_proto_generic.c     | 1 -
 net/netfilter/nf_conntrack_proto_gre.c         | 1 -
 net/netfilter/nf_conntrack_proto_sctp.c        | 1 -
 net/netfilter/nf_conntrack_proto_tcp.c         | 1 -
 net/netfilter/nf_conntrack_proto_udp.c         | 1 -
 10 files changed, 4 insertions(+), 13 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index d4933d56809d..738a0307a96b 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -43,7 +43,6 @@ struct nf_conntrack_l4proto {
 		      unsigned int dataoff,
 		      enum ip_conntrack_info ctinfo,
 		      u_int8_t pf,
-		      unsigned int hooknum,
 		      unsigned int *timeouts);
 
 	/* Called when a new connection for this protocol found;
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 434b4e20f6db..ce108a996316 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -82,7 +82,6 @@ static int icmp_packet(struct nf_conn *ct,
 		       unsigned int dataoff,
 		       enum ip_conntrack_info ctinfo,
 		       u_int8_t pf,
-		       unsigned int hooknum,
 		       unsigned int *timeout)
 {
 	/* Do not immediately delete the connection after the first
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 43544b975eae..30e34c4de003 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -95,7 +95,6 @@ static int icmpv6_packet(struct nf_conn *ct,
 		       unsigned int dataoff,
 		       enum ip_conntrack_info ctinfo,
 		       u_int8_t pf,
-		       unsigned int hooknum,
 		       unsigned int *timeout)
 {
 	/* Do not immediately delete the connection after the first
@@ -129,8 +128,7 @@ static bool icmpv6_new(struct nf_conn *ct, const struct sk_buff *skb,
 static int
 icmpv6_error_message(struct net *net, struct nf_conn *tmpl,
 		     struct sk_buff *skb,
-		     unsigned int icmp6off,
-		     unsigned int hooknum)
+		     unsigned int icmp6off)
 {
 	struct nf_conntrack_tuple intuple, origtuple;
 	const struct nf_conntrack_tuple_hash *h;
@@ -214,7 +212,7 @@ icmpv6_error(struct net *net, struct nf_conn *tmpl,
 	if (icmp6h->icmp6_type >= 128)
 		return NF_ACCEPT;
 
-	return icmpv6_error_message(net, tmpl, skb, dataoff, hooknum);
+	return icmpv6_error_message(net, tmpl, skb, dataoff);
 }
 
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index c23df7c9cd59..ee5555dd7ebc 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1414,7 +1414,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	/* Decide what timeout policy we want to apply to this flow. */
 	timeouts = nf_ct_timeout_lookup(net, ct, l4proto);
 
-	ret = l4proto->packet(ct, skb, dataoff, ctinfo, pf, hooknum, timeouts);
+	ret = l4proto->packet(ct, skb, dataoff, ctinfo, pf, timeouts);
 	if (ret <= 0) {
 		/* Invalid: inverse of the return code tells
 		 * the netfilter core what to do */
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 188347571fc7..0f5a4d79f6b8 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -469,7 +469,7 @@ static unsigned int *dccp_get_timeouts(struct net *net)
 
 static int dccp_packet(struct nf_conn *ct, const struct sk_buff *skb,
 		       unsigned int dataoff, enum ip_conntrack_info ctinfo,
-		       u_int8_t pf, unsigned int hooknum,
+		       u_int8_t pf,
 		       unsigned int *timeouts)
 {
 	struct net *net = nf_ct_net(ct);
diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index 2993995b690d..9cd40700842e 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -61,7 +61,6 @@ static int generic_packet(struct nf_conn *ct,
 			  unsigned int dataoff,
 			  enum ip_conntrack_info ctinfo,
 			  u_int8_t pf,
-			  unsigned int hooknum,
 			  unsigned int *timeout)
 {
 	nf_ct_refresh_acct(ct, ctinfo, skb, *timeout);
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index c0e3a23ac23a..09a90484c27d 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -245,7 +245,6 @@ static int gre_packet(struct nf_conn *ct,
 		      unsigned int dataoff,
 		      enum ip_conntrack_info ctinfo,
 		      u_int8_t pf,
-		      unsigned int hooknum,
 		      unsigned int *timeouts)
 {
 	/* If we've seen traffic both ways, this is a GRE connection.
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 890b5c73368d..6303a88af12b 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -307,7 +307,6 @@ static int sctp_packet(struct nf_conn *ct,
 		       unsigned int dataoff,
 		       enum ip_conntrack_info ctinfo,
 		       u_int8_t pf,
-		       unsigned int hooknum,
 		       unsigned int *timeouts)
 {
 	enum sctp_conntrack new_state, old_state;
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 33c52d9ab2f5..cba1c6ffe51a 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -803,7 +803,6 @@ static int tcp_packet(struct nf_conn *ct,
 		      unsigned int dataoff,
 		      enum ip_conntrack_info ctinfo,
 		      u_int8_t pf,
-		      unsigned int hooknum,
 		      unsigned int *timeouts)
 {
 	struct net *net = nf_ct_net(ct);
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index dcf3030d2226..8af734cd1a94 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -74,7 +74,6 @@ static int udp_packet(struct nf_conn *ct,
 		      unsigned int dataoff,
 		      enum ip_conntrack_info ctinfo,
 		      u_int8_t pf,
-		      unsigned int hooknum,
 		      unsigned int *timeouts)
 {
 	/* If we've seen traffic both ways, this is some kind of UDP
-- 
2.1.4

