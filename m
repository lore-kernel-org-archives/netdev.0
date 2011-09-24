From: jgq516@gmail.com
Subject: [PATCH 2/2] net/fec: add poll controller function for fec nic
Date: Sat, 24 Sep 2011 10:19:44 +0800
Message-ID: <1316830784-17108-2-git-send-email-jgq516@gmail.com>
References: <1316830784-17108-1-git-send-email-jgq516@gmail.com>
Cc: jgq516@gmail.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1316830784-17108-1-git-send-email-jgq516@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xiao Jiang <jgq516@gmail.com>

Add poll controller function for fec nic.

Signed-off-by: Xiao Jiang <jgq516@gmail.com>
---
 drivers/net/fec.c |   27 +++++++++++++++++++++++++++
 1 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 5705def..00eb5c7 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -235,6 +235,7 @@ struct fec_enet_private {
 	int	link;
 	int	full_duplex;
 	struct	completion mdio_done;
+	int	irq[FEC_IRQ_NUM];
 };
 
 /* FEC MII MMFR bits definition */
@@ -1323,6 +1324,29 @@ fec_set_mac_address(struct net_device *ndev, void *p)
 	return 0;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * fec_poll_controller: FEC Poll controller function
+ * @dev: The FEC network adapter
+ *
+ * Polled functionality used by netconsole and others in non interrupt mode
+ *
+ */
+void fec_poll_controller(struct net_device *dev)
+{
+	int i;
+	struct fec_enet_private *fep = netdev_priv(dev);
+
+	for (i = 0; i < FEC_IRQ_NUM; i++) {
+		if (fep->irq[i] > 0) {
+			disable_irq(fep->irq[i]);
+			fec_enet_interrupt(fep->irq[i], dev);
+			enable_irq(fep->irq[i]);
+		}
+	}
+}
+#endif
+
 static const struct net_device_ops fec_netdev_ops = {
 	.ndo_open		= fec_enet_open,
 	.ndo_stop		= fec_enet_close,
@@ -1333,6 +1357,9 @@ static const struct net_device_ops fec_netdev_ops = {
 	.ndo_tx_timeout		= fec_timeout,
 	.ndo_set_mac_address	= fec_set_mac_address,
 	.ndo_do_ioctl		= fec_enet_ioctl,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller    = fec_poll_controller,
+#endif
 };
 
  /*
-- 
1.7.0.4
