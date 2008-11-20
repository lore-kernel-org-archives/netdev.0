From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/9] netdev: add more functions to netdevice ops
Date: Thu, 20 Nov 2008 09:59:14 -0800
Message-ID: <20081120175933.601338012@vyatta.com>
References: <20081120175913.943543638@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:53063 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752662AbYKTSEL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2008 13:04:11 -0500
Content-Disposition: inline; filename=netdev-ops2.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves neigh_setup and hard_start_xmit into the network device ops
structure. For bisection, fix all the previously converted drivers as well.
Bonding driver took the biggest hit on this.

Added a prefetch of the hard_start_xmit in the fast path to try and reduce
any impact this would have.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/8139cp.c            |    2 -
 drivers/net/8139too.c           |    2 -
 drivers/net/acenic.c            |    4 ++
 drivers/net/atl1e/atl1e_main.c  |    3 +-
 drivers/net/atlx/atl1.c         |    4 +-
 drivers/net/atlx/atl2.c         |    2 -
 drivers/net/bonding/bond_main.c |   56 ++++++++++++++++++++++++++++++++--------
 drivers/net/chelsio/cxgb2.c     |    6 ++--
 drivers/net/cxgb3/cxgb3_main.c  |    1 
 drivers/net/e100.c              |    2 -
 drivers/net/e1000/e1000_main.c  |    2 -
 drivers/net/e1000e/netdev.c     |    2 -
 drivers/net/enic/enic_main.c    |    2 -
 drivers/net/forcedeth.c         |   22 +++++++++++++--
 drivers/net/ifb.c               |    4 +-
 drivers/net/igb/igb_main.c      |    2 -
 drivers/net/ixgb/ixgb_main.c    |    2 -
 drivers/net/ixgbe/ixgbe_main.c  |    2 -
 drivers/net/loopback.c          |    2 -
 drivers/net/macvlan.c           |    4 +-
 drivers/net/niu.c               |    2 -
 drivers/net/ppp_generic.c       |    5 +--
 drivers/net/r8169.c             |    2 -
 drivers/net/skge.c              |    2 -
 drivers/net/sky2.c              |    3 +-
 drivers/net/tg3.c               |   45 ++++++++++++++++++++++----------
 drivers/net/tun.c               |    4 +-
 drivers/net/veth.c              |    2 -
 drivers/net/via-velocity.c      |    2 -
 include/linux/netdevice.h       |   39 ++++++++++++++++++---------
 net/bridge/br_device.c          |   10 +++----
 net/bridge/br_if.c              |    2 -
 net/core/dev.c                  |   12 +++++---
 net/core/neighbour.c            |    6 ++--
 net/core/netpoll.c              |    6 ++--
 net/core/pktgen.c               |    8 ++---
 36 files changed, 183 insertions(+), 93 deletions(-)

--- a/drivers/net/acenic.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/acenic.c	2008-11-20 09:14:13.000000000 -0800
@@ -455,10 +455,13 @@ static const struct net_device_ops ace_n
 	.ndo_stop		= ace_close,
 	.ndo_tx_timeout		= ace_watchdog,
 	.ndo_get_stats		= ace_get_stats,
+	.ndo_start_xmit		= ace_start_xmit,
 	.ndo_set_multicast_list	= ace_set_multicast_list,
 	.ndo_set_mac_address	= ace_set_mac_addr,
 	.ndo_change_mtu		= ace_change_mtu,
+#if ACENIC_DO_VLAN
 	.ndo_vlan_rx_register	= ace_vlan_rx_register,
