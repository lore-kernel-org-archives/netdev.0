From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: IPv6: autoconfiguration and suspend/resume or link down/up
Date: Wed, 20 Jul 2011 09:15:56 -0700
Message-ID: <20110720091556.619a0c14@nehalam.ftrdhcpuser.net>
References: <20110719180222.GA7509@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58527 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752341Ab1GTQP6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 12:15:58 -0400
In-Reply-To: <20110719180222.GA7509@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 19 Jul 2011 20:02:53 +0200
Jiri Bohac <jbohac@suse.cz> wrote:

> Hi,
> 
> I came over a surprising behaviour with IPv6 autoconfiguration,
> which I think is a bug, but I would first like to hear other
> people's opinions before trying to fix this:
> 
> Problem 1: all the address/route lifetimes are kept in jiffies
> and jiffies don't get incremented on resume. So when a
> route/address lifetime is 30 minutes and the system resumes after
> 1 hour, the route/address should be considered expired, but it is
> not.
> 
> Problem 2: when a system is moved to a new network a RS is not
> sent. Thus, IPv6 does not autoconfigure until the router sends a
> periodic RA. This can occur both while the system is alive and
> while it is suspended. I think the autoconfigured state should be
> discarded when the kernel suspects the system could have been
> moved to a different network.
> 
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

What hardware?

I think the normal solution is to have the device drop the link
during it's suspend and then attempt to renegotiate it on resume.
This is needed for wired (autonegotiation) and wireless already.
There maybe old drivers that don't do this. That is probably why
Ubuntu and other distro's used to rmmod the drivers during suspend.

If the driver drops the link during suspend then the necessary link
events happen to keep bridging, ipv6, bonding and all the other possible
network protocols happy.

