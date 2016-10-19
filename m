From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 6/6] net: use core MTU range checking in misc drivers
Date: Tue, 18 Oct 2016 22:33:33 -0400
Message-ID: <20161019023333.15760-7-jarod@redhat.com>
References: <20161019023333.15760-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        Stefan Richter <stefanr@s5r6.in-berlin.de>,
        Faisal Latif <faisal.latif@intel.com>,
        linux-rdma@vger.kernel.org, Cliff Whickman <cpw@sgi.com>,
        Robin Holt <robinmholt@gmail.com>,
        Jes Sorensen <jes@trained-monkey.org>,
        Marek Lindner <mareklindner@neomailbox.ch>,
        Simon Wunderlich <sw@simonwunderlich.de>,
        Antonio Quartulli <a@unstable.cc>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51334 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934086AbcJSCeB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Oct 2016 22:34:01 -0400
In-Reply-To: <20161019023333.15760-1-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

firewire-net:
- set min/max_mtu
- remove fwnet_change_mtu

nes:
- set max_mtu
- clean up nes_netdev_change_mtu

xpnet:
- set min/max_mtu
- remove xpnet_dev_change_mtu

hippi:
- set min/max_mtu
- remove hippi_change_mtu

batman-adv:
- set max_mtu
- remove batadv_interface_change_mtu
- initialization is a little async, not 100% certain that max_mtu is set
  in the optimal place, don't have hardware to test with

rionet:
- set min/max_mtu
- remove rionet_change_mtu

slip:
- set min/max_mtu
- streamline sl_change_mtu

CC: netdev@vger.kernel.org
CC: Stefan Richter <stefanr@s5r6.in-berlin.de>
CC: Faisal Latif <faisal.latif@intel.com>
CC: linux-rdma@vger.kernel.org
CC: Cliff Whickman <cpw@sgi.com>
CC: Robin Holt <robinmholt@gmail.com>
CC: Jes Sorensen <jes@trained-monkey.org>
CC: Marek Lindner <mareklindner@neomailbox.ch>
CC: Simon Wunderlich <sw@simonwunderlich.de>
CC: Antonio Quartulli <a@unstable.cc>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/firewire/net.c              | 12 ++----------
 drivers/infiniband/hw/nes/nes.c     |  1 -
 drivers/infiniband/hw/nes/nes.h     |  4 ++--
 drivers/infiniband/hw/nes/nes_nic.c | 10 +++-------
 drivers/misc/sgi-xp/xpnet.c         | 21 ++++-----------------
 drivers/net/hippi/rrunner.c         |  1 -
 drivers/net/rionet.c                | 15 +++------------
 drivers/net/slip/slip.c             | 11 +++++------
 include/linux/hippidevice.h         |  1 -
 net/802/hippi.c                     | 14 ++------------
 net/batman-adv/soft-interface.c     | 13 +------------
 11 files changed, 22 insertions(+), 81 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 309311b..b5f125c 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1349,15 +1349,6 @@ static netdev_tx_t fwnet_tx(struct sk_buff *skb, struct net_device *net)
 	return NETDEV_TX_OK;
 }
 
-static int fwnet_change_mtu(struct net_device *net, int new_mtu)
-{
-	if (new_mtu < 68)
-		return -EINVAL;
-
-	net->mtu = new_mtu;
-	return 0;
-}
-
 static const struct ethtool_ops fwnet_ethtool_ops = {
 	.get_link	= ethtool_op_get_link,
 };
@@ -1366,7 +1357,6 @@ static const struct net_device_ops fwnet_netdev_ops = {
 	.ndo_open       = fwnet_open,
 	.ndo_stop	= fwnet_stop,
 	.ndo_start_xmit = fwnet_tx,
-	.ndo_change_mtu = fwnet_change_mtu,
 };
 
 static void fwnet_init_dev(struct net_device *net)
