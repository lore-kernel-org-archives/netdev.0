From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] act_cpu: packet distributing
Date: Wed, 14 Jul 2010 06:30:04 +0200
Message-ID: <1279081804.2444.117.camel@edumazet-laptop>
References: <1279077475-2956-1-git-send-email-xiaosuo@gmail.com>
	 <1279078875.2444.103.camel@edumazet-laptop>
	 <AANLkTimPmXWyAspJqnya7aM_vDRNzDdJJf2bl7CYrAXN@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41263 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885Ab0GNEaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 00:30:08 -0400
Received: by wwi17 with SMTP id 17so1658255wwi.1
        for <netdev@vger.kernel.org>; Tue, 13 Jul 2010 21:30:07 -0700 (PDT)
In-Reply-To: <AANLkTimPmXWyAspJqnya7aM_vDRNzDdJJf2bl7CYrAXN@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 juillet 2010 =C3=A0 12:17 +0800, Changli Gao a =C3=A9cri=
t :
> On Wed, Jul 14, 2010 at 11:41 AM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:

> >
> > Why doing the search again, in case skb->sk already set by another
> > module before you, like tproxy ?
> >
>=20
> Although it is unlikely skb->sk is non null, as tc is before
> netfilter, I will handle this case. Thanks.
>=20

In this case, provide the skb->sk already set case on tproxy, not in
act_cpu. But doing it on both will give a hint for future modules...

> >> +static int tcf_cpu(struct sk_buff *skb, struct tc_action *a,
> >> +                struct tcf_result *res)
> >> +{
> >> +     struct tcf_cpu *p =3D a->priv;
> >> +     u32 type;
> >> +     u32 value;
> >> +     int cpu, action;
> >> +     struct sk_buff *nskb;
> >> +     unsigned int qtail;
> >> +
> >> +     spin_lock(&p->tcf_lock);
> >
> > Ok, the big lock...
> >
> > We have a lockless TCP/UDP input path, and this modules adds a lock
> > again.
> >
> >> +     p->tcf_tm.lastuse =3D jiffies;
> >> +     p->tcf_bstats.bytes +=3D qdisc_pkt_len(skb);
> >> +     p->tcf_bstats.packets++;
> >> +     type =3D p->type;
> >> +     value =3D p->value;
> >> +     action =3D p->tcf_action;
> >> +     spin_unlock(&p->tcf_lock);
> >> +
> >
> > Please change all this crap  (legacy crap, copied from other tc
> > modules), by modern one, using RCU and no locking in hot path.
> >
>=20
> Thanks, I'll try. It is a write critical section, and for me it is
> difficult to convert this lock to RCU. Could you show me some
> examples?

We can convert bytes/packets stats to percpu stats for example.
That might need a generic change.

Then, a normal RCU protection should be enough to fetch
type/value/action fields.



