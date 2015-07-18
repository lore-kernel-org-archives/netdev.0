From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2 -next] net: fib: use fib result when zero-length
 prefix aliases exist
Date: Sat, 18 Jul 2015 20:05:46 +0200
Message-ID: <20150718180546.GA7835@breakpoint.cc>
References: <1437154621-18180-1-git-send-email-fw@strlen.de>
 <alpine.LFD.2.11.1507180045330.2410@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:60588 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751501AbbGRSFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jul 2015 14:05:48 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1507180045330.2410@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julian Anastasov <ja@ssi.bg> wrote:

[ Dave, please toss my patch, its either v3 or something else entirely ]

> 	In fact, TOS should be matched just like in
> fib_table_lookup but it is not.
> 
> > This changes fib_select_default to not change the FIB chosen result EXCEPT
> > if this nexthop appears to be unreachable.
> > 
> > fib_detect_death() logic is reversed -- we consider a nexthop 'dead' only
> > if it has a neigh entry in unreachable state.
> 
> 	The only difference I see is that NUD_NODE is
> declared by fib_nud_is_unreach() as reachable. May be
> it is better, for example, new route in NUD_NONE state
> will be tried for a while, until its state is determined.

fib_detect_death considers neigh_lookup() returning NULL as unreach.

I don't think its good idea and should rather only skip if NUD is
failed or incomplete.

> > +	if (likely(!fib_nud_is_unreach(res->fi)))
> > +		return;
> 
> 	here first is unreachable...
> > +	/* attempt to pick another nexthop */
> >  	hlist_for_each_entry_rcu(fa, fa_head, fa_list) {
> >  		struct fib_info *next_fi = fa->fa_info;
> >  
> > @@ -1223,38 +1223,30 @@ void fib_select_default(struct fib_result *res)
> >  		    next_fi->fib_nh[0].nh_scope != RT_SCOPE_LINK)
> >  			continue;
> >  
> > +		order++;
> > +
> > +		if (next_fi == res->fi) /* already tested, not reachable */
> > +			continue;
> > +
> >  		fib_alias_accessed(fa);
> >  
> > -		if (!fi) {
> > -			if (next_fi != res->fi)
> > +		if (fib_nud_is_unreach(next_fi))
> 
> 			all others are unreachable too...
> 
> > +			continue;
> > +
> > +		/* try to round-robin among all fa_aliases in case
> > +		 * res->fi nexthop is unreachable.
> 
> 	round-robin only among reachables? But original algorithm
> can round-robin among unreachables. State will not change
> without trying some packets to unreachable dests.

Hmm... thanks for pointing that out.

But thats confusing.  If thats true, why does fib_detect_death
even exist?  If we skip unreachables, they cannot become
reachable again...?

> > +			fi = next_fi;
> > +			fi_idx = order;
> > +			if (order > tb->tb_default)
> >  				break;
> 
> 	1=unreac, 2=reach, 3=tb_default(reach), 4=reach.
> We like 2 (fi == NULL), why we continue after 2, skip
> default 3 (because order > tb->tb_default is false) and
> finally select 4 (order=4 > tb->tb_default=3)?

Hmm.  Let me ask different question.
What is the supposed behaviour in the case you describe?

Removing order > default
test means we'll always pick first reachable in the list, no?

I don't think thats bad, but, how/why is is that 'better'?

> > +	tb->tb_default = fi_idx;
> 
> 	And we do not round-robin if all look unreachable?

Right.  One possible solution might be this patch, but alter
fib_nud_is_unreach() to also check timer_pending(n->timer), i.e.

if (state & (NUD_INCOMPLETE | NUD_FAILED))
	return timer_was_pending ? UNREACHABLE : REACHABLE;

This way we would re-try gw not only if neigh doesn't exist but
also if no retry is pending.

What do you think?

> As for fib_select_default,
> may be only change like below is needed. It additionally
> restricts the alternative routes to same prefix, same TOS.
> The TOS restriction was missing from long time but the
> prefix check was lost recently when fa_head was changed
> to contain aliases from different prefixes.

>  /* Must be invoked inside of an RCU protected region.  */
> -void fib_select_default(struct fib_result *res)
> +void fib_select_default(const struct flowi4 *flp, struct fib_result *res)
>  {
>  	struct fib_info *fi = NULL, *last_resort = NULL;
>  	struct hlist_head *fa_head = res->fa_head;
>  	struct fib_table *tb = res->table;
> +	u8 slen = 32 - res->prefixlen;
>  	int order = -1, last_idx = -1;
>  	struct fib_alias *fa;
>  
>  	hlist_for_each_entry_rcu(fa, fa_head, fa_list) {
>  		struct fib_info *next_fi = fa->fa_info;
>  
> +		if (fa->fa_slen != slen)
> +			continue;
>  		if (next_fi->fib_scope != res->scope ||
>  		    fa->fa_type != RTN_UNICAST)
>  			continue;
>  
> +		if (fa->tb_id != tb->tb_id)
> +			continue;
> +		if (fa->fa_tos && fa->fa_tos != flp->flowi4_tos)
> +			continue;

Hmm, this means we won't consider alternative if tos doesn't match,
except 0.

So with
ip route add tos 0x00 via 192.168.1.1
ip route add tos 0x04 via 192.168.1.2
ip route add tos 0x08 via 192.168.1.3
ip route add tos 0x0c via 192.168.1.4
ip route add tos 0x10 via 192.168.1.5

and ping -Q 1.2.3.4

if 1.5 is unreachable, we pick 1.1 (tos 0x0).

Others are not attempted.
Do you consider that 'correct'?  I don't see why
we can use tos 0x00 but not e.g. 0x04 in that case.

If .5 becomes available, we won't attempt it and still use 1.1/tos 0.

Thanks for looking into this.
