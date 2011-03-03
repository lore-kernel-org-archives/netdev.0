From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v2)
Date: Thu, 03 Mar 2011 09:27:48 +0100
Message-ID: <1299140868.2456.35.camel@edumazet-laptop>
References: <20110228171738.2cc8c9a0@nehalam>
	 <20110302020610.GD1005@gandalf.sssup.it>
	 <1299064667.2920.4.camel@edumazet-laptop> <20110302081108.689571d8@nehalam>
	 <1299082728.2920.18.camel@edumazet-laptop>
	 <1299087087.2920.27.camel@edumazet-laptop>
	 <20110303081940.GA29685@gandalf.sssup.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org,
	Paolo Valente <paolo.valente@unimore.it>
To: Fabio Checconi <fchecconi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44825 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754676Ab1CCIhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 03:37:25 -0500
Received: by fxm17 with SMTP id 17so862578fxm.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 00:37:24 -0800 (PST)
In-Reply-To: <20110303081940.GA29685@gandalf.sssup.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 mars 2011 =C3=A0 09:19 +0100, Fabio Checconi a =C3=A9crit :
> Hi,
>=20
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Wed, Mar 02, 2011 06:31:27PM +0100
> >
> > Le mercredi 02 mars 2011 =C3=A0 17:18 +0100, Eric Dumazet a =C3=A9c=
rit :
> > > Le mercredi 02 mars 2011 =C3=A0 08:11 -0800, Stephen Hemminger a =
=C3=A9crit :
> > >=20
> > > > I put the iproute2 code into the repository in the experimental=
 branch.
> > > >=20
> > >=20
> > > Thanks
> > >=20
> > > It seems as soon as packets are dropped, qdisc is frozen (no more
> > > packets dequeued)
>=20
>   I've been able to reproduce this problem using netem, and it seems =
to
> be due to this check:
>=20
> > +	/* If the new skb is not the head of queue, then done here. */
> > +	if (skb !=3D qdisc_peek_head(cl->qdisc))
> > +		return err;
>=20
> changing it to:
>=20
> 	if (cl->qdisc->q.qlen !=3D 1)
> 		return err;
>=20
> seems to make things work.  I think this is because qdisc_peek_head()
> looks at the wrong list, as the skb is not queued directly in q, but
> ends up in the child qdisc attached to cl->qdisc.
>=20

Strange, I used the default qdisc (pfifo) created in qfq classes

>=20
> > >=20
> > > Hmm...
> > >=20
> >=20
> > It seems class deletes are buggy.
> >=20
> > After one "tc class del dev $ETH classid 11:1 ..."
> >=20
> > a "tc -s -d qdisc show dev $ETH" triggers an Oops
> >=20
>=20
> This seems to be due to:
>=20
> > +static void qfq_destroy_class(struct Qdisc *sch, struct qfq_class =
*cl)
> > +{
> > +	struct qfq_sched *q =3D (struct qfq_sched *)sch;
>=20
> it should be:
>=20
> 	struct qfq_sched *q =3D sched_priv(sch);
>=20
> The same bug you identified in qfq_reset_qdisc() is present also in
> qfq_drop(), both loops need to be corrected...
>=20
> It should also be noted that this scheduler (like HFSC, IIRC) depends
> on the child qdisc not to reorder packets for the guarantees to be me=
t,
> as the timestamps need to be in sync with the length of the packet at=
 the
> head of the queue.  If this can't be guaranteed, to preserve the form=
al
> correctness it should be changed to always use the maximum packet siz=
e
> to calculate the timestamps.
>=20
> @Stephen: not that I'm proud of that, but all the bugs found so far a=
re mine...

I am going to test an updated version, thanks for all these hints !



