From: Joe Perches <joe@perches.com>
Subject: [PATCH -next 3/3] netfilter: Use seq_overflow
Date: Tue, 10 Dec 2013 21:12:44 -0800
Message-ID: <81323bd2acdabcd7ab7d62e05032e6529b8dfbf0.1386738050.git.joe@perches.com>
References: <cover.1386738050.git.joe@perches.com>
Cc: Kees Cook <keescook@chromium.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexander Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1386738050.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the uses of the return of seq_printf/seq_puts/seq_putc to
use check seq_overflow to determine if a buffer overflow has occurred.

This will eventually allow seq_printf & seq_puts to be converted to a
void return instead of the often misused return that is often assumed
to be an int for the number of bytes emitted ala printk.

Convert seq_print_acct to return int.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/netfilter/nf_conntrack_acct.h          |  3 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |  6 ++-
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   | 42 +++++++++++++--------
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c     |  6 ++-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c     | 10 +++--
 net/netfilter/nf_conntrack_acct.c                  | 11 +++---
 net/netfilter/nf_conntrack_expect.c                |  4 +-
 net/netfilter/nf_conntrack_proto_dccp.c            | 12 ++++--
 net/netfilter/nf_conntrack_proto_gre.c             | 15 +++++---
 net/netfilter/nf_conntrack_proto_sctp.c            | 12 ++++--
 net/netfilter/nf_conntrack_proto_tcp.c             | 11 ++++--
 net/netfilter/nf_conntrack_proto_udp.c             |  7 ++--
 net/netfilter/nf_conntrack_proto_udplite.c         |  7 ++--
 net/netfilter/nf_conntrack_standalone.c            | 44 +++++++++++++---------
 net/netfilter/nf_log.c                             | 26 ++++++-------
 net/netfilter/nfnetlink_log.c                      | 12 +++---
 net/netfilter/nfnetlink_queue_core.c               | 14 ++++---
 net/netfilter/x_tables.c                           |  8 ++--
 net/netfilter/xt_hashlimit.c                       | 34 +++++++++--------
 19 files changed, 169 insertions(+), 115 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_acct.h b/include/net/netfilter/nf_conntrack_acct.h
index 79d8d16..939bffe 100644
--- a/include/net/netfilter/nf_conntrack_acct.h
+++ b/include/net/netfilter/nf_conntrack_acct.h
@@ -46,8 +46,7 @@ struct nf_conn_acct *nf_ct_acct_ext_add(struct nf_conn *ct, gfp_t gfp)
 	return acct;
 };
 
-unsigned int seq_print_acct(struct seq_file *s, const struct nf_conn *ct,
-			    int dir);
+int seq_print_acct(struct seq_file *s, const struct nf_conn *ct, int dir);
 
 /* Check if connection tracking accounting is enabled */
 static inline bool nf_ct_acct_enabled(struct net *net)
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index ecd8bec..aa07f0b 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -59,8 +59,10 @@ static bool ipv4_invert_tuple(struct nf_conntrack_tuple *tuple,
 static int ipv4_print_tuple(struct seq_file *s,
 			    const struct nf_conntrack_tuple *tuple)
 {
-	return seq_printf(s, "src=%pI4 dst=%pI4 ",
-			  &tuple->src.u3.ip, &tuple->dst.u3.ip);
+	seq_printf(s, "src=%pI4 dst=%pI4 ",
+		   &tuple->src.u3.ip, &tuple->dst.u3.ip);
+
+	return seq_overflow(s);
 }
 
 static int ipv4_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index 4c48e43..67ba510 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -104,10 +104,10 @@ static int ct_show_secctx(struct seq_file *s, const struct nf_conn *ct)
 	if (ret)
 		return 0;
 
-	ret = seq_printf(s, "secctx=%s ", secctx);
+	seq_printf(s, "secctx=%s ", secctx);
 
 	security_release_secctx(secctx, len);
-	return ret;
+	return seq_overflow(s);
 }
 #else
 static inline int ct_show_secctx(struct seq_file *s, const struct nf_conn *ct)
