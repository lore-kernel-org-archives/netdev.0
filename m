From: pablo@netfilter.org
Subject: [PATCH 5/7] netfilter: nfnl_queue: support NAT TCP sequence adjustment if packet mangled
Date: Mon,  4 Jun 2012 14:21:23 +0200
Message-ID: <1338812485-4232-6-git-send-email-pablo@netfilter.org>
References: <1338812485-4232-1-git-send-email-pablo@netfilter.org>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1338812485-4232-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

User-space programs that receive traffic via NFQUEUE may mangle packets.
If NAT is enabled, this usually puzzles sequence tracking, leading to
traffic disruptions.

With this patch, nfnl_queue will make the corresponding NAT TCP sequence
adjustment if:

1) The packet has been mangled,
2) the NFQNL_F_CONNTRACK flag has been set, and
3) NAT is detected.

This is required by the new user-space cthelper infrastructure.
By now, we only support TCP since we have no helpers for DCCP
or SCTP. Better to add this if we do ever need it.

You can still use this without the cthelper infrastructure. There
are several post on the Internet complaning about this (mostly
people using NFQUEUE for IDS).

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_nat_helper.h |    7 ++++++
 net/ipv4/netfilter/nf_nat_helper.c    |   13 ++++++++++
 net/netfilter/nfnetlink_queue.c       |   42 ++++++++++++++++++++++-----------
 3 files changed, 48 insertions(+), 14 deletions(-)

diff --git a/include/net/netfilter/nf_nat_helper.h b/include/net/netfilter/nf_nat_helper.h
index 02bb6c2..ee92a0c 100644
--- a/include/net/netfilter/nf_nat_helper.h
+++ b/include/net/netfilter/nf_nat_helper.h
@@ -46,6 +46,13 @@ extern int (*nf_nat_seq_adjust_hook)(struct sk_buff *skb,
 				     struct nf_conn *ct,
 				     enum ip_conntrack_info ctinfo);
 
+extern void nf_nat_tcp_seq_adjust(struct sk_buff *skb,
+				  struct nf_conn *ct,
+				  enum ip_conntrack_info ctinfo,
+				  int off);
+
+struct nf_conntrack_expect;
+
 /* Setup NAT on this expected conntrack so it follows master, but goes
  * to port ct->master->saved_proto. */
 extern void nf_nat_follow_master(struct nf_conn *ct,
diff --git a/net/ipv4/netfilter/nf_nat_helper.c b/net/ipv4/netfilter/nf_nat_helper.c
index af65958..7c7b5b8 100644
--- a/net/ipv4/netfilter/nf_nat_helper.c
+++ b/net/ipv4/netfilter/nf_nat_helper.c
@@ -153,6 +153,19 @@ void nf_nat_set_seq_adjust(struct nf_conn *ct, enum ip_conntrack_info ctinfo,
 }
 EXPORT_SYMBOL_GPL(nf_nat_set_seq_adjust);
 
+void nf_nat_tcp_seq_adjust(struct sk_buff *skb, struct nf_conn *ct,
+			   enum ip_conntrack_info ctinfo, int off)
+{
+	const struct tcphdr *th;
+
+	if (nf_ct_protonum(ct) != IPPROTO_TCP)
+		return;
+
+	th = (struct tcphdr *)(skb_network_header(skb)+ ip_hdrlen(skb));
+	nf_nat_set_seq_adjust(ct, ctinfo, th->seq, off);
+}
+EXPORT_SYMBOL_GPL(nf_nat_tcp_seq_adjust);
+
 static void nf_nat_csum(struct sk_buff *skb, const struct iphdr *iph, void *data,
 			int datalen, __sum16 *check, int oldlen)
 {
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index b007779..b18a367 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -38,6 +38,10 @@
 #include "../bridge/br_private.h"
 #endif
 
+#ifdef CONFIG_NF_NAT_NEEDED
+#include <net/netfilter/nf_nat_helper.h>
+#endif
+
 #define NFQNL_QMAX_DEFAULT 1024
 
 struct nfqnl_instance {
@@ -497,12 +501,10 @@ err_out:
 }
 
 static int
-nfqnl_mangle(void *data, int data_len, struct nf_queue_entry *e)
+nfqnl_mangle(void *data, int data_len, struct nf_queue_entry *e, int diff)
 {
 	struct sk_buff *nskb;
-	int diff;
 
-	diff = data_len - e->skb->len;
 	if (diff < 0) {
 		if (pskb_trim(e->skb, data_len))
 			return -ENOMEM;
@@ -761,6 +763,8 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 	unsigned int verdict;
 	struct nf_queue_entry *entry;
 	struct nfq_ct_hook *nfq_ct;
+	enum ip_conntrack_info uninitialized_var(ctinfo);
+	struct nf_conn *ct = NULL;
 
 	queue = instance_lookup(queue_num);
 	if (!queue)
@@ -779,26 +783,36 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 	if (entry == NULL)
 		return -ENOENT;
 
+	rcu_read_lock();
+	nfq_ct = rcu_dereference(nfq_ct_hook);
+	if (nfq_ct != NULL && (queue->flags & NFQNL_F_CONNTRACK) &&
+	    nfqa[NFQA_CT]) {
+		ct = nf_ct_get(entry->skb, &ctinfo);
+		if (ct && nf_ct_is_untracked(ct))
+			ct = NULL;
+	}
+
 	if (nfqa[NFQA_PAYLOAD]) {
+		u16 payload_len = nla_len(nfqa[NFQA_PAYLOAD]);
+		int diff = payload_len - entry->skb->len;
+
 		if (nfqnl_mangle(nla_data(nfqa[NFQA_PAYLOAD]),
-				 nla_len(nfqa[NFQA_PAYLOAD]), entry) < 0)
+				 payload_len, entry, diff) < 0)
 			verdict = NF_DROP;
+
+#ifdef CONFIG_NF_NAT_NEEDED
+		/* Adjust sequence numbers to avoid puzzling conntrack */
+		if (ct && (ct->status & IPS_NAT_MASK) && diff)
+			nf_nat_tcp_seq_adjust(skb, ct, ctinfo, diff);
+#endif
 	}
 
 	if (nfqa[NFQA_MARK])
 		entry->skb->mark = ntohl(nla_get_be32(nfqa[NFQA_MARK]));
 
-	rcu_read_lock();
-	nfq_ct = rcu_dereference(nfq_ct_hook);
-	if (nfq_ct != NULL &&
-	    (queue->flags & NFQNL_F_CONNTRACK) && nfqa[NFQA_CT]) {
-		enum ip_conntrack_info ctinfo;
-		struct nf_conn *ct;
+	if (ct)
+		nfq_ct->parse(nfqa[NFQA_CT], ct);
 
-		ct = nf_ct_get(entry->skb, &ctinfo);
-		if (ct && !nf_ct_is_untracked(ct))
-			nfq_ct->parse(nfqa[NFQA_CT], ct);
-	}
 	rcu_read_unlock();
 
 	nf_reinject(entry, verdict);
-- 
1.7.10

