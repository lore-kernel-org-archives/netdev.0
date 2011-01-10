From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] sched: CHOKe packet scheduler (v0.2)
Date: Mon, 10 Jan 2011 18:45:11 +0100
Message-ID: <1294681511.3491.21.camel@edumazet-laptop>
References: <20110104162930.6fa672e3@nehalam>
	 <1294208375.3420.46.camel@edumazet-laptop>
	 <20110105091718.02f8a00f@nehalam>
	 <1294248332.10633.25.camel@edumazet-laptop>
	 <20110105112104.64ad3c86@nehalam>
	 <1294286850.2723.65.camel@edumazet-laptop>
	 <20110106205549.0de56de1@nehalam> <1294667210.3491.7.camel@edumazet-laptop>
	 <20110110093123.5431b368@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42579 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220Ab1AJRt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 12:49:28 -0500
Received: by wwa36 with SMTP id 36so886023wwa.1
        for <netdev@vger.kernel.org>; Mon, 10 Jan 2011 09:49:23 -0800 (PST)
In-Reply-To: <20110110093123.5431b368@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 10 janvier 2011 =C3=A0 09:31 -0800, Stephen Hemminger a =C3=A9=
crit :
> On Mon, 10 Jan 2011 14:46:50 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > Le jeudi 06 janvier 2011 =C3=A0 20:55 -0800, Stephen Hemminger a =C3=
=A9crit :
> >=20
> > >=20
> > > The problem is that large tables of pointers in kernel require ei=
ther
> > > contiguous allocation or some indirect table algorithm.
> > >=20
> >=20
> > Here is a v3 version with an array based queue for O(1) peek_random
> > complexity.
> >=20
> > Could you send the iproute2 patch so that I can test it ?
> >=20
> > Thanks !
> >=20
> >=20
> > diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
> > index e69de29..ea9db00 100644
> > --- a/net/sched/sch_choke.c
> > +++ b/net/sched/sch_choke.c
> > @@ -0,0 +1,388 @@
> > +/*
> > + * net/sched/sch_choke.c	CHOKE scheduler
> > + *
> > + * Copyright (c) 2011 Stephen Hemminger <shemminger@vyatta.com>
> > + * Copyright (c) 2011 Eric Dumazet <eric.dumazet@gmail.com>
> > + *
> > + * This program is free software; you can redistribute it and/or
> > + * modify it under the terms of the GNU General Public License
> > + * version 2 as published by the Free Software Foundation.
> > + *
> > + */
> > +
> > +#include <linux/module.h>
> > +#include <linux/types.h>
> > +#include <linux/kernel.h>
> > +#include <linux/skbuff.h>
> > +#include <linux/reciprocal_div.h>
> > +#include <net/pkt_sched.h>
> > +#include <net/inet_ecn.h>
> > +#include <net/red.h>
> > +
> > +/*	CHOKe stateless AQM for fair bandwidth allocation
> > +        =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
> > +
> > +   CHOKe (CHOose and Keep for responsive flows, CHOose and Kill fo=
r
> > +   unresponsive flows) is a variant of RED that penalizes misbehav=
ing flows but
> > +   maintains no flow state. The difference from RED is an addition=
al step
> > +   during the enqueuing process. If average queue size is over the
> > +   low threshold (qmin), a packet is chosen at random from the que=
ue.
> > +   If both the new and chosen packet are from the same flow, both
> > +   are dropped. Unlike RED, CHOKe is not a "classful" qdisc becaus=
e it
> > +   needs to access packets in queue randomly.
> > +
> > +   Source:
> > +   R. Pan, B. Prabhakar, and K. Psounis, "CHOKe, A Stateless
> > +   Active Queue Management Scheme for Approximating Fair Bandwidth=
 Allocation",
> > +   IEEE INFOCOM, 2000.
> > +
> > +   A. Tang, J. Wang, S. Low, "Understanding CHOKe: Throughput and =
Spatial
> > +   Characteristics", IEEE/ACM Transactions on Networking, 2004
> > +
> > + */
> > +
> > +struct choke_sched_data {
> > +	u32		 limit;
> > +	unsigned char	 flags;
> > +
> > +	struct red_parms parms;
> > +	struct red_stats stats;
> > +
> > +	unsigned int	 head;
> > +	unsigned int	 tail;
> > +	unsigned int	 holes;
> > +	unsigned int	 tab_mask; /* size - 1 */
> > +	struct sk_buff **tab;
> > +};
> > +
> > +static inline unsigned int choke_len(const struct choke_sched_data=
 *q)
> > +{
> > +	return (q->tail - q->head) & q->tab_mask;
> > +}
> > +
> > +/* deliver a random number between 0 and N - 1 */
> > +static inline u32 random_N(unsigned int N)
> > +{
> > +	return reciprocal_divide(random32(), N);
> > +}
> > +
> > +/* Select a packet at random from the queue in O(1) */
> > +static struct sk_buff *choke_peek_random(struct choke_sched_data *=
q, unsigned int *pidx)
> > +{
> > +	*pidx =3D (q->head + random_N(choke_len(q))) & q->tab_mask;
> > +	return q->tab[*pidx];
> > +}
>=20
> I don't think this works right. The choke_peek_random could find a ho=
le.
> Either the data structure has to change, or the peek_random has to re=
try,
> or if quick peek fails then compress the slot with memmove and retry.
>=20
>=20

Yes, this "compress only if peek_random() finds a hole seems good, I'll
try this.

As number of holes is known, we could have :

if (holes_proportion_is_less_than_20_percent())
	try another random number X times
else
	compress table to remove holes.



