From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Wed, 06 Jul 2005 02:32:24 +0200
Message-ID: <42CB2698.2080904@cosmosbay.com>
References: <20050705173411.GK16076@postel.suug.ch> <20050705.142210.14973612.davem@davemloft.net> <20050705213355.GM16076@postel.suug.ch> <20050705.143548.28788459.davem@davemloft.net> <42CB14B2.5090601@cosmosbay.com> <20050705234104.GR16076@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050705234104.GR16076@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf a =E9crit :

> I still think we can fix this performance issue without manually
> unrolling the loop or we should at least try to. In the end gcc
> should notice the constant part of the loop and move it out so
> basically the only difference should the additional prio++ and
> possibly a failing branch prediction.
>=20
> What about this? I'm still not sure where exactly all the time
> is lost so this is a shot in the dark.
>=20
> Index: net-2.6/net/sched/sch_generic.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net-2.6.orig/net/sched/sch_generic.c
> +++ net-2.6/net/sched/sch_generic.c
> @@ -330,10 +330,11 @@ static struct sk_buff *pfifo_fast_dequeu
>  {
>  	int prio;
>  	struct sk_buff_head *list =3D qdisc_priv(qdisc);
> +	struct sk_buff *skb;
> =20
> -	for (prio =3D 0; prio < PFIFO_FAST_BANDS; prio++, list++) {
> -		struct sk_buff *skb =3D __qdisc_dequeue_head(qdisc, list);
> -		if (skb) {
> +	for (prio =3D 0; prio < PFIFO_FAST_BANDS; prio++) {
> +		if (!skb_queue_empty(list + prio)) {
> +			skb =3D __qdisc_dequeue_head(qdisc, list);
>  			qdisc->q.qlen--;
>  			return skb;
>  		}
>=20
>=20

Hum... shouldnt it be :

+			skb =3D __qdisc_dequeue_head(qdisc, list + prio);


?

Anyway, the branches misprediction come from the fact that most of packet=
s are queued in the prio=3D2 list.

So each time this function is called, a non unrolled version has to pay 2=
 to 5 branches misprediction.

if ((!skb_queue_empty(list + prio))  /* branch not taken, mispredict when=
 prio=3D0 */

if ((!skb_queue_empty(list + prio))  /* branch not taken, mispredict when=
 prio=3D1 */
if ((!skb_queue_empty(list + prio))  /* branch taken (or not if queue is =
really empty), mispredict when prio=3D2 */

Maybe we can rewrite the whole thing without branches, examining prio fro=
m PFIFO_FAST_BANDS-1 down to 0, at least for modern cpu with=20
conditional mov (cmov)

struct sk_buff_head *best =3D NULL;
struct sk_buff_head *list =3D qdisc_priv(qdisc)+PFIFO_FAST_BANDS-1;
if (skb_queue_empty(list)) best =3D list ;
list--;
if (skb_queue_empty(list)) best =3D list ;
list--;
if (skb_queue_empty(list)) best =3D list ;
if (best !=3D NULL) {
	qdisc->q.qlen--;
	return __qdisc_dequeue_head(qdisc, best);
	}

This version should have one branch.
I will test this after some sleep :)
See you
Eric
