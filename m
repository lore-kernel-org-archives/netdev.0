From: Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
Subject: [PATCH v5 04/17] net: qualcomm: use net_device_ops instead of direct call
Date: Wed, 10 May 2017 10:53:15 +0200
Message-ID: <1494406408-31760-5-git-send-email-stefan.wahren@i2se.com>
References: <1494406408-31760-1-git-send-email-stefan.wahren@i2se.com>
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>, linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1494406408-31760-1-git-send-email-stefan.wahren-eS4NqCHxEME@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

There is no need to export qcaspi_netdev_open and qcaspi_netdev_close
because they are also accessible via the net_device_ops.

Signed-off-by: Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
---
 drivers/net/ethernet/qualcomm/qca_debug.c | 5 +++--
 drivers/net/ethernet/qualcomm/qca_spi.c   | 4 ++--
 drivers/net/ethernet/qualcomm/qca_spi.h   | 3 ---
 3 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/qca_debug.c b/drivers/net/ethernet/qualcomm/qca_debug.c
index d145df9..92b6be9 100644
--- a/drivers/net/ethernet/qualcomm/qca_debug.c
+++ b/drivers/net/ethernet/qualcomm/qca_debug.c
@@ -275,6 +275,7 @@ qcaspi_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ring)
 static int
 qcaspi_set_ringparam(struct net_device *dev, struct ethtool_ringparam *ring)
 {
+	const struct net_device_ops *ops = dev->netdev_ops;
 	struct qcaspi *qca = netdev_priv(dev);
 
 	if ((ring->rx_pending) ||
@@ -283,13 +284,13 @@ qcaspi_set_ringparam(struct net_device *dev, struct ethtool_ringparam *ring)
 		return -EINVAL;
 
 	if (netif_running(dev))
-		qcaspi_netdev_close(dev);
+		ops->ndo_stop(dev);
 
 	qca->txr.count = max_t(u32, ring->tx_pending, TX_RING_MIN_LEN);
 	qca->txr.count = min_t(u16, qca->txr.count, TX_RING_MAX_LEN);
 
 	if (netif_running(dev))
-		qcaspi_netdev_open(dev);
+		ops->ndo_open(dev);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index 8590109..5c79612 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -602,7 +602,7 @@ qcaspi_intr_handler(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-int
+static int
 qcaspi_netdev_open(struct net_device *dev)
 {
 	struct qcaspi *qca = netdev_priv(dev);
@@ -639,7 +639,7 @@ qcaspi_netdev_open(struct net_device *dev)
 	return 0;
 }
 
-int
+static int
 qcaspi_netdev_close(struct net_device *dev)
 {
 	struct qcaspi *qca = netdev_priv(dev);
diff --git a/drivers/net/ethernet/qualcomm/qca_spi.h b/drivers/net/ethernet/qualcomm/qca_spi.h
index 6e31a0e..064853d 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.h
+++ b/drivers/net/ethernet/qualcomm/qca_spi.h
@@ -108,7 +108,4 @@ struct qcaspi {
 	u16 burst_len;
 };
 
-int qcaspi_netdev_open(struct net_device *dev);
-int qcaspi_netdev_close(struct net_device *dev);
-
 #endif /* _QCA_SPI_H */
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
