From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [Bonding-devel] [PATCH 3/3] bonding: Improve IGMP join processing
Date: Tue, 6 Mar 2007 19:21:30 -0800
Message-ID: <OF3F503F34.0DCEF024-ON88257297.0010A9D5-88257297.00126F62@us.ibm.com>
References: <20070307015012.GA4783@core2.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Andy Gospodarek <andy@greyhouse.net>,
	bonding-devel@lists.sourceforge.net,
	Brian Haley <brian.haley@hp.com>, fubar@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: "Andy Gospodarek" <gospo@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:60460 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030781AbXCGDVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 22:21:35 -0500
In-Reply-To: <20070307015012.GA4783@core2.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > >    Marking the master down would, I believe, issue notifiers that
> > the device has gone down.  Various things, network manager sort of
> > applications in particular, listen to those, so I'm not sure it's a 
good
> > idea.  I think there are other side effects as well, I'm thinking it
> > would flush routes associated with the interface as well.

[BTW, you can call ip_mc_down()/ip_mc_up() directly w/o getting there
        from the notifiers -- then no side-effects.]

Andy Gospodarek wrote:
> 
> I agree with Jay here.  I hate that bonding has to have so much
> knowledge about upper layer protocols, but for the ones that are
> stateful like IGMP we will need fixes like the one proposed.

        I have no problem with bonding having knowledge of ULP's (I
don't like it, but I don't have to look at it :-) ), but the
patch is doing it the other way around. What I don't like about the
proposed patch is that it's adding knowledge of bonding to IGMP.
        And IGMP does work fine in this case, w/o flooding or the
proposed patch. It just has the risk of losing multicast packets
during one query interval, and that only happens if you're
using a switch that does IGMP snooping.
        I'd like the patch a lot better if it were basicly this:

mc_bond_fudge(void)
{
        ip_mc_down(masterdev);
/*do whatever you need to do to switch the slave */
        ip_mc_up(masterdev);
}

        That doesn't go through the notifier chain, uses existing
functions, doesn't have any refcnt issues, and most importantly
could/should reside in a bonding source file and not in igmp.c. :-)
        But RTNL is required whether you use up/down or roll your
own variant, so it sounds like you have other issues to resolve too.

                                                        +-DLS


