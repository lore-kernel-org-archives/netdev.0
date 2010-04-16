From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: Re: [PATCH] drivers/net/pcmcia/3c574_cs: fixing stats.tx_bytes
 counter
Date: Fri, 16 Apr 2010 15:01:01 +0200
Message-ID: <20100416130101.GB7877@comet.dominikbrodowski.net>
References: <alpine.DEB.1.10.1003312014120.9974@blala.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Alexander Kurz <akurz@blala.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.133.102.198]:48851 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752555Ab0DPNBN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Apr 2010 09:01:13 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.1003312014120.9974@blala.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

as this is more netdev-related than PCMCIA-related, could you pick it up?
Else, I'm willing to take it upstream, but would prefer your ACK on this.

Thanks & best wishes,

	Dominik

From: Alexander Kurz <akurz@blala.de>
Date: Wed, 31 Mar 2010 20:21:29 +0400
Subject: [PATCH] net: 3c574_cs fix stats.tx_bytes counter

Update the stats counter calculation in 3c574_cs, similar
to the method used in 3c589_cs. This corrects the contents
of the counter on tests using a "Megahertz 574B" card.

[linux@dominikbrodowski.net: clean up commit message]
Signed-off-by: Alexander Kurz <linux@kbdbabel.org>
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>

diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index 727bb38..30b7cf7 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -772,8 +772,13 @@ static netdev_tx_t el3_start_xmit(struct sk_buff *skb,
 		  inw(ioaddr + EL3_STATUS));
 
 	spin_lock_irqsave(&lp->window_lock, flags);
+
+	dev->stats.tx_bytes += skb->len;
+
+	/* Put out the doubleword header... */
 	outw(skb->len, ioaddr + TX_FIFO);
 	outw(0, ioaddr + TX_FIFO);
+	/* ... and the packet rounded to a doubleword. */
 	outsl(ioaddr + TX_FIFO, skb->data, (skb->len+3)>>2);
 
 	dev->trans_start = jiffies;
@@ -1012,8 +1017,6 @@ static void update_stats(struct net_device *dev)
 	/* BadSSD */				   inb(ioaddr + 12);
 	up					 = inb(ioaddr + 13);
 
-	dev->stats.tx_bytes 			+= tx + ((up & 0xf0) << 12);
-
 	EL3WINDOW(1);
 }
 
