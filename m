From: Marc Pignat <marc.pignat@hevs.ch>
Subject: [PATCH] at91_ether: late collistions are counted twice
Date: Thu, 8 May 2008 17:39:00 +0200
Message-ID: <200805081739.02489.marc.pignat@hevs.ch>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@maxim.org.za
To: linux-arm-kernel@lists.arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.hevs.ch ([153.109.23.10]:57052 "EHLO mail.hevs.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753102AbYEHPjK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 11:39:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


According to the at91rm9200 datasheet, table 36-6, late collisions
(AT91_EMAC_LCOL) are already counted in the collision register (in scol, mcol or
ecol , depending on the type of error).

So don't count them twice in stats.collisions.

Signed-off-by: Marc Pignat <marc.pignat@hevs.ch>
---

Hello!

After reviewing the "at91_ether: use netstats in net_device structure" patch, I
had a look the the datasheet and found this small error.

This is really a small error (in statistics) and I will never have collisions,
I'm connected to a switch, but I've no reason not fixing it :)

Best regards



Marc

patch against v2.6.26-rc1 + "[PATCH v2] at91_ether: use netstats in net_device structure"

--- a/drivers/net/arm/at91_ether.c
+++ b/drivers/net/arm/at91_ether.c
@@ -843,7 +843,7 @@ static int at91ether_tx(struct sk_buff *skb, struct net_device *dev)
  */
 static struct net_device_stats *at91ether_stats(struct net_device *dev)
 {
-	int ale, lenerr, seqe, lcol, ecol;
+	int ale, lenerr, seqe, ecol;
 
 	if (netif_running(dev)) {
 		dev->stats.rx_packets += at91_emac_read(AT91_EMAC_OK);		/* Good frames received */
@@ -862,12 +862,11 @@ static struct net_device_stats *at91ether_stats(struct net_device *dev)
 		dev->stats.tx_carrier_errors += at91_emac_read(AT91_EMAC_CSE);	/* Carrier Sense errors */
 		dev->stats.tx_heartbeat_errors += at91_emac_read(AT91_EMAC_SQEE);/* Heartbeat error */
 
-		lcol = at91_emac_read(AT91_EMAC_LCOL);
+		dev->stats.tx_window_errors += at91_emac_read(AT91_EMAC_LCOL);	/* Late collisions */
 		ecol = at91_emac_read(AT91_EMAC_ECOL);
-		dev->stats.tx_window_errors += lcol;			/* Late collisions */
 		dev->stats.tx_aborted_errors += ecol;			/* 16 collisions */
 
-		dev->stats.collisions += (at91_emac_read(AT91_EMAC_SCOL) + at91_emac_read(AT91_EMAC_MCOL) + lcol + ecol);
+		dev->stats.collisions += (at91_emac_read(AT91_EMAC_SCOL) + at91_emac_read(AT91_EMAC_MCOL) + ecol);
 	}
 	return &dev->stats;
 }
