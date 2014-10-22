From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH v2 net-next] net: ipv6: Add a sysctl to make
 optimistic addresses useful candidates
Date: Wed, 22 Oct 2014 13:36:11 +0200
Message-ID: <1413977771.2337.50.camel@localhost>
References: <1413864306-20055-1-git-send-email-ek@google.com>
	 <1413920743.32553.45.camel@localhost>
	 <CAAedzxpsaEGt+oO0xJWLxcjapdRYauHP4rAsKkf_skcdzbGEmg@mail.gmail.com>
	 <1413972774.2337.37.camel@localhost>
	 <CAAedzxpG1TEVVm_kHgRJcOO7qkFmyyYnfPL0ONN7GcypmtRq1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Lorenzo Colitti <lorenzo@google.com>
To: Erik Kline <ek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:55085 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932927AbaJVLgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 07:36:13 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway2.nyi.internal (Postfix) with ESMTP id 6193A2092C
	for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 07:36:13 -0400 (EDT)
In-Reply-To: <CAAedzxpG1TEVVm_kHgRJcOO7qkFmyyYnfPL0ONN7GcypmtRq1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mi, 2014-10-22 at 20:15 +0900, Erik Kline wrote:
> >> >>       case IPV6_SADDR_RULE_PREFIX:
> >> >>               /* Rule 8: Use longest matching prefix */
> >> >>               ret = ipv6_addr_diff(&score->ifa->addr, dst->addr);
> >> >> @@ -3222,8 +3240,13 @@ static void addrconf_dad_begin(struct inet6_ifaddr *ifp)
> >> >>        * Optimistic nodes can start receiving
> >> >>        * Frames right away
> >> >>        */
> >> >> -     if (ifp->flags & IFA_F_OPTIMISTIC)
> >> >> +     if (ifp->flags & IFA_F_OPTIMISTIC) {
> >> >>               ip6_ins_rt(ifp->rt);
> >> >> +             /* Because optimistic nodes can receive frames, notify
> >> >> +              * listeners. If DAD fails, RTM_DELADDR is sent.
> >> >> +              */
> >> >> +             ipv6_ifa_notify(RTM_NEWADDR, ifp);
> >> >> +     }
> >> >
> >> > I wonder if we can now delete the ipv6_ifa_notify(RTM_NEWADDR, ifp) in
> >> > addrconf_dad_completed.
> >>
> >> I don't know what everyone's general preference would be, but mine
> >> would be to err on the side of notifying on state changes.  It seems
> >> harmless to me to keep it in, and something in userspace might want to
> >> know if/when DAD completes.
> >
> > Userspace expects to communicate with an address which gets announced
> > via RTM_NEWADDR, so I would make the RTM_NEWADDR notifications
> > conditional on use_optimistic flag in both, the completed and the
> > dad_begin function. This sounds like the best option to me, no?
> 
> That's easy enough to do in addrconf_dad_begin().  Unfortunately, by
> the time we get to addrconf_dad_completed() the IFA_F_OPTIMISTIC flag
> has already been cleared.
> 
> I have a version that attempts to take its best guess as to whether an
> RTM_NEWADDR _should_ have already been sent--something like:
> 
> #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
>         // We probably already sent a notification in addrconf_dad_begin().
>         if (!ifp->idev->cnf.optimistic_dad || !ifp->idev->cnf.use_optimistic)
> #endif
>         ipv6_ifa_notify(RTM_NEWADDR, ifp);
> 
> but that doesn't seem that clean to me (apart from the ifdef-y
> messiness of it).  Do you think this "best guess" approach is
> reasonable?

I would definitely ack a patch which removes the macros and the config
option CONFIG_IPV6_OPTIMISTIC_DAD completely.

You also can split the ifdefed part into a small helper function:

static inline bool ipv6_use_optimistic_addr(struct inet6_dev *idev)
{
#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
        return idev->cnf.optimistic_dad && idev->cnf.use_optimistic;
#else
        return false;
#endif
}

...

and then in both locations update the RTM_NEWADDR like this:

addrconf_dad_begin:

if (ipv6_use_optimisitic_addr(idev))
   notify...

and the dad_completed with a negated check. I think this is the easiest
option.

> With just the "use_optimistic" check in addrconf_dad_begin(),
> userspace can still communicate with addresses it gets via
> RTM_NEWADDR, it will just get /two/ such notifications: one when it
> can probably use it and one when it definitely can.
> 
> Thoughts?

In the near future we also must introduce specific DAD events needed for
RFC7217 addresses (to count DAD progress and safe the information per
prefix in user space). I would prefer to keep the logic for RTM_NEWADDR
that the kernel will definitely allow the use of the address but
RTM_NEWADDR should be handled idempotent by user space.

Thanks,
Hannes
