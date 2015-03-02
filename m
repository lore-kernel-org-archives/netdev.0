From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 3/6] fib_trie: Fib find node should return parent
Date: Mon, 02 Mar 2015 13:32:35 -0800
Message-ID: <20150302213235.1490.88546.stgit@ahduyck-vm-fedora20>
References: <20150302212637.1490.33609.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44900 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755009AbbCBVch (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2015 16:32:37 -0500
In-Reply-To: <20150302212637.1490.33609.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that the parent pointer is returned by reference in
fib_find_node.  By doing this I can use it to find the parent node when I
am performing an insertion and I don't have to look for it again in
fib_insert_node.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 5f8081f..6b9cc70 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -912,10 +912,12 @@ static void fib_insert_alias(struct tnode *l, struct fib_alias *fa,
 }
 
 /* rcu_read_lock needs to be hold by caller from readside */
-static struct tnode *fib_find_node(struct trie *t, u32 key)
+static struct tnode *fib_find_node(struct trie *t, struct tnode **tp, u32 key)
 {
 	struct tnode *n = rcu_dereference_rtnl(t->trie);
 
+	*tp = NULL;
+
 	while (n) {
 		unsigned long index = get_index(key, n);
 
@@ -936,6 +938,7 @@ static struct tnode *fib_find_node(struct trie *t, u32 key)
 		if (IS_LEAF(n))
 			break;
 
+		*tp = n;
 		n = tnode_get_child_rcu(n, index);
 	}
 
@@ -1071,15 +1074,15 @@ static struct tnode *fib_insert_node(struct trie *t, u32 key, int plen)
  */
 int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 {
-	struct trie *t = (struct trie *) tb->tb_data;
+	struct trie *t = (struct trie *)tb->tb_data;
 	struct fib_alias *fa, *new_fa;
+	struct tnode *l, *tp;
 	struct fib_info *fi;
 	u8 plen = cfg->fc_dst_len;
 	u8 slen = KEYLENGTH - plen;
 	u8 tos = cfg->fc_tos;
-	u32 key, mask;
+	u32 key;
 	int err;
-	struct tnode *l;
 
 	if (plen > KEYLENGTH)
 		return -EINVAL;
@@ -1088,9 +1091,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 
 	pr_debug("Insert table=%u %08x/%d\n", tb->tb_id, key, plen);
 
-	mask = ntohl(inet_make_mask(plen));
-
-	if (key & ~mask)
+	if ((plen < KEYLENGTH) && (key << plen))
 		return -EINVAL;
 
 	fi = fib_create_info(cfg);
@@ -1099,7 +1100,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 		goto err;
 	}
 
-	l = fib_find_node(t, key);
+	l = fib_find_node(t, &tp, key);
 	fa = l ? fib_find_alias(&l->leaf, slen, tos, fi->fib_priority) : NULL;
 
 	/* Now fa, if non-NULL, points to the first fib alias
@@ -1406,22 +1407,21 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
 	struct fib_alias *fa, *fa_to_delete;
+	struct tnode *l, *tp;
 	u8 plen = cfg->fc_dst_len;
-	u8 tos = cfg->fc_tos;
 	u8 slen = KEYLENGTH - plen;
-	struct tnode *l;
-	u32 key, mask;
+	u8 tos = cfg->fc_tos;
+	u32 key;
 
 	if (plen > KEYLENGTH)
 		return -EINVAL;
 
 	key = ntohl(cfg->fc_dst);
-	mask = ntohl(inet_make_mask(plen));
 
-	if (key & ~mask)
+	if ((plen < KEYLENGTH) && (key << plen))
 		return -EINVAL;
 
-	l = fib_find_node(t, key);
+	l = fib_find_node(t, &tp, key);
 	if (!l)
 		return -ESRCH;
 
