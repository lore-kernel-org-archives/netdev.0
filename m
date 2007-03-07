From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [Bonding-devel] [PATCH 3/3] bonding: Improve IGMP join processing
Date: Tue, 6 Mar 2007 16:45:45 -0800
Message-ID: <OF5C8C5CA8.4BC1B722-ON88257297.00029119-88257297.00042D61@us.ibm.com>
References: <11176.1173222941@death>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "Andy Gospodarek" <andy@greyhouse.net>,
	bonding-devel@lists.sourceforge.net,
	Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: fubar@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:49236 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161060AbXCGApt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 19:45:49 -0500
In-Reply-To: <11176.1173222941@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fubar@linux.vnet.ibm.com wrote on 03/06/2007 03:15:41 PM:

> 
> David Stevens <dlstevens@us.ibm.com> wrote:
> 
> >It looks to me like "rejoin" is essentially ip_mc_up(), and it'd be 
better
> >to call that than add a nearly identical function.
> 
>    Won't ip_mc_up() acquire an additional reference (via
> ip_mc_inc_group) to the IGMP_ALL_HOSTS im->users that would never be
> released (in the case of bonding calling the function out of the blue)?

        Yes. I'm not sure that matters-- destroy_dev doesn't care how many
references to a group, and IGMP_ALL_HOSTS isn't advertised (so wouldn't
get a "leave" when you only down the interface, like other groups do).
But since ip_mc_up() is *entirely* that join plus group_added() on all
the existing groups, there really shouldn't be another. But the new device
will need the all-hosts group in its hardware multicast filter, too, if
it hasn't already been using multicasting. Your "reload" caller could just
dec_group that group after calling ip_mc_up().

>    In looking at it, the ip_mc_rejoin_group function (the new one
> added with the patch) is a lot more like igmp_group_added() than
> ip_mc_up().
No, group_added() is one group. mc_up() just calls group_added on all
of them, which I think is what the rejoin was trying to do.

>I'm not sure if the extra bits in igmp_group_added() are
> worthy of concern; I'm thinking not, since im->loaded shouldn't be zero
> coming in for the bonding case.
        "im->loaded" means the device has it in its multicast address 
filter.
If you're switching devices, and didn't do all the multicast stuff on all
the devices originally, then you want it to be 0 (and should make it so,
like ip_mc_down() does). :-)

>    I think the meat that the "rejoin" wants is what's in
> igmpv3_send_cr(), which appears to do the actual sending stuff.  I'm not
> sure if that's better to call directly (and risk locking adventures) or
> to just trip the timer via igmp_ifc_event().

        No, no, no -- please don't mess with those directly. It'd be a 
maintenance
nightmare, and multicasting is device independent right now. :-) I'd hope 
there
wouldn't be any bonding-specific code needed at this layer, which is why I 
hope
something like using up/down would work out.

                                                                +-DLS

