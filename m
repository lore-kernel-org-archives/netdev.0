From: "Injong Rhee" <rhee@eos.ncsu.edu>
Subject: RE: [RFC] TCP burst control
Date: Wed, 7 Jul 2004 01:49:34 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407070549.i675nrPf008824@ms-smtp-01-eri0.southeast.rr.com>
References: <200407070546.i675kkPf008128@ms-smtp-01-eri0.southeast.rr.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <shemminger@osdl.org>, <netdev@oss.sgi.com>, <rhee@ncsu.edu>,
        <lxu2@ncsu.edu>, <mathis@psc.edu>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Injong Rhee'" <rhee@eos.ncsu.edu>,
        "'David S. Miller'" <davem@redhat.com>
In-Reply-To: <200407070546.i675kkPf008128@ms-smtp-01-eri0.southeast.rr.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Also some additional reports on this moderation problem can be found in
http://www.hep.ucl.ac.uk/~ytl/tcpip/linux/tcp_moderate_cwnd/


Injong Rhee, Associate Professor
North Carolina State University
Raleigh, NC 27699
rhee@eos.ncsu.edu, http://www.csc.ncsu.edu/faculty/rhee


-----Original Message-----
From: Injong Rhee [mailto:rhee@eos.ncsu.edu] 
Sent: Wednesday, July 07, 2004 1:46 AM
To: 'David S. Miller'
Cc: shemminger@osdl.org; netdev@oss.sgi.com; rhee@ncsu.edu; lxu2@ncsu.edu;
mathis@psc.edu
Subject: RE: [RFC] TCP burst control


Hi David,

Let me clarify the issue a little. In my earlier message, I might have
sounded like accusing rate halving of the burst problem and window
oscillation. I might have misrepresented it a little in the heat of writing
the email too fast :-). In fact, rate halving helps ease burst during fast
recovery as written in the Internet draft. 

The main problem lies in the variable that rate halving is closely
interacting with in TCP SACK implementation: packet_in_flight (or pipe_). In
the current implementation of Linux TCP SACK, cwnd is set to
packet_in_flight + C for every ack for CWR, recovery, and timeout-- Here C
is 1 to 3. But many times, packet_in_flight drops *far* below cwnd during
fast recovery. In high speed networks, a lot of packets can be lost in one
RTT (even acks as well because of slow CPUs). If that happens,
packet_in_flight becomes very small. At this time, Linux cwnd moderation (or
burst control) kicks in by setting cwnd to packet_in_flight + C so that the
sender does not burst all those packets between packet_in_flight and cwnd at
a single time. However, there is a problem with this approach. Since cwnd is
kept to very small, the transmission rate drops to almost zero during fast
recovery -- it should drop only to half of the current transmission rate (or
in high-speed protocols like BIC, it is only 87% of the current rate). Since
fast recovery lasts more than several RTTs, the network capacity is highly
underutilized during fast recovery. Furthermore, right after fast recovery,
cwnd goes into slow start since cwnd is typically far smaller than ssthrsh
after fast recovery. This also creates a lot of burst -- likely causing back
to back losses or even timeouts.

You can see this behavior in the following link:

http://www.csc.ncsu.edu/faculty/rhee/export/bitcp/tiny_release/experiments/B
IC-600-75-7500-1-0-0-noburst/index.htm

We run in a dummynet without any change in the burst control. You can see
that whenever there is fast recovery, the rate almost drop to zero. The pink
line is the throughput observed from the dummynet at every second, and red
one is from Iperf. In the second figure, you can see cwnd. It drops to the
bottom during fast recovery -- this is not part of congestion control. It is
the burst control of Linux SACK doing it. 

But with our new burst control:

http://www.csc.ncsu.edu/faculty/rhee/export/bitcp/tiny_release/experiments/B
IC-600-75-7500-1-0-0/index.htm

You can see that cwnd is quite stabilized and the throughput does not have
as much dip as in the original case.

Here is what we do: instead of reducing cwnd to packet_in_flight (which is,
in fact, meddling with congestion control), we reduce the gap between these
two numbers by allowing transmitting more packets per ack (we set this to
three more packets per ack) until packet_in_flight becomes close to cwnd.
Also right after fast recovery, we increase packet_in_flight by 1% of
packet_in_flight up to cwnd. This reduces the huge burst after fast
recovery. Our implementation is trying to leave cwnd only to congestion
control and separates burst control from congestion control. This makes the
behavior of congestion control more predictable.  We will report more on
this tomorrow when we get back to the Lab to test some other environments,
especially when we have smaller buffers. This scheme may not be the cure for
all and needs more testing. So far, it has been working very well.

Stay tuned.
Injong.
---
Injong Rhee, Associate Professor
North Carolina State University
Raleigh, NC 27699
rhee@eos.ncsu.edu, http://www.csc.ncsu.edu/faculty/rhee



-----Original Message-----
>From: David S. Miller [mailto:davem@redhat.com] 
Sent: Tuesday, July 06, 2004 8:29 PM
To: Injong Rhee
Cc: shemminger@osdl.org; netdev@oss.sgi.com; rhee@ncsu.edu; lxu2@ncsu.edu;
mathis@psc.edu
Subject: Re: [RFC] TCP burst control

On Tue, 6 Jul 2004 20:09:41 -0400
"Injong Rhee" <rhee@eos.ncsu.edu> wrote:

> Currently with rate having, current Linux tcp stack is full of hacks that
in
> fact, hurt the performance of linux tcp (sorry to say this).

If rate-halving is broken, have you taken this up with it's creator,
Mr. Mathis?  What was his response?

I've added him to the CC: list so this can be properly discussed.
