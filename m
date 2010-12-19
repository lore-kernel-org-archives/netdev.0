From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC PATCH] net_sched: sch_sfq: better struct layouts
Date: Sun, 19 Dec 2010 22:22:34 +0100
Message-ID: <20101219212234.GA2323@del.dom.local>
References: <1292421783.3427.232.camel@edumazet-laptop>
 <4D08E6C2.804@trash.net>
 <1292430424.3427.350.camel@edumazet-laptop>
 <1292431256.3427.358.camel@edumazet-laptop>
 <4D08F025.5030603@trash.net>
 <1292432120.3427.366.camel@edumazet-laptop>
 <4D08F4F4.3050501@trash.net>
 <1292504932.2883.110.camel@edumazet-laptop>
 <1292604766.2906.51.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36011 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932485Ab0LSVWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Dec 2010 16:22:42 -0500
Received: by wyb28 with SMTP id 28so2305394wyb.19
        for <netdev@vger.kernel.org>; Sun, 19 Dec 2010 13:22:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1292604766.2906.51.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 17, 2010 at 05:52:46PM +0100, Eric Dumazet wrote:
> Le jeudi 16 d=E9cembre 2010 ?? 14:08 +0100, Eric Dumazet a =E9crit :
=2E..
> > struct sfq_slot {
> > 	struct sk_buff *first;
> > 	struct sk_buff *last;
> > 	u8 qlen;
> > 	sfq_index next; /* dequeue chain */
> > 	u16 hash;
> > 	short allot;
> > 	/* 16bit hole */
> > };
> >=20
> > This would save 768 bytes on x86_64 (and much more if LOCKDEP is us=
ed)

I think open coding sk_buff_head is a wrong idea. Otherwise, this
patch looks OK to me, only a few cosmetic suggestions below.

>=20
> Here is a preliminary patch, shrinking sizeof(struct sfq_sched_data)
> from 0x14f8 (or more if spinlocks are bigger) to 0x1180 bytes, and
> reduce text size as well.
>=20
>    text	   data	    bss	    dec	    hex	filename
>    4821	    152	      0	   4973	   136d	old/net/sched/sch_sfq.o
>    4651	    136	      0	   4787	   12b3	new/net/sched/sch_sfq.o
>=20
>=20
> All data for a slot/flow is now grouped in a compact and cache friend=
ly
> structure :
>=20
> struct sfq_slot {
>         struct sk_buff  *skblist_next;
>         struct sk_buff  *skblist_prev;
>         sfq_index       qlen; /* number of skbs in skblist */
>         sfq_index       next; /* next slot in sfq chain */
>         unsigned short  hash; /* hash value (index in ht[]) */
>         short           allot; /* credit for this slot */
>         struct sfq_head anchor; /* anchor in dep[] chains */
> };
>=20
>=20
>=20
>  net/sched/sch_sfq.c |  223 +++++++++++++++++++++++------------------=
-
>  1 file changed, 125 insertions(+), 98 deletions(-)
>=20
> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index 3cf478d..28968eb 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> @@ -69,25 +69,40 @@
>  	This implementation limits maximal queue length to 128;
>  	maximal mtu to 2^15-1; number of hash buckets to 1024.
>  	The only goal of this restrictions was that all data
> -	fit into one 4K page :-). Struct sfq_sched_data is
> -	organized in anti-cache manner: all the data for a bucket
> -	are scattered over different locations. This is not good,
> -	but it allowed me to put it into 4K.
> +	fit into one 4K page on 32bit arches.
> =20
>  	It is easy to increase these values, but not in flight.  */
> =20
> -#define SFQ_DEPTH		128
> +#define SFQ_DEPTH		128 /* max number of packets per slot (per flow) =
*/
> +#define SFQ_SLOTS		128 /* max number of flows */
> +#define EMPTY_SLOT		255

SFQ_EMPTY_SLOT?

