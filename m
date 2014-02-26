From: Timo Teras <timo.teras@iki.fi>
Subject: Re: probe netlink app in NUD_PROBE
Date: Wed, 26 Feb 2014 08:28:14 +0200
Message-ID: <20140226082814.00289828@vostro>
References: <20140222104419.6b4daa44@vostro>
	<20140225.181844.1715731388552960836.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:58654 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750712AbaBZG1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 01:27:25 -0500
Received: by mail-la0-f45.google.com with SMTP id hr17so299832lab.18
        for <netdev@vger.kernel.org>; Tue, 25 Feb 2014 22:27:22 -0800 (PST)
In-Reply-To: <20140225.181844.1715731388552960836.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Feb 2014 18:18:44 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Timo Teras <timo.teras@iki.fi>
> Date: Sat, 22 Feb 2014 10:44:19 +0200
> 
> > When a stale or delayed neigh entry is being re-validated the entry
> > goes to NUD_PROBE state. At the moment only unicast probes are sent.
> > This is basically because neigh_max_probes() limits the probe
> > amount so.
> > 
> > Now, opennhrp intentionally configures UCAST_PROBES and
> > MCAST_PROBES to zero and APP_PROBES to something meaningful. The
> > idea is that opennhrp replaces arp completely with NHRP implemented
> > in userland.
> > 
> > Due to this it seems there is a very small time window, when the
> > NUD_PROBE times out and the neighbour entry gets invalidated, and
> > packets get lost.
> > 
> > To remedy this, I would like to have these NUD_PROBE validations
> > sent via netlink too.
> > 
> > First choice is to change to just use both unicast and application
> > probes:
> 
> So basically, the generic and protocol-specific neighbour code work
> together to implement a cascading priority based probing scheme using
> a per-neigh counter and three limits.
> 
> It seems that neigh->probes is zero when we enter the probing state.
> 
> On each solicit we increment neigh->probes.
> 
> Then we have this very funny logic in the protocol specific
> implementations of solicit:
> 
> 	probes = atomic_read(&neigh->probes);
> 
> 	probes -= UCAST_PROBES;
> 	if (probes < 0) {
> 		send unicast probe;
> 	} else {
> 		probes -= APP_PROBES;
> 		if (probes < 0) {
> 			trigger application based probe via netlink
> 		} else {
> 			send multicast probe;
> 		}
> 	}
> 
> As an example, for ipv4 arp, UCAST_PROBES defaults to 3 and APP_PROBES
> defaults (as you say) to zero.

Right, the idea is that on NUD_INVALID it does sequence of:
	UCAST_PROBES protocol specific unicasts
	APP_PROBE    netlink requeusts
	MCAST_PROBES protocol specific multicasts

And in NUD_PROBE currently only the unicast probes.

> If neigh_max_probes() evaluates to UCAST_PROBES, we'll do 3 unicast
> probes then fail the neigh, for example.
> 
> I took a look at iproute2's arpd, and I suggest you take a gander
> over there as well.
> 
> If given the '-a N' option it will set app_probes to N and send it's
> own ARP requests out in certain situations.
> 
> It might depend upon the current behavior of neigh_max_probes().

In fact, it seems that the arpd is expecting to get app probe in
NUD_PROBE. There's code like:
        if (ndm->ndm_state&NUD_PROBE) {
                 /* If we get this, kernel still has some valid
                  * address, but unicast probing failed and host
                  * is either dead or changed its mac address.
                  * Kernel is going to initiate broadcast resolution.
                  * OK, we invalidate our information as well.
                  */
                  if (dbdat.data && !IS_NEG(dbdat.data))
                         stats.app_neg++;

                  dbase->del(dbase, &dbkey, 0);

On the other hand opennhrp, needs the NUD_PROBE app queries to confirm
the existing entries, as opennhrp intentionally turns UCAST_PROBES to
zero.

So I'll submit the first variant soon, where app probes are added to be
done for NUD_PROBE.

- Timo
