From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 08/15] ethernet/sun: use core min/max MTU checking
Date: Mon, 17 Oct 2016 15:54:10 -0400
Message-ID: <20161017195417.48259-9-jarod@redhat.com>
References: <20161017195417.48259-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161017195417.48259-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

cassini: min_mtu 60, max_mtu 9000

niu: min_mtu 68, max_mtu 9216

sungem: min_mtu 68, max_mtu 1500 (comments say jumbo mode is broken)

sunvnet: min_mtu 68, max_mtu 65535
- removed sunvnet_change_mut_common as it does nothing now

CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/sun/cassini.c        |  7 ++++---
 drivers/net/ethernet/sun/ldmvsw.c         |  5 ++++-
 drivers/net/ethernet/sun/niu.c            |  7 ++++---
 drivers/net/ethernet/sun/sungem.c         | 11 ++++++-----
 drivers/net/ethernet/sun/sunvnet.c        |  5 ++++-
 drivers/net/ethernet/sun/sunvnet_common.c | 10 ----------
 drivers/net/ethernet/sun/sunvnet_common.h |  3 ++-
 7 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index 062bce9..e9e5ef2 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -3863,9 +3863,6 @@ static int cas_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct cas *cp = netdev_priv(dev);
 
-	if (new_mtu < CAS_MIN_MTU || new_mtu > CAS_MAX_MTU)
-		return -EINVAL;
-
 	dev->mtu = new_mtu;
 	if (!netif_running(dev) || !netif_device_present(dev))
 		return 0;
@@ -5115,6 +5112,10 @@ static int cas_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (pci_using_dac)
 		dev->features |= NETIF_F_HIGHDMA;
 
