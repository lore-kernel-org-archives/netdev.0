From: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: creating netdev queues on the fly?
Date: Fri, 11 Nov 2011 12:42:54 +0100
Message-ID: <CAA93jw7n1jYiWrnHOF0Zmzd0cVtadNhPSCpP5YqEdq_Q9opw5A@mail.gmail.com>
References: <1320933501.3967.68.camel@jlt3.sipsolutions.net>
	<CAGXE3d-_RFgW_zwfX2vTBe1psXmgoBFO5pd5cAgtYo=Jwpddhw@mail.gmail.com>
	<7be02f26a67fac4c7448a74f1f17aa01@visp.net.lb>
	<CAA93jw7ECQegWj6rpd48sbmDQUjorCYzXANXJSj0baHtxzC7EA@mail.gmail.com>
	<1321009374.2548.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Denys Fedoryshchenko <denys-ArQk2d8GGkZT5gTzvV8LJA@public.gmane.org>,
	Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew McGregor <andrewmcgr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1321009374.2548.31.camel@edumazet-laptop>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 11, 2011 at 12:02 PM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>=
 wrote:
> Le jeudi 10 novembre 2011 =E0 16:25 +0100, Dave Taht a =E9crit :
>
>
>
>> Two notes:
>>
>> 1) Getting 'time' from the kernel is expensive. And: System time wan=
ders.
>>
>> mac80211 Wifi devices however do export a get_tsf function which cou=
ld
>> be used as a relative-to-the-queue clock - and we actually don't nee=
d
>> accuracy down to the level of get_tsf (25ns)
>>
>
>
> getting 'time' from kernel is not that expensive, depending on
> resolution you need. We are not going to use timestamps from devices =
!

Wireless keeps track of time via a TSF function.

http://en.wikipedia.org/wiki/Timing_Synchronization_Function_%28TSF%29

TSF wanders forward based on an election process from broadcast beacons=
,
the presentation below contains animations and the like that describe
how it works

http://www.cse.ohio-state.edu/~lai/788-Au05/2-scalibility.ppt

=46urther it copes with life in terms of TU. One tu is 1024us.

Now, whether any of that is truly relevant to how to do packet
scheduling well on wireless, is a good question. TU is fairly
fundamental to the minstrel algorithm. It bothers me to have anything
resembling a beat frequency.

>
> If ms resolution is enough (say you want to drop packets if they stay
> more than 100ms in qdisc), jiffies is a single memory read.

The intended properties of the hardware queues are 10 ms VO, 100 ms
VI, and some_sane_number_relative_to_real_bandwidth for BE and BK.

The software queues should make similar assumptions, although for
voice traffic, being able to drop and 'pull forward' the next packet
in a stream should it exceed time in queue would be good, and you
could go with 30 ms in queue with that level of jitter.

>
> If needing us or ns resolution, psched_get_time() uses ktime_get(), a=
nd
> is used in CBQ, HTB, HFSC, TBF, so if it was expensive we would have =
big
> problem right now :)
>
> 2) You need to get a timestamp on entry to the first queue and check
>> against the allowable latency on exit from the last. So to construct=
 a
>> tc chain you'd want a tfifo (timestamp on entry), fifot (check
>> timestamp against limit on dequeue), and for the simplest of
>> applications : tfifot (timestamp on entry, check on exit)
>
> That would be not very practical.
>
> I would see a new Qdisc/Class property, like the rate estimator, that=
 we
> can attach to any Qdisc/Class with a new tc option.
>
> Even without any limit enforcing (might be Random Early Detection by =
the
> way), it could be used to get a Queue Delay estimation, using EWMA
>
> avqdelay =3D avqdelay*(1-W) + qdelay*W;
> W =3D 2^(-ewma_log);
>
> tc [ qdisc | class] add [...] [est 1sec 8sec] [delayest ewma_log ] ..

More elegant to be sure. But for N you kind of need to do ewma between
aggregated transmission groups.

>
> tc -s -d qdisc ...
> qdisc htb 1: root refcnt 2 r2q 10 default 1 direct_packets_stat 0 ver=
 3.17
> =A0Sent 3596219 bytes 2567 pkt (dropped 238, overlimits 3797 requeues=
 0)
> =A0rate 2557Kbit 215pps backlog 0b 0p requeues 0
> =A0delay 91ms

I still don't 'get' how we can split out a stream based on a
stationid, toss it in a queue to be further scheduled (my choice would
be QFQ, btw), and then sanely de-schedule a burst of packets for that
destination appropriate for that station's aggregation level and
transmit rate using existing tc methods.

I liked the callback idea discussed earlier for implementing a
'grouper' of this sort.

That said I'm strongly encouraged by the dialog thus far on this thread=
=2E

>
>
>
> tc [ qdisc | class] add [...] [est 1sec 8sec] [delaylimit max ] ..
>
> tc -s -d qdisc ...
> qdisc htb 1: root refcnt 2 r2q 10 default 1 direct_packets_stat 0 ver=
 3.17
> =A0Sent 3596219 bytes 2567 pkt (dropped 238, overlimits 3797 requeues=
 0)
> =A0rate 2557Kbit 215pps backlog 0b 0p requeues 0
> =A0delay 91ms delaylimit 100ms (dropped 12)

and I assume that you are either making this syntax up or coding
faster than emailing in some tree somewhere...

>
>
>
>



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
