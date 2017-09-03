From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 36/47] netfilter: conntrack: place print_tuple in procfs part
Date: Mon,  4 Sep 2017 00:42:43 +0200
Message-ID: <1504478574-13281-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

CONFIG_NF_CONNTRACK_PROCFS is deprecated, no need to use a function
pointer in the trackers for this. Place the printf formatting in
the one place that uses it.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_l3proto.h   |  4 --
 include/net/netfilter/nf_conntrack_l4proto.h   |  4 --
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  8 ----
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   | 11 -----
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |  8 ----
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c | 11 -----
 net/netfilter/nf_conntrack_l3proto_generic.c   |  6 ---
 net/netfilter/nf_conntrack_proto_dccp.c        | 10 -----
 net/netfilter/nf_conntrack_proto_generic.c     |  7 ----
 net/netfilter/nf_conntrack_proto_gre.c         | 10 -----
 net/netfilter/nf_conntrack_proto_sctp.c        | 11 -----
 net/netfilter/nf_conntrack_proto_tcp.c         | 11 -----
 net/netfilter/nf_conntrack_proto_udp.c         | 13 ------
 net/netfilter/nf_conntrack_standalone.c        | 58 +++++++++++++++++++++++++-
 14 files changed, 56 insertions(+), 116 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/net/netfilter/nf_conntrack_l3proto.h
