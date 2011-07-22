From: David Miller <davem@davemloft.net>
Subject: Re: IPv6: autoconfiguration and suspend/resume or link down/up
Date: Fri, 22 Jul 2011 01:06:28 -0700 (PDT)
Message-ID: <20110722.010628.1678943945721626312.davem@davemloft.net>
References: <20110719180222.GA7509@midget.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.hengli.com.au,
	shemminger@vyatta.com
To: jbohac@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40504 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147Ab1GVIGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 04:06:42 -0400
In-Reply-To: <20110719180222.GA7509@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Bohac <jbohac@suse.cz>
Date: Tue, 19 Jul 2011 20:02:53 +0200

> When the cable is unplugged and plugged in again, we already get
> notified through linkwatch -> netdev_state_change ->
>   -> call_netdevice_notifiers(NETDEV_CHANGE, ...)
> However, if the device has already been autoconfigured,
> addrconf_notify() only handles this event by printing a
> message.
> 
> So my idea was to:
> - handle link up/down in addrconf_notify() similarly to
>   NETDEV_UP/NETDEV_DOWN
> 
> - on suspend, faking a link down event; on resume, faking a link up event
>   (or better, having a special event type for suspend/resume)
> 
> This would cause autoconfiguration to be restarted on resume as
> well as cable plug/unplug, solving both the above problems.
> 
> Or do we want to completely rely on userspace tools
> (networkmanager/ifplug) and expect them to do NETDEV_DOWN on
> unplug/suspend and NETDEV_UP on plug/resume?
> 
> Any thoughts?

This is an oft-reocurring discussion, what to do on link up/down
events wrt. all sorts of autoconfiguration.

My gut instinct is that on any link state change (physical link down,
suspend) we should be prepared to renegotiate everything and anything
since as you state we could be on a different physical network.

Suspend is even more important because while we were suspended we
could be on the same network but the routers present and available
might have changed completely.

In userspace I've noticed that we've grown an ecosystem of stupid
tools and facilities, none (or very few) of which monitor link status
in order to do handle things intelligently.  DHCP servers are a great
example.  DHCP servers spit out broadcast discover packets before we
even have a link up.

Filling this void is NetworkManager, which does listen on a netlink
socket for device state changes, hotplug, etc.  And in response it
explicitly tells various facilities to reprobe the network.

This is why I'm reluctant to give NetworkManager a hard time, because
whilst it's a huge beast, it is at least trying to do the right thing.
:-)