@@ -1481,6 +1471,8 @@ static int fwnet_probe(struct fw_unit *unit,
 	max_mtu = (1 << (card->max_receive + 1))
 		  - sizeof(struct rfc2734_header) - IEEE1394_GASP_HDR_SIZE;
 	net->mtu = min(1500U, max_mtu);
+	net->min_mtu = ETH_MIN_MTU;
+	net->max_mtu = net->mtu;
 
 	/* Set our hardware address while we're at it */
 	ha = (union fwnet_hwaddr *)net->dev_addr;
diff --git a/drivers/infiniband/hw/nes/nes.c b/drivers/infiniband/hw/nes/nes.c
index 35cbb17..2baa45a 100644
--- a/drivers/infiniband/hw/nes/nes.c
+++ b/drivers/infiniband/hw/nes/nes.c
@@ -65,7 +65,6 @@ MODULE_DESCRIPTION("NetEffect RNIC Low-level iWARP Driver");
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_VERSION(DRV_VERSION);
 
-int max_mtu = 9000;
 int interrupt_mod_interval = 0;
 
 /* Interoperability */
diff --git a/drivers/infiniband/hw/nes/nes.h b/drivers/infiniband/hw/nes/nes.h
index e7430c9..85acd08 100644
--- a/drivers/infiniband/hw/nes/nes.h
+++ b/drivers/infiniband/hw/nes/nes.h
@@ -83,6 +83,8 @@
 #define NES_FIRST_QPN           64
 #define NES_SW_CONTEXT_ALIGN    1024
 
+#define NES_MAX_MTU		9000
+
 #define NES_NIC_MAX_NICS        16
 #define NES_MAX_ARP_TABLE_SIZE  4096
 
@@ -169,8 +171,6 @@ do { \
 #include "nes_cm.h"
 #include "nes_mgt.h"
 
-extern int max_mtu;
-#define max_frame_len (max_mtu+ETH_HLEN)
 extern int interrupt_mod_interval;
 extern int nes_if_count;
 extern int mpa_version;
diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index 2b27d13..7f8597d 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -981,20 +981,16 @@ static int nes_netdev_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct nes_vnic	*nesvnic = netdev_priv(netdev);
 	struct nes_device *nesdev = nesvnic->nesdev;
-	int ret = 0;
 	u8 jumbomode = 0;
 	u32 nic_active;
 	u32 nic_active_bit;
 	u32 uc_all_active;
 	u32 mc_all_active;
 
-	if ((new_mtu < ETH_ZLEN) || (new_mtu > max_mtu))
-		return -EINVAL;
-
 	netdev->mtu = new_mtu;
 	nesvnic->max_frame_size	= new_mtu + VLAN_ETH_HLEN;
 
-	if (netdev->mtu	> 1500)	{
+	if (netdev->mtu	> ETH_DATA_LEN)	{
 		jumbomode=1;
 	}
 	nes_nic_init_timer_defaults(nesdev, jumbomode);
@@ -1020,7 +1016,7 @@ static int nes_netdev_change_mtu(struct net_device *netdev, int new_mtu)
 		nes_write_indexed(nesdev, NES_IDX_NIC_UNICAST_ALL, nic_active);
 	}
 
-	return ret;
+	return 0;
 }
 
 
@@ -1658,7 +1654,7 @@ struct net_device *nes_netdev_init(struct nes_device *nesdev,
 
 	netdev->watchdog_timeo = NES_TX_TIMEOUT;
 	netdev->irq = nesdev->pcidev->irq;
-	netdev->mtu = ETH_DATA_LEN;
+	netdev->max_mtu = NES_MAX_MTU;
 	netdev->hard_header_len = ETH_HLEN;
 	netdev->addr_len = ETH_ALEN;
 	netdev->type = ARPHRD_ETHER;
diff --git a/drivers/misc/sgi-xp/xpnet.c b/drivers/misc/sgi-xp/xpnet.c
index 557f978..0c26eaf 100644
--- a/drivers/misc/sgi-xp/xpnet.c
+++ b/drivers/misc/sgi-xp/xpnet.c
@@ -118,6 +118,8 @@ static DEFINE_SPINLOCK(xpnet_broadcast_lock);
  * now, the default is 64KB.
  */
 #define XPNET_MAX_MTU (0x800000UL - L1_CACHE_BYTES)
+/* 68 comes from min TCP+IP+MAC header */
+#define XPNET_MIN_MTU 68
 /* 32KB has been determined to be the ideal */
 #define XPNET_DEF_MTU (0x8000UL)
 
@@ -330,22 +332,6 @@ xpnet_dev_stop(struct net_device *dev)
 	return 0;
 }
 
-static int
-xpnet_dev_change_mtu(struct net_device *dev, int new_mtu)
-{
-	/* 68 comes from min TCP+IP+MAC header */
-	if ((new_mtu < 68) || (new_mtu > XPNET_MAX_MTU)) {
-		dev_err(xpnet, "ifconfig %s mtu %d failed; value must be "
-			"between 68 and %ld\n", dev->name, new_mtu,
-			XPNET_MAX_MTU);
-		return -EINVAL;
-	}
-
-	dev->mtu = new_mtu;
-	dev_dbg(xpnet, "ifconfig %s mtu set to %d\n", dev->name, new_mtu);
-	return 0;
-}
-
 /*
  * Notification that the other end has received the message and
  * DMA'd the skb information.  At this point, they are done with
@@ -519,7 +505,6 @@ static const struct net_device_ops xpnet_netdev_ops = {
 	.ndo_open		= xpnet_dev_open,
 	.ndo_stop		= xpnet_dev_stop,
 	.ndo_start_xmit		= xpnet_dev_hard_start_xmit,
-	.ndo_change_mtu		= xpnet_dev_change_mtu,
 	.ndo_tx_timeout		= xpnet_dev_tx_timeout,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -555,6 +540,8 @@ xpnet_init(void)
 
 	xpnet_device->netdev_ops = &xpnet_netdev_ops;
 	xpnet_device->mtu = XPNET_DEF_MTU;
+	xpnet_device->min_mtu = XPNET_MIN_MTU;
+	xpnet_device->max_mtu = XPNET_MAX_MTU;
 
 	/*
 	 * Multicast assumes the LSB of the first octet is set for multicast
diff --git a/drivers/net/hippi/rrunner.c b/drivers/net/hippi/rrunner.c
index 95c0b45..f5a9728 100644
--- a/drivers/net/hippi/rrunner.c
+++ b/drivers/net/hippi/rrunner.c
@@ -68,7 +68,6 @@ static const struct net_device_ops rr_netdev_ops = {
 	.ndo_stop		= rr_close,
 	.ndo_do_ioctl		= rr_ioctl,
 	.ndo_start_xmit		= rr_start_xmit,
-	.ndo_change_mtu		= hippi_change_mtu,
 	.ndo_set_mac_address	= hippi_mac_addr,
 };
 
diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index a31f461..300bb14 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -466,17 +466,6 @@ static void rionet_set_msglevel(struct net_device *ndev, u32 value)
 	rnet->msg_enable = value;
 }
 
-static int rionet_change_mtu(struct net_device *ndev, int new_mtu)
-{
-	if ((new_mtu < 68) || (new_mtu > RIONET_MAX_MTU)) {
-		printk(KERN_ERR "%s: Invalid MTU size %d\n",
-		       ndev->name, new_mtu);
-		return -EINVAL;
-	}
-	ndev->mtu = new_mtu;
-	return 0;
-}
-
 static const struct ethtool_ops rionet_ethtool_ops = {
 	.get_drvinfo = rionet_get_drvinfo,
 	.get_msglevel = rionet_get_msglevel,
@@ -488,7 +477,6 @@ static const struct net_device_ops rionet_netdev_ops = {
 	.ndo_open		= rionet_open,
 	.ndo_stop		= rionet_close,
 	.ndo_start_xmit		= rionet_start_xmit,
-	.ndo_change_mtu		= rionet_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
 };
@@ -525,6 +513,9 @@ static int rionet_setup_netdev(struct rio_mport *mport, struct net_device *ndev)
 
 	ndev->netdev_ops = &rionet_netdev_ops;
 	ndev->mtu = RIONET_MAX_MTU;
+	/* MTU range: 68 - 4082 */
+	ndev->min_mtu = ETH_MIN_MTU;
+	ndev->max_mtu = RIONET_MAX_MTU;
 	ndev->features = NETIF_F_LLTX;
 	SET_NETDEV_DEV(ndev, &mport->dev);
 	ndev->ethtool_ops = &rionet_ethtool_ops;
diff --git a/drivers/net/slip/slip.c b/drivers/net/slip/slip.c
index 9ed6d1c..7e933d8 100644
--- a/drivers/net/slip/slip.c
+++ b/drivers/net/slip/slip.c
@@ -561,12 +561,7 @@ static int sl_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct slip *sl = netdev_priv(dev);
 
-	if (new_mtu < 68 || new_mtu > 65534)
-		return -EINVAL;
-
-	if (new_mtu != dev->mtu)
-		return sl_realloc_bufs(sl, new_mtu);
-	return 0;
+	return sl_realloc_bufs(sl, new_mtu);
 }
 
 /* Netdevice get statistics request */
