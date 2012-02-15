From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH v2 2/2] net: use eth_hw_addr_random() and reset
	addr_assign_type
Date: Wed, 15 Feb 2012 17:45:40 +0100
Message-ID: <1329324340-13461-3-git-send-email-danny.kukawka@bisect.de>
References: <1329324340-13461-1-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev@openvswitch.org, bridge@lists.linux-foundation.org,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>, Danny Kukawka <dkukawka@suse.de>,
	linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1329324340-13461-1-git-send-email-danny.kukawka@bisect.de>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Use eth_hw_addr_random() instead of calling random_ether_addr()
to set addr_assign_type correctly to NET_ADDR_RANDOM.

Reset the state to NET_ADDR_PERM as soon as the MAC get
changed via .ndo_set_mac_address.

v2: adapt to renamed eth_hw_addr_random()

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/dummy.c                              |    3 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
 drivers/net/ethernet/calxeda/xgmac.c             |    3 ++-
 drivers/net/ethernet/marvell/pxa168_eth.c        |    3 ++-
 drivers/net/ethernet/micrel/ks8842.c             |    3 ++-
 drivers/net/ethernet/micrel/ks8851.c             |    3 ++-
 drivers/net/ethernet/micrel/ks8851_mll.c         |    1 +
 drivers/net/ethernet/microchip/enc28j60.c        |    3 ++-
 drivers/net/ethernet/nvidia/forcedeth.c          |    3 ++-
 drivers/net/ethernet/smsc/smsc911x.c             |    3 ++-
 drivers/net/ethernet/tile/tilepro.c              |    3 ++-
 drivers/net/macvlan.c                            |    3 ++-
 drivers/net/team/team.c                          |    3 ++-
 net/bridge/br_device.c                           |    3 ++-
 net/openvswitch/vport-internal_dev.c             |    3 ++-
 16 files changed, 29 insertions(+), 14 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 087648e..d5c6d92 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -47,6 +47,7 @@ static int dummy_set_address(struct net_device *dev, void *p)
 	if (!is_valid_ether_addr(sa->sa_data))
 		return -EADDRNOTAVAIL;
 
+	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
 	memcpy(dev->dev_addr, sa->sa_data, ETH_ALEN);
 	return 0;
 }
@@ -135,7 +136,7 @@ static void dummy_setup(struct net_device *dev)
 	dev->flags &= ~IFF_MULTICAST;
 	dev->features	|= NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO;
 	dev->features	|= NETIF_F_HW_CSUM | NETIF_F_HIGHDMA | NETIF_F_LLTX;
-	random_ether_addr(dev->dev_addr);
+	eth_hw_addr_random(dev);
 }
 
 static int dummy_validate(struct nlattr *tb[], struct nlattr *data[])
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 03f3935..b304f5d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3008,6 +3008,7 @@ int bnx2x_change_mac_addr(struct net_device *dev, void *p)
 			return rc;
 	}
 
