From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH] gianfar: Add I/O barriers when touching buffer descriptor ownership.
Date: Tue, 1 May 2007 11:55:42 -0500
Message-ID: <20070501165542.GA31285@ld0162-tx32.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:50412 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754801AbXEAQzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 12:55:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The hardware must not see that is given ownership of a buffer until it is
completely written, and when the driver receives ownership of a buffer,
it must ensure that any other reads to the buffer reflect its final
state.  Thus, I/O barriers are added where required.

Without this patch, I have observed GCC reordering the setting of
bdp->length and bdp->status in gfar_new_skb.

Signed-off-by: Scott Wood <scottwood@freescale.com>
---
 drivers/net/gianfar.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index b666a0c..f187dc3 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1025,6 +1025,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev->trans_start = jiffies;
 
+	iobarrier_w();
 	txbdp->status = status;
 
 	/* If this was the last BD in the ring, the next one */
@@ -1301,6 +1302,7 @@ struct sk_buff * gfar_new_skb(struct net_device *dev, struct rxbd8 *bdp)
 	bdp->length = 0;
 
 	/* Mark the buffer empty */
+	iobarrier_w();
 	bdp->status |= (RXBD_EMPTY | RXBD_INTERRUPT);
 
 	return skb;
@@ -1484,6 +1486,7 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 	bdp = priv->cur_rx;
 
 	while (!((bdp->status & RXBD_EMPTY) || (--rx_work_limit < 0))) {
+		iobarrier_r();
 		skb = priv->rx_skbuff[priv->skb_currx];
 
 		if (!(bdp->status &
-- 
1.5.0.3
