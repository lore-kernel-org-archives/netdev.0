From: Simon Guinot <simon.guinot@sequanux.org>
Subject: [PATCH v2 3/3] ARM: mvebu: disable IP checksum with jumbo frames for Armada 370
Date: Wed, 17 Jun 2015 15:19:22 +0200
Message-ID: <1434547162-6275-4-git-send-email-simon.guinot@sequanux.org>
References: <1434547162-6275-1-git-send-email-simon.guinot@sequanux.org>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Vincent Donnefort <vdonnefort@gmail.com>,
	<stable@vger.kernel.org>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1434547162-6275-1-git-send-email-simon.guinot@sequanux.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Ethernet controller found in the Armada 370, 380 and 385 SoCs don't
support TCP/IP checksumming with frame sizes larger than 1600 bytes.

This patch fixes the issue by disabling the features NETIF_F_IP_CSUM and
NETIF_F_TSO for the Armada 370 and compatibles SoCs when the MTU is set
to a value greater than 1600 bytes.

Signed-off-by: Simon Guinot <simon.guinot@sequanux.org>
Cc: <stable@vger.kernel.org> # v3.8+
---
 drivers/net/ethernet/marvell/mvneta.c | 26 +++++++++++++++++++++++++-
 1 file changed, 25 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index aceb977b104d..9b2b7478fe47 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -310,6 +310,7 @@ struct mvneta_port {
 	unsigned int link;
 	unsigned int duplex;
 	unsigned int speed;
+	unsigned int tx_csum_limit;
 	int use_inband_status:1;
 };
 
@@ -2502,8 +2503,10 @@ static int mvneta_change_mtu(struct net_device *dev, int mtu)
 
 	dev->mtu = mtu;
 
-	if (!netif_running(dev))
+	if (!netif_running(dev)) {
+		netdev_update_features(dev);
 		return 0;
+	}
 
 	/* The interface is running, so we have to force a
 	 * reallocation of the queues
@@ -2532,9 +2535,26 @@ static int mvneta_change_mtu(struct net_device *dev, int mtu)
 	mvneta_start_dev(pp);
 	mvneta_port_up(pp);
 
+	netdev_update_features(dev);
+
 	return 0;
 }
 
+static netdev_features_t mvneta_fix_features(struct net_device *dev,
+					     netdev_features_t features)
+{
+	struct mvneta_port *pp = netdev_priv(dev);
+
+	if (pp->tx_csum_limit && dev->mtu > pp->tx_csum_limit) {
+		features &= ~(NETIF_F_IP_CSUM | NETIF_F_TSO);
+		netdev_info(dev,
+			    "Disable IP checksum for MTU greater than %dB\n",
+			    pp->tx_csum_limit);
+	}
+
+	return features;
+}
+
 /* Get mac address */
 static void mvneta_get_mac_addr(struct mvneta_port *pp, unsigned char *addr)
 {
@@ -2856,6 +2876,7 @@ static const struct net_device_ops mvneta_netdev_ops = {
 	.ndo_set_rx_mode     = mvneta_set_rx_mode,
 	.ndo_set_mac_address = mvneta_set_mac_addr,
 	.ndo_change_mtu      = mvneta_change_mtu,
+	.ndo_fix_features    = mvneta_fix_features,
 	.ndo_get_stats64     = mvneta_get_stats64,
 	.ndo_do_ioctl        = mvneta_ioctl,
 };
@@ -3101,6 +3122,9 @@ static int mvneta_probe(struct platform_device *pdev)
 		}
 	}
 
+	if (of_device_is_compatible(dn, "marvell,armada-370-neta"))
+		pp->tx_csum_limit = 1600;
+
 	pp->tx_ring_size = MVNETA_MAX_TXD;
 	pp->rx_ring_size = MVNETA_MAX_RXD;
 
-- 
2.1.4