@@ -663,6 +658,10 @@ static void sl_setup(struct net_device *dev)
 	dev->addr_len		= 0;
 	dev->tx_queue_len	= 10;
 
+	/* MTU range: 68 - 65534 */
+	dev->min_mtu = 68;
+	dev->max_mtu = 65534;
+
 	/* New-style flags. */
 	dev->flags		= IFF_NOARP|IFF_POINTOPOINT|IFF_MULTICAST;
 }
diff --git a/include/linux/hippidevice.h b/include/linux/hippidevice.h
index 8ec23fb..402f99e 100644
--- a/include/linux/hippidevice.h
+++ b/include/linux/hippidevice.h
@@ -32,7 +32,6 @@ struct hippi_cb {
 };
 
 __be16 hippi_type_trans(struct sk_buff *skb, struct net_device *dev);
-int hippi_change_mtu(struct net_device *dev, int new_mtu);
 int hippi_mac_addr(struct net_device *dev, void *p);
 int hippi_neigh_setup_dev(struct net_device *dev, struct neigh_parms *p);
 struct net_device *alloc_hippi_dev(int sizeof_priv);
diff --git a/net/802/hippi.c b/net/802/hippi.c
index ade1a52..5e4427b 100644
--- a/net/802/hippi.c
+++ b/net/802/hippi.c
@@ -116,18 +116,6 @@ __be16 hippi_type_trans(struct sk_buff *skb, struct net_device *dev)
 
 EXPORT_SYMBOL(hippi_type_trans);
 
