From: Florian Westphal <fw@strlen.de>
Subject: Re: problem with rtnetlink 'reference' count
Date: Tue, 24 Oct 2017 11:10:43 +0200
Message-ID: <20171024091043.GC19457@breakpoint.cc>
References: <20171023142555.GF3165@worktop.lehotels.local>
 <20171023153200.GA12422@breakpoint.cc>
 <20171023162006.GH3165@worktop.lehotels.local>
 <20171023163744.GB12422@breakpoint.cc>
 <20171023183158.GI3165@worktop.lehotels.local>
 <20171023193703.GA19457@breakpoint.cc>
 <20171024083338.GL3165@worktop.lehotels.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:47354 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751323AbdJXJLB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 05:11:01 -0400
Content-Disposition: inline
In-Reply-To: <20171024083338.GL3165@worktop.lehotels.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Zijlstra <peterz@infradead.org> wrote:
> On Mon, Oct 23, 2017 at 09:37:03PM +0200, Florian Westphal wrote:
> 
> > > OK, so then why not do something like so?
> > > @@ -260,10 +259,18 @@ void rtnl_unregister_all(int protocol)
> > >  	RCU_INIT_POINTER(rtnl_msg_handlers[protocol], NULL);
> > >  	rtnl_unlock();
> > >  
> > > +	/*
> > > +	 * XXX explain what this is for...
> > > +	 */
> > >  	synchronize_net();
> > >  
> > > -	while (refcount_read(&rtnl_msg_handlers_ref[protocol]) > 1)
> > > -		schedule();
> > > +	/*
> > > +	 * This serializes against the rcu_read_lock() section in
> > > +	 * rtnetlink_rcv_msg() such that after this, all prior instances have
> > > +	 * completed and future instances must observe the NULL written above.
> > > +	 */
> > > +	synchronize_rcu();
> > 
> > Yes, but that won't help with running dumpers, see below.
> > 
> > > @@ -4218,7 +4223,6 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
> > >  			};
> > >  			err = netlink_dump_start(rtnl, skb, nlh, &c);
> > 
> > This will copy .dumper function address to nlh->cb for later invocation
> > when dump gets resumed (its called from netlink_recvmsg()),
> > so this can return to userspace and dump can be resumed on next recv().
> > 
> > Because the dumper function was stored in the socket, NULLing the
> > rtnl_msg_handlers[] only prevents new dumps from starting but not
> > already set-up dumps from resuming.
> 
> but netlink_dump_start() will actually grab a reference on the module;
> but it does so too late.

Yes, but rtnl_register() doesn't pass a module pointer, i.e. in
rtnetlink_rcv_msg we can't set up the module pointer to the correct one.

We'd have to pass the module pointer to rtnl_register() and store it,
or add a new api that passes it, or, yet another option, avoid use
of .dumpit from modular users and keep the dump handling fully within
these modules.

(the api is from ancient times when it was only used from builtin
 code paths).

I'll try a few things tomorrow to see what makes most sense or if there
are any other options.
