From: pablo@netfilter.org
Subject: [PATCH 5/7] netfilter: nfnetlink_queue: add NAT TCP sequence adjustment if packet mangled
Date: Sat, 16 Jun 2012 17:49:54 +0200
Message-ID: <1339861796-2676-6-git-send-email-pablo@netfilter.org>
References: <1339861796-2676-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1339861796-2676-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

User-space programs that receive traffic via NFQUEUE may mangle packets.
If NAT is enabled, this usually puzzles sequence tracking, leading to
traffic disruptions.

With this patch, nfnl_queue will make the corresponding NAT TCP sequence
adjustment if:

1) The packet has been mangled,
2) the NFQA_CFG_F_CONNTRACK flag has been set, and
3) NAT is detected.

There are some records on the Internet complaning about this issue:
http://stackoverflow.com/questions/260757/packet-mangling-utilities-besides-iptables

By now, we only support TCP since we have no helpers for DCCP or SCTP.
Better to add this if we ever have some helper over those layer 4 protocols.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter.h             |    2 ++
 include/net/netfilter/nf_nat_helper.h |    4 ++++
 net/ipv4/netfilter/nf_nat_helper.c    |   13 +++++++++++++
 net/netfilter/nf_conntrack_netlink.c  |    4 ++++
 net/netfilter/nfnetlink_queue.c       |   19 +++++++++++--------
 5 files changed, 34 insertions(+), 8 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index ba65bfb..dca19e6 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -401,6 +401,8 @@ struct nfq_ct_hook {
 	size_t (*build_size)(const struct nf_conn *ct);
 	int (*build)(struct sk_buff *skb, struct nf_conn *ct);
 	int (*parse)(const struct nlattr *attr, struct nf_conn *ct);
+	void (*seq_adjust)(struct sk_buff *skb, struct nf_conn *ct,
+			   u32 ctinfo, int off);
 };
 extern struct nfq_ct_hook *nfq_ct_hook;
 #else
diff --git a/include/net/netfilter/nf_nat_helper.h b/include/net/netfilter/nf_nat_helper.h
index 02bb6c2..7d8fb7b 100644
--- a/include/net/netfilter/nf_nat_helper.h
+++ b/include/net/netfilter/nf_nat_helper.h
@@ -54,4 +54,8 @@ extern void nf_nat_follow_master(struct nf_conn *ct,
 extern s16 nf_nat_get_offset(const struct nf_conn *ct,
 			     enum ip_conntrack_dir dir,
 			     u32 seq);
+
+extern void nf_nat_tcp_seq_adjust(struct sk_buff *skb, struct nf_conn *ct,
+				  u32 dir, int off);
+
 #endif
diff --git a/net/ipv4/netfilter/nf_nat_helper.c b/net/ipv4/netfilter/nf_nat_helper.c
index af65958..2e59ad0 100644
--- a/net/ipv4/netfilter/nf_nat_helper.c
+++ b/net/ipv4/netfilter/nf_nat_helper.c
@@ -153,6 +153,19 @@ void nf_nat_set_seq_adjust(struct nf_conn *ct, enum ip_conntrack_info ctinfo,
 }
 EXPORT_SYMBOL_GPL(nf_nat_set_seq_adjust);
 
+void nf_nat_tcp_seq_adjust(struct sk_buff *skb, struct nf_conn *ct,
+			   u32 ctinfo, int off)
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
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index d304d59..8be0ab9 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -46,6 +46,7 @@
 #ifdef CONFIG_NF_NAT_NEEDED
 #include <net/netfilter/nf_nat_core.h>
 #include <net/netfilter/nf_nat_protocol.h>
+#include <net/netfilter/nf_nat_helper.h>
 #endif
 
 #include <linux/netfilter/nfnetlink.h>
@@ -1751,6 +1752,9 @@ static struct nfq_ct_hook ctnetlink_nfqueue_hook = {
 	.build_size	= ctnetlink_nfqueue_build_size,
 	.build		= ctnetlink_nfqueue_build,
 	.parse		= ctnetlink_nfqueue_parse,
+#ifdef CONFIG_NF_NAT_NEEDED
+	.seq_adjust	= nf_nat_tcp_seq_adjust,
+#endif
 };
 #endif /* CONFIG_NETFILTER_NETLINK_QUEUE */
 
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 647923a..ff82c79 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -502,12 +502,10 @@ err_out:
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
@@ -767,6 +765,8 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 	unsigned int verdict;
 	struct nf_queue_entry *entry;
 	struct nfq_ct_hook *nfq_ct;
+	enum ip_conntrack_info uninitialized_var(ctinfo);
+	struct nf_conn *ct = NULL;
 
 	queue = instance_lookup(queue_num);
 	if (!queue)
@@ -789,20 +789,23 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 	nfq_ct = rcu_dereference(nfq_ct_hook);
 	if (nfq_ct != NULL &&
 	    (queue->flags & NFQA_CFG_F_CONNTRACK) && nfqa[NFQA_CT]) {
-		enum ip_conntrack_info ctinfo;
-		struct nf_conn *ct;
-
 		ct = nf_ct_get(entry->skb, &ctinfo);
 		if (ct && !nf_ct_is_untracked(ct))
 			nfq_ct->parse(nfqa[NFQA_CT], ct);
 	}
-	rcu_read_unlock();
 
 	if (nfqa[NFQA_PAYLOAD]) {
+		u16 payload_len = nla_len(nfqa[NFQA_PAYLOAD]);
+		int diff = payload_len - entry->skb->len;
+
 		if (nfqnl_mangle(nla_data(nfqa[NFQA_PAYLOAD]),
-				 nla_len(nfqa[NFQA_PAYLOAD]), entry) < 0)
+				 payload_len, entry, diff) < 0)
 			verdict = NF_DROP;
+
+		if (ct && (ct->status & IPS_NAT_MASK) && diff)
+			nfq_ct->seq_adjust(skb, ct, ctinfo, diff);
 	}
+	rcu_read_unlock();
 
 	if (nfqa[NFQA_MARK])
 		entry->skb->mark = ntohl(nla_get_be32(nfqa[NFQA_MARK]));
-- 
1.7.10

