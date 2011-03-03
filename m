From: Fabio Checconi <fchecconi@gmail.com>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v2)
Date: Thu, 3 Mar 2011 09:19:40 +0100
Message-ID: <20110303081940.GA29685@gandalf.sssup.it>
References: <20110228171738.2cc8c9a0@nehalam>
 <20110302020610.GD1005@gandalf.sssup.it>
 <1299064667.2920.4.camel@edumazet-laptop>
 <20110302081108.689571d8@nehalam>
 <1299082728.2920.18.camel@edumazet-laptop>
 <1299087087.2920.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org,
	Paolo Valente <paolo.valente@unimore.it>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms01.sssup.it ([193.205.80.99]:60842 "EHLO sssup.it"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754587Ab1CCIR6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 03:17:58 -0500
Content-Disposition: inline
In-Reply-To: <1299087087.2920.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, Mar 02, 2011 06:31:27PM +0100
>
> Le mercredi 02 mars 2011 =E0 17:18 +0100, Eric Dumazet a =E9crit :
> > Le mercredi 02 mars 2011 =E0 08:11 -0800, Stephen Hemminger a =E9cr=
it :
> >=20
> > > I put the iproute2 code into the repository in the experimental b=
ranch.
> > >=20
> >=20
> > Thanks
> >=20
> > It seems as soon as packets are dropped, qdisc is frozen (no more
> > packets dequeued)

  I've been able to reproduce this problem using netem, and it seems to
be due to this check:

> +	/* If the new skb is not the head of queue, then done here. */
> +	if (skb !=3D qdisc_peek_head(cl->qdisc))
> +		return err;

changing it to:

	if (cl->qdisc->q.qlen !=3D 1)
		return err;

seems to make things work.  I think this is because qdisc_peek_head()
looks at the wrong list, as the skb is not queued directly in q, but
ends up in the child qdisc attached to cl->qdisc.


> >=20
> > Hmm...
> >=20
>=20
> It seems class deletes are buggy.
>=20
> After one "tc class del dev $ETH classid 11:1 ..."
>=20
> a "tc -s -d qdisc show dev $ETH" triggers an Oops
>=20

This seems to be due to:

> +static void qfq_destroy_class(struct Qdisc *sch, struct qfq_class *c=
l)
> +{
> +	struct qfq_sched *q =3D (struct qfq_sched *)sch;

it should be:

	struct qfq_sched *q =3D sched_priv(sch);

The same bug you identified in qfq_reset_qdisc() is present also in
qfq_drop(), both loops need to be corrected...

It should also be noted that this scheduler (like HFSC, IIRC) depends
on the child qdisc not to reorder packets for the guarantees to be met,
as the timestamps need to be in sync with the length of the packet at t=
he
head of the queue.  If this can't be guaranteed, to preserve the formal
correctness it should be changed to always use the maximum packet size
to calculate the timestamps.

@Stephen: not that I'm proud of that, but all the bugs found so far are=
 mine...
