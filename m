From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH RFC v4 02/10] net: qca_debug: use net_device_ops instead of direct call
Date: Mon, 27 Mar 2017 15:37:20 +0200
Message-ID: <1490621848-24828-3-git-send-email-stefan.wahren@i2se.com>
References: <1490621848-24828-1-git-send-email-stefan.wahren@i2se.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Marcel Holtmann <marcel@holtmann.org>,
        Sebastian Reichel <sre@kernel.org>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490621848-24828-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no need to export qcaspi_netdev_open and qcaspi_netdev_close
because they are also accessible via the net_device_ops.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 drivers/net/ethernet/qualcomm/qca_debug.c | 5 +++--
 drivers/net/ethernet/qualcomm/qca_spi.h   | 3 ---
 2 files changed, 3 insertions(+), 5 deletions(-)

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
