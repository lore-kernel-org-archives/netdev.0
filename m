From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: [Q] How to invalidate ARP cache for a network device from
 within kernel
Date: Sat, 27 Nov 2010 16:33:15 +0200
Message-ID: <1290868395.5305.14.camel@maxim-laptop>
References: <1290793099.3716.21.camel@maxim-laptop>
	 <20101127021833.328e8942@stein> <1290821143.4145.3.camel@maxim-laptop>
	 <20101127151315.631dc1dd@stein>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux1394-devel <linux1394-devel@lists.sourceforge.net>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:36445 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752384Ab0K0OdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Nov 2010 09:33:22 -0500
Received: by bwz15 with SMTP id 15so2608910bwz.19
        for <netdev@vger.kernel.org>; Sat, 27 Nov 2010 06:33:20 -0800 (PST)
In-Reply-To: <20101127151315.631dc1dd@stein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-11-27 at 15:13 +0100, Stefan Richter wrote:
> On Nov 27 Maxim Levitsky wrote:
> > > > However as soon as bus reset happens, the upper layer ARP cache
> > > > isn't invalidated, thus all attempts to send packets to remote
> > > > node now fail, because the additional information (node id and
> > > > bus address) about remote node is now invalid, but ARP core
> > > > doesn't send ARP requests because it has the response in the
> > > > cache.  
> > > 
> > > When is this a problem?  With nodes which stay on the bus (i.e. are
> > > present before and after the bus reset)?  Or with nodes which go
> > > away and come back much later (but before the old ARP cache entry
> > > was cleaned out)?  
> > Its about later.
> > A node that disconnects and connects after 5 seconds for example or 20
> > seconds.
> > ARP timeout is I think 30 seconds or even more.
> > 
> > Btw I already solved that problem.
> > Patches attached.
> [...]
> > Subject: [PATCH 2/3] NET: ARP: allow to invalidate specific ARP entries
> > 
> > IPv4 over firewire needs to be able to remove ARP entries
> > from cache that belong to nodes that are removed, because
> > IPv4 over firewire uses ARP packets for private information
> > about nodes.
> > 
> > This information becames invalid on node removal, thus
> > as soon as it is connected again, ARP packet should be sent
> > to it which is not done due to valid cache entry.
> > 
> > CC: netdev@vger.kernel.org
> > Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
> > ---
> >  include/net/arp.h |    1 +
> >  net/ipv4/arp.c    |   29 ++++++++++++++++++-----------
> >  2 files changed, 19 insertions(+), 11 deletions(-)
> 
> [...]
> 
> > Subject: [PATCH 3/3] firewire: net: invalidate ARP entries for
> > removed nodes.
> > 
> > This allows to be able to connect to nodes that disappered
> > from the bus and after some time appeared again.
> > 
> > Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
> > ---
> >  drivers/firewire/net.c |    7 +++++++
> >  1 files changed, 7 insertions(+), 0 deletions(-)
> 
> I wonder if this is the right approach.
> 
> Suppose somebody implements IPv6 over 1394 (RFC 3146) which uses
> Neighbour Discovery (RFC 2461).  What are we going to do then to solve
> the very same problem?
Well, thats a problem, but firewire is somewhat unique.
I don't image any other networking transport to be protocol dependent.

> 
> (Is it a problem at all?  There is just an annoying period of 30
> seconds or so during which packets are dropped.  And that period
> starts when the cable was pulled or the remote node PM-suspended or a
> hub powered down or the likes.)
It is somewhat a problem, if you for example suspend a system by mistake
and on resume you need to wait too much.
It is annoying.


