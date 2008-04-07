From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [RFC] fib_trie: memory waste solutions
Date: Mon, 7 Apr 2008 08:55:38 +0200
Message-ID: <18425.50538.876583.892728@robur.slu.se>
References: <20080401172702.094c0700@extreme>
	<47F33D42.9080302@cosmosbay.com>
	<47F39998.8040605@cosmosbay.com>
	<20080402110335.66b04181@extreme>
	<47F3E031.1030806@cosmosbay.com>
	<20080404090257.2ec38b0c@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:36311 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752147AbYDGGzp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Apr 2008 02:55:45 -0400
In-Reply-To: <20080404090257.2ec38b0c@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Stephen Hemminger writes:
 > Eric wisely pointed out that for larger sizes of nodes, the
 > current allocation in fib_trie wastes lots of memory.  For a sample
 > of routes extracted from the bugzilla bug the largest node grows
 > to 2M bytes on 64 bit system. This leads to 2044K of wasted memory.
 > 
 > There are two possible solutions (see attached). One uses vmalloc()
 > rather than alloc_pages, but has to add complexity on freeing.
 > The other adds a layer of indirection to the tnode lookup.
 > 
 > Both have been tested on net-2.6.26 with the huge route table.
 > I slightly prefer the vmalloc version, but both work fine.

 Do we get slower with vmalloc due to TLB-lookups etc? Guess this
 should be investigated.

 http://mail.nl.linux.org/kernelnewbies/2005-12/msg00212.html
 
 Memory savings (different)

 Cheers
					--ro


Current BGP here.

        Aver depth:     2.58
        Max depth:      6
        Leaves:         238903
        Internal nodes: 58049
          1: 30668  2: 11458  3: 9214  4: 3904  5: 1738  6: 721  7: 271  8: 74  16: 1
        Pointers: 464272
