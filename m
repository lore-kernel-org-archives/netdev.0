From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC PATCH]: Dynamically sized routing cache hash table.
Date: Tue, 6 Mar 2007 10:41:49 +0100
Message-ID: <20070306094149.GC12365@wotan.suse.de>
References: <20070305.202632.74752497.davem@davemloft.net> <20070306091112.GA12365@wotan.suse.de> <200703061023.44722.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	robert.olsson@its.uu.se, Paul McKenney <paulmck@us.ibm.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:42359 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030472AbXCFJmX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 04:42:23 -0500
Content-Disposition: inline
In-Reply-To: <200703061023.44722.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 06, 2007 at 10:23:44AM +0100, Eric Dumazet wrote:
> On Tuesday 06 March 2007 10:11, Nick Piggin wrote:
> 
> > Cool! I have some fixes for the rcu barrier issues, with some C-style
> > comments and questions :)
> >
> > I was going to send you a fix first for the rcu barriers, then a
> > second to convert the read-side to a barrier-less one that I described,
> > however considering that your patch is a WIP in progress anyway, I
> > won't worry too much about the normal protocol.
> >
> > I _think_ my reasoning regarding the rcu barriers and grace periods
> > is correct. I'll keep thinking about it though. (Paul cc'ed).
> >
> > I'm not so familiar with this code, so I have sprinkled around a lot
> > of comments that could be pure crap ;) They are mainly just to help
> > you ensure that you cover all bases... compile tested only at this
> > stage.
> 
> I think we missed :
> 
> +static void rt_hash_resize_work(struct work_struct *work)
> 
> +
> +			*head = rth->u.dst.rt_next;
> +
> +			hash = rt_hashfn(rt_hash,
> +					 rth->fl.fl4_dst,
> +					 rth->fl.fl4_src,
> +					 iface);
> +			rth->u.dst.rt_next = rt_hash->table[hash].chain;
> +			rt_hash->table[hash].chain = rth;
> 
> This really needs some ..._del_rcu()/..._add_rcu()_ ... primitives, no ?
> Or else a reader might be very confused...

I'm not sure... this code really depends on the hash table management,
rather than the management of the hash tables, if you understand me ;)

>From what I can _see_, this is similar to how rt_intern_hash does it.
I don't know exactly why rt_intern_hash can get away without using
rcu_assign_pointer in some cases, however:

Note that we don't need an rcu_assign_pointer for this, because the
memory operations that initialized the entry have already been ordered
when it was first inserted.

