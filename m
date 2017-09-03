From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 37/47] netfilter: conntrack: print_conntrack only needed if CONFIG_NF_CONNTRACK_PROCFS
Date: Mon,  4 Sep 2017 00:42:44 +0200
Message-ID: <1504478574-13281-2-git-send-email-pablo@netfilter.org>
References: <1504478574-13281-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1504478574-13281-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_l4proto.h | 7 ++++---
 net/netfilter/nf_conntrack_proto_dccp.c      | 6 ++++++
 net/netfilter/nf_conntrack_proto_gre.c       | 4 ++++
 net/netfilter/nf_conntrack_proto_sctp.c      | 6 ++++++
 net/netfilter/nf_conntrack_proto_tcp.c       | 6 ++++++
 5 files changed, 26 insertions(+), 3 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index 7e8da04a5eb6..4976ef92dc78 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -61,9 +61,6 @@ struct nf_conntrack_l4proto {
 	/* called by gc worker if table is full */
 	bool (*can_early_drop)(const struct nf_conn *ct);
 
-	/* Print out the private part of the conntrack. */
-	void (*print_conntrack)(struct seq_file *s, struct nf_conn *);
-
 	/* Return the array of timeouts for this protocol. */
 	unsigned int *(*get_timeouts)(struct net *net);
 
@@ -97,6 +94,10 @@ struct nf_conntrack_l4proto {
 		const struct nla_policy *nla_policy;
 	} ctnl_timeout;
 #endif
+#ifdef CONFIG_NF_CONNTRACK_PROCFS
+	/* Print out the private part of the conntrack. */
+	void (*print_conntrack)(struct seq_file *s, struct nf_conn *);
+#endif
 	unsigned int	*net_id;
 	/* Init l4proto pernet data */
 	int (*init_net)(struct net *net, u_int16_t proto);
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index d2df49ac390a..188347571fc7 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -623,10 +623,12 @@ static bool dccp_can_early_drop(const struct nf_conn *ct)
 	return false;
 }
 
+#ifdef CONFIG_NF_CONNTRACK_PROCFS
 static void dccp_print_conntrack(struct seq_file *s, struct nf_conn *ct)
 {
 	seq_printf(s, "%s ", dccp_state_names[ct->proto.dccp.state]);
 }