@@ -141,10 +141,11 @@ static int ct_seq_show(struct seq_file *s, void *v)
 	NF_CT_ASSERT(l4proto);
 
 	ret = -ENOSPC;
-	if (seq_printf(s, "%-8s %u %ld ",
-		      l4proto->name, nf_ct_protonum(ct),
-		      timer_pending(&ct->timeout)
-		      ? (long)(ct->timeout.expires - jiffies)/HZ : 0) != 0)
+	seq_printf(s, "%-8s %u %ld ",
+		   l4proto->name, nf_ct_protonum(ct),
+		   timer_pending(&ct->timeout)
+		   ? (long)(ct->timeout.expires - jiffies)/HZ : 0);
+	if (seq_overflow(s))
 		goto release;
 
 	if (l4proto->print_conntrack && l4proto->print_conntrack(s, ct))
@@ -154,35 +155,44 @@ static int ct_seq_show(struct seq_file *s, void *v)
 			l3proto, l4proto))
 		goto release;
 
-	if (seq_print_acct(s, ct, IP_CT_DIR_ORIGINAL))
+	seq_print_acct(s, ct, IP_CT_DIR_ORIGINAL);
+	if (seq_overflow(s))
 		goto release;
 
-	if (!(test_bit(IPS_SEEN_REPLY_BIT, &ct->status)))
-		if (seq_printf(s, "[UNREPLIED] "))
+	if (!(test_bit(IPS_SEEN_REPLY_BIT, &ct->status))) {
+		seq_printf(s, "[UNREPLIED] ");
+		if (seq_overflow(s))
 			goto release;
+	}
 
 	if (print_tuple(s, &ct->tuplehash[IP_CT_DIR_REPLY].tuple,
 			l3proto, l4proto))
 		goto release;
 
-	if (seq_print_acct(s, ct, IP_CT_DIR_REPLY))
+	seq_print_acct(s, ct, IP_CT_DIR_REPLY);
+	if (seq_overflow(s))
 		goto release;
 
-	if (test_bit(IPS_ASSURED_BIT, &ct->status))
-		if (seq_printf(s, "[ASSURED] "))
+	if (test_bit(IPS_ASSURED_BIT, &ct->status)) {
+		seq_printf(s, "[ASSURED] ");
+		if (seq_overflow(s))
 			goto release;
+	}
 
 #ifdef CONFIG_NF_CONNTRACK_MARK
-	if (seq_printf(s, "mark=%u ", ct->mark))
+	seq_printf(s, "mark=%u ", ct->mark);
+	if (seq_overflow(s))
 		goto release;
 #endif
 
 	if (ct_show_secctx(s, ct))
 		goto release;
 
-	if (seq_printf(s, "use=%u\n", atomic_read(&ct->ct_general.use)))
+	seq_printf(s, "use=%u\n", atomic_read(&ct->ct_general.use));
+	if (seq_overflow(s))
 		goto release;
 	ret = 0;
+
 release:
 	nf_ct_put(ct);
 	return ret;
@@ -297,7 +307,9 @@ static int exp_seq_show(struct seq_file *s, void *v)
 		    __nf_ct_l3proto_find(exp->tuple.src.l3num),
 		    __nf_ct_l4proto_find(exp->tuple.src.l3num,
 					 exp->tuple.dst.protonum));
