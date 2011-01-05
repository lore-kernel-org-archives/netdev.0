From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] sched: CHOKe packet scheduler (v0.2)
Date: Wed, 5 Jan 2011 12:15:52 -0800
Message-ID: <20110105121552.1b4ccb03@nehalam>
References: <20110104162930.6fa672e3@nehalam>
	<1294208375.3420.46.camel@edumazet-laptop>
	<20110105091718.02f8a00f@nehalam>
	<1294248332.10633.25.camel@edumazet-laptop>
	<20110105112104.64ad3c86@nehalam>
	<1294257967.2723.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50992 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752161Ab1AEUP4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 15:15:56 -0500
In-Reply-To: <1294257967.2723.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 05 Jan 2011 21:06:07 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mercredi 05 janvier 2011 =E0 11:21 -0800, Stephen Hemminger a =E9c=
rit :
> > This implements the CHOKe packet scheduler based on the existing
> > Linux RED scheduler based on the algorithm described in the paper.
> >=20
>=20
> > +
> > +static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> > +{
> > +	struct choke_sched_data *q =3D qdisc_priv(sch);
> > +	struct red_parms *p =3D &q->parms;
> > +
> > +	p->qavg =3D red_calc_qavg(p, skb_queue_len(&sch->q));
> > +	if (red_is_idling(p))
> > +		red_end_of_idle_period(p);
> > +
> > +	if (p->qavg <=3D p->qth_min)
> > +		p->qcount =3D -1;
> > +	else {
> > +		struct sk_buff *oskb;
> > +
> > +		/* Draw a packet at random from queue */
> > +		oskb =3D skb_peek_random(&sch->q);
> > +
> > +		/* Both packets from same flow?
> > +		 * Assumes skb_get_rxhash already set hash on oskb->rxhash
> > +		 * prior to queuing
>=20
> but this is not true... if at that time, p->qavg was <=3D p->qth_min.
> Packet was directly enqueued.
>=20
> Just use :
>=20
> if (skb_get_rxhash(oskb) =3D=3D skb_get_rxhash(skb))
>=20
> Since skb_get_rxhash(skb) doesnt recompute rxhash if already set.
>=20
> Hmm... I am now wondering if this actually works on egress at all
> (can we use rxhash here I mean)
>=20
>=20
>=20
> > +		 */
> > +		if (oskb->rxhash =3D=3D skb_get_rxhash(skb)) {
> > +			/* Drop both packets */
> > +			__skb_unlink(oskb, &sch->q);
> > +			qdisc_drop(oskb, sch);
> > +			goto congestion_drop;
> > +		}
>=20

The code computes a value, whether it is correct or not is another ques=
tion.
Also a little concerned that different NIC's compute different flow has=
h
values which could cause false positives.

--=20
