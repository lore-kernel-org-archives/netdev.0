From: jamal <hadi@cyberus.ca>
Subject: Re: NAPI vs. interrupts
Date: Sat, 11 Jan 2003 22:41:32 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030111220310.Y9973@shell.cyberus.ca>
References: <20030111220826.GA10085@gtf.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "" <linux-net@vger.kernel.org>, "" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20030111220826.GA10085@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Sat, 11 Jan 2003, Jeff Garzik wrote:

> I am seeing some tg3 reports occasionally that show a fair number of
> interrupts-per-second, even though tg3 is 100% NAPI.
>

sample data?

> It seems to me that as machines get faster, and amount of memory
> increase [xlat: less waiting for free RAM in all parts of the kernel,
> and less GFP_ATOMIC alloc failures], the likelihood that a NAPI driver
> can process 100% of the RX and TX work without having to reqquest
> subsequent iterations of dev->poll().
>

This is very interesting - I havent come across such a CPU myself.
I am just about to unleash a P4 machine (> 2Ghz) so i may see this.

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
> whereas a non-NAPI driver _always_ does
> 	ack irqs
> 	process events
>

I think you may have added one more transaction on NAPI, but thats beside
the point.
Yes, this is what would happen in the worst case on NAPI.
When Manfred first posted his results i was one of the doubting people
as to the effect of these extra IOs. Recently i got my hands on a pentium
(lucky me!) and i was able to see up to 8% increase on CPU with NAPI
vs non-NAPI under conditions of what i would consider typically to
be low traffic input (anywhere between 5-8000 packets coming into the
system). To describe the problem better, anywhere where the CPU can
process the full rate (example the 5000 packets/sec arrivals on the
pentium above) the system becomes penalized by the extra IO. Note in
the above pentium system, the effect of IO became lower when i switched
to MMIO based PCI transactions. Of course when going got tough on the
pentium it died without NAPI.

> When there is load, the obvious NAPI benefits kick in.  However, on
> super-fast servers, SMP boxes, etc. it seems likely to me that one can
> receive well in excess of 1,000 interrupts per second, simply because
> the box is so fast it can run thousands of iterations of the NAPI "worst
> case", above.
>

True but you are better off with NAPI than without it in fast machines.
[I dont think youll notice much of CPU cycles disappearing on P3 for
example]
It's the slow machines that are a problem - and there you make the
sacrifice on small loads where you spend the unnecessary CPU but benefit
when you go under stress.
Lets take a worst case doomsday scenario:
Giges max rate: 1.4Mpps; take only 30% of that and you are
talking rx interupts at around 500K/sec. Say you have two giges NICs,
thats 1M receive interupts/sec. Is there a commodity type h/ware which
can handle this?
Robert and i have been discussing this very issue for our presentation at
nordu/usenix coming up and his arguement is: who gives a shit if you
loose some CPU cycles at low rates? He has a point, of course; I have been
experimenting with some things which will kick into NAPI at high rates
and maintain old scheme but what i can say at this point is that
they are experimental and that some of the benefits of NAPI disapear as
a result. For the scheme to work, all the NAPI benefits have to be
maintained and it has to be very unintrusive.

> The purpose of this email is to solicit suggestions to develop a
> strategy to fix what I believe is a problem with NAPI.
>
> Here are some comments of mine:
>
> 1) Can this problem be alleviated entirely without driver changes?  For
> example, would it be reasonable to do pkts-per-second sampling in the
> net core, and enable software mitigation based on that?
>
> 2) Implement hardware mitigation in addition to NAPI.  Either the driver
> does adaptive sampling, or simply hard-locks mitigation settings at
> something that averages out to N pkts per second.
>
> 3) Implement an alternate driver path that follows the classical,
> non-NAPI interrupt handling path in addition to NAPI, by logic similar
> to this[warning: off the cuff and not analyzed... i.e. just an idea]:
>
> 	ack irqs
> 	call dev->poll() from irq handler
> 			[processes events until budget runs out,
> 		 	 or available events are all processed]
> 	if budget ran out,
> 		mask irqs
> 		netif_rx_schedule()
>
> [this, #3, does not address the irq-per-sec problem directly, but does
> lessen the effect of "worst case"]
>
> Anyway, for tg3 specifically, I am leaning towards the latter part of #2,
> hard-locking mitigation settings at something tests prove is
> "reasonable", and in heavy load situations NAPI will kick in as
> expected, and perform its magic ;-)
>

Youll run into all sorts of problems with 1 and 3. Example in SMP.
I think 2 is the best path for now. If we can collect data that shows
this to be an issue we can accelerate getting a patch; i only work on it
when i am bored. For now i agree with Roberts philosophy - if we can get
the workaround for free while maintaining NAPI benefits, great. The
question is do we care about slow machines loosing some cycles?

cheers,
jamal