-	return seq_putc(s, '\n');
+	seq_putc(s, '\n');
+
+	return seq_overflow(s);
 }
 
 static const struct seq_operations exp_seq_ops = {
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 4cbc6b2..d5b0cd4 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -63,8 +63,10 @@ static bool ipv6_invert_tuple(struct nf_conntrack_tuple *tuple,
 static int ipv6_print_tuple(struct seq_file *s,
 			    const struct nf_conntrack_tuple *tuple)
 {
-	return seq_printf(s, "src=%pI6 dst=%pI6 ",
-			  tuple->src.u3.ip6, tuple->dst.u3.ip6);
+	seq_printf(s, "src=%pI6 dst=%pI6 ",
+		   tuple->src.u3.ip6, tuple->dst.u3.ip6);
+
+	return seq_overflow(s);
 }
 
 static int ipv6_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index b3807c5..4d6d138 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -87,10 +87,12 @@ static bool icmpv6_invert_tuple(struct nf_conntrack_tuple *tuple,
 static int icmpv6_print_tuple(struct seq_file *s,
 			      const struct nf_conntrack_tuple *tuple)
 {
-	return seq_printf(s, "type=%u code=%u id=%u ",
-			  tuple->dst.u.icmp.type,
-			  tuple->dst.u.icmp.code,
-			  ntohs(tuple->src.u.icmp.id));
+	seq_printf(s, "type=%u code=%u id=%u ",
+		   tuple->dst.u.icmp.type,
+		   tuple->dst.u.icmp.code,
+		   ntohs(tuple->src.u.icmp.id));
+
+	return seq_overflow(s);
 }
 
 static unsigned int *icmpv6_get_timeouts(struct net *net)
diff --git a/net/netfilter/nf_conntrack_acct.c b/net/netfilter/nf_conntrack_acct.c
index a4b5e2a..897d9cc 100644
--- a/net/netfilter/nf_conntrack_acct.c
+++ b/net/netfilter/nf_conntrack_acct.c
@@ -36,8 +36,7 @@ static struct ctl_table acct_sysctl_table[] = {
 };
 #endif /* CONFIG_SYSCTL */
 
-unsigned int
-seq_print_acct(struct seq_file *s, const struct nf_conn *ct, int dir)
+int seq_print_acct(struct seq_file *s, const struct nf_conn *ct, int dir)
 {
 	struct nf_conn_acct *acct;
 	struct nf_conn_counter *counter;
@@ -47,9 +46,11 @@ seq_print_acct(struct seq_file *s, const struct nf_conn *ct, int dir)
 		return 0;
 
 	counter = acct->counter;
-	return seq_printf(s, "packets=%llu bytes=%llu ",
-			  (unsigned long long)atomic64_read(&counter[dir].packets),
-			  (unsigned long long)atomic64_read(&counter[dir].bytes));
+	seq_printf(s, "packets=%llu bytes=%llu ",
+		   (unsigned long long)atomic64_read(&counter[dir].packets),
+		   (unsigned long long)atomic64_read(&counter[dir].bytes));
+
+	return seq_overflow(s);
 };
 EXPORT_SYMBOL_GPL(seq_print_acct);
 
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 4fd1ca9..15bbf36 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -544,7 +544,9 @@ static int exp_seq_show(struct seq_file *s, void *v)
 				   helper->expect_policy[expect->class].name);
 	}
 
-	return seq_putc(s, '\n');
+	seq_putc(s, '\n');
+
+	return seq_overflow(s);
 }
 
 static const struct seq_operations exp_seq_ops = {
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index a99b6c3..a0f95a6 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -621,14 +621,18 @@ out_invalid:
 static int dccp_print_tuple(struct seq_file *s,
 			    const struct nf_conntrack_tuple *tuple)
 {
-	return seq_printf(s, "sport=%hu dport=%hu ",
-			  ntohs(tuple->src.u.dccp.port),
-			  ntohs(tuple->dst.u.dccp.port));
+	seq_printf(s, "sport=%hu dport=%hu ",
+		   ntohs(tuple->src.u.dccp.port),
+		   ntohs(tuple->dst.u.dccp.port));
+
+	return seq_overflow(s);
 }
 
 static int dccp_print_conntrack(struct seq_file *s, struct nf_conn *ct)
 {
-	return seq_printf(s, "%s ", dccp_state_names[ct->proto.dccp.state]);
+	seq_printf(s, "%s ", dccp_state_names[ct->proto.dccp.state]);
+
+	return seq_overflow(s);
 }
 
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index 9d9c0da..234f7f6 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -230,17 +230,20 @@ static bool gre_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
 static int gre_print_tuple(struct seq_file *s,
 			   const struct nf_conntrack_tuple *tuple)
 {
-	return seq_printf(s, "srckey=0x%x dstkey=0x%x ",
-			  ntohs(tuple->src.u.gre.key),
-			  ntohs(tuple->dst.u.gre.key));
+	seq_printf(s, "srckey=0x%x dstkey=0x%x ",
+		   ntohs(tuple->src.u.gre.key), ntohs(tuple->dst.u.gre.key));
+
+	return seq_overflow(s);
 }
 
 /* print private data for conntrack */
 static int gre_print_conntrack(struct seq_file *s, struct nf_conn *ct)
 {
-	return seq_printf(s, "timeout=%u, stream_timeout=%u ",
-			  (ct->proto.gre.timeout / HZ),
-			  (ct->proto.gre.stream_timeout / HZ));
+	seq_printf(s, "timeout=%u, stream_timeout=%u ",
+		   ct->proto.gre.timeout / HZ,
+		   ct->proto.gre.stream_timeout / HZ);
+
+	return seq_overflow(s);
 }
 
 static unsigned int *gre_get_timeouts(struct net *net)
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 1314d33..b8b5708 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -169,9 +169,11 @@ static bool sctp_invert_tuple(struct nf_conntrack_tuple *tuple,
 static int sctp_print_tuple(struct seq_file *s,
 			    const struct nf_conntrack_tuple *tuple)
 {
-	return seq_printf(s, "sport=%hu dport=%hu ",
-			  ntohs(tuple->src.u.sctp.port),
-			  ntohs(tuple->dst.u.sctp.port));
+	seq_printf(s, "sport=%hu dport=%hu ",
+		   ntohs(tuple->src.u.sctp.port),
+		   ntohs(tuple->dst.u.sctp.port));
+
+	return seq_overflow(s);
 }
 
 /* Print out the private part of the conntrack. */
@@ -183,7 +185,9 @@ static int sctp_print_conntrack(struct seq_file *s, struct nf_conn *ct)
 	state = ct->proto.sctp.state;
 	spin_unlock_bh(&ct->lock);
 
-	return seq_printf(s, "%s ", sctp_conntrack_names[state]);
+	seq_printf(s, "%s ", sctp_conntrack_names[state]);
+
+	return seq_overflow(s);
 }
 
 #define for_each_sctp_chunk(skb, sch, _sch, offset, dataoff, count)	\
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 44d1ea3..d21de09e 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -305,9 +305,10 @@ static bool tcp_invert_tuple(struct nf_conntrack_tuple *tuple,
 static int tcp_print_tuple(struct seq_file *s,
 			   const struct nf_conntrack_tuple *tuple)
 {
-	return seq_printf(s, "sport=%hu dport=%hu ",
-			  ntohs(tuple->src.u.tcp.port),
-			  ntohs(tuple->dst.u.tcp.port));
+	seq_printf(s, "sport=%hu dport=%hu ",
+		   ntohs(tuple->src.u.tcp.port), ntohs(tuple->dst.u.tcp.port));
+
+	return seq_overflow(s);
 }
 
 /* Print out the private part of the conntrack. */
@@ -319,7 +320,9 @@ static int tcp_print_conntrack(struct seq_file *s, struct nf_conn *ct)
 	state = ct->proto.tcp.state;
 	spin_unlock_bh(&ct->lock);
 
-	return seq_printf(s, "%s ", tcp_conntrack_names[state]);
+	seq_printf(s, "%s ", tcp_conntrack_names[state]);
+
+	return seq_overflow(s);
 }
 
 static unsigned int get_conntrack_index(const struct tcphdr *tcph)
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 9d7721c..c2b52da 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -66,9 +66,10 @@ static bool udp_invert_tuple(struct nf_conntrack_tuple *tuple,
 static int udp_print_tuple(struct seq_file *s,
 			   const struct nf_conntrack_tuple *tuple)
 {
-	return seq_printf(s, "sport=%hu dport=%hu ",
-			  ntohs(tuple->src.u.udp.port),
-			  ntohs(tuple->dst.u.udp.port));
+	seq_printf(s, "sport=%hu dport=%hu ",
+		   ntohs(tuple->src.u.udp.port), ntohs(tuple->dst.u.udp.port));
+
+	return seq_overflow(s);
 }
 
 static unsigned int *udp_get_timeouts(struct net *net)
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 2750e6c..7c4fb9b 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -74,9 +74,10 @@ static bool udplite_invert_tuple(struct nf_conntrack_tuple *tuple,
 static int udplite_print_tuple(struct seq_file *s,
 			       const struct nf_conntrack_tuple *tuple)
 {
-	return seq_printf(s, "sport=%hu dport=%hu ",
-			  ntohs(tuple->src.u.udp.port),
-			  ntohs(tuple->dst.u.udp.port));
+	seq_printf(s, "sport=%hu dport=%hu ",
+		   ntohs(tuple->src.u.udp.port), ntohs(tuple->dst.u.udp.port));
+
+	return seq_overflow(s);
 }
 
 static unsigned int *udplite_get_timeouts(struct net *net)
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index f641751..6666119 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -129,10 +129,10 @@ static int ct_show_secctx(struct seq_file *s, const struct nf_conn *ct)
 	if (ret)
 		return 0;
 
-	ret = seq_printf(s, "secctx=%s ", secctx);
+	seq_printf(s, "secctx=%s ", secctx);
 
 	security_release_secctx(secctx, len);
-	return ret;
+	return seq_overflow(s);
 }
 #else
 static inline int ct_show_secctx(struct seq_file *s, const struct nf_conn *ct)
@@ -156,8 +156,9 @@ static int ct_show_delta_time(struct seq_file *s, const struct nf_conn *ct)
 		else
 			delta_time = 0;
 
-		return seq_printf(s, "delta-time=%llu ",
-				  (unsigned long long)delta_time);
+		seq_printf(s, "delta-time=%llu ",
+			   (unsigned long long)delta_time);
+		return seq_overflow(s);
 	}
 	return 0;
 }
