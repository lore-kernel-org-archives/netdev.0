From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: creating netdev queues on the fly?
Date: Thu, 10 Nov 2011 18:00:15 +0100
Message-ID: <1320944415.10042.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1320933501.3967.68.camel@jlt3.sipsolutions.net>
	 <1320935713.2310.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 (sfid-20111110_153533_082549_9B566EB4) <1320942369.3967.127.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1320942369.3967.127.camel-8upI4CBIZJIJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le jeudi 10 novembre 2011 =C3=A0 17:26 +0100, Johannes Berg a =C3=A9cri=
t :
> On Thu, 2011-11-10 at 15:35 +0100, Eric Dumazet wrote:
>=20
> > > So to get to my question: What if we could create netdev queues o=
n the
> > > fly?
>=20
> > In term of qdisc management I believe its a bit complex if we start=
 to
> > dynamically add netdev queues :)
>=20
> Yeah I was thinking that would be the problematic part.
>=20
> > My first idea would be to extend Qdisc management so that a device =
can
> > callback qdisc when a frame is finaly delivered / consumed / discar=
ded.
> >=20
> > We currently only have qdisc->enqueue() and qdisc->dequeue(), we co=
uld
> > add qdisc->deliver_callback(skb)
> >=20
> > You keep devices as they are, with a netdevqueue per hardware queue=
=2E
> >=20
> > Then, using a Qdisc like existing ones, but with a limit of
> > outstanding(given to device but not yet consumed) packets per class=
=2E
> >=20
> > external tc classifier would deliver a hash/index depending on remo=
te
> > station.
>=20
> So basically you'd have a class for each station? Or a class for each
> station/AC? That's a lot of classes rather than queues, are they
> pre-allocated, or does it not matter? Overall that sounds like a good
> approach.

They could be statically allocated in a stochastic fashion (Sorry, SFQ
is one of my favorite qdisc, very light in memory/cpu and yet powerful)

net/sched/sch_sfq.c

Of course, HFSC / DRR are considered more flexible, but eat _much_ more
memory.

http://people.netfilter.org/kaber/shaping

You declare a hash divisor of 1024 to map one station to one class
(Might have hash collision of course...)

Each active slot contains a local queue to one remote station.
Each queue can be pfifo or whatever smart qdisc (sfq, or a more flexibl=
e
qdisc)

Then you use a filter to select the appropriate class :

tc filter add dev ${dev} protocol all pref 1 parent $handle handle 1 \
	flow hash keys remote_station divisor 1024



--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
