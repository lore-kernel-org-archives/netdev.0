From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH 2/3] can: restart device even if dev_alloc_skb() fails
Date: Mon, 20 Jul 2009 16:06:40 +0200
Message-ID: <20090720140638.747810963@denx.de>
References: <20090720140638.342067093@denx.de>
Cc: socketcan-core@lists.berlios.de,
	Kurt Van Dijck <kurt.van.dijck@eia.be>,
	Wolfgang Grandegger <wg@grandegger.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:60775 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753780AbZGTOGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 10:06:40 -0400
Content-Disposition: inline; filename=busoff-restart.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If dev_alloc_skb() failed in can_restart(), the device was left behind
in the bus-off state. This patch restarts the device nevertheless.

Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/dev.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: net-next-2.6/drivers/net/can/dev.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/dev.c	2009-06-09 12:45:38.446934371 +0200
+++ net-next-2.6/drivers/net/can/dev.c	2009-07-20 16:03:19.129997395 +0200
@@ -346,7 +346,7 @@
 	skb = dev_alloc_skb(sizeof(struct can_frame));
 	if (skb == NULL) {
 		err = -ENOMEM;
-		goto out;
+		goto restart;
 	}
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_CAN);
@@ -361,13 +361,13 @@
 	stats->rx_packets++;
 	stats->rx_bytes += cf->can_dlc;
 
+restart:
 	dev_dbg(dev->dev.parent, "restarted\n");
 	priv->can_stats.restarts++;
 
 	/* Now restart the device */
 	err = priv->do_set_mode(dev, CAN_MODE_START);
 
-out:
 	netif_carrier_on(dev);
 	if (err)
 		dev_err(dev->dev.parent, "Error %d during restart", err);

