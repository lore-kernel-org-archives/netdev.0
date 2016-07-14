From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2 3/3] netfilter: replace list_head with single linked
 list
Date: Thu, 14 Jul 2016 21:19:03 +0200
Message-ID: <20160714191903.GA4149@breakpoint.cc>
References: <1468337541-23930-1-git-send-email-aconole@bytheb.org>
 <1468337541-23930-4-git-send-email-aconole@bytheb.org>
 <20160714175812.GA1021@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Aaron Conole <aconole@bytheb.org>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:46105 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751153AbcGNTTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 15:19:12 -0400
Content-Disposition: inline
In-Reply-To: <20160714175812.GA1021@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Tue, Jul 12, 2016 at 11:32:21AM -0400, Aaron Conole wrote:
> > The netfilter hook list never uses the prev pointer, and so can be
> > trimmed to be a smaller singly-linked list.
> > 
 	struct list_head list;
> >  
> > @@ -161,8 +167,6 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
> >  				 int (*okfn)(struct net *, struct sock *, struct sk_buff *),
> >  				 int thresh)
> >  {
> > -	struct list_head *hook_list;
> > -
> >  #ifdef HAVE_JUMP_LABEL
> >  	if (__builtin_constant_p(pf) &&
> >  	    __builtin_constant_p(hook) &&
> > @@ -170,14 +174,14 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
> >  		return 1;
> >  #endif
> >  
> > -	hook_list = &net->nf.hooks[pf][hook];
> > -
> 
> You have to place rcu_read_lock() here, see below.

Not necessarily, rcu_access_pointer does not need it.

> > -	if (!list_empty(hook_list)) {
> > +	if (rcu_access_pointer(net->nf.hooks[pf][hook])) {
> 
> This check above is out of the rcu read-side section, here this may
> evaluate true...

Yes.

> >  		/* We may already have this, but read-locks nest anyway */
> >  		rcu_read_lock();
> > +		hook_list = rcu_dereference(net->nf.hooks[pf][hook]);
> 
> ... but then, net->nf.hooks[pf][hook]) may have become NULL, I guess
> this race will result in a crash.

Right, the hook_list needs to be checked vs. NULL again.

Alternatively of course just place rcu_read_lock above and replace
the acccess_pointer with hook_list = rcu_dereference().

> General note on this patchset: With linked-lists, it was always true
> that net->nf.hooks[pf][hook] is non-NULL since this was pointing to
> the list head. After this patch this no longer true, that means we
> have to be more careful ;).

Right.

> > @@ -310,8 +345,10 @@ next_hook:
> >  		if (ret == 0)
> >  			ret = -EPERM;
> >  	} else if ((verdict & NF_VERDICT_MASK) == NF_QUEUE) {
> > -		int err = nf_queue(skb, elem, state,
> > -				   verdict >> NF_VERDICT_QBITS);
> > +		int err;
> > +
> > +		state->hook_list = elem;
> 
> Will this work in terms of escapability? Scenario: 1) packet is
> enqueued, 2) hook is gone and 3) userspace reinjects the packet. In
> that case we hold a reference to an entry that doesn't exist anymore.

Nowadays we zap entries that have a hook owner that we are
unregistering, this is also why we don't have owner refcounting
of the hooks anymore.  So this *should* be fine.

> Ok, I'm stopping here, I think this needs another spin.

My fault.

These patches originate from a garbage pile of an old working
branch of mine and it never was in a shape where each patch
was building on its own, and it was also never checkpatch-clean.

I also never got around splitting it into smaller bites.