>  #define SFQ_HASH_DIVISOR	1024
> =20
> -/* This type should contain at least SFQ_DEPTH*2 values */
> +/* This type should contain at least SFQ_DEPTH + SFQ_SLOTS values */
>  typedef unsigned char sfq_index;
> =20
> +/*
> + * We dont use pointers to save space.
> + * Small indexes [0 ... SFQ_SLOTS - 1] are 'pointers' to slots[] arr=
ay
> + * while following values [SFQ_SLOTS ... SFQ_SLOTS + SFQ_DEPTH - 1]
> + * are 'pointers' to dep[] array
> + */
>  struct sfq_head
>  {
>  	sfq_index	next;
>  	sfq_index	prev;
>  };
> =20
> +struct sfq_slot {
> +	struct sk_buff	*skblist_next;
> +	struct sk_buff	*skblist_prev;
> +	sfq_index	qlen; /* number of skbs in skblist */
> +	sfq_index	next; /* next slot in sfq chain */
> +	unsigned short	hash; /* hash value (index in ht[]) */
> +	short		allot; /* credit for this slot */
> +	struct sfq_head anchor; /* anchor in dep[] chains */

struct sfq_head dep?

> +};
> +
>  struct sfq_sched_data
>  {
>  /* Parameters */
> @@ -99,17 +114,24 @@ struct sfq_sched_data
>  	struct tcf_proto *filter_list;
>  	struct timer_list perturb_timer;
>  	u32		perturbation;
> -	sfq_index	tail;		/* Index of current slot in round */
> -	sfq_index	max_depth;	/* Maximal depth */
> +	sfq_index	max_depth;	/* depth of longest slot */

depth and/or length? (One dimension should be enough.)

> =20
> +	struct sfq_slot *tail;		/* current slot in round */
>  	sfq_index	ht[SFQ_HASH_DIVISOR];	/* Hash table */
> -	sfq_index	next[SFQ_DEPTH];	/* Active slots link */
> -	short		allot[SFQ_DEPTH];	/* Current allotment per slot */
> -	unsigned short	hash[SFQ_DEPTH];	/* Hash value indexed by slots */
> -	struct sk_buff_head	qs[SFQ_DEPTH];		/* Slot queue */
> -	struct sfq_head	dep[SFQ_DEPTH*2];	/* Linked list of slots, indexed =
by depth */
> +	struct sfq_slot	slots[SFQ_SLOTS];
> +	struct sfq_head	dep[SFQ_DEPTH];	/* Linked list of slots, indexed by=
 depth */
>  };
> =20
> +/*
> + * sfq_head are either in a sfq_slot or in dep[] array
> + */
> +static inline struct sfq_head *get_head(struct sfq_sched_data *q, sf=
q_index val)

static inline struct sfq_head *sfq_dep_head()?

=2E..
> @@ -304,31 +328,36 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *=
sch)
>  	hash--;
> =20
>  	x =3D q->ht[hash];
> -	if (x =3D=3D SFQ_DEPTH) {
> -		q->ht[hash] =3D x =3D q->dep[SFQ_DEPTH].next;
> -		q->hash[x] =3D hash;
> +	slot =3D &q->slots[x];
> +	if (x =3D=3D EMPTY_SLOT) {
> +		x =3D q->dep[0].next; /* get a free slot */
> +		q->ht[hash] =3D x;
> +		slot =3D &q->slots[x];
> +		slot->hash =3D hash;
> +		slot->skblist_next =3D slot->skblist_prev =3D (struct sk_buff *)sl=
ot;
>  	}
> =20
> -	/* If selected queue has length q->limit, this means that
> -	 * all another queues are empty and that we do simple tail drop,

No reason to remove this line.

> +	/* If selected queue has length q->limit, do simple tail drop,
>  	 * i.e. drop _this_ packet.
>  	 */
> -	if (q->qs[x].qlen >=3D q->limit)
> +	if (slot->qlen >=3D q->limit)
>  		return qdisc_drop(skb, sch);
> =20
>  	sch->qstats.backlog +=3D qdisc_pkt_len(skb);
> -	__skb_queue_tail(&q->qs[x], skb);
> +	skb->prev =3D slot->skblist_prev;
> +	skb->next =3D (struct sk_buff *)slot;
> +	slot->skblist_prev->next =3D skb;
> +	slot->skblist_prev =3D skb;

If you really have to do this, all these: __skb_queue_tail(),
__skb_dequeue(), skb_queue_head_init(), skb_peek() etc. used here
should stay as (local) inline functions to remain readability.

Jarek P.
