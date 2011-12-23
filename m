From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: SFQ on HFSC leaf does not seem to work
Date: Fri, 23 Dec 2011 01:40:50 -0500
Message-ID: <1324622450.10184.142.camel@denise.theartistscloset.com>
References: <1324620022.10184.100.camel@denise.theartistscloset.com>
	 <CAA93jw5FZ=Sz0afmnwwZ-COmSi=HfcXDJfokQgn3_nHEquTb5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:62964 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752320Ab1LWGk4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Dec 2011 01:40:56 -0500
In-Reply-To: <CAA93jw5FZ=Sz0afmnwwZ-COmSi=HfcXDJfokQgn3_nHEquTb5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-12-23 at 07:32 +0100, Dave Taht wrote:
> On Fri, Dec 23, 2011 at 7:00 AM, John A. Sullivan III
> <jsullivan@opensourcedevel.com> wrote:
> > Hello, all.  I have an experimental HFSC setup with three leaf classes
> > each with SFQ as the final qdisc.  One queue is for ssh on port 822, one
> > is for tcp traffic on port 443, the third is the default.
> >
> > If I flood the 443 queue with netcat, my ssh sessions are responsive and
> > my continuous ping shows a round trip time of around 50ms in keeping
> > with my netem settings.
> >
> > However, if I flood the default queue with netcat on port 80, ssh is
> > still responsive but my ping round trip times shoot up over 3000ms.
> >
> > I thought it might be the bufferbloat phenomenon so I reduced the
> > txqueuelen on both sides of the ping to 0.  Both sides use old 10BaseT
> > NICs and have no ring buffer.  I also set the SFQ limit on the default
> > queue to 2 just in case.  Still no difference.
> 
> Your txqueuelen on the ifb devices is probably 1000.
Alas, not.  They defaulted to 32 and I reset them to 0 :(

I'll also paste in a slightly optimized rule set but it still made no
difference.
> 
> 
> 
> >
> > The default queue is dequeuing at roughly 400 kbits which matches my
> > HFSC configuration.  A full sized packet should take 30 ms to pass at
> > that rate ((1514 * 8)/400,000) so, if I am round robining the queues, I
> > would expect latency on a default sized ping to be only 30 ms plus the
> > netem delay.
> >
> > Where might this 3000 ms delay be coming from?
> >
> > Here is the rule set:
> >
> #!/bin/sh

tc qdisc add dev eth1 root handle 1: hfsc default 20
tc class add dev eth1 parent 1: classid 1:1 hfsc sc rate 1490kbit ul rate 1490kbit
tc class add dev eth1 parent 1:1 classid 1:20 hfsc rt rate 400kbit ls rate 200kbit
tc qdisc add dev eth1 parent 1:20 handle 1201 sfq perturb 10
tc class add dev eth1 parent 1:1 classid 1:10 hfsc rt umax 16kbit dmax 50ms rate 200kbit ls rate 1000kbit
tc qdisc add dev eth1 parent 1:10 handle 1101 sfq perturb 60
tc class add dev eth1 parent 1:1 classid 1:30 hfsc rt umax 1514b dmax 20ms rate 20kbit
tc qdisc add dev eth1 parent 1:30 handle 1301 sfq perturb 60
iptables -t mangle -A POSTROUTING -p 6 --syn --dport 443 -j CONNMARK --set-mark 0x10
iptables -t mangle -A PREROUTING -p 6 --syn --dport 822 -j CONNMARK --set-mark 0x11
iptables -t mangle -A POSTROUTING -o eth1 -p 6 -j CONNMARK --restore-mark
modprobe ifb
ifconfig ifb0 up
ifconfig ifb1 up
tc qdisc add dev ifb0 root handle 1: hfsc default 20
tc class add dev ifb0 parent 1: classid 1:1 hfsc sc rate 1490kbit ul rate 1490kbit
tc class add dev ifb0 parent 1:1 classid 1:20 hfsc rt rate 400kbit ls rate 200kbit
tc qdisc add dev ifb0 parent 1:20 handle 1201 netem delay 25ms 5ms distribution normal loss 0.1% 30%
tc class add dev ifb0 parent 1:1 classid 1:10 hfsc rt umax 16kbit dmax 50ms rate 200kbit ls rate 1000kbit
tc qdisc add dev ifb0 parent 1:10 handle 1101 netem delay 25ms 5ms distribution normal loss 0.1% 30%
tc class add dev ifb0 parent 1:1 classid 1:30 hfsc rt umax 1514b dmax 20ms rate 20kbit
tc qdisc add dev ifb0 parent 1:30 handle 1301 netem delay 25ms 5ms distribution normal loss 0.1% 30%
tc filter add dev ifb0 parent 1:0 protocol ip prio 1 handle 6: u32 divisor 1
tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 match ip protocol 6 0xff link 6: offset at 0 mask 0x0f00 shift 6 plus 0 eat
tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 ht 6:0 match tcp src 443 0x00ff flowid 1:10
tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 ht 6:0 match tcp dst 822 0xff00 flowid 1:30
tc qdisc add dev ifb1 root handle 2 netem delay 25ms 5ms distribution normal loss 0.1% 30%
tc qdisc add dev eth1 ingress
tc filter add dev eth1 parent ffff: protocol ip prio 50 u32 match u32 0 0 action mirred egress redirect dev ifb0
tc filter add dev eth1 parent 1:1 protocol ip prio 1 handle 0x11 fw flowid 1:30
tc filter add dev eth1 parent 1:1 protocol ip prio 1 handle 0x10 fw flowid 1:10
tc filter add dev eth1 parent 1:1 protocol ip prio 2 u32 match u32 0 0 flowid 1:20
tc filter add dev eth1 parent 1:0 protocol ip prio 1 u32 match u32 0 0 flowid 1:1 action mirred egress redirect dev ifb1

> >
> > Thanks - John
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> 
