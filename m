From: Joe Perches <joe@perches.com>
Subject: [PATCH -next 2/2] netfilter: Convert print_tuple functions to return void
Date: Wed, 11 Dec 2013 19:44:12 -0800
Message-ID: <fdd62757f3d2dd66e65c4a0c5bd61be97e14a29b.1386819513.git.joe@perches.com>
References: <cover.1386819513.git.joe@perches.com>
Cc: Kees Cook <keescook@chromium.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexander Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1386819513.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since adding a new function to seq_file (seq_is_buf_full)
there isn't any value for functions called from seq_show to
return anything.   Remove the int returns of the various
print_tuple/<foo>_print_tuple functions.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/netfilter/nf_conntrack_core.h    |  2 +-
 include/net/netfilter/nf_conntrack_l3proto.h |  4 ++--
 include/net/netfilter/nf_conntrack_l4proto.h |  4 ++--
 net/netfilter/nf_conntrack_l3proto_generic.c |  5 ++---
 net/netfilter/nf_conntrack_proto_dccp.c      | 10 +++++-----
 net/netfilter/nf_conntrack_proto_generic.c   |  5 ++---
 net/netfilter/nf_conntrack_proto_gre.c       | 10 +++++-----
 net/netfilter/nf_conntrack_proto_sctp.c      | 10 +++++-----
 net/netfilter/nf_conntrack_proto_tcp.c       | 10 +++++-----
 net/netfilter/nf_conntrack_proto_udp.c       | 10 +++++-----
 net/netfilter/nf_conntrack_proto_udplite.c   | 10 +++++-----
 net/netfilter/nf_conntrack_standalone.c      | 15 +++++++--------
 12 files changed, 46 insertions(+), 49 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index 15308b8..7b8f18c 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -72,7 +72,7 @@ static inline int nf_conntrack_confirm(struct sk_buff *skb)
 	return ret;
 }
 
-int
+void
 print_tuple(struct seq_file *s, const struct nf_conntrack_tuple *tuple,
             const struct nf_conntrack_l3proto *l3proto,
             const struct nf_conntrack_l4proto *proto);
diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/net/netfilter/nf_conntrack_l3proto.h
index 3efab70..9e349db 100644
--- a/include/net/netfilter/nf_conntrack_l3proto.h
+++ b/include/net/netfilter/nf_conntrack_l3proto.h
@@ -38,8 +38,8 @@ struct nf_conntrack_l3proto {
 			     const struct nf_conntrack_tuple *orig);
 
 	/* Print out the per-protocol part of the tuple. */
-	int (*print_tuple)(struct seq_file *s,
-			   const struct nf_conntrack_tuple *);
+	void (*print_tuple)(struct seq_file *s,
+			    const struct nf_conntrack_tuple *);
 
 	/*
 	 * Called before tracking. 
diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index 4c8d573..fead8ee 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -56,8 +56,8 @@ struct nf_conntrack_l4proto {
 		     u_int8_t pf, unsigned int hooknum);
 
 	/* Print out the per-protocol part of the tuple. Return like seq_* */
-	int (*print_tuple)(struct seq_file *s,
-			   const struct nf_conntrack_tuple *);
+	void (*print_tuple)(struct seq_file *s,
+			    const struct nf_conntrack_tuple *);
 
 	/* Print out the private part of the conntrack. */
 	int (*print_conntrack)(struct seq_file *s, struct nf_conn *);
diff --git a/net/netfilter/nf_conntrack_l3proto_generic.c b/net/netfilter/nf_conntrack_l3proto_generic.c
index e7eb807..cf9ace7 100644
--- a/net/netfilter/nf_conntrack_l3proto_generic.c
+++ b/net/netfilter/nf_conntrack_l3proto_generic.c
@@ -49,10 +49,9 @@ static bool generic_invert_tuple(struct nf_conntrack_tuple *tuple,
 	return true;
 }
 
