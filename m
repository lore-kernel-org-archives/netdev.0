From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net PATCH 1/2] ipv4: Restore fib_trie_flush_external function and
 fix call ordering
Date: Tue, 15 Nov 2016 05:46:06 -0500
Message-ID: <20161115104606.13711.37506.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161115104306.13711.67911.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, Jiri Pirko <jiri@mellanox.com>,
        davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24207 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752246AbcKOQrU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 11:47:20 -0500
In-Reply-To: <20161115104306.13711.67911.stgit@ahduyck-blue-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch that removed the FIB offload infrastructure was a bit too
aggressive and also removed code needed to clean up us splitting the table
if additional rules were added.  Specifically the function
fib_trie_flush_external was called at the end of a new rule being added to
flush the foreign trie entries from the main trie.

I updated the code so that we only call fib_trie_flush_external on the main
table so that we flush the entries for local from main.  This way we don't
call it for every rule change which is what was happening previously.

Fixes: 347e3b28c1ba2 ("switchdev: remove FIB offload infrastructure")
Reported-by: Eric Dumazet <edumazet@google.com>
Cc: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 include/net/ip_fib.h    |    1 +
 net/ipv4/fib_frontend.c |   20 +++++++++++---
 net/ipv4/fib_trie.c     |   65 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 81 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index b9314b4..f390c3b 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -243,6 +243,7 @@ int fib_table_dump(struct fib_table *table, struct sk_buff *skb,
 		   struct netlink_callback *cb);
 int fib_table_flush(struct net *net, struct fib_table *table);
 struct fib_table *fib_trie_unmerge(struct fib_table *main_tb);
+void fib_table_flush_external(struct fib_table *table);
 void fib_free_table(struct fib_table *tb);
 
 #ifndef CONFIG_IP_MULTIPLE_TABLES
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index c3b8047..161fc0f 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -151,7 +151,7 @@ static void fib_replace_table(struct net *net, struct fib_table *old,
 
 int fib_unmerge(struct net *net)
 {
-	struct fib_table *old, *new;
+	struct fib_table *old, *new, *main_table;
 
 	/* attempt to fetch local table if it has been allocated */
 	old = fib_get_table(net, RT_TABLE_LOCAL);
@@ -162,11 +162,21 @@ int fib_unmerge(struct net *net)
 	if (!new)
 		return -ENOMEM;
 
+	/* table is already unmerged */
+	if (new == old)
+		return 0;
+
 	/* replace merged table with clean table */
-	if (new != old) {
-		fib_replace_table(net, old, new);
-		fib_free_table(old);
-	}
+	fib_replace_table(net, old, new);
+	fib_free_table(old);
+
+	/* attempt to fetch main table if it has been allocated */
+	main_table = fib_get_table(net, RT_TABLE_MAIN);
+	if (!main_table)
+		return 0;
+
+	/* flush local entries from main table */
+	fib_table_flush_external(main_table);
 
 	return 0;
 }
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 4cff74d..735edc9 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1760,6 +1760,71 @@ struct fib_table *fib_trie_unmerge(struct fib_table *oldtb)
 	return NULL;
 }
 
+/* Caller must hold RTNL */
+void fib_table_flush_external(struct fib_table *tb)
+{
+	struct trie *t = (struct trie *)tb->tb_data;
+	struct key_vector *pn = t->kv;
+	unsigned long cindex = 1;
+	struct hlist_node *tmp;
+	struct fib_alias *fa;
+
+	/* walk trie in reverse order */
+	for (;;) {
+		unsigned char slen = 0;
+		struct key_vector *n;
+
+		if (!(cindex--)) {
+			t_key pkey = pn->key;
+
+			/* cannot resize the trie vector */
+			if (IS_TRIE(pn))
+				break;
+
+			/* resize completed node */
+			pn = resize(t, pn);
+			cindex = get_index(pkey, pn);
+
+			continue;
+		}
+
+		/* grab the next available node */
+		n = get_child(pn, cindex);
+		if (!n)
+			continue;
+
+		if (IS_TNODE(n)) {
+			/* record pn and cindex for leaf walking */
+			pn = n;
+			cindex = 1ul << n->bits;
+
+			continue;
+		}
+
+		hlist_for_each_entry_safe(fa, tmp, &n->leaf, fa_list) {
+			/* if alias was cloned to local then we just
+			 * need to remove the local copy from main
+			 */
+			if (tb->tb_id != fa->tb_id) {
+				hlist_del_rcu(&fa->fa_list);
+				alias_free_mem_rcu(fa);
+				continue;
+			}
+
+			/* record local slen */
+			slen = fa->fa_slen;
+		}
+
+		/* update leaf slen */
+		n->slen = slen;
+
+		if (hlist_empty(&n->leaf)) {
+			put_child_root(pn, n->key, NULL);
+			node_free(n);
+		}
+	}
+}
+
 /* Caller must hold RTNL. */
 int fib_table_flush(struct net *net, struct fib_table *tb)
 {