+#endif
 
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 static int dccp_to_nlattr(struct sk_buff *skb, struct nlattr *nla,
@@ -879,7 +881,9 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_dccp4 __read_mostly = {
 	.get_timeouts		= dccp_get_timeouts,
 	.error			= dccp_error,
 	.can_early_drop		= dccp_can_early_drop,
+#ifdef CONFIG_NF_CONNTRACK_PROCFS
 	.print_conntrack	= dccp_print_conntrack,
+#endif
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.to_nlattr		= dccp_to_nlattr,
 	.nlattr_size		= dccp_nlattr_size,
@@ -913,7 +917,9 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_dccp6 __read_mostly = {
 	.get_timeouts		= dccp_get_timeouts,
 	.error			= dccp_error,
 	.can_early_drop		= dccp_can_early_drop,
+#ifdef CONFIG_NF_CONNTRACK_PROCFS
 	.print_conntrack	= dccp_print_conntrack,
+#endif
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.to_nlattr		= dccp_to_nlattr,
 	.nlattr_size		= dccp_nlattr_size,
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index cd28095dd7a4..c0e3a23ac23a 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -224,6 +224,7 @@ static bool gre_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
 	return true;
 }
 
+#ifdef CONFIG_NF_CONNTRACK_PROCFS
 /* print private data for conntrack */
 static void gre_print_conntrack(struct seq_file *s, struct nf_conn *ct)
 {
@@ -231,6 +232,7 @@ static void gre_print_conntrack(struct seq_file *s, struct nf_conn *ct)
 		   (ct->proto.gre.timeout / HZ),
 		   (ct->proto.gre.stream_timeout / HZ));
 }
+#endif
 
 static unsigned int *gre_get_timeouts(struct net *net)
 {
@@ -357,7 +359,9 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_gre4 __read_mostly = {
 	.l4proto	 = IPPROTO_GRE,
 	.pkt_to_tuple	 = gre_pkt_to_tuple,
 	.invert_tuple	 = gre_invert_tuple,
+#ifdef CONFIG_NF_CONNTRACK_PROCFS
 	.print_conntrack = gre_print_conntrack,
+#endif
 	.get_timeouts    = gre_get_timeouts,
 	.packet		 = gre_packet,
 	.new		 = gre_new,
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index da83b401be17..890b5c73368d 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -174,11 +174,13 @@ static bool sctp_invert_tuple(struct nf_conntrack_tuple *tuple,
 	return true;
 }
 
+#ifdef CONFIG_NF_CONNTRACK_PROCFS
 /* Print out the private part of the conntrack. */
 static void sctp_print_conntrack(struct seq_file *s, struct nf_conn *ct)
 {
 	seq_printf(s, "%s ", sctp_conntrack_names[ct->proto.sctp.state]);
 }
+#endif
 
 #define for_each_sctp_chunk(skb, sch, _sch, offset, dataoff, count)	\
 for ((offset) = (dataoff) + sizeof(struct sctphdr), (count) = 0;	\
@@ -784,7 +786,9 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp4 __read_mostly = {
 	.l4proto 		= IPPROTO_SCTP,
 	.pkt_to_tuple 		= sctp_pkt_to_tuple,
 	.invert_tuple 		= sctp_invert_tuple,
+#ifdef CONFIG_NF_CONNTRACK_PROCFS
 	.print_conntrack	= sctp_print_conntrack,
+#endif
 	.packet 		= sctp_packet,
 	.get_timeouts		= sctp_get_timeouts,
 	.new 			= sctp_new,
@@ -819,7 +823,9 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6 __read_mostly = {
 	.l4proto 		= IPPROTO_SCTP,
 	.pkt_to_tuple 		= sctp_pkt_to_tuple,
 	.invert_tuple 		= sctp_invert_tuple,
+#ifdef CONFIG_NF_CONNTRACK_PROCFS
 	.print_conntrack	= sctp_print_conntrack,
+#endif
 	.packet 		= sctp_packet,
 	.get_timeouts		= sctp_get_timeouts,
 	.new 			= sctp_new,
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index c868b36b8945..33c52d9ab2f5 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -301,11 +301,13 @@ static bool tcp_invert_tuple(struct nf_conntrack_tuple *tuple,
 	return true;
 }
 
+#ifdef CONFIG_NF_CONNTRACK_PROCFS
 /* Print out the private part of the conntrack. */
 static void tcp_print_conntrack(struct seq_file *s, struct nf_conn *ct)
 {
 	seq_printf(s, "%s ", tcp_conntrack_names[ct->proto.tcp.state]);
 }
+#endif
 
 static unsigned int get_conntrack_index(const struct tcphdr *tcph)
 {
@@ -1549,7 +1551,9 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp4 __read_mostly =
 	.l4proto 		= IPPROTO_TCP,
 	.pkt_to_tuple 		= tcp_pkt_to_tuple,
 	.invert_tuple 		= tcp_invert_tuple,
+#ifdef CONFIG_NF_CONNTRACK_PROCFS
 	.print_conntrack 	= tcp_print_conntrack,
+#endif
 	.packet 		= tcp_packet,
 	.get_timeouts		= tcp_get_timeouts,
 	.new 			= tcp_new,
@@ -1585,7 +1589,9 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp6 __read_mostly =
 	.l4proto 		= IPPROTO_TCP,
 	.pkt_to_tuple 		= tcp_pkt_to_tuple,
 	.invert_tuple 		= tcp_invert_tuple,
+#ifdef CONFIG_NF_CONNTRACK_PROCFS
 	.print_conntrack 	= tcp_print_conntrack,
+#endif
 	.packet 		= tcp_packet,
 	.get_timeouts		= tcp_get_timeouts,
 	.new 			= tcp_new,
-- 
2.1.4


