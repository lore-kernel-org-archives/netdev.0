From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 2/2] ipv6 addrconf: don't cleanup route prefix for IFA_F_NOPREFIXROUTE
Date: Tue, 7 Jan 2014 20:01:48 +0100
Message-ID: <20140107190148.GD30393@order.stressinduktion.org>
References: <1389029375-17698-1-git-send-email-thaller@redhat.com> <1389105553-21230-1-git-send-email-thaller@redhat.com> <1389105553-21230-3-git-send-email-thaller@redhat.com> <20140107162847.GB30393@order.stressinduktion.org> <1389119577.2248.16.camel@weing>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	stephen@networkplumber.org, dcbw@redhat.com
To: Thomas Haller <thaller@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45981 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766AbaAGTBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 14:01:50 -0500
Content-Disposition: inline
In-Reply-To: <1389119577.2248.16.camel@weing>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Jan 07, 2014 at 07:32:57PM +0100, Thomas Haller wrote:
> On Tue, 2014-01-07 at 17:28 +0100, Hannes Frederic Sowa wrote:
> > On Tue, Jan 07, 2014 at 03:39:13PM +0100, Thomas Haller wrote:
> > > Also, when adding the NOPREFIXROUTE flag to an already existing address,
> > > check if there there is a prefix that was likly added by the kernel
> > > and delete it.
> > 
> > Hmm, could you give a bit more details why you have done this? I find
> > that a bit counterintuitive. Maybe it has a reason?
> > 
> 
> You find the behavior or the commit message counterintuitive? Didn't you
> suggest this behavior in your email from "7 Jan 2014 13:01:11 +0100"?

I guess I was a bit confused, sorry. I think I confused the deleted and modify
case. However:

So we have the following changes on addresses:

add is simple: just as in the first patch

modify: is a bit hairy. To be extremly exact, we would have to recreate the
	route with proper metrics etc. so delete in any case and reinsert.
	I really dislike removing a route someone else might have inserted
	manually, and this is a likely scenario.

	Somehow I tend to just don't allow NOPREFIXROUTE on modify at all and
	just return a proper error value. What do you think? What would be the
	best behavior for NM?

delete: if IFA_F_NOPREFIXROUTE is set, we don't care about removing a prefix
	route, it must be set by user space and should get cleaned up by user
	space

> 
> 
> For v3 I will reword the commit message. How about the following:
> 
>     ipv6 addrconf: don't cleanup prefix route for IFA_F_NOPREFIXROUTE
>     
>     Refactor the deletion/update of prefix routes when removing an
>     address. Now, consider IFA_F_NOPREFIXROUTE and if there is an address
>     present with this flag, to not cleanup the route. Instead, assume
>     that userspace is taking care of this prefix.
>     
>     Also perform the same cleanup, when userspace changes an existing address
>     to add NOPREFIXROUTE to an address that didn't have this flag. We do this
>     because when the address was added, a prefix route was created for it.
>     Since the user now wants to handle this route by himself, we remove it again.
>     
>     As before, a prefix route only gets removed, if there is no address
>     that might need it. Or, if there are only non-permanent addresses,
>     update the lifetime of the route.

If we want go with the current modify behavior this sounds good.

Thanks,

  Hannes
