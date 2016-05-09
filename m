From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 20/36] netfilter: conntrack: check netns when comparing conntrack objects
Date: Mon,  9 May 2016 20:46:38 +0200
Message-ID: <1462819614-5402-21-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45732 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752633AbcEISrZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 14:47:25 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 4421FE8E8F
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:24 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 242AC13471F
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:24 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id F058D134711
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:21 +0200 (CEST)
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Once we place all conntracks in the same hash table we must also compare
the netns pointer to skip conntracks that belong to a different namespace.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   |  8 ++++++--
 net/netfilter/nf_conntrack_core.c                  | 23 ++++++++++++----------
 net/netfilter/nf_conntrack_netlink.c               |  3 +++
 3 files changed, 22 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index 483cf79..171aba1 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -115,6 +115,7 @@ static inline void ct_show_secctx(struct seq_file *s, const struct nf_conn *ct)
 #endif
 
 static bool ct_seq_should_skip(const struct nf_conn *ct,
+			       const struct net *net,
 			       const struct nf_conntrack_tuple_hash *hash)
 {
 	/* we only want to print DIR_ORIGINAL */
@@ -124,6 +125,9 @@ static bool ct_seq_should_skip(const struct nf_conn *ct,
 	if (nf_ct_l3num(ct) != AF_INET)
 		return true;
 
+	if (!net_eq(nf_ct_net(ct), net))
+		return true;
+
 	return false;
 }
 
@@ -136,7 +140,7 @@ static int ct_seq_show(struct seq_file *s, void *v)
 	int ret = 0;
 
 	NF_CT_ASSERT(ct);
-	if (ct_seq_should_skip(ct, hash))
+	if (ct_seq_should_skip(ct, seq_file_net(s), hash))
 		return 0;
 
 	if (unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
@@ -144,7 +148,7 @@ static int ct_seq_show(struct seq_file *s, void *v)
 
 	/* check if we raced w. object reuse */
 	if (!nf_ct_is_confirmed(ct) ||
-	    ct_seq_should_skip(ct, hash))
+	    ct_seq_should_skip(ct, seq_file_net(s), hash))
 		goto release;
 
 	l3proto = __nf_ct_l3proto_find(nf_ct_l3num(ct));
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 3b9c302..10ae2ee 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -447,7 +447,8 @@ static void death_by_timeout(unsigned long ul_conntrack)
 static inline bool
 nf_ct_key_equal(struct nf_conntrack_tuple_hash *h,
 		const struct nf_conntrack_tuple *tuple,
-		const struct nf_conntrack_zone *zone)
+		const struct nf_conntrack_zone *zone,
+		const struct net *net)
 {
 	struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(h);
 
@@ -456,7 +457,8 @@ nf_ct_key_equal(struct nf_conntrack_tuple_hash *h,
 	 */
 	return nf_ct_tuple_equal(tuple, &h->tuple) &&
 	       nf_ct_zone_equal(ct, zone, NF_CT_DIRECTION(h)) &&
-	       nf_ct_is_confirmed(ct);
+	       nf_ct_is_confirmed(ct) &&
+	       net_eq(net, nf_ct_net(ct));
 }
 
 /*
@@ -481,7 +483,7 @@ begin:
 	} while (read_seqcount_retry(&nf_conntrack_generation, sequence));
 
 	hlist_nulls_for_each_entry_rcu(h, n, &ct_hash[bucket], hnnode) {
-		if (nf_ct_key_equal(h, tuple, zone)) {
+		if (nf_ct_key_equal(h, tuple, zone, net)) {
 			NF_CT_STAT_INC_ATOMIC(net, found);
 			return h;
 		}
@@ -517,7 +519,7 @@ begin:
 			     !atomic_inc_not_zero(&ct->ct_general.use)))
 			h = NULL;
 		else {
-			if (unlikely(!nf_ct_key_equal(h, tuple, zone))) {
+			if (unlikely(!nf_ct_key_equal(h, tuple, zone, net))) {
 				nf_ct_put(ct);
 				goto begin;
 			}
@@ -573,12 +575,12 @@ nf_conntrack_hash_check_insert(struct nf_conn *ct)
 	/* See if there's one in the list already, including reverse */
 	hlist_nulls_for_each_entry(h, n, &net->ct.hash[hash], hnnode)
 		if (nf_ct_key_equal(h, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
-				    zone))
+				    zone, net))
 			goto out;
 
 	hlist_nulls_for_each_entry(h, n, &net->ct.hash[reply_hash], hnnode)
 		if (nf_ct_key_equal(h, &ct->tuplehash[IP_CT_DIR_REPLY].tuple,
-				    zone))
+				    zone, net))
 			goto out;
 
 	add_timer(&ct->timeout);
@@ -663,12 +665,12 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	   not in the hash.  If there is, we lost race. */
 	hlist_nulls_for_each_entry(h, n, &net->ct.hash[hash], hnnode)
 		if (nf_ct_key_equal(h, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
-				    zone))
+				    zone, net))
 			goto out;
 
 	hlist_nulls_for_each_entry(h, n, &net->ct.hash[reply_hash], hnnode)
 		if (nf_ct_key_equal(h, &ct->tuplehash[IP_CT_DIR_REPLY].tuple,
-				    zone))
+				    zone, net))
 			goto out;
 
 	/* Timer relative to confirmation time, not original
@@ -740,7 +742,7 @@ nf_conntrack_tuple_taken(const struct nf_conntrack_tuple *tuple,
 	hlist_nulls_for_each_entry_rcu(h, n, &ct_hash[hash], hnnode) {
 		ct = nf_ct_tuplehash_to_ctrack(h);
 		if (ct != ignored_conntrack &&
-		    nf_ct_key_equal(h, tuple, zone)) {
+		    nf_ct_key_equal(h, tuple, zone, net)) {
 			NF_CT_STAT_INC_ATOMIC(net, found);
 			rcu_read_unlock();
 			return 1;
@@ -1383,7 +1385,8 @@ get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
 				if (NF_CT_DIRECTION(h) != IP_CT_DIR_ORIGINAL)
 					continue;
 				ct = nf_ct_tuplehash_to_ctrack(h);
-				if (iter(ct, data))
+				if (net_eq(nf_ct_net(ct), net) &&
+				    iter(ct, data))
 					goto found;
 			}
 		}
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 294a8e2..f6bbcb2 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -837,6 +837,9 @@ restart:
 			if (NF_CT_DIRECTION(h) != IP_CT_DIR_ORIGINAL)
 				continue;
 			ct = nf_ct_tuplehash_to_ctrack(h);
+			if (!net_eq(net, nf_ct_net(ct)))
+				continue;
+
 			/* Dump entries of a given L3 protocol number.
 			 * If it is not specified, ie. l3proto == 0,
 			 * then dump everything. */
-- 
2.1.4
