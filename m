From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Sundance network driver (D-Link DFE-580TX) timeouts rendering
 interface unusable
Date: Mon, 30 Jan 2012 16:21:40 +0100
Message-ID: <1327936900.2297.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <SNT141-W3553B2629FBBC84A5A140596860@phx.gbl>
	 <1327205171.8004.96.camel@deadeye>
	 <SNT141-W5087B9A5022955EA5564DB96890@phx.gbl>
	 <20120126220640.GO12704@decadent.org.uk>
	 <SNT141-W58AC5ADD0BC9DE29AFA00D968E0@phx.gbl>
	 <1327811546.5400.291.camel@deadeye>
	 <CAHj3AVm8cjkj83QHGAqOji6t4uWFr6jAAADu7vLKyfEORk1LoA@mail.gmail.com>
	 <1327918447.2288.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1327932311.5400.429.camel@deadeye>
	 <1327933736.2288.41.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1327934477.5400.448.camel@deadeye>
	 <1327935455.2297.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Denis Kirjanov <kirjanov@gmail.com>,
	"Mike ." <mike-bugreport@hotmail.com>, 656476@bugs.debian.org,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38806 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753086Ab2A3PVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 10:21:44 -0500
Received: by bkas6 with SMTP id s6so3269493bka.19
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 07:21:43 -0800 (PST)
In-Reply-To: <1327935455.2297.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 30 janvier 2012 =C3=A0 15:57 +0100, Eric Dumazet a =C3=A9crit =
:

> Hmm, TX _completion_ is not run from tasklet but hardware IRQ, this i=
s
> why I added the spin_lock_irqsave().
>=20
>=20
> Tasklet fires the TX, but hardware IRQ does the TX completion part.
>=20
> This driver is ... interesting :)
>=20

Oh well, we also must make sure we held np->lock in TX completion when
doing our test to eventually call netif_wake_queue(), I missed it was
released too early.

here is a more complete patch.

diff --git a/drivers/net/ethernet/dlink/sundance.c b/drivers/net/ethern=
et/dlink/sundance.c
index 28a3a9b..d5e9472 100644
--- a/drivers/net/ethernet/dlink/sundance.c
+++ b/drivers/net/ethernet/dlink/sundance.c
@@ -1099,11 +1099,13 @@ start_tx (struct sk_buff *skb, struct net_devic=
e *dev)
 	tasklet_schedule(&np->tx_tasklet);
=20
 	/* On some architectures: explicitly flush cache lines here. */
-	if (np->cur_tx - np->dirty_tx < TX_QUEUE_LEN - 1 &&
-	    !netif_queue_stopped(dev)) {
-		/* do nothing */
-	} else {
-		netif_stop_queue (dev);
+	if (np->cur_tx - np->dirty_tx >=3D TX_QUEUE_LEN - 1) {
+		unsigned long flags;
+
+		spin_lock_irqsave(&np->lock, flags);
+		if (np->cur_tx - np->dirty_tx >=3D TX_QUEUE_LEN - 1)
+			netif_stop_queue(dev);
+		spin_unlock_irqrestore(&np->lock, flags);
 	}
 	if (netif_msg_tx_queued(np)) {
 		printk (KERN_DEBUG
@@ -1242,8 +1244,8 @@ static irqreturn_t intr_handler(int irq, void *de=
v_instance)
 			hw_frame_id =3D ioread8(ioaddr + TxFrameId);
 		}
=20
+		spin_lock(&np->lock);
 		if (np->pci_dev->revision >=3D 0x14) {
-			spin_lock(&np->lock);
 			for (; np->cur_tx - np->dirty_tx > 0; np->dirty_tx++) {
 				int entry =3D np->dirty_tx % TX_RING_SIZE;
 				struct sk_buff *skb;
@@ -1267,9 +1269,7 @@ static irqreturn_t intr_handler(int irq, void *de=
v_instance)
 				np->tx_ring[entry].frag[0].addr =3D 0;
 				np->tx_ring[entry].frag[0].length =3D 0;
 			}
-			spin_unlock(&np->lock);
 		} else {
-			spin_lock(&np->lock);
 			for (; np->cur_tx - np->dirty_tx > 0; np->dirty_tx++) {
 				int entry =3D np->dirty_tx % TX_RING_SIZE;
 				struct sk_buff *skb;
@@ -1286,7 +1286,6 @@ static irqreturn_t intr_handler(int irq, void *de=
v_instance)
 				np->tx_ring[entry].frag[0].addr =3D 0;
 				np->tx_ring[entry].frag[0].length =3D 0;
 			}
-			spin_unlock(&np->lock);
 		}
=20
 		if (netif_queue_stopped(dev) &&
@@ -1294,6 +1293,7 @@ static irqreturn_t intr_handler(int irq, void *de=
v_instance)
 			/* The ring is no longer full, clear busy flag. */
 			netif_wake_queue (dev);
 		}
+		spin_unlock(&np->lock);
 		/* Abnormal error summary/uncommon events handlers. */
 		if (intr_status & (IntrPCIErr | LinkChange | StatsMax))
 			netdev_error(dev, intr_status);