-static int generic_print_tuple(struct seq_file *s,
-			    const struct nf_conntrack_tuple *tuple)
+static void generic_print_tuple(struct seq_file *s,
+				const struct nf_conntrack_tuple *tuple)
 {
-	return 0;
 }
 
 static int generic_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index a99b6c3..d357f11 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -618,12 +618,12 @@ out_invalid:
 	return -NF_ACCEPT;
 }
 
-static int dccp_print_tuple(struct seq_file *s,
-			    const struct nf_conntrack_tuple *tuple)
+static void dccp_print_tuple(struct seq_file *s,
+			     const struct nf_conntrack_tuple *tuple)
 {
-	return seq_printf(s, "sport=%hu dport=%hu ",
-			  ntohs(tuple->src.u.dccp.port),
-			  ntohs(tuple->dst.u.dccp.port));
+	seq_printf(s, "sport=%hu dport=%hu ",
+		   ntohs(tuple->src.u.dccp.port),
+		   ntohs(tuple->dst.u.dccp.port));
 }
 
 static int dccp_print_conntrack(struct seq_file *s, struct nf_conn *ct)
diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index d25f2937..0a3ded1 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -39,10 +39,9 @@ static bool generic_invert_tuple(struct nf_conntrack_tuple *tuple,
 }
 
 /* Print out the per-protocol part of the tuple. */
-static int generic_print_tuple(struct seq_file *s,
-			       const struct nf_conntrack_tuple *tuple)
+static void generic_print_tuple(struct seq_file *s,
+				const struct nf_conntrack_tuple *tuple)
 {
-	return 0;
 }
 
 static unsigned int *generic_get_timeouts(struct net *net)
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index 9d9c0da..802b72c 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -227,12 +227,12 @@ static bool gre_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
 }
 
 /* print gre part of tuple */
-static int gre_print_tuple(struct seq_file *s,
-			   const struct nf_conntrack_tuple *tuple)
+static void gre_print_tuple(struct seq_file *s,
+			    const struct nf_conntrack_tuple *tuple)
 {
-	return seq_printf(s, "srckey=0x%x dstkey=0x%x ",
-			  ntohs(tuple->src.u.gre.key),
-			  ntohs(tuple->dst.u.gre.key));
+	seq_printf(s, "srckey=0x%x dstkey=0x%x ",
+		   ntohs(tuple->src.u.gre.key),
+		   ntohs(tuple->dst.u.gre.key));
 }
 
 /* print private data for conntrack */
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 1314d33..1b1d0e9 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -166,12 +166,12 @@ static bool sctp_invert_tuple(struct nf_conntrack_tuple *tuple,
 }
 
 /* Print out the per-protocol part of the tuple. */
-static int sctp_print_tuple(struct seq_file *s,
-			    const struct nf_conntrack_tuple *tuple)
+static void sctp_print_tuple(struct seq_file *s,
+			     const struct nf_conntrack_tuple *tuple)
 {
-	return seq_printf(s, "sport=%hu dport=%hu ",
-			  ntohs(tuple->src.u.sctp.port),
-			  ntohs(tuple->dst.u.sctp.port));
+	seq_printf(s, "sport=%hu dport=%hu ",
+		   ntohs(tuple->src.u.sctp.port),
+		   ntohs(tuple->dst.u.sctp.port));
 }
 
 /* Print out the private part of the conntrack. */
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 44d1ea3..c2693e78 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -302,12 +302,12 @@ static bool tcp_invert_tuple(struct nf_conntrack_tuple *tuple,
 }
 
 /* Print out the per-protocol part of the tuple. */
