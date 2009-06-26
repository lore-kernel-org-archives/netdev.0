From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Fri, 26 Jun 2009 17:54:10 +0200
Message-ID: <20090626155410.GA6526@ami.dom.local>
References: <4A43E9F1.90209@cosmosbay.com> <20090626080302.GB5204@ff.dom.local> <19012.37515.146191.198843@robur.slu.se> <20090626093727.GA6832@ff.dom.local> <19012.49700.908412.410984@robur.slu.se> <20090626125449.GA8897@ff.dom.local> <20090626132820.GB8897@ff.dom.local> <19012.53943.734747.493480@robur.slu.se> <20090626151051.GA2714@ami.dom.local> <20090626153010.GC6771@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <robert@robur.slu.se>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	Eric Dumazet <dada1@cosmosbay.com>,
	=?us-ascii?B?PT9JU08tODg1OS0yP1E/UGF3ZT1CM19TdGFzemV3c2tpPz0=?=
	<pstaszewski@itcare.pl>, Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:34427 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698AbZFZPyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 11:54:33 -0400
Received: by fxm9 with SMTP id 9so2189680fxm.37
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2009 08:54:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090626153010.GC6771@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 26, 2009 at 08:30:10AM -0700, Paul E. McKenney wrote:
> On Fri, Jun 26, 2009 at 05:10:52PM +0200, Jarek Poplawski wrote:
> > On Fri, Jun 26, 2009 at 03:52:55PM +0200, Robert Olsson wrote:
> > > 
> > > Jarek Poplawski writes:
> > > 
> > >  Thanks, 
> > > 
> > >  Should be worth testing so we synchronize_rcu instead of doing call_rcu's
> > >  
> > 
> > Alas take 2 (nor 1) doesn't compile, so here it is again.
> 
> So the idea is to balance memory and latency, so that large changes
> (those affecting the root node) get at least one synchronize_rcu(),
> while smaller changes just use call_rcu(), correct?  This means that
> the amount of memory awaiting an RCU grace period is limited, but
> the algorithm avoids per-node synchronize_rcu() overhead.
> 
> If I understand the goal correctly, looks good!  (Give or take my
> limited understanding of fib_trie and is usage, of course.)

The goal is practically to replace all call_rcu() during
trie_rebalance() with synchronize_rcu() (except some freeing after
ENOMEM). I guess currently (<= 2.6.30) call_rcu() can free this
memory after trie_rebalance() has finished, that's why there were
problems with enabled preemption. So this patch tries to do/force
this a bit earlier - at least before the top/largest node is
rebalanced.

Thanks,
Jarek P.

> 
> 							Thanx, Paul
> 
> > Thanks,
> > Jarek P.
> > --- (take 3 - for testing)
> > 
> >  net/ipv4/fib_trie.c |   30 ++++++++++++++++++++++++------
> >  1 files changed, 24 insertions(+), 6 deletions(-)
> > 
> > diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> > index 012cf5a..1a4c4b7 100644
> > --- a/net/ipv4/fib_trie.c
> > +++ b/net/ipv4/fib_trie.c
> > @@ -366,6 +366,17 @@ static void __tnode_vfree(struct work_struct *arg)
> >  	vfree(tn);
> >  }
> > 
> > +static void __tnode_free(struct tnode *tn)
> > +{
> > +	size_t size = sizeof(struct tnode) +
> > +		      (sizeof(struct node *) << tn->bits);
> > +
> > +	if (size <= PAGE_SIZE)
> > +		kfree(tn);
> > +	else
> > +		vfree(tn);
> > +}
> > +
> >  static void __tnode_free_rcu(struct rcu_head *head)
> >  {
> >  	struct tnode *tn = container_of(head, struct tnode, rcu);
> > @@ -402,7 +413,7 @@ static void tnode_free_flush(void)
> >  	while ((tn = tnode_free_head)) {
> >  		tnode_free_head = tn->tnode_free;
> >  		tn->tnode_free = NULL;
> > -		tnode_free(tn);
> > +		__tnode_free(tn);
> >  	}
> >  }
> > 
> > @@ -1021,18 +1032,25 @@ static void trie_rebalance(struct trie *t, struct tnode *tn)
> >  				      (struct node *)tn, wasfull);
> > 
> >  		tp = node_parent((struct node *) tn);
> > -		tnode_free_flush();
> >  		if (!tp)
> >  			break;
> >  		tn = tp;
> >  	}
> > 
> > +	if (tnode_free_head) {
> > +		synchronize_rcu();
> > +		tnode_free_flush();
> > +	}
> > +
> >  	/* Handle last (top) tnode */
> > -	if (IS_TNODE(tn))
> > +	if (IS_TNODE(tn)) {
> >  		tn = (struct tnode *)resize(t, (struct tnode *)tn);
> > -
> > -	rcu_assign_pointer(t->trie, (struct node *)tn);
> > -	tnode_free_flush();
> > +		rcu_assign_pointer(t->trie, (struct node *)tn);
> > +		synchronize_rcu();
> > +		tnode_free_flush();
> > +	} else {
> > +		rcu_assign_pointer(t->trie, (struct node *)tn);
> > +	}
> > 
> >  	return;
> >  }
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
