From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] net: release dst entry in dev_queue_xmit()
Date: Wed, 25 Mar 2009 19:41:27 +0100
Message-ID: <49CA7AD7.8040401@cosmosbay.com>
References: <49C380A6.4000904@cosmosbay.com>	<20090324.234354.43714160.davem@davemloft.net>	<49C9D99A.2040900@cosmosbay.com> <20090325.001720.238121238.davem@davemloft.net> <49CA7658.4010400@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50423 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763487AbZCYSlh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 14:41:37 -0400
In-Reply-To: <49CA7658.4010400@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> David Miller wrote, On 03/25/2009 08:17 AM:
>=20
>> From: Eric Dumazet <dada1@cosmosbay.com>
>> Date: Wed, 25 Mar 2009 08:13:30 +0100
>>
>>> If done in dev_hard_start_xmit(), skb could be requeued (because of
>>> NETDEV_TX_BUSY).  Then if requeued, maybe at this time, dst being
>>> NULL is not a problem ?
>> Usually it should be OK because the packet schedulers have
>> a sort-of one-behind state that allows them to reinsert
>> the SKB into their queue datastructures without reclassifying.
>=20
>=20
> Actually, since David has dumped requeuing there is no reinserting;
> this last one "requeued" skb is buffered at the top in q->gso_skb
> and waiting for better times.

Yes indeed, this is what I thought too, thanks Jarek.

I tested following patch today on my machine, but obviously could not t=
ry=20
all possible quirks :)

[PATCH] net: release dst entry in dev_hard_start_xmit()

One point of contention in high network loads is the dst_release() perf=
ormed
when a transmited skb is freed. This is because NIC tx completion calls=
 skb free
long after original call to dev_queue_xmit(skb).

CPU cache is cold and the atomic op in dst_release() stalls. On SMP, th=
is is
quite visible if one CPU is 100% handling softirqs for a network device=
,
since dst_clone() is done by other cpus, involving cache line ping pong=
s.

I believe we can release dst in dev_hard_start_xmit(), while cpu cache =
is hot, since
caller of dev_queue_xmit() had to hold a reference on dst right before.=
 This reduce
work to be done by softirq handler, and decrease cache misses.

I also believe only pktgen can call dev_queue_xmit() with skb which hav=
e
a skb->users !=3D 1. But pkthen skbs have a NULL dst entry.

I added a WARN_ON_ONCE() to catch other cases, and not release skb->dst
if skb->users !=3D 1

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/net/core/dev.c b/net/core/dev.c
index e3fe5c7..a622db6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1664,6 +1664,26 @@ static int dev_gso_segment(struct sk_buff *skb)
 	return 0;
 }
=20
+
+/*
+ * Release dst while its refcnt is likely hot in CPU cache, instead
+ * of waiting NIC tx completion.
+ * We inline dst_release() code for performance reason
+ */
+static void release_skb_dst(struct sk_buff *skb)
+{
+	if (likely(skb->dst)) {
+		if (!WARN_ON_ONCE(atomic_read(&skb->users) !=3D 1)) {
+			int newrefcnt;
+
+			smp_mb__before_atomic_dec();
+			newrefcnt =3D atomic_dec_return(&skb->dst->__refcnt);
+			WARN_ON(newrefcnt < 0);
+			skb->dst =3D NULL;
+		}
+	}
+}
+
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq)
 {
@@ -1681,6 +1701,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, stru=
ct net_device *dev,
 				goto gso;
 		}
=20
+		release_skb_dst(skb);
 		return ops->ndo_start_xmit(skb, dev);
 	}
=20
@@ -1691,6 +1712,7 @@ gso:
=20
 		skb->next =3D nskb->next;
 		nskb->next =3D NULL;
+		release_skb_dst(nskb);
 		rc =3D ops->ndo_start_xmit(nskb, dev);
 		if (unlikely(rc)) {
 			nskb->next =3D skb->next;