@@ -192,11 +193,12 @@ static int ct_seq_show(struct seq_file *s, void *v)
 	NF_CT_ASSERT(l4proto);
 
 	ret = -ENOSPC;
-	if (seq_printf(s, "%-8s %u %-8s %u %ld ",
-		       l3proto->name, nf_ct_l3num(ct),
-		       l4proto->name, nf_ct_protonum(ct),
-		       timer_pending(&ct->timeout)
-		       ? (long)(ct->timeout.expires - jiffies)/HZ : 0) != 0)
+	seq_printf(s, "%-8s %u %-8s %u %ld ",
+		   l3proto->name, nf_ct_l3num(ct),
+		   l4proto->name, nf_ct_protonum(ct),
+		   timer_pending(&ct->timeout)
+		   ? (long)(ct->timeout.expires - jiffies) / HZ : 0);
+	if (seq_overflow(s))
 		goto release;
 
 	if (l4proto->print_conntrack && l4proto->print_conntrack(s, ct))
@@ -209,9 +211,11 @@ static int ct_seq_show(struct seq_file *s, void *v)
 	if (seq_print_acct(s, ct, IP_CT_DIR_ORIGINAL))
 		goto release;
 
-	if (!(test_bit(IPS_SEEN_REPLY_BIT, &ct->status)))
-		if (seq_printf(s, "[UNREPLIED] "))
+	if (!(test_bit(IPS_SEEN_REPLY_BIT, &ct->status))) {
+		seq_printf(s, "[UNREPLIED] ");
+		if (seq_overflow(s))
 			goto release;
+	}
 
 	if (print_tuple(s, &ct->tuplehash[IP_CT_DIR_REPLY].tuple,
 			l3proto, l4proto))