-int hippi_change_mtu(struct net_device *dev, int new_mtu)
-{
-	/*
-	 * HIPPI's got these nice large MTUs.
-	 */
-	if ((new_mtu < 68) || (new_mtu > 65280))
-		return -EINVAL;
-	dev->mtu = new_mtu;
-	return 0;
-}
-EXPORT_SYMBOL(hippi_change_mtu);
-
 /*
  * For HIPPI we will actually use the lower 4 bytes of the hardware
  * address as the I-FIELD rather than the actual hardware address.
@@ -174,6 +162,8 @@ static void hippi_setup(struct net_device *dev)
 	dev->type		= ARPHRD_HIPPI;
 	dev->hard_header_len 	= HIPPI_HLEN;
 	dev->mtu		= 65280;
+	dev->min_mtu		= 68;
+	dev->max_mtu		= 65280;
 	dev->addr_len		= HIPPI_ALEN;
 	dev->tx_queue_len	= 25 /* 5 */;
 	memset(dev->broadcast, 0xFF, HIPPI_ALEN);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 49e16b6..112679d 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -158,17 +158,6 @@ static int batadv_interface_set_mac_addr(struct net_device *dev, void *p)
 	return 0;
 }
 
-static int batadv_interface_change_mtu(struct net_device *dev, int new_mtu)
-{
-	/* check ranges */
-	if ((new_mtu < 68) || (new_mtu > batadv_hardif_min_mtu(dev)))
-		return -EINVAL;
-
-	dev->mtu = new_mtu;
-
-	return 0;
-}
-
 /**
  * batadv_interface_set_rx_mode - set the rx mode of a device
  * @dev: registered network device to modify
@@ -920,7 +909,6 @@ static const struct net_device_ops batadv_netdev_ops = {
 	.ndo_vlan_rx_add_vid = batadv_interface_add_vid,
 	.ndo_vlan_rx_kill_vid = batadv_interface_kill_vid,
 	.ndo_set_mac_address = batadv_interface_set_mac_addr,
-	.ndo_change_mtu = batadv_interface_change_mtu,
 	.ndo_set_rx_mode = batadv_interface_set_rx_mode,
 	.ndo_start_xmit = batadv_interface_tx,
 	.ndo_validate_addr = eth_validate_addr,
@@ -987,6 +975,7 @@ struct net_device *batadv_softif_create(struct net *net, const char *name)
 	dev_net_set(soft_iface, net);
 
 	soft_iface->rtnl_link_ops = &batadv_link_ops;
+	soft_iface->max_mtu = batadv_hardif_min_mtu(soft_iface);
 
 	ret = register_netdevice(soft_iface);
 	if (ret < 0) {
-- 
2.10.0