-static int tcp_print_tuple(struct seq_file *s,
-			   const struct nf_conntrack_tuple *tuple)
+static void tcp_print_tuple(struct seq_file *s,
+			    const struct nf_conntrack_tuple *tuple)
 {
-	return seq_printf(s, "sport=%hu dport=%hu ",
-			  ntohs(tuple->src.u.tcp.port),
-			  ntohs(tuple->dst.u.tcp.port));
+	seq_printf(s, "sport=%hu dport=%hu ",
+		   ntohs(tuple->src.u.tcp.port),
+		   ntohs(tuple->dst.u.tcp.port));
 }
 
 /* Print out the private part of the conntrack. */
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 9d7721c..6957281 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -63,12 +63,12 @@ static bool udp_invert_tuple(struct nf_conntrack_tuple *tuple,
 }
 
 /* Print out the per-protocol part of the tuple. */
-static int udp_print_tuple(struct seq_file *s,
-			   const struct nf_conntrack_tuple *tuple)
+static void udp_print_tuple(struct seq_file *s,
+			    const struct nf_conntrack_tuple *tuple)
 {
-	return seq_printf(s, "sport=%hu dport=%hu ",
-			  ntohs(tuple->src.u.udp.port),
-			  ntohs(tuple->dst.u.udp.port));
+	seq_printf(s, "sport=%hu dport=%hu ",
+		   ntohs(tuple->src.u.udp.port),
+		   ntohs(tuple->dst.u.udp.port));
 }
 
 static unsigned int *udp_get_timeouts(struct net *net)
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 2750e6c..c5903d1 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -71,12 +71,12 @@ static bool udplite_invert_tuple(struct nf_conntrack_tuple *tuple,
 }
 
 /* Print out the per-protocol part of the tuple. */
-static int udplite_print_tuple(struct seq_file *s,
-			       const struct nf_conntrack_tuple *tuple)
+static void udplite_print_tuple(struct seq_file *s,
+				const struct nf_conntrack_tuple *tuple)
 {
-	return seq_printf(s, "sport=%hu dport=%hu ",
-			  ntohs(tuple->src.u.udp.port),
-			  ntohs(tuple->dst.u.udp.port));
+	seq_printf(s, "sport=%hu dport=%hu ",
+		   ntohs(tuple->src.u.udp.port),
+		   ntohs(tuple->dst.u.udp.port));
 }
 
 static unsigned int *udplite_get_timeouts(struct net *net)
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index f641751..26f49be 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -36,12 +36,13 @@
 MODULE_LICENSE("GPL");
 
 #ifdef CONFIG_NF_CONNTRACK_PROCFS
-int
+void
 print_tuple(struct seq_file *s, const struct nf_conntrack_tuple *tuple,
             const struct nf_conntrack_l3proto *l3proto,
             const struct nf_conntrack_l4proto *l4proto)
 {
-	return l3proto->print_tuple(s, tuple) || l4proto->print_tuple(s, tuple);
+	l3proto->print_tuple(s, tuple);
+	l4proto->print_tuple(s, tuple);
 }
 EXPORT_SYMBOL_GPL(print_tuple);
 
@@ -202,9 +203,8 @@ static int ct_seq_show(struct seq_file *s, void *v)
 	if (l4proto->print_conntrack && l4proto->print_conntrack(s, ct))
 		goto release;
 
-	if (print_tuple(s, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
-			l3proto, l4proto))
-		goto release;
+	print_tuple(s, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
+		    l3proto, l4proto);
 
 	if (seq_print_acct(s, ct, IP_CT_DIR_ORIGINAL))
 		goto release;
@@ -213,9 +213,8 @@ static int ct_seq_show(struct seq_file *s, void *v)
 		if (seq_printf(s, "[UNREPLIED] "))
 			goto release;
 
-	if (print_tuple(s, &ct->tuplehash[IP_CT_DIR_REPLY].tuple,
-			l3proto, l4proto))
-		goto release;
+	print_tuple(s, &ct->tuplehash[IP_CT_DIR_REPLY].tuple,
+		    l3proto, l4proto);
 
 	if (seq_print_acct(s, ct, IP_CT_DIR_REPLY))
 		goto release;
-- 
1.8.1.2.459.gbcd45b4.dirty