@@ -220,12 +224,15 @@ static int ct_seq_show(struct seq_file *s, void *v)
 	if (seq_print_acct(s, ct, IP_CT_DIR_REPLY))
 		goto release;
 
-	if (test_bit(IPS_ASSURED_BIT, &ct->status))
-		if (seq_printf(s, "[ASSURED] "))
+	if (test_bit(IPS_ASSURED_BIT, &ct->status)) {
+		seq_printf(s, "[ASSURED] ");
+		if (seq_overflow(s))
 			goto release;
+	}
 
 #if defined(CONFIG_NF_CONNTRACK_MARK)
-	if (seq_printf(s, "mark=%u ", ct->mark))
+	seq_printf(s, "mark=%u ", ct->mark);
+	if (seq_overflow(s))
 		goto release;
 #endif
 
@@ -233,17 +240,20 @@ static int ct_seq_show(struct seq_file *s, void *v)
 		goto release;
 
 #ifdef CONFIG_NF_CONNTRACK_ZONES
-	if (seq_printf(s, "zone=%u ", nf_ct_zone(ct)))
+	seq_printf(s, "zone=%u ", nf_ct_zone(ct));
+	if (seq_overflow(s))
 		goto release;
 #endif
 
 	if (ct_show_delta_time(s, ct))
 		goto release;
 
