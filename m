From: Weiguang Shi <wgshi2002@yahoo.ca>
Subject: RE: [RFC] TCP burst control
Date: Wed, 14 Jul 2004 20:11:52 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040715001152.26115.qmail@web54105.mail.yahoo.com>
References: <200407070546.i675kkPf008128@ms-smtp-01-eri0.southeast.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev linux <netdev@oss.sgi.com>, Qiang Ye <qye@cs.ualberta.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Injong Rhee <rhee@eos.ncsu.edu>
In-Reply-To: <200407070546.i675kkPf008128@ms-smtp-01-eri0.southeast.rr.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

My question is: Why in_flight drops *far* below cwnd in 
the first place?

The assumption is that each time an ack comes, TCP SHOULD 
decrease in_flight by the number of new segments that the ack 
acknowledges. 

During fast recovery, each packet after the lost is acked 
immediately (in the form of a duplicate ack) by the 
receiver since it is out of order. Each dupack should 
bring the latest SACK info, i.e., one more packet received. 
Therefore a packet cannot trigger a dupack acknowledging
more than one new segment, not even in the multiple-packet-drop 
scenario.

That is, sacked_out++ upon each ack during fast recovery;
lost_out=0 according to the conservative SACK; and before
the first (partial) ack that advances snd.una, retrans_out=1. 
Therefore, 

      in_flight = packets_out - sacked_out + 1

This seems to indicate that with SACK, in_flight should 
gradually decrease instead of dropping suddenly during 
fast recovery.

On the other hand, I've seen sudden-drops in my experiments. What 
happened?

Regards,
Wei

--- Injong Rhee <rhee@eos.ncsu.edu> wrote: > 
> Hi David,
> 
> ...
>
> The main problem lies in the variable that rate halving is closely
> interacting with in TCP SACK implementation: packet_in_flight (or pipe_). In
> the current implementation of Linux TCP SACK, cwnd is set to
> packet_in_flight + C for every ack for CWR, recovery, and timeout-- Here C
> is 1 to 3. But many times, packet_in_flight drops *far* below cwnd during
> fast recovery. In high speed networks, a lot of packets can be lost in one
> RTT (even acks as well because of slow CPUs). If that happens,
> packet_in_flight becomes very small. At this time, Linux cwnd moderation (or
> burst control) kicks in by setting cwnd to packet_in_flight + C so that the
> sender does not burst all those packets between packet_in_flight and cwnd at
> a single time. However, there is a problem with this approach. Since cwnd is
> kept to very small, the transmission rate drops to almost zero during fast
> recovery -- it should drop only to half of the current transmission rate (or
> in high-speed protocols like BIC, it is only 87% of the current rate). Since
> fast recovery lasts more than several RTTs, the network capacity is highly
> underutilized during fast recovery. Furthermore, right after fast recovery,
> cwnd goes into slow start since cwnd is typically far smaller than ssthrsh
> after fast recovery. This also creates a lot of burst -- likely causing back
> to back losses or even timeouts.
> 
> You can see this behavior in the following link:
> 
> http://www.csc.ncsu.edu/faculty/rhee/export/bitcp/tiny_release/experiments/B
> IC-600-75-7500-1-0-0-noburst/index.htm
> 
> We run in a dummynet without any change in the burst control. You can see
> that whenever there is fast recovery, the rate almost drop to zero. The pink
> line is the throughput observed from the dummynet at every second, and red
> one is from Iperf. In the second figure, you can see cwnd. It drops to the
> bottom during fast recovery -- this is not part of congestion control. It is
> the burst control of Linux SACK doing it. 
> 
> But with our new burst control:
> 
> http://www.csc.ncsu.edu/faculty/rhee/export/bitcp/tiny_release/experiments/B
> IC-600-75-7500-1-0-0/index.htm
> 
> You can see that cwnd is quite stabilized and the throughput does not have
> as much dip as in the original case.
> 
> Here is what we do: instead of reducing cwnd to packet_in_flight (which is,
> in fact, meddling with congestion control), we reduce the gap between these
> two numbers by allowing transmitting more packets per ack (we set this to
> three more packets per ack) until packet_in_flight becomes close to cwnd.
> Also right after fast recovery, we increase packet_in_flight by 1% of
> packet_in_flight up to cwnd. This reduces the huge burst after fast
> recovery. Our implementation is trying to leave cwnd only to congestion
> control and separates burst control from congestion control. This makes the
> behavior of congestion control more predictable.  We will report more on
> this tomorrow when we get back to the Lab to test some other environments,
> especially when we have smaller buffers. This scheme may not be the cure for
> all and needs more testing. So far, it has been working very well.
> 
> Stay tuned.
> Injong.
> ---
> Injong Rhee, Associate Professor
> North Carolina State University
> Raleigh, NC 27699
> rhee@eos.ncsu.edu, http://www.csc.ncsu.edu/faculty/rhee
> 
> 
> 
> -----Original Message-----
> From: David S. Miller [mailto:davem@redhat.com] 
> Sent: Tuesday, July 06, 2004 8:29 PM
> To: Injong Rhee
> Cc: shemminger@osdl.org; netdev@oss.sgi.com; rhee@ncsu.edu; lxu2@ncsu.edu;
> mathis@psc.edu
> Subject: Re: [RFC] TCP burst control
> 
> On Tue, 6 Jul 2004 20:09:41 -0400
> "Injong Rhee" <rhee@eos.ncsu.edu> wrote:
> 
> > Currently with rate having, current Linux tcp stack is full of hacks that
> in
> > fact, hurt the performance of linux tcp (sorry to say this).
> 
> If rate-halving is broken, have you taken this up with it's creator,
> Mr. Mathis?  What was his response?
> 
> I've added him to the CC: list so this can be properly discussed.
> 
> 
>  




______________________________________________________________________ 
Post your free ad now! http://personals.yahoo.ca
