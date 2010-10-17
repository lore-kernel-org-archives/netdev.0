From: Bill Fink <billfink@mindspring.com>
Subject: Re: tbf/htb qdisc limitations
Date: Sat, 16 Oct 2010 21:24:34 -0400
Message-ID: <20101016212434.72ae5250.billfink@mindspring.com>
References: <20101013233653.1e363692.billfink@mindspring.com>
	<20101014064404.GA6219@ff.dom.local>
	<20101014031354.e172d737.billfink@mindspring.com>
	<20101014080939.GA7710@ff.dom.local>
	<20101014085005.GA8349@ff.dom.local>
	<20101015023749.f085006b.billfink@mindspring.com>
	<1287125059.2659.1812.camel@edumazet-laptop>
	<20101015173746.12c7c40a.billfink@mindspring.com>
	<20101015220535.GA1997@del.dom.local>
	<20101016005106.35e4cc8d.billfink@mindspring.com>
	<20101016205824.GA2113@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	Steven Brudenell <steven.brudenell@gmail.com>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:46874 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757162Ab0JQBYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Oct 2010 21:24:38 -0400
In-Reply-To: <20101016205824.GA2113@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 16 Oct 2010, Jarek Poplawski wrote:

> On Sat, Oct 16, 2010 at 12:51:06AM -0400, Bill Fink wrote:
> > On Sat, 16 Oct 2010, Jarek Poplawski wrote:
> > 
> > > On Fri, Oct 15, 2010 at 05:37:46PM -0400, Bill Fink wrote:
> > > ...
> > > > i7test7% tc -s -d qdisc show dev eth2
> > > > qdisc prio 1: root refcnt 33 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
> > > >  Sent 11028687119 bytes 1223828 pkt (dropped 293, overlimits 0 requeues 0) 
> > > >  backlog 0b 0p requeues 0 
> > > > qdisc tbf 10: parent 1:1 rate 8900Mbit burst 1112500b/64 mpu 0b lat 4295.0s 
> > > >  Sent 11028687077 bytes 1223827 pkt (dropped 293, overlimits 593 requeues 0) 
> > > >  backlog 0b 0p requeues 0 
> > > > 
> > > > I'm not sure how you can have so many dropped but not have
> > > > any TCP retransmissions (or not show up as requeues).  But
> > > > there's probably something basic I just don't understand
> > > > about how all this stuff works.
> > > 
> > > Me either, but it seems higher "limit" might help with these drops.
> > 
> > You were of course correct about the higher limit helping.
> > I finally upgraded the field system to 2.6.35, and did some
> > testing on the real data path of interest, which has an RTT
> > of about 29 ms.  I set up a rate limit of 8 Gbps using the
> > following commands:
> > 
> > tc qdisc add dev eth2 root handle 1: prio
> > tc qdisc add dev eth2 parent 1:1 handle 10: tbf rate 8000mbit limit 35000000 burst 20000 mtu 9000
> > tc filter add dev eth2 protocol ip parent 1: prio 1 u32 match ip protocol 6 0xff match ip dst 192.168.1.23 flowid 10:1
> > 
> > hecn-i7sl1% nuttcp -T10 -i1 -w50m 192.168.1.23
> >   676.3750 MB /   1.00 sec = 5673.4646 Mbps     0 retrans
> >   948.5625 MB /   1.00 sec = 7957.1508 Mbps     0 retrans
> >   948.8125 MB /   1.00 sec = 7959.5902 Mbps     0 retrans
> >   948.3750 MB /   1.00 sec = 7955.5382 Mbps     0 retrans
> >   949.0000 MB /   1.00 sec = 7960.6696 Mbps     0 retrans
> >   948.7500 MB /   1.00 sec = 7958.7873 Mbps     0 retrans
> >   948.6875 MB /   1.00 sec = 7958.0959 Mbps     0 retrans
> >   948.6250 MB /   1.00 sec = 7957.4205 Mbps     0 retrans
> >   948.7500 MB /   1.00 sec = 7958.7237 Mbps     0 retrans
> >   948.4375 MB /   1.00 sec = 7956.3648 Mbps     0 retrans
> > 
> >  9270.5625 MB /  10.09 sec = 7707.7457 Mbps 24 %TX 36 %RX 0 retrans 29.38 msRTT
> > 
> > hecn-i7sl1% tc -s -d qdisc show dev eth2
> > qdisc prio 1: root refcnt 33 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
> >  Sent 9779476756 bytes 1084943 pkt (dropped 0, overlimits 0 requeues 0) 
> >  backlog 0b 0p requeues 0 
> > qdisc tbf 10: parent 1:1 rate 8000Mbit burst 19000b/64 mpu 0b lat 35.0ms 
> >  Sent 9779476756 bytes 1084943 pkt (dropped 0, overlimits 1831360 requeues 0) 
> >  backlog 0b 0p requeues 0 
> > 
> > No drops!
> > 
> > BTW the effective rate limit seems to be a very coarse adjustment
> > at these speeds.  I was seeing some data path issues at 8.9 Gbps
> > so I tried setting slightly lower rates such as 8.8 Gbps, 8.7 Gbps,
> > etc, but they still gave me an effective rate limit of about 8.9 Gbps.
> > It wasn't until I got down to a setting of 8 Gbps that I actually
> > got an effective rate limit of 8 Gbps.
> > 
> > Also the man page for tbf seems to be wrong/misleading about
> > the burst parameter.  It states:
> > 
> > 	"If your buffer is too small, packets may be dropped because more
> > 	tokens arrive per timer tick than fit in your bucket.  The minimum
> > 	buffer size can be calculated by dividing the rate by HZ.
> > 
> > According to that, with a rate of 8 Gbps and HZ=1000, the minimum
> > burst should be 1000000 bytes.  But my testing shows that a burst
> > of just 20000 works just fine.  That's only 2 9000-byte packets
> > or about 20 usec of traffic at the 8 Gbps rate.  Using too large
> > a value for burst can actually be harmful as it allows the traffic
> > to temporarily exceed the desired rate limit.
> 
> As I mentioned before, it could work, but your config is really on
> the edge. Anyway, if lower than minimum buffer size is needed
> something else is definitely wrong. (Btw, this size can matter less
> with high resolution timers.) You could try if my iproute patch:
> "tc_core: Use double in tc_core_time2tick()" (not merged) can help
> here. While googling for this patch I found this page, which might be
> interesting to you (besides the link to the thread with the patch at
> the end, take 1 or 2, shouldn't matter):
> 
> http://code.google.com/p/pspacer/wiki/HTBon10GbE
>  
> If it doesn't help reconsider hfsc.

Thanks for the link.  From his results, it appears you can
get better accuracy by keeping TSO/GSO enabled and upping
the tc mtu parameter to 64000.  I will have to try that out.

For the very high bandwidth cases I tend to deal with, would
there be any advantage to further reducing the PSCHED_SHIFT
from its current value of 6?

					-Bill
