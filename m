From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/2] netlink: Use rhashtable walk iterator
Date: Mon, 26 Jan 2015 10:21:33 +1100
Message-ID: <E1YFWUn-0004gX-6e@gondolin.me.apana.org.au>
References: <20150125232040.GA17936@gondor.apana.org.au>
To: Thomas Graf <tgraf@suug.ch>, Ying Xue <ying.xue@windriver.com>,
	davem@davemloft.net, kaber@trash.net, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:60779 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbbAYXVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 18:21:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch gets rid of the manual rhashtable walk in netlink
which touches rhashtable internals that should not be exposed.
It does so by using the rhashtable iterator primitives.

In fact the existing code was very buggy.  Some sockets weren't
shown at all while others were shown more than once.
 
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/netlink/af_netlink.c |  113 +++++++++++++++++------------------------------
 1 file changed, 41 insertions(+), 72 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index d77b346..6f8549e 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2884,99 +2884,68 @@ EXPORT_SYMBOL(nlmsg_notify);
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
-
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
-	}
-	return NULL;
-}
-
-static void *netlink_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(RCU)
-{
-	rcu_read_lock();
-	return *pos ? netlink_seq_socket_idx(seq, *pos - 1) : SEQ_START_TOKEN;
+	rhashtable_walk_init(&nl_table[iter->link].hash, &iter->hti);
+	return rhashtable_walk_start(&iter->hti);
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
+		while (!(nlk = rhashtable_walk_next(&iter->hti))) {
+			int err;
 
-	if (v == SEQ_START_TOKEN)
-		return netlink_seq_socket_idx(seq, 0);
+			rhashtable_walk_stop(&iter->hti);
+			if (++iter->link >= MAX_LINKS)
+				return NULL;
 
-	net = seq_file_net(seq);
-	iter = seq->private;
-	nlk = v;
+			err = netlink_walk_start(iter);
+			if (err)
+				return ERR_PTR(err);
+		}
+	} while (sock_net(&nlk->sk) != seq_file_net(seq));
 
-	i = iter->link;
-	ht = &nl_table[i].hash;
-	tbl = rht_dereference_rcu(ht->tbl, ht);
-	rht_for_each_entry_rcu_continue(nlk, node, nlk->node.next, tbl, iter->hash_idx, node)
-		if (net_eq(sock_net((struct sock *)nlk), net))
-			return nlk;
+	return nlk;
+}
 
-	j = iter->hash_idx + 1;
+static void *netlink_seq_start(struct seq_file *seq, loff_t *posp)
+{
+	struct nl_seq_iter *iter = seq->private;
+	void *obj = SEQ_START_TOKEN;
+	loff_t pos;
+	int err;
 
-	do {
+	iter->link = 0;
+	err = netlink_walk_start(iter);
+	if (err)
+		return ERR_PTR(err);
 
-		for (; j < tbl->size; j++) {
-			rht_for_each_entry_rcu(nlk, node, tbl, j, node) {
-				if (net_eq(sock_net((struct sock *)nlk), net)) {
-					iter->link = i;
-					iter->hash_idx = j;
-					return nlk;
-				}
-			}
-		}
+	for (pos = *posp; pos && obj; pos--)
+		obj = __netlink_seq_next(seq);
 
-		j = 0;
-	} while (++i < MAX_LINKS);
+	return obj;
+}
 
-	return NULL;
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
+	if (iter->link < MAX_LINKS)
+		rhashtable_walk_stop(&iter->hti);
 }
 
 