-	if (seq_printf(s, "use=%u\n", atomic_read(&ct->ct_general.use)))
+	seq_printf(s, "use=%u\n", atomic_read(&ct->ct_general.use));
+	if (seq_overflow(s))
 		goto release;
 
-	ret = 0;
+	return 0;
+
 release:
 	nf_ct_put(ct);
 	return ret;
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 85296d4..386327e 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -189,32 +189,32 @@ static int seq_show(struct seq_file *s, void *v)
 	loff_t *pos = v;
 	const struct nf_logger *logger;
 	struct nf_logger *t;
-	int ret;
 	struct net *net = seq_file_net(s);
 
 	logger = rcu_dereference_protected(net->nf.nf_loggers[*pos],
 					   lockdep_is_held(&nf_log_mutex));
 
 	if (!logger)
-		ret = seq_printf(s, "%2lld NONE (", *pos);
+		seq_printf(s, "%2lld NONE (", *pos);
 	else
-		ret = seq_printf(s, "%2lld %s (", *pos, logger->name);
-
-	if (ret < 0)
-		return ret;
+		seq_printf(s, "%2lld %s (", *pos, logger->name);
+	if (seq_overflow(s))
+		return seq_overflow(s);
 
 	list_for_each_entry(t, &nf_loggers_l[*pos], list[*pos]) {
-		ret = seq_printf(s, "%s", t->name);
-		if (ret < 0)
-			return ret;
+		seq_printf(s, "%s", t->name);
+		if (seq_overflow(s))
+			return seq_overflow(s);
 		if (&t->list[*pos] != nf_loggers_l[*pos].prev) {
-			ret = seq_printf(s, ",");
-			if (ret < 0)
-				return ret;
+			seq_printf(s, ",");
+			if (seq_overflow(s))
+				return seq_overflow(s);
 		}
 	}
 