+#endif
 };
 
 static int __devinit acenic_probe_one(struct pci_dev *pdev,
@@ -489,7 +492,6 @@ static int __devinit acenic_probe_one(st
 	dev->watchdog_timeo = 5*HZ;
 
 	dev->netdev_ops = &ace_netdev_ops;
-	dev->hard_start_xmit = &ace_start_xmit;
 	SET_ETHTOOL_OPS(dev, &ace_ethtool_ops);
 
 	/* we only display this string ONCE */
--- a/drivers/net/atl1e/atl1e_main.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/atl1e/atl1e_main.c	2008-11-20 09:14:13.000000000 -0800
@@ -2256,6 +2256,7 @@ static void atl1e_shutdown(struct pci_de
 static const struct net_device_ops atl1e_netdev_ops = {
 	.ndo_open		= atl1e_open,
 	.ndo_stop		= atl1e_close,
+	.ndo_start_xmit		= atl1e_xmit_frame,
 	.ndo_get_stats		= atl1e_get_stats,
 	.ndo_set_multicast_list	= atl1e_set_multi,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -2277,7 +2278,7 @@ static int atl1e_init_netdev(struct net_
 
 	netdev->irq  = pdev->irq;
 	netdev->netdev_ops = &atl1e_netdev_ops;
-	netdev->hard_start_xmit = atl1e_xmit_frame,
+
 	netdev->watchdog_timeo = AT_TX_WATCHDOG;
 	atl1e_set_ethtool_ops(netdev);
 
--- a/drivers/net/atlx/atl1.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/atlx/atl1.c	2008-11-20 09:14:58.000000000 -0800
@@ -2883,12 +2883,13 @@ static void atl1_poll_controller(struct 
 static const struct net_device_ops atl1_netdev_ops = {
 	.ndo_open		= atl1_open,
 	.ndo_stop		= atl1_close,
+	.ndo_start_xmit		= atl1_xmit_frame,
 	.ndo_set_multicast_list	= atlx_set_multi,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= atl1_set_mac,
 	.ndo_change_mtu		= atl1_change_mtu,
 	.ndo_do_ioctl		= atlx_ioctl,
-	.ndo_tx_timeout	= atlx_tx_timeout,
+	.ndo_tx_timeout		= atlx_tx_timeout,
 	.ndo_vlan_rx_register	= atlx_vlan_rx_register,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= atl1_poll_controller,
@@ -2983,7 +2984,6 @@ static int __devinit atl1_probe(struct p
 	adapter->mii.reg_num_mask = 0x1f;
 
 	netdev->netdev_ops = &atl1_netdev_ops;
-	netdev->hard_start_xmit = &atl1_xmit_frame;
 	netdev->watchdog_timeo = 5 * HZ;
 
 	netdev->ethtool_ops = &atl1_ethtool_ops;
--- a/drivers/net/atlx/atl2.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/atlx/atl2.c	2008-11-20 09:14:13.000000000 -0800
@@ -1315,6 +1315,7 @@ static void atl2_poll_controller(struct 
 static const struct net_device_ops atl2_netdev_ops = {
 	.ndo_open		= atl2_open,
 	.ndo_stop		= atl2_close,
+	.ndo_start_xmit		= atl2_xmit_frame,
 	.ndo_set_multicast_list	= atl2_set_multi,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= atl2_set_mac,
@@ -1400,7 +1401,6 @@ static int __devinit atl2_probe(struct p
 
 	atl2_setup_pcicmd(pdev);
 
-	netdev->hard_start_xmit = &atl2_xmit_frame;
 	netdev->netdev_ops = &atl2_netdev_ops;
 	atl2_set_ethtool_ops(netdev);
 	netdev->watchdog_timeo = 5 * HZ;
--- a/drivers/net/bonding/bond_main.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/bonding/bond_main.c	2008-11-20 09:14:13.000000000 -0800
@@ -1377,14 +1377,12 @@ done:
 	return 0;
 }
 
-
 static void bond_setup_by_slave(struct net_device *bond_dev,
 				struct net_device *slave_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 
-	bond_dev->neigh_setup           = slave_dev->neigh_setup;
-	bond_dev->header_ops		= slave_dev->header_ops;
+	bond_dev->header_ops	    = slave_dev->header_ops;
 
 	bond_dev->type		    = slave_dev->type;
 	bond_dev->hard_header_len   = slave_dev->hard_header_len;
@@ -4124,6 +4122,20 @@ static void bond_set_multicast_list(stru
 	read_unlock(&bond->lock);
 }
 
+static int bond_neigh_setup(struct net_device *dev, struct neigh_parms *parms)
+{
+	struct bonding *bond = netdev_priv(dev);
+	struct slave *slave = bond->first_slave;
+
+	if (slave) {
+		const struct net_device_ops *slave_ops
+			= slave->dev->netdev_ops;
+		if (slave_ops->ndo_neigh_setup)
+			return slave_ops->ndo_neigh_setup(dev, parms);
+	}
+	return 0;
+}
+
 /*
  * Change the MTU of all of a master's slaves to match the master
  */
@@ -4490,6 +4502,35 @@ static void bond_set_xmit_hash_policy(st
 	}
 }
 
+static int bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	const struct bonding *bond = netdev_priv(dev);
+
+	switch (bond->params.mode) {
+	case BOND_MODE_ROUNDROBIN:
+		return bond_xmit_roundrobin(skb, dev);
+	case BOND_MODE_ACTIVEBACKUP:
+		return bond_xmit_activebackup(skb, dev);
+	case BOND_MODE_XOR:
+		return bond_xmit_xor(skb, dev);
+	case BOND_MODE_BROADCAST:
+		return bond_xmit_broadcast(skb, dev);
+	case BOND_MODE_8023AD:
+		return bond_3ad_xmit_xor(skb, dev);
+	case BOND_MODE_ALB:
+	case BOND_MODE_TLB:
+		return bond_alb_xmit(skb, dev);
+	default:
+		/* Should never happen, mode already checked */
+		printk(KERN_ERR DRV_NAME ": %s: Error: Unknown bonding mode %d\n",
+		     dev->name, bond->params.mode);
+		WARN_ON_ONCE(1);
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+}
+
+
 /*
  * set bond mode specific net device operations
  */
@@ -4499,28 +4540,22 @@ void bond_set_mode_ops(struct bonding *b
 
 	switch (mode) {
 	case BOND_MODE_ROUNDROBIN:
-		bond_dev->hard_start_xmit = bond_xmit_roundrobin;
 		break;
 	case BOND_MODE_ACTIVEBACKUP:
-		bond_dev->hard_start_xmit = bond_xmit_activebackup;
 		break;
 	case BOND_MODE_XOR:
-		bond_dev->hard_start_xmit = bond_xmit_xor;
 		bond_set_xmit_hash_policy(bond);
 		break;
 	case BOND_MODE_BROADCAST:
-		bond_dev->hard_start_xmit = bond_xmit_broadcast;
 		break;
 	case BOND_MODE_8023AD:
 		bond_set_master_3ad_flags(bond);
-		bond_dev->hard_start_xmit = bond_3ad_xmit_xor;
 		bond_set_xmit_hash_policy(bond);
 		break;
 	case BOND_MODE_ALB:
 		bond_set_master_alb_flags(bond);
 		/* FALLTHRU */
 	case BOND_MODE_TLB:
-		bond_dev->hard_start_xmit = bond_alb_xmit;
 		break;
 	default:
 		/* Should never happen, mode already checked */
@@ -4553,12 +4588,13 @@ static const struct ethtool_ops bond_eth
 static const struct net_device_ops bond_netdev_ops = {
 	.ndo_open		= bond_open,
 	.ndo_stop		= bond_close,
+	.ndo_start_xmit		= bond_start_xmit,
 	.ndo_get_stats		= bond_get_stats,
 	.ndo_do_ioctl		= bond_do_ioctl,
 	.ndo_set_multicast_list	= bond_set_multicast_list,
 	.ndo_change_mtu		= bond_change_mtu,
-	.ndo_validate_addr	= NULL,
 	.ndo_set_mac_address 	= bond_set_mac_address,
+	.ndo_neigh_setup	= bond_neigh_setup,
 	.ndo_vlan_rx_register	= bond_vlan_rx_register,
 	.ndo_vlan_rx_add_vid 	= bond_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= bond_vlan_rx_kill_vid,
--- a/drivers/net/chelsio/cxgb2.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/chelsio/cxgb2.c	2008-11-20 09:14:13.000000000 -0800
@@ -915,7 +915,7 @@ static int t1_set_mac_addr(struct net_de
 }
 
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
-static void vlan_rx_register(struct net_device *dev,
+static void t1_vlan_rx_register(struct net_device *dev,
 				   struct vlan_group *grp)
 {
 	struct adapter *adapter = dev->ml_priv;
@@ -1013,6 +1013,7 @@ void t1_fatal_err(struct adapter *adapte
 static const struct net_device_ops cxgb_netdev_ops = {
 	.ndo_open		= cxgb_open,
 	.ndo_stop		= cxgb_close,
+	.ndo_start_xmit		= t1_start_xmit,
 	.ndo_get_stats		= t1_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_multicast_list	= t1_set_rxmode,
@@ -1020,7 +1021,7 @@ static const struct net_device_ops cxgb_
 	.ndo_change_mtu		= t1_change_mtu,
 	.ndo_set_mac_address	= t1_set_mac_addr,
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
-	.ndo_vlan_rx_register	= vlan_rx_register,
+	.ndo_vlan_rx_register	= t1_vlan_rx_register,
 #endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= t1_netpoll,
@@ -1157,7 +1158,6 @@ static int __devinit init_one(struct pci
 		}
 
 		netdev->netdev_ops = &cxgb_netdev_ops;
-		netdev->hard_start_xmit = t1_start_xmit;
 		netdev->hard_header_len += (adapter->flags & TSO_CAPABLE) ?
 			sizeof(struct cpl_tx_pkt_lso) : sizeof(struct cpl_tx_pkt);
 
--- a/drivers/net/cxgb3/cxgb3_main.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/cxgb3/cxgb3_main.c	2008-11-20 09:14:13.000000000 -0800
@@ -2955,7 +2955,6 @@ static int __devinit init_one(struct pci
 
 		netdev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 		netdev->netdev_ops = &cxgb_netdev_ops;
-		netdev->hard_start_xmit = t3_eth_xmit;
 		SET_ETHTOOL_OPS(netdev, &cxgb_ethtool_ops);
 	}
 
--- a/drivers/net/e100.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/e100.c	2008-11-20 09:14:13.000000000 -0800
@@ -2615,6 +2615,7 @@ static int e100_close(struct net_device 
 static const struct net_device_ops e100_netdev_ops = {
 	.ndo_open		= e100_open,
 	.ndo_stop		= e100_close,
+	.ndo_start_xmit		= e100_xmit_frame,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_multicast_list	= e100_set_multicast_list,
 	.ndo_set_mac_address	= e100_set_mac_address,
@@ -2640,7 +2641,6 @@ static int __devinit e100_probe(struct p
 	}
 
 	netdev->netdev_ops = &e100_netdev_ops;
-	netdev->hard_start_xmit = e100_xmit_frame;
 	SET_ETHTOOL_OPS(netdev, &e100_ethtool_ops);
 	netdev->watchdog_timeo = E100_WATCHDOG_PERIOD;
 	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
--- a/drivers/net/e1000/e1000_main.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/e1000/e1000_main.c	2008-11-20 09:14:13.000000000 -0800
@@ -891,6 +891,7 @@ static int e1000_is_need_ioport(struct p
 static const struct net_device_ops e1000_netdev_ops = {
 	.ndo_open		= e1000_open,
 	.ndo_stop		= e1000_close,
+	.ndo_start_xmit		= e1000_xmit_frame,
 	.ndo_get_stats		= e1000_get_stats,
 	.ndo_set_rx_mode	= e1000_set_rx_mode,
 	.ndo_set_mac_address	= e1000_set_mac,
@@ -1001,7 +1002,6 @@ static int __devinit e1000_probe(struct 
 	}
 
 	netdev->netdev_ops = &e1000_netdev_ops;
-	netdev->hard_start_xmit = &e1000_xmit_frame;
 	e1000_set_ethtool_ops(netdev);
 	netdev->watchdog_timeo = 5 * HZ;
 	netif_napi_add(netdev, &adapter->napi, e1000_clean, 64);
--- a/drivers/net/e1000e/netdev.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/e1000e/netdev.c	2008-11-20 09:14:13.000000000 -0800
@@ -4707,6 +4707,7 @@ static void e1000_eeprom_checks(struct e
 static const struct net_device_ops e1000e_netdev_ops = {
 	.ndo_open		= e1000_open,
 	.ndo_stop		= e1000_close,
+	.ndo_start_xmit		= e1000_xmit_frame,
 	.ndo_get_stats		= e1000_get_stats,
 	.ndo_set_multicast_list	= e1000_set_multi,
 	.ndo_set_mac_address	= e1000_set_mac,
@@ -4822,7 +4823,6 @@ static int __devinit e1000_probe(struct 
 
 	/* construct the net_device struct */
 	netdev->netdev_ops		= &e1000e_netdev_ops;
-	netdev->hard_start_xmit		= &e1000_xmit_frame;
 	e1000e_set_ethtool_ops(netdev);
 	netdev->watchdog_timeo		= 5 * HZ;
 	netif_napi_add(netdev, &adapter->napi, e1000_clean, 64);
--- a/drivers/net/enic/enic_main.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/enic/enic_main.c	2008-11-20 09:14:13.000000000 -0800
@@ -1593,6 +1593,7 @@ static void enic_iounmap(struct enic *en
 static const struct net_device_ops enic_netdev_ops = {
 	.ndo_open		= enic_open,
 	.ndo_stop		= enic_stop,
+	.ndo_start_xmit		= enic_hard_start_xmit,
 	.ndo_get_stats		= enic_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_multicast_list	= enic_set_multicast_list,
@@ -1830,7 +1831,6 @@ static int __devinit enic_probe(struct p
 	}
 
 	netdev->netdev_ops = &enic_netdev_ops;
-	netdev->hard_start_xmit = enic_hard_start_xmit;
 	netdev->watchdog_timeo = 2 * HZ;
 	netdev->ethtool_ops = &enic_ethtool_ops;
 
--- a/drivers/net/forcedeth.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/forcedeth.c	2008-11-20 09:14:13.000000000 -0800
@@ -5412,6 +5412,23 @@ static const struct net_device_ops nv_ne
 	.ndo_open		= nv_open,
 	.ndo_stop		= nv_close,
 	.ndo_get_stats		= nv_get_stats,
+	.ndo_start_xmit		= nv_start_xmit,
+	.ndo_tx_timeout		= nv_tx_timeout,
+	.ndo_change_mtu		= nv_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= nv_set_mac_address,
+	.ndo_set_multicast_list	= nv_set_multicast,
+	.ndo_vlan_rx_register	= nv_vlan_rx_register,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= nv_poll_controller,
+#endif
+};
+
+static const struct net_device_ops nv_netdev_ops_optimized = {
+	.ndo_open		= nv_open,
+	.ndo_stop		= nv_close,
+	.ndo_get_stats		= nv_get_stats,
+	.ndo_start_xmit		= nv_start_xmit_optimized,
 	.ndo_tx_timeout		= nv_tx_timeout,
 	.ndo_change_mtu		= nv_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -5592,11 +5609,10 @@ static int __devinit nv_probe(struct pci
 		goto out_freering;
 
 	if (!nv_optimized(np))
-		dev->hard_start_xmit = nv_start_xmit;
+		dev->netdev_ops = &nv_netdev_ops;
 	else
-		dev->hard_start_xmit = nv_start_xmit_optimized;
+		dev->netdev_ops = &nv_netdev_ops_optimized;
 
-	dev->netdev_ops = &nv_netdev_ops;
 #ifdef CONFIG_FORCEDETH_NAPI
 	netif_napi_add(dev, &np->napi, nv_napi_poll, RX_WORK_PER_LOOP);
 #endif
--- a/drivers/net/ifb.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/ifb.c	2008-11-20 09:14:37.000000000 -0800
@@ -138,15 +138,15 @@ resched:
 }
 
 static const struct net_device_ops ifb_netdev_ops = {
-	.ndo_validate_addr = eth_validate_addr,
 	.ndo_open	= ifb_open,
 	.ndo_stop	= ifb_close,
+	.ndo_start_xmit	= ifb_xmit,
+	.ndo_validate_addr = eth_validate_addr,
 };
 
 static void ifb_setup(struct net_device *dev)
 {
 	/* Initialize the device structure. */
-	dev->hard_start_xmit = ifb_xmit;
 	dev->destructor = free_netdev;
 	dev->netdev_ops = &ifb_netdev_ops;
 
--- a/drivers/net/igb/igb_main.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/igb/igb_main.c	2008-11-20 09:14:13.000000000 -0800
@@ -953,6 +953,7 @@ static int igb_is_need_ioport(struct pci
 static const struct net_device_ops igb_netdev_ops = {
 	.ndo_open 		= igb_open,
 	.ndo_stop		= igb_close,
+	.ndo_start_xmit		= igb_xmit_frame_adv,
 	.ndo_get_stats		= igb_get_stats,
 	.ndo_set_multicast_list	= igb_set_multi,
 	.ndo_set_mac_address	= igb_set_mac,
@@ -1080,7 +1081,6 @@ static int __devinit igb_probe(struct pc
 	netdev->netdev_ops = &igb_netdev_ops;
 	igb_set_ethtool_ops(netdev);
 	netdev->watchdog_timeo = 5 * HZ;
-	netdev->hard_start_xmit = &igb_xmit_frame_adv;
 
 	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
 
--- a/drivers/net/ixgb/ixgb_main.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/ixgb/ixgb_main.c	2008-11-20 09:14:13.000000000 -0800
@@ -324,6 +324,7 @@ ixgb_reset(struct ixgb_adapter *adapter)
 static const struct net_device_ops ixgb_netdev_ops = {
 	.ndo_open 		= ixgb_open,
 	.ndo_stop		= ixgb_close,
+	.ndo_start_xmit		= ixgb_xmit_frame,
 	.ndo_get_stats		= ixgb_get_stats,
 	.ndo_set_multicast_list	= ixgb_set_multi,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -414,7 +415,6 @@ ixgb_probe(struct pci_dev *pdev, const s
 	}
 
 	netdev->netdev_ops = &ixgb_netdev_ops;
-	netdev->hard_start_xmit = &ixgb_xmit_frame;
 	ixgb_set_ethtool_ops(netdev);
 	netdev->watchdog_timeo = 5 * HZ;
 	netif_napi_add(netdev, &adapter->napi, ixgb_clean, 64);
--- a/drivers/net/ixgbe/ixgbe_main.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/ixgbe/ixgbe_main.c	2008-11-20 09:14:13.000000000 -0800
@@ -3730,6 +3730,7 @@ static int ixgbe_link_config(struct ixgb
 static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open 		= ixgbe_open,
 	.ndo_stop		= ixgbe_close,
+	.ndo_start_xmit		= ixgbe_xmit_frame,
 	.ndo_get_stats		= ixgbe_get_stats,
 	.ndo_set_multicast_list	= ixgbe_set_rx_mode,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -3826,7 +3827,6 @@ static int __devinit ixgbe_probe(struct 
 	}
 
 	netdev->netdev_ops = &ixgbe_netdev_ops;
-	netdev->hard_start_xmit = &ixgbe_xmit_frame;
 	ixgbe_set_ethtool_ops(netdev);
 	netdev->watchdog_timeo = 5 * HZ;
 	strcpy(netdev->name, pci_name(pdev));
--- a/drivers/net/loopback.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/loopback.c	2008-11-20 09:14:13.000000000 -0800
@@ -145,6 +145,7 @@ static void loopback_dev_free(struct net
 
 static const struct net_device_ops loopback_ops = {
 	.ndo_init      = loopback_dev_init,
+	.ndo_start_xmit= loopback_xmit,
 	.ndo_get_stats = loopback_get_stats,
 };
 
@@ -155,7 +156,6 @@ static const struct net_device_ops loopb
 static void loopback_setup(struct net_device *dev)
 {
 	dev->mtu		= (16 * 1024) + 20 + 20 + 12;
-	dev->hard_start_xmit	= loopback_xmit;
 	dev->hard_header_len	= ETH_HLEN;	/* 14	*/
 	dev->addr_len		= ETH_ALEN;	/* 6	*/
 	dev->tx_queue_len	= 0;
--- a/drivers/net/macvlan.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/macvlan.c	2008-11-20 09:14:13.000000000 -0800
@@ -140,7 +140,7 @@ static struct sk_buff *macvlan_handle_fr
 	return NULL;
 }
 
-static int macvlan_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int macvlan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	const struct macvlan_dev *vlan = netdev_priv(dev);
 	unsigned int len = skb->len;
@@ -365,6 +365,7 @@ static const struct net_device_ops macvl
 	.ndo_init		= macvlan_init,
 	.ndo_open		= macvlan_open,
 	.ndo_stop		= macvlan_stop,
+	.ndo_start_xmit		= macvlan_start_xmit,
 	.ndo_change_mtu		= macvlan_change_mtu,
 	.ndo_change_rx_flags	= macvlan_change_rx_flags,
 	.ndo_set_mac_address	= macvlan_set_mac_address,
@@ -377,7 +378,6 @@ static void macvlan_setup(struct net_dev
 	ether_setup(dev);
 
 	dev->netdev_ops		= &macvlan_netdev_ops;
-	dev->hard_start_xmit	= macvlan_hard_start_xmit;
 	dev->destructor		= free_netdev;
 	dev->header_ops		= &macvlan_hard_header_ops,
 	dev->ethtool_ops	= &macvlan_ethtool_ops;
--- a/drivers/net/ppp_generic.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/ppp_generic.c	2008-11-20 09:14:13.000000000 -0800
@@ -972,7 +972,8 @@ ppp_net_ioctl(struct net_device *dev, st
 }
 
 static const struct net_device_ops ppp_netdev_ops = {
-	.ndo_do_ioctl = ppp_net_ioctl,
+	.ndo_start_xmit = ppp_start_xmit,
+	.ndo_do_ioctl   = ppp_net_ioctl,
 };
 
 static void ppp_setup(struct net_device *dev)
@@ -2437,8 +2438,6 @@ ppp_create_interface(int unit, int *retp
 	skb_queue_head_init(&ppp->mrq);
 #endif /* CONFIG_PPP_MULTILINK */
 
-	dev->hard_start_xmit = ppp_start_xmit;
-
 	ret = -EEXIST;
 	mutex_lock(&all_ppp_mutex);
 	if (unit < 0)
--- a/drivers/net/skge.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/skge.c	2008-11-20 09:14:13.000000000 -0800
@@ -3805,6 +3805,7 @@ static __exit void skge_debug_cleanup(vo
 static const struct net_device_ops skge_netdev_ops = {
 	.ndo_open		= skge_up,
 	.ndo_stop		= skge_down,
+	.ndo_start_xmit		= skge_xmit_frame,
 	.ndo_do_ioctl		= skge_ioctl,
 	.ndo_get_stats		= skge_get_stats,
 	.ndo_tx_timeout		= skge_tx_timeout,
@@ -3831,7 +3832,6 @@ static struct net_device *skge_devinit(s
 	}
 
 	SET_NETDEV_DEV(dev, &hw->pdev->dev);
-	dev->hard_start_xmit = skge_xmit_frame;
 	dev->netdev_ops = &skge_netdev_ops;
 	dev->ethtool_ops = &skge_ethtool_ops;
 	dev->watchdog_timeo = TX_WATCHDOG;
--- a/drivers/net/sky2.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/sky2.c	2008-11-20 09:14:13.000000000 -0800
@@ -4047,6 +4047,7 @@ static const struct net_device_ops sky2_
   {
 	.ndo_open		= sky2_up,
 	.ndo_stop		= sky2_down,
+	.ndo_start_xmit		= sky2_xmit_frame,
 	.ndo_do_ioctl		= sky2_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= sky2_set_mac_address,
@@ -4063,6 +4064,7 @@ static const struct net_device_ops sky2_
   {
 	.ndo_open		= sky2_up,
 	.ndo_stop		= sky2_down,
+	.ndo_start_xmit		= sky2_xmit_frame,
 	.ndo_do_ioctl		= sky2_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= sky2_set_mac_address,
@@ -4090,7 +4092,6 @@ static __devinit struct net_device *sky2
 
 	SET_NETDEV_DEV(dev, &hw->pdev->dev);
 	dev->irq = hw->pdev->irq;
-	dev->hard_start_xmit = sky2_xmit_frame;
 	SET_ETHTOOL_OPS(dev, &sky2_ethtool_ops);
 	dev->watchdog_timeo = TX_WATCHDOG;
 	dev->netdev_ops = &sky2_netdev_ops[port];
--- a/drivers/net/tg3.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/tg3.c	2008-11-20 09:14:13.000000000 -0800
@@ -12614,19 +12614,6 @@ static int __devinit tg3_get_invariants(
 	else
 		tp->tg3_flags &= ~TG3_FLAG_POLL_SERDES;
 
-	/* All chips before 5787 can get confused if TX buffers
-	 * straddle the 4GB address boundary in some cases.
-	 */
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
-		tp->dev->hard_start_xmit = tg3_start_xmit;
-	else
-		tp->dev->hard_start_xmit = tg3_start_xmit_dma_bug;
-
 	tp->rx_offset = 2;
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 &&
 	    (tp->tg3_flags & TG3_FLAG_PCIX_MODE) != 0)
@@ -13346,6 +13333,26 @@ static void __devinit tg3_init_coal(stru
 static const struct net_device_ops tg3_netdev_ops = {
 	.ndo_open		= tg3_open,
 	.ndo_stop		= tg3_close,
+	.ndo_start_xmit		= tg3_start_xmit,
+	.ndo_get_stats		= tg3_get_stats,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_multicast_list	= tg3_set_rx_mode,
+	.ndo_set_mac_address	= tg3_set_mac_addr,
+	.ndo_do_ioctl		= tg3_ioctl,
+	.ndo_tx_timeout		= tg3_tx_timeout,
+	.ndo_change_mtu		= tg3_change_mtu,
+#if TG3_VLAN_TAG_USED
+	.ndo_vlan_rx_register	= tg3_vlan_rx_register,
+#endif
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= tg3_poll_controller,
+#endif
+};
+
+static const struct net_device_ops tg3_netdev_ops_dma_bug = {
+	.ndo_open		= tg3_open,
+	.ndo_stop		= tg3_close,
+	.ndo_start_xmit		= tg3_start_xmit_dma_bug,
 	.ndo_get_stats		= tg3_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_multicast_list	= tg3_set_rx_mode,
@@ -13475,7 +13482,6 @@ static int __devinit tg3_init_one(struct
 	tp->rx_jumbo_pending = TG3_DEF_RX_JUMBO_RING_PENDING;
 	tp->tx_pending = TG3_DEF_TX_RING_PENDING;
 
-	dev->netdev_ops = &tg3_netdev_ops;
 	netif_napi_add(dev, &tp->napi, tg3_poll, 64);
 	dev->ethtool_ops = &tg3_ethtool_ops;
 	dev->watchdog_timeo = TG3_TX_TIMEOUT;
@@ -13488,6 +13494,17 @@ static int __devinit tg3_init_one(struct
 		goto err_out_iounmap;
 	}
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
+		dev->netdev_ops = &tg3_netdev_ops;
+	else
+		dev->netdev_ops = &tg3_netdev_ops_dma_bug;
+
+
 	/* The EPB bridge inside 5714, 5715, and 5780 and any
 	 * device behind the EPB cannot support DMA addresses > 40-bit.
 	 * On 64-bit systems with IOMMU, use 40-bit dma_mask.
--- a/drivers/net/tun.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/tun.c	2008-11-20 09:14:13.000000000 -0800
@@ -308,13 +308,14 @@ tun_net_change_mtu(struct net_device *de
 static const struct net_device_ops tun_netdev_ops = {
 	.ndo_open		= tun_net_open,
 	.ndo_stop		= tun_net_close,
+	.ndo_start_xmit		= tun_net_xmit,
 	.ndo_change_mtu		= tun_net_change_mtu,
-
 };
 
 static const struct net_device_ops tap_netdev_ops = {
 	.ndo_open		= tun_net_open,
 	.ndo_stop		= tun_net_close,
+	.ndo_start_xmit		= tun_net_xmit,
 	.ndo_change_mtu		= tun_net_change_mtu,
 	.ndo_set_multicast_list	= tun_net_mclist,
 	.ndo_set_mac_address	= eth_mac_addr,
@@ -691,7 +692,6 @@ static void tun_setup(struct net_device 
 	tun->owner = -1;
 	tun->group = -1;
 
-	dev->hard_start_xmit = tun_net_xmit;
 	dev->ethtool_ops = &tun_ethtool_ops;
 	dev->destructor = free_netdev;
 	dev->features |= NETIF_F_NETNS_LOCAL;
--- a/drivers/net/veth.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/veth.c	2008-11-20 09:14:13.000000000 -0800
@@ -265,6 +265,7 @@ static void veth_dev_free(struct net_dev
 static const struct net_device_ops veth_netdev_ops = {
 	.ndo_init	= veth_dev_init,
 	.ndo_open	= veth_open,
+	.ndo_start_xmit = veth_xmit,
 	.ndo_get_stats	= veth_get_stats,
 };
 
@@ -273,7 +274,6 @@ static void veth_setup(struct net_device
 	ether_setup(dev);
 
 	dev->netdev_ops = &veth_netdev_ops;
-	dev->hard_start_xmit = veth_xmit;
 	dev->ethtool_ops = &veth_ethtool_ops;
 	dev->features |= NETIF_F_LLTX;
 	dev->destructor = veth_dev_free;
--- a/drivers/net/via-velocity.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/via-velocity.c	2008-11-20 09:14:13.000000000 -0800
@@ -852,6 +852,7 @@ static int velocity_soft_reset(struct ve
 static const struct net_device_ops velocity_netdev_ops = {
 	.ndo_open		= velocity_open,
 	.ndo_stop		= velocity_close,
+	.ndo_start_xmit		= velocity_xmit,
 	.ndo_get_stats		= velocity_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_multicast_list	= velocity_set_multi,
@@ -971,7 +972,6 @@ static int __devinit velocity_found1(str
 	vptr->phy_id = MII_GET_PHY_ID(vptr->mac_regs);
 
 	dev->irq = pdev->irq;
-	dev->hard_start_xmit = velocity_xmit;
 	dev->netdev_ops = &velocity_netdev_ops;
 	dev->ethtool_ops = &velocity_ethtool_ops;
 
--- a/include/linux/netdevice.h	2008-11-20 09:14:09.000000000 -0800
+++ b/include/linux/netdevice.h	2008-11-20 09:14:13.000000000 -0800
@@ -454,8 +454,8 @@ struct netdev_queue {
 
 /*
  * This structure defines the management hooks for network devices.
- * The following hooks can bed defined and are optonal (can be null)
- * unless otherwise noted.
+ * The following hooks can be defined; unless noted otherwise, they are
+ * optional and can be filled with a null pointer.
  *
  * int (*ndo_init)(struct net_device *dev);
  *     This function is called once when network device is registered.
@@ -475,6 +475,15 @@ struct netdev_queue {
  *     This function is called when network device transistions to the down
  *     state.
  *
+ * int (*ndo_hard_start_xmit)(struct sk_buff *skb, struct net_device *dev);
+ *	Called when a packet needs to be transmitted.
+ *	Must return NETDEV_TX_OK , NETDEV_TX_BUSY, or NETDEV_TX_LOCKED,
+ *	Required can not be NULL.
+ *
+ * u16 (*ndo_select_queue)(struct net_device *dev, struct sk_buff *skb);
+ *	Called to decide which queue to when device supports multiple
+ *	transmit queues.
+ *
  * void (*ndo_change_rx_flags)(struct net_device *dev, int flags);
  *	This function is called to allow device receiver to make
  *	changes to configuration when multicast or promiscious is enabled.
@@ -508,7 +517,7 @@ struct netdev_queue {
  *	of a device. If not defined, any request to change MTU will
  *	will return an error.
  *
- * void (*ndo_tx_timeout) (struct net_device *dev);
+ * void (*ndo_tx_timeout)(struct net_device *dev);
  *	Callback uses when the transmitter has not made any progress
  *	for dev->watchdog ticks.
  *
@@ -538,6 +547,10 @@ struct net_device_ops {
 	void			(*ndo_uninit)(struct net_device *dev);
 	int			(*ndo_open)(struct net_device *dev);
 	int			(*ndo_stop)(struct net_device *dev);
+ 	int			(*ndo_start_xmit) (struct sk_buff *skb,
+						   struct net_device *dev);
+ 	u16			(*ndo_select_queue)(struct net_device *dev,
+						    struct sk_buff *skb);
 #define HAVE_CHANGE_RX_FLAGS
 	void			(*ndo_change_rx_flags)(struct net_device *dev,
 						       int flags);
@@ -557,8 +570,10 @@ struct net_device_ops {
 	int			(*ndo_set_config)(struct net_device *dev,
 					          struct ifmap *map);
 #define HAVE_CHANGE_MTU
-	int			(*ndo_change_mtu)(struct net_device *dev, int new_mtu);
-
+	int			(*ndo_change_mtu)(struct net_device *dev,
+						  int new_mtu);
+	int			(*ndo_neigh_setup)(struct net_device *dev,
+						   struct neigh_parms *);
 #define HAVE_TX_TIMEOUT
 	void			(*ndo_tx_timeout) (struct net_device *dev);
 
@@ -761,18 +776,12 @@ struct net_device
 	/* Number of TX queues currently active in device  */
 	unsigned int		real_num_tx_queues;
 
-	/* Map buffer to appropriate transmit queue */
-	u16			(*select_queue)(struct net_device *dev,
-						struct sk_buff *skb);
-
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
 	spinlock_t		tx_global_lock;
 /*
  * One part is mostly used on xmit path (device)
  */
 	void			*priv;	/* pointer to private data	*/
-	int			(*hard_start_xmit) (struct sk_buff *skb,
-						    struct net_device *dev);
 	/* These may be needed for future network-power-down code. */
 	unsigned long		trans_start;	/* Time (in jiffies) of last Tx	*/
 
@@ -800,8 +809,6 @@ struct net_device
 	/* Called from unregister, can be used to call free_netdev */
 	void (*destructor)(struct net_device *dev);
 
-	int (*neigh_setup)(struct net_device *dev, struct neigh_parms *);
-
 #ifdef CONFIG_NETPOLL
 	struct netpoll_info	*npinfo;
 #endif
@@ -842,6 +849,10 @@ struct net_device
 		void			(*uninit)(struct net_device *dev);
 		int			(*open)(struct net_device *dev);
 		int			(*stop)(struct net_device *dev);
+		int			(*hard_start_xmit) (struct sk_buff *skb,
+							    struct net_device *dev);
+		u16			(*select_queue)(struct net_device *dev,
+							struct sk_buff *skb);
 		void			(*change_rx_flags)(struct net_device *dev,
 							   int flags);
 		void			(*set_rx_mode)(struct net_device *dev);
@@ -854,6 +865,8 @@ struct net_device
 		int			(*set_config)(struct net_device *dev,
 						      struct ifmap *map);
 		int			(*change_mtu)(struct net_device *dev, int new_mtu);
+		int			(*neigh_setup)(struct net_device *dev,
+						       struct neigh_parms *);
 		void			(*tx_timeout) (struct net_device *dev);
 		struct net_device_stats* (*get_stats)(struct net_device *dev);
 		void			(*vlan_rx_register)(struct net_device *dev,
--- a/net/bridge/br_device.c	2008-11-20 09:14:09.000000000 -0800
+++ b/net/bridge/br_device.c	2008-11-20 09:14:13.000000000 -0800
@@ -163,10 +163,11 @@ static const struct ethtool_ops br_ethto
 static const struct net_device_ops br_netdev_ops = {
 	.ndo_open		 = br_dev_open,
 	.ndo_stop		 = br_dev_stop,
-	.ndo_set_mac_address = br_set_mac_address,
-	.ndo_set_multicast_list = br_dev_set_multicast_list,
-	.ndo_change_mtu	 = br_change_mtu,
-	.ndo_do_ioctl	= br_dev_ioctl,
+	.ndo_start_xmit		 = br_dev_xmit,
+	.ndo_set_mac_address	 = br_set_mac_address,
+	.ndo_set_multicast_list	 = br_dev_set_multicast_list,
+	.ndo_change_mtu		 = br_change_mtu,
+	.ndo_do_ioctl		 = br_dev_ioctl,
 };
 
 void br_dev_setup(struct net_device *dev)
@@ -175,7 +176,6 @@ void br_dev_setup(struct net_device *dev
 	ether_setup(dev);
 
 	dev->netdev_ops = &br_netdev_ops;
-	dev->hard_start_xmit = br_dev_xmit;
 	dev->destructor = free_netdev;
 	SET_ETHTOOL_OPS(dev, &br_ethtool_ops);
 	dev->tx_queue_len = 0;
--- a/net/bridge/br_if.c	2008-11-20 09:14:09.000000000 -0800
+++ b/net/bridge/br_if.c	2008-11-20 09:14:13.000000000 -0800
@@ -373,7 +373,7 @@ int br_add_if(struct net_bridge *br, str
 	if (dev->flags & IFF_LOOPBACK || dev->type != ARPHRD_ETHER)
 		return -EINVAL;
 
-	if (dev->hard_start_xmit == br_dev_xmit)
+	if (dev->netdev_ops->ndo_start_xmit == br_dev_xmit)
 		return -ELOOP;
 
 	if (dev->br_port != NULL)
--- a/net/core/dev.c	2008-11-20 09:14:09.000000000 -0800
+++ b/net/core/dev.c	2008-11-20 09:14:13.000000000 -0800
@@ -1660,6 +1660,9 @@ static int dev_gso_segment(struct sk_buf
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq)
 {
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	prefetch(&dev->netdev_ops->ndo_start_xmit);
 	if (likely(!skb->next)) {
 		if (!list_empty(&ptype_all))
 			dev_queue_xmit_nit(skb, dev);
@@ -1671,7 +1674,7 @@ int dev_hard_start_xmit(struct sk_buff *
 				goto gso;
 		}
 
-		return dev->hard_start_xmit(skb, dev);
+		return ops->ndo_start_xmit(skb, dev);
 	}
 
 gso:
@@ -1681,7 +1684,7 @@ gso:
 
 		skb->next = nskb->next;
 		nskb->next = NULL;
-		rc = dev->hard_start_xmit(nskb, dev);
+		rc = ops->ndo_start_xmit(nskb, dev);
 		if (unlikely(rc)) {
 			nskb->next = skb->next;
 			skb->next = nskb;
@@ -1755,10 +1758,11 @@ static u16 simple_tx_hash(struct net_dev
 static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 					struct sk_buff *skb)
 {
+	const struct net_device_ops *ops = dev->netdev_ops;
 	u16 queue_index = 0;
 
-	if (dev->select_queue)
-		queue_index = dev->select_queue(dev, skb);
+	if (ops->ndo_select_queue)
+		queue_index = ops->ndo_select_queue(dev, skb);
 	else if (dev->real_num_tx_queues > 1)
 		queue_index = simple_tx_hash(dev, skb);
 
--- a/net/core/neighbour.c	2008-11-20 09:14:09.000000000 -0800
+++ b/net/core/neighbour.c	2008-11-20 09:14:13.000000000 -0800
@@ -1327,9 +1327,9 @@ struct neigh_parms *neigh_parms_alloc(st
 				      struct neigh_table *tbl)
 {
 	struct neigh_parms *p, *ref;
-	struct net *net;
+	struct net *net = dev_net(dev);
+	const struct net_device_ops *ops = dev->netdev_ops;
 
-	net = dev_net(dev);
 	ref = lookup_neigh_params(tbl, net, 0);
 	if (!ref)
 		return NULL;
@@ -1341,7 +1341,7 @@ struct neigh_parms *neigh_parms_alloc(st
 		p->reachable_time =
 				neigh_rand_reach_time(p->base_reachable_time);
 
-		if (dev->neigh_setup && dev->neigh_setup(dev, p)) {
+		if (ops->ndo_neigh_setup && ops->ndo_neigh_setup(dev, p)) {
 			kfree(p);
 			return NULL;
 		}
--- a/net/core/netpoll.c	2008-11-20 09:14:09.000000000 -0800
+++ b/net/core/netpoll.c	2008-11-20 09:14:13.000000000 -0800
@@ -58,6 +58,7 @@ static void queue_process(struct work_st
 
 	while ((skb = skb_dequeue(&npinfo->txq))) {
 		struct net_device *dev = skb->dev;
+		const struct net_device_ops *ops = dev->netdev_ops;
 		struct netdev_queue *txq;
 
 		if (!netif_device_present(dev) || !netif_running(dev)) {
@@ -71,7 +72,7 @@ static void queue_process(struct work_st
 		__netif_tx_lock(txq, smp_processor_id());
 		if (netif_tx_queue_stopped(txq) ||
 		    netif_tx_queue_frozen(txq) ||
-		    dev->hard_start_xmit(skb, dev) != NETDEV_TX_OK) {
+		    ops->ndo_start_xmit(skb, dev) != NETDEV_TX_OK) {
 			skb_queue_head(&npinfo->txq, skb);
 			__netif_tx_unlock(txq);
 			local_irq_restore(flags);
@@ -273,6 +274,7 @@ static void netpoll_send_skb(struct netp
 	int status = NETDEV_TX_BUSY;
 	unsigned long tries;
 	struct net_device *dev = np->dev;
+	const struct net_device_ops *ops = dev->netdev_ops;
 	struct netpoll_info *npinfo = np->dev->npinfo;
 
 	if (!npinfo || !netif_running(dev) || !netif_device_present(dev)) {
@@ -293,7 +295,7 @@ static void netpoll_send_skb(struct netp
 		     tries > 0; --tries) {
 			if (__netif_tx_trylock(txq)) {
 				if (!netif_tx_queue_stopped(txq))
-					status = dev->hard_start_xmit(skb, dev);
+					status = ops->ndo_start_xmit(skb, dev);
 				__netif_tx_unlock(txq);
 
 				if (status == NETDEV_TX_OK)
--- a/net/core/pktgen.c	2008-11-20 09:14:09.000000000 -0800
+++ b/net/core/pktgen.c	2008-11-20 09:14:13.000000000 -0800
@@ -3357,14 +3357,14 @@ static void pktgen_rem_thread(struct pkt
 
 static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 {
-	struct net_device *odev = NULL;
+	struct net_device *odev = pkt_dev->odev;
+	int (*xmit)(struct sk_buff *, struct net_device *)
+		= odev->netdev_ops->ndo_start_xmit;
 	struct netdev_queue *txq;
 	__u64 idle_start = 0;
 	u16 queue_map;
 	int ret;
 
-	odev = pkt_dev->odev;
-
 	if (pkt_dev->delay_us || pkt_dev->delay_ns) {
 		u64 now;
 
@@ -3445,7 +3445,7 @@ static __inline__ void pktgen_xmit(struc
 
 		atomic_inc(&(pkt_dev->skb->users));
 	      retry_now:
-		ret = odev->hard_start_xmit(pkt_dev->skb, odev);
+		ret = (*xmit)(pkt_dev->skb, odev);
 		if (likely(ret == NETDEV_TX_OK)) {
 			pkt_dev->last_ok = 1;
 			pkt_dev->sofar++;
--- a/drivers/net/8139cp.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/8139cp.c	2008-11-20 09:14:13.000000000 -0800
@@ -1824,6 +1824,7 @@ static const struct net_device_ops cp_ne
 	.ndo_set_multicast_list	= cp_set_rx_mode,
 	.ndo_get_stats		= cp_get_stats,
 	.ndo_do_ioctl		= cp_ioctl,
+	.ndo_start_xmit		= cp_start_xmit,
 	.ndo_tx_timeout		= cp_tx_timeout,
 #if CP_VLAN_TAG_USED
 	.ndo_vlan_rx_register	= cp_vlan_rx_register,
@@ -1949,7 +1950,6 @@ static int cp_init_one (struct pci_dev *
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
 	dev->netdev_ops = &cp_netdev_ops;
-	dev->hard_start_xmit = cp_start_xmit;
 	netif_napi_add(dev, &cp->napi, cp_rx_poll, 16);
 	dev->ethtool_ops = &cp_ethtool_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
--- a/drivers/net/8139too.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/8139too.c	2008-11-20 09:14:13.000000000 -0800
@@ -921,6 +921,7 @@ static const struct net_device_ops rtl81
 	.ndo_stop		= rtl8139_close,
 	.ndo_get_stats		= rtl8139_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_start_xmit		= rtl8139_start_xmit,
 	.ndo_set_multicast_list	= rtl8139_set_rx_mode,
 	.ndo_do_ioctl		= netdev_ioctl,
 	.ndo_tx_timeout		= rtl8139_tx_timeout,
@@ -992,7 +993,6 @@ static int __devinit rtl8139_init_one (s
 	dev->netdev_ops = &rtl8139_netdev_ops;
 	dev->ethtool_ops = &rtl8139_ethtool_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
-	dev->hard_start_xmit = rtl8139_start_xmit;
 	netif_napi_add(dev, &tp->napi, rtl8139_poll, 64);
 
 	/* note: the hardware is not capable of sg/csum/highdma, however
--- a/drivers/net/niu.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/niu.c	2008-11-20 09:14:13.000000000 -0800
@@ -8892,6 +8892,7 @@ static struct net_device * __devinit niu
 static const struct net_device_ops niu_netdev_ops = {
 	.ndo_open		= niu_open,
 	.ndo_stop		= niu_close,
+	.ndo_start_xmit		= niu_start_xmit,
 	.ndo_get_stats		= niu_get_stats,
 	.ndo_set_multicast_list	= niu_set_rx_mode,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -8904,7 +8905,6 @@ static const struct net_device_ops niu_n
 static void __devinit niu_assign_netdev_ops(struct net_device *dev)
 {
 	dev->netdev_ops = &niu_netdev_ops;
-	dev->hard_start_xmit = niu_start_xmit;
 	dev->ethtool_ops = &niu_ethtool_ops;
 	dev->watchdog_timeo = NIU_TX_TIMEOUT;
 }
--- a/drivers/net/r8169.c	2008-11-20 09:14:09.000000000 -0800
+++ b/drivers/net/r8169.c	2008-11-20 09:14:13.000000000 -0800
@@ -1927,6 +1927,7 @@ static const struct net_device_ops rtl81
 	.ndo_open		= rtl8169_open,
 	.ndo_stop		= rtl8169_close,
 	.ndo_get_stats		= rtl8169_get_stats,
+	.ndo_start_xmit		= rtl8169_start_xmit,
 	.ndo_tx_timeout		= rtl8169_tx_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= rtl8169_change_mtu,
@@ -2125,7 +2126,6 @@ rtl8169_init_one(struct pci_dev *pdev, c
 		dev->dev_addr[i] = RTL_R8(MAC0 + i);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
-	dev->hard_start_xmit = rtl8169_start_xmit;
 	SET_ETHTOOL_OPS(dev, &rtl8169_ethtool_ops);
 	dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
 	dev->irq = pdev->irq;

-- 