+	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 
 	if (netif_running(dev))
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 1e3f978..46edeea 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9605,7 +9605,7 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 
 	if (BP_NOMCP(bp)) {
 		BNX2X_ERROR("warning: random MAC workaround active\n");
-		random_ether_addr(bp->dev->dev_addr);
+		eth_hw_addr_random(bp->dev);
 	} else if (IS_MF(bp)) {
 		val2 = MF_CFG_RD(bp, func_mf_config[func].mac_upper);
 		val = MF_CFG_RD(bp, func_mf_config[func].mac_lower);
diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 1fce186..11f667f 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -1012,7 +1012,7 @@ static int xgmac_open(struct net_device *dev)
 	 * address using the following linux command:
 	 *      ifconfig eth0 hw ether xx:xx:xx:xx:xx:xx  */
 	if (!is_valid_ether_addr(dev->dev_addr)) {
-		random_ether_addr(dev->dev_addr);
+		eth_hw_addr_random(dev);
 		netdev_dbg(priv->dev, "generated random MAC address %pM\n",
 			dev->dev_addr);
 	}
@@ -1482,6 +1482,7 @@ static int xgmac_set_mac_address(struct net_device *dev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
+	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 
 	xgmac_set_mac_addr(ioaddr, dev->dev_addr, 0);
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 953ba58..f90f778 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -629,6 +629,7 @@ static int pxa168_eth_set_mac_address(struct net_device *dev, void *addr)
 	if (!is_valid_ether_addr(sa->sa_data))
 		return -EINVAL;
 	memcpy(oldMac, dev->dev_addr, ETH_ALEN);
+	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
 	memcpy(dev->dev_addr, sa->sa_data, ETH_ALEN);
 	netif_addr_lock_bh(dev);
 	update_hash_table_mac_address(pep, oldMac, dev->dev_addr);
@@ -1522,7 +1523,7 @@ static int pxa168_eth_probe(struct platform_device *pdev)
 	INIT_WORK(&pep->tx_timeout_task, pxa168_eth_tx_timeout_task);
 
 	printk(KERN_INFO "%s:Using random mac address\n", DRIVER_NAME);
-	random_ether_addr(dev->dev_addr);
+	eth_hw_addr_random(dev);
 
 	pep->pd = pdev->dev.platform_data;
 	pep->rx_ring_size = NUM_RX_DESCS;
diff --git a/drivers/net/ethernet/micrel/ks8842.c b/drivers/net/ethernet/micrel/ks8842.c
index 0a85690..0686b93 100644
--- a/drivers/net/ethernet/micrel/ks8842.c
+++ b/drivers/net/ethernet/micrel/ks8842.c
@@ -1080,6 +1080,7 @@ static int ks8842_set_mac(struct net_device *netdev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
+	netdev->addr_assign_type &= ~NET_ADDR_RANDOM;
 	memcpy(netdev->dev_addr, mac, netdev->addr_len);
 
 	ks8842_write_mac_addr(adapter, mac);
@@ -1211,7 +1212,7 @@ static int __devinit ks8842_probe(struct platform_device *pdev)
 		ks8842_read_mac_addr(adapter, netdev->dev_addr);
 
 		if (!is_valid_ether_addr(netdev->dev_addr))
-			random_ether_addr(netdev->dev_addr);
+			eth_hw_addr_random(netdev);
 	}
 
 	id = ks8842_read16(adapter, 32, REG_SW_ID_AND_ENABLE);
diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index 6b35e7d..ce43dd7 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -439,7 +439,7 @@ static void ks8851_init_mac(struct ks8851_net *ks)
 				dev->dev_addr);
 	}
 
-	random_ether_addr(dev->dev_addr);
+	eth_hw_addr_random(dev);
 	ks8851_write_mac_addr(dev);
 }
 
@@ -1050,6 +1050,7 @@ static int ks8851_set_mac_address(struct net_device *dev, void *addr)
 	if (!is_valid_ether_addr(sa->sa_data))
 		return -EADDRNOTAVAIL;
 
+	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
 	memcpy(dev->dev_addr, sa->sa_data, ETH_ALEN);
 	return ks8851_write_mac_addr(dev);
 }
diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index e58e78e..74a0dd9 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -1241,6 +1241,7 @@ static int ks_set_mac_address(struct net_device *netdev, void *paddr)
 	struct sockaddr *addr = paddr;
 	u8 *da;
 
+	netdev->addr_assign_type &= ~NET_ADDR_RANDOM;
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 
 	da = (u8 *)netdev->dev_addr;
diff --git a/drivers/net/ethernet/microchip/enc28j60.c b/drivers/net/ethernet/microchip/enc28j60.c
index 50055e0..40c18fe 100644
--- a/drivers/net/ethernet/microchip/enc28j60.c
+++ b/drivers/net/ethernet/microchip/enc28j60.c
@@ -527,6 +527,7 @@ static int enc28j60_set_mac_address(struct net_device *dev, void *addr)
 	if (!is_valid_ether_addr(address->sa_data))
 		return -EADDRNOTAVAIL;
 
+	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
 	memcpy(dev->dev_addr, address->sa_data, dev->addr_len);
 	return enc28j60_set_hw_macaddr(dev);
 }
@@ -1579,7 +1580,7 @@ static int __devinit enc28j60_probe(struct spi_device *spi)
 		ret = -EIO;
 		goto error_irq;
 	}
-	random_ether_addr(dev->dev_addr);
+	eth_hw_addr_random(dev);
 	enc28j60_set_hw_macaddr(dev);
 
 	/* Board setup must set the relevant edge trigger type;
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 4c4e7f4..ebb5f05 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -3022,6 +3022,7 @@ static int nv_set_mac_address(struct net_device *dev, void *addr)
 
 	/* synchronized against open : rtnl_lock() held by caller */
 	memcpy(dev->dev_addr, macaddr->sa_data, ETH_ALEN);
