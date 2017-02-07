From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 3/3] rhashtable: Add nested tables
Date: Tue, 7 Feb 2017 19:02:16 +0100
Message-ID: <20170207180216.GC11584@breakpoint.cc>
References: <20170207123827.GA14678@gondor.apana.org.au>
 <E1cb53h-0003qD-No@gondobar>
 <20170207131728.GA11584@breakpoint.cc>
 <20170207132911.GA14888@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:57836 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753651AbdBGSDy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 13:03:54 -0500
Content-Disposition: inline
In-Reply-To: <20170207132911.GA14888@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Tue, Feb 07, 2017 at 02:17:28PM +0100, Florian Westphal wrote:
> >
> > Ok, but why?
> 
> Because people expect the hash table insertion to succeed, even
> on softirq paths where you cannot vmalloc.

I can't really say anything here because *I* don't expect
it to succeed.

> > It seems to add a whole lot of complexity...
> > 
> > What users can't handle the insert failure case until resize
> > has completed?
> 
> Users that need to insert on softirq that cannot throttle the
> rate.

Even with this proposed patch things will eventually fail
on OOM conditions.

Also, such period should be very short until rht has reached
peak size for the workload.

> > Would relaxing the max chain length (until rehash is done) be an
> > alternative?
> 
> Considering that this is intended for users that cannot throttle
> the rate of insertion, I think we'd be much better off just failing
> them than sticking them on what will essentially be a linked list.

I think that would depend on the user and the requirement, but
I don't know of any such users.

I get impression thatan (r)hashtable might be the wrong data
structure for this in first place.

Also, given that we could easily oversubscribe a table by a factor
of 10 or more while still keeping sane chain lengths I don't
see why thats a problem (also, a 'rht_insert_force' or similar
interface that doesn't do chain length checks makes it
easy to spot places that need/want this behaviour).

> As people don't like insertion failure, I think this level of
> complexity is justified.

I am not sure.

I think rhastable is already bloated; I can't say I can understand
all of the checks and knobs it has without looking at git history.

(insecure_elasticity and/or insecure_max_entries come to mind, seems
 some of that might not even be needed anymore but I don't have time
 right now to investigate).
