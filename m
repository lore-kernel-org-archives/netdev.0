From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: PATCH SB1250 NAPI support
Date: Thu, 29 Jun 2006 22:01:07 +0200
Message-ID: <20060629200107.GA8122@electric-eye.fr.zoreil.com>
References: <20060524125512.GO12089@deprecation.cyrius.com> <op.s93yprpethfl8t@localhost.localdomain> <20060525133505.GH8746@deprecation.cyrius.com> <op.tamrhvwlthfl8t@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tbm@cyrius.com, jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-mips@linux-mips.org, mark.e.mason@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:21155 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932376AbWF2UDQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 16:03:16 -0400
To: Tom Rix <trix@specifix.com>
Content-Disposition: inline
In-Reply-To: <op.tamrhvwlthfl8t@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tom Rix <trix@specifix.com> :
[...]
diff -rup a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
--- a/drivers/net/sb1250-mac.c	2006-03-09 04:25:41.000000000 -0600
+++ b/drivers/net/sb1250-mac.c	2006-03-09 05:30:52.000000000 -0600
[...]
@@ -2079,13 +2095,31 @@ static irqreturn_t sbmac_intr(int irq,vo
 		 * Transmits on channel 0
 		 */
 
+#if defined(CONFIG_SBMAC_NAPI)
 		if (isr & (M_MAC_INT_CHANNEL << S_MAC_TX_CH0)) {
-			sbdma_tx_process(sc,&(sc->sbm_txdma));
+			sbdma_tx_process(sc,&(sc->sbm_txdma), 0);
 		}
 
 		/*
 		 * Receives on channel 0
 		 */
+		if (isr & (M_MAC_INT_CHANNEL << S_MAC_RX_CH0)) {
+			if (netif_rx_schedule_prep(dev))
+			{

An irq could appear here. I am skeptical that it is safe to write
the irq mask register so late.

One should probably consider a break in the enclosing "for" loop too.


+				__raw_writeq(0, sc->sbm_imr);
+				__netif_rx_schedule(dev);
+			}
+			else
+			{

} else {, please.

-- 
Ueimor
