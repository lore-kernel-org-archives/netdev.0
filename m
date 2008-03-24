From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.26] Only process completed frames
Date: Mon, 24 Mar 2008 10:53:27 -0500
Message-ID: <1206374009-1292-2-git-send-email-afleming@freescale.com>
References: <1206374009-1292-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>,
	Dai Haruki <dai.haruki@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:48101 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447AbYCXPyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 11:54:06 -0400
In-Reply-To: <1206374009-1292-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the LAST bit is not set in the RxBD, it's possible we're processing an
incomplete frame, which is bad.  While we're at it, add a constant for
the error bitmask, so the whole if-clause fits on one line, and is more
legible.

Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |    4 +---
 drivers/net/gianfar.h |    3 +++
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 0ab4b26..a59edf7 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1526,9 +1526,7 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 		rmb();
 		skb = priv->rx_skbuff[priv->skb_currx];
 
-		if (!(bdp->status &
-		      (RXBD_LARGE | RXBD_SHORT | RXBD_NONOCTET
-		       | RXBD_CRCERR | RXBD_OVERRUN | RXBD_TRUNCATED))) {
+		if ((bdp->status & RXBD_LAST) && !(bdp->status & RXBD_ERR)) {
 			/* Increment the number of packets */
 			dev->stats.rx_packets++;
 			howmany++;
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 46cd773..26eb6ab 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -340,6 +340,9 @@ extern const char gfar_driver_version[];
 #define RXBD_OVERRUN		0x0002
 #define RXBD_TRUNCATED		0x0001
 #define RXBD_STATS		0x01ff
+#define RXBD_ERR		(RXBD_LARGE | RXBD_SHORT | RXBD_NONOCTET 	\
+				| RXBD_CRCERR | RXBD_OVERRUN			\
+				| RXBD_TRUNCATED)
 
 /* Rx FCB status field bits */
 #define RXFCB_VLN		0x8000
-- 
1.5.4.23.gef5b9

