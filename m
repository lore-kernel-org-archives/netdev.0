From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/19] netfilter: nf_nat: change sequence number adjustments to 32 bits
Date: Tue, 20 Aug 2013 12:54:42 +0200
Message-ID: <1376996091-3964-11-git-send-email-pablo@netfilter.org>
References: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Using 16 bits is too small, when many adjustments happen the offsets might
overflow and break the connection.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter.h              |    2 +-
 include/net/netfilter/nf_conntrack.h   |    2 +-
 include/net/netfilter/nf_nat.h         |    2 +-
 include/net/netfilter/nf_nat_helper.h  |    6 +++---
 net/netfilter/nf_conntrack_core.c      |    2 +-
 net/netfilter/nf_conntrack_proto_tcp.c |    4 ++--
 net/netfilter/nf_nat_helper.c          |    8 ++++----
 7 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index f4bbf2c..655d5d1 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -330,7 +330,7 @@ extern struct nfq_ct_hook __rcu *nfq_ct_hook;
 
 struct nfq_ct_nat_hook {
 	void (*seq_adjust)(struct sk_buff *skb, struct nf_conn *ct,
-			   u32 ctinfo, int off);
+			   u32 ctinfo, s32 off);
 };
 extern struct nfq_ct_nat_hook __rcu *nfq_ct_nat_hook;
 #else
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 939aced..e5eb8b6 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -234,7 +234,7 @@ static inline bool nf_ct_kill(struct nf_conn *ct)
 }
 
 /* These are for NAT.  Icky. */
-extern s16 (*nf_ct_nat_offset)(const struct nf_conn *ct,
+extern s32 (*nf_ct_nat_offset)(const struct nf_conn *ct,
 			       enum ip_conntrack_dir dir,
 			       u32 seq);
 
diff --git a/include/net/netfilter/nf_nat.h b/include/net/netfilter/nf_nat.h
index ad14a79..e244141 100644
--- a/include/net/netfilter/nf_nat.h
+++ b/include/net/netfilter/nf_nat.h
@@ -19,7 +19,7 @@ struct nf_nat_seq {
 	u_int32_t correction_pos;
 
 	/* sequence number offset before and after last modification */
-	int16_t offset_before, offset_after;
+	int32_t offset_before, offset_after;
 };
 
 #include <linux/list.h>
diff --git a/include/net/netfilter/nf_nat_helper.h b/include/net/netfilter/nf_nat_helper.h
index b4d6bfc..194c347 100644
--- a/include/net/netfilter/nf_nat_helper.h
+++ b/include/net/netfilter/nf_nat_helper.h
@@ -41,7 +41,7 @@ extern int nf_nat_mangle_udp_packet(struct sk_buff *skb,
 
 extern void nf_nat_set_seq_adjust(struct nf_conn *ct,
 				  enum ip_conntrack_info ctinfo,
-				  __be32 seq, s16 off);
+				  __be32 seq, s32 off);
 extern int nf_nat_seq_adjust(struct sk_buff *skb,
 			     struct nf_conn *ct,
 			     enum ip_conntrack_info ctinfo,
@@ -56,11 +56,11 @@ extern int (*nf_nat_seq_adjust_hook)(struct sk_buff *skb,
 extern void nf_nat_follow_master(struct nf_conn *ct,
 				 struct nf_conntrack_expect *this);
 
-extern s16 nf_nat_get_offset(const struct nf_conn *ct,
+extern s32 nf_nat_get_offset(const struct nf_conn *ct,
 			     enum ip_conntrack_dir dir,
 			     u32 seq);
 
 extern void nf_nat_tcp_seq_adjust(struct sk_buff *skb, struct nf_conn *ct,
-				  u32 dir, int off);
+				  u32 dir, s32 off);
 
 #endif
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 089e408..0934611 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1695,7 +1695,7 @@ err_stat:
 	return ret;
 }
 
-s16 (*nf_ct_nat_offset)(const struct nf_conn *ct,
+s32 (*nf_ct_nat_offset)(const struct nf_conn *ct,
 			enum ip_conntrack_dir dir,
 			u32 seq);
 EXPORT_SYMBOL_GPL(nf_ct_nat_offset);
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 7dcc376..8f308d8 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -496,7 +496,7 @@ static void tcp_sack(const struct sk_buff *skb, unsigned int dataoff,
 }
 
 #ifdef CONFIG_NF_NAT_NEEDED
-static inline s16 nat_offset(const struct nf_conn *ct,
+static inline s32 nat_offset(const struct nf_conn *ct,
 			     enum ip_conntrack_dir dir,
 			     u32 seq)
 {
@@ -525,7 +525,7 @@ static bool tcp_in_window(const struct nf_conn *ct,
 	struct ip_ct_tcp_state *receiver = &state->seen[!dir];
 	const struct nf_conntrack_tuple *tuple = &ct->tuplehash[dir].tuple;
 	__u32 seq, ack, sack, end, win, swin;
-	s16 receiver_offset;
+	s32 receiver_offset;
 	bool res;
 
 	/*
diff --git a/net/netfilter/nf_nat_helper.c b/net/netfilter/nf_nat_helper.c
index a7262ed..ff4a589 100644
--- a/net/netfilter/nf_nat_helper.c
+++ b/net/netfilter/nf_nat_helper.c
@@ -68,13 +68,13 @@ adjust_tcp_sequence(u32 seq,
 }
 
 /* Get the offset value, for conntrack */
-s16 nf_nat_get_offset(const struct nf_conn *ct,
+s32 nf_nat_get_offset(const struct nf_conn *ct,
 		      enum ip_conntrack_dir dir,
 		      u32 seq)
 {
 	struct nf_conn_nat *nat = nfct_nat(ct);
 	struct nf_nat_seq *this_way;
-	s16 offset;
+	s32 offset;
 
 	if (!nat)
 		return 0;
@@ -143,7 +143,7 @@ static int enlarge_skb(struct sk_buff *skb, unsigned int extra)
 }
 
 void nf_nat_set_seq_adjust(struct nf_conn *ct, enum ip_conntrack_info ctinfo,
-			   __be32 seq, s16 off)
+			   __be32 seq, s32 off)
 {
 	if (!off)
 		return;
@@ -370,7 +370,7 @@ nf_nat_seq_adjust(struct sk_buff *skb,
 	struct tcphdr *tcph;
 	int dir;
 	__be32 newseq, newack;
-	s16 seqoff, ackoff;
+	s32 seqoff, ackoff;
 	struct nf_conn_nat *nat = nfct_nat(ct);
 	struct nf_nat_seq *this_way, *other_way;
 	int res;
-- 
1.7.10.4

