From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/25] netfilter: cttimeout: unlink timeout obj again when hash resize happen
Date: Sat, 23 Jul 2016 13:08:17 +0200
Message-ID: <1469272119-29942-4-git-send-email-pablo@netfilter.org>
References: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35883 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751308AbcGWLJN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 07:09:13 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 9F04BE7DAD
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:12 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 9039BFAB53
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:12 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id A0807FAB52
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:10 +0200 (CEST)
In-Reply-To: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

Imagine such situation, nf_conntrack_htable_size now is 4096, we are doing
ctnl_untimeout, and iterate on 3000# bucket.

Meanwhile, another user try to reduce hash size to 2048, then all nf_conn
are removed to the new hashtable. When this hash resize operation finished,
we still try to itreate ct begin from 3000# bucket, find nothing to do and
just return.

We may miss unlinking some timeout objects. And later we will end up with
invalid references to timeout object that are already gone.

So when we find that hash resize happened, try to unlink timeout objects
from the 0# bucket again.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_cttimeout.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 3c84f14..4cdcd96 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -303,16 +303,24 @@ static void ctnl_untimeout(struct net *net, struct ctnl_timeout *timeout)
 {
 	struct nf_conntrack_tuple_hash *h;
 	const struct hlist_nulls_node *nn;
+	unsigned int last_hsize;
+	spinlock_t *lock;
 	int i;
 
 	local_bh_disable();
-	for (i = 0; i < nf_conntrack_htable_size; i++) {
-		nf_conntrack_lock(&nf_conntrack_locks[i % CONNTRACK_LOCKS]);
-		if (i < nf_conntrack_htable_size) {
-			hlist_nulls_for_each_entry(h, nn, &nf_conntrack_hash[i], hnnode)
-				untimeout(h, timeout);
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
+
+		hlist_nulls_for_each_entry(h, nn, &nf_conntrack_hash[i], hnnode)
+			untimeout(h, timeout);
+		spin_unlock(lock);
 	}
 	local_bh_enable();
 }
-- 
2.1.4
