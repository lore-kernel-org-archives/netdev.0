From: jgq516@gmail.com
Subject: [PATCH v2 2/2] net/fec: add poll controller function for fec nic
Date: Thu, 29 Sep 2011 20:15:57 +0800
Message-ID: <1317298557-2878-2-git-send-email-jgq516@gmail.com>
References: <1317298557-2878-1-git-send-email-jgq516@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgq516@gmail.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1317298557-2878-1-git-send-email-jgq516@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xiao Jiang <jgq516@gmail.com>

Add poll controller function for fec nic.

Signed-off-by: Xiao Jiang <jgq516@gmail.com>
---
 drivers/net/ethernet/freescale/fec.c |   27 +++++++++++++++++++++++++++
 1 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 1794ea4..1124ce0 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -242,6 +242,7 @@ struct fec_enet_private {
 	int	link;
 	int	full_duplex;
 	struct	completion mdio_done;
+	int	irq[FEC_IRQ_NUM];
 };
 
 /* FEC MII MMFR bits definition */
@@ -1363,6 +1364,29 @@ fec_set_mac_address(struct net_device *ndev, void *p)
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
@@ -1373,6 +1397,9 @@ static const struct net_device_ops fec_netdev_ops = {
 	.ndo_tx_timeout		= fec_timeout,
 	.ndo_set_mac_address	= fec_set_mac_address,
 	.ndo_do_ioctl		= fec_enet_ioctl,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= fec_poll_controller,
+#endif
 };
 
  /*
-- 
1.7.6.1
