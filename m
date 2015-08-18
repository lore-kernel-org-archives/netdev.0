From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH 1/6] net/bonding: enable LRO if one device supports it
Date: Tue, 18 Aug 2015 09:45:12 +0200
Message-ID: <20150818074512.GA4563@unicorn.suse.cz>
References: <1439488980-44738-1-git-send-email-jarod@redhat.com>
 <1439488980-44738-2-git-send-email-jarod@redhat.com>
 <20150814065622.GA21759@unicorn.suse.cz>
 <55CE7C8F.8070702@redhat.com>
 <55D24CFA.4000307@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>, netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40809 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751440AbbHRHpP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 03:45:15 -0400
Content-Disposition: inline
In-Reply-To: <55D24CFA.4000307@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 17, 2015 at 05:07:06PM -0400, Jarod Wilson wrote:
> On 2015-08-14 7:41 PM, Jarod Wilson wrote:
> >
> >Yeah, my thinking was that it should mean "there's at least one lro
> >capable slave". If we just leave things the way they are though, I think
> >its confusing on the user side -- it was one of our QE people who
> >reported confusion being able to toggle lro on a bond when none of the
> >slaves supported it. And there's also the inconsistency among devices
> >that support lro in their vlan_features. So I think *something* should
> >still be done here to make things clearer and more consistent, but I'll
> >have to ponder that next week, since its beyond quitting time on Friday
> >already. :)
> >
> >Oh, last thought: the comment above #define NETIF_F_ONE_FOR_ALL is
> >partly to blame for my not thinking harder and trying inverted ordering
> >of slave additions:
> >
> >/*
> >  * If one device supports one of these features, then enable them
> >  * for all in netdev_increment_features.
> >  */
> >
> >This clearly seems to fall down in the lro case. :)
> 
> Similarly, adding LRO to NETIF_F_ALL_FOR_ALL, even a bond with only
> LRO-capable hardware, I'm seeing the bond wind up without LRO and it
> can't be toggled on.

I still believe the very idea of computing bond's NETIF_F_LRO from its
slaves - or, more generally, upper device from lower devices - is wrong.
This makes very good sense for e.g. TSO where lower device is processing
packets passed to it by the lower devices. Then it makes sense to
propagate the information whether the physical device on the bottom can
process those packets (OK, TSO is perhaps not the best example here as
we can always emulate it in software and still gain some performance).

However, with LRO, the situation is exactly the opposite: packets are
produced at the bottom device in the hierarchy and passed up; and
somewhere on the higher level we may hit a reason why LRO should be
disabled (bridged device, IPv6 forwarding enabled, device in a netns
with IPv4 forwarding enabled). This hierarchy may be quite complicated,
I've seen things like a bond with a vlan on top of it and a macvlan on
top of the vlan which was then moved into a different netns (LXC
container). LRO related issues in setups like this were the reason for
529d04895446 and eventually fbe168ba91f7.

I agree that current state is not perfect but I don't think creating an
artificial value of NETIF_F_LRO composed of slave values for a bond (and
probably also a team, for consistency) is going to help. I would see
more sense in rethinking the current concept of deriving all upper
device's features from its lower devices and completing the two classes
we already have:

  - NETIF_F_ONE_FOR_ALL: propagated up, OR-ed
  - NETIF_F_ALL_FOR_ALL: propagated up, AND-ed

by two new classes:

  - propagated down, OR-ed
  - propagated down, AND-ed

NETIF_F_LRO should IMHO fall into the last class. I don't have an
example of a flag belonging to third class from the top of my head
but there may also be one (GRO, perhaps?). Such change would, of course,
require careful planning and testing to avoid regressions.

> I think the answer here (which to be fair, Nik suggested originally to
> me when I inherited this bug from him) is indeed to simply remove LRO
> from BOND_VLAN_FEATURES. Leave it fixed off for the bond itself, which
> should then turn it off for underlying devices via fbe168ba91f7 by
> default. If the user goes and turns it back on for the underlying
> devices individually, that's their prerogative. They keep both halves
> if it breaks.
> 
> Does that sound sane?

If I understand the code correctly, this would mean bond would have
NETIF_F_LRO always disabled in its dev->features so that any slave would
end up with disabled LRO after bond_enslave(). While this would be less
of a problem than LRO enabled when it shouldn't, it would cause a
performance penalty in the cases when there is no reason to disable LRO
(end hosts without any virtualization or other bridging or forwarding).

So the distribution init scripts (or management daemons like wicked or
systemd-networkd) would have to handle the LRO reenabling somehow. And
they would have trouble checking whether to do reenable LRO or not as
bond would stop keeping the state information whether dev_disable_lro()
was called for it or not (we must not reenable LRO if it was).

                                                         Michal Kubecek
