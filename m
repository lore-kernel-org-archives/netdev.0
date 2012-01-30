From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Sundance network driver (D-Link DFE-580TX) timeouts rendering
 interface unusable
Date: Mon, 30 Jan 2012 11:36:03 +0100
Message-ID: <1327919763.2288.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <SNT141-W3553B2629FBBC84A5A140596860@phx.gbl>
	 <1327205171.8004.96.camel@deadeye>
	 <SNT141-W5087B9A5022955EA5564DB96890@phx.gbl>
	 <20120126220640.GO12704@decadent.org.uk>
	 <SNT141-W58AC5ADD0BC9DE29AFA00D968E0@phx.gbl>
	 <1327811546.5400.291.camel@deadeye>
	 <CAHj3AVm8cjkj83QHGAqOji6t4uWFr6jAAADu7vLKyfEORk1LoA@mail.gmail.com>
	 <1327918447.2288.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <ben@decadent.org.uk>,
	"Mike ." <mike-bugreport@hotmail.com>, 656476@bugs.debian.org,
	netdev <netdev@vger.kernel.org>
To: Denis Kirjanov <kirjanov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:64948 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752028Ab2A3KgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 05:36:08 -0500
Received: by lagu2 with SMTP id u2so2093100lag.19
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 02:36:07 -0800 (PST)
In-Reply-To: <1327918447.2288.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 30 janvier 2012 =C3=A0 11:14 +0100, Eric Dumazet a =C3=A9crit =
:
> Le lundi 30 janvier 2012 =C3=A0 12:51 +0300, Denis Kirjanov a =C3=A9c=
rit :
> > I'll check this out. After kernel.org was cracked I've missed
> > @kernel.org mail account.
>=20
>=20
> At first glance, start_tx() is racy against TX completion.
>=20
> It does :
>=20
>         if (np->cur_tx - np->dirty_tx < TX_QUEUE_LEN - 1 &&
>             !netif_queue_stopped(dev)) {
>                 /* do nothing */
>         } else {
>                 netif_stop_queue (dev);
>         }
>=20
> So it can call netif_stop_queue() while TX completion handler did a
> cleanup of all queued packets right before.
>=20
>=20
> Note intr_handler() doesnt hold the queue spinlock when it does :
>=20
>                 if (netif_queue_stopped(dev) &&
>                         np->cur_tx - np->dirty_tx < TX_QUEUE_LEN - 4)=
 {
>                         /* The ring is no longer full, clear busy fla=
g. */
>                         netif_wake_queue (dev);
>                 }
>=20

So I would try following patch :

 drivers/net/ethernet/dlink/sundance.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/dlink/sundance.c b/drivers/net/ethern=
et/dlink/sundance.c
index 28a3a9b..c671a6c 100644
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
