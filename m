From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/4] netlink: Use rhashtable walk iterator
Date: Wed, 04 Feb 2015 07:33:24 +1100
Message-ID: <E1YIkA0-00063W-Hi@gondolin.me.apana.org.au>
References: <20150203203213.GA23177@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:44964 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161148AbbBCUda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 15:33:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch gets rid of the manual rhashtable walk in netlink
which touches rhashtable internals that should not be exposed.
It does so by using the rhashtable iterator primitives.

In fact the existing code was very buggy.  Some sockets weren't
shown at all while others were shown more than once.
 
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/netlink/af_netlink.c |  130 +++++++++++++++++++++++------------------------
 1 file changed, 64 insertions(+), 66 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index a36777b..1558548 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2886,99 +2886,97 @@ EXPORT_SYMBOL(nlmsg_notify);
 #ifdef CONFIG_PROC_FS
 struct nl_seq_iter {
 	struct seq_net_private p;
+	struct rhashtable_iter hti;
 	int link;
-	int hash_idx;
 };
 
-static struct sock *netlink_seq_socket_idx(struct seq_file *seq, loff_t pos)
+static int netlink_walk_start(struct nl_seq_iter *iter)
 {
-	struct nl_seq_iter *iter = seq->private;
-	int i, j;
-	struct netlink_sock *nlk;
-	struct sock *s;
-	loff_t off = 0;
-
-	for (i = 0; i < MAX_LINKS; i++) {
-		struct rhashtable *ht = &nl_table[i].hash;
-		const struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
-
-		for (j = 0; j < tbl->size; j++) {
-			struct rhash_head *node;
-
-			rht_for_each_entry_rcu(nlk, node, tbl, j, node) {
-				s = (struct sock *)nlk;
+	int err;
 
-				if (sock_net(s) != seq_file_net(seq))
-					continue;
-				if (off == pos) {
-					iter->link = i;
-					iter->hash_idx = j;
-					return s;
-				}
-				++off;
-			}
-		}
+	err = rhashtable_walk_init(&nl_table[iter->link].hash, &iter->hti);
+	if (err) {
+		iter->link = MAX_LINKS;
+		return err;
 	}
-	return NULL;
+
+	err = rhashtable_walk_start(&iter->hti);
+	return err == -EAGAIN ? 0 : err;
 }
 
-static void *netlink_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(RCU)
+static void netlink_walk_stop(struct nl_seq_iter *iter)
 {
-	rcu_read_lock();
-	return *pos ? netlink_seq_socket_idx(seq, *pos - 1) : SEQ_START_TOKEN;
+	rhashtable_walk_stop(&iter->hti);
+	rhashtable_walk_exit(&iter->hti);
 }
 
-static void *netlink_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+static void *__netlink_seq_next(struct seq_file *seq)
 {
-	struct rhashtable *ht;
-	const struct bucket_table *tbl;
-	struct rhash_head *node;
+	struct nl_seq_iter *iter = seq->private;
 	struct netlink_sock *nlk;
-	struct nl_seq_iter *iter;
-	struct net *net;
-	int i, j;
 
-	++*pos;
+	do {
+		for (;;) {
+			int err;
 
-	if (v == SEQ_START_TOKEN)
-		return netlink_seq_socket_idx(seq, 0);
+			nlk = rhashtable_walk_next(&iter->hti);
 
-	net = seq_file_net(seq);
-	iter = seq->private;
-	nlk = v;
+			if (IS_ERR(nlk)) {
+				if (PTR_ERR(nlk) == -EAGAIN)
+					continue;
 
-	i = iter->link;
-	ht = &nl_table[i].hash;
-	tbl = rht_dereference_rcu(ht->tbl, ht);
-	rht_for_each_entry_rcu_continue(nlk, node, nlk->node.next, tbl, iter->hash_idx, node)
-		if (net_eq(sock_net((struct sock *)nlk), net))
-			return nlk;
+				return nlk;
+			}
 
-	j = iter->hash_idx + 1;
+			if (nlk)
+				break;
 
-	do {
+			netlink_walk_stop(iter);
+			if (++iter->link >= MAX_LINKS)
+				return NULL;
 
-		for (; j < tbl->size; j++) {
-			rht_for_each_entry_rcu(nlk, node, tbl, j, node) {
-				if (net_eq(sock_net((struct sock *)nlk), net)) {
-					iter->link = i;
-					iter->hash_idx = j;
-					return nlk;
-				}
-			}
+			err = netlink_walk_start(iter);
+			if (err)
+				return ERR_PTR(err);
 		}
+	} while (sock_net(&nlk->sk) != seq_file_net(seq));
 
-		j = 0;
-	} while (++i < MAX_LINKS);
+	return nlk;
+}
 
-	return NULL;
+static void *netlink_seq_start(struct seq_file *seq, loff_t *posp)
+{
+	struct nl_seq_iter *iter = seq->private;
+	void *obj = SEQ_START_TOKEN;
+	loff_t pos;
+	int err;
+
+	iter->link = 0;
+
+	err = netlink_walk_start(iter);
+	if (err)
+		return ERR_PTR(err);
+
+	for (pos = *posp; pos && obj && !IS_ERR(obj); pos--)
+		obj = __netlink_seq_next(seq);
+
+	return obj;
+}
+
+static void *netlink_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	++*pos;
+	return __netlink_seq_next(seq);
 }
 
 static void netlink_seq_stop(struct seq_file *seq, void *v)
-	__releases(RCU)
 {
-	rcu_read_unlock();
+	struct nl_seq_iter *iter = seq->private;
+
+	if (iter->link >= MAX_LINKS)
+		return;
+
+	netlink_walk_stop(iter);
 }
 
 
