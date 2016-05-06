From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] netdev: enc28j60 kernel panic fix.
Date: Fri, 6 May 2016 22:35:46 +0200
Message-ID: <20160506203546.GA10067@electric-eye.fr.zoreil.com>
References: <CAEGHc+xdoSVa9J_uYm-Az7n4xc+mycy7Jf1p75pss3eVK3jUHA@mail.gmail.com>
 <20160505085110.GA29858@electric-eye.fr.zoreil.com>
 <CAEGHc+ymc3uY0C0WhjfEo5RoS-bQ7h7f6tbBQpAGEJ=D9rr6FA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Russell <david@aprsworld.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40448 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758397AbcEFUfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 16:35:48 -0400
Content-Disposition: inline
In-Reply-To: <CAEGHc+ymc3uY0C0WhjfEo5RoS-bQ7h7f6tbBQpAGEJ=D9rr6FA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(please don't top post)

David Russell <david@aprsworld.com> :
> I kind of thought my patch was at best incomplete.  When you state
> this change silences the bug but does not fix it, what are the
> implications of systems running this patch?  We have some production
> systems using this patch.  They reboot daily, but have been solid.

If my assumption is right it should drop an extra packet here and there.
No leak.

However transmit errors + transmit packets should still match the number
of times the driver calls enc28j60_send_packet (you would have to cook
your own stat to check the latter though).

> In addition, if we sent you a pi and the ethernet controller and a
> small but reasonable sum of money for your labor, would you be able to
> properly fix it ?

I'd rather see you testing my crap. :o)

Pi as multi-core (the expected race needs several cores or a netconsole
style transmit from an irq/bh context) ?

> Short of that, do you have any recommendations on quick overviews of
> the networking stack in the kernel and then documentation on the
> various flags and such?

A tad bit too high-level a question... Plain ctags + printk for a start ?

Does the patch below make a difference ?

Takes longer to crash counts as a difference.

diff --git a/drivers/net/ethernet/microchip/enc28j60.c b/drivers/net/ethernet/microchip/enc28j60.c
index 7066954..405fe3f 100644
--- a/drivers/net/ethernet/microchip/enc28j60.c
+++ b/drivers/net/ethernet/microchip/enc28j60.c
@@ -1170,7 +1170,8 @@ static void enc28j60_irq_work_handler(struct work_struct *work)
 				enc28j60_dump_tsv(priv, "Tx Done", tsv);
 			}
 			enc28j60_tx_clear(ndev, err);
-			locked_reg_bfclr(priv, EIR, EIR_TXIF);
+			locked_reg_bfclr(priv, EIR, EIR_TXIF | EIR_TXERIF);
+			intflags &= ~EIR_TXERIF;
 		}
 		/* TX Error handler */
 		if ((intflags & EIR_TXERIF) != 0) {
@@ -1190,6 +1191,7 @@ static void enc28j60_irq_work_handler(struct work_struct *work)
 			nolock_reg_bfclr(priv, ECON1, ECON1_TXRST);
 			nolock_txfifo_init(priv, TXSTART_INIT, TXEND_INIT);
 			mutex_unlock(&priv->lock);
+			locked_reg_bfclr(priv, EIR, EIR_TXIF | EIR_TXERIF);
 			/* Transmit Late collision check for retransmit */
 			if (TSV_GETBIT(tsv, TSV_TXLATECOLLISION)) {
 				if (netif_msg_tx_err(priv))
@@ -1203,7 +1205,6 @@ static void enc28j60_irq_work_handler(struct work_struct *work)
 					enc28j60_tx_clear(ndev, true);
 			} else
 				enc28j60_tx_clear(ndev, true);
-			locked_reg_bfclr(priv, EIR, EIR_TXERIF);
 		}
 		/* RX Error handler */
 		if ((intflags & EIR_RXERIF) != 0) {
