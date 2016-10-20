From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next v2 7/9] net: use core MTU range checking in misc drivers
Date: Thu, 20 Oct 2016 13:55:22 -0400
Message-ID: <20161020175524.6184-8-jarod@redhat.com>
References: <20161019023333.15760-1-jarod@redhat.com>
 <20161020175524.6184-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org,
        Stefan Richter <stefanr@s5r6.in-berlin.de>,
        Faisal Latif <faisal.latif@intel.com>,
        Cliff Whickman <cpw@sgi.com>,
        Robin Holt <robinmholt@gmail.com>,
        Jes Sorensen <jes@trained-monkey.org>,
        Marek Lindner <mareklindner@neomailbox.ch>,
        Simon Wunderlich <sw@simonwunderlich.de>,
        Antonio Quartulli <a@unstable.cc>,
        Sathya Prakash <sathya.prakash@broadcom.com>,
        Chaitra P B <chaitra.basappa@broadcom.com>,
        Suganath Prabu Subramani
        <suganath-prabu.subramani@broadcom.com>,
        MPT-FusionLinux.pdl@broadcom.com,
        Sebastian Reichel <sre@kernel.org>,
        Felipe Balbi <balbi@kernel.org>,
        Arvid Brodin <arvid.brodin@alten.se>,
        Remi Denis-Courmont <courmisch@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32778 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756310AbcJTRz5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Oct 2016 13:55:57 -0400
In-Reply-To: <20161020175524.6184-1-jarod@redhat.com>
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

um/net_kern:
- remove pointless ndo_change_mtu

hsi/clients/ssi_protocol:
- use core MTU range checking
- remove now redundant ssip_pn_set_mtu

ipoib:
- set a default max MTU value
- Note: ipoib's actual max MTU can vary, depending on if the device is in
  connected mode or not, so we'll just set the max_mtu value to the max
  possible, and let the ndo_change_mtu function continue to validate any new
  MTU change requests with checks for CM or not. Note that ipoib has no
  min_mtu set, and thus, the network core's mtu > 0 check is the only lower
  bounds here.

mptlan:
- use net core MTU range checking
- remove now redundant mpt_lan_change_mtu

fddi:
- min_mtu = 21, max_mtu = 4470
- remove now redundant fddi_change_mtu (including export)

fjes:
- min_mtu = 8192, max_mtu = 65536
- The max_mtu value is actually one over IP_MAX_MTU here, but the idea is to
  get past the core net MTU range checks so fjes_change_mtu can validate a
  new MTU against what it supports (see fjes_support_mtu in fjes_hw.c)

hsr:
- min_mtu = 0 (calls ether_setup, max_mtu is 1500)

f_phonet:
- min_mtu = 6, max_mtu = 65541

u_ether:
- min_mtu = 14, max_mtu = 15412

phonet/pep-gprs:
- min_mtu = 576, max_mtu = 65530
- remove redundant gprs_set_mtu

