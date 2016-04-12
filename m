From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/8] netfilter: bridge: pass L2 header and VLAN as netlink attributes in queues to userspace
Date: Wed, 13 Apr 2016 01:02:41 +0200
Message-ID: <1460502166-20340-4-git-send-email-pablo@netfilter.org>
References: <1460502166-20340-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36497 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965778AbcDLXDD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2016 19:03:03 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 90C4BEAA9A
	for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 01:03:01 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 71C111B30BC
	for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 01:03:01 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 034F4AD88
	for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 01:02:58 +0200 (CEST)
In-Reply-To: <1460502166-20340-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephane Bryant <stephane.ml.bryant@gmail.com>

- This creates 2 netlink attribute NFQA_VLAN and NFQA_L2HDR.
- These are filled up for the PF_BRIDGE family on the way to userspace.
- NFQA_VLAN is a nested attribute, with the NFQA_VLAN_PROTO and the
  NFQA_VLAN_TCI carrying the corresponding vlan_proto and vlan_tci
  fields from the skb using big endian ordering (and using the CFI
  bit as the VLAN_TAG_PRESENT flag in vlan_tci as in the skb)

Signed-off-by: Stephane Bryant <stephane.ml.bryant@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nfnetlink_queue.h | 10 +++++
 net/netfilter/nfnetlink_queue.c                | 58 ++++++++++++++++++++++++++
 2 files changed, 68 insertions(+)

diff --git a/include/uapi/linux/netfilter/nfnetlink_queue.h b/include/uapi/linux/netfilter/nfnetlink_queue.h
index b67a853..ae30841 100644
--- a/include/uapi/linux/netfilter/nfnetlink_queue.h
+++ b/include/uapi/linux/netfilter/nfnetlink_queue.h
@@ -30,6 +30,14 @@ struct nfqnl_msg_packet_timestamp {
 	__aligned_be64	usec;
 };
 
+enum nfqnl_vlan_attr {
+	NFQA_VLAN_UNSPEC,
+	NFQA_VLAN_PROTO,		/* __be16 skb vlan_proto */
+	NFQA_VLAN_TCI,			/* __be16 skb htons(vlan_tci) */
+	__NFQA_VLAN_MAX,
+};
+#define NFQA_VLAN_MAX (__NFQA_VLAN_MAX + 1)
+
 enum nfqnl_attr_type {
 	NFQA_UNSPEC,
 	NFQA_PACKET_HDR,
@@ -50,6 +58,8 @@ enum nfqnl_attr_type {
 	NFQA_UID,			/* __u32 sk uid */
 	NFQA_GID,			/* __u32 sk gid */
 	NFQA_SECCTX,			/* security context string */
+	NFQA_VLAN,			/* nested attribute: packet vlan info */
+	NFQA_L2HDR,			/* full L2 header */
 
 	__NFQA_MAX
 };
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 7542999..6889c7c 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -295,6 +295,59 @@ static u32 nfqnl_get_sk_secctx(struct sk_buff *skb, char **secdata)
 	return seclen;
 }
 
+static u32 nfqnl_get_bridge_size(struct nf_queue_entry *entry)
+{
+	struct sk_buff *entskb = entry->skb;
+	u32 nlalen = 0;
+
+	if (entry->state.pf != PF_BRIDGE || !skb_mac_header_was_set(entskb))
+		return 0;
+
+	if (skb_vlan_tag_present(entskb))
+		nlalen += nla_total_size(nla_total_size(sizeof(__be16)) +
+					 nla_total_size(sizeof(__be16)));
+
+	if (entskb->network_header > entskb->mac_header)
+		nlalen += nla_total_size((entskb->network_header -
+					  entskb->mac_header));
+
+	return nlalen;
+}
+
+static int nfqnl_put_bridge(struct nf_queue_entry *entry, struct sk_buff *skb)
+{
+	struct sk_buff *entskb = entry->skb;
+
+	if (entry->state.pf != PF_BRIDGE || !skb_mac_header_was_set(entskb))
+		return 0;
+
+	if (skb_vlan_tag_present(entskb)) {
+		struct nlattr *nest;
+
+		nest = nla_nest_start(skb, NFQA_VLAN | NLA_F_NESTED);
+		if (!nest)
+			goto nla_put_failure;
+
+		if (nla_put_be16(skb, NFQA_VLAN_TCI, htons(entskb->vlan_tci)) ||
+		    nla_put_be16(skb, NFQA_VLAN_PROTO, entskb->vlan_proto))
+			goto nla_put_failure;
+
+		nla_nest_end(skb, nest);
+	}
+
+	if (entskb->mac_header < entskb->network_header) {
+		int len = (int)(entskb->network_header - entskb->mac_header);
+
+		if (nla_put(skb, NFQA_L2HDR, len, skb_mac_header(entskb)))
+			goto nla_put_failure;
+	}
+
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
 static struct sk_buff *
 nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 			   struct nf_queue_entry *entry,
@@ -334,6 +387,8 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 	if (entskb->tstamp.tv64)
 		size += nla_total_size(sizeof(struct nfqnl_msg_packet_timestamp));
 
+	size += nfqnl_get_bridge_size(entry);
+
 	if (entry->state.hook <= NF_INET_FORWARD ||
 	   (entry->state.hook == NF_INET_POST_ROUTING && entskb->sk == NULL))
 		csum_verify = !skb_csum_unnecessary(entskb);
@@ -497,6 +552,9 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 		}
 	}
 
+	if (nfqnl_put_bridge(entry, skb) < 0)
+		goto nla_put_failure;
+
 	if (entskb->tstamp.tv64) {
 		struct nfqnl_msg_packet_timestamp ts;
 		struct timespec64 kts = ktime_to_timespec64(skb->tstamp);
-- 
2.1.4
