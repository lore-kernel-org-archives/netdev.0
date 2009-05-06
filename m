From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 3/4] netxen: fix bonding support
Date: Tue,  5 May 2009 22:05:08 -0700
Message-ID: <1241586309-12112-4-git-send-email-dhananjay@netxen.com>
References: <1241586309-12112-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:59286 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751310AbZEFFFN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2009 01:05:13 -0400
In-Reply-To: <1241586309-12112-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Pause traffic during mac addr change.
o Enable setting mac address for NX3031.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    6 +-
 drivers/net/netxen/netxen_nic_hw.c   |   28 ++-----
 drivers/net/netxen/netxen_nic_hw.h   |   10 --
 drivers/net/netxen/netxen_nic_init.c |    7 +-
 drivers/net/netxen/netxen_nic_main.c |   45 +++++++---
 drivers/net/netxen/netxen_nic_niu.c  |  154 +++++++--------------------------
 6 files changed, 82 insertions(+), 168 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index d368e24..9350c86 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1264,9 +1264,10 @@ struct netxen_adapter {
 
 	int (*enable_phy_interrupts) (struct netxen_adapter *);
 	int (*disable_phy_interrupts) (struct netxen_adapter *);
-	int (*macaddr_set) (struct netxen_adapter *, netxen_ethernet_macaddr_t);
+	int (*macaddr_set) (struct netxen_adapter *, u8 *);
 	int (*set_mtu) (struct netxen_adapter *, int);
 	int (*set_promisc) (struct netxen_adapter *, u32);
+	void (*set_multi) (struct net_device *);
 	int (*phy_read) (struct netxen_adapter *, long reg, u32 *);
 	int (*phy_write) (struct netxen_adapter *, long reg, u32 val);
 	int (*init_port) (struct netxen_adapter *, int);
@@ -1331,6 +1332,9 @@ int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter,
 int netxen_nic_set_mtu_xgb(struct netxen_adapter *adapter, int new_mtu);
 int netxen_nic_set_mtu_gb(struct netxen_adapter *adapter, int new_mtu);
 
+int netxen_p2_nic_set_mac_addr(struct netxen_adapter *adapter, u8 *addr);
+int netxen_p3_nic_set_mac_addr(struct netxen_adapter *adapter, u8 *addr);
+
 #define NXRD32(adapter, off) \
 	(adapter->hw_read_wx(adapter, off))
 #define NXWR32(adapter, off, val) \
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index be643ea..86c9e78 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -321,27 +321,6 @@ static unsigned crb_hub_agt[64] =
 
 #define NETXEN_WINDOW_ONE 	0x2000000 /*CRB Window: bit 25 of CRB address */
 
-int netxen_nic_set_mac(struct net_device *netdev, void *p)
-{
-	struct netxen_adapter *adapter = netdev_priv(netdev);
-	struct sockaddr *addr = p;
-
-	if (netif_running(netdev))
-		return -EBUSY;
-
-	if (!is_valid_ether_addr(addr->sa_data))
-		return -EADDRNOTAVAIL;
-
-	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
-
-	/* For P3, MAC addr is not set in NIU */
-	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
-		if (adapter->macaddr_set)
-			adapter->macaddr_set(adapter, addr->sa_data);
-
-	return 0;
-}
-
 #define NETXEN_UNICAST_ADDR(port, index) \
 	(NETXEN_UNICAST_ADDR_BASE+(port*32)+(index*8))
 #define NETXEN_MCAST_ADDR(port, index) \
@@ -643,6 +622,13 @@ void netxen_p3_free_mac_list(struct netxen_adapter *adapter)
 	}
 }
 
