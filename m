From: Dan Williams <dcbw@redhat.com>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with
 IFLA_F_TEMPORARY flag
Date: Tue, 29 Oct 2013 09:31:18 -0500
Message-ID: <1383057078.2236.12.camel@dcbw.foobar.com>
References: <CAGCdqXHUW=RJf67qPXVRhPY__GAs02+G9mJV7agN5pDdfELXXA@mail.gmail.com>
	 <20131027132941.GA1443@minipsycho.orion>
	 <20131027164835.GB4714@order.stressinduktion.org>
	 <20131028.171725.1076499130782328273.davem@davemloft.net>
	 <1383002179.28991.14.camel@dcbw.foobar.com>
	 <20131028234842.GB26185@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jiri@resnulli.us,
	vyasevich@gmail.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	thaller@redhat.com, stephen@networkplumber.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27884 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753202Ab3J2OcR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 10:32:17 -0400
In-Reply-To: <20131028234842.GB26185@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-29 at 00:48 +0100, Hannes Frederic Sowa wrote:
> On Mon, Oct 28, 2013 at 06:16:19PM -0500, Dan Williams wrote:
> > On Mon, 2013-10-28 at 17:17 -0400, David Miller wrote:
> > > From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > > Date: Sun, 27 Oct 2013 17:48:35 +0100
> > > 
> > > > A temporary address is also bound to a non-privacy public address so
> > > > it's lifetime is determined by its lifetime (e.g. if you switch the
> > > > network and don't receive on-link information for that prefix any
> > > > more). NetworkManager would have to take care about that, too. It is
> > > > just a question of what NetworkManager wants to handle itself or lets
> > > > the kernel handle for it.
> > > 
> > > How much really needs to be in userspace to implement RFC4941?
> > > 
> > > I don't like the idea that even for a fully up and properly
> > > functioning link, if NetworkManager wedges then critical things like
> > > temporary address (re-)generation, will cease.
> > 
> > Honestly, I'd be completely happy to leave temporary address handling up
> > to the kernel and *not* do it in userspace; the kernel already has all
> > the code.  There are two problems with that though, (a) it's tied to
> > in-kernel RA handling, and (b) it's controlled by a CONFIG option.  Both
> > these are solvable.
> 
> Ah, (a) does complicate things, I agree. But the tieing is essential
> currently. So it seems a netlink interface would be needed to tie a new
> address to an already installed one, if the kernel should still deal
> with the regeneration?

I think it's simpler than that.  New flag set when adding the
non-private address that says "create and manage privacy addresses for
this non-private address".  The kernel then adds the privacy addresses
generated off the non-private address/prefixlen, and ties their lifetime
to the non-private address.  If the non-private address is removed, the
privacy addresses could get removed too.

I don't think we need API to tie addresses to already installed ones,
because the kernel already has the privacy address generation code, so
why should userspace generate the privacy address at all?  Just leave
that to the kernel.

> > First off, what's the reasoning behind having IPv6 privacy as a config
> > option?  It's off-by-default and must be explicitly turned on, so is
> > there any harm in removing the config?  Or is it just for
> > smallest-kernel-ever folks?
> 
> I don't know about the policy. Does it really matter as distributions
> normally switch it on? But I would not like to see the option removed
> entirly, maybe the default could be changed.
> 
> > Would a new IFA_F_MANAGE_TEMP (or better name) work here, indicating
> > that for some new static address, that the kernel should create and
> > manage the temporary privacy addresses associated with its prefix?
> 
> But this would only be needed if they were managed in user-space, no?

"if they" == what?  privacy address or static address?  What
NetworkManager is trying to do is handle RAs in userspace with libndp
for various flexibility and behavioral reasons, but we'd really like to
leave all the temporary address stuff up to the kernel.

So NM would handle RA/RS and when it gets a prefix, it would create the
IPv6 non-private address and add it to the interface.  When adding, it
would also set the "IFA_F_MANAGE_TEMP" flag (or whatever) and the kernel
would then handle all the privacy address generation, lifetimes, and
timers.  Basically, break some of the privacy code away from the
in-kernel RA handling so that privacy addresses could be triggered from
userland too.

Would that be workable?

Dan 
