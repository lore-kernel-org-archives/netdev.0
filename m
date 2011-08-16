From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 1/3] net: introduce IFF_UNICAST_FLT private flag
Date: Tue, 16 Aug 2011 18:29:00 +0200
Message-ID: <1313512142-3355-2-git-send-email-jpirko@redhat.com>
References: <1313512142-3355-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, kaber@trash.net, yoshfuji@linux-ipv6.org,
	rdunlap@xenotime.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	mirqus@gmail.com, jesse@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64630 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752296Ab1HPSCM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2011 14:02:12 -0400
In-Reply-To: <1313512142-3355-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use IFF_UNICAST_FTL to find out if driver handles unicast address
filtering. In case it does not, promisc mode is entered.

Patch also fixes following drivers:
stmmac, niu: support uc filtering and yet it propagated
	ndo_set_multicast_list
bna, benet, pxa168_eth, ks8851, ks8851_mll, ksz884x : has set
	ndo_set_rx_mode but do not support uc filtering

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2.c               |    2 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |    3 +++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |    3 +++
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    2 ++
 drivers/net/ethernet/cisco/enic/enic_main.c        |    3 +++
 drivers/net/ethernet/intel/e1000/e1000_main.c      |    2 ++
 drivers/net/ethernet/intel/igb/igb_main.c          |    3 +++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |    3 +++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |    3 +++
 drivers/net/ethernet/marvell/mv643xx_eth.c         |    2 ++
 drivers/net/ethernet/octeon/octeon_mgmt.c          |    3 +++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   13 ++++++++-----
 drivers/net/ethernet/sun/niu.c                     |    5 ++++-
 drivers/net/virtio_net.c                           |    1 +
 include/linux/if.h                                 |    1 +
 include/linux/netdevice.h                          |    2 ++
 net/core/dev.c                                     |   12 ++++++------
 17 files changed, 51 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 4b2b570..4a9a8c81 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -36,6 +36,7 @@
 #include <linux/time.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
+#include <linux/if.h>
 #include <linux/if_vlan.h>
 #include <net/ip.h>
 #include <net/tcp.h>
@@ -8370,6 +8371,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->vlan_features = dev->hw_features;
 	dev->hw_features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 	dev->features |= dev->hw_features;
