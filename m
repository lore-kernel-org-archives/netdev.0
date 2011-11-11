From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: creating netdev queues on the fly?
Date: Fri, 11 Nov 2011 12:02:54 +0100
Message-ID: <1321009374.2548.31.camel@edumazet-laptop>
References: <1320933501.3967.68.camel@jlt3.sipsolutions.net>
	 <CAGXE3d-_RFgW_zwfX2vTBe1psXmgoBFO5pd5cAgtYo=Jwpddhw@mail.gmail.com>
	 <7be02f26a67fac4c7448a74f1f17aa01@visp.net.lb>
	 <CAA93jw7ECQegWj6rpd48sbmDQUjorCYzXANXJSj0baHtxzC7EA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Denys Fedoryshchenko <denys-ArQk2d8GGkZT5gTzvV8LJA@public.gmane.org>,
	Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAA93jw7ECQegWj6rpd48sbmDQUjorCYzXANXJSj0baHtxzC7EA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le jeudi 10 novembre 2011 =C3=A0 16:25 +0100, Dave Taht a =C3=A9crit :



> Two notes:
>=20
> 1) Getting 'time' from the kernel is expensive. And: System time wand=
ers.
>=20
> mac80211 Wifi devices however do export a get_tsf function which coul=
d
> be used as a relative-to-the-queue clock - and we actually don't need
> accuracy down to the level of get_tsf (25ns)
>=20


getting 'time' from kernel is not that expensive, depending on
resolution you need. We are not going to use timestamps from devices !

If ms resolution is enough (say you want to drop packets if they stay
more than 100ms in qdisc), jiffies is a single memory read.

If needing us or ns resolution, psched_get_time() uses ktime_get(), and
is used in CBQ, HTB, HFSC, TBF, so if it was expensive we would have bi=
g
problem right now :)

2) You need to get a timestamp on entry to the first queue and check
> against the allowable latency on exit from the last. So to construct =
a
> tc chain you'd want a tfifo (timestamp on entry), fifot (check
> timestamp against limit on dequeue), and for the simplest of
> applications : tfifot (timestamp on entry, check on exit)

That would be not very practical.

I would see a new Qdisc/Class property, like the rate estimator, that w=
e
can attach to any Qdisc/Class with a new tc option.

Even without any limit enforcing (might be Random Early Detection by th=
e
way), it could be used to get a Queue Delay estimation, using EWMA

avqdelay =3D avqdelay*(1-W) + qdelay*W;
W =3D 2^(-ewma_log);

tc [ qdisc | class] add [...] [est 1sec 8sec] [delayest ewma_log ] ..

tc -s -d qdisc ...
qdisc htb 1: root refcnt 2 r2q 10 default 1 direct_packets_stat 0 ver 3=
=2E17
 Sent 3596219 bytes 2567 pkt (dropped 238, overlimits 3797 requeues 0)=20
 rate 2557Kbit 215pps backlog 0b 0p requeues 0=20
 delay 91ms



tc [ qdisc | class] add [...] [est 1sec 8sec] [delaylimit max ] ..

tc -s -d qdisc ...
qdisc htb 1: root refcnt 2 r2q 10 default 1 direct_packets_stat 0 ver 3=
=2E17
 Sent 3596219 bytes 2567 pkt (dropped 238, overlimits 3797 requeues 0)=20
 rate 2557Kbit 215pps backlog 0b 0p requeues 0=20
 delay 91ms delaylimit 100ms (dropped 12)



--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
