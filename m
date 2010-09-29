From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: add a recursion limit in xmit path
Date: Wed, 29 Sep 2010 21:04:32 +0200
Message-ID: <1285787072.2813.333.camel@edumazet-laptop>
References: <1285664747.2607.48.camel@edumazet-laptop>
	 <AANLkTinCz_0jHsMYW9_Wko78i9U20qefFbTYCQQQ-pz5@mail.gmail.com>
	 <1285785794.2813.292.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:59684 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755054Ab0I2TEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 15:04:38 -0400
Received: by fxm4 with SMTP id 4so177008fxm.19
        for <netdev@vger.kernel.org>; Wed, 29 Sep 2010 12:04:37 -0700 (PDT)
In-Reply-To: <1285785794.2813.292.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 29 septembre 2010 =C3=A0 20:43 +0200, Eric Dumazet a =C3=A9=
crit :
> Le mercredi 29 septembre 2010 =C3=A0 10:33 -0700, Jesse Gross a =C3=A9=
crit :
>=20
> > The tx lock has another use here: to break local loops.  With this
> > change, a misconfigured tunnel can bring down the machine with a st=
ack
> > overflow.  There are clearly other ways to fix this that don't requ=
ire
> > a lock that restricts parallelism, such as a loop counter, but that=
's
> > the way it is now.
>=20
> Thats a very good point !
>=20
> We could use a loop counter in the skb, but this use a bit of ram,
> or percpu counters in tunnel drivers, to avoid a given level of
> recursion.
>=20
> /* this should be shared by all tunnels */
> DEFINE_PER_CPU(tunnel_xmit_count);
>=20
>=20
>=20
> tunnel_xmit()
> {
> if (__this_cpu_read(tunnel_xmit_count) >=3D LIMIT)
> 	goto tx_error;
> __this_cpu_inc(tunnel_xmit_count);
>=20
> ....
>=20
> __IPTUNNEL_XMIT(tstats, &dev->stats);
>=20
> __this_cpu_dec(tunnel_xmit_count),
> return NETDEV_TX_OK;
>=20
> }
>=20
>=20

This can be handled generically in net/core/dev.c

David, if you accept the lockless patches, please apply this one
before ;)

Thanks !

[PATCH net-next-2.6] net: add a recursion limit in xmit path

As tunnel devices are going to be lockless, we need to make sure a
misconfigured machine wont enter an infinite loop.

Add a percpu variable, and limit to three the number of stacked xmits.

Reported-by: Jesse Gross <jesse@nicira.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c |   12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 48ad47f..50dacca 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2177,6 +2177,9 @@ static inline int __dev_xmit_skb(struct sk_buff *=
skb, struct Qdisc *q,
 	return rc;
 }
=20
+static DEFINE_PER_CPU(int, xmit_recursion);
+#define RECURSION_LIMIT 3
+
 /**
  *	dev_queue_xmit - transmit a buffer
  *	@skb: buffer to transmit
@@ -2242,10 +2245,15 @@ int dev_queue_xmit(struct sk_buff *skb)
=20
 		if (txq->xmit_lock_owner !=3D cpu) {
=20
+			if (__this_cpu_read(xmit_recursion) > RECURSION_LIMIT)
+				goto recursion_alert;
+
 			HARD_TX_LOCK(dev, txq, cpu);
=20
 			if (!netif_tx_queue_stopped(txq)) {
+				__this_cpu_inc(xmit_recursion);
 				rc =3D dev_hard_start_xmit(skb, dev, txq);
+				__this_cpu_dec(xmit_recursion);
 				if (dev_xmit_complete(rc)) {
 					HARD_TX_UNLOCK(dev, txq);
 					goto out;
@@ -2257,7 +2265,9 @@ int dev_queue_xmit(struct sk_buff *skb)
 				       "queue packet!\n", dev->name);
 		} else {
 			/* Recursion is detected! It is possible,
-			 * unfortunately */
+			 * unfortunately
+			 */
+recursion_alert:
 			if (net_ratelimit())
 				printk(KERN_CRIT "Dead loop on virtual device "
 				       "%s, fix it urgently!\n", dev->name);


