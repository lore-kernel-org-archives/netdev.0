From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-next] tcp: use an RB tree for ooo receive queue
Date: Thu, 8 Sep 2016 14:02:51 +0300 (EEST)
Message-ID: <alpine.DEB.2.10.1609081236470.18111@whp-28.cs.helsinki.fi>
References: <1473284968.15733.8.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_script-11482-1473332572-0001-2"
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Yaogong Wang <wygivan@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from script.cs.helsinki.fi ([128.214.11.1]:49893 "EHLO
        script.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932741AbcIHLIA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 07:08:00 -0400
In-Reply-To: <1473284968.15733.8.camel@edumazet-glaptop3.roam.corp.google.com>
Content-ID: <alpine.DEB.2.10.1609081359130.18111@whp-28.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_script-11482-1473332572-0001-2
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable
Content-ID: <alpine.DEB.2.10.1609081349201.18111@whp-28.cs.helsinki.fi>

On Wed, 7 Sep 2016, Eric Dumazet wrote:

> From: Yaogong Wang <wygivan@google.com>
>=20
> Over the years, TCP BDP has increased by several orders of magnitude,
> and some people are considering to reach the 2 Gbytes limit.
>=20
> Even with current window scale limit of 14, ~1 Gbytes maps to ~740,000
> MSS.
>    =20
> In presence of packet losses (or reorders), TCP stores incoming packets
> into an out of order queue, and number of skbs sitting there waiting fo=
r
> the missing packets to be received can be in the 10^5 range.
>=20
> Most packets are appended to the tail of this queue, and when
> packets can finally be transferred to receive queue, we scan the queue
> from its head.
>=20
> However, in presence of heavy losses, we might have to find an arbitrar=
y
> point in this queue, involving a linear scan for every incoming packet,
> throwing away cpu caches.
>=20
> This patch converts it to a RB tree, to get bounded latencies.
>=20
> Yaogong wrote a preliminary patch about 2 years ago.
> Eric did the rebase, added ofo_last_skb cache, polishing and tests.
>=20
> Tested with network dropping between 1 and 10 % packets, with good
> success (about 30 % increase of throughput in stress tests)

While testing, was there any check done for the data that was delivered
in order to ensure that no corruption occured (either by you or Yaogong)?=20
...This kind of changes have some potential to cause some corruption to
the stream content and it would be nice to be sure there wasn't any
accidents.

> Next step would be to also use an RB tree for the write queue at sender
> side ;)
>
> @@ -4403,8 +4414,10 @@ static int tcp_try_rmem_schedule(struct sock *sk=
, struct sk_buff *skb,
>  static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
>  {
>  =09struct tcp_sock *tp =3D tcp_sk(sk);
> +=09struct rb_node **p, *q, *parent;
>  =09struct sk_buff *skb1;
>  =09u32 seq, end_seq;
> +=09bool fragstolen;
> =20
>  =09tcp_ecn_check_ce(tp, skb);
> =20
> @@ -4419,88 +4432,85 @@ static void tcp_data_queue_ofo(struct sock *sk, =
struct sk_buff *skb)
>  =09inet_csk_schedule_ack(sk);
> =20
>  =09NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPOFOQUEUE);
> +=09seq =3D TCP_SKB_CB(skb)->seq;
> +=09end_seq =3D TCP_SKB_CB(skb)->end_seq;
>  =09SOCK_DEBUG(sk, "out of order segment: rcv_next %X seq %X - %X\n",
> -=09=09   tp->rcv_nxt, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq);
> +=09=09   tp->rcv_nxt, seq, end_seq);
> =20
> -=09skb1 =3D skb_peek_tail(&tp->out_of_order_queue);
> -=09if (!skb1) {
> +=09p =3D &tp->out_of_order_queue.rb_node;
> +=09if (RB_EMPTY_ROOT(&tp->out_of_order_queue)) {
>  =09=09/* Initial out of order segment, build 1 SACK. */
>  =09=09if (tcp_is_sack(tp)) {
>  =09=09=09tp->rx_opt.num_sacks =3D 1;
> -=09=09=09tp->selective_acks[0].start_seq =3D TCP_SKB_CB(skb)->seq;
> -=09=09=09tp->selective_acks[0].end_seq =3D
> -=09=09=09=09=09=09TCP_SKB_CB(skb)->end_seq;
> +=09=09=09tp->selective_acks[0].start_seq =3D seq;
> +=09=09=09tp->selective_acks[0].end_seq =3D end_seq;

>  =09=09}
> -=09=09__skb_queue_head(&tp->out_of_order_queue, skb);
> +=09=09rb_link_node(&skb->rbnode, NULL, p);
> +=09=09rb_insert_color(&skb->rbnode, &tp->out_of_order_queue);
> +=09=09tp->ooo_last_skb =3D skb;
>  =09=09goto end;
>  =09}
> =20
> -=09seq =3D TCP_SKB_CB(skb)->seq;
> -=09end_seq =3D TCP_SKB_CB(skb)->end_seq;

I hate to nitpick but moving these variables earlier and the=20
TCP_SKB_CB(skb)->seq/end_seq simplifications seem unrelated and
could be done in another patch?

> @@ -4830,43 +4876,43 @@ restart:
>  static void tcp_collapse_ofo_queue(struct sock *sk)
>  {
>  =09struct tcp_sock *tp =3D tcp_sk(sk);
> -=09struct sk_buff *skb =3D skb_peek(&tp->out_of_order_queue);
> -=09struct sk_buff *head;
> +=09struct sk_buff *skb, *head;
> +=09struct rb_node *p;
>  =09u32 start, end;
> =20
> -=09if (!skb)
> +=09p =3D rb_first(&tp->out_of_order_queue);
> +=09skb =3D rb_entry_safe(p, struct sk_buff, rbnode);
> +new_range:
> +=09if (!skb) {
> +=09=09p =3D rb_last(&tp->out_of_order_queue);
> +=09=09/* Note: This is possible p is NULL here. We do not
> +=09=09 * use rb_entry_safe(), as ooo_last_skb is valid only
> +=09=09 * if rbtree is not empty.
> +=09=09 */
> +=09=09tp->ooo_last_skb =3D rb_entry(p, struct sk_buff, rbnode);
>  =09=09return;
> -
> +=09}
>  =09start =3D TCP_SKB_CB(skb)->seq;
>  =09end =3D TCP_SKB_CB(skb)->end_seq;
> -=09head =3D skb;
> -
> -=09for (;;) {
> -=09=09struct sk_buff *next =3D NULL;
> =20
> -=09=09if (!skb_queue_is_last(&tp->out_of_order_queue, skb))
> -=09=09=09next =3D skb_queue_next(&tp->out_of_order_queue, skb);
> -=09=09skb =3D next;
> +=09for (head =3D skb;;) {
> +=09=09skb =3D tcp_skb_next(skb, NULL);
> =20
> -=09=09/* Segment is terminated when we see gap or when
> -=09=09 * we are at the end of all the queue. */
> +=09=09/* Range is terminated when we see a gap or when
> +=09=09 * we are at the queue end.
> +=09=09 */
>  =09=09if (!skb ||
>  =09=09    after(TCP_SKB_CB(skb)->seq, end) ||
>  =09=09    before(TCP_SKB_CB(skb)->end_seq, start)) {
> -=09=09=09tcp_collapse(sk, &tp->out_of_order_queue,
> +=09=09=09tcp_collapse(sk, NULL, &tp->out_of_order_queue,
>  =09=09=09=09     head, skb, start, end);
> -=09=09=09head =3D skb;
> -=09=09=09if (!skb)
> -=09=09=09=09break;
> -=09=09=09/* Start new segment */
> +=09=09=09goto new_range;
> +=09=09}
> +
> +=09=09if (unlikely(before(TCP_SKB_CB(skb)->seq, start)))
>  =09=09=09start =3D TCP_SKB_CB(skb)->seq;
> +=09=09if (after(TCP_SKB_CB(skb)->end_seq, end))
>  =09=09=09end =3D TCP_SKB_CB(skb)->end_seq;
> -=09=09} else {
> -=09=09=09if (before(TCP_SKB_CB(skb)->seq, start))
> -=09=09=09=09start =3D TCP_SKB_CB(skb)->seq;
> -=09=09=09if (after(TCP_SKB_CB(skb)->end_seq, end))
> -=09=09=09=09end =3D TCP_SKB_CB(skb)->end_seq;
> -=09=09}
>  =09}
>  }

I tried long to think if I could propose alternative layout which would=20
make this function to exit from the end but couldn't come up anything=20
sensible. As is, it's always exiting within that top if block which is
somewhat unintuitive :-).

Acked-By: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki>

--=20
 i.
--=_script-11482-1473332572-0001-2--