Null ptrs: 167321
Total size: 7841  kB


 > 
 > IPV4: fib_trie use vmalloc for large tnodes
 > 
 > Use vmalloc rather than alloc_pages to avoid wasting memory.
 > The problem is that tnode structure has a power of 2 sized array,
 > plus a header. So the current code wastes almost half the memory
 > allocated because it always needs the next bigger size to hold
 > that small header.
 > 
 > This is similar to an earlier patch by Eric, but instead of a list
 > and lock, I used a workqueue to handle the fact that vfree can't
 > be done in interrupt context.
 > 
 > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
 > 
 > ---
 >  net/ipv4/fib_trie.c |   25 +++++++++++++++----------
 >  1 file changed, 15 insertions(+), 10 deletions(-)
 > 
 > --- a/net/ipv4/fib_trie.c	2008-04-04 08:57:01.000000000 -0700
 > +++ b/net/ipv4/fib_trie.c	2008-04-04 08:57:03.000000000 -0700
 > @@ -122,7 +122,10 @@ struct tnode {
 >  	unsigned char bits;		/* 2log(KEYLENGTH) bits needed */
 >  	unsigned int full_children;	/* KEYLENGTH bits needed */
 >  	unsigned int empty_children;	/* KEYLENGTH bits needed */
 > -	struct rcu_head rcu;
 > +	union {
 > +		struct rcu_head rcu;
 > +		struct work_struct work;
 > +	};
 >  	struct node *child[0];
 >  };
 >  
 > @@ -350,16 +353,16 @@ static inline void free_leaf_info(struct
 >  
 >  static struct tnode *tnode_alloc(size_t size)
 >  {
 > -	struct page *pages;
 > -
 >  	if (size <= PAGE_SIZE)
 >  		return kzalloc(size, GFP_KERNEL);
 > +	else
 > +		return __vmalloc(size, GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);
 > +}
 >  
 > -	pages = alloc_pages(GFP_KERNEL|__GFP_ZERO, get_order(size));
 > -	if (!pages)
 > -		return NULL;
 > -
 > -	return page_address(pages);
 > +static void __tnode_vfree(struct work_struct *arg)
 > +{
 > +	struct tnode *tn = container_of(arg, struct tnode, work);
 > +	vfree(tn);
 >  }
 >  
 >  static void __tnode_free_rcu(struct rcu_head *head)
 > @@ -370,8 +373,10 @@ static void __tnode_free_rcu(struct rcu_
 >  
 >  	if (size <= PAGE_SIZE)
 >  		kfree(tn);
 > -	else
 > -		free_pages((unsigned long)tn, get_order(size));
 > +	else {
 > +		INIT_WORK(&tn->work, __tnode_vfree);
 > +		schedule_work(&tn->work);
 > +	}
 >  }
 >  
 >  static inline void tnode_free(struct tnode *tn)
 > IPV4: fib_trie split child off from tnode
 > 
 > For large tnode's the power of 2 allocation wastes almost half the space
 > since the tnode is allocated with the power of 2 sized child pointers.
 > To solve this add a layer of indirection. For small nodes (the common case)
 > can just use a single allocation, for larger use pages like before.
 > 
 > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
 > 
 > 
 > ---
 >  net/ipv4/fib_trie.c |   43 ++++++++++++++++++++++++++-----------------
 >  1 file changed, 26 insertions(+), 17 deletions(-)
 > 
 > --- a/net/ipv4/fib_trie.c	2008-04-03 09:09:45.000000000 -0700
 > +++ b/net/ipv4/fib_trie.c	2008-04-03 22:08:33.000000000 -0700
 > @@ -120,10 +120,10 @@ struct tnode {
 >  	t_key key;
 >  	unsigned char pos;		/* 2log(KEYLENGTH) bits needed */
 >  	unsigned char bits;		/* 2log(KEYLENGTH) bits needed */
 > +	struct node **child;
 >  	unsigned int full_children;	/* KEYLENGTH bits needed */
 >  	unsigned int empty_children;	/* KEYLENGTH bits needed */
 >  	struct rcu_head rcu;
 > -	struct node *child[0];
 >  };
 >  
 >  #ifdef CONFIG_IP_FIB_TRIE_STATS
 > @@ -348,30 +348,40 @@ static inline void free_leaf_info(struct
 >  	call_rcu(&leaf->rcu, __leaf_info_free_rcu);
 >  }
 >  
 > -static struct tnode *tnode_alloc(size_t size)
 > +static struct tnode *tnode_alloc(int bits)
 >  {
 > -	struct page *pages;
 > -
 > -	if (size <= PAGE_SIZE)
 > -		return kzalloc(size, GFP_KERNEL);
 > +	size_t space = sizeof(struct node *) << bits;
 > +	size_t size = space + sizeof(struct tnode);
 > +	struct tnode *tn;
 >  
 > -	pages = alloc_pages(GFP_KERNEL|__GFP_ZERO, get_order(size));
 > -	if (!pages)
 > +	tn = kzalloc(size > PAGE_SIZE ? sizeof(struct tnode) : size, GFP_KERNEL);
 > +	if (!tn)
 >  		return NULL;
 >  
 > -	return page_address(pages);
 > +	if (size <= PAGE_SIZE)
 > +		tn->child = (struct node **) (tn + 1);
 > +	else {
 > +		struct page *pages = alloc_pages(GFP_KERNEL|__GFP_ZERO,
 > +						 get_order(space));
 > +		if (!pages) {
 > +			kfree(tn);
 > +			return NULL;
 > +		}
 > +		tn->child = page_address(pages);
 > +	}
 > +
 > +	return tn;
 >  }
 >  
 >  static void __tnode_free_rcu(struct rcu_head *head)
 >  {
 >  	struct tnode *tn = container_of(head, struct tnode, rcu);
 > -	size_t size = sizeof(struct tnode) +
 > -		      (sizeof(struct node *) << tn->bits);
 > +	size_t space = sizeof(struct node *) << tn->bits;
 > +	size_t size = space + sizeof(struct tnode);
 >  
 > -	if (size <= PAGE_SIZE)
 > -		kfree(tn);
 > -	else
 > -		free_pages((unsigned long)tn, get_order(size));
 > +	if (size > PAGE_SIZE)
 > +		free_pages((unsigned long)tn->child, get_order(space));
 > +	kfree(tn);
 >  }
 >  
 >  static inline void tnode_free(struct tnode *tn)
 > @@ -404,8 +414,7 @@ static struct leaf_info *leaf_info_new(i
 >  
 >  static struct tnode *tnode_new(t_key key, int pos, int bits)
 >  {
 > -	size_t sz = sizeof(struct tnode) + (sizeof(struct node *) << bits);
 > -	struct tnode *tn = tnode_alloc(sz);
 > +	struct tnode *tn = tnode_alloc(bits);
 >  
 >  	if (tn) {
 >  		tn->parent = T_TNODE;