index e31861e4fa6a..dabb53b0913c 100644
--- a/include/net/netfilter/nf_conntrack_l3proto.h
+++ b/include/net/netfilter/nf_conntrack_l3proto.h
@@ -37,10 +37,6 @@ struct nf_conntrack_l3proto {
 	bool (*invert_tuple)(struct nf_conntrack_tuple *inverse,
 			     const struct nf_conntrack_tuple *orig);
 
-	/* Print out the per-protocol part of the tuple. */
-	void (*print_tuple)(struct seq_file *s,
-			    const struct nf_conntrack_tuple *);
-
 	/*
 	 * Called before tracking. 
 	 *	*dataoff: offset of protocol header (TCP, UDP,...) in skb
diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index 15c58dd3f701..7e8da04a5eb6 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -61,10 +61,6 @@ struct nf_conntrack_l4proto {
 	/* called by gc worker if table is full */
 	bool (*can_early_drop)(const struct nf_conn *ct);
 
-	/* Print out the per-protocol part of the tuple. Return like seq_* */
-	void (*print_tuple)(struct seq_file *s,
-			    const struct nf_conntrack_tuple *);
-
 	/* Print out the private part of the conntrack. */
 	void (*print_conntrack)(struct seq_file *s, struct nf_conn *);
 
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 9f7ea862068c..fe374da4bc13 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -63,13 +63,6 @@ static bool ipv4_invert_tuple(struct nf_conntrack_tuple *tuple,
 	return true;
 }
 
-static void ipv4_print_tuple(struct seq_file *s,
-			    const struct nf_conntrack_tuple *tuple)
-{
-	seq_printf(s, "src=%pI4 dst=%pI4 ",
-		   &tuple->src.u3.ip, &tuple->dst.u3.ip);
-}
-
 static int ipv4_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
 			    unsigned int *dataoff, u_int8_t *protonum)
 {
@@ -355,7 +348,6 @@ struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv4 __read_mostly = {
 	.l3proto	 = PF_INET,
 	.pkt_to_tuple	 = ipv4_pkt_to_tuple,
 	.invert_tuple	 = ipv4_invert_tuple,
-	.print_tuple	 = ipv4_print_tuple,
 	.get_l4proto	 = ipv4_get_l4proto,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.tuple_to_nlattr = ipv4_tuple_to_nlattr,
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index fdbeb03e4600..434b4e20f6db 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -71,16 +71,6 @@ static bool icmp_invert_tuple(struct nf_conntrack_tuple *tuple,
 	return true;
 }
 
-/* Print out the per-protocol part of the tuple. */
-static void icmp_print_tuple(struct seq_file *s,
-			    const struct nf_conntrack_tuple *tuple)
-{
-	seq_printf(s, "type=%u code=%u id=%u ",
-		   tuple->dst.u.icmp.type,
-		   tuple->dst.u.icmp.code,
-		   ntohs(tuple->src.u.icmp.id));
-}
-
 static unsigned int *icmp_get_timeouts(struct net *net)
 {
 	return &icmp_pernet(net)->timeout;
@@ -364,7 +354,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_icmp __read_mostly =
 	.l4proto		= IPPROTO_ICMP,
 	.pkt_to_tuple		= icmp_pkt_to_tuple,
 	.invert_tuple		= icmp_invert_tuple,
-	.print_tuple		= icmp_print_tuple,
 	.packet			= icmp_packet,
 	.get_timeouts		= icmp_get_timeouts,
 	.new			= icmp_new,
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 91d37fbe28de..fe01dc953c56 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -67,13 +67,6 @@ static bool ipv6_invert_tuple(struct nf_conntrack_tuple *tuple,
 	return true;
 }
 
-static void ipv6_print_tuple(struct seq_file *s,
-			    const struct nf_conntrack_tuple *tuple)
-{
-	seq_printf(s, "src=%pI6 dst=%pI6 ",
-		   tuple->src.u3.ip6, tuple->dst.u3.ip6);
-}
-
 static int ipv6_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
 			    unsigned int *dataoff, u_int8_t *protonum)
 {
@@ -350,7 +343,6 @@ struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv6 __read_mostly = {
 	.l3proto		= PF_INET6,
 	.pkt_to_tuple		= ipv6_pkt_to_tuple,
 	.invert_tuple		= ipv6_invert_tuple,
-	.print_tuple		= ipv6_print_tuple,
 	.get_l4proto		= ipv6_get_l4proto,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.tuple_to_nlattr	= ipv6_tuple_to_nlattr,
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 805ab122767a..808f63e2e1ff 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -84,16 +84,6 @@ static bool icmpv6_invert_tuple(struct nf_conntrack_tuple *tuple,
 	return true;
 }
 
-/* Print out the per-protocol part of the tuple. */
-static void icmpv6_print_tuple(struct seq_file *s,
-			      const struct nf_conntrack_tuple *tuple)
-{
-	seq_printf(s, "type=%u code=%u id=%u ",
-		   tuple->dst.u.icmp.type,
-		   tuple->dst.u.icmp.code,
-		   ntohs(tuple->src.u.icmp.id));
-}
-
 static unsigned int *icmpv6_get_timeouts(struct net *net)
 {
 	return &icmpv6_pernet(net)->timeout;
@@ -369,7 +359,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_icmpv6 __read_mostly =
 	.l4proto		= IPPROTO_ICMPV6,
 	.pkt_to_tuple		= icmpv6_pkt_to_tuple,
 	.invert_tuple		= icmpv6_invert_tuple,
-	.print_tuple		= icmpv6_print_tuple,
 	.packet			= icmpv6_packet,
 	.get_timeouts		= icmpv6_get_timeouts,
 	.new			= icmpv6_new,
diff --git a/net/netfilter/nf_conntrack_l3proto_generic.c b/net/netfilter/nf_conntrack_l3proto_generic.c
index 0387971582bc..397e6911214f 100644
--- a/net/netfilter/nf_conntrack_l3proto_generic.c
+++ b/net/netfilter/nf_conntrack_l3proto_generic.c
@@ -49,11 +49,6 @@ static bool generic_invert_tuple(struct nf_conntrack_tuple *tuple,
 	return true;
 }
 
-static void generic_print_tuple(struct seq_file *s,
-				const struct nf_conntrack_tuple *tuple)
-{
-}
-
 static int generic_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
 			       unsigned int *dataoff, u_int8_t *protonum)
 {
@@ -66,7 +61,6 @@ struct nf_conntrack_l3proto nf_conntrack_l3proto_generic __read_mostly = {
 	.l3proto	 = PF_UNSPEC,
 	.pkt_to_tuple	 = generic_pkt_to_tuple,
 	.invert_tuple	 = generic_invert_tuple,
-	.print_tuple	 = generic_print_tuple,
 	.get_l4proto	 = generic_get_l4proto,
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_generic);
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index a0492184a0a8..d2df49ac390a 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -623,14 +623,6 @@ static bool dccp_can_early_drop(const struct nf_conn *ct)
 	return false;
 }
 
-static void dccp_print_tuple(struct seq_file *s,
-			     const struct nf_conntrack_tuple *tuple)
-{
-	seq_printf(s, "sport=%hu dport=%hu ",
-		   ntohs(tuple->src.u.dccp.port),
-		   ntohs(tuple->dst.u.dccp.port));
-}
-
 static void dccp_print_conntrack(struct seq_file *s, struct nf_conn *ct)
 {
 	seq_printf(s, "%s ", dccp_state_names[ct->proto.dccp.state]);
@@ -887,7 +879,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_dccp4 __read_mostly = {
 	.get_timeouts		= dccp_get_timeouts,
 	.error			= dccp_error,
 	.can_early_drop		= dccp_can_early_drop,
-	.print_tuple		= dccp_print_tuple,
 	.print_conntrack	= dccp_print_conntrack,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.to_nlattr		= dccp_to_nlattr,
@@ -922,7 +913,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_dccp6 __read_mostly = {
 	.get_timeouts		= dccp_get_timeouts,
 	.error			= dccp_error,
 	.can_early_drop		= dccp_can_early_drop,
-	.print_tuple		= dccp_print_tuple,
 	.print_conntrack	= dccp_print_conntrack,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.to_nlattr		= dccp_to_nlattr,
diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index 4fe8b3312823..2bc3d0c1a5bf 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -62,12 +62,6 @@ static bool generic_invert_tuple(struct nf_conntrack_tuple *tuple,
 	return true;
 }
 
-/* Print out the per-protocol part of the tuple. */
-static void generic_print_tuple(struct seq_file *s,
-				const struct nf_conntrack_tuple *tuple)
-{
-}
-
 static unsigned int *generic_get_timeouts(struct net *net)
 {
 	return &(generic_pernet(net)->timeout);
@@ -189,7 +183,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_generic __read_mostly =
 	.l4proto		= 255,
 	.pkt_to_tuple		= generic_pkt_to_tuple,
 	.invert_tuple		= generic_invert_tuple,
-	.print_tuple		= generic_print_tuple,
 	.packet			= generic_packet,
 	.get_timeouts		= generic_get_timeouts,
 	.new			= generic_new,
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index 984bcfdbd4d7..cd28095dd7a4 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -224,15 +224,6 @@ static bool gre_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
 	return true;
 }
 
-/* print gre part of tuple */
-static void gre_print_tuple(struct seq_file *s,
-			    const struct nf_conntrack_tuple *tuple)
-{
-	seq_printf(s, "srckey=0x%x dstkey=0x%x ",
-		   ntohs(tuple->src.u.gre.key),
-		   ntohs(tuple->dst.u.gre.key));
-}
-
 /* print private data for conntrack */
 static void gre_print_conntrack(struct seq_file *s, struct nf_conn *ct)
 {
@@ -366,7 +357,6 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_gre4 __read_mostly = {
 	.l4proto	 = IPPROTO_GRE,
 	.pkt_to_tuple	 = gre_pkt_to_tuple,
 	.invert_tuple	 = gre_invert_tuple,
-	.print_tuple	 = gre_print_tuple,
 	.print_conntrack = gre_print_conntrack,
 	.get_timeouts    = gre_get_timeouts,
 	.packet		 = gre_packet,
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 1d7a995ea049..da83b401be17 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -174,15 +174,6 @@ static bool sctp_invert_tuple(struct nf_conntrack_tuple *tuple,
 	return true;
 }
 
-/* Print out the per-protocol part of the tuple. */
-static void sctp_print_tuple(struct seq_file *s,
-			     const struct nf_conntrack_tuple *tuple)
-{
-	seq_printf(s, "sport=%hu dport=%hu ",
-		   ntohs(tuple->src.u.sctp.port),
-		   ntohs(tuple->dst.u.sctp.port));
-}
-
 /* Print out the private part of the conntrack. */
 static void sctp_print_conntrack(struct seq_file *s, struct nf_conn *ct)
 {
@@ -793,7 +784,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp4 __read_mostly = {
 	.l4proto 		= IPPROTO_SCTP,
 	.pkt_to_tuple 		= sctp_pkt_to_tuple,
 	.invert_tuple 		= sctp_invert_tuple,
-	.print_tuple 		= sctp_print_tuple,
 	.print_conntrack	= sctp_print_conntrack,
 	.packet 		= sctp_packet,
 	.get_timeouts		= sctp_get_timeouts,
@@ -829,7 +819,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6 __read_mostly = {
 	.l4proto 		= IPPROTO_SCTP,
 	.pkt_to_tuple 		= sctp_pkt_to_tuple,
 	.invert_tuple 		= sctp_invert_tuple,
-	.print_tuple 		= sctp_print_tuple,
 	.print_conntrack	= sctp_print_conntrack,
 	.packet 		= sctp_packet,
 	.get_timeouts		= sctp_get_timeouts,
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index e3e59e3d0592..c868b36b8945 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -301,15 +301,6 @@ static bool tcp_invert_tuple(struct nf_conntrack_tuple *tuple,
 	return true;
 }
 
-/* Print out the per-protocol part of the tuple. */
-static void tcp_print_tuple(struct seq_file *s,
-			    const struct nf_conntrack_tuple *tuple)
-{
-	seq_printf(s, "sport=%hu dport=%hu ",
-		   ntohs(tuple->src.u.tcp.port),
-		   ntohs(tuple->dst.u.tcp.port));
-}
-
 /* Print out the private part of the conntrack. */
 static void tcp_print_conntrack(struct seq_file *s, struct nf_conn *ct)
 {
@@ -1558,7 +1549,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp4 __read_mostly =
 	.l4proto 		= IPPROTO_TCP,
 	.pkt_to_tuple 		= tcp_pkt_to_tuple,
 	.invert_tuple 		= tcp_invert_tuple,
-	.print_tuple 		= tcp_print_tuple,
 	.print_conntrack 	= tcp_print_conntrack,
 	.packet 		= tcp_packet,
 	.get_timeouts		= tcp_get_timeouts,
@@ -1595,7 +1585,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp6 __read_mostly =
 	.l4proto 		= IPPROTO_TCP,
 	.pkt_to_tuple 		= tcp_pkt_to_tuple,
 	.invert_tuple 		= tcp_invert_tuple,
-	.print_tuple 		= tcp_print_tuple,
 	.print_conntrack 	= tcp_print_conntrack,
 	.packet 		= tcp_packet,
 	.get_timeouts		= tcp_get_timeouts,
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index ec861a1169f1..dcf3030d2226 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -63,15 +63,6 @@ static bool udp_invert_tuple(struct nf_conntrack_tuple *tuple,
 	return true;
 }
 
-/* Print out the per-protocol part of the tuple. */
-static void udp_print_tuple(struct seq_file *s,
-			    const struct nf_conntrack_tuple *tuple)
-{
-	seq_printf(s, "sport=%hu dport=%hu ",
-		   ntohs(tuple->src.u.udp.port),
-		   ntohs(tuple->dst.u.udp.port));
-}
-
 static unsigned int *udp_get_timeouts(struct net *net)
 {
 	return udp_pernet(net)->timeouts;
@@ -316,7 +307,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp4 __read_mostly =
 	.allow_clash		= true,
 	.pkt_to_tuple		= udp_pkt_to_tuple,
 	.invert_tuple		= udp_invert_tuple,
-	.print_tuple		= udp_print_tuple,
 	.packet			= udp_packet,
 	.get_timeouts		= udp_get_timeouts,
 	.new			= udp_new,
@@ -349,7 +339,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite4 __read_mostly =
 	.allow_clash		= true,
 	.pkt_to_tuple		= udp_pkt_to_tuple,
 	.invert_tuple		= udp_invert_tuple,
-	.print_tuple		= udp_print_tuple,
 	.packet			= udp_packet,
 	.get_timeouts		= udp_get_timeouts,
 	.new			= udp_new,
@@ -382,7 +371,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp6 __read_mostly =
 	.allow_clash		= true,
 	.pkt_to_tuple		= udp_pkt_to_tuple,
 	.invert_tuple		= udp_invert_tuple,
-	.print_tuple		= udp_print_tuple,
 	.packet			= udp_packet,
 	.get_timeouts		= udp_get_timeouts,
 	.new			= udp_new,
@@ -415,7 +403,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite6 __read_mostly =
 	.allow_clash		= true,
 	.pkt_to_tuple		= udp_pkt_to_tuple,
 	.invert_tuple		= udp_invert_tuple,
-	.print_tuple		= udp_print_tuple,
 	.packet			= udp_packet,
 	.get_timeouts		= udp_get_timeouts,
 	.new			= udp_new,
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index b28f9e93f574..9eb85858d764 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -41,8 +41,62 @@ print_tuple(struct seq_file *s, const struct nf_conntrack_tuple *tuple,
             const struct nf_conntrack_l3proto *l3proto,
             const struct nf_conntrack_l4proto *l4proto)
 {
-	l3proto->print_tuple(s, tuple);
-	l4proto->print_tuple(s, tuple);
+	switch (l3proto->l3proto) {
+	case NFPROTO_IPV4:
+		seq_printf(s, "src=%pI4 dst=%pI4 ",
+			   &tuple->src.u3.ip, &tuple->dst.u3.ip);
+		break;
+	case NFPROTO_IPV6:
+		seq_printf(s, "src=%pI6 dst=%pI6 ",
+			   tuple->src.u3.ip6, tuple->dst.u3.ip6);
+		break;
+	default:
+		break;
+	}
+
+	switch (l4proto->l4proto) {
+	case IPPROTO_ICMP:
+		seq_printf(s, "type=%u code=%u id=%u ",
+			   tuple->dst.u.icmp.type,
+			   tuple->dst.u.icmp.code,
+			   ntohs(tuple->src.u.icmp.id));
+		break;
+	case IPPROTO_TCP:
+		seq_printf(s, "sport=%hu dport=%hu ",
+			   ntohs(tuple->src.u.tcp.port),
+			   ntohs(tuple->dst.u.tcp.port));
+		break;
+	case IPPROTO_UDPLITE: /* fallthrough */
+	case IPPROTO_UDP:
+		seq_printf(s, "sport=%hu dport=%hu ",
+			   ntohs(tuple->src.u.udp.port),
+			   ntohs(tuple->dst.u.udp.port));
+
+		break;
+	case IPPROTO_DCCP:
+		seq_printf(s, "sport=%hu dport=%hu ",
+			   ntohs(tuple->src.u.dccp.port),
+			   ntohs(tuple->dst.u.dccp.port));
+		break;
+	case IPPROTO_SCTP:
+		seq_printf(s, "sport=%hu dport=%hu ",
+			   ntohs(tuple->src.u.sctp.port),
+			   ntohs(tuple->dst.u.sctp.port));
+		break;
+	case IPPROTO_ICMPV6:
+		seq_printf(s, "type=%u code=%u id=%u ",
+			   tuple->dst.u.icmp.type,
+			   tuple->dst.u.icmp.code,
+			   ntohs(tuple->src.u.icmp.id));
+		break;
+	case IPPROTO_GRE:
+		seq_printf(s, "srckey=0x%x dstkey=0x%x ",
+			   ntohs(tuple->src.u.gre.key),
+			   ntohs(tuple->dst.u.gre.key));
+		break;
+	default:
+		break;
+	}
 }
 EXPORT_SYMBOL_GPL(print_tuple);
 
-- 
2.1.4


