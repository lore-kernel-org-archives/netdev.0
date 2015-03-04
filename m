From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v2 8/8] fib_trie: Prevent allocating tnode if bits
 is too big for size_t
Date: Wed, 04 Mar 2015 15:04:46 -0800
Message-ID: <20150304230409.1612.98286.stgit@ahduyck-vm-fedora20>
References: <20150304225459.1612.45514.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34561 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752201AbbCDXEt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2015 18:04:49 -0500
In-Reply-To: <20150304225459.1612.45514.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code to prevent us from attempting to allocate a tnode with
a size larger than what can be represented by size_t.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 08676c5..fae34ad 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -277,6 +277,8 @@ static inline void alias_free_mem_rcu(struct fib_alias *fa)
 
 #define TNODE_KMALLOC_MAX \
 	ilog2((PAGE_SIZE - TNODE_SIZE(0)) / sizeof(struct tnode *))
+#define TNODE_VMALLOC_MAX \
+	ilog2((SIZE_MAX - TNODE_SIZE(0)) / sizeof(struct tnode *))
 
 static void __node_free_rcu(struct rcu_head *head)
 {
@@ -292,8 +294,17 @@ static void __node_free_rcu(struct rcu_head *head)
 
 #define node_free(n) call_rcu(&n->rcu, __node_free_rcu)
 
-static struct tnode *tnode_alloc(size_t size)
+static struct tnode *tnode_alloc(int bits)
 {
+	size_t size;
+
+	/* verify bits is within bounds */
+	if (bits > TNODE_VMALLOC_MAX)
+		return NULL;
+
+	/* determine size and verify it is non-zero and didn't overflow */
+	size = TNODE_SIZE(1ul << bits);
+
 	if (size <= PAGE_SIZE)
 		return kzalloc(size, GFP_KERNEL);
 	else
@@ -334,8 +345,7 @@ static struct tnode *leaf_new(t_key key, struct fib_alias *fa)
 
 static struct tnode *tnode_new(t_key key, int pos, int bits)
 {
-	size_t sz = TNODE_SIZE(1ul << bits);
-	struct tnode *tn = tnode_alloc(sz);
+	struct tnode *tn = tnode_alloc(bits);
 	unsigned int shift = pos + bits;
 
 	/* verify bits and pos their msb bits clear and values are valid */
