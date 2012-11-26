From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BQL support in gianfar causes network hickup
Date: Mon, 26 Nov 2012 09:17:35 -0800
Message-ID: <1353950255.7553.6.camel@edumazet-glaptop>
References: <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE6E@Exchange1.lawo.de>
	 <50AFA599.9040108@windriver.com> <loom.20121124T213422-650@post.gmane.org>
	 <1353800616.2590.4562.camel@edumazet-glaptop>
	 <20121126100111.GA3728@mac.home> <1353947677.7553.2.camel@edumazet-glaptop>
	 <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE6F@Exchange1.lawo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tino Keitel <tino.keitel@tikei.de>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Keitel, Tino (ALC NetworX GmbH)" <Tino.Keitel@alcnetworx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:40461 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934195Ab2KZRRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 12:17:38 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so8170150pbc.19
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2012 09:17:38 -0800 (PST)
In-Reply-To: <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE6F@Exchange1.lawo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-11-26 at 18:08 +0100, Keitel, Tino (ALC NetworX GmbH)
wrote:
> On Mo, 2012-11-26 at 08:34 -0800, Eric Dumazet wrote:
> > On Mon, 2012-11-26 at 11:01 +0100, Tino Keitel wrote:
> > > On Sat, Nov 24, 2012 at 15:43:36 -0800, Eric Dumazet wrote:
> > > 
> > > [...]
> > > 
> > > > Hmm, I wonder if BQL makes a particular bug showing more often.
> > > > 
> > > > I see gianfar uses a very small watchdog_timeo of 1 second, while many
> > > > drivers use 5 seconds.
> > > > 
> > > > What happens if you change this to 5 seconds ?
> > > 
> > > I still got the trace and a failing ptp client.
> > > 
> > 
> > Thanks. Is this bug easy to trigger ?
> > 
> > I suspect a core issue and a race, likely to happen on your (non x86)
> > hardware
> > 
> > Could you add the following debugging patch ?
> 
> No visible difference:

OK it seems you trigger the problem fast !

Please try the following as well :

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 19ac096..77190bf 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -101,7 +101,7 @@
 
 #include "gianfar.h"
 
-#define TX_TIMEOUT      (1*HZ)
+#define TX_TIMEOUT      (5*HZ)
 
 const char gfar_driver_version[] = "1.3";
 
@@ -2465,9 +2465,9 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 	struct sk_buff *skb;
 	int skb_dirtytx;
 	int tx_ring_size = tx_queue->tx_ring_size;
-	int frags = 0, nr_txbds = 0;
+	int frags, nr_txbds;
 	int i;
-	int howmany = 0;
+	int howmany = 0, total_txbds = 0;
 	int tqi = tx_queue->qindex;
 	unsigned int bytes_sent = 0;
 	u32 lstatus;
@@ -2479,7 +2479,6 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 	skb_dirtytx = tx_queue->skb_dirtytx;
 
 	while ((skb = tx_queue->tx_skbuff[skb_dirtytx])) {
-		unsigned long flags;
 
 		frags = skb_shinfo(skb)->nr_frags;
 
@@ -2541,20 +2540,24 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 			      TX_RING_MOD_MASK(tx_ring_size);
 
 		howmany++;
-		spin_lock_irqsave(&tx_queue->txlock, flags);
-		tx_queue->num_txbdfree += nr_txbds;
-		spin_unlock_irqrestore(&tx_queue->txlock, flags);
+		total_txbds += nr_txbds;
 	}
 
-	/* If we freed a buffer, we can restart transmission, if necessary */
-	if (netif_tx_queue_stopped(txq) && tx_queue->num_txbdfree)
-		netif_wake_subqueue(dev, tqi);
+	if (howmany) {
+		unsigned long flags;
 
+		spin_lock_irqsave(&tx_queue->txlock, flags);
+		tx_queue->num_txbdfree += total_txbds;
+		/* If we freed a buffer, we can restart transmission, if necessary */
+		if (netif_tx_queue_stopped(txq))
+			netif_tx_wake_queue(txq);
+		netdev_tx_completed_queue(txq, howmany, bytes_sent);
+		spin_unlock_irqrestore(&tx_queue->txlock, flags);
+	}
 	/* Update dirty indicators */
 	tx_queue->skb_dirtytx = skb_dirtytx;
 	tx_queue->dirty_tx = bdp;
 
-	netdev_tx_completed_queue(txq, howmany, bytes_sent);
 
 	return howmany;
 }