+int netxen_p3_nic_set_mac_addr(struct netxen_adapter *adapter, u8 *addr)
+{
+	/* assuming caller has already copied new addr to netdev */
+	netxen_p3_nic_set_multi(adapter->netdev);
+	return 0;
+}
+
 #define	NETXEN_CONFIG_INTR_COALESCE	3
 
 /*
diff --git a/drivers/net/netxen/netxen_nic_hw.h b/drivers/net/netxen/netxen_nic_hw.h
index f20c965..d4e8333 100644
--- a/drivers/net/netxen/netxen_nic_hw.h
+++ b/drivers/net/netxen/netxen_nic_hw.h
@@ -42,8 +42,6 @@ struct netxen_adapter;
 
 void netxen_nic_set_link_parameters(struct netxen_adapter *adapter);
 
-typedef u8 netxen_ethernet_macaddr_t[6];
-
 /* Nibble or Byte mode for phy interface (GbE mode only) */
 
 #define _netxen_crb_get_bit(var, bit)  ((var >> bit) & 0x1)
@@ -395,14 +393,6 @@ int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter,
 int netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
 				       u32 mode);
 
-/* set the MAC address for a given MAC */
-int netxen_niu_macaddr_set(struct netxen_adapter *adapter,
-			   netxen_ethernet_macaddr_t addr);
-
-/* XG version */
-int netxen_niu_xg_macaddr_set(struct netxen_adapter *adapter,
-			      netxen_ethernet_macaddr_t addr);
-
 /* Generic enable for GbE ports. Will detect the speed of the link. */
 int netxen_niu_gbe_init_port(struct netxen_adapter *adapter, int port);
 
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index de9ebbd..4a51c31 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -319,13 +319,15 @@ err_out:
 
 void netxen_initialize_adapter_ops(struct netxen_adapter *adapter)
 {
+	adapter->macaddr_set = netxen_p2_nic_set_mac_addr;
+	adapter->set_multi = netxen_p2_nic_set_multi;
+
 	switch (adapter->ahw.port_type) {
 	case NETXEN_NIC_GBE:
 		adapter->enable_phy_interrupts =
 		    netxen_niu_gbe_enable_phy_interrupts;
 		adapter->disable_phy_interrupts =
 		    netxen_niu_gbe_disable_phy_interrupts;
-		adapter->macaddr_set = netxen_niu_macaddr_set;
 		adapter->set_mtu = netxen_nic_set_mtu_gb;
 		adapter->set_promisc = netxen_niu_set_promiscuous_mode;
 		adapter->phy_read = netxen_niu_gbe_phy_read;
@@ -339,7 +341,6 @@ void netxen_initialize_adapter_ops(struct netxen_adapter *adapter)
 		    netxen_niu_xgbe_enable_phy_interrupts;
 		adapter->disable_phy_interrupts =
 		    netxen_niu_xgbe_disable_phy_interrupts;
-		adapter->macaddr_set = netxen_niu_xg_macaddr_set;
 		adapter->set_mtu = netxen_nic_set_mtu_xgb;
 		adapter->init_port = netxen_niu_xg_init_port;
 		adapter->set_promisc = netxen_niu_xg_set_promiscuous_mode;
@@ -353,6 +354,8 @@ void netxen_initialize_adapter_ops(struct netxen_adapter *adapter)
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
 		adapter->set_mtu = nx_fw_cmd_set_mtu;
 		adapter->set_promisc = netxen_p3_nic_set_promisc;
+		adapter->macaddr_set = netxen_p3_nic_set_mac_addr;
+		adapter->set_multi = netxen_p3_nic_set_multi;
 	}
 }
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index a5577f8..83dadfd 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -442,20 +442,38 @@ netxen_read_mac_addr(struct netxen_adapter *adapter)
 
 	if (!is_valid_ether_addr(netdev->perm_addr))
 		dev_warn(&pdev->dev, "Bad MAC address %pM.\n", netdev->dev_addr);
-	else
-		adapter->macaddr_set(adapter, netdev->dev_addr);
 
 	return 0;
 }
 
