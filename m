From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: NAPI vs. interrupts
Date: Wed, 15 Jan 2003 00:06:26 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E01087ADC@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-8859-1"
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
content-class: urn:content-classes:message
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> NAPI driver _always_ does
> 	ack some irqs
> 	mask irqs
> 	ack some more irqs
> 	process events
> 	unmask irqs

e1000+NAPI is this path.

> The purpose of this email is to solicit suggestions to 
> develop a strategy to fix what I believe is a problem with NAPI.
> 
> Here are some comments of mine:
> 
> 1) Can this problem be alleviated entirely without driver 
> changes?  For example, would it be reasonable to do 
> pkts-per-second sampling in the net core, and enable software 
> mitigation based on that?
> 
> 2) Implement hardware mitigation in addition to NAPI.  Either 
> the driver does adaptive sampling, or simply hard-locks 
> mitigation settings at something that averages out to N pkts 
> per second.

I've tried something similar to this while playing around with e1000
recently.  Using ITR (InterruptThrottleRate), dial in a max intr/sec
rate of say 4000 intr/sec, and then just call netif_rx_schedule() for
each interrupt.  Don't mask/unmask interrupts.  If already polling,
netif_rx_schedule does nothing.  The code differences between the NAPI
path and non-NAPI path was minimal, so I liked that, and your worst case
is gone.  If you look at the average size of the Rx packets, you could
fine tune ITR to get a pkt/intr rate to balance your quota to try to
maximize the amount of time spent polling, but this is too fancy for my
taste.  Anyway, worst case, 2*4000 PIO writes/sec was the savings, but I
can't say I could measure a difference.
 
-scott
