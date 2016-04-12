From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/8] netfilter: bridge: nf queue verdict to use NFQA_VLAN and NFQA_L2HDR
Date: Wed, 13 Apr 2016 01:02:42 +0200
Message-ID: <1460502166-20340-5-git-send-email-pablo@netfilter.org>
References: <1460502166-20340-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1460502166-20340-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephane Bryant <stephane.ml.bryant@gmail.com>

This makes nf queues use NFQA_VLAN and NFQA_L2HDR in verdict to modify the
original skb

Signed-off-by: Stephane Bryant <stephane.ml.bryant@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_queue.c | 47 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 6889c7c..5bebe78 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -964,12 +964,18 @@ static struct notifier_block nfqnl_rtnl_notifier = {
 	.notifier_call	= nfqnl_rcv_nl_event,
 };
 
+static const struct nla_policy nfqa_vlan_policy[NFQA_VLAN_MAX + 1] = {
+	[NFQA_VLAN_TCI]		= { .type = NLA_U16},
+	[NFQA_VLAN_PROTO]	= { .type = NLA_U16},
+};
+
 static const struct nla_policy nfqa_verdict_policy[NFQA_MAX+1] = {
 	[NFQA_VERDICT_HDR]	= { .len = sizeof(struct nfqnl_msg_verdict_hdr) },
 	[NFQA_MARK]		= { .type = NLA_U32 },
 	[NFQA_PAYLOAD]		= { .type = NLA_UNSPEC },
 	[NFQA_CT]		= { .type = NLA_UNSPEC },
 	[NFQA_EXP]		= { .type = NLA_UNSPEC },
+	[NFQA_VLAN]		= { .type = NLA_NESTED },
 };
 
 static const struct nla_policy nfqa_verdict_batch_policy[NFQA_MAX+1] = {
@@ -1083,6 +1089,40 @@ static struct nf_conn *nfqnl_ct_parse(struct nfnl_ct_hook *nfnl_ct,
 	return ct;
 }
 
+static int nfqa_parse_bridge(struct nf_queue_entry *entry,
+			     const struct nlattr * const nfqa[])
+{
+	if (nfqa[NFQA_VLAN]) {
+		struct nlattr *tb[NFQA_VLAN_MAX + 1];
+		int err;
+
+		err = nla_parse_nested(tb, NFQA_VLAN_MAX, nfqa[NFQA_VLAN],
+				       nfqa_vlan_policy);
+		if (err < 0)
+			return err;
+
+		if (!tb[NFQA_VLAN_TCI] || !tb[NFQA_VLAN_PROTO])
+			return -EINVAL;
+
+		entry->skb->vlan_tci = ntohs(nla_get_be16(tb[NFQA_VLAN_TCI]));
+		entry->skb->vlan_proto = nla_get_be16(tb[NFQA_VLAN_PROTO]);
+	}
+
+	if (nfqa[NFQA_L2HDR]) {
+		int mac_header_len = entry->skb->network_header -
+			entry->skb->mac_header;
+
+		if (mac_header_len != nla_len(nfqa[NFQA_L2HDR]))
+			return -EINVAL;
+		else if (mac_header_len > 0)
+			memcpy(skb_mac_header(entry->skb),
+			       nla_data(nfqa[NFQA_L2HDR]),
+			       mac_header_len);
+	}
+
+	return 0;
+}
+
 static int nfqnl_recv_verdict(struct net *net, struct sock *ctnl,
 			      struct sk_buff *skb,
 			      const struct nlmsghdr *nlh,
@@ -1098,6 +1138,7 @@ static int nfqnl_recv_verdict(struct net *net, struct sock *ctnl,
 	struct nfnl_ct_hook *nfnl_ct;
 	struct nf_conn *ct = NULL;
 	struct nfnl_queue_net *q = nfnl_queue_pernet(net);
+	int err;
 
 	queue = instance_lookup(q, queue_num);
 	if (!queue)
@@ -1124,6 +1165,12 @@ static int nfqnl_recv_verdict(struct net *net, struct sock *ctnl,
 			ct = nfqnl_ct_parse(nfnl_ct, nlh, nfqa, entry, &ctinfo);
 	}
 
+	if (entry->state.pf == PF_BRIDGE) {
+		err = nfqa_parse_bridge(entry, nfqa);
+		if (err < 0)
+			return err;
+	}
+
 	if (nfqa[NFQA_PAYLOAD]) {
 		u16 payload_len = nla_len(nfqa[NFQA_PAYLOAD]);
 		int diff = payload_len - entry->skb->len;
-- 
2.1.4

