From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: 2.6.24-rc4-mm1 - BUG in tcp_fragment
Date: Fri, 14 Dec 2007 07:52:10 +0100
Message-ID: <4762281A.8000600@fr.ibm.com>
References: <20071204211701.994dfce6.akpm@linux-foundation.org> <47616FA6.1010607@fr.ibm.com> <Pine.LNX.4.64.0712140024360.12376@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:1466 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752343AbXLNGwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 01:52:46 -0500
In-Reply-To: <Pine.LNX.4.64.0712140024360.12376@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> On Thu, 13 Dec 2007, Cedric Le Goater wrote:
>=20
>> I got this one while compiling on NFS.
>>
>> C.
>>
>> kernel BUG at /home/legoater/linux/2.6.24-rc4-mm1/include/net/tcp.h:=
1480!
>=20
> I'm not exactly sure what patches you have applied and which patches =
are=20
> not, with rc4-mm1 there are two patches (first one was incomplete, I=20
> assume you had at least that one based on your other mail) to really =
fix=20
> the issues in (__|)tcp_reset_fack_counts(...).=20

Yes I only have the first patch you sent on lkml on top of 2.6.24-rc4-m=
m1.
attached below. I didn't see the second one on lkml ? =20

> However, there seems to be so much breakage that I have a bit trouble=
 to=20
> decide where to start... The situation seems bit scary :-).

my n/w environment seems to reproduce these issues quite easily. if you
need some testing, just ping me.

Cheers,

C.=20

> So, I might soon prepare a revert patch for most of the questionable=20
> TCP parts and ask Dave to apply it (and drop them fully during next=20
> rebase) unless I suddently figure something out soon which explains=20
> all/most of the problems, then return to drawing board. ...As it seem=
s=20
> that the cumulative ACK processing problem discovered later on (havin=
g=20
> rather cumbersome solution with skbs only) will make part of the work=
=20
> that's currently in net-2.6.25 quite useless/duplicate effort. But th=
anks=20
> anyway for reporting these.
>=20
>=20

Subject: [PATCH] [TCP]: Fix fack_count miscountings (multiple places)

1) Fack_count is set incorrectly if the highest sent skb is
already sacked (the skb->prev won't return it because it's on
the other list already). These manifest as fackets_out counting
error later on, the second-order effects are very hard to track,
so it may fix all out-standing TCP bug reports.

2) Prev =3D=3D NULL check was wrong way around

3) Last skb's fack count was incorrectly skipped while() {} loop

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h |   22 ++++++++++++++++------
 1 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 9dbed0b..11a7e3e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1337,10 +1337,20 @@ static inline struct sk_buff *tcp_send_head(str=
uct sock *sk)
 static inline void tcp_advance_send_head(struct sock *sk, struct sk_bu=
ff *skb)
 {
        struct sk_buff *prev =3D tcp_write_queue_prev(sk, skb);
+       unsigned int fc =3D 0;
+
+       if (prev =3D=3D (struct sk_buff *)&sk->sk_write_queue)
+               prev =3D NULL;
+       else if (!tcp_skb_adjacent(sk, prev, skb))
+               prev =3D NULL;
=20
-       if (prev !=3D (struct sk_buff *)&sk->sk_write_queue)
-               TCP_SKB_CB(skb)->fack_count =3D TCP_SKB_CB(prev)->fack_=
count +
-                                             tcp_skb_pcount(prev);
+       if ((prev =3D=3D NULL) && !__tcp_write_queue_empty(sk, TCP_WQ_S=
ACKED))
+               prev =3D __tcp_write_queue_tail(sk, TCP_WQ_SACKED);
+
+       if (prev !=3D NULL)
+               fc =3D TCP_SKB_CB(prev)->fack_count + tcp_skb_pcount(pr=
ev);
+
+       TCP_SKB_CB(skb)->fack_count =3D fc;
=20
        sk->sk_send_head =3D tcp_write_queue_next(sk, skb);
        if (sk->sk_send_head =3D=3D (struct sk_buff *)&sk->sk_write_que=
ue)
@@ -1464,7 +1474,7 @@ static inline struct sk_buff *__tcp_reset_fack_co=
unts(struct sock *sk,
 {
        unsigned int fc =3D 0;
=20
-       if (prev =3D=3D NULL)
+       if (prev !=3D NULL)
                fc =3D TCP_SKB_CB(*prev)->fack_count + tcp_skb_pcount(*=
prev);
=20
        BUG_ON((*prev !=3D NULL) && !tcp_skb_adjacent(sk, *prev, skb));
@@ -1521,7 +1531,7 @@ static inline void tcp_reset_fack_counts(struct s=
ock *sk, struct sk_buff *inskb)
                skb[otherq] =3D prev->next;
        }
=20
-       while (skb[queue] !=3D __tcp_write_queue_tail(sk, queue)) {
+       do {
                /* Lazy find for the other queue */
                if (skb[queue] =3D=3D NULL) {
                        skb[queue] =3D tcp_write_queue_find(sk, TCP_SKB=
_CB(prev)->seq,
@@ -1535,7 +1545,7 @@ static inline void tcp_reset_fack_counts(struct s=
ock *sk, struct sk_buff *inskb)
                        break;
=20
                queue ^=3D TCP_WQ_SACKED;
-       }
+       } while (skb[queue] !=3D __tcp_write_queue_tail(sk, queue));
 }
=20
 static inline void __tcp_insert_write_queue_after(struct sk_buff *skb,
-- 1.5.0.6