CC: netdev@vger.kernel.org
CC: linux-rdma@vger.kernel.org
CC: Stefan Richter <stefanr@s5r6.in-berlin.de>
CC: Faisal Latif <faisal.latif@intel.com>
CC: linux-rdma@vger.kernel.org
CC: Cliff Whickman <cpw@sgi.com>
CC: Robin Holt <robinmholt@gmail.com>
CC: Jes Sorensen <jes@trained-monkey.org>
CC: Marek Lindner <mareklindner@neomailbox.ch>
CC: Simon Wunderlich <sw@simonwunderlich.de>
CC: Antonio Quartulli <a@unstable.cc>
CC: Sathya Prakash <sathya.prakash@broadcom.com>
CC: Chaitra P B <chaitra.basappa@broadcom.com>
CC: Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>
CC: MPT-FusionLinux.pdl@broadcom.com
CC: Sebastian Reichel <sre@kernel.org>
CC: Felipe Balbi <balbi@kernel.org>
CC: Arvid Brodin <arvid.brodin@alten.se>
CC: Remi Denis-Courmont <courmisch@gmail.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 arch/um/drivers/net_kern.c                |  8 --------
 drivers/firewire/net.c                    | 18 ++++--------------
 drivers/hsi/clients/ssi_protocol.c        | 14 ++++----------
 drivers/infiniband/hw/nes/nes.c           |  1 -
 drivers/infiniband/hw/nes/nes.h           |  4 ++--
 drivers/infiniband/hw/nes/nes_nic.c       | 10 +++-------
 drivers/infiniband/ulp/ipoib/ipoib_main.c |  1 +
 drivers/message/fusion/mptlan.c           | 15 ++++-----------
 drivers/misc/sgi-xp/xpnet.c               | 21 ++++-----------------
 drivers/net/fddi/skfp/skfddi.c            |  1 -
 drivers/net/fjes/fjes_main.c              |  2 ++
 drivers/net/hippi/rrunner.c               |  1 -
 drivers/net/rionet.c                      | 15 +++------------
 drivers/net/slip/slip.c                   | 11 +++++------
 drivers/usb/gadget/function/f_phonet.c    | 11 ++---------
 drivers/usb/gadget/function/u_ether.c     | 14 ++++----------
 include/linux/fddidevice.h                |  1 -
 include/linux/hippidevice.h               |  1 -
 net/802/fddi.c                            | 11 ++---------
 net/802/hippi.c                           | 14 ++------------
 net/batman-adv/soft-interface.c           | 13 +------------
 net/hsr/hsr_device.c                      |  1 +
 net/phonet/pep-gprs.c                     | 12 ++----------
 23 files changed, 46 insertions(+), 154 deletions(-)

