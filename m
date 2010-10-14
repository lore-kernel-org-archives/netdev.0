From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Nested GRE locking bug
Date: Thu, 14 Oct 2010 06:11:59 +0200
Message-ID: <1287029519.2649.108.camel@edumazet-laptop>
References: <1287028842.11178.68.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Beatrice Barbe <beatrice.barbe@gmail.com>,
	599816@bugs.debian.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51022 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750732Ab0JNEMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 00:12:21 -0400
Received: by wyb28 with SMTP id 28so1740523wyb.19
        for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 21:12:20 -0700 (PDT)
In-Reply-To: <1287028842.11178.68.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 14 octobre 2010 =C3=A0 05:00 +0100, Ben Hutchings a =C3=A9crit=
 :
> Beatrice Barbe reported a reproducible crash after creating large
> numbers of nested GRE tunnels and then pinging with the source addres=
s
> forced.  I was able to reproduce this using net-2.6.  I'm attaching t=
he
> kernel config I used and a script to reproduce this based on the scri=
pt
> she provided.  The magic number of tunnels to create is apparently 37=
=2E
>=20
> With lockdep enabled, I get the following output:
>=20

Thats a known problem, actually, called stack exhaustion :)

net-next-2.6 contains a fix for this, adding the perc_cpu xmit_recursio=
n
limit. We might push it to net-2.6

Thanks

commit 745e20f1b626b1be4b100af5d4bf7b3439392f8f
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Wed Sep 29 13:23:09 2010 -0700

    net: add a recursion limit in xmit path
   =20
    As tunnel devices are going to be lockless, we need to make sure a
    misconfigured machine wont enter an infinite loop.
   =20
    Add a percpu variable, and limit to three the number of stacked xmi=
ts.
   =20
    Reported-by: Jesse Gross <jesse@nicira.com>
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

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


