From: Tim Sander <tstone@vlsi.informatik.tu-darmstadt.de>
Subject: [PATCH] Re: [PATCH] net/fec: infinite spin on sirq-net-tx on real-time
Date: Tue, 7 Feb 2012 01:48:06 +0100
Message-ID: <201202070148.06411.tstone@vlsi.informatik.tu-darmstadt.de>
References: <1328520810-28030-1-git-send-email-hector.palacios@digi.com> <1328534721.5882.225.camel@gandalf.stny.rr.com> <1328535599.2220.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Hector Palacios <hector.palacios@digi.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"jgq516@gmail.com" <jgq516@gmail.com>,
	"tim.sander@hbm.com" <tim.sander@hbm.com>,
	"u.kleine-koenig@pengutronix.de" <u.kleine-koenig@pengutronix.de>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	Zeng Zhaoming <b32542@freescale.com>,
	Frank Li <Frank.Li@freescale.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lnx141.hrz.tu-darmstadt.de ([130.83.156.236]:54864 "EHLO
	lnx141.hrz.tu-darmstadt.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751341Ab2BGAzs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Feb 2012 19:55:48 -0500
In-Reply-To: <1328535599.2220.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi
Am Montag 06 Februar 2012, 14:39:59 schrieb Eric Dumazet:
> Le lundi 06 f=C3=A9vrier 2012 =C3=A0 08:25 -0500, Steven Rostedt a =C3=
=A9crit :
> > On Mon, 2012-02-06 at 12:03 +0100, Hector Palacios wrote:
> > > >> @@ -530,6 +531,7 @@ fec_stop(struct net_device *ndev)
> > > >>=20
> > > >>   	udelay(10);
> > > >>   	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
> > > >>   	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
> > > >>=20
> > > >> +	fep->link =3D 0;
> > > >=20
> > > > Why not call netif_stop_queue(dev) here ?
> > >=20
> > > I'm no network driver expert so I'll leave it up to others to com=
ment.
> > > I just forward ported a patch I came across in Freescale's BSP wh=
ich
> > > solves the problem in mainline and in RT.
> >=20
> > Hector,
> >=20
> > Eric's suggestion may also work. Could your revert this patch and a=
dd
> > the netif_stop_queue(dev) there, and see if it fixes the problems i=
n
> > both mainline and -rt?
>=20
> Not sure it will be enough to call netif_stop_queue(dev) in fec_stop(=
)
>=20
> We probably need to start the device with its tx queue stopped, then
> later when device is really ready wakeup the queue.
I am talking about 3.0-rt33 kernel since this is the one i can test the=
 best.

Ok i just found out that removing:

        if (!fep->link) {
                /* Link is down or autonegotiation is in progress. */
                netif_stop_queue(ndev);
                return NETDEV_TX_BUSY;
        }
does not seem to work. Also netif_stop_queue seems to be mandantory to =
get the driver working.
If this condition in the hotpath is removed i see the ksoftirq high cpu=
load problem again.
I am not sure if the patch for lines 470 if netif_stop_queue(ndev); is =
really nessary.
I also found an double cleanup in my earlier patch. So heres the next i=
teration of the
fec ksoftirq fix for preempt rt.

Tim

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 885d8ba..140cb13 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -244,6 +244,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net=
_device *ndev)
=20
        if (!fep->link) {
                /* Link is down or autonegotiation is in progress. */
+               netif_stop_queue(ndev);
                return NETDEV_TX_BUSY;
        }
=20
@@ -470,6 +471,9 @@ fec_stop(struct net_device *ndev)
        udelay(10);
        writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
        writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
+
+       netif_stop_queue(ndev);
+       fep->link =3D 0;
 }
=20
=20
@@ -787,6 +791,7 @@ static void fec_enet_adjust_link(struct net_device =
*ndev)
        if (phy_dev->link) {
                if (fep->full_duplex !=3D phy_dev->duplex) {
                        fec_restart(ndev, phy_dev->duplex);
+                       netif_wake_queue(ndev);
                        status_change =3D 1;
                }
        }
@@ -1118,6 +1123,10 @@ static int fec_enet_alloc_buffers(struct net_dev=
ice *ndev)
        bdp =3D fep->tx_bd_base;
        for (i =3D 0; i < TX_RING_SIZE; i++) {
                fep->tx_bounce[i] =3D kmalloc(FEC_ENET_TX_FRSIZE, GFP_K=
ERNEL);
+               if(!fep->tx_bounce[i])  {
+                       fec_enet_free_buffers(ndev);
+                       return -ENOMEM;
+               }
=20
                bdp->cbd_sc =3D 0;
                bdp->cbd_bufaddr =3D 0;
