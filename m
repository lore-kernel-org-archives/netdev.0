From: David Miller <davem@davemloft.net>
Subject: Re: probe netlink app in NUD_PROBE
Date: Tue, 25 Feb 2014 18:18:44 -0500 (EST)
Message-ID: <20140225.181844.1715731388552960836.davem@davemloft.net>
References: <20140222104419.6b4daa44@vostro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58505 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbaBYXSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 18:18:48 -0500
In-Reply-To: <20140222104419.6b4daa44@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timo Teras <timo.teras@iki.fi>
Date: Sat, 22 Feb 2014 10:44:19 +0200

> When a stale or delayed neigh entry is being re-validated the entry
> goes to NUD_PROBE state. At the moment only unicast probes are sent.
> This is basically because neigh_max_probes() limits the probe amount so.
> 
> Now, opennhrp intentionally configures UCAST_PROBES and MCAST_PROBES to
> zero and APP_PROBES to something meaningful. The idea is that opennhrp
> replaces arp completely with NHRP implemented in userland.
> 
> Due to this it seems there is a very small time window, when the
> NUD_PROBE times out and the neighbour entry gets invalidated, and
> packets get lost.
> 
> To remedy this, I would like to have these NUD_PROBE validations sent
> via netlink too.
> 
> First choice is to change to just use both unicast and application
> probes:

So basically, the generic and protocol-specific neighbour code work
together to implement a cascading priority based probing scheme using
a per-neigh counter and three limits.

It seems that neigh->probes is zero when we enter the probing state.

On each solicit we increment neigh->probes.

Then we have this very funny logic in the protocol specific
implementations of solicit:

	probes = atomic_read(&neigh->probes);

	probes -= UCAST_PROBES;
	if (probes < 0) {
		send unicast probe;
	} else {
		probes -= APP_PROBES;
		if (probes < 0) {
			trigger application based probe via netlink
		} else {
			send multicast probe;
		}
	}

As an example, for ipv4 arp, UCAST_PROBES defaults to 3 and APP_PROBES
defaults (as you say) to zero.

If neigh_max_probes() evaluates to UCAST_PROBES, we'll do 3 unicast
probes then fail the neigh, for example.

I took a look at iproute2's arpd, and I suggest you take a gander
over there as well.

If given the '-a N' option it will set app_probes to N and send it's
own ARP requests out in certain situations.

It might depend upon the current behavior of neigh_max_probes().
