From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next 3/9] netfilter: conntrack: don't attempt to
 iterate over empty table
Date: Tue, 3 May 2016 19:55:59 +0200
Message-ID: <20160503175559.GJ2395@breakpoint.cc>
References: <1461863628-23350-1-git-send-email-fw@strlen.de>
 <1461863628-23350-4-git-send-email-fw@strlen.de>
 <20160503170357.GA21641@salvia>
 <20160503171744.GG2395@breakpoint.cc>
 <20160503174144.GA3782@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:50355 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933513AbcECR4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 13:56:04 -0400
Content-Disposition: inline
In-Reply-To: <20160503174144.GA3782@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > I was thinking of the cleanup we do in the netns exit path
> > (in nf_conntrack_cleanup_net_list() ).
> 
> Right, but in that path we still have entries in the table.

Not necessarily, they might have already been removed
(timeout, close).

> > If you don't like this I can move the check here:
> > 
> > i_see_dead_people:
> >     busy = 0;
> >     list_for_each_entry(net, net_exit_list, exit_list) {
> >     // here
> >     if (atomic_read .. > 0)
> >        nf_ct_iterate_cleanup(net, kill_all, ...
> 
> I don't mind about placing this or there, as I said, my question is
> how often we will hit this optimization in a real scenario.
> 
> If you think the answer is often, then this will help.

I think the extra atomic_read in this code does no harm and
saves us the entire scan.  Also, in the exit path, when we hit the
'i_see_dead_people' label we restart the entire loop, so if we
have 200 netns on the list and the last one caused that restart,
we re-iterate needlesly for 199 netns...

> Otherwise, every time we'll go container destruction path, we'll hit
> slow path, ie.  scanning the full table.

Yes, but I see no other choice.
