From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 09/15] ethernet/dlink: use core min/max MTU checking
Date: Mon, 17 Oct 2016 15:54:11 -0400
Message-ID: <20161017195417.48259-10-jarod@redhat.com>
References: <20161017195417.48259-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        Denis Kirjanov <kda@linux-powerpc.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161017195417.48259-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dl2k: min_mtu 68, max_mtu 1536 or 8000, depending on hardware
- Removed change_mtu, does nothing productive anymore

sundance: min_mtu 68, max_mtu 8191

CC: netdev@vger.kernel.org
CC: Denis Kirjanov <kda@linux-powerpc.org>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/dlink/dl2k.c     | 22 ++++------------------
 drivers/net/ethernet/dlink/sundance.c |  6 ++++--
 2 files changed, 8 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index 78f1446..8c95a8a 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -76,7 +76,6 @@ static void rio_free_tx (struct net_device *dev, int irq);
 static void tx_error (struct net_device *dev, int tx_status);
 static int receive_packet (struct net_device *dev);
 static void rio_error (struct net_device *dev, int int_status);
-static int change_mtu (struct net_device *dev, int new_mtu);
 static void set_multicast (struct net_device *dev);
 static struct net_device_stats *get_stats (struct net_device *dev);
 static int clear_stats (struct net_device *dev);
@@ -106,7 +105,6 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_set_rx_mode	= set_multicast,
 	.ndo_do_ioctl		= rio_ioctl,
 	.ndo_tx_timeout		= rio_tx_timeout,
-	.ndo_change_mtu		= change_mtu,
 };
 
 static int
@@ -230,6 +228,10 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 #if 0
 	dev->features = NETIF_F_IP_CSUM;
 #endif
+	/* MTU range: 68 - 1536 or 8000 */
+	dev->min_mtu = ETH_MIN_MTU;
+	dev->max_mtu = np->jumbo ? MAX_JUMBO : PACKET_SIZE;
+
 	pci_set_drvdata (pdev, dev);
 
 	ring_space = pci_alloc_consistent (pdev, TX_TOTAL_SIZE, &ring_dma);
@@ -1198,22 +1200,6 @@ clear_stats (struct net_device *dev)
 	return 0;
 }
 
-
-static int
-change_mtu (struct net_device *dev, int new_mtu)
-{
-	struct netdev_private *np = netdev_priv(dev);
-	int max = (np->jumbo) ? MAX_JUMBO : 1536;
-
-	if ((new_mtu < 68) || (new_mtu > max)) {
-		return -EINVAL;
-	}
-
-	dev->mtu = new_mtu;
-
-	return 0;
-}
-
 static void
 set_multicast (struct net_device *dev)
 {
diff --git a/drivers/net/ethernet/dlink/sundance.c b/drivers/net/ethernet/dlink/sundance.c
index 79d8009..eab36ac 100644
--- a/drivers/net/ethernet/dlink/sundance.c
+++ b/drivers/net/ethernet/dlink/sundance.c
@@ -580,6 +580,10 @@ static int sundance_probe1(struct pci_dev *pdev,
 	dev->ethtool_ops = &ethtool_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
+	/* MTU range: 68 - 8191 */
+	dev->min_mtu = ETH_MIN_MTU;
+	dev->max_mtu = 8191;
+
 	pci_set_drvdata(pdev, dev);
 
 	i = register_netdev(dev);
@@ -713,8 +717,6 @@ static int sundance_probe1(struct pci_dev *pdev,
 
 static int change_mtu(struct net_device *dev, int new_mtu)
 {
-	if ((new_mtu < 68) || (new_mtu > 8191)) /* Set by RxDMAFrameLen */
-		return -EINVAL;
 	if (netif_running(dev))
 		return -EBUSY;
 	dev->mtu = new_mtu;
-- 
2.10.0
