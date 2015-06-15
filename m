From: Simon Guinot <simon.guinot@sequanux.org>
Subject: [PATCH 1/2] net: mvneta: introduce tx_csum_limit property
Date: Mon, 15 Jun 2015 16:27:22 +0200
Message-ID: <1434378443-23029-2-git-send-email-simon.guinot@sequanux.org>
References: <1434378443-23029-1-git-send-email-simon.guinot@sequanux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1434378443-23029-1-git-send-email-simon.guinot@sequanux.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This patch introduces the tx_csum_limit DT property. This allows to
configure the maximum frame size for which the Ethernet controller is
able to perform TCP/IP checksumming. If MTU is set to a value greater
than tx_csum_limit, then the features NETIF_F_IP_CSUM and NETIF_F_TSO
are disabled.

Signed-off-by: Simon Guinot <simon.guinot@sequanux.org>
Cc: <stable@vger.kernel.org> # v3.8+
---
 .../bindings/net/marvell-armada-370-neta.txt       |  3 +++
 drivers/net/ethernet/marvell/mvneta.c              | 25 +++++++++++++++++++++-
 2 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt b/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
index 750d577e8083..db48c83ff0f5 100644
--- a/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
+++ b/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
@@ -8,6 +8,9 @@ Required properties:
 - phy-mode: See ethernet.txt file in the same directory
 - clocks: a pointer to the reference clock for this device.
 
+Optional properties:
+- tx_csum_limit: max tx packet size for hardware checksum.
+
 Example:
 
 ethernet@d0070000 {
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index ce5f7f9cff06..1a724e0a2a26 100644
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
@@ -3101,6 +3122,8 @@ static int mvneta_probe(struct platform_device *pdev)
 		}
 	}
 
+	of_property_read_u32(dn, "tx_csum_limit", &pp->tx_csum_limit);
+
 	pp->tx_ring_size = MVNETA_MAX_TXD;
 	pp->rx_ring_size = MVNETA_MAX_RXD;
 
-- 
2.1.4
