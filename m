From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] pktgen: check for link down
Date: Sat, 19 Sep 2009 22:18:44 -0700
Message-ID: <20090919221844.114e2e23@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Robert Olsson <robert@herjulf.net>,
	Jesper Dangaard Brouer <jdb@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33462 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751264AbZITFSr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Sep 2009 01:18:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If cable is pulled, pktgen shouldn't continue slamming packets into the
device.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/pktgen.c	2009-09-19 11:20:55.546463176 -0700
+++ b/net/core/pktgen.c	2009-09-19 11:22:44.810509240 -0700
@@ -1959,7 +1959,7 @@ static int pktgen_setup_dev(struct pktge
 	if (odev->type != ARPHRD_ETHER) {
 		printk(KERN_ERR "pktgen: not an ethernet device: \"%s\"\n", ifname);
 		err = -EINVAL;
-	} else if (!netif_running(odev)) {
+	} else if (!netif_running(odev) || !netif_carrier_ok(odev)) {
 		printk(KERN_ERR "pktgen: device is down: \"%s\"\n", ifname);
 		err = -ENETDOWN;
 	} else {
@@ -3410,7 +3410,7 @@ static void pktgen_xmit(struct pktgen_de
 	/* Did we saturate the queue already? */
 	if (netif_tx_queue_stopped(txq) || netif_tx_queue_frozen(txq)) {
 		/* If device is down, then all queues are permnantly frozen */
-		if (netif_running(odev))
+		if (netif_running(odev) && netif_carrier_ok(odev))
 			idle(pkt_dev);
 		else
 			pktgen_stop_device(pkt_dev);
