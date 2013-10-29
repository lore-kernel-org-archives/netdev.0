From: Dan Williams <dcbw@redhat.com>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with
 IFLA_F_TEMPORARY flag
Date: Tue, 29 Oct 2013 12:21:11 -0500
Message-ID: <1383067271.2236.71.camel@dcbw.foobar.com>
References: <CAGCdqXHUW=RJf67qPXVRhPY__GAs02+G9mJV7agN5pDdfELXXA@mail.gmail.com>
	 <20131027132941.GA1443@minipsycho.orion>
	 <20131027164835.GB4714@order.stressinduktion.org>
	 <20131028.171725.1076499130782328273.davem@davemloft.net>
	 <1383002179.28991.14.camel@dcbw.foobar.com>
	 <20131028234842.GB26185@order.stressinduktion.org>
	 <1383057078.2236.12.camel@dcbw.foobar.com>
	 <20131029143847.GB16253@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jiri@resnulli.us,
	vyasevich@gmail.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	thaller@redhat.com, stephen@networkplumber.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54485 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758051Ab3J2RWD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 13:22:03 -0400
In-Reply-To: <20131029143847.GB16253@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-29 at 15:38 +0100, Hannes Frederic Sowa wrote:
> Hi!
> 
> On Tue, Oct 29, 2013 at 09:31:18AM -0500, Dan Williams wrote:
> > On Tue, 2013-10-29 at 00:48 +0100, Hannes Frederic Sowa wrote:
> > > On Mon, Oct 28, 2013 at 06:16:19PM -0500, Dan Williams wrote:
> > > > On Mon, 2013-10-28 at 17:17 -0400, David Miller wrote:
> > > > > From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > > > > Date: Sun, 27 Oct 2013 17:48:35 +0100
> > > > > 
> > > > > > A temporary address is also bound to a non-privacy public address so
> > > > > > it's lifetime is determined by its lifetime (e.g. if you switch the
> > > > > > network and don't receive on-link information for that prefix any
> > > > > > more). NetworkManager would have to take care about that, too. It is
> > > > > > just a question of what NetworkManager wants to handle itself or lets
> > > > > > the kernel handle for it.
> > > > > 
> > > > > How much really needs to be in userspace to implement RFC4941?
> > > > > 
> > > > > I don't like the idea that even for a fully up and properly
> > > > > functioning link, if NetworkManager wedges then critical things like
> > > > > temporary address (re-)generation, will cease.
> > > > 
> > > > Honestly, I'd be completely happy to leave temporary address handling up
> > > > to the kernel and *not* do it in userspace; the kernel already has all
> > > > the code.  There are two problems with that though, (a) it's tied to
> > > > in-kernel RA handling, and (b) it's controlled by a CONFIG option.  Both
> > > > these are solvable.
> > > 
> > > Ah, (a) does complicate things, I agree. But the tieing is essential
> > > currently. So it seems a netlink interface would be needed to tie a new
> > > address to an already installed one, if the kernel should still deal
> > > with the regeneration?
> > 
> > I think it's simpler than that.  New flag set when adding the
> > non-private address that says "create and manage privacy addresses for
> > this non-private address".  The kernel then adds the privacy addresses
> > generated off the non-private address/prefixlen, and ties their lifetime
> > to the non-private address.  If the non-private address is removed, the
> > privacy addresses could get removed too.
> > 
> > I don't think we need API to tie addresses to already installed ones,
> > because the kernel already has the privacy address generation code, so
> > why should userspace generate the privacy address at all?  Just leave
> > that to the kernel.
> 
> Ok.
> 
> > > > First off, what's the reasoning behind having IPv6 privacy as a config
> > > > option?  It's off-by-default and must be explicitly turned on, so is
> > > > there any harm in removing the config?  Or is it just for
> > > > smallest-kernel-ever folks?
> > > 
> > > I don't know about the policy. Does it really matter as distributions
> > > normally switch it on? But I would not like to see the option removed
> > > entirly, maybe the default could be changed.
> > > 
> > > > Would a new IFA_F_MANAGE_TEMP (or better name) work here, indicating
> > > > that for some new static address, that the kernel should create and
> > > > manage the temporary privacy addresses associated with its prefix?
> > > 
> > > But this would only be needed if they were managed in user-space, no?
> > 
> > "if they" == what?  privacy address or static address?  What
> 
> With "they" I meant privacy addresses.
> 
> > NetworkManager is trying to do is handle RAs in userspace with libndp
> > for various flexibility and behavioral reasons, but we'd really like to
> > leave all the temporary address stuff up to the kernel.
> 
> Can you provide me with details why the Kernel RA implementation is not good
> enough? I tried to find some bugs, I found some but they were missing details
> or were not even correct or outdated.

First, RA handling is too tightly tied to interface flags.  This is a
problem because interfaces are required to be IFF_UP for various
operations like carrier detection, wireless scanning, reading certain
interface properties, link statistics, etc.  We can play games with
flipping accept_ra, but changing accept_ra doesn't trigger an RS.  At
the moment, only interface flag changes trigger an RS, and that also can
reset a lot of L2 state.

Second, Router Solicitations are required at various times other than
NETDEV_CHANGE/NETDEV_UP.  The router is not guaranteed to send (nor are
we guaranteed to receive) an RA when the RDNSS/DNSSL approach their
lifetimes, so to ensure those values are still still valid, we need to
send out an RS, especially on lossy networks where the RA might get
dropped.

Third, we need more flexibility in reading ND user options like DNSSL
and RDNSS and newer stuff.  Every new option that userspace might want
to process requires some kernel code (ndisc_is_useropt()) to push it out
to userspace, and that means these options are not available on older
kernels.

Fourth, there's no opportunity to override any of the RA-derived
settings with user preferences before the kernel commits them.  Perhaps
the user wishes to ignore a specific prefix (but accept other prefixes
or other RAs), or to ignore the automatically provided routes, or
whatever.

> > So NM would handle RA/RS and when it gets a prefix, it would create the
> > IPv6 non-private address and add it to the interface.  When adding, it
> > would also set the "IFA_F_MANAGE_TEMP" flag (or whatever) and the kernel
> > would then handle all the privacy address generation, lifetimes, and
> > timers.  Basically, break some of the privacy code away from the
> > in-kernel RA handling so that privacy addresses could be triggered from
> > userland too.
> > 
> > Would that be workable?
> 
> That sounds like a solid plan for me. I would actually liked to see that NM
> would use the kernel implementation but I guess there is no way back any more.
> :(

Some of the issues mentioned above might be inappropriate to solve
entirely in the kernel.  I have no problem with in-kernel IPv6 for
simple use-cases and it works great for these.  But if we think about
more complex functionality, especially where userland might want an
opportunity to override some of the behavior, and backwards
compatibility with kernels that don't implement these changes, we'd like
to handle some addrconf in userspace.

Dan
