From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [FIB]: full_children & empty_children should be uint, not ushort
Date: Sun, 13 Jan 2008 19:30:21 +0100
Message-ID: <478A58BD.8010304@cosmosbay.com>
References: <20080112064513.803976049@linux-foundation.org> <20080112064646.659443238@linux-foundation.org> <4788A17D.5070903@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050005070706060901070102"
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Robert Olsson <robert.olsson@its.uu.se>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:41571 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753251AbYAMSag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2008 13:30:36 -0500
In-Reply-To: <4788A17D.5070903@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050005070706060901070102
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

Eric Dumazet a écrit :
> 4) full_children & empty_children being 'unsigned short',
>    we probably are limited to 2^15 elements, but I could not
>    find this limit enforced somewhere.

Hi David

In my testings, I found that once a tnode is built with 2^16 slots (or more), 
it cannot be freed.

Extract of /proc/net/fib_triestat

Main:
  Aver depth:     1.50
  Max depth:      2
  Leaves:         2
  Internal nodes: 3
    1: 1  2: 1  17: 1
  Pointers: 131078
Null ptrs: 131074
Total size: 513  kB
# ip route
192.168.11.0/24 dev eth0  proto kernel  scope link  src 192.168.11.129
default via 192.168.11.2 dev eth0

Two fixes are possible : Enlarge full_children & empty_children to 32bits, or 
force a limit in code to never exceed 2^15 children in a tnode. I chose the 
first solution since it can be done with 0 memory cost on 64bit arches.

Thank you

[FIB]: full_children & empty_children should be uint, not ushort

If declared as unsigned short, these fields can overflow, and whole trie logic
is broken. I could not make the machine crash, but some tnode can never
be freed.

Note for 64 bit arches : By reordering t_key and parent in [node, leaf, tnode] 
structures, we can use 32 bits hole after t_key so that sizeof(struct tnode) 
doesnt change after this patch.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------050005070706060901070102
Content-Type: text/plain;
 name="fib_trie.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fib_trie.patch"

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index f26ba31..9696722 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -97,13 +97,13 @@ typedef unsigned int t_key;
 #define IS_LEAF(n) (n->parent & T_LEAF)
 
 struct node {
-	t_key key;
 	unsigned long parent;
+	t_key key;
 };
 
 struct leaf {
-	t_key key;
 	unsigned long parent;
+	t_key key;
 	struct hlist_head list;
 	struct rcu_head rcu;
 };
@@ -116,12 +116,12 @@ struct leaf_info {
 };
 
 struct tnode {
-	t_key key;
 	unsigned long parent;
+	t_key key;
 	unsigned char pos;		/* 2log(KEYLENGTH) bits needed */
 	unsigned char bits;		/* 2log(KEYLENGTH) bits needed */
-	unsigned short full_children;	/* KEYLENGTH bits needed */
-	unsigned short empty_children;	/* KEYLENGTH bits needed */
+	unsigned int full_children;	/* KEYLENGTH bits needed */
+	unsigned int empty_children;	/* KEYLENGTH bits needed */
 	struct rcu_head rcu;
 	struct node *child[0];
 };
@@ -329,12 +329,12 @@ static inline void free_leaf_info(struct leaf_info *leaf)
 	call_rcu(&leaf->rcu, __leaf_info_free_rcu);
 }
 
-static struct tnode *tnode_alloc(unsigned int size)
+static struct tnode *tnode_alloc(size_t size)
 {
 	struct page *pages;
 
 	if (size <= PAGE_SIZE)
-		return kcalloc(size, 1, GFP_KERNEL);
+		return kzalloc(size, GFP_KERNEL);
 
 	pages = alloc_pages(GFP_KERNEL|__GFP_ZERO, get_order(size));
 	if (!pages)
@@ -346,8 +346,8 @@ static struct tnode *tnode_alloc(unsigned int size)
 static void __tnode_free_rcu(struct rcu_head *head)
 {
 	struct tnode *tn = container_of(head, struct tnode, rcu);
-	unsigned int size = sizeof(struct tnode) +
-		(1 << tn->bits) * sizeof(struct node *);
+	size_t size = sizeof(struct tnode) +
+		      (sizeof(struct node *) << tn->bits);
 
 	if (size <= PAGE_SIZE)
 		kfree(tn);
@@ -386,8 +386,7 @@ static struct leaf_info *leaf_info_new(int plen)
 
 static struct tnode* tnode_new(t_key key, int pos, int bits)
 {
-	int nchildren = 1<<bits;
-	int sz = sizeof(struct tnode) + nchildren * sizeof(struct node *);
+	size_t sz = sizeof(struct tnode) + (sizeof(struct node *) << bits);
 	struct tnode *tn = tnode_alloc(sz);
 
 	if (tn) {
@@ -399,8 +398,8 @@ static struct tnode* tnode_new(t_key key, int pos, int bits)
 		tn->empty_children = 1<<bits;
 	}
 
-	pr_debug("AT %p s=%u %u\n", tn, (unsigned int) sizeof(struct tnode),
-		 (unsigned int) (sizeof(struct node) * 1<<bits));
+	pr_debug("AT %p s=%u %lu\n", tn, (unsigned int) sizeof(struct tnode),
+		 (unsigned long) (sizeof(struct node) << bits));
 	return tn;
 }
 

--------------050005070706060901070102--
