From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] [PATCH 3/3] bonding: Improve IGMP join processing
Date: Tue, 06 Mar 2007 15:15:41 -0800
Message-ID: <11176.1173222941@death>
References: <OF686AF962.8A54116E-ON88257296.007AF408-88257296.007BC448@us.ibm.com>
Cc: "Andy Gospodarek" <andy@greyhouse.net>, netdev@vger.kernel.org,
	Brian Haley <brian.haley@hp.com>,
	bonding-devel@lists.sourceforge.net, netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:52590 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030658AbXCFXSL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 18:18:11 -0500
In-reply-to: <OF686AF962.8A54116E-ON88257296.007AF408-88257296.007BC448@us.ibm.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


David Stevens <dlstevens@us.ibm.com> wrote:

>It looks to me like "rejoin" is essentially ip_mc_up(), and it'd be better
>to call that than add a nearly identical function.

	Won't ip_mc_up() acquire an additional reference (via
ip_mc_inc_group) to the IGMP_ALL_HOSTS im->users that would never be
released (in the case of bonding calling the function out of the blue)?

	In looking at it, the ip_mc_rejoin_group function (the new one
added with the patch) is a lot more like igmp_group_added() than
ip_mc_up().  I'm not sure if the extra bits in igmp_group_added() are
worthy of concern; I'm thinking not, since im->loaded shouldn't be zero
coming in for the bonding case.

	I think the meat that the "rejoin" wants is what's in
igmpv3_send_cr(), which appears to do the actual sending stuff.  I'm not
sure if that's better to call directly (and risk locking adventures) or
to just trip the timer via igmp_ifc_event().

	Anyway, it looks like all of this needs to be done under RTNL,
which isn't the case, so I need to go off and look into reworking it
again.

	Andy: do you have any work in progress on the sleep / rtnl stuff
we've been discussing?

>Also, real interfaces already do gratuitous IGMP advertisements when
>they are bounced (the reason there is an ip_mc_up()). Could bonding,
>when failing over, simply mark the master interface as down, switch, and
>then mark the master as up again? In addition to doing the right
>thing for both IPv4 and IPv6 multicasting w/o any code changes in those
>layers, it may have similar benefits for ARP and neighbor discovery, 
>right?

	Marking the master down would, I believe, issue notifiers that
the device has gone down.  Various things, network manager sort of
applications in particular, listen to those, so I'm not sure it's a good
idea.  I think there are other side effects as well, I'm thinking it
would flush routes associated with the interface as well.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
