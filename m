From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] b44: netpoll locking fix
Date: Tue, 29 May 2007 15:30:33 -0700
Message-ID: <20070529153033.0230974f@freepuppy>
References: <20070529211458.GA31200@electric-eye.fr.zoreil.com>
	<20070529142734.3de0ef4f@freepuppy>
	<20070529222041.GB31200@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gary Zambrano <zambrano@broadcom.com>, jgarzik@pobox.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:45670 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750987AbXE2Wkb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2007 18:40:31 -0400
In-Reply-To: <20070529222041.GB31200@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 30 May 2007 00:20:41 +0200
=46rancois Romieu <romieu@fr.zoreil.com> wrote:

> Stephen Hemminger <shemminger@linux-foundation.org> :
> =E2=85=9C...]
> > Better to just get rid of using the lock as a transmit lock and
> > use netif_tx_lock instead.
> > --- a/drivers/net/b44.c	2007-05-29 09:51:43.000000000 -0700
> > +++ b/drivers/net/b44.c	2007-05-29 14:26:03.000000000 -0700
> > @@ -607,6 +607,7 @@ static void b44_tx(struct b44 *bp)
> >  {
> >  	u32 cur, cons;
> > =20
> > +	netif_tx_lock(bp->dev);
> >  	cur  =3D br32(bp, B44_DMATX_STAT) & DMATX_STAT_CDMASK;
> >  	cur /=3D sizeof(struct dma_desc);
> > =20
>=20
> (damn, you are quick)
>=20
> I am not completely convinced.
>=20
> 1. netpoll_send_skb (calls netif_tx_trylock(dev))
>    -> netpoll_poll(np)
>       -> poll_napi(np)
>          -> np->dev->poll(np->dev, &budget) ( =3D=3D b44_poll)
>             -> b44_tx
>                -> netif_tx_lock(bp->dev) *deadlock*

Netpoll needs to be fixed. (or scrapped), as is it will break drivers
trying to use tx_lock in poll routine. I know sky2 would get borked.

Something like this:


--- a/net/core/netpoll.c	2007-05-08 14:19:32.000000000 -0700
+++ b/net/core/netpoll.c	2007-05-29 15:28:22.000000000 -0700
@@ -250,22 +250,23 @@ static void netpoll_send_skb(struct netp
 		unsigned long flags;
=20
 		local_irq_save(flags);
-		if (netif_tx_trylock(dev)) {
-			/* try until next clock tick */
-			for (tries =3D jiffies_to_usecs(1)/USEC_PER_POLL;
-					tries > 0; --tries) {
+		/* try until next clock tick */
+		for (tries =3D jiffies_to_usecs(1)/USEC_PER_POLL;
+		     tries > 0; --tries) {
+			if (netif_tx_trylock(dev)) {
 				if (!netif_queue_stopped(dev))
 					status =3D dev->hard_start_xmit(skb, dev);
+				netif_tx_unlock(dev);
=20
 				if (status =3D=3D NETDEV_TX_OK)
 					break;
=20
-				/* tickle device maybe there is some cleanup */
-				netpoll_poll(np);
-
-				udelay(USEC_PER_POLL);
 			}
-			netif_tx_unlock(dev);
+
+			/* tickle device maybe there is some cleanup */
+			netpoll_poll(np);
+
+			udelay(USEC_PER_POLL);
 		}
 		local_irq_restore(flags);
 	}
