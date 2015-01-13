From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: why are IPv6 addresses removed on link down
Date: Tue, 13 Jan 2015 16:00:30 +0100
Message-ID: <1421161230.13626.30.camel@stressinduktion.org>
References: <54B4A7E4.7030301@gmail.com> <20150112231021.316648e3@urahara>
		 <1421145346.13626.12.camel@redhat.com> <54B50873.4090907@miraclelinux.com>
		 <54B50C71.7090007@miraclelinux.com> <1421152613.13626.24.camel@redhat.com>
	 <54B53187.7080306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:52567 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751004AbbAMPAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 10:00:33 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id EFB5E209B6
	for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 10:00:32 -0500 (EST)
In-Reply-To: <54B53187.7080306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Di, 2015-01-13 at 07:53 -0700, David Ahern wrote:
> On 1/13/15 5:36 AM, Hannes Frederic Sowa wrote:
> > Hi,
> >
> > On Di, 2015-01-13 at 21:15 +0900, YOSHIFUJI Hideaki wrote:
> >> YOSHIFUJI Hideaki wrote:
> >>> Hi,
> >>>
> >>> Hannes Frederic Sowa wrote:
> >>>> On Mo, 2015-01-12 at 23:10 -0800, Stephen Hemminger wrote:
> >>>>> On Mon, 12 Jan 2015 22:06:44 -0700
> >>>>> David Ahern <dsahern@gmail.com> wrote:
> >>>>>
> >>>>>> We noticed that IPv6 addresses are removed on a link down. e.g.,
> >>>>>>      ip link set dev eth1
> >>>>>>
> >>>>>>
> >>>>>> Looking at the code it appears to be this code path in addrconf.c:
> >>>>>>
> >>>>>>            case NETDEV_DOWN:
> >>>>>>            case NETDEV_UNREGISTER:
> >>>>>>                    /*
> >>>>>>                     *      Remove all addresses from this interface.
> >>>>>>                     */
> >>>>>>                    addrconf_ifdown(dev, event != NETDEV_DOWN);
> >>>>>>                    break;
> >>>>>>
> >>>>>> IPv4 addresses are NOT removed on a link down. Is there a particular
> >>>>>> reason IPv6 addresses are?
> >>>>>>
> >>>>>> Thanks,
> >>>>>> David
> >>>>>
> >>>>> See RFC's which describes how IPv6 does Duplicate Address Detection.
> >>>>> Address is not valid when link is down, since DAD is not possible.
> >>>>
> >>>> It should be no problem if the kernel would reacquire them on ifup and
> >>>> do proper DAD. We simply must not use them while the interface is dead
> >>>> (also making sure they don't get used for loopback routing).
> >>>>
> >>>> The problem the IPv6 addresses get removed is much more a historical
> >>>> artifact nowadays, I think. It is part of user space API and scripts
> >>>> deal with that already.
> >>>
> >>> We might have another "detached" state which essintially drops
> >>> outgoing packets while link is down.  Just after recovering link,
> >>> we could start receiving packet from the link and perform optimistic
> >>> DAD. And then, after it succeeds, we may start sending packets.
> >>>
> >>> Since "detached" state is like the state just before completing
> >>> Optimistic DAD, it is not so difficult to implement this extended
> >>> behavior, I guess.
> >>>
> >>
> >> Note that node is allowed to send packets to neighbours or default
> >> routers if the node knows their link-layer addresses during Optimistic
> >> DAD.
> >>
> >
> > I don't think it should be a problem from internal state handling of the
> > addresses.
> >
> > I am much more concerned with scripts expecting the addresses to be
> > flushed on interface down/up and not reacting appropriate.
> 
> The current code seems inconsistent: I can put an IPv6 address on a link 
> in the down state. On a link up the address is retained. Only on a 
> subsequent link down is it removed. If DAD or anything else is the 
> reason for the current logic then why allow an address to be assigned in 
> the down state? Similarly that it currently seems to work ok then it 
> suggests the right thing is done on a link up in which case a flush is 
> not needed.
> 
> Bottom line is there a harm in removing the flush? If there is no harm 
> will mainline kernel take a patch to do that or is your backward 
> compatibility concern enough to block it?

This was already discussed several times here, e.g. one patch I just 
found:

http://lists.openwall.net/netdev/2011/01/24/8
and
http://patchwork.ozlabs.org/patch/17558/

Albeit I hate sysctls for things like this, it might I tend to find it
acceptable because it solves a problem which happened to lots of people.
And I don't like the current behavior neither.

I think this can work, but we should follow up all the old discussions
to not introduce any kind of new undesired behavior this time.

Thanks,
Hannes
