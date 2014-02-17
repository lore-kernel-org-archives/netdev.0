From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] ipv6: fix inconsistent prefix route handling
Date: Mon, 17 Feb 2014 15:08:26 +0100
Message-ID: <20140217140826.GD22833@order.stressinduktion.org>
References: <20140216165128.GF8634@order.stressinduktion.org> <5301AF26.7080102@openwrt.org> <20140217130557.GC22833@order.stressinduktion.org> <53020AF7.60702@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Steven Barth <cyrus@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60804 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752832AbaBQOI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 09:08:28 -0500
Content-Disposition: inline
In-Reply-To: <53020AF7.60702@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 17, 2014 at 02:13:27PM +0100, Steven Barth wrote:
> Ah sorry, maybe I was a bit unclear about this. With temporary addresses 
> I meant addresses created like this:
> 
> ip address add 2001:db8::1/64 dev eth0 valid_lft 1234 preferred_lft 1001
> 
> or the equivalent netlink-calls and with permanent addresses i was 
> referring to addresses created similarly but with an infinite lifetime 
> (e.g. through ip without giving valid_lft or preferred_lft arguments).
> 
> Hope that makes it clear.

Yes, makes sense, thanks!

I fear there is currently no combination of ifp->flags which can test for
that. Your first patch seems to be too dangerous in removing neighbour
discovery brought in on-link state, I fear. It may even be a problem for
permanent ones, but that's how it is done, currently.

Best option would be to fully decouple prefix routes from address handling,
but that would break current userspace.

Current iproute has support for no-prefix-route address addition (see
iproute2 commit 58c69b226fb3a ("add support for IFA_F_NOPREFIXROUTE")), so you
could manage those address and route combination directly from user space.

So if we want to clean up those routes we either must set IFA_F_PERMANENT to
the ifp flags of the address in inet6_addr_add and really make sure nothing
breaks because of this. Or introduce a new flag, like IFA_F_USERINSTALLED e.g.

Current ifp flags handling is really complex and we had some bad bugs
in recent changes, so I guess, it is not a trivial task (I reviewed the
last patches changing code in that for hours and they still had bugs :/), so I
am unsure what is the right approach. Both ways (adding PERMANENT) and adding
a new IFP_P_USERINSTALLED would need to be considered and reviewed.

Thanks,

  Hannes
