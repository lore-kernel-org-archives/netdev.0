From: Jiri Bohac <jbohac@suse.cz>
Subject: IPv6: autoconfiguration and suspend/resume or link down/up
Date: Tue, 19 Jul 2011 20:02:53 +0200
Message-ID: <20110719180222.GA7509@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	stephen hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35060 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750987Ab1GSSC4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2011 14:02:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I came over a surprising behaviour with IPv6 autoconfiguration,
which I think is a bug, but I would first like to hear other
people's opinions before trying to fix this:

Problem 1: all the address/route lifetimes are kept in jiffies
and jiffies don't get incremented on resume. So when a
route/address lifetime is 30 minutes and the system resumes after
1 hour, the route/address should be considered expired, but it is
not.

Problem 2: when a system is moved to a new network a RS is not
sent. Thus, IPv6 does not autoconfigure until the router sends a
periodic RA. This can occur both while the system is alive and
while it is suspended. I think the autoconfigured state should be
discarded when the kernel suspects the system could have been
moved to a different network.

When the cable is unplugged and plugged in again, we already get
notified through linkwatch -> netdev_state_change ->
  -> call_netdevice_notifiers(NETDEV_CHANGE, ...)
However, if the device has already been autoconfigured,
addrconf_notify() only handles this event by printing a
message.

So my idea was to:
- handle link up/down in addrconf_notify() similarly to
  NETDEV_UP/NETDEV_DOWN

- on suspend, faking a link down event; on resume, faking a link up event
  (or better, having a special event type for suspend/resume)

This would cause autoconfiguration to be restarted on resume as
well as cable plug/unplug, solving both the above problems.

Or do we want to completely rely on userspace tools
(networkmanager/ifplug) and expect them to do NETDEV_DOWN on
unplug/suspend and NETDEV_UP on plug/resume?

Any thoughts?

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

