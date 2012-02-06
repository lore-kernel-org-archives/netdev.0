From: "Tim Sander" <tim.sander@hbm.com>
Subject: [PATCH]Re: [PATCH] net/fec: infinite spin on sirq-net-tx on real-time
Date: Mon, 6 Feb 2012 14:43:39 +0100
Message-ID: <201202061443.39668.tim.sander@hbm.com>
References: <1328520810-28030-1-git-send-email-hector.palacios@digi.com> <4F2FB39B.9010205@digi.com> <1328532924.2220.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/Plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Hector Palacios" <hector.palacios@digi.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	<shawn.guo@linaro.org>, <jgq516@gmail.com>, <rostedt@goodmis.org>,
	<u.kleine-koenig@pengutronix.de>, <tglx@linutronix.de>,
	"Zeng Zhaoming" <b32542@freescale.com>,
	"Frank Li" <Frank.Li@freescale.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.medianet-world.de ([213.157.0.172]:10302 "HELO
	relay.medianet-world.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753420Ab2BFNvQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 08:51:16 -0500
Content-Class: urn:content-classes:message
In-reply-to: <1328532924.2220.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi=20

I just reworked the driver according to Eric's suggestions.
It passes first smoke tests. I don't know how to test the out of memory=
 path.

Am Montag, 6. Februar 2012, 13:55:24 schrieb Eric Dumazet:
> Le lundi 06 f=C3=A9vrier 2012 =C3=A0 12:03 +0100, Hector Palacios a =C3=
=A9crit :
> > I'm no network driver expert so I'll leave it up to others to comme=
nt. I
> > just forward ported a patch I came across in Freescale's BSP which
> > solves the problem in mainline and in RT.
>=20
> I understood you didnt write the patch alone, and my question was
> addressed to all people involved, not only to you.
>=20
> FEC driver needs some bugfixes, before diverging too much from the st=
ate
> of the art.
>=20
> For example, fec_enet_alloc_buffers()  doesnt check for allocation
> failures :
>=20
> fep->tx_bounce[i] =3D kmalloc(FEC_ENET_TX_FRSIZE, GFP_KERNEL);
>=20
> NULL dereferences are then possible later in fec_enet_start_xmit()
>=20
> By the way, I am not even sure kmalloc(2048) has a guarantee on
> alignement of the result, depending on the slub/slab debugging option=
s.
I have not taken care of the alignment issue mentioned.

> If softirqd is a real time task, an inifinite spin is hit
> if the FEC driver tries to send a packet before the autonegotiation
> with the PHY has completed.
>=20
> This was seen when booting the platform with DHCP on. The driver
> sends the DHCP request before the PHY has completed autonegotiation.
> As a consequence, the driver's dev_hard_start_xmit returns NETDEV_TX_=
BUSY.
> NETDEV_TX_BUSY is part of NET_TX_MASK thus the packet is requeued (th=
e
> skb->next =3D nskb) in dev_hard_start_xmit(). And the NETDEV_TX_BUSY =
is
> passed back to sch_derect_xmit() which calls dev_requeue_skb() which
> then calls __netif_schedule(q) which will call __netif_reschedule(q)
> which will then do raise_softirq_irqoff(NET_TX_SOFTIRQ).
>=20
> Thus, as soon as ksoftirq exits this routine, it will restart the
> process over again. As the fec driver never finished with its
> negotiations, the process starts over again and we never move forward=
=2E
>=20
> Newsgroup reference: linux-rt-users http://www.spinics.net/lists/linu=
x-rt-users/msg07551.html

Signed-of-by: Tim Sander <tim.sander@hbm.com>

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 885d8ba..f69d95f 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -242,11 +242,6 @@ fec_enet_start_xmit(struct sk_buff *skb, struct ne=
t_device *ndev)
        unsigned short  status;
        unsigned long flags;
=20
-       if (!fep->link) {
-               /* Link is down or autonegotiation is in progress. */
-               return NETDEV_TX_BUSY;
-       }
-
        spin_lock_irqsave(&fep->hw_lock, flags);
        /* Fill in a Tx ring entry */
        bdp =3D fep->cur_tx;
@@ -470,6 +465,9 @@ fec_stop(struct net_device *ndev)
        udelay(10);
        writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
        writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
+
+       netif_stop_queue(ndev);
+       fep->link =3D 0;
 }
=20
=20
@@ -787,6 +785,7 @@ static void fec_enet_adjust_link(struct net_device =
*ndev)
        if (phy_dev->link) {
                if (fep->full_duplex !=3D phy_dev->duplex) {
                        fec_restart(ndev, phy_dev->duplex);
+                       netif_wake_queue(ndev);
                        status_change =3D 1;
                }
        }
@@ -1118,6 +1117,13 @@ static int fec_enet_alloc_buffers(struct net_dev=
ice *ndev)
        bdp =3D fep->tx_bd_base;
        for (i =3D 0; i < TX_RING_SIZE; i++) {
                fep->tx_bounce[i] =3D kmalloc(FEC_ENET_TX_FRSIZE, GFP_K=
ERNEL);
+               if(!fep->tx_bounce[i])  {
+                       for(j =3D 0; j < i; j++) {
+                               kfree(fep->tx_bounce[j]);
+                       }
+                       fec_enet_free_buffers(ndev);
+                       return -ENOMEM;
+               }
=20
                bdp->cbd_sc =3D 0;
                bdp->cbd_bufaddr =3D 0;


Hottinger Baldwin Messtechnik GmbH, Im Tiefen See 45, 64293 Darmstadt, =
Germany | www.hbm.com=20

Registered as GmbH (German limited liability corporation) in the commer=
cial register at the local court of Darmstadt, HRB 1147 =20
Company domiciled in Darmstadt | CEO: Andreas Huellhorst | Chairman of =
the board: James Charles Webster

Als Gesellschaft mit beschraenkter Haftung eingetragen im Handelsregist=
er des Amtsgerichts Darmstadt unter HRB 1147=20
Sitz der Gesellschaft: Darmstadt | Geschaeftsfuehrung: Andreas Huellhor=
st | Aufsichtsratsvorsitzender: James Charles Webster

The information in this email is confidential. It is intended solely fo=
r the addressee. If you are not the intended recipient, please let me k=
now and delete this email.

Die in dieser E-Mail enthaltene Information ist vertraulich und ledigli=
ch f=C3=BCr den Empfaenger bestimmt. Sollten Sie nicht der eigentliche =
Empfaenger sein, informieren Sie mich bitte kurz und loeschen diese E-M=
ail.
