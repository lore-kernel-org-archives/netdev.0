From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [Bonding-devel] [PATCH 3/3] bonding: Improve IGMP join processing
Date: Fri, 9 Mar 2007 11:53:45 -0500
Message-ID: <20070309165344.GA29496@gospo.rdu.redhat.com>
References: <20070307015012.GA4783@core2.greyhouse.net> <OF3F503F34.0DCEF024-ON88257297.0010A9D5-88257297.00126F62@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>,
	bonding-devel@lists.sourceforge.net,
	Brian Haley <brian.haley@hp.com>, fubar@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47809 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767390AbXCIQy7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 11:54:59 -0500
Content-Disposition: inline
In-Reply-To: <OF3F503F34.0DCEF024-ON88257297.0010A9D5-88257297.00126F62@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 06, 2007 at 07:21:30PM -0800, David Stevens wrote:
>  > >    Marking the master down would, I believe, issue notifiers that
> > > the device has gone down.  Various things, network manager sort of
> > > applications in particular, listen to those, so I'm not sure it's a 
> good
> > > idea.  I think there are other side effects as well, I'm thinking it
> > > would flush routes associated with the interface as well.
> 
> [BTW, you can call ip_mc_down()/ip_mc_up() directly w/o getting there
>         from the notifiers -- then no side-effects.]
> 

While this might seem like a nice solution if we think only about what
would cause the smallest change to igmp.c (since you just need to add a
small patch to export additional symbols), I shudder to think about the
disruption that this could cause in the network in some cases.

> Andy Gospodarek wrote:
> > 
> > I agree with Jay here.  I hate that bonding has to have so much
> > knowledge about upper layer protocols, but for the ones that are
> > stateful like IGMP we will need fixes like the one proposed.
> 
>         I have no problem with bonding having knowledge of ULP's (I
> don't like it, but I don't have to look at it :-) ), but the
> patch is doing it the other way around. What I don't like about the
> proposed patch is that it's adding knowledge of bonding to IGMP.

I disagree with this statement.  Why does adding an extra function to
aide in the transmission of additional igmp joins cause igmp to have
knowledge of bonding?

>         And IGMP does work fine in this case, w/o flooding or the
> proposed patch. It just has the risk of losing multicast packets
> during one query interval, and that only happens if you're
> using a switch that does IGMP snooping.

I feel like igmp snooping is a pretty widely used feature and I would
guess that it is used by anyone doing a/b bonding that has concerns
about igmp failover.

>         I'd like the patch a lot better if it were basicly this:
> 
> mc_bond_fudge(void)
> {
>         ip_mc_down(masterdev);
> /*do whatever you need to do to switch the slave */
>         ip_mc_up(masterdev);
> }
> 
>         That doesn't go through the notifier chain, uses existing
> functions, doesn't have any refcnt issues, and most importantly
> could/should reside in a bonding source file and not in igmp.c. :-)
>         But RTNL is required whether you use up/down or roll your
> own variant, so it sounds like you have other issues to resolve too.

The RTNL stuff would be all done work if Jay would just accept my
workqueue patch.  ;-)

> 
>                                                         +-DLS
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
