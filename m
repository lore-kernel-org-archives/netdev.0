From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2] net_sched: sch_sfq: fix allot handling
Date: Wed, 15 Dec 2010 17:43:17 +0100
Message-ID: <4D08F025.5030603@trash.net>
References: <1292421783.3427.232.camel@edumazet-laptop>	 <4D08E6C2.804@trash.net>  <1292430424.3427.350.camel@edumazet-laptop> <1292431256.3427.358.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54816 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810Ab0LOQnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 11:43:21 -0500
In-Reply-To: <1292431256.3427.358.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.12.2010 17:40, Eric Dumazet wrote:
> Le mercredi 15 d=E9cembre 2010 =E0 17:27 +0100, Eric Dumazet a =E9cri=
t :
>=20
>> Hmm, you may be right, thanks a lot for reviewing !
>>
>> I noticed that with normal quantum (1514), my SFQ setup was sending =
two
>> full frames per flow after my patch, so was about to prepare a new
>> version ;)
>>
>> I'll post a v2 shortly.
>=20
> Indeed, the missing init in sfq_enqueue() is enough to solve the
> problem :=20
>=20
> [PATCH v2] net_sched: sch_sfq: fix allot handling
>=20
> When deploying SFQ/IFB here at work, I found the allot management was
> pretty wrong in sfq, even changing allot from short to int...
>=20
> We should init allot for each new flow, not using a previous value fo=
und
> in slot.
>=20
> Before patch, I saw bursts of several packets per flow, apparently
> denying the default "quantum 1514" limit I had on my SFQ class.
>=20
> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index 3cf478d..065a2a5 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> @@ -321,14 +321,13 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *=
sch)
>  	sfq_inc(q, x);
>  	if (q->qs[x].qlen =3D=3D 1) {		/* The flow is new */
>  		if (q->tail =3D=3D SFQ_DEPTH) {	/* It is the first flow */
> -			q->tail =3D x;
>  			q->next[x] =3D x;
> -			q->allot[x] =3D q->quantum;
>  		} else {
>  			q->next[x] =3D q->next[q->tail];
>  			q->next[q->tail] =3D x;
> -			q->tail =3D x;
>  		}
> +		q->tail =3D x;
> +		q->allot[x] =3D q->quantum;
>  	}

Now we could remove the allot increase in sfq_dequeue for
the case that the flow becomes inactive. It is incorrect
anyways.
