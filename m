From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] fib_trie: flush improvement
Date: Wed, 02 Apr 2008 16:35:04 +0200
Message-ID: <47F39998.8040605@cosmosbay.com>
References: <20080401172702.094c0700@extreme> <47F33D42.9080302@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020008060707080202070207"
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp27.orange.fr ([80.12.242.96]:48211 "EHLO smtp27.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753835AbYDBOfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 10:35:17 -0400
In-Reply-To: <47F33D42.9080302@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020008060707080202070207
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Eric Dumazet a =E9crit :
> Stephen Hemminger a =E9crit :
>> This is an attempt to fix the problem described in:
>>      http://bugzilla.kernel.org/show_bug.cgi?id=3D6648
>> I can reproduce this by loading lots and lots of routes and the taking=

>> the interface down. This causes all entries in trie to be flushed, but=

>> each leaf removal causes a rebalance of the trie. And since the remova=
l
>> is depth first, it creates lots of needless work.
>>
>> Instead on flush, just walk the trie and prune as we go.
>> The implementation is for description only, it probably doesn't work=20
>> yet.
>>
>>  =20
>
> I dont get it, since the bug reporter mentions with recent kernels :
>
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
>
> Is it what you get with your tests ?
>
> Pawel reports :
>
> cat /proc/net/fib_triestat
> Main: Aver depth: 2.26 Max depth: 6 Leaves: 235924
> Internal nodes: 57854 1: 31632 2: 11422 3: 8475 4: 3755 5: 1676 6: 893 =

> 18: 1
>
> Pointers: 609760 Null ptrs: 315983 Total size: 16240 kB
>
> warning messages comes from rootnode that cannot be expanded, since it =

> hits MAX_ORDER (on a 32bit x86)
>
>
>
> (sizeof(struct tnode) + (sizeof(struct node *) << bits);) is rounded=20
> to 4 << (bit + 1), ie 2 << 20
>
> For larger allocations Pawel has two choices :
>
> change MAX_ORDER from 11 to 13 or 14
> If this machine is a pure router, this change wont have performance=20
> impact.
>
> Or (more difficult, but more appropriate for mainline) change=20
> fib_trie.c to use vmalloc() for very big allocaions (for the root=20
> only), and vfree()
>
> Since vfree() cannot be called from rcu callback, one has to setup a=20
> struct work_struct helper.
>
Here is a patch (untested unfortunatly) to implement this.

[IPV4] fib_trie: root_tnode can benefit of vmalloc()

FIB_TRIE root node can be very large and currently hits MAX_ORDER limit.
It also wastes about 50% of allocated size, because of power of two=20
rounding of tnode.

A switch to vmalloc() can improve FIB_TRIE performance by allowing root=20
node to grow
past the alloc_pages() limit, while preserving memory.

Special care must be taken to free such zone, as rcu handler is not=20
allowed to call vfree(),
we use a worker instead.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>



--------------020008060707080202070207
Content-Type: text/plain;
 name="trie_vmalloc.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="trie_vmalloc.patch"

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 9e491e7..871e9e9 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -120,9 +120,13 @@ struct tnode {
 	t_key key;
 	unsigned char pos;		/* 2log(KEYLENGTH) bits needed */
 	unsigned char bits;		/* 2log(KEYLENGTH) bits needed */
+	unsigned char vmalloced;
 	unsigned int full_children;	/* KEYLENGTH bits needed */
 	unsigned int empty_children;	/* KEYLENGTH bits needed */
-	struct rcu_head rcu;
+	union {
+		struct rcu_head rcu;
+		struct tnode *next;
+	};
 	struct node *child[0];
 };
 
@@ -347,17 +351,31 @@ static inline void free_leaf_info(struct leaf_info *leaf)
 static struct tnode *tnode_alloc(size_t size)
 {
 	struct page *pages;
+	struct tnode *tn;
 
 	if (size <= PAGE_SIZE)
 		return kzalloc(size, GFP_KERNEL);
 
-	pages = alloc_pages(GFP_KERNEL|__GFP_ZERO, get_order(size));
-	if (!pages)
-		return NULL;
-
-	return page_address(pages);
+	/*
+	 * Because of power of two requirements of alloc_pages(),
+	 * we prefer vmalloc() in case we waste too much memory.
+	 */
+	if (roundup_pow_of_two(size) - size <= PAGE_SIZE * 8) {
+		pages = alloc_pages(GFP_KERNEL | __GFP_ZERO, get_order(size));
+		if (pages)
+			return page_address(pages);
+	}
+	tn = __vmalloc(size, GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);
+	if (tn)
+		tn->vmalloced = 1;
+	return tn;
 }
 
+static void fb_worker_func(struct work_struct *work);
+static DECLARE_WORK(fb_vfree_work, fb_worker_func);
+static DEFINE_SPINLOCK(fb_vfree_lock);
+static struct tnode *fb_vfree_list;
+
 static void __tnode_free_rcu(struct rcu_head *head)
 {
 	struct tnode *tn = container_of(head, struct tnode, rcu);
@@ -366,8 +384,30 @@ static void __tnode_free_rcu(struct rcu_head *head)
 
 	if (size <= PAGE_SIZE)
 		kfree(tn);
-	else
+	else if (!tn->vmalloced)
 		free_pages((unsigned long)tn, get_order(size));
+	else {
+		spin_lock(&fb_vfree_lock);
+		tn->next = fb_vfree_list;
+		fb_vfree_list = tn;
+		schedule_work(&fb_vfree_work);
+		spin_unlock(&fb_vfree_lock);
+	}
+}
+
+static void fb_worker_func(struct work_struct *work)
+{
+	struct tnode *tn, *next;
+
+	spin_lock_bh(&fb_vfree_lock);
+	tn = fb_vfree_list;
+	fb_vfree_list = NULL;
+	spin_unlock_bh(&fb_vfree_lock);
+	while (tn) {
+		next = tn->next;
+		vfree(tn);
+		tn = next;
+	}
 }
 
 static inline void tnode_free(struct tnode *tn)

--------------020008060707080202070207--


