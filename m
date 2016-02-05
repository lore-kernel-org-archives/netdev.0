From: Alexandre Bounine <alexandre.bounine@idt.com>
Subject: [PATCH 02/30] rapidio/rionet: add capability to change MTU
Date: Fri,  5 Feb 2016 18:19:18 -0500
Message-ID: <1454714386-15259-3-git-send-email-alexandre.bounine@idt.com>
References: <1454714386-15259-1-git-send-email-alexandre.bounine@idt.com>
Cc: Aurelien Jacquiot <a-jacquiot@ti.com>,
	Alexandre Bounine <alexandre.bounine@idt.com>,
	Matt Porter <mporter@kernel.crashing.org>,
	Andre van Herk <andre.van.herk@prodrive-technologies.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454714386-15259-1-git-send-email-alexandre.bounine@idt.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Aurelien Jacquiot <a-jacquiot@ti.com>

Replace default Ethernet-specific routine by the custom one to allow
setting of larger MTU supported by RapidIO messaging (max RIO packet
size is 4096 bytes).

Signed-off-by: Aurelien Jacquiot <a-jacquiot@ti.com>
Signed-off-by: Alexandre Bounine <alexandre.bounine@idt.com>
Cc: Matt Porter <mporter@kernel.crashing.org>
Cc: Andre van Herk <andre.van.herk@prodrive-technologies.com>
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 drivers/net/rionet.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index e7034c5..d3d6e35 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -48,6 +48,8 @@ MODULE_LICENSE("GPL");
 #define RIONET_TX_RING_SIZE	CONFIG_RIONET_TX_SIZE
 #define RIONET_RX_RING_SIZE	CONFIG_RIONET_RX_SIZE
 #define RIONET_MAX_NETS		8
+#define RIONET_MSG_SIZE         RIO_MAX_MSG_SIZE
+#define RIONET_MAX_MTU          (RIONET_MSG_SIZE - ETH_HLEN)
 
 struct rionet_private {
 	struct rio_mport *mport;
@@ -443,6 +445,17 @@ static void rionet_set_msglevel(struct net_device *ndev, u32 value)
 	rnet->msg_enable = value;
 }
 
+static int rionet_change_mtu(struct net_device *ndev, int new_mtu)
+{
+	if ((new_mtu < 68) || (new_mtu > RIONET_MAX_MTU)) {
+		printk(KERN_ERR "%s: Invalid MTU size %d\n",
+		       ndev->name, new_mtu);
+		return -EINVAL;
+	}
+	ndev->mtu = new_mtu;
+	return 0;
+}
+
 static const struct ethtool_ops rionet_ethtool_ops = {
 	.get_drvinfo = rionet_get_drvinfo,
 	.get_msglevel = rionet_get_msglevel,
@@ -454,7 +467,7 @@ static const struct net_device_ops rionet_netdev_ops = {
 	.ndo_open		= rionet_open,
 	.ndo_stop		= rionet_close,
 	.ndo_start_xmit		= rionet_start_xmit,
-	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_change_mtu		= rionet_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
 };
@@ -489,7 +502,7 @@ static int rionet_setup_netdev(struct rio_mport *mport, struct net_device *ndev)
 	ndev->dev_addr[5] = device_id & 0xff;
 
 	ndev->netdev_ops = &rionet_netdev_ops;
-	ndev->mtu = RIO_MAX_MSG_SIZE - 14;
+	ndev->mtu = RIONET_MAX_MTU;
 	ndev->features = NETIF_F_LLTX;
 	SET_NETDEV_DEV(ndev, &mport->dev);
 	ndev->ethtool_ops = &rionet_ethtool_ops;
-- 
1.7.8.4
