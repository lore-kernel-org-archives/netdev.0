From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH can-next] can: dump stack on protocol bugs
Date: Mon, 18 Mar 2013 18:52:06 +0100
Message-ID: <51475446.9000604@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:18618 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148Ab3CRRwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 13:52:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rework of the kernel hlist implementation "hlist: drop the node parameter
from iterators" (b67bfe0d42cac56c512dd5da4b1b347a23f4b70a) created some
fallout in the form of non matching comments and obsolete code.

Additionally to the cleanup this patch adds a WARN() statement to catch the
caller of the wrong filter removal request.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

---

diff --git a/net/can/af_can.c b/net/can/af_can.c
index 8bacf28..c4e5085 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -546,16 +546,13 @@ void can_rx_unregister(struct net_device *dev, canid_t can_id, canid_t mask,
 	}
 
 	/*
-	 * Check for bugs in CAN protocol implementations:
-	 * If no matching list item was found, the list cursor variable next
-	 * will be NULL, while r will point to the last item of the list.
+	 * Check for bugs in CAN protocol implementations using af_can.c:
+	 * 'r' will be NULL if no matching list item was found for removal.
 	 */
 
 	if (!r) {
-		pr_err("BUG: receive list entry not found for "
-		       "dev %s, id %03X, mask %03X\n",
-		       DNAME(dev), can_id, mask);
-		r = NULL;
+		WARN(1, "BUG: receive list entry not found for dev %s, "
+		     "id %03X, mask %03X\n", DNAME(dev), can_id, mask);
 		goto out;
 	}
 
