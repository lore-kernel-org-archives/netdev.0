From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/4] RCU: introduce noref debug
Date: Wed, 11 Oct 2017 08:45:32 -0700
Message-ID: <20171011154532.GD3521@linux.vnet.ibm.com>
References: <cover.1507294365.git.pabeni@redhat.com>
 <20171006133436.GY3521@linux.vnet.ibm.com>
 <1507302609.2793.16.camel@redhat.com>
 <20171006163414.GC3521@linux.vnet.ibm.com>
 <1507567992.21825.9.camel@redhat.com>
 <20171011040225.GU3521@linux.vnet.ibm.com>
 <1507733436.2487.32.camel@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
        Josh Triplett <josh@joshtriplett.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev@vger.kernel.org
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:58726 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756560AbdJKPph (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 11:45:37 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9BFiMRO002479
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 11:45:37 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dhnrssk9f-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 11:45:36 -0400
Received: from localhost
        by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
        Wed, 11 Oct 2017 11:45:35 -0400
Content-Disposition: inline
In-Reply-To: <1507733436.2487.32.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 11, 2017 at 04:50:36PM +0200, Paolo Abeni wrote:
> On Tue, 2017-10-10 at 21:02 -0700, Paul E. McKenney wrote:
> > Linus and Ingo will ask me how users decide how they should set that
> > additional build flag.  Especially given that if there is code that
> > requires non-strict checking, isn't everyone required to set up non-strict
> > checking to avoid false positives?  Unless you can also configure out
> > all the code that requires non-strict checking, I suppose, but how
> > would you keep track of what to configure out?
> 
> I'm working to a new version using a single compile flag - without
> additional strict option.
> 
> I don't know of any other subsytem that stores rcu pointer in
> datastructures for a longer amount of time. That having said, I wonder
> if the tests should completely move to the networking subsystem for the
> time being. The Kconfig option would thus be called NET_DEBUG or
> something along the lines. For abstraction it would be possible to add
> an atomic_notifier_chain to the rcu_read/unlock methods, where multiple
> users or checkers could register for. That way we keep the users
> seperate from the implementation for the cost of a bit more layering
> and more indirect calls. But given that this will anyway slow down
> execution a lot, it will anyway only be suitable in
> testing/verification/debugging environments.

I like this approach.  And if it does a good job of finding networking
bugs over the next year or so, I would be quite happy to consider
something for all RCU users.

> > OK.  There will probably be some discussion about the API in that case.
> 
> I'll drop noref parameter, the key will became mandatory - the exact
> position of where the reference of RCU managed object is stored. In the
> case of noref dst it is &skb->_skb_refdst. With this kind of API it
> should suite more subsystems.

Interesting.  Do you intend to allow rcu_track_noref() to refuse to
record a pointer?  Other than for the array-full case.

> > True enough.  Except that if people were good about always clearing the
> > pointer, then the pointer couldn't leak, right?  Or am I missing something
> > in your use cases?
> 
> This is correct. The dst_entry checking in skb, which this patch series
> implements there are strict brackets in the sense of skb_dst_set,
> skb_dst_set_noref, skb_dst_force, etc., which form brackets around the
> safe uses of those dst_entries. This patch series validates that the
> correct skb_dst_* functions are being called before the sk_buff leaves
> the rcu protected section. Thus we don't need to modify and review a
> lot of code but we can just patch into those helpers already.

Makes sense.  Those willing to strictly bracket uses gain some debug
assist.

> > Or to put it another way -- have you been able to catch any real
> > pointer-leak bugs with thister-leak bugs with this?  The other RCU
> > debug options have had pretty long found-bug lists before we accepted
> > them.
> 
> There have been two problems found so far, one is a rather minor one
> while the other one seems like a normal bug. The patches for those are
> part of this series (3/4 and 4/4).

I agree that you have started gathering evidence and that the early
indications are positive, if quite mildly so.  If this time next year
there are a few tens of such bugs found, preferably including some
serious ones, I would very likely look favorably on pulling this in to
allow others to use it.

							Thanx, Paul
