From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH RFC 24/30] net: fec: better implementation of iMX6
	ERR006358 quirk
Date: Sun, 22 Jun 2014 09:12:35 +0100
Message-ID: <20140622081234.GB32514@n2100.arm.linux.org.uk>
References: <20140620121118.GR32514@n2100.arm.linux.org.uk> <E1WxxhR-0005YP-Q1@rmk-PC.arm.linux.org.uk> <316b383d2512440db51ea7c55992920d@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:38136 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751274AbaFVIMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2014 04:12:39 -0400
Content-Disposition: inline
In-Reply-To: <316b383d2512440db51ea7c55992920d@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 22, 2014 at 07:49:11AM +0000, fugang.duan@freescale.com wrote:
> From: Russell King <rmk@arm.linux.org.uk> Data: Friday, June 20, 2014 8:14 PM
> >To: linux-arm-kernel@lists.infradead.org
> >Cc: Duan Fugang-B38611; netdev@vger.kernel.org
> >Subject: [PATCH RFC 24/30] net: fec: better implementation of iMX6
> >ERR006358 quirk
> >
> >Using a (delayed) workqueue for ERR006358 is not correct - a work queue is
> >a single-trigger device.  Once the work queue has been scheduled, it can't
> >be re-scheduled until it has been run.  This can cause problems - with an
> >appropriate packet timing, we can end up with packets queued, but not sent
> >by the hardware, resulting in the transmit timeout firing.
> >
> >Re-implement this as per the workaround detailed in the ERR006358
> >documentation - if there are packets waiting to be sent when we service
> >the transmit ring, and we see that the transmitter is not running, kick
> >the transmitter to run the pending entries in the ring.
> >
> >Testing here with a 10Mbit half duplex link sees the resulting iperf TCP
> >bandwidth increase from between 1 to 2Mbps to between 8 to 9Mbps.
> >
> >Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> >---
> > drivers/net/ethernet/freescale/fec.h      |  1 -
> > drivers/net/ethernet/freescale/fec_main.c | 31 +++++---------------------
> >-----
> > 2 files changed, 5 insertions(+), 27 deletions(-)
> >
> >diff --git a/drivers/net/ethernet/freescale/fec.h
> >b/drivers/net/ethernet/freescale/fec.h
> >index 96d2a18f1b99..17e294970207 100644
> >--- a/drivers/net/ethernet/freescale/fec.h
> >+++ b/drivers/net/ethernet/freescale/fec.h
> >@@ -259,7 +259,6 @@ struct bufdesc_ex {
> > struct fec_enet_delayed_work {
> > 	struct delayed_work delay_work;
> > 	bool timeout;
> >-	bool trig_tx;
> > };
> >
> > /* The FEC buffer descriptors track the ring buffers.  The rx_bd_base and
> >diff --git a/drivers/net/ethernet/freescale/fec_main.c
> >b/drivers/net/ethernet/freescale/fec_main.c
> >index 62120e47ef5a..957bb98add5a 100644
> >--- a/drivers/net/ethernet/freescale/fec_main.c
> >+++ b/drivers/net/ethernet/freescale/fec_main.c
> >@@ -342,22 +342,6 @@ fec_enet_clear_csum(struct sk_buff *skb, struct
> >net_device *ndev)
> > 	return 0;
> > }
> >
> >-static void
> >-fec_enet_submit_work(struct bufdesc *bdp, struct fec_enet_private *fep) -
> >{
> >-	const struct platform_device_id *id_entry =
> >-				platform_get_device_id(fep->pdev);
> >-	struct bufdesc *bdp_pre;
> >-
> >-	bdp_pre = fec_enet_get_prevdesc(bdp, fep);
> >-	if ((id_entry->driver_data & FEC_QUIRK_ERR006358) &&
> >-	    !(bdp_pre->cbd_sc & BD_ENET_TX_READY)) {
> >-		fep->delay_work.trig_tx = true;
> >-		schedule_delayed_work(&(fep->delay_work.delay_work),
> >-					msecs_to_jiffies(1));
> >-	}
> >-}
> >-
> > static int
> > fec_enet_txq_submit_frag_skb(struct sk_buff *skb, struct net_device *ndev)
> >{ @@ -545,8 +529,6 @@ static int fec_enet_txq_submit_skb(struct sk_buff
> >*skb, struct net_device *ndev)
> > 	status |= (BD_ENET_TX_READY | BD_ENET_TX_TC);
> > 	bdp->cbd_sc = status;
> >
> >-	fec_enet_submit_work(bdp, fep);
> >-
> > 	/* If this was the last BD in the ring, start at the beginning again.
> >*/
> > 	bdp = fec_enet_get_nextdesc(last_bdp, fep);
> >
> >@@ -735,8 +717,6 @@ static int fec_enet_txq_submit_tso(struct sk_buff *skb,
> >struct net_device *ndev)
> > 	/* Save skb pointer */
> > 	fep->tx_skbuff[index] = skb;
> >
> >-	fec_enet_submit_work(bdp, fep);
> >-
> > 	skb_tx_timestamp(skb);
> > 	fep->cur_tx = bdp;
> >
> >@@ -1065,11 +1045,6 @@ static void fec_enet_work(struct work_struct *work)
> > 		}
> > 		rtnl_unlock();
> > 	}
> >-
> >-	if (fep->delay_work.trig_tx) {
> >-		fep->delay_work.trig_tx = false;
> >-		writel(0, fep->hwp + FEC_X_DES_ACTIVE);
> >-	}
> > }
> >
> > static void
> >@@ -1166,7 +1141,11 @@ fec_enet_tx(struct net_device *ndev)
> > 				netif_wake_queue(ndev);
> > 		}
> > 	}
> >-	return;
> >+
> >+	/* ERR006538: Keep the transmitter going */
> >+	if (fep->dirty_tx != fep->cur_tx &&
> >+	    readl(fep->hwp + FEC_X_DES_ACTIVE) == 0)
> >+		writel(0, fep->hwp + FEC_X_DES_ACTIVE);
> > }
> >
> If fep->dirty_tx == fep->cur_tx, which means tx bd entry is empty, it
> doesn't need to trigger TDAR.

