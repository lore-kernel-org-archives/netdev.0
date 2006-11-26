From: dean gaudet <dean@arctic.org>
Subject: Re: gratuitous arp
Date: Sun, 26 Nov 2006 09:46:05 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0611260929130.8068@twinlark.arctic.org>
References: <Pine.LNX.4.64.0611251526040.8068@twinlark.arctic.org>
 <4568F663.7090805@superbug.co.uk> <Pine.LNX.4.64.0611251819310.8068@twinlark.arctic.org>
 <456991D9.7000503@superbug.co.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from twinlark.arctic.org ([207.7.145.18]:57039 "EHLO
	twinlark.arctic.org") by vger.kernel.org with ESMTP id S935459AbWKZRqG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Nov 2006 12:46:06 -0500
To: James Courtier-Dutton <James@superbug.co.uk>
In-Reply-To: <456991D9.7000503@superbug.co.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 26 Nov 2006, James Courtier-Dutton wrote:

> dean gaudet wrote:
> > On Sun, 26 Nov 2006, James Courtier-Dutton wrote:
> > 
> > > dean gaudet wrote:
> > > > hi...
> > > > 
> > > > i ran into some problems recently which would have been avoided if my
> > > > box
> > > > did a gratuitous arp as it brought up all interfaces (the router took
> > > > forever to timeout the ARP entries for interface aliases).  so i set
> > > > about
> > > > looking to see why that wasn't happening.
> > ...
> > > Are you 100% sure about this?
> > > Have you done a packet sniff on the network?
> > > A lot of routers ignore gratuitous arp for security reasons.
> > 
> > yeah i've done some packet sniffing to verify this.
> > 
> > here's what happened (twice now):  i upgraded a (normally busy) box, so the
> > MAC address changed.  the router is a cisco (not managed by me).
> > 
> > debian reboot sequence at some point brings up the primary eth0 address and
> > very soon thereafter there will be an arp "who-has $default_gw tell
> > $primary_addr".  that's sufficient to get the cisco to update its ARP cache
> > for $primary_addr.  this isn't gratuitous arp, but does the trick for the
> > $primary_addr.
> > 
> > but there's no gratuitous arp for any eth0:N aliased interfaces... and the
> > cisco ARP cache on this ISP router seems to be set to a long timeout.  i
> > could reach eth0:N from local net, but couldn't get outside local net from
> > eth0:N.
> > 
> > issuing "arping -I eth0 -s $secondary_addr $default_gw" for each secondary
> > address updated the cisco ARP cache and i could then reach eth0:N remotely.
> > 
> > so... that may not be exactly gratuitous arp, but basically i was stuck
> > until i forced the cisco to update its ARP cache for each of the secondary
> > addrs...
> > 
> > it seems to me it'd be nice for the init sequence to take care of this, so
> > that other folks don't have to spend time debugging similar problems.  i
> > just wanted to ask if i'm missing something obvious before i go open a
> > debian bug.  (i'm tempted to see if fedora does anything differently.)
> > 
> > thanks
> > -dean
> 
> Ok, I think it is better to just do gratuitous arp on the primary interface.
> If one starts doing it on secondary interfaces, one would then have to also do
> it for all proxy-arp addresses(if used), and thinks could start getting rather
> messy.

the "primary" address (the address which is used as the source address for 
all ARP packets) didn't need a gratuitous ARP because it sent a real ARP 
request to find the default gateway's MAC addr.

it was all the rest of the addresses which were screwed (which i'll call 
secondary just because they're not the ones which are used in ARP 
requests, and aren't the ones used as default addresses for IN_ADDR_ANY 
sockets).

but yeah, i can see an ARP storm nightmare if every address does it at the 
same time at boot... with the likely result of the cisco dropping some 
(especially because i'm sure ARP is on the slow path through the generally 
weak cpu in a cisco router).

ugh, this does seem a rather specialized problem, and manually fixing it 
with arping/garp/send_arp seems most appropriate.

i pondered a daemon which would use libpcap to observe traffic for a while 
and look at outbound packets which aren't seeing inbound responses and 
then try to help with a directed ARP... and would stop after a few 
minutes... but it's so special purpose it's just silly.  it's useful only 
for a machine upgrade in the presence of silly default 4h ARP cache 
timeouts or for IP failover without MAC failover and in the presence of 
boxes which ignore grat arp.

-dean
