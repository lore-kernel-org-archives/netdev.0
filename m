From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 2/3] net/fec_mpc52xx: Migrate to net_device_ops.
Date: Wed, 01 Apr 2009 00:16:57 -0600
Message-ID: <20090401061657.8641.92975.stgit@localhost.localdomain>
References: <20090401060117.8641.32252.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.225]:45993 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755132AbZDAGRD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 02:17:03 -0400
Received: by rv-out-0506.google.com with SMTP id f9so3442346rvb.1
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2009 23:17:02 -0700 (PDT)
In-Reply-To: <20090401060117.8641.32252.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Henk Stegeman <henk.stegeman@gmail.com>

Since not using net_device_ops gets you shunned out the cool crowd,
this patch modifies the fec_mpc52xx Ethernet driver to provide the
management hooks via a struct net_device_ops.

Reported-by: Henk Stegeman <henk.stegeman@gmail.com>
Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/net/fec_mpc52xx.c |   36 ++++++++++++++++++++----------------
 1 files changed, 20 insertions(+), 16 deletions(-)


diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index f99463f..e4355d4 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -371,7 +371,7 @@ static int mpc52xx_fec_close(struct net_device *dev)
  * invariant will hold if you make sure that the netif_*_queue()
  * calls are done at the proper times.
  */
-static int mpc52xx_fec_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int mpc52xx_fec_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
 	struct bcom_fec_bd *bd;
@@ -379,7 +379,7 @@ static int mpc52xx_fec_hard_start_xmit(struct sk_buff *skb, struct net_device *d
 	if (bcom_queue_full(priv->tx_dmatsk)) {
 		if (net_ratelimit())
 			dev_err(&dev->dev, "transmit queue overrun\n");
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	spin_lock_irq(&priv->lock);
@@ -400,7 +400,7 @@ static int mpc52xx_fec_hard_start_xmit(struct sk_buff *skb, struct net_device *d
 
 	spin_unlock_irq(&priv->lock);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -890,6 +890,22 @@ static int mpc52xx_fec_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	return mpc52xx_fec_phy_mii_ioctl(priv, if_mii(rq), cmd);
 }
 
+static const struct net_device_ops mpc52xx_fec_netdev_ops = {
+	.ndo_open = mpc52xx_fec_open,
+	.ndo_stop = mpc52xx_fec_close,
+	.ndo_start_xmit = mpc52xx_fec_start_xmit,
+	.ndo_set_multicast_list = mpc52xx_fec_set_multicast_list,
+	.ndo_set_mac_address = mpc52xx_fec_set_mac_address,
+	.ndo_validate_addr = eth_validate_addr,
+	.ndo_do_ioctl = mpc52xx_fec_ioctl,
+	.ndo_change_mtu = eth_change_mtu,
+	.ndo_tx_timeout = mpc52xx_fec_tx_timeout,
+	.ndo_get_stats = mpc52xx_fec_get_stats,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller = mpc52xx_fec_poll_controller,
+#endif
+};
+
 /* ======================================================================== */
 /* OF Driver                                                                */
 /* ======================================================================== */
@@ -934,22 +950,10 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
 		return -EBUSY;
 
 	/* Init ether ndev with what we have */
-	ndev->open		= mpc52xx_fec_open;
-	ndev->stop		= mpc52xx_fec_close;
-	ndev->hard_start_xmit	= mpc52xx_fec_hard_start_xmit;
-	ndev->do_ioctl		= mpc52xx_fec_ioctl;
+	ndev->netdev_ops	= &mpc52xx_fec_netdev_ops;
 	ndev->ethtool_ops	= &mpc52xx_fec_ethtool_ops;
-	ndev->get_stats		= mpc52xx_fec_get_stats;
-	ndev->set_mac_address	= mpc52xx_fec_set_mac_address;
-	ndev->set_multicast_list = mpc52xx_fec_set_multicast_list;
-	ndev->tx_timeout	= mpc52xx_fec_tx_timeout;
 	ndev->watchdog_timeo	= FEC_WATCHDOG_TIMEOUT;
 	ndev->base_addr		= mem.start;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	ndev->poll_controller = mpc52xx_fec_poll_controller;
-#endif
-
-	priv->t_irq = priv->r_irq = ndev->irq = NO_IRQ; /* IRQ are free for now */
 
 	spin_lock_init(&priv->lock);
 

