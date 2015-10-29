From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCHv2 net 2/2] ipv4: update RTNH_F_LINKDOWN flag on UP
 event
Date: Thu, 29 Oct 2015 22:15:51 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1510292135550.2300@ja.home.ssi.bg>
References: <1445896753-14464-1-git-send-email-ja@ssi.bg> <1445896753-14464-3-git-send-email-ja@ssi.bg> <20151027045203.GG3567@gospo.home.greyhouse.net> <alpine.LFD.2.11.1510270905500.1994@ja.home.ssi.bg> <20151027183737.GH3567@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:60513 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752355AbbJ2UQB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2015 16:16:01 -0400
In-Reply-To: <20151027183737.GH3567@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 27 Oct 2015, Andy Gospodarek wrote:

> > 	Of course, we have a semantic problem when setting
> > RTNH_F_LINKDOWN on last address removal, i.e. this event
> > has nothing to do with the link state. But it works because
> > RTNH_F_LINKDOWN is valid for lookups only when DEAD flag
> > is not set, so that is why my patch looks this way.
> The problem you describe here was a concern of mine as well.  I would
> really like the output of 'ip route show' to properly reflect the link
> state and fix the problem you describe, but it seems like it will not in
> this case with your current patch.  I'll do a bit more testing and let
> you know.

	Another option is to remove the RTNH_F_LINKDOWN
usage from any event, from FIB structs. In case only
netif_carrier_ok check is needed, it looks cheap to just
call it after the IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN check.
When showing it to user space we can again use netif_carrier_ok.

	The new fib_rebalance() is special, it still
needs to be called, just like now on NETDEV_CHANGE
event but only when ignore_routes_with_linkdown=1, i.e.
we can avoid calling fib_sync_up/fib_sync_down_dev in
fib_netdev_event if the flag is not set, guarded by 
CONFIG_IP_ROUTE_MULTIPATH check.

	To make this work we can also call somehow
fib_rebalance() from devinet_conf_proc() context when
the flag is changed, all this is for the
CONFIG_IP_ROUTE_MULTIPATH case.

Regards

--
Julian Anastasov <ja@ssi.bg>
