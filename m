From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [RFC] fib_trie: flush improvement
Date: Wed, 2 Apr 2008 11:31:19 +0200
Message-ID: <18419.21095.85697.414845@robur.slu.se>
References: <20080401172702.094c0700@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:40283 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751721AbYDBKC7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 06:02:59 -0400
Received: from robur.slu.se (robur.slu.se [130.238.98.12])
	by mx1.slu.se (8.13.7/8.13.6) with ESMTP id m329nc8P017371
	for <netdev@vger.kernel.org>; Wed, 2 Apr 2008 11:49:38 +0200
In-Reply-To: <20080401172702.094c0700@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Stephen Hemminger writes:
 > This is an attempt to fix the problem described in:
 >      http://bugzilla.kernel.org/show_bug.cgi?id=6648
 > I can reproduce this by loading lots and lots of routes and the taking
 > the interface down. This causes all entries in trie to be flushed, but
 > each leaf removal causes a rebalance of the trie. And since the removal
 > is depth first, it creates lots of needless work.

 OK! Havn't seen it on our boxes yet. Yes it useless work to rebalance
 if we are flushing.

 > Instead on flush, just walk the trie and prune as we go.

 Yes something like that should work. 

 An alternative could be to add an argument to trie_leaf_remove (and 
 fib_insert_node) to control if rebalance should be run. Of course
 from flush we tell trie_leaf_remove not to rebalance.

 In general I'll think the trie should look pretty OK even if we rebalance 
 every 2:nd or 3:rd etc insert/delete. Which could decrease the load and 
 speed up BGP route convergence even more.

 It could be idea to some tuning possiblites from userland. For example the 
 node threshold values and ev. rebalance threshold

 Cheers
					--ro

 > 
 > --- a/net/ipv4/fib_trie.c	2008-04-01 13:54:53.000000000 -0700
 > +++ b/net/ipv4/fib_trie.c	2008-04-01 17:19:00.000000000 -0700
 > @@ -1665,7 +1665,7 @@ static int fn_trie_delete(struct fib_tab
 >  	return 0;
 >  }
 >  
 > -static int trie_flush_list(struct trie *t, struct list_head *head)
 > +static int trie_flush_list(struct list_head *head)
 >  {
 >  	struct fib_alias *fa, *fa_node;
 >  	int found = 0;
 > @@ -1683,24 +1683,74 @@ static int trie_flush_list(struct trie *
 >  	return found;
 >  }
 >  
 > -static int trie_flush_leaf(struct trie *t, struct leaf *l)
 > +static int trie_flush_leaf(struct leaf *l)
 >  {
 > -	int found = 0;
 >  	struct hlist_head *lih = &l->list;
 >  	struct hlist_node *node, *tmp;
 >  	struct leaf_info *li = NULL;
 > +	int found = 0;
 >  
 >  	hlist_for_each_entry_safe(li, node, tmp, lih, hlist) {
 > -		found += trie_flush_list(t, &li->falh);
 > +		found += trie_flush_list(&li->falh);
 >  
 >  		if (list_empty(&li->falh)) {
 >  			hlist_del_rcu(&li->hlist);
 >  			free_leaf_info(li);
 >  		}
 >  	}
 > +	tnode_free((struct tnode *) l);
 > +
 >  	return found;
 >  }
 >  
 > +static int trie_flush(struct tnode *p)
 > +{
 > +	struct node *c = NULL;
 > +	t_key idx = 0;
 > +	int found = 0;
 > +
 > +	for(;;) {
 > +		for ( ;idx < (1u << p->bits); ++idx) {
 > +			struct node *c = p->child[idx];
 > +			if (!c)
 > +				continue;
 > +
 > +			rcu_assign_pointer(p->child[idx], NULL);
 > +			if (IS_LEAF(c)) {
 > +				found += trie_flush_leaf((struct leaf *) c);
 > +				continue;
 > +			}
 > +
 > +			/* Descend one level */
 > +			p = (struct tnode *) c;
 > +			idx = 0;
 > +		}
 > +
 > +		/* Node empty, free and go back up */
 > +		tnode_free((struct tnode *) c);
 > +		c = (struct node *) p;
 > +		p = node_parent(c);
 > +		if (p == NULL)
 > +			return found; /* at root */
 > +
 > +		idx = tkey_extract_bits(c->key, p->pos, p->bits) + 1;
 > +	}
 > +}
 > +
 > +static int fn_trie_flush(struct fib_table *tb)
 > +{
 > +	struct trie *t = (struct trie *) tb->tb_data;
 > +	struct tnode *n = (struct tnode *) t->trie;
 > +
 > +	ASSERT_RTNL();
 > +	rcu_assign_pointer(t->trie, NULL);
 > +
 > +	if (IS_LEAF(n))
 > +		return trie_flush_leaf((struct leaf *) n);
 > +	else
 > +		return trie_flush(n);
 > +}
 > +
 >  /*
 >   * Scan for the next right leaf starting at node p->child[idx]
 >   * Since we have back pointer, no recursion necessary.
 > @@ -1772,30 +1822,6 @@ static struct leaf *trie_leafindex(struc
 >  }
 >  
 >  
 > -/*
 > - * Caller must hold RTNL.
 > - */
 > -static int fn_trie_flush(struct fib_table *tb)
 > -{
 > -	struct trie *t = (struct trie *) tb->tb_data;
 > -	struct leaf *l, *ll = NULL;
 > -	int found = 0;
 > -
 > -	for (l = trie_firstleaf(t); l; l = trie_nextleaf(l)) {
 > -		found += trie_flush_leaf(t, l);
 > -
 > -		if (ll && hlist_empty(&ll->list))
 > -			trie_leaf_remove(t, ll);
 > -		ll = l;
 > -	}
 > -
 > -	if (ll && hlist_empty(&ll->list))
 > -		trie_leaf_remove(t, ll);
 > -
 > -	pr_debug("trie_flush found=%d\n", found);
 > -	return found;
 > -}
 > -
 >  static void fn_trie_select_default(struct fib_table *tb,
 >  				   const struct flowi *flp,
 >  				   struct fib_result *res)
