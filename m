From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: in-driver QoS
Date: Tue, 8 Jun 2004 15:01:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040608220109.GA24536@bougret.hpl.hp.com>
References: <20040608184831.GA18462@bougret.hpl.hp.com> <1086722317.1023.18.camel@jzny.localdomain> <20040608195238.GA21089@bougret.hpl.hp.com> <1086728139.1023.71.camel@jzny.localdomain>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1086728139.1023.71.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jun 08, 2004 at 04:55:39PM -0400, jamal wrote:
> On Tue, 2004-06-08 at 15:52, Jean Tourrilhes wrote:
> > On Tue, Jun 08, 2004 at 03:18:37PM -0400, jamal wrote:
> > > Prioritization is a subset of QoS. So if 802.11e talks prioritization,
> > > thats precisely what it means - QoS.
> > 
> > 	Yes, it's one component of a QoS solution. But, my point is
> > that on it's own, it's not enough.
> 
> There is no mapping or exclusivity of QoS to bandwidth reservation.
> The most basic QoS and most popular QoS mechanisms even on Linux is 
> just prioritization and nothing to do with bandwidth allocation.

	The difference is that the Linux infrastructure can do it,
even if you don't do it, the 802.11e can't.
	Whatever, it does not matter.

> > 	I don't buy that. The multiple DMA ring is not the main thing
> > here, all DMA transfer share the same I/O bus to the card and share
> > the same memory pool, so there is no real performance gain there. The
> > I/O bnandwidth to the card is vastly superior to the medium bandwidth,
> > so the DMA process will never be a bottleneck.
> 
> According to Vladimir the wireless piece of it is different.
> i.e each DMA ring will get different 802.11 channels 

	Nope they can't get to different wireless channel, unless you
have two radio modem in your hardware. If you have two radio hardware,
then you might as well present two virtual devices.
	The standard 802.11e (EDCF/HCF) is mostly a modification of
the contention process on the medium, everything happens on the same
wireless channel. Vladimir's use of "channel" is confusing, but I
think he meant a virtual channel in the hardware, or something else.

> with different backoff and contention window parameters. 

	Yep. This impact the contention process.
	This is similar to what was implemented in 100VG / IEEE
802.12, but in more elaborated.

> So nothing to do with the DMA process being a bottleneck.

	You were the one worried about having multiple DMA rings.

> Help me understand this better:
> theres a wired side and a wireless side or are both send and receive
> interafacing to the air?

	This is like old coax-Ethernet, but instead of having a common
coax cable, you have a single wireless channel shared by all
stations. For more details, please look in my Wireless Howto.
	Both send and receive are done on the same frequency. The
other side of the hardware plug in the PCI bus.

> > The real benefit is that the contention on the medium is
> > prioritised (between contenting nodes). The contention process (CSMA,
> > backoff, and all the jazz) will give a preference to stations with
> > packet of the highest priority compared to stations wanting to send
> > packet of lower priorities. To gain advantage of that, you only need
> > to assign your packet the right priority at the driver level, and the
> > CSMA will send it appropriately.
> 
> Yes, but how does the CSMA figure that? Is it not from the different
> DMA rings?

	Yes. So, what the drivers need to do in the xmit handler is to
figure out what is the packet priority (probably using skb->priority
or another mechanism) and put it in the appropriate queue/ring/FIFO.

> Is it a FIFO or there are several DMA rings involved? If the later:
> when do you stop the netdevice (i.e call netif_stop_queue())? 

	There is 4 FIFOs (or whichever number then want to configure)
in parallel.
	Most likely, the FIFOs will share the same memory pool on the
card, so when a FIFO is full, most likely the other FIFOs will be full
or close to it.
	In theory, they could dedicate card memory to each FIFO. But,
in such case, if one FIFO is full and the other empty, it means that
the card scheduler doesn't process packets according to the netdev
scheduler. The netdev scheduler is the authoritative one, because
directly controled by the policy and the intserv/diffserv
software. Therefore you really want the card scheduler to start
draining the full FIFO before we resume sending to the other FIFOs,
otherwise the card scheduler will biased the policy netdev tries to
enforce.
	So, in any case, my suggestion would be to netif_stop_queue()
as soon as one FIFO is full, and to netif_wake_queue() as soon as all
FIFO have space. This is the most simple and predictable solution.

	But, we are talking there as if the hardware was going to have
some incredibly smart scheduler across FIFOs. From my experience with
wireless MAC implementations, the behaviour will be really simplistic
(always send from the highest priority FIFO), if not totally
broken. And you will probably have very little control over it in low
end cards (hardwired ?).
	This is why I would not trust MAC level scheduling (within a
single host), and my concern is more to avoid the card scheduler to
mess up netdev scheduling (which is a known quantity) rather than try
to find way to take advantage of it.

> > 	So, I would not worry about the DMA rings. I may worry a
> > little bit about packet reordering between queues, but I don't think
> > it's a problem. And about the new contention behaviour, this is only
> > between different stations, not within a node, so it won't impact you.
> 
> Anyone putting different packets from same flow cant guarantee ordering.

	For performance reason, because of TCP behaviour, you really
want to keep packets of a flow ordered. I agree that keeping ordering
across flow in non realistic, because the point of QoS is to reorder
packet across flows.

> cheers,
> jamal

	Have fun...

	Jean