+int netxen_nic_set_mac(struct net_device *netdev, void *p)
+{
+	struct netxen_adapter *adapter = netdev_priv(netdev);
+	struct sockaddr *addr = p;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EINVAL;
+
+	if (netif_running(netdev)) {
+		netif_device_detach(netdev);
+		netxen_napi_disable(adapter);
+	}
+
+	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
+	adapter->macaddr_set(adapter, addr->sa_data);
+
+	if (netif_running(netdev)) {
+		netif_device_attach(netdev);
+		netxen_napi_enable(adapter);
+	}
+	return 0;
+}
+
 static void netxen_set_multicast_list(struct net_device *dev)
 {
 	struct netxen_adapter *adapter = netdev_priv(dev);
 
-	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
-		netxen_p3_nic_set_multi(dev);
-	else
-		netxen_p2_nic_set_multi(dev);
+	adapter->set_multi(dev);
 }
 
 static const struct net_device_ops netxen_netdev_ops = {
@@ -782,16 +800,13 @@ netxen_nic_up(struct netxen_adapter *adapter, struct net_device *netdev)
 				netxen_nic_driver_name, adapter->portnum);
 		return err;
 	}
-	adapter->macaddr_set(adapter, netdev->dev_addr);
-
-	netxen_nic_set_link_parameters(adapter);
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
+		adapter->macaddr_set(adapter, netdev->dev_addr);
 
-	netxen_set_multicast_list(netdev);
-	if (adapter->set_mtu)
-		adapter->set_mtu(adapter, netdev->mtu);
+	adapter->set_multi(netdev);
+	adapter->set_mtu(adapter, netdev->mtu);
 
 	adapter->ahw.linkup = 0;
-	mod_timer(&adapter->watchdog_timer, jiffies);
 
 	netxen_napi_enable(adapter);
 
@@ -800,6 +815,10 @@ netxen_nic_up(struct netxen_adapter *adapter, struct net_device *netdev)
 
 	if (adapter->capabilities & NX_FW_CAPABILITY_LINK_NOTIFICATION)
 		netxen_linkevent_request(adapter, 1);
+	else
+		netxen_nic_set_link_parameters(adapter);
+
+	mod_timer(&adapter->watchdog_timer, jiffies);
 
 	return 0;
 }
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index 5e2698b..5941c79 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -402,76 +402,6 @@ int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port)
 	return 0;
 }
 
-/*
- * Return the current station MAC address.
- * Note that the passed-in value must already be in network byte order.
- */
-static int netxen_niu_macaddr_get(struct netxen_adapter *adapter,
-				  netxen_ethernet_macaddr_t * addr)
-{
-	u32 stationhigh;
-	u32 stationlow;
-	int phy = adapter->physical_port;
-	u8 val[8];
-
-	if (addr == NULL)
-		return -EINVAL;
-	if ((phy < 0) || (phy > 3))
-		return -EINVAL;
-
-	stationhigh = NXRD32(adapter, NETXEN_NIU_GB_STATION_ADDR_0(phy));
-	stationlow = NXRD32(adapter, NETXEN_NIU_GB_STATION_ADDR_1(phy));
-	((__le32 *)val)[1] = cpu_to_le32(stationhigh);
-	((__le32 *)val)[0] = cpu_to_le32(stationlow);
-
-	memcpy(addr, val + 2, 6);
-
-	return 0;
-}
-
-/*
- * Set the station MAC address.
- * Note that the passed-in value must already be in network byte order.
- */
-int netxen_niu_macaddr_set(struct netxen_adapter *adapter,
-			   netxen_ethernet_macaddr_t addr)
-{
-	u8 temp[4];
-	u32 val;
-	int phy = adapter->physical_port;
-	unsigned char mac_addr[6];
-	int i;
-
-	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
-		return 0;
-
-	for (i = 0; i < 10; i++) {
-		temp[0] = temp[1] = 0;
-		memcpy(temp + 2, addr, 2);
-		val = le32_to_cpu(*(__le32 *)temp);
-		if (NXWR32(adapter, NETXEN_NIU_GB_STATION_ADDR_1(phy), val))
-			return -EIO;
-
-		memcpy(temp, ((u8 *) addr) + 2, sizeof(__le32));
-		val = le32_to_cpu(*(__le32 *)temp);
-		if (NXWR32(adapter, NETXEN_NIU_GB_STATION_ADDR_0(phy), val))
-			return -2;
-
-		netxen_niu_macaddr_get(adapter,
-				       (netxen_ethernet_macaddr_t *) mac_addr);
-		if (memcmp(mac_addr, addr, 6) == 0)
-			break;
-	}
-
-	if (i == 10) {
-		printk(KERN_ERR "%s: cannot set Mac addr for %s\n",
-		       netxen_nic_driver_name, adapter->netdev->name);
-		printk(KERN_ERR "MAC address set: %pM.\n", addr);
-		printk(KERN_ERR "MAC address get: %pM.\n", mac_addr);
-	}
-	return 0;
-}
-
 /* Disable a GbE interface */
 int netxen_niu_disable_gbe_port(struct netxen_adapter *adapter)
 {
@@ -561,57 +491,6 @@ int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter,
 	return 0;
 }
 
