From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 07/29] fib_trie: Fib find node should return parent
Date: Tue, 24 Feb 2015 12:48:42 -0800
Message-ID: <20150224204842.26106.64260.stgit@ahduyck-vm-fedora20>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45032 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752485AbbBXUsn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:48:43 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKmhM4016318
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:48:43 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKmgQK029781
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:48:42 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
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
index 4c82e60..1cb9e92 100644
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
@@ -1408,22 +1409,21 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
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
 
