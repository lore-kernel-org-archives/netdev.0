From: jamal <hadi@cyberus.ca>
Subject: Re: in-driver QoS
Date: 08 Jun 2004 23:46:49 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1086752809.1049.62.camel@jzny.localdomain>
References: <20040608184831.GA18462@bougret.hpl.hp.com>
	 <1086722317.1023.18.camel@jzny.localdomain>
	 <20040608195238.GA21089@bougret.hpl.hp.com>
	 <1086728139.1023.71.camel@jzny.localdomain>
	 <20040608220109.GA24536@bougret.hpl.hp.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20040608220109.GA24536@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-06-08 at 18:01, Jean Tourrilhes wrote:


> > According to Vladimir the wireless piece of it is different.
> > i.e each DMA ring will get different 802.11 channels 
> 
> Nope they can't get to different wireless channel, unless you
> have two radio modem in your hardware. If you have two radio hardware,
> then you might as well present two virtual devices.

Since Vladimir is not speaking up i am gonna take your word for it.

> The standard 802.11e (EDCF/HCF) is mostly a modification of
> the contention process on the medium, everything happens on the same
> wireless channel. Vladimir's use of "channel" is confusing, but I
> think he meant a virtual channel in the hardware, or something else.
>
> > with different backoff and contention window parameters. 
> 
> 	Yep. This impact the contention process.
> 	This is similar to what was implemented in 100VG / IEEE
> 802.12, but in more elaborated.

so the only differentiation is on backoff and contention window
parameters. In other words, higher prio will get opportunity to be more
of a hog or aggressive?

> > So nothing to do with the DMA process being a bottleneck.
> 
> 	You were the one worried about having multiple DMA rings.
> 
> > Help me understand this better:
> > theres a wired side and a wireless side or are both send and receive
> > interafacing to the air?
> 
> This is like old coax-Ethernet, but instead of having a common
> coax cable, you have a single wireless channel shared by all
> stations. For more details, please look in my Wireless Howto.
> Both send and receive are done on the same frequency. The
> other side of the hardware plug in the PCI bus.

I think i gotcha.


> > Yes, but how does the CSMA figure that? Is it not from the different
> > DMA rings?
> 
> Yes. So, what the drivers need to do in the xmit handler is to
> figure out what is the packet priority (probably using skb->priority
> or another mechanism) and put it in the appropriate queue/ring/FIFO.
> 

Sure this is the easy part. The hard part is below.

> > Is it a FIFO or there are several DMA rings involved? If the later:
> > when do you stop the netdevice (i.e call netif_stop_queue())? 
> 
> There is 4 FIFOs (or whichever number then want to configure)
> in parallel.
> Most likely, the FIFOs will share the same memory pool on the
> card, so when a FIFO is full, most likely the other FIFOs will be full
> or close to it.

How do you reach such a conclusion?
There maybe packets of the same priority for longs periods of time.

> In theory, they could dedicate card memory to each FIFO. But,
> in such case, if one FIFO is full and the other empty, it means that
> the card scheduler doesn't process packets according to the netdev
> scheduler. The netdev scheduler is the authoritative one, because
> directly controled by the policy and the intserv/diffserv
> software. Therefore you really want the card scheduler to start
> draining the full FIFO before we resume sending to the other FIFOs,
> otherwise the card scheduler will biased the policy netdev tries to
> enforce.

But then you loose sync with the qdisc level scheduling.
Assume a burst of low prio packets arrive, they get drained to the low
prio FIFO in the driver. It gets full and now we lock the driver.
Next a burst of high prio packets come in and they cantt be sent to the
driver until all low prio packets already on FIFO are sent.

> So, in any case, my suggestion would be to netif_stop_queue()
> as soon as one FIFO is full, and to netif_wake_queue() as soon as all
> FIFO have space. This is the most simple and predictable solution.

Simple, yes. Predictable or even accurate, no.
Take a very simple prio based scheduling. The rules are you only process
low priority packets if higher ones dont exist.
It also means that higher priority packets can starve the low prio ones
and that would be fine.

> But, we are talking there as if the hardware was going to have
> some incredibly smart scheduler across FIFOs. From my experience with
> wireless MAC implementations, the behaviour will be really simplistic
> (always send from the highest priority FIFO), if not totally
> broken. 

"Always send from highest priority" is fine. Its what the default linux
scheduler and the prio qdisc do. A lot of research and experienece has
gone into understanding their behaviors.
Perhaps you could tell users to configure such prioritization when using
these NICs.

> And you will probably have very little control over it in low
> end cards (hardwired ?).

Actually there are ethernet MACs today which have multiple DMA rings. so
the general problem is not just for wireless devices.

> This is why I would not trust MAC level scheduling (within a
> single host), and my concern is more to avoid the card scheduler to
> mess up netdev scheduling (which is a known quantity) rather than try
> to find way to take advantage of it.

We need to make chnages and do it properly. 
Your approach to use only one priority/FIFO is not sane. 
Of course the wireless people dont have to use it - Although that will
be a mistake. I have a NIC that has two DMA channels which i plan to map
to X priority levels at the the qdisc levels. 

> For performance reason, because of TCP behaviour, you really
> want to keep packets of a flow ordered. I agree that keeping ordering
> across flow in non realistic, because the point of QoS is to reorder
> packet across flows.

That can be handled at the TC level using policies.

cheers,
jamal