-/*
- * Set the MAC address for an XG port
- * Note that the passed-in value must already be in network byte order.
- */
-int netxen_niu_xg_macaddr_set(struct netxen_adapter *adapter,
-			      netxen_ethernet_macaddr_t addr)
-{
-	int phy = adapter->physical_port;
-	u8 temp[4];
-	u32 val;
-
-	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
-		return 0;
-
-	if ((phy < 0) || (phy > NETXEN_NIU_MAX_XG_PORTS))
-		return -EIO;
-
-	temp[0] = temp[1] = 0;
-	switch (phy) {
-	case 0:
-	    memcpy(temp + 2, addr, 2);
-	    val = le32_to_cpu(*(__le32 *)temp);
-	    if (NXWR32(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_1, val))
-		return -EIO;
-
-	    memcpy(&temp, ((u8 *) addr) + 2, sizeof(__le32));
-	    val = le32_to_cpu(*(__le32 *)temp);
-	    if (NXWR32(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_HI, val))
-		return -EIO;
-	    break;
-
-	case 1:
-	    memcpy(temp + 2, addr, 2);
-	    val = le32_to_cpu(*(__le32 *)temp);
-	    if (NXWR32(adapter, NETXEN_NIU_XG1_STATION_ADDR_0_1, val))
-		return -EIO;
-
-	    memcpy(&temp, ((u8 *) addr) + 2, sizeof(__le32));
-	    val = le32_to_cpu(*(__le32 *)temp);
-	    if (NXWR32(adapter, NETXEN_NIU_XG1_STATION_ADDR_0_HI, val))
-		return -EIO;
-	    break;
-
-	default:
-	    printk(KERN_ERR "Unknown port %d\n", phy);
-	    break;
-	}
-
-	return 0;
-}
-
 int netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
 		u32 mode)
 {
@@ -636,3 +515,36 @@ int netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
 
 	return 0;
 }
+
+int netxen_p2_nic_set_mac_addr(struct netxen_adapter *adapter, u8 *addr)
+{
+	u32 mac_hi, mac_lo;
+	u32 reg_hi, reg_lo;
+
+	u8 phy = adapter->physical_port;
+	u8 phy_count = (adapter->ahw.port_type == NETXEN_NIC_XGBE) ?
+		NETXEN_NIU_MAX_XG_PORTS : NETXEN_NIU_MAX_GBE_PORTS;
+
+	if (phy >= phy_count)
+		return -EINVAL;
+
+	mac_lo = ((u32)addr[0] << 16) | ((u32)addr[1] << 24);
+	mac_hi = addr[2] | ((u32)addr[3] << 8) |
+		((u32)addr[4] << 16) | ((u32)addr[5] << 24);
+
+	if (adapter->ahw.port_type == NETXEN_NIC_XGBE) {
+		reg_lo = NETXEN_NIU_XGE_STATION_ADDR_0_1 + (0x10000 * phy);
+		reg_hi = NETXEN_NIU_XGE_STATION_ADDR_0_HI + (0x10000 * phy);
+	} else {
+		reg_lo = NETXEN_NIU_GB_STATION_ADDR_1(phy);
+		reg_hi = NETXEN_NIU_GB_STATION_ADDR_0(phy);
+	}
+
+	/* write twice to flush */
+	if (NXWR32(adapter, reg_lo, mac_lo) || NXWR32(adapter, reg_hi, mac_hi))
+		return -EIO;
+	if (NXWR32(adapter, reg_lo, mac_lo) || NXWR32(adapter, reg_hi, mac_hi))
+		return -EIO;
+
+	return 0;
+}
-- 
1.6.0.2

