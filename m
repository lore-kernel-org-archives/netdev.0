From: Ivan Mikhaylov <ivan@de.ibm.com>
Subject: [PATCH 1/2] net/ibm/emac: add set mac addr callback
Date: Wed, 14 Sep 2016 19:06:44 +0300
Message-ID: <1473869205-85314-1-git-send-email-ivan@de.ibm.com>
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

add realization for mac address set and remove dummy callback.

Signed-off-by: Ivan Mikhaylov <ivan@de.ibm.com>
---
 drivers/net/ethernet/ibm/emac/core.c | 31 +++++++++++++++++++++++++++++--
 1 file changed, 29 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 4c9771d..2dfc603 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -980,6 +980,33 @@ static void emac_set_multicast_list(struct net_device *ndev)
 	__emac_set_multicast_list(dev);
 }
 
+static int emac_set_mac_address(struct net_device *ndev, void *sa)
+{
+	struct emac_instance *dev = netdev_priv(ndev);
+	struct sockaddr *addr = sa;
+	struct emac_regs __iomem *p = dev->emacp;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+	       return -EADDRNOTAVAIL;
+
+	mutex_lock(&dev->link_lock);
+
+	memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
+
+	emac_rx_disable(dev);
+	emac_tx_disable(dev);
+	out_be32(&p->iahr, (ndev->dev_addr[0] << 8) | ndev->dev_addr[1]);
+	out_be32(&p->ialr, (ndev->dev_addr[2] << 24) |
+		(ndev->dev_addr[3] << 16) | (ndev->dev_addr[4] << 8) |
+		ndev->dev_addr[5]);
+	emac_tx_enable(dev);
+	emac_rx_enable(dev);
+
+	mutex_unlock(&dev->link_lock);
+
+	return 0;
+}
+
 static int emac_resize_rx_ring(struct emac_instance *dev, int new_mtu)
 {
 	int rx_sync_size = emac_rx_sync_size(new_mtu);
@@ -2686,7 +2713,7 @@ static const struct net_device_ops emac_netdev_ops = {
 	.ndo_do_ioctl		= emac_ioctl,
 	.ndo_tx_timeout		= emac_tx_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_set_mac_address	= emac_set_mac_address,
 	.ndo_start_xmit		= emac_start_xmit,
 	.ndo_change_mtu		= eth_change_mtu,
 };
@@ -2699,7 +2726,7 @@ static const struct net_device_ops emac_gige_netdev_ops = {
 	.ndo_do_ioctl		= emac_ioctl,
 	.ndo_tx_timeout		= emac_tx_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_set_mac_address	= emac_set_mac_address,
 	.ndo_start_xmit		= emac_start_xmit_sg,
 	.ndo_change_mtu		= emac_change_mtu,
 };
-- 
2.7.4 (Apple Git-66)
