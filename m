From: "Tim Sander" <tim.sander@hbm.com>
Subject: Re: [PATCH] fec: fix tx bounce handling
Date: Mon, 6 Feb 2012 17:09:31 +0100
Message-ID: <201202061709.31406.tim.sander@hbm.com>
References: <1328520810-28030-1-git-send-email-hector.palacios@digi.com> <1328532924.2220.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1328535883.2220.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
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
Received: from relay.medianet-world.de ([213.157.0.172]:13772 "HELO
	relay.medianet-world.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755407Ab2BFQK0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 11:10:26 -0500
Content-Class: urn:content-classes:message
In-reply-to: <1328535883.2220.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I forward ported the patch i have for 3.0-rt (which was working on a qu=
ick test)=20
to the net-dev  branch with the patch from Eric mixed in.=20

But a quick test revealed that dmesg is full of:
eth0: tx queue full!.
Not good! Any suggestions on this?

Tim

Heres my patch for 3.3:

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/etherne=
t/freescale/fec.c
index 336edd7..74d5865 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -284,11 +284,6 @@ fec_enet_start_xmit(struct sk_buff *skb, struct ne=
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
@@ -319,8 +314,8 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net=
_device *ndev)
        if (((unsigned long) bufaddr) & FEC_ALIGNMENT) {
                unsigned int index;
                index =3D bdp - fep->tx_bd_base;
-               memcpy(fep->tx_bounce[index], skb->data, skb->len);
-               bufaddr =3D fep->tx_bounce[index];
+               bufaddr =3D PTR_ALIGN(fep->tx_bounce[index], FEC_ALIGNM=
ENT + 1);
+               memcpy(bufaddr, skb->data, skb->len);
        }
=20
        /*
@@ -542,6 +537,9 @@ fec_stop(struct net_device *ndev)
                writel(2, fep->hwp + FEC_ECNTRL);
                writel(rmii_mode, fep->hwp + FEC_R_CNTRL);
        }
+
+       netif_stop_queue(ndev);
+       fep->link=3D0;
 }
=20
=20
@@ -1210,7 +1208,7 @@ static int fec_enet_alloc_buffers(struct net_devi=
ce *ndev)
=20
        bdp =3D fep->rx_bd_base;
        for (i =3D 0; i < RX_RING_SIZE; i++) {
-               skb =3D dev_alloc_skb(FEC_ENET_RX_FRSIZE);
+               skb =3D __dev_alloc_skb(FEC_ENET_RX_FRSIZE, GFP_KERNEL)=
;
                if (!skb) {
                        fec_enet_free_buffers(ndev);
                        return -ENOMEM;
@@ -1230,6 +1228,10 @@ static int fec_enet_alloc_buffers(struct net_dev=
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
