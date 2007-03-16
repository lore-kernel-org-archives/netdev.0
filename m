From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] fib_hash removal
Date: Fri, 16 Mar 2007 08:48:39 -0700
Message-ID: <20070316154839.GA3626@linux.vnet.ibm.com>
References: <17914.36807.643615.571195@robur.slu.se>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net, tgr@suug.ch, Jens.Laas@data.slu.se,
	hans.liss@its.uu.se
To: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pool-71-111-94-253.ptldor.dsl-w.verizon.net ([71.111.94.253]:29916
	"EHLO IBM-8EC8B5596CA.beaverton.ibm.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753795AbXCQT3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2007 15:29:52 -0400
Content-Disposition: inline
In-Reply-To: <17914.36807.643615.571195@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 16, 2007 at 01:38:31PM +0100, Robert Olsson wrote:
> 
> Hello, Just discussed this Patrick...
> 
> We have two users of trie_leaf_remove, fn_trie_flush and fn_trie_delete 
> both are holding RTNL. So there shouldn't be need for this preempt stuff. 
> This is assumed to a leftover from an older RCU-take.

True enough!  One request -- would it be reasonable to add to
trie_leaf_remove()'s comment to state that RTNL must be held
by the caller?

						Thanx, Paul

> > Mhh .. I think I just remembered something - me incorrectly suggesting
> > to add it there while we were talking about this at OLS :) IIRC the
> > idea was to make sure tnode_free (which at that time didn't use
> > call_rcu) wouldn't free memory while still in use in a rcu read-side
> > critical section. It should have been synchronize_rcu of course,
> > but with tnode_free using call_rcu it seems to be completely
> > unnecessary. So I guess we can simply remove it.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>
> 
> Cheers.
> 					--ro
> 
> 
> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c
> @@ -1534,7 +1534,6 @@ static int trie_leaf_remove(struct trie 
>  	t->revision++;
>  	t->size--;
> 
> -	preempt_disable();
>  	tp = NODE_PARENT(n);
>  	tnode_free((struct tnode *) n);
> 
> @@ -1544,7 +1543,6 @@ static int trie_leaf_remove(struct trie 
>  		rcu_assign_pointer(t->trie, trie_rebalance(t, tp));
>  	} else
>  		rcu_assign_pointer(t->trie, NULL);
> -	preempt_enable();
> 
>  	return 1;
>  }
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