+	dev->priv_flags |= IFF_UNICAST_FLT;
 
 	if ((rc = register_netdev(dev))) {
 		dev_err(&pdev->dev, "Cannot register net device\n");
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 1507091..212a7e3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -37,6 +37,7 @@
 #include <linux/time.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
+#include <linux/if.h>
 #include <linux/if_vlan.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
@@ -10273,6 +10274,8 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 	dev->netdev_ops = &bnx2x_netdev_ops;
 	bnx2x_set_ethtool_ops(dev);
 
+	dev->priv_flags |= IFF_UNICAST_FLT;
+
 	dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 |
 		NETIF_F_RXCSUM | NETIF_F_LRO | NETIF_F_HW_VLAN_TX;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index c9957b7..90b4921 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -41,6 +41,7 @@
 #include <linux/err.h>
 #include <linux/etherdevice.h>
 #include <linux/firmware.h>
+#include <linux/if.h>
 #include <linux/if_vlan.h>
 #include <linux/init.h>
 #include <linux/log2.h>
@@ -3639,6 +3640,8 @@ static int __devinit init_one(struct pci_dev *pdev,
 		netdev->features |= netdev->hw_features | highdma;
 		netdev->vlan_features = netdev->features & VLAN_FEAT;
 
+		netdev->priv_flags |= IFF_UNICAST_FLT;
+
 		netdev->netdev_ops = &cxgb4_netdev_ops;
 		SET_ETHTOOL_OPS(netdev, &cxgb_ethtool_ops);
 	}
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index ec79913..da9072b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2625,6 +2625,8 @@ static int __devinit cxgb4vf_pci_probe(struct pci_dev *pdev,
 		if (pci_using_dac)
 			netdev->features |= NETIF_F_HIGHDMA;
 
+		netdev->priv_flags |= IFF_UNICAST_FLT;
+
 		netdev->netdev_ops = &cxgb4vf_netdev_ops;
 		SET_ETHTOOL_OPS(netdev, &cxgb4vf_ethtool_ops);
 
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 67a27cd..f342be0 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -28,6 +28,7 @@
 #include <linux/pci.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/if.h>
 #include <linux/if_ether.h>
 #include <linux/if_vlan.h>
 #include <linux/ethtool.h>
@@ -2442,6 +2443,8 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	if (using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
+	netdev->priv_flags |= IFF_UNICAST_FLT;
+
 	err = register_netdev(netdev);
 	if (err) {
 		dev_err(dev, "Cannot register net device, aborting\n");
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index f97afda..7c280e5 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1080,6 +1080,8 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	netdev->vlan_features |= NETIF_F_HW_CSUM;
 	netdev->vlan_features |= NETIF_F_SG;
 
+	netdev->priv_flags |= IFF_UNICAST_FLT;
+
 	adapter->en_mng_pt = e1000_enable_mng_pass_thru(hw);
 
 	/* initialize eeprom parameters */
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 40d4c40..592b5c1 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -39,6 +39,7 @@
 #include <linux/net_tstamp.h>
 #include <linux/mii.h>
 #include <linux/ethtool.h>
+#include <linux/if.h>
 #include <linux/if_vlan.h>
 #include <linux/pci.h>
 #include <linux/pci-aspm.h>
@@ -1973,6 +1974,8 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		netdev->features |= NETIF_F_SCTP_CSUM;
 	}
 
+	netdev->priv_flags |= IFF_UNICAST_FLT;
+
 	adapter->en_mng_pt = igb_enable_mng_pass_thru(hw);
 
 	/* before reading the NVM, reset the controller to put the device in a
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e86297b..8c70273 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -42,6 +42,7 @@
 #include <net/checksum.h>
 #include <net/ip6_checksum.h>
 #include <linux/ethtool.h>
+#include <linux/if.h>
 #include <linux/if_vlan.h>
 #include <linux/prefetch.h>
 #include <scsi/fc/fc_fcoe.h>
@@ -7527,6 +7528,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	netdev->vlan_features |= NETIF_F_IPV6_CSUM;
 	netdev->vlan_features |= NETIF_F_SG;
 
+	netdev->priv_flags |= IFF_UNICAST_FLT;
+
 	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
 		adapter->flags &= ~(IXGBE_FLAG_RSS_ENABLED |
 				    IXGBE_FLAG_DCB_ENABLED);
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 3b880a2..45b0078 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -44,6 +44,7 @@
 #include <net/checksum.h>
 #include <net/ip6_checksum.h>
 #include <linux/ethtool.h>
+#include <linux/if.h>
 #include <linux/if_vlan.h>
 #include <linux/prefetch.h>
 
@@ -3358,6 +3359,8 @@ static int __devinit ixgbevf_probe(struct pci_dev *pdev,
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
+	netdev->priv_flags |= IFF_UNICAST_FLT;
+
 	/* The HW MAC address was set and/or determined in sw_init */
 	memcpy(netdev->dev_addr, adapter->hw.mac.addr, netdev->addr_len);
 	memcpy(netdev->perm_addr, adapter->hw.mac.addr, netdev->addr_len);
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 2596999..1e2c9f07 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2923,6 +2923,8 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_RXCSUM;
 	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM;
 
+	dev->priv_flags |= IFF_UNICAST_FLT;
+
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (mp->shared->win_protect)
diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
index 429e08c..d6f96e5 100644
--- a/drivers/net/ethernet/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
@@ -13,6 +13,7 @@
 #include <linux/platform_device.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/if.h>
 #include <linux/if_vlan.h>
 #include <linux/slab.h>
 #include <linux/phy.h>
@@ -1102,6 +1103,8 @@ static int __devinit octeon_mgmt_probe(struct platform_device *pdev)
 	tasklet_init(&p->tx_clean_tasklet,
 		     octeon_mgmt_clean_tx_tasklet, (unsigned long)p);
 
+	netdev->priv_flags |= IFF_UNICAST_FLT;
+
 	netdev->netdev_ops = &octeon_mgmt_ops;
 	netdev->ethtool_ops = &octeon_mgmt_ethtool_ops;
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index c6e567e..68fb5b0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -42,6 +42,7 @@
 #include <linux/crc32.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
+#include <linux/if.h>
 #include <linux/if_vlan.h>
 #include <linux/dma-mapping.h>
 #include <linux/slab.h>
@@ -1284,7 +1285,7 @@ static int stmmac_config(struct net_device *dev, struct ifmap *map)
 }
 
 /**
- *  stmmac_multicast_list - entry point for multicast addressing
+ *  stmmac_set_rx_mode - entry point for multicast addressing
  *  @dev : pointer to the device structure
  *  Description:
  *  This function is a driver entry point which gets called by the kernel
@@ -1292,7 +1293,7 @@ static int stmmac_config(struct net_device *dev, struct ifmap *map)
  *  Return value:
  *  void.
  */
-static void stmmac_multicast_list(struct net_device *dev)
+static void stmmac_set_rx_mode(struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 
@@ -1421,7 +1422,7 @@ static const struct net_device_ops stmmac_netdev_ops = {
 	.ndo_stop = stmmac_release,
 	.ndo_change_mtu = stmmac_change_mtu,
 	.ndo_fix_features = stmmac_fix_features,
-	.ndo_set_multicast_list = stmmac_multicast_list,
+	.ndo_set_rx_mode = stmmac_set_rx_mode,
 	.ndo_tx_timeout = stmmac_tx_timeout,
 	.ndo_do_ioctl = stmmac_ioctl,
 	.ndo_set_config = stmmac_config,
@@ -1498,10 +1499,12 @@ static int stmmac_mac_device_setup(struct net_device *dev)
 
 	struct mac_device_info *device;
 
-	if (priv->plat->has_gmac)
+	if (priv->plat->has_gmac) {
+		dev->priv_flags |= IFF_UNICAST_FLT;
 		device = dwmac1000_setup(priv->ioaddr);
-	else
+	} else {
 		device = dwmac100_setup(priv->ioaddr);
+	}
 
 	if (!device)
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index ed47585..3c9ef1c 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -17,6 +17,7 @@
 #include <linux/delay.h>
 #include <linux/bitops.h>
 #include <linux/mii.h>
+#include <linux/if.h>
 #include <linux/if_ether.h>
 #include <linux/if_vlan.h>
 #include <linux/ip.h>
@@ -9716,7 +9717,7 @@ static const struct net_device_ops niu_netdev_ops = {
 	.ndo_stop		= niu_close,
 	.ndo_start_xmit		= niu_start_xmit,
 	.ndo_get_stats64	= niu_get_stats,
-	.ndo_set_multicast_list	= niu_set_rx_mode,
+	.ndo_set_rx_mode	= niu_set_rx_mode,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= niu_set_mac_addr,
 	.ndo_do_ioctl		= niu_ioctl,
@@ -9852,6 +9853,8 @@ static int __devinit niu_pci_init_one(struct pci_dev *pdev,
 
 	niu_set_basic_features(dev);
 
+	dev->priv_flags |= IFF_UNICAST_FLT;
+
 	np->regs = pci_ioremap_bar(pdev, 0);
 	if (!np->regs) {
 		dev_err(&pdev->dev, "Cannot map device registers, aborting\n");
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 0c7321c..4f09f88 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -949,6 +949,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 		return -ENOMEM;
 
 	/* Set up network device as normal. */
+	dev->priv_flags |= IFF_UNICAST_FLT;
 	dev->netdev_ops = &virtnet_netdev;
 	dev->features = NETIF_F_HIGHDMA;
 
diff --git a/include/linux/if.h b/include/linux/if.h
index 03489ca..db20bd4 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -78,6 +78,7 @@
 					 * datapath port */
 #define IFF_TX_SKB_SHARING	0x10000	/* The interface supports sharing
 					 * skbs on transmit */
+#define IFF_UNICAST_FLT	0x20000		/* Supports unicast filtering	*/
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ddee79b..96e4f7e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -723,6 +723,8 @@ struct netdev_tc_txq {
  *
  * void (*ndo_set_rx_mode)(struct net_device *dev);
  *	This function is called device changes address list filtering.
+ *	If driver handles unicast address filtering, it should set
+ *	IFF_UNICAST_FLT to its priv_flags.
  *
  * void (*ndo_set_multicast_list)(struct net_device *dev);
  *	This function is called when the multicast address list changes.
diff --git a/net/core/dev.c b/net/core/dev.c
index d22ffd7..018c15c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4489,9 +4489,7 @@ void __dev_set_rx_mode(struct net_device *dev)
 	if (!netif_device_present(dev))
 		return;
 
-	if (ops->ndo_set_rx_mode)
-		ops->ndo_set_rx_mode(dev);
-	else {
+	if (!(dev->priv_flags & IFF_UNICAST_FLT)) {
 		/* Unicast addresses changes may only happen under the rtnl,
 		 * therefore calling __dev_set_promiscuity here is safe.
 		 */
@@ -4502,10 +4500,12 @@ void __dev_set_rx_mode(struct net_device *dev)
 			__dev_set_promiscuity(dev, -1);
 			dev->uc_promisc = false;
 		}
-
-		if (ops->ndo_set_multicast_list)
-			ops->ndo_set_multicast_list(dev);
 	}
+
+	if (ops->ndo_set_rx_mode)
+		ops->ndo_set_rx_mode(dev);
+	else if (ops->ndo_set_multicast_list)
+		ops->ndo_set_multicast_list(dev);
 }
 
 void dev_set_rx_mode(struct net_device *dev)
-- 
1.7.6