diff --git a/arch/um/drivers/net_kern.c b/arch/um/drivers/net_kern.c
index 2cd5b68..1669240 100644
--- a/arch/um/drivers/net_kern.c
+++ b/arch/um/drivers/net_kern.c
@@ -256,13 +256,6 @@ static void uml_net_tx_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
-static int uml_net_change_mtu(struct net_device *dev, int new_mtu)
-{
-	dev->mtu = new_mtu;
-
-	return 0;
-}
-
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void uml_net_poll_controller(struct net_device *dev)
 {
@@ -374,7 +367,6 @@ static const struct net_device_ops uml_netdev_ops = {
 	.ndo_set_rx_mode	= uml_net_set_multicast_list,
 	.ndo_tx_timeout 	= uml_net_tx_timeout,
 	.ndo_set_mac_address	= eth_mac_addr,
-	.ndo_change_mtu 	= uml_net_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = uml_net_poll_controller,
diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 309311b..8430222 100644
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
@@ -1435,7 +1425,6 @@ static int fwnet_probe(struct fw_unit *unit,
 	struct net_device *net;
 	bool allocated_netdev = false;
 	struct fwnet_device *dev;
-	unsigned max_mtu;
 	int ret;
 	union fwnet_hwaddr *ha;
 
@@ -1478,9 +1467,10 @@ static int fwnet_probe(struct fw_unit *unit,
 	 * Use the RFC 2734 default 1500 octets or the maximum payload
 	 * as initial MTU
 	 */
-	max_mtu = (1 << (card->max_receive + 1))
-		  - sizeof(struct rfc2734_header) - IEEE1394_GASP_HDR_SIZE;
-	net->mtu = min(1500U, max_mtu);
+	net->max_mtu = (1 << (card->max_receive + 1))
+		       - sizeof(struct rfc2734_header) - IEEE1394_GASP_HDR_SIZE;
+	net->mtu = min(1500U, net->max_mtu);
+	net->min_mtu = ETH_MIN_MTU;
 
 	/* Set our hardware address while we're at it */
 	ha = (union fwnet_hwaddr *)net->dev_addr;
diff --git a/drivers/hsi/clients/ssi_protocol.c b/drivers/hsi/clients/ssi_protocol.c
index 6031cd1..7ef8196 100644
--- a/drivers/hsi/clients/ssi_protocol.c
+++ b/drivers/hsi/clients/ssi_protocol.c
@@ -960,15 +960,6 @@ static int ssip_pn_stop(struct net_device *dev)
 	return 0;
 }
 
-static int ssip_pn_set_mtu(struct net_device *dev, int new_mtu)
-{
-	if (new_mtu > SSIP_MAX_MTU || new_mtu < PHONET_MIN_MTU)
-		return -EINVAL;
-	dev->mtu = new_mtu;
-
-	return 0;
-}
-
 static void ssip_xmit_work(struct work_struct *work)
 {
 	struct ssi_protocol *ssi =
@@ -1060,7 +1051,6 @@ static const struct net_device_ops ssip_pn_ops = {
 	.ndo_open	= ssip_pn_open,
 	.ndo_stop	= ssip_pn_stop,
 	.ndo_start_xmit	= ssip_pn_xmit,
-	.ndo_change_mtu	= ssip_pn_set_mtu,
 };
 
 static void ssip_pn_setup(struct net_device *dev)
@@ -1136,6 +1126,10 @@ static int ssi_protocol_probe(struct device *dev)
 		goto out1;
 	}
 
+	/* MTU range: 6 - 65535 */
+	ssi->netdev->min_mtu = PHONET_MIN_MTU;
+	ssi->netdev->max_mtu = SSIP_MAX_MTU;
+
 	SET_NETDEV_DEV(ssi->netdev, dev);
 	netif_carrier_off(ssi->netdev);
 	err = register_netdev(ssi->netdev);
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
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index cc05921..ae5d7cd 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -2017,6 +2017,7 @@ static struct net_device *ipoib_add_port(const char *format,
 	/* MTU will be reset when mcast join happens */
 	priv->dev->mtu  = IPOIB_UD_MTU(priv->max_ib_mtu);
 	priv->mcast_mtu  = priv->admin_mtu = priv->dev->mtu;
+	priv->dev->max_mtu = IPOIB_CM_MTU;
 
 	priv->dev->neigh_priv_len = sizeof(struct ipoib_neigh);
 
diff --git a/drivers/message/fusion/mptlan.c b/drivers/message/fusion/mptlan.c
index 6955c9e..55dd71b 100644
--- a/drivers/message/fusion/mptlan.c
+++ b/drivers/message/fusion/mptlan.c
@@ -549,16 +549,6 @@ mpt_lan_close(struct net_device *dev)
 }
 
 /*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=*/
-static int
-mpt_lan_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if ((new_mtu < MPT_LAN_MIN_MTU) || (new_mtu > MPT_LAN_MAX_MTU))
-		return -EINVAL;
-	dev->mtu = new_mtu;
-	return 0;
-}
-
-/*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=*/
 /* Tx timeout handler. */
 static void
 mpt_lan_tx_timeout(struct net_device *dev)
@@ -1304,7 +1294,6 @@ static const struct net_device_ops mpt_netdev_ops = {
 	.ndo_open       = mpt_lan_open,
 	.ndo_stop       = mpt_lan_close,
 	.ndo_start_xmit = mpt_lan_sdu_send,
-	.ndo_change_mtu = mpt_lan_change_mtu,
 	.ndo_tx_timeout = mpt_lan_tx_timeout,
 };
 
@@ -1375,6 +1364,10 @@ mpt_register_lan_device (MPT_ADAPTER *mpt_dev, int pnum)
 	dev->netdev_ops = &mpt_netdev_ops;
 	dev->watchdog_timeo = MPT_LAN_TX_TIMEOUT;
 
+	/* MTU range: 96 - 65280 */
+	dev->min_mtu = MPT_LAN_MIN_MTU;
+	dev->max_mtu = MPT_LAN_MAX_MTU;
+
 	dlprintk((KERN_INFO MYNAM ": Finished registering dev "
 		"and setting initial values\n"));
 
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
diff --git a/drivers/net/fddi/skfp/skfddi.c b/drivers/net/fddi/skfp/skfddi.c
index 51acc6d..3a63918 100644
--- a/drivers/net/fddi/skfp/skfddi.c
+++ b/drivers/net/fddi/skfp/skfddi.c
@@ -166,7 +166,6 @@ static const struct net_device_ops skfp_netdev_ops = {
 	.ndo_stop		= skfp_close,
 	.ndo_start_xmit		= skfp_send_pkt,
 	.ndo_get_stats		= skfp_ctl_get_stats,
-	.ndo_change_mtu		= fddi_change_mtu,
 	.ndo_set_rx_mode	= skfp_ctl_set_multicast_list,
 	.ndo_set_mac_address	= skfp_ctl_set_mac_address,
 	.ndo_do_ioctl		= skfp_ioctl,
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index f36eb4a..b77e4ecf 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -1316,6 +1316,8 @@ static void fjes_netdev_setup(struct net_device *netdev)
 	netdev->netdev_ops = &fjes_netdev_ops;
 	fjes_set_ethtool_ops(netdev);
 	netdev->mtu = fjes_support_mtu[3];
+	netdev->min_mtu = fjes_support_mtu[0];
+	netdev->max_mtu = fjes_support_mtu[3];
 	netdev->flags |= IFF_BROADCAST;
 	netdev->features |= NETIF_F_HW_CSUM | NETIF_F_HW_VLAN_CTAG_FILTER;
 }
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
diff --git a/drivers/usb/gadget/function/f_phonet.c b/drivers/usb/gadget/function/f_phonet.c
index 0473d61..b4058f0 100644
--- a/drivers/usb/gadget/function/f_phonet.c
+++ b/drivers/usb/gadget/function/f_phonet.c
@@ -261,19 +261,10 @@ static int pn_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-static int pn_net_mtu(struct net_device *dev, int new_mtu)
-{
-	if ((new_mtu < PHONET_MIN_MTU) || (new_mtu > PHONET_MAX_MTU))
-		return -EINVAL;
-	dev->mtu = new_mtu;
-	return 0;
-}
-
 static const struct net_device_ops pn_netdev_ops = {
 	.ndo_open	= pn_net_open,
 	.ndo_stop	= pn_net_close,
 	.ndo_start_xmit	= pn_net_xmit,
-	.ndo_change_mtu	= pn_net_mtu,
 };
 
 static void pn_net_setup(struct net_device *dev)
@@ -282,6 +273,8 @@ static void pn_net_setup(struct net_device *dev)
 	dev->type		= ARPHRD_PHONET;
 	dev->flags		= IFF_POINTOPOINT | IFF_NOARP;
 	dev->mtu		= PHONET_DEV_MTU;
+	dev->min_mtu		= PHONET_MIN_MTU;
+	dev->max_mtu		= PHONET_MAX_MTU;
 	dev->hard_header_len	= 1;
 	dev->dev_addr[0]	= PN_MEDIA_USB;
 	dev->addr_len		= 1;
diff --git a/drivers/usb/gadget/function/u_ether.c b/drivers/usb/gadget/function/u_ether.c
index 9c8c9ed..39a6df1 100644
--- a/drivers/usb/gadget/function/u_ether.c
+++ b/drivers/usb/gadget/function/u_ether.c
@@ -142,15 +142,6 @@ static inline int qlen(struct usb_gadget *gadget, unsigned qmult)
 
 /* NETWORK DRIVER HOOKUP (to the layer above this driver) */
 
-static int ueth_change_mtu(struct net_device *net, int new_mtu)
-{
-	if (new_mtu <= ETH_HLEN || new_mtu > GETHER_MAX_ETH_FRAME_LEN)
-		return -ERANGE;
-	net->mtu = new_mtu;
-
-	return 0;
-}
-
 static void eth_get_drvinfo(struct net_device *net, struct ethtool_drvinfo *p)
 {
 	struct eth_dev *dev = netdev_priv(net);
@@ -736,7 +727,6 @@ static const struct net_device_ops eth_netdev_ops = {
 	.ndo_open		= eth_open,
 	.ndo_stop		= eth_stop,
 	.ndo_start_xmit		= eth_start_xmit,
-	.ndo_change_mtu		= ueth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
@@ -799,6 +789,10 @@ struct eth_dev *gether_setup_name(struct usb_gadget *g,
 
 	net->ethtool_ops = &ops;
 
+	/* MTU range: 14 - 15412 */
+	net->min_mtu = ETH_HLEN;
+	net->max_mtu = GETHER_MAX_ETH_FRAME_LEN;
+
 	dev->gadget = g;
 	SET_NETDEV_DEV(net, &g->dev);
 	SET_NETDEV_DEVTYPE(net, &gadget_type);
diff --git a/include/linux/fddidevice.h b/include/linux/fddidevice.h
index 9a79f01..32c22cf 100644
--- a/include/linux/fddidevice.h
+++ b/include/linux/fddidevice.h
@@ -26,7 +26,6 @@
 
 #ifdef __KERNEL__
 __be16 fddi_type_trans(struct sk_buff *skb, struct net_device *dev);
-int fddi_change_mtu(struct net_device *dev, int new_mtu);
 struct net_device *alloc_fddidev(int sizeof_priv);
 #endif
 
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
diff --git a/net/802/fddi.c b/net/802/fddi.c
index 7d3a0af..6356623 100644
--- a/net/802/fddi.c
+++ b/net/802/fddi.c
@@ -141,15 +141,6 @@ __be16 fddi_type_trans(struct sk_buff *skb, struct net_device *dev)
 
 EXPORT_SYMBOL(fddi_type_trans);
 
-int fddi_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if ((new_mtu < FDDI_K_SNAP_HLEN) || (new_mtu > FDDI_K_SNAP_DLEN))
-		return -EINVAL;
-	dev->mtu = new_mtu;
-	return 0;
-}
-EXPORT_SYMBOL(fddi_change_mtu);
-
 static const struct header_ops fddi_header_ops = {
 	.create		= fddi_header,
 };
@@ -161,6 +152,8 @@ static void fddi_setup(struct net_device *dev)
 	dev->type		= ARPHRD_FDDI;
 	dev->hard_header_len	= FDDI_K_SNAP_HLEN+3;	/* Assume 802.2 SNAP hdr len + 3 pad bytes */
 	dev->mtu		= FDDI_K_SNAP_DLEN;	/* Assume max payload of 802.2 SNAP frame */
+	dev->min_mtu		= FDDI_K_SNAP_HLEN;
+	dev->max_mtu		= FDDI_K_SNAP_DLEN;
 	dev->addr_len		= FDDI_K_ALEN;
 	dev->tx_queue_len	= 100;			/* Long queues on FDDI */
 	dev->flags		= IFF_BROADCAST | IFF_MULTICAST;
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
diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
index 16737cd..fc65b14 100644
--- a/net/hsr/hsr_device.c
+++ b/net/hsr/hsr_device.c
@@ -398,6 +398,7 @@ void hsr_dev_setup(struct net_device *dev)
 	random_ether_addr(dev->dev_addr);
 
 	ether_setup(dev);
+	dev->min_mtu = 0;
 	dev->header_ops = &hsr_header_ops;
 	dev->netdev_ops = &hsr_device_ops;
 	SET_NETDEV_DEVTYPE(dev, &hsr_type);
diff --git a/net/phonet/pep-gprs.c b/net/phonet/pep-gprs.c
index fa8237f..21c28b5 100644
--- a/net/phonet/pep-gprs.c
+++ b/net/phonet/pep-gprs.c
@@ -217,20 +217,10 @@ static netdev_tx_t gprs_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-static int gprs_set_mtu(struct net_device *dev, int new_mtu)
-{
-	if ((new_mtu < 576) || (new_mtu > (PHONET_MAX_MTU - 11)))
-		return -EINVAL;
-
-	dev->mtu = new_mtu;
-	return 0;
-}
-
 static const struct net_device_ops gprs_netdev_ops = {
 	.ndo_open	= gprs_open,
 	.ndo_stop	= gprs_close,
 	.ndo_start_xmit	= gprs_xmit,
-	.ndo_change_mtu	= gprs_set_mtu,
 };
 
 static void gprs_setup(struct net_device *dev)
@@ -239,6 +229,8 @@ static void gprs_setup(struct net_device *dev)
 	dev->type		= ARPHRD_PHONET_PIPE;
 	dev->flags		= IFF_POINTOPOINT | IFF_NOARP;
 	dev->mtu		= GPRS_DEFAULT_MTU;
+	dev->min_mtu		= 576;
+	dev->max_mtu		= (PHONET_MAX_MTU - 11);
 	dev->hard_header_len	= 0;
 	dev->addr_len		= 0;
 	dev->tx_queue_len	= 10;
-- 
2.10.0
