From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: NAPI vs. interrupts
Date: Mon, 13 Jan 2003 16:57:12 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15906.57816.361093.607705@robur.slu.se>
References: <20030111220826.GA10085@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20030111220826.GA10085@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeff Garzik writes:
 
 > It seems to me that as machines get faster, and amount of memory
 > increase [xlat: less waiting for free RAM in all parts of the kernel,
 > and less GFP_ATOMIC alloc failures], the likelihood that a NAPI driver
 > can process 100% of the RX and TX work without having to reqquest
 > subsequent iterations of dev->poll().

 True.

 > NAPI's benefits kick in when there is some amount of system load.
 > However if the box is fast enough to eliminate cases where system load
 > would otherwise exist (interrupt and packet processing overhead), the
 > NAPI "worst case" kicks in, where a NAPI driver _always_ does
 > 	ack some irqs
 > 	mask irqs
 > 	ack some more irqs
 > 	process events
 > 	unmask irqs
 > 

Another "worst case" :-)

NAPI subsequent iterations of dev->poll at softirq
 
whereas a non-NAPI driver **always**  does IRQ
 	ack irqs
 	process events


So for this we pay the "insurance fee" of acking and disabling irq's
to get dev->poll running. The acking we need non-NAPI as well to see 
if this irq is for us. And if case NAPI the ack at irq is passed to 
dev->poll. (Davem patch to e1000). So more or we less we have the cost 
of one PCI write + PCI sync if MMIO to disable irq's to enable processing 
at softirq. And another PCI-write to enable irq's.

NAPI relays on the fact interrupts is the best way to indicate work 
and keep latency at an absolute minimum sparse traffic-levels and 
polling is unbeatable at high loads.

And the packet processing at softirq gives good system behavior system 
manageable and even some hooks to control the balance between irq/softirq 
and user mode apps. 

 > 1) Can this problem be alleviated entirely without driver changes?  For
 > example, would it be reasonable to do pkts-per-second sampling in the
 > net core, and enable software mitigation based on that?

We played with this some time ago... First I think we should say we need
something from the particular device we are dealing with any general 
measures we risk doing really bad things... i.e adding latencies to 
wrong devices etc.

We tried different forms of averages and EWMA (exponented weighted 
moving average) but nothing was fast enough to "follow" the burstiness
of a device receiving packets.
 
The only usable measure we found was the number of RX packets on the
ring. This also has the "advantage" of being adjusted by the CPU
load. You have it tulip.

 > 2) Implement hardware mitigation in addition to NAPI.  Either the driver
 > does adaptive sampling, or simply hard-locks mitigation settings at
 > something that averages out to N pkts per second.

 Yes should be doable...

 But real question do we need it? I'm asking this question myself I was
 mentally disturbed the interrupts myself and I added mitigation to tulip.
 And even some other hacks in tulip delaying the exit to "done".

 Still I'm not sure... 

 > 3) Implement an alternate driver path that follows the classical,
 > non-NAPI interrupt handling path in addition to NAPI, by logic similar
 > to this[warning: off the cuff and not analyzed... i.e. just an idea]:
 > 
 > 	ack irqs
 > 	call dev->poll() from irq handler
 > 			[processes events until budget runs out,
 > 		 	 or available events are all processed]
 
 Well you need some more steps. The central backlog is needed again and you
 need to schedule the RX softirq to process the backlog's packets. 

 > 	if budget ran out,
 > 		mask irqs
 > 		netif_rx_schedule()
 > 	
 > [this, #3, does not address the irq-per-sec problem directly, but does
 > lessen the effect of "worst case"]

 No "top" performance would probably be somewhat be less due to irq's.

 > Anyway, for tg3 specifically, I am leaning towards the latter part of #2,
 > hard-locking mitigation settings at something tests prove is
 > "reasonable", and in heavy load situations NAPI will kick in as
 > expected, and perform its magic ;-)

 I've planned a test with the recent tg3 stuff for some time...

 
 Cheers.
						--ro
 
