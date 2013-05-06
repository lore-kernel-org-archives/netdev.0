From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH] fib_trie: no need to delay vfree()
Date: Mon, 6 May 2013 03:03:46 +0100
Message-ID: <20130506020346.GK25399@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49384 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982Ab3EFCDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 May 2013 22:03:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that vfree() can be called from interrupt contexts, there's no
need to play games with schedule_work() to escape calling vfree()
from RCU callbacks.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
Not sure if it's 3.10 or 3.11 fodder - the patch is trivial and
vfree() from RCU callbacks will be exercised in 3.10 anyway (both
for large descriptor tables and for large sysv semaphore arrays).
OTOH, it doesn't fix any bugs, so...  Up to you.

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index ff06b75..49616fe 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -125,7 +125,6 @@ struct tnode {
 	unsigned int empty_children;	/* KEYLENGTH bits needed */
 	union {
 		struct rcu_head rcu;
-		struct work_struct work;
 		struct tnode *tnode_free;
 	};
 	struct rt_trie_node __rcu *child[0];
@@ -383,12 +382,6 @@ static struct tnode *tnode_alloc(size_t size)
 		return vzalloc(size);
 }
 
-static void __tnode_vfree(struct work_struct *arg)
-{
-	struct tnode *tn = container_of(arg, struct tnode, work);
-	vfree(tn);
-}
-
 static void __tnode_free_rcu(struct rcu_head *head)
 {
 	struct tnode *tn = container_of(head, struct tnode, rcu);
@@ -397,10 +390,8 @@ static void __tnode_free_rcu(struct rcu_head *head)
 
 	if (size <= PAGE_SIZE)
 		kfree(tn);
-	else {
-		INIT_WORK(&tn->work, __tnode_vfree);
-		schedule_work(&tn->work);
-	}
+	else
+		vfree(tn);
 }
 
 static inline void tnode_free(struct tnode *tn)
