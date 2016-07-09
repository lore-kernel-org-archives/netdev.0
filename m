From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net] ipv4: reject RTNH_F_LINKDOWN for incompatible
 routes
Date: Sat, 9 Jul 2016 23:11:36 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1607092242360.1557@ja.home.ssi.bg>
References: <1468054815-24766-1-git-send-email-ja@ssi.bg> <20160709172327.GP18787@gospo.rdu.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Vegard Nossum <vegard.nossum@oracle.com>,
	Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:49294 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752843AbcGIUL5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2016 16:11:57 -0400
In-Reply-To: <20160709172327.GP18787@gospo.rdu.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sat, 9 Jul 2016, Andy Gospodarek wrote:

> On Sat, Jul 09, 2016 at 12:00:15PM +0300, Julian Anastasov wrote:
> > Vegard Nossum is reporting for a crash in fib_dump_info (fib_nhs==1)
> > when nh_dev = NULL. Problem happens when RTNH_F_LINKDOWN is
> > provided from user space for routes that do not use the flag,
> > catched with netlink fuzzer.
> 
> Can you also include the panic log in the changelog or at a minimum post
> it here?

	Now after Vegard posted it, I'll include in v2.

> > RTNH_F_LINKDOWN should be used only for link routes, not for
> > local routes or for routes with error code. Do not complicate
> > fast path with more checks, reject the flag early when configured
> > for incompatible routes.
> 
> Did the netlink fuzzer (trinity?) happen to check any of the other flags
> (liks RTNH_F_DEAD) that are normally set by the kernel but could be
> problematic when send down from userspace?

	My guess is that fib_flush will release it soon or
later. I preferred to reject the RTNH_F_LINKDOWN flag only
for some kind of routes but another alternative is to always
reject both RTNH_F_LINKDOWN and RTNH_F_DEAD: RTNH_F_LINKDOWN
is recalculated and there is no good reason user space to
provide initial value for flag that is maintained by kernel.

> >  	if (fib_props[cfg->fc_type].error) {
> > -		if (cfg->fc_gw || cfg->fc_oif || cfg->fc_mp)
> > +		if (cfg->fc_gw || cfg->fc_oif || cfg->fc_mp ||
> > +		    (fi->fib_nh->nh_flags & RTNH_F_LINKDOWN))
> >  			goto err_inval;
> 
> It looks a bit odd to use cfg in the existing checkd and fi->fib_nh in
> the rest, but not a huge issue since cfg->fc_flags and
> fi->fib_nh->nh_flags should be equivalent should be the same for single
> and multipath routes.

	Using fc_flags works too for the above case. In fact,
it goes also to fib_flags, so we should have our checks there.
But it is true that RTNH_F_LINKDOWN is not used from fib_flags,
I think, we already had a chance to talk about it on 27 Oct 2015.

	May be we can reject the both flags once for
rtnh_flags in fib_get_nhs() and then for fc_flags in
fib_create_info().

Regards
