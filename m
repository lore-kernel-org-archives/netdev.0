From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH 10/12] fec: switch to net_device_ops
Date: Wed, 15 Apr 2009 13:32:23 +0200
Message-ID: <1239795145-27558-11-git-send-email-s.hauer@pengutronix.de>
References: <1239795145-27558-1-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-2-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-3-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-4-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-5-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-6-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-7-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-8-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-9-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-10-git-send-email-s.hauer@pengutronix.de>
Cc: Greg Ungerer <gerg@snapgear.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49331 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759522AbZDOLgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 07:36:50 -0400
In-Reply-To: <1239795145-27558-10-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/fec.c |   36 ++++++++++++++++++++----------------
 1 files changed, 20 insertions(+), 16 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index d96aba9..f4afbe9 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -210,17 +210,13 @@ struct fec_enet_private {
 	int	full_duplex;
 };
 
-static int fec_enet_open(struct net_device *dev);
-static int fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static void fec_enet_mii(struct net_device *dev);
 static irqreturn_t fec_enet_interrupt(int irq, void * dev_id);
 static void fec_enet_tx(struct net_device *dev);
 static void fec_enet_rx(struct net_device *dev);
 static int fec_enet_close(struct net_device *dev);
-static void set_multicast_list(struct net_device *dev);
 static void fec_restart(struct net_device *dev, int duplex);
 static void fec_stop(struct net_device *dev);
-static void fec_set_mac_address(struct net_device *dev);
 
 
 /* MII processing.  We keep this as simple as possible.  Requests are
@@ -1411,7 +1407,6 @@ fec_enet_open(struct net_device *dev)
 	/* I should reset the ring buffers here, but I don't yet know
 	 * a simple way to do that.
 	 */
-	fec_set_mac_address(dev);
 
 	fep->sequence_done = 0;
 	fep->link = 0;
@@ -1544,19 +1539,35 @@ static void set_multicast_list(struct net_device *dev)
 }
 
 /* Set a MAC change in hardware. */
-static void
-fec_set_mac_address(struct net_device *dev)
+static int
+fec_set_mac_address(struct net_device *dev, void *p)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
+	struct sockaddr *addr = p;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 
-	/* Set station address. */
 	writel(dev->dev_addr[3] | (dev->dev_addr[2] << 8) |
 		(dev->dev_addr[1] << 16) | (dev->dev_addr[0] << 24),
 		fep->hwp + FEC_ADDR_LOW);
 	writel((dev->dev_addr[5] << 16) | (dev->dev_addr[4] << 24),
 		fep + FEC_ADDR_HIGH);
+	return 0;
 }
 
+static const struct net_device_ops fec_netdev_ops = {
+	.ndo_open		= fec_enet_open,
+	.ndo_stop		= fec_enet_close,
+	.ndo_start_xmit		= fec_enet_start_xmit,
+	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_tx_timeout		= fec_timeout,
+	.ndo_set_mac_address	= fec_set_mac_address,
+};
+
  /*
   * XXX:  We need to clean up on failure exits here.
   *
@@ -1652,12 +1663,8 @@ int __init fec_enet_init(struct net_device *dev, int index)
 	fec_request_mii_intr(dev);
 #endif
 	/* The FEC Ethernet specific entries in the device structure */
-	dev->open = fec_enet_open;
-	dev->hard_start_xmit = fec_enet_start_xmit;
-	dev->tx_timeout = fec_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
-	dev->stop = fec_enet_close;
-	dev->set_multicast_list = set_multicast_list;
+	dev->netdev_ops = &fec_netdev_ops;
 
 	for (i=0; i<NMII-1; i++)
 		mii_cmds[i].mii_next = &mii_cmds[i+1];
@@ -1696,9 +1703,6 @@ fec_restart(struct net_device *dev, int duplex)
 	/* Clear any outstanding interrupt. */
 	writel(0xffc00000, fep->hwp + FEC_IEVENT);
 
-	/* Set station address.	*/
-	fec_set_mac_address(dev);
-
 	/* Reset all multicast.	*/
 	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
 	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
-- 
1.6.2.1

