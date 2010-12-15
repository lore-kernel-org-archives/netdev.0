From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched: sch_sfq: fix allot handling
Date: Wed, 15 Dec 2010 17:27:04 +0100
Message-ID: <1292430424.3427.350.camel@edumazet-laptop>
References: <1292421783.3427.232.camel@edumazet-laptop>
	 <4D08E6C2.804@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:35094 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008Ab0LOQ1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 11:27:10 -0500
Received: by wwi17 with SMTP id 17so5532189wwi.1
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 08:27:08 -0800 (PST)
In-Reply-To: <4D08E6C2.804@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 d=C3=A9cembre 2010 =C3=A0 17:03 +0100, Patrick McHardy a=
 =C3=A9crit :
> On 15.12.2010 15:03, Eric Dumazet wrote:
> > When deploying SFQ/IFB here at work, I found the allot management w=
as
> > pretty wrong in sfq, even changing allot from short to int...
> >=20
> > We should init allot for each new flow turn, not using a previous v=
alue,
> > or else small packets can easily make allot overflow.
> >=20
> > Before patch, I saw burst of several packets per flow, apparently
> > denying the "allot 1514" limit I had on my SFQ class.
> >=20
> > class sfq 11:1 parent 11:=20
> >  (dropped 0, overlimits 0 requeues 0)=20
> >  backlog 0b 7p requeues 0=20
> >  allot 11546=20
> >=20
> > class sfq 11:46 parent 11:=20
> >  (dropped 0, overlimits 0 requeues 0)=20
> >  backlog 0b 1p requeues 0=20
> >  allot -23873=20
> >=20
> > class sfq 11:78 parent 11:=20
> >  (dropped 0, overlimits 0 requeues 0)=20
> >  backlog 0b 5p requeues 0=20
> >  allot 11393=20
>=20
> These values definitely look wrong.
>=20
> > diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> > index 3cf478d..8c8a190 100644
> > --- a/net/sched/sch_sfq.c
> > +++ b/net/sched/sch_sfq.c
> > @@ -270,7 +270,7 @@ static unsigned int sfq_drop(struct Qdisc *sch)
> >  		/* It is difficult to believe, but ALL THE SLOTS HAVE LENGTH 1. =
*/
> >  		d =3D q->next[q->tail];
> >  		q->next[q->tail] =3D q->next[d];
> > -		q->allot[q->next[d]] +=3D q->quantum;
> > +		q->allot[q->next[d]] =3D q->quantum;
> >  		skb =3D q->qs[d].prev;
> >  		len =3D qdisc_pkt_len(skb);
> >  		__skb_unlink(skb, &q->qs[d]);
>=20
> I'm not sure about this part, but lets ignore that for now since it
> shouldn't affect your testcase unless you're using CBQ.
>=20




> > @@ -321,14 +321,13 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc=
 *sch)
> >  	sfq_inc(q, x);
> >  	if (q->qs[x].qlen =3D=3D 1) {		/* The flow is new */
> >  		if (q->tail =3D=3D SFQ_DEPTH) {	/* It is the first flow */
> > -			q->tail =3D x;
> >  			q->next[x] =3D x;
> > -			q->allot[x] =3D q->quantum;
> >  		} else {
> >  			q->next[x] =3D q->next[q->tail];
> >  			q->next[q->tail] =3D x;
> > -			q->tail =3D x;
> >  		}
> > +		q->tail =3D x;
> > +		q->allot[x] =3D q->quantum;
> >  	}
>=20
> This looks correct, for new flows allot should be initialized from
> scratch.
>=20
> >  	if (++sch->q.qlen <=3D q->limit) {
> >  		sch->bstats.bytes +=3D qdisc_pkt_len(skb);
> > @@ -382,11 +381,11 @@ sfq_dequeue(struct Qdisc *sch)
> >  			return skb;
> >  		}
> >  		q->next[q->tail] =3D a;
> > -		q->allot[a] +=3D q->quantum;
> > +		q->allot[a] =3D q->quantum;
>=20
> The allot initialization doesn't seem necessary anymore at all
> now that you're reinitalizing allot for flows that became active
> unconditionally in sfq_enqueue().
>=20



> >  	} else if ((q->allot[a] -=3D qdisc_pkt_len(skb)) <=3D 0) {
> >  		q->tail =3D a;
> >  		a =3D q->next[a];
> > -		q->allot[a] +=3D q->quantum;
> > +		q->allot[a] =3D q->quantum;
>=20
> This seems to break long-term fairness for active flows by not
> accounting for overshooting the allotment in the next round
> anymore.
>=20
> I think either the change in sfq_enqueue() or the first change
> in sfq_dequeue() should be enough to fix the problem you're seeing.
> Basically what needs to be done is initialize allot once from
> scratch when the flow becomes active, then add one quantum per
> round while it stays active.

Hmm, you may be right, thanks a lot for reviewing !

I noticed that with normal quantum (1514), my SFQ setup was sending two
full frames per flow after my patch, so was about to prepare a new
version ;)

I'll post a v2 shortly.

Thanks


