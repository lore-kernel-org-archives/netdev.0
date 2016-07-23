From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/25] netfilter: nf_ct_helper: unlink helper again when hash resize happen
Date: Sat, 23 Jul 2016 13:08:18 +0200
Message-ID: <1469272119-29942-5-git-send-email-pablo@netfilter.org>
References: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35888 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751328AbcGWLJP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 07:09:15 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id C62E1E7DB0
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:13 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id B88E6DA8F3
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:13 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id BF481FC61A
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:11 +0200 (CEST)
In-Reply-To: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

From: Liping Zhang <liping.zhang@spreadtrum.com>

Similar to ctnl_untimeout, when hash resize happened, we should try
to do unhelp from the 0# bucket again.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_helper.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 3a1a88b..a4294e9 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -409,6 +409,8 @@ void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
 	struct nf_conntrack_expect *exp;
 	const struct hlist_node *next;
 	const struct hlist_nulls_node *nn;
+	unsigned int last_hsize;
+	spinlock_t *lock;
 	struct net *net;
 	unsigned int i;
 
@@ -446,13 +448,18 @@ void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
 	rtnl_unlock();
 
 	local_bh_disable();
-	for (i = 0; i < nf_conntrack_htable_size; i++) {
-		nf_conntrack_lock(&nf_conntrack_locks[i % CONNTRACK_LOCKS]);
-		if (i < nf_conntrack_htable_size) {
-			hlist_nulls_for_each_entry(h, nn, &nf_conntrack_hash[i], hnnode)
-				unhelp(h, me);
+restart:
+	last_hsize = nf_conntrack_htable_size;
+	for (i = 0; i < last_hsize; i++) {
+		lock = &nf_conntrack_locks[i % CONNTRACK_LOCKS];
+		nf_conntrack_lock(lock);
+		if (last_hsize != nf_conntrack_htable_size) {
+			spin_unlock(lock);
+			goto restart;
 		}
-		spin_unlock(&nf_conntrack_locks[i % CONNTRACK_LOCKS]);
+		hlist_nulls_for_each_entry(h, nn, &nf_conntrack_hash[i], hnnode)
+			unhelp(h, me);
+		spin_unlock(lock);
 	}
 	local_bh_enable();
 }
-- 
2.1.4