I think you're wrong.  Upon initialisation (which is the empty case
because at initialisation time, the tx ring will be empty), fep->cur_tx
is set to the first tx bd entry, and fep->dirty_tx is set to the
/preceding/ entry.

When a packet is loaded to be transmitted, it is placed in the fep->cur_tx
slot.  In other words, fep->cur_tx points at the tx bd entry which takes
the _next_ packet to be loaded into the ring.

When packets are reaped, the first thing the reaping function does after
reading fep->dirty_tx is increment to the next ring entry.

So, the "ring full" case is fep->dirty_tx == fep->cur_tx, and the "ring
empty" case is next(fep->dirty_tx) == fep->cur_tx.

You've made this mistake in the SG patch, where you miscalculate the ring
free size when fep->dirty_tx == fep->cur_tx, indicating that the ring is
entirely free, when in fact it has no free entries.

> The issue is the last tx frame cannot be trasmited by uDMA since uDMA
> had cleared the TDAR after user write TDAR.
> User					uDMA
> 					Process the previous frame, detect the next BD ready bit,
> 					The next BD ready bit is not set
> Set the next BD ready bit
> Set TDAR
> 					Since the next BD ready bit detected as not set, start to clear TDAR.

Yes, I'm well aware of the mechanism that causes this problem.

> The issue has happened customer product, and was fixed by previous
> workaround.  The issue only happened at little packets transmission.
> Special for command communicate protocol to the other end.

So, please explain to me why, with the current solution, I get:

1. half duplex performance is abismal, to the point that the ethernet
   only achieves about 12-25% of the bandwidth, and jumps massively
   using the solution in this patch (which is as per the workaround
   documented in the errata document.)

2. transmit timeouts when operating in half-duplex mode.

> If you move the extra trigger to tx clean function, you must check:
> bdp_pre = fec_enet_get_prevdesc(fep->cur_tx, fep);
> bdp_next = fec_enet_get_nextdesc(fep->dirty_tx, fep); 
> if (bdp_next == bdp_pre &&
> 	bdp_pre->cbd_sc & BD_ENET_TX_READY &&
> 	readl(fep->hwp + FEC_X_DES_ACTIVE) == 0) 
> 	writel(0, fep->hwp + FEC_X_DES_ACTIVE);

While I agree that we can read back to check whether the device indicates
that transmit is active, there's no point to the other tests.  If there
are entries in the transmit ring but the transmitter indicates that it is
not active, then it is obvious that the bug has been hit.  This is exactly
what my implementation above does.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.
