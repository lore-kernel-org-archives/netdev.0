From: Jeff Garzik <jgarzik@pobox.com>
Subject: NAPI vs. interrupts
Date: Sat, 11 Jan 2003 17:08:26 -0500
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030111220826.GA10085@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

I am seeing some tg3 reports occasionally that show a fair number of
interrupts-per-second, even though tg3 is 100% NAPI.

It seems to me that as machines get faster, and amount of memory
increase [xlat: less waiting for free RAM in all parts of the kernel,
and less GFP_ATOMIC alloc failures], the likelihood that a NAPI driver
can process 100% of the RX and TX work without having to reqquest
subsequent iterations of dev->poll().

NAPI's benefits kick in when there is some amount of system load.
However if the box is fast enough to eliminate cases where system load
would otherwise exist (interrupt and packet processing overhead), the
NAPI "worst case" kicks in, where a NAPI driver _always_ does
	ack some irqs
	mask irqs
	ack some more irqs
	process events
	unmask irqs

whereas a non-NAPI driver _always_ does
	ack irqs
	process events

When there is load, the obvious NAPI benefits kick in.  However, on
super-fast servers, SMP boxes, etc. it seems likely to me that one can
receive well in excess of 1,000 interrupts per second, simply because
the box is so fast it can run thousands of iterations of the NAPI "worst
case", above.

The purpose of this email is to solicit suggestions to develop a
strategy to fix what I believe is a problem with NAPI.

Here are some comments of mine:

1) Can this problem be alleviated entirely without driver changes?  For
example, would it be reasonable to do pkts-per-second sampling in the
net core, and enable software mitigation based on that?

2) Implement hardware mitigation in addition to NAPI.  Either the driver
does adaptive sampling, or simply hard-locks mitigation settings at
something that averages out to N pkts per second.

3) Implement an alternate driver path that follows the classical,
non-NAPI interrupt handling path in addition to NAPI, by logic similar
to this[warning: off the cuff and not analyzed... i.e. just an idea]:

	ack irqs
	call dev->poll() from irq handler
			[processes events until budget runs out,
		 	 or available events are all processed]
	if budget ran out,
		mask irqs
		netif_rx_schedule()
	
[this, #3, does not address the irq-per-sec problem directly, but does
lessen the effect of "worst case"]

Anyway, for tg3 specifically, I am leaning towards the latter part of #2,
hard-locking mitigation settings at something tests prove is
"reasonable", and in heavy load situations NAPI will kick in as
expected, and perform its magic ;-)

Comments/feedback requested.

	Jeff




