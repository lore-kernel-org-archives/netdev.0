From: Jason Lunz <lunz@falooley.org>
Subject: Re: Luca Deri's paper: Improving Passive Packet Capture: Beyond Device Polling
Date: Tue, 6 Apr 2004 16:01:20 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <c4uk8g$38l$1@sea.gmane.org>
References: <20040330142354.GA17671@outblaze.com> <1081033332.2037.61.camel@jzny.localdomain> <c4rvvv$dbf$1@sea.gmane.org> <407286BB.8080107@draigBrady.com> <4072A1CD.8070905@ntop.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

deri@ntop.org said:
> In addition if you do care about performance, I believe you're willing
> to turn off packet transmission and only do packet receive. 

I don't understand what you mean by this. packet-mmap works perfectly
well on an UP|PROMISC interface with no addresses bound to it. As long
as no packets are injected through a packet socket, the tx path never
gets involved.

> IRQ: Linux has far too much latency, in particular at high speeds. I'm
> not the right person who can say "this is the way to go", however I
> believe that we need some sort of interrupt prioritization like RTIRQ
> does.

I don't think this is the problem, since small-packet performance is bad
even with a fully-polling e1000 in NAPI mode. As Robert Olsson has
demonstrated, a highly-loaded napi e1000 only generates a few hundred
interrupts per second. So the vast majority of packets recieved are
coming in without a hardware interrupt occurring at all.

Could it be that each time an hw irq _is_ generated, it causes many
packets to be lost? That's a possibility. Can you explain in more detail
how you measured the effect of interrupt latency on recieve efficiency?

> Finally It would be nice to have in the standard Linux core some
> packet capture improvements. It could either be based on my work or on
> somebody else's work. It doesn't really matter as long as Linux gets
> faster.

I agree. I think a good place to start would be reading and
understanding this thread:

http://thread.gmane.org/gmane.linux.kernel/193758

There's some disagreement for a while about where all this softirq load
is coming from. It looks like an interaction of softirqs and RCU, but
the first patch doesn't help.  Finally Olsson pointed out:

http://article.gmane.org/gmane.linux.kernel/194412

that the majority of softirq's are being run from hardirq exit. Even
with NAPI. At this point, I think, it's clear that the problem exists
regardless of rcu, and indeed, Linux is bad at doing packet-mmap RX of a
small-packet gigabit flood on both 2.4 and 2.6 (my old 2.4 measurements
earlier in this thread show this).

I'm particularly interested in trying Andrea's suggestion from
http://article.gmane.org/gmane.linux.kernel/194486 , but I won't have
the time anytime soon.

Jason
