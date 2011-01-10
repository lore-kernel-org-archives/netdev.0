From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] sched: CHOKe packet scheduler (v0.2)
Date: Mon, 10 Jan 2011 09:31:23 -0800
Message-ID: <20110110093123.5431b368@nehalam>
References: <20110104162930.6fa672e3@nehalam>
	<1294208375.3420.46.camel@edumazet-laptop>
	<20110105091718.02f8a00f@nehalam>
	<1294248332.10633.25.camel@edumazet-laptop>
	<20110105112104.64ad3c86@nehalam>
	<1294286850.2723.65.camel@edumazet-laptop>
	<20110106205549.0de56de1@nehalam>
	<1294667210.3491.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35039 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753063Ab1AJRb1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 12:31:27 -0500
In-Reply-To: <1294667210.3491.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Jan 2011 14:46:50 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le jeudi 06 janvier 2011 =E0 20:55 -0800, Stephen Hemminger a =E9crit=
 :
>=20
> >=20
> > The problem is that large tables of pointers in kernel require eith=
er
> > contiguous allocation or some indirect table algorithm.
> >=20
>=20
> Here is a v3 version with an array based queue for O(1) peek_random
> complexity.
>=20
> Could you send the iproute2 patch so that I can test it ?
>=20
> Thanks !
>=20
>=20
> diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
> index e69de29..ea9db00 100644
> --- a/net/sched/sch_choke.c
> +++ b/net/sched/sch_choke.c
> @@ -0,0 +1,388 @@
> +/*
> + * net/sched/sch_choke.c	CHOKE scheduler
> + *
> + * Copyright (c) 2011 Stephen Hemminger <shemminger@vyatta.com>
> + * Copyright (c) 2011 Eric Dumazet <eric.dumazet@gmail.com>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * version 2 as published by the Free Software Foundation.
> + *
> + */
> +
> +#include <linux/module.h>
> +#include <linux/types.h>
> +#include <linux/kernel.h>
> +#include <linux/skbuff.h>
> +#include <linux/reciprocal_div.h>
> +#include <net/pkt_sched.h>
> +#include <net/inet_ecn.h>
> +#include <net/red.h>
> +
> +/*	CHOKe stateless AQM for fair bandwidth allocation
> +        =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
> +
> +   CHOKe (CHOose and Keep for responsive flows, CHOose and Kill for
> +   unresponsive flows) is a variant of RED that penalizes misbehavin=
g flows but
> +   maintains no flow state. The difference from RED is an additional=
 step
> +   during the enqueuing process. If average queue size is over the
> +   low threshold (qmin), a packet is chosen at random from the queue=
=2E
> +   If both the new and chosen packet are from the same flow, both
> +   are dropped. Unlike RED, CHOKe is not a "classful" qdisc because =
it
> +   needs to access packets in queue randomly.
> +
> +   Source:
> +   R. Pan, B. Prabhakar, and K. Psounis, "CHOKe, A Stateless
> +   Active Queue Management Scheme for Approximating Fair Bandwidth A=
llocation",
> +   IEEE INFOCOM, 2000.
> +
> +   A. Tang, J. Wang, S. Low, "Understanding CHOKe: Throughput and Sp=
atial
> +   Characteristics", IEEE/ACM Transactions on Networking, 2004
> +
> + */
> +
> +struct choke_sched_data {
> +	u32		 limit;
> +	unsigned char	 flags;
> +
> +	struct red_parms parms;
> +	struct red_stats stats;
> +
> +	unsigned int	 head;
> +	unsigned int	 tail;
> +	unsigned int	 holes;
> +	unsigned int	 tab_mask; /* size - 1 */
> +	struct sk_buff **tab;
> +};
> +
> +static inline unsigned int choke_len(const struct choke_sched_data *=
q)
> +{
> +	return (q->tail - q->head) & q->tab_mask;
> +}
> +
> +/* deliver a random number between 0 and N - 1 */
> +static inline u32 random_N(unsigned int N)
> +{
> +	return reciprocal_divide(random32(), N);
> +}
> +
> +/* Select a packet at random from the queue in O(1) */
> +static struct sk_buff *choke_peek_random(struct choke_sched_data *q,=
 unsigned int *pidx)
> +{
> +	*pidx =3D (q->head + random_N(choke_len(q))) & q->tab_mask;
> +	return q->tab[*pidx];
> +}

I don't think this works right. The choke_peek_random could find a hole=
=2E
Either the data structure has to change, or the peek_random has to retr=
y,
or if quick peek fails then compress the slot with memmove and retry.


--=20
