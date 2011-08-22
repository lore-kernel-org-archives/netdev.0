From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 0/2] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods (v3)
Date: Mon, 22 Aug 2011 14:14:20 -0400
Message-ID: <20110822181420.GD12337@hmsreliant.think-freely.org>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
 <1311696338-4739-1-git-send-email-nhorman@tuxdriver.com>
 <1313593637.2776.9.camel@bwh-desktop>
 <20110822002641.GA2550@neilslaptop.think-freely.org>
 <1314029857.2803.6.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35113 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376Ab1HVSO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 14:14:27 -0400
Content-Disposition: inline
In-Reply-To: <1314029857.2803.6.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 22, 2011 at 05:17:37PM +0100, Ben Hutchings wrote:
> On Sun, 2011-08-21 at 20:27 -0400, Neil Horman wrote:
> > On Wed, Aug 17, 2011 at 04:07:17PM +0100, Ben Hutchings wrote:
> > > On Tue, 2011-07-26 at 12:05 -0400, Neil Horman wrote:
> > > > Ok, after considering all your comments, Dave suggested this as an alternate
> > > > approach:
> > > > 
> > > > 1) We create a new priv_flag, IFF_SKB_TX_SHARED, to identify drivers capable of
> > > > handling shared skbs.  Default is to not set this flag
> > > > 
> > > > 2) Modify ether_setup to enable this flag, under the assumption that any driver
> > > > calling this  function is initalizing a real ethernet device and as such can
> > > > handle shared skbs since they don't tend to store state in the skb struct.
> > > > Pktgen can then query this flag when a user script attempts to issue the
> > > > clone_skb command and decide if it is to be alowed or not.
> > > [...]
> > > 
> > > A bunch of Ethernet drivers do skb_pad() or skb_padto() in their
> > > ndo_start_xmit implementations, either to avoid hardware bugs or because
> > > the MAC doesn't automatically pad to the minimum frame length.  This
> > > presumably means they can't generally handle shared skbs, though in the
> > > specific case of pktgen it should be safe as long as a single skb is not
> > > submitted by multiple threads at once.
> > > 
> > Agreed, given that pktgen is doing skb sharing in a serialized manner (i.e. one
> > thread of execution increasing skb->users rather than in multiple threads), the
> > skb_pad[to] cases are safe.  Are there cases in which shared skbs are
> > transmitted in parallel threads that we need to check for?
> 
> Not that I'm aware of.  However, you have defined the flag to mean 'safe
> to send shared skbs', and this is not generally true for those drivers.
> 
> So please decide whether:
> a. The flag means 'safe to send shared skbs' (i.e. the TX path does not
> modify the skb) and drivers which pad must clear it on their devices.
> b. The flag means 'safe to send shared skbs in the way ptkgen does', and
> the restrictions this places on the user and driver should be specified.
> 

The flag means safe to send shared skbs.

Actually looking closer at this, I don't think this is much of a problem at all.
The flag is cleared on devices for which it is unsafe to send shared skbs, not
because there are multiple users of the skb in parallel, but because the driver
expects to have continued exclusive access to the skb after the drivers
ndo_start_xmit method returns.

In the pktgen case, skbs have skb->users > 1, but all users exist in the same
execution context, making their transmission serialized.

In the additional cases you are concerned with, multiple users of an skb may or
may not run in parallel.  In the parallel case however, to avoid additional
races, one of the following must be true:

1) All n contexts treat the skb as immutible and wind up sending to the same
device and queue, at which point the xmit_lock in the net_device serializes
their operation.

2) Each of the n contexts (or a subset thereof) will modify the skb data, which
requires that they do their own locking between each other, which must encompass
the transmission of the skb in each context (lest they corrupt the skb during
transmission).  Such locking again serializes the transmit peth.

In either case, access to the skb is serialized such that it is only ever
handled by one driver at one time, and during that window drivers may opt to
modify the state of the skb, as long as they dont' expect the sate to remain in
their control after the return from ndo_start_xmit.


So even though drivers that call skb_pad[to] modify the skb, its perfectly ok to
do so, as long as they don't assume that the struct skb will remain in that
state after the driver is done with it.

This works out perfectly well for skb_padto calls, since the function reduces to
a no-op after the minimal tail size has been reached.

Its a bit more problematic for skb_pad, since the possibility exists for
successive calls to skb_pad to iteratively increase the pad until the skb
tailroom is exhausted, causing a transmission error.  That said however, there
are only 6 drivers that use skb_pad (sfx, niu, rt2800, rt61pci, rt37usb, and
claw), and they all only pad if the skb is not already a minimum length.  These
calls should probably be audited and converted to skb_padto anyway.

So, in my view, these aren't really problems.  If someone just does a blind skb
pad in the driver, then we have something of a problem, but one that is easily
fixed if and when the problem should arise.
Neil

