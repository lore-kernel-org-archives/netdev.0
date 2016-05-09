From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 18/36] netfilter: conntrack: use nf_ct_key_equal() in more places
Date: Mon,  9 May 2016 20:46:36 +0200
Message-ID: <1462819614-5402-19-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45740 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752599AbcEISrX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 14:47:23 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 65FFBE8E91
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:22 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 4E3A2134728
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:22 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 495D5134712
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:20 +0200 (CEST)
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

This prepares for upcoming change that places all conntracks into a
single, global table.  For this to work we will need to also compare
net pointer during lookup.  To avoid open-coding such check use the
nf_ct_key_equal helper and then later extend it to also consider net_eq.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c | 29 +++++++++++------------------
 1 file changed, 11 insertions(+), 18 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index f2e75a5..3b9c302 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -572,16 +572,13 @@ nf_conntrack_hash_check_insert(struct nf_conn *ct)
 
 	/* See if there's one in the list already, including reverse */
 	hlist_nulls_for_each_entry(h, n, &net->ct.hash[hash], hnnode)
-		if (nf_ct_tuple_equal(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
-				      &h->tuple) &&
-		    nf_ct_zone_equal(nf_ct_tuplehash_to_ctrack(h), zone,
-				     NF_CT_DIRECTION(h)))
+		if (nf_ct_key_equal(h, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
+				    zone))
 			goto out;
+
 	hlist_nulls_for_each_entry(h, n, &net->ct.hash[reply_hash], hnnode)
-		if (nf_ct_tuple_equal(&ct->tuplehash[IP_CT_DIR_REPLY].tuple,
-				      &h->tuple) &&
-		    nf_ct_zone_equal(nf_ct_tuplehash_to_ctrack(h), zone,
-				     NF_CT_DIRECTION(h)))
+		if (nf_ct_key_equal(h, &ct->tuplehash[IP_CT_DIR_REPLY].tuple,
+				    zone))
 			goto out;
 
 	add_timer(&ct->timeout);
@@ -665,16 +662,13 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	   NAT could have grabbed it without realizing, since we're
 	   not in the hash.  If there is, we lost race. */
 	hlist_nulls_for_each_entry(h, n, &net->ct.hash[hash], hnnode)
-		if (nf_ct_tuple_equal(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
-				      &h->tuple) &&
-		    nf_ct_zone_equal(nf_ct_tuplehash_to_ctrack(h), zone,
-				     NF_CT_DIRECTION(h)))
+		if (nf_ct_key_equal(h, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
+				    zone))
 			goto out;
+
 	hlist_nulls_for_each_entry(h, n, &net->ct.hash[reply_hash], hnnode)
-		if (nf_ct_tuple_equal(&ct->tuplehash[IP_CT_DIR_REPLY].tuple,
-				      &h->tuple) &&
-		    nf_ct_zone_equal(nf_ct_tuplehash_to_ctrack(h), zone,
-				     NF_CT_DIRECTION(h)))
+		if (nf_ct_key_equal(h, &ct->tuplehash[IP_CT_DIR_REPLY].tuple,
+				    zone))
 			goto out;
 
 	/* Timer relative to confirmation time, not original
@@ -746,8 +740,7 @@ nf_conntrack_tuple_taken(const struct nf_conntrack_tuple *tuple,
 	hlist_nulls_for_each_entry_rcu(h, n, &ct_hash[hash], hnnode) {
 		ct = nf_ct_tuplehash_to_ctrack(h);
 		if (ct != ignored_conntrack &&
-		    nf_ct_tuple_equal(tuple, &h->tuple) &&
-		    nf_ct_zone_equal(ct, zone, NF_CT_DIRECTION(h))) {
+		    nf_ct_key_equal(h, tuple, zone)) {
 			NF_CT_STAT_INC_ATOMIC(net, found);
 			rcu_read_unlock();
 			return 1;
-- 
2.1.4