> 
> Anyhow.  I suspect eth1394's/ firewire-net's neighbour (fwnet_peer)
> management is lacking.  Consider this example session between
> Linux/firewire-net and OS X.
> 
> 1.) Plug them together, ifup on Linux.  On the Linux node, the local
> node is fw5 and the remote OS X node is fw9.
> 
> 2.) On OS X, don't start any user action on the FireWire networking
> interface.  On Linux, start pinging the remote node.  Ping gets replies.
> 
> 3.) Unplug the cable.  Ping's requests are being dropped from now on.
> There is a bit of log spam until firewire-core releases the fw9
> fw_device instance, which includes that firewire-net removes the
> corresponding fwnet_peer instance:
> Nov 27 12:17:15 stein kernel: firewire_net: fwnet_write_complete: failed: 13
> Nov 27 12:17:16 stein kernel: firewire_net: fwnet_write_complete: failed: 13
> 
> 4.) Plug the cable back in a few seconds later.  Resulting dmesg:
> Nov 27 12:17:19 stein kernel: firewire_core: skipped bus generations, destroying all nodes
> Nov 27 12:17:20 stein kernel: firewire_net: No peer for ARP packet from 0017f2fffe66fb80
> Nov 27 12:17:20 stein kernel: firewire_net: No peer for ARP packet from 0017f2fffe66fb80
> Nov 27 12:17:20 stein kernel: firewire_core: rediscovered device fw5
> Nov 27 12:17:20 stein kernel: firewire_core: phy config: card 2, new root=ffc1, gap_count=5
> Nov 27 12:17:20 stein kernel: firewire_net: No peer for ARP packet from 0017f2fffe66fb80
> Nov 27 12:17:20 stein kernel: firewire_net: No peer for ARP packet from 0017f2fffe66fb80
> Nov 27 12:17:20 stein kernel: firewire_net: No peer for ARP packet from 0017f2fffe66fb80
> Nov 27 12:17:21 stein kernel: firewire_net: No peer for ARP packet from 0017f2fffe66fb80
> Nov 27 12:17:21 stein kernel: firewire_net: No peer for ARP packet from
> 0017f2fffe66fb80 Nov 27 12:17:21 stein kernel: firewire_net: No peer
> for ARP packet from 0017f2fffe66fb80 Nov 27 12:17:22 stein kernel:
> firewire_net: No peer for ARP packet from 0017f2fffe66fb80 Nov 27
> 12:17:23 stein kernel: firewire_core: created device fw9: GUID
> 0017f2fffe66fb80, S400, 1 config ROM retries
> 
> 5.) At this point, ping's requests are still being dropped.
> 
> 6.) A whole while later, ping is back in business again, obviously
> because the old ARP entry was cleared and a new ARP request--response
> was performed.
> 
> We learn two things from that:
> 
>   - OS X sends gratuitous ARP messages.  Maybe that's Zeroconf (RFC
>     3927), or maybe that's just part of their RFC 2734 driver.
>     There seem to be consistently nine of such messages sent within a
>     period of 3 or 4 seconds, starting almost immediately after
>     self-ID-complete after cable replug.
> 
>   - fwnet_probe, which adds the fwnet_peer instance that pertains to
>     fw9, is performed just a little bit too late to match one of those
>     ARP packets with an fwnet_peer instance.
Which means that even if we teach firewire-net to send ARP requests,
these won't be handled by other side that runs firewire-net too.
Of course 

> 
> Should firewire-net send gratuitous ARP messages too?  I.e., in
> fwnet_probe, if the interface is up, send an ARP Request packet which
> solicits a response.  Likewise, if/when IPv6-over-1394 is implemented,
> let fwnet_probe send a Neighbour Solicitation packet.  ---  In effect,
> this means that we would not add EXPORT_SYMBOL(arp_invalidate) and,
> perspectively, EXPORT_SYMBOL(ndisc_invalidate), and call those when a
> node went away.  Instead, we solicit an ARP Response or a Neighbor
> Advertisement when a node joined us and let that response or
> advertisement update the ARP cache or NDP cache.
I am not against that at all.
Clearning the cache seemed just to be very robust and solve a root case.
This is less robust solution (which you even proved because OSX does
it...)


> 
> The question is, is the link-layer driver firewire-net a proper place
> to call arp_send() and ndisc_send_ns()?
> 
> And is this any better than a new arp_invalidate() and
> ndisc_invalidate()?
That what I am not sure at all.
I can bypass arp_send, and just create a 1394 ARP packet and send it
using fw_request.
But doing that as I did seemed to be also quite simple.
It is protocol depedent but that is firewire  fault not mine.

> 
> ----
> 
> On a loosely related note, after looking at 1394 AR and at NDP,
> shouldn't we rather set
> 	net_device.addr_len = 16
> and
> 	net_device.dev_addr = concatenation of EUI-64, max_rec, spd,
> 	                      and unicast_FIFO
> ?
The problem is that except GUID, the rest can change.
And hardware addresses should be fixed.


Best regards,
	Maxim Levitsky