-	return seq_printf(s, ")\n");
+	seq_printf(s, ")\n");
+
+	return seq_overflow(s);
 }
 
 static const struct seq_operations nflog_seq_ops = {
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 3c4b69e..99d4a6c 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -1001,11 +1001,13 @@ static int seq_show(struct seq_file *s, void *v)
 {
 	const struct nfulnl_instance *inst = v;
 
-	return seq_printf(s, "%5d %6d %5d %1d %5d %6d %2d\n",
-			  inst->group_num,
-			  inst->peer_portid, inst->qlen,
-			  inst->copy_mode, inst->copy_range,
-			  inst->flushtimeout, atomic_read(&inst->use));
+	seq_printf(s, "%5d %6d %5d %1d %5d %6d %2d\n",
+		   inst->group_num,
+		   inst->peer_portid, inst->qlen,
+		   inst->copy_mode, inst->copy_range,
+		   inst->flushtimeout, atomic_read(&inst->use));
+
+	return seq_overflow(s);
 }
 
 static const struct seq_operations nful_seq_ops = {
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 21258cf..c3f4762 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -1253,12 +1253,14 @@ static int seq_show(struct seq_file *s, void *v)
 {
 	const struct nfqnl_instance *inst = v;
 
-	return seq_printf(s, "%5d %6d %5d %1d %5d %5d %5d %8d %2d\n",
-			  inst->queue_num,
-			  inst->peer_portid, inst->queue_total,
-			  inst->copy_mode, inst->copy_range,
-			  inst->queue_dropped, inst->queue_user_dropped,
-			  inst->id_sequence, 1);
+	seq_printf(s, "%5d %6d %5d %1d %5d %5d %5d %8d %2d\n",
+		   inst->queue_num,
+		   inst->peer_portid, inst->queue_total,
+		   inst->copy_mode, inst->copy_range,
+		   inst->queue_dropped, inst->queue_user_dropped,
+		   inst->id_sequence, 1);
+
+	return seq_overflow(s);
 }
 
 static const struct seq_operations nfqnl_seq_ops = {
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 227aa11..a74f49f 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -983,10 +983,12 @@ static int xt_table_seq_show(struct seq_file *seq, void *v)
 {
 	struct xt_table *table = list_entry(v, struct xt_table, list);
 
-	if (strlen(table->name))
-		return seq_printf(seq, "%s\n", table->name);
-	else
+	if (!strlen(table->name))
 		return 0;
+
+	seq_printf(seq, "%s\n", table->name);
+
+	return seq_overflow(seq);
 }
 
 static const struct seq_operations xt_table_seq_ops = {
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index a3910fc..c229655 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -797,25 +797,27 @@ static int dl_seq_real_show(struct dsthash_ent *ent, u_int8_t family,
 
 	switch (family) {
 	case NFPROTO_IPV4:
-		res = seq_printf(s, "%ld %pI4:%u->%pI4:%u %u %u %u\n",
-				 (long)(ent->expires - jiffies)/HZ,
-				 &ent->dst.ip.src,
-				 ntohs(ent->dst.src_port),
-				 &ent->dst.ip.dst,
-				 ntohs(ent->dst.dst_port),
-				 ent->rateinfo.credit, ent->rateinfo.credit_cap,
-				 ent->rateinfo.cost);
+		seq_printf(s, "%ld %pI4:%u->%pI4:%u %u %u %u\n",
+			   (long)(ent->expires - jiffies)/HZ,
+			   &ent->dst.ip.src,
+			   ntohs(ent->dst.src_port),
+			   &ent->dst.ip.dst,
+			   ntohs(ent->dst.dst_port),
+			   ent->rateinfo.credit, ent->rateinfo.credit_cap,
+			   ent->rateinfo.cost);
+		res = seq_overflow(s);
 		break;
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	case NFPROTO_IPV6:
-		res = seq_printf(s, "%ld %pI6:%u->%pI6:%u %u %u %u\n",
-				 (long)(ent->expires - jiffies)/HZ,
-				 &ent->dst.ip6.src,
-				 ntohs(ent->dst.src_port),
-				 &ent->dst.ip6.dst,
-				 ntohs(ent->dst.dst_port),
-				 ent->rateinfo.credit, ent->rateinfo.credit_cap,
-				 ent->rateinfo.cost);
+		seq_printf(s, "%ld %pI6:%u->%pI6:%u %u %u %u\n",
+			   (long)(ent->expires - jiffies)/HZ,
+			   &ent->dst.ip6.src,
+			   ntohs(ent->dst.src_port),
+			   &ent->dst.ip6.dst,
+			   ntohs(ent->dst.dst_port),
+			   ent->rateinfo.credit, ent->rateinfo.credit_cap,
+			   ent->rateinfo.cost);
+		res = seq_overflow(s);
 		break;
 #endif
 	default:
-- 
1.8.1.2.459.gbcd45b4.dirty
