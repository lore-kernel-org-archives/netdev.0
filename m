From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH] ibm_newemac: Don't call dev_mc_add() before device is
	registered
Date: Mon, 18 Aug 2008 07:29:23 +1000
Message-ID: <1219008563.28339.15.camel@pasglop>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	Sebastian Siewior <bigeasy@linutronix.de>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:33625 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751483AbYHQV35 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Aug 2008 17:29:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We must not call dev_mc_add() from within our HW configure which happens
before we initialize and register the netdev. Do it in open() instead.

Thanks to Sebastian Siewior for tracking it down. 

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

This fixes an uninitialized spinlock warning (and possibly more).

Please apply.

Cheers,
Ben.

Index: linux-work/drivers/net/ibm_newemac/core.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/core.c	2008-08-14 13:36:10.000000000 +1000
+++ linux-work/drivers/net/ibm_newemac/core.c	2008-08-14 13:42:10.000000000 +1000
@@ -663,9 +663,6 @@ static int emac_configure(struct emac_in
 	if (emac_phy_gpcs(dev->phy.mode))
 		emac_mii_reset_phy(&dev->phy);
 
-	/* Required for Pause packet support in EMAC */
-	dev_mc_add(ndev, default_mcast_addr, sizeof(default_mcast_addr), 1);
-
 	return 0;
 }
 
@@ -1150,6 +1147,9 @@ static int emac_open(struct net_device *
 	} else
 		netif_carrier_on(dev->ndev);
 
+	/* Required for Pause packet support in EMAC */
+	dev_mc_add(ndev, default_mcast_addr, sizeof(default_mcast_addr), 1);
+
 	emac_configure(dev);
 	mal_poll_add(dev->mal, &dev->commac);
 	mal_enable_tx_channel(dev->mal, dev->mal_tx_chan);


_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-dev

