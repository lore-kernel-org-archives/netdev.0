From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/22] netfilter: nf_conntrack: reduce resolve_normal_ct args
Date: Mon, 20 Mar 2017 11:08:41 +0100
Message-ID: <1490004530-9128-14-git-send-email-pablo@netfilter.org>
References: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52080 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753339AbdCTKJj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 06:09:39 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id F27385232A
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:13 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id E1B67DA86F
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:13 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D3C59DA872
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:10 +0100 (CET)
In-Reply-To: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

also mark init_conntrack noinline, in most cases resolve_normal_ct will
find an existing conntrack entry.

text    data     bss     dec     hex filename
16735    5707     176   22618    585a net/netfilter/nf_conntrack_core.o
16687    5707     176   22570    582a net/netfilter/nf_conntrack_core.o

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c | 57 ++++++++++++++++++---------------------
 1 file changed, 26 insertions(+), 31 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 071b97fcbefb..b0f2e8e65084 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1129,7 +1129,7 @@ EXPORT_SYMBOL_GPL(nf_conntrack_free);
 
 /* Allocate a new conntrack: we return -ENOMEM if classification
    failed due to stress.  Otherwise it really is unclassifiable. */
-static struct nf_conntrack_tuple_hash *
+static noinline struct nf_conntrack_tuple_hash *
 init_conntrack(struct net *net, struct nf_conn *tmpl,
 	       const struct nf_conntrack_tuple *tuple,
 	       struct nf_conntrack_l3proto *l3proto,
@@ -1237,21 +1237,20 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 	return &ct->tuplehash[IP_CT_DIR_ORIGINAL];
 }
 
-/* On success, returns conntrack ptr, sets skb->_nfct | ctinfo */
-static inline struct nf_conn *
+/* On success, returns 0, sets skb->_nfct | ctinfo */
+static int
 resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 		  struct sk_buff *skb,
 		  unsigned int dataoff,
 		  u_int16_t l3num,
 		  u_int8_t protonum,
 		  struct nf_conntrack_l3proto *l3proto,
-		  struct nf_conntrack_l4proto *l4proto,
-		  int *set_reply,
-		  enum ip_conntrack_info *ctinfo)
+		  struct nf_conntrack_l4proto *l4proto)
 {
 	const struct nf_conntrack_zone *zone;
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_tuple_hash *h;
+	enum ip_conntrack_info ctinfo;
 	struct nf_conntrack_zone tmp;
 	struct nf_conn *ct;
 	u32 hash;
@@ -1260,7 +1259,7 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 			     dataoff, l3num, protonum, net, &tuple, l3proto,
 			     l4proto)) {
 		pr_debug("Can't get tuple\n");
-		return NULL;
+		return 0;
 	}
 
 	/* look for tuple match */
@@ -1271,33 +1270,30 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 		h = init_conntrack(net, tmpl, &tuple, l3proto, l4proto,
 				   skb, dataoff, hash);
 		if (!h)
-			return NULL;
+			return 0;
 		if (IS_ERR(h))
-			return (void *)h;
+			return PTR_ERR(h);
 	}
 	ct = nf_ct_tuplehash_to_ctrack(h);
 
 	/* It exists; we have (non-exclusive) reference. */
 	if (NF_CT_DIRECTION(h) == IP_CT_DIR_REPLY) {
-		*ctinfo = IP_CT_ESTABLISHED_REPLY;
-		/* Please set reply bit if this packet OK */
-		*set_reply = 1;
+		ctinfo = IP_CT_ESTABLISHED_REPLY;
 	} else {
 		/* Once we've had two way comms, always ESTABLISHED. */
 		if (test_bit(IPS_SEEN_REPLY_BIT, &ct->status)) {
 			pr_debug("normal packet for %p\n", ct);
-			*ctinfo = IP_CT_ESTABLISHED;
+			ctinfo = IP_CT_ESTABLISHED;
 		} else if (test_bit(IPS_EXPECTED_BIT, &ct->status)) {
 			pr_debug("related packet for %p\n", ct);
-			*ctinfo = IP_CT_RELATED;
+			ctinfo = IP_CT_RELATED;
 		} else {
 			pr_debug("new packet for %p\n", ct);
-			*ctinfo = IP_CT_NEW;
+			ctinfo = IP_CT_NEW;
 		}
-		*set_reply = 0;
 	}
-	nf_ct_set(skb, ct, *ctinfo);
-	return ct;
+	nf_ct_set(skb, ct, ctinfo);
+	return 0;
 }
 
 unsigned int
@@ -1311,7 +1307,6 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	unsigned int *timeouts;
 	unsigned int dataoff;
 	u_int8_t protonum;
-	int set_reply = 0;
 	int ret;
 
 	tmpl = nf_ct_get(skb, &ctinfo);
@@ -1354,23 +1349,22 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 			goto out;
 	}
 repeat:
-	ct = resolve_normal_ct(net, tmpl, skb, dataoff, pf, protonum,
-			       l3proto, l4proto, &set_reply, &ctinfo);
-	if (!ct) {
-		/* Not valid part of a connection */
-		NF_CT_STAT_INC_ATOMIC(net, invalid);
-		ret = NF_ACCEPT;
-		goto out;
-	}
-
-	if (IS_ERR(ct)) {
+	ret = resolve_normal_ct(net, tmpl, skb, dataoff, pf, protonum,
+				l3proto, l4proto);
+	if (ret < 0) {
 		/* Too stressed to deal. */
 		NF_CT_STAT_INC_ATOMIC(net, drop);
 		ret = NF_DROP;
 		goto out;
 	}
 
-	NF_CT_ASSERT(skb_nfct(skb));
+	ct = nf_ct_get(skb, &ctinfo);
+	if (!ct) {
+		/* Not valid part of a connection */
+		NF_CT_STAT_INC_ATOMIC(net, invalid);
+		ret = NF_ACCEPT;
+		goto out;
+	}
 
 	/* Decide what timeout policy we want to apply to this flow. */
 	timeouts = nf_ct_timeout_lookup(net, ct, l4proto);
@@ -1395,7 +1389,8 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 		goto out;
 	}
 
-	if (set_reply && !test_and_set_bit(IPS_SEEN_REPLY_BIT, &ct->status))
+	if (ctinfo == IP_CT_ESTABLISHED_REPLY &&
+	    !test_and_set_bit(IPS_SEEN_REPLY_BIT, &ct->status))
 		nf_conntrack_event_cache(IPCT_REPLY, ct);
 out:
 	if (tmpl)
-- 
2.1.4
