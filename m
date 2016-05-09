From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 32/36] netfilter: conntrack: make netns address part of expect hash
Date: Mon,  9 May 2016 20:46:50 +0200
Message-ID: <1462819614-5402-33-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45821 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752820AbcEISrg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 14:47:36 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 5AE69E8E87
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:34 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 4832913470E
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:34 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 1CAFB134729
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:32 +0200 (CEST)
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_expect.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index da95d74..130f1be 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -24,6 +24,7 @@
 #include <linux/moduleparam.h>
 #include <linux/export.h>
 #include <net/net_namespace.h>
+#include <net/netns/hash.h>
 
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_core.h>
@@ -73,15 +74,17 @@ static void nf_ct_expectation_timed_out(unsigned long ul_expect)
 	nf_ct_expect_put(exp);
 }
 
-static unsigned int nf_ct_expect_dst_hash(const struct nf_conntrack_tuple *tuple)
+static unsigned int nf_ct_expect_dst_hash(const struct net *n, const struct nf_conntrack_tuple *tuple)
 {
-	unsigned int hash;
+	unsigned int hash, seed;
 
 	get_random_once(&nf_ct_expect_hashrnd, sizeof(nf_ct_expect_hashrnd));
 
+	seed = nf_ct_expect_hashrnd ^ net_hash_mix(n);
+
 	hash = jhash2(tuple->dst.u3.all, ARRAY_SIZE(tuple->dst.u3.all),
 		      (((tuple->dst.protonum ^ tuple->src.l3num) << 16) |
-		       (__force __u16)tuple->dst.u.all) ^ nf_ct_expect_hashrnd);
+		       (__force __u16)tuple->dst.u.all) ^ seed);
 
 	return reciprocal_scale(hash, nf_ct_expect_hsize);
 }
@@ -108,7 +111,7 @@ __nf_ct_expect_find(struct net *net,
 	if (!net->ct.expect_count)
 		return NULL;
 
-	h = nf_ct_expect_dst_hash(tuple);
+	h = nf_ct_expect_dst_hash(net, tuple);
 	hlist_for_each_entry_rcu(i, &net->ct.expect_hash[h], hnode) {
 		if (nf_ct_exp_equal(tuple, i, zone, net))
 			return i;
@@ -148,7 +151,7 @@ nf_ct_find_expectation(struct net *net,
 	if (!net->ct.expect_count)
 		return NULL;
 
-	h = nf_ct_expect_dst_hash(tuple);
+	h = nf_ct_expect_dst_hash(net, tuple);
 	hlist_for_each_entry(i, &net->ct.expect_hash[h], hnode) {
 		if (!(i->flags & NF_CT_EXPECT_INACTIVE) &&
 		    nf_ct_exp_equal(tuple, i, zone, net)) {
@@ -352,7 +355,7 @@ static int nf_ct_expect_insert(struct nf_conntrack_expect *exp)
 	struct nf_conn_help *master_help = nfct_help(exp->master);
 	struct nf_conntrack_helper *helper;
 	struct net *net = nf_ct_exp_net(exp);
-	unsigned int h = nf_ct_expect_dst_hash(&exp->tuple);
+	unsigned int h = nf_ct_expect_dst_hash(net, &exp->tuple);
 
 	/* two references : one for hash insert, one for the timer */
 	atomic_add(2, &exp->use);
@@ -411,7 +414,7 @@ static inline int __nf_ct_expect_check(struct nf_conntrack_expect *expect)
 		ret = -ESHUTDOWN;
 		goto out;
 	}
-	h = nf_ct_expect_dst_hash(&expect->tuple);
+	h = nf_ct_expect_dst_hash(net, &expect->tuple);
 	hlist_for_each_entry_safe(i, next, &net->ct.expect_hash[h], hnode) {
 		if (expect_matches(i, expect)) {
 			if (del_timer(&i->timeout)) {
-- 
2.1.4