+	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
 
 	if (netif_running(dev)) {
 		netif_tx_lock_bh(dev);
@@ -5741,7 +5742,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		dev_err(&pci_dev->dev,
 			"Invalid MAC address detected: %pM - Please complain to your hardware vendor.\n",
 			dev->dev_addr);
-		random_ether_addr(dev->dev_addr);
+		eth_hw_addr_random(dev);
 		dev_err(&pci_dev->dev,
 			"Using random MAC address: %pM\n", dev->dev_addr);
 	}
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 24d2df0..5a684ba 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1833,6 +1833,7 @@ static int smsc911x_set_mac_address(struct net_device *dev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
+	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
 
 	spin_lock_irq(&pdata->mac_lock);
@@ -2486,7 +2487,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 				   "Mac Address is read from LAN911x EEPROM");
 		} else {
 			/* eeprom values are invalid, generate random MAC */
-			random_ether_addr(dev->dev_addr);
+			eth_hw_addr_random(dev);
 			smsc911x_set_hw_mac_address(pdata, dev->dev_addr);
 			SMSC_TRACE(pdata, probe,
 				   "MAC Address is set to random_ether_addr");
diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index d9951af..b446b9a 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -2190,6 +2190,7 @@ static int tile_net_set_mac_address(struct net_device *dev, void *p)
 
 	/* ISSUE: Note that "dev_addr" is now a pointer. */
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
 
 	return 0;
 }
@@ -2254,7 +2255,7 @@ static int tile_net_get_mac(struct net_device *dev)
 		 * can't get its MAC address, we are most likely running
 		 * the simulator, so let's generate a random MAC address.
 		 */
-		random_ether_addr(dev->dev_addr);
+		eth_hw_addr_random(dev);
 	}
 
 	return 0;
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 9ea9921..f975afd 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -372,6 +372,7 @@ static int macvlan_set_mac_address(struct net_device *dev, void *p)
 
 	if (!(dev->flags & IFF_UP)) {
 		/* Just copy in the new address */
+		dev->addr_assign_type &= ~NET_ADDR_RANDOM;
 		memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
 	} else {
 		/* Rehash and update the device filters */
@@ -687,7 +688,7 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 		return -EINVAL;
 
 	if (!tb[IFLA_ADDRESS])
-		random_ether_addr(dev->dev_addr);
+		eth_hw_addr_random(dev);
 
 	if (!macvlan_port_exists(lowerdev)) {
 		err = macvlan_port_create(lowerdev);
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 6b678f3..8f81805 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -868,6 +868,7 @@ static int team_set_mac_address(struct net_device *dev, void *p)
 	struct team_port *port;
 	struct sockaddr *addr = p;
 
+	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
 	rcu_read_lock();
 	list_for_each_entry_rcu(port, &team->port_list, list)
@@ -1087,7 +1088,7 @@ static int team_newlink(struct net *src_net, struct net_device *dev,
 	int err;
 
 	if (tb[IFLA_ADDRESS] == NULL)
-		random_ether_addr(dev->dev_addr);
+		eth_hw_addr_random(dev);
 
 	err = register_netdevice(dev);
 	if (err)
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 71773b0..a157bf8 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -171,6 +171,7 @@ static int br_set_mac_address(struct net_device *dev, void *p)
 
 	spin_lock_bh(&br->lock);
 	if (compare_ether_addr(dev->dev_addr, addr->sa_data)) {
+		dev->addr_assign_type &= ~NET_ADDR_RANDOM;
 		memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
 		br_fdb_change_mac_address(br, addr->sa_data);
 		br_stp_change_bridge_id(br, addr->sa_data);
@@ -334,7 +335,7 @@ void br_dev_setup(struct net_device *dev)
 {
 	struct net_bridge *br = netdev_priv(dev);
 
-	random_ether_addr(dev->dev_addr);
+	eth_hw_addr_random(dev);
 	ether_setup(dev);
 
 	dev->netdev_ops = &br_netdev_ops;
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 322b8d2..b6b1d7d 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -66,6 +66,7 @@ static int internal_dev_mac_addr(struct net_device *dev, void *p)
 
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
+	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 	return 0;
 }
@@ -145,7 +146,7 @@ static void do_setup(struct net_device *netdev)
 	netdev->vlan_features = netdev->features;
 	netdev->features |= NETIF_F_HW_VLAN_TX;
 	netdev->hw_features = netdev->features & ~NETIF_F_LLTX;
-	random_ether_addr(netdev->dev_addr);
+	eth_hw_addr_random(netdev);
 }
 
 static struct vport *internal_dev_create(const struct vport_parms *parms)
-- 
1.7.8.3
