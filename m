From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 26/36] netfilter: conntrack: introduce clash resolution on insertion race
Date: Mon,  9 May 2016 20:46:44 +0200
Message-ID: <1462819614-5402-27-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45739 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752706AbcEISra (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 14:47:30 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id EE79FE8E8D
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:28 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id DF50A13471B
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:28 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id AF717134715
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:26 +0200 (CEST)
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces nf_ct_resolve_clash() to resolve race condition on
conntrack insertions.

This is particularly a problem for connection-less protocols such as
UDP, with no initial handshake. Two or more packets may race to insert
the entry resulting in packet drops.

Another problematic scenario are packets enqueued to userspace via
NFQUEUE after the raw table, that make it easier to trigger this
race.

To resolve this, the idea is to reset the conntrack entry to the one
that won race. Packet and bytes counters are also merged.

The 'insert_failed' stats still accounts for this situation, after
this patch, the drop counter is bumped whenever we drop packets, so we
can watch for unresolved clashes.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_l4proto.h |  3 ++
 net/netfilter/nf_conntrack_core.c            | 53 ++++++++++++++++++++++++++--
 net/netfilter/nf_conntrack_proto_udp.c       |  2 ++
 net/netfilter/nf_conntrack_proto_udplite.c   |  2 ++
 4 files changed, 57 insertions(+), 3 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index 956d8a6..1a5fb36 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -23,6 +23,9 @@ struct nf_conntrack_l4proto {
 	/* L4 Protocol number. */
 	u_int8_t l4proto;
 
+	/* Resolve clashes on insertion races. */
+	bool allow_clash;
+
 	/* Try to fill in the third arg: dataoff is offset past network protocol
            hdr.  Return true if possible. */
 	bool (*pkt_to_tuple)(const struct sk_buff *skb, unsigned int dataoff,
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 25e0c26..f58a704 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -617,6 +617,48 @@ static inline void nf_ct_acct_update(struct nf_conn *ct,
 	}
 }
 
+static void nf_ct_acct_merge(struct nf_conn *ct, enum ip_conntrack_info ctinfo,
+			     const struct nf_conn *loser_ct)
+{
+	struct nf_conn_acct *acct;
+
+	acct = nf_conn_acct_find(loser_ct);
+	if (acct) {
+		struct nf_conn_counter *counter = acct->counter;
+		enum ip_conntrack_info ctinfo;
+		unsigned int bytes;
+
+		/* u32 should be fine since we must have seen one packet. */
+		bytes = atomic64_read(&counter[CTINFO2DIR(ctinfo)].bytes);
+		nf_ct_acct_update(ct, ctinfo, bytes);
+	}
+}
+
+/* Resolve race on insertion if this protocol allows this. */
+static int nf_ct_resolve_clash(struct net *net, struct sk_buff *skb,
+			       enum ip_conntrack_info ctinfo,
+			       struct nf_conntrack_tuple_hash *h)
+{
+	/* This is the conntrack entry already in hashes that won race. */
+	struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(h);
+	struct nf_conntrack_l4proto *l4proto;
+
+	l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
+	if (l4proto->allow_clash &&
+	    !nf_ct_is_dying(ct) &&
+	    atomic_inc_not_zero(&ct->ct_general.use)) {
+		nf_ct_acct_merge(ct, ctinfo, (struct nf_conn *)skb->nfct);
+		nf_conntrack_put(skb->nfct);
+		/* Assign conntrack already in hashes to this skbuff. Don't
+		 * modify skb->nfctinfo to ensure consistent stateful filtering.
+		 */
+		skb->nfct = &ct->ct_general;
+		return NF_ACCEPT;
+	}
+	NF_CT_STAT_INC(net, drop);
+	return NF_DROP;
+}
+
 /* Confirm a connection given skb; places it in hash table */
 int
 __nf_conntrack_confirm(struct sk_buff *skb)
@@ -631,6 +673,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	enum ip_conntrack_info ctinfo;
 	struct net *net;
 	unsigned int sequence;
+	int ret = NF_DROP;
 
 	ct = nf_ct_get(skb, &ctinfo);
 	net = nf_ct_net(ct);
@@ -673,8 +716,10 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	 */
 	nf_ct_del_from_dying_or_unconfirmed_list(ct);
 
-	if (unlikely(nf_ct_is_dying(ct)))
-		goto out;
+	if (unlikely(nf_ct_is_dying(ct))) {
+		nf_ct_add_to_dying_list(ct);
+		goto dying;
+	}
 
 	/* See if there's one in the list already, including reverse:
 	   NAT could have grabbed it without realizing, since we're
@@ -725,10 +770,12 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 
 out:
 	nf_ct_add_to_dying_list(ct);
+	ret = nf_ct_resolve_clash(net, skb, ctinfo, h);
+dying:
 	nf_conntrack_double_unlock(hash, reply_hash);
 	NF_CT_STAT_INC(net, insert_failed);
 	local_bh_enable();
-	return NF_DROP;
+	return ret;
 }
 EXPORT_SYMBOL_GPL(__nf_conntrack_confirm);
 
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 478f92f..4fd0405 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -309,6 +309,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp4 __read_mostly =
 	.l3proto		= PF_INET,
 	.l4proto		= IPPROTO_UDP,
 	.name			= "udp",
+	.allow_clash		= true,
 	.pkt_to_tuple		= udp_pkt_to_tuple,
 	.invert_tuple		= udp_invert_tuple,
 	.print_tuple		= udp_print_tuple,
@@ -341,6 +342,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp6 __read_mostly =
 	.l3proto		= PF_INET6,
 	.l4proto		= IPPROTO_UDP,
 	.name			= "udp",
+	.allow_clash		= true,
 	.pkt_to_tuple		= udp_pkt_to_tuple,
 	.invert_tuple		= udp_invert_tuple,
 	.print_tuple		= udp_print_tuple,
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 1ac8ee1..9d692f5 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -274,6 +274,7 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite4 __read_mostly =
 	.l3proto		= PF_INET,
 	.l4proto		= IPPROTO_UDPLITE,
 	.name			= "udplite",
+	.allow_clash		= true,
 	.pkt_to_tuple		= udplite_pkt_to_tuple,
 	.invert_tuple		= udplite_invert_tuple,
 	.print_tuple		= udplite_print_tuple,
@@ -306,6 +307,7 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite6 __read_mostly =
 	.l3proto		= PF_INET6,
 	.l4proto		= IPPROTO_UDPLITE,
 	.name			= "udplite",
+	.allow_clash		= true,
 	.pkt_to_tuple		= udplite_pkt_to_tuple,
 	.invert_tuple		= udplite_invert_tuple,
 	.print_tuple		= udplite_print_tuple,
-- 
2.1.4