+	/* MTU range: 60 - varies or 9000 */
+	dev->min_mtu = CAS_MIN_MTU;
+	dev->max_mtu = CAS_MAX_MTU;
+
 	if (register_netdev(dev)) {
 		dev_err(&pdev->dev, "Cannot register net device, aborting\n");
 		goto err_out_free_consistent;
diff --git a/drivers/net/ethernet/sun/ldmvsw.c b/drivers/net/ethernet/sun/ldmvsw.c
index 0ac449a..335b876 100644
--- a/drivers/net/ethernet/sun/ldmvsw.c
+++ b/drivers/net/ethernet/sun/ldmvsw.c
@@ -139,7 +139,6 @@ static const struct net_device_ops vsw_ops = {
 	.ndo_set_mac_address	= sunvnet_set_mac_addr_common,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_tx_timeout		= sunvnet_tx_timeout_common,
-	.ndo_change_mtu		= sunvnet_change_mtu_common,
 	.ndo_start_xmit		= vsw_start_xmit,
 	.ndo_select_queue	= vsw_select_queue,
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -239,6 +238,10 @@ static struct net_device *vsw_alloc_netdev(u8 hwaddr[],
 			   NETIF_F_HW_CSUM | NETIF_F_SG;
 	dev->features = dev->hw_features;
 
+	/* MTU range: 68 - 65535 */
+	dev->min_mtu = ETH_MIN_MTU;
+	dev->max_mtu = VNET_MAX_MTU;
+
 	SET_NETDEV_DEV(dev, &vdev->dev);
 
 	return dev;
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index a2371aa..f90d1af 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -6754,9 +6754,6 @@ static int niu_change_mtu(struct net_device *dev, int new_mtu)
 	struct niu *np = netdev_priv(dev);
 	int err, orig_jumbo, new_jumbo;
 
-	if (new_mtu < 68 || new_mtu > NIU_MAX_MTU)
-		return -EINVAL;
-
 	orig_jumbo = (dev->mtu > ETH_DATA_LEN);
 	new_jumbo = (new_mtu > ETH_DATA_LEN);
 
@@ -9823,6 +9820,10 @@ static int niu_pci_init_one(struct pci_dev *pdev,
 
 	dev->irq = pdev->irq;
 
+	/* MTU range: 68 - 9216 */
+	dev->min_mtu = ETH_MIN_MTU;
+	dev->max_mtu = NIU_MAX_MTU;
+
 	niu_assign_netdev_ops(dev);
 
 	err = niu_get_invariants(np);
diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index d6ad0fb..66ecf0f 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -2476,9 +2476,9 @@ static void gem_set_multicast(struct net_device *dev)
 }
 
 /* Jumbo-grams don't seem to work :-( */
-#define GEM_MIN_MTU	68
+#define GEM_MIN_MTU	ETH_MIN_MTU
 #if 1
-#define GEM_MAX_MTU	1500
+#define GEM_MAX_MTU	ETH_DATA_LEN
 #else
 #define GEM_MAX_MTU	9000
 #endif
@@ -2487,9 +2487,6 @@ static int gem_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct gem *gp = netdev_priv(dev);
 
-	if (new_mtu < GEM_MIN_MTU || new_mtu > GEM_MAX_MTU)
-		return -EINVAL;
-
 	dev->mtu = new_mtu;
 
 	/* We'll just catch it later when the device is up'd or resumed */
@@ -2977,6 +2974,10 @@ static int gem_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (pci_using_dac)
 		dev->features |= NETIF_F_HIGHDMA;
 
+	/* MTU range: 68 - 1500 (Jumbo mode is broken) */
+	dev->min_mtu = GEM_MIN_MTU;
+	dev->max_mtu = GEM_MAX_MTU;
+
 	/* Register with kernel */
 	if (register_netdev(dev)) {
 		pr_err("Cannot register net device, aborting\n");
diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index a2f9b47..5356a70 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -159,7 +159,6 @@ static const struct net_device_ops vnet_ops = {
 	.ndo_set_mac_address	= sunvnet_set_mac_addr_common,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_tx_timeout		= sunvnet_tx_timeout_common,
-	.ndo_change_mtu		= sunvnet_change_mtu_common,
 	.ndo_start_xmit		= vnet_start_xmit,
 	.ndo_select_queue	= vnet_select_queue,
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -202,6 +201,10 @@ static struct vnet *vnet_new(const u64 *local_mac,
 			   NETIF_F_HW_CSUM | NETIF_F_SG;
 	dev->features = dev->hw_features;
 
+	/* MTU range: 68 - 65535 */
+	dev->min_mtu = ETH_MIN_MTU;
+	dev->max_mtu = VNET_MAX_MTU;
+
 	SET_NETDEV_DEV(dev, &vdev->dev);
 
 	err = register_netdev(dev);
diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
index 904a5a1..58efe69 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -1583,16 +1583,6 @@ void sunvnet_set_rx_mode_common(struct net_device *dev, struct vnet *vp)
 }
 EXPORT_SYMBOL_GPL(sunvnet_set_rx_mode_common);
 
-int sunvnet_change_mtu_common(struct net_device *dev, int new_mtu)
-{
-	if (new_mtu < 68 || new_mtu > 65535)
-		return -EINVAL;
-
-	dev->mtu = new_mtu;
-	return 0;
-}
-EXPORT_SYMBOL_GPL(sunvnet_change_mtu_common);
-
 int sunvnet_set_mac_addr_common(struct net_device *dev, void *p)
 {
 	return -EINVAL;
diff --git a/drivers/net/ethernet/sun/sunvnet_common.h b/drivers/net/ethernet/sun/sunvnet_common.h
index bd36528..ce5c824 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.h
+++ b/drivers/net/ethernet/sun/sunvnet_common.h
@@ -15,6 +15,8 @@
 #define	VNET_MINTSO	 2048	/* VIO protocol's minimum TSO len */
 #define	VNET_MAXTSO	65535	/* VIO protocol's maximum TSO len */
 
+#define VNET_MAX_MTU	65535
+
 /* VNET packets are sent in buffers with the first 6 bytes skipped
  * so that after the ethernet header the IPv4/IPv6 headers are aligned
  * properly.
@@ -125,7 +127,6 @@ int sunvnet_close_common(struct net_device *dev);
 void sunvnet_set_rx_mode_common(struct net_device *dev, struct vnet *vp);
 int sunvnet_set_mac_addr_common(struct net_device *dev, void *p);
 void sunvnet_tx_timeout_common(struct net_device *dev);
-int sunvnet_change_mtu_common(struct net_device *dev, int new_mtu);
 int sunvnet_start_xmit_common(struct sk_buff *skb, struct net_device *dev,
 			   struct vnet_port *(*vnet_tx_port)
 			   (struct sk_buff *, struct net_device *));
-- 
2.10.0
