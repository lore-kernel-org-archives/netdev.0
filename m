From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next 3/9] netfilter: conntrack: don't attempt to
 iterate over empty table
Date: Tue, 3 May 2016 19:41:44 +0200
Message-ID: <20160503174144.GA3782@salvia>
References: <1461863628-23350-1-git-send-email-fw@strlen.de>
 <1461863628-23350-4-git-send-email-fw@strlen.de>
 <20160503170357.GA21641@salvia>
 <20160503171744.GG2395@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39764 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934181AbcECRlu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 13:41:50 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 36B3B1BFA86
	for <netdev@vger.kernel.org>; Tue,  3 May 2016 19:41:47 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 2511C33AA
	for <netdev@vger.kernel.org>; Tue,  3 May 2016 19:41:47 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 10FE4AD6C
	for <netdev@vger.kernel.org>; Tue,  3 May 2016 19:41:45 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20160503171744.GG2395@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 03, 2016 at 07:17:44PM +0200, Florian Westphal wrote:
> Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > On Thu, Apr 28, 2016 at 07:13:42PM +0200, Florian Westphal wrote:
> > > Once we place all conntracks into same table iteration becomes more
> > > costly because the table contains conntracks that we are not interested
> > > in (belonging to other netns).
> > > 
> > > So don't bother scanning if the current namespace has no entries.
> > > 
> > > Signed-off-by: Florian Westphal <fw@strlen.de>
> > > ---
> > >  net/netfilter/nf_conntrack_core.c | 3 +++
> > >  1 file changed, 3 insertions(+)
> > > 
> > > diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> > > index 29fa08b..f2e75a5 100644
> > > --- a/net/netfilter/nf_conntrack_core.c
> > > +++ b/net/netfilter/nf_conntrack_core.c
> > > @@ -1428,6 +1428,9 @@ void nf_ct_iterate_cleanup(struct net *net,
> > >  
> > >  	might_sleep();
> > >  
> > > +	if (atomic_read(&net->ct.count) == 0)
> > > +		return;
> > 
> > This optimization gets defeated with just one single conntrack (ie.
> > net->ct.count == 1), so I wonder if this is practical thing.
> 
> I was thinking of the cleanup we do in the netns exit path
> (in nf_conntrack_cleanup_net_list() ).

Right, but in that path we still have entries in the table.

> If you don't like this I can move the check here:
> 
> i_see_dead_people:
>     busy = 0;
>     list_for_each_entry(net, net_exit_list, exit_list) {
>     // here
>     if (atomic_read .. > 0)
>        nf_ct_iterate_cleanup(net, kill_all, ...

I don't mind about placing this or there, as I said, my question is
how often we will hit this optimization in a real scenario.

If you think the answer is often, then this will help.

Otherwise, every time we'll go container destruction path, we'll hit
slow path, ie.  scanning the full table.

> > At the cost of consuming more memory per conntrack, we may consider
> > adding a per-net list so this iteration doesn't become a problem.
> 
> I don't think that will be needed.   We don't have any such iterations
> in the fast path.
>
> For dumps via ctnetlink it shouldn't be a big deal either, if needed
> we can optimize that to use rcu readlocks only and 'upgrade' to locked
> path only when we want to dump the candidate ct.
> for deferred pruning).
> early_drop will go away soon (i'll rework it to do the early_drop from
> work queue).

OK.
