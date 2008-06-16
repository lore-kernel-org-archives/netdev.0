From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 2/4] netxen: remove global physical_port array
Date: Sun, 15 Jun 2008 22:59:44 -0700
Message-ID: <1213595986-1929-3-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:32889 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752132AbYFPGis (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 02:38:48 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Store physical port number in netxen_adapter structure.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h         |    2 +-
 drivers/net/netxen/netxen_nic_ethtool.c |    6 +++---
 drivers/net/netxen/netxen_nic_hw.c      |    8 ++++----
 drivers/net/netxen/netxen_nic_isr.c     |    4 ++--
 drivers/net/netxen/netxen_nic_main.c    |    4 +---
 drivers/net/netxen/netxen_nic_niu.c     |   22 +++++++++++-----------
 6 files changed, 22 insertions(+), 24 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 8cb29f5..ec2ed89 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -863,6 +863,7 @@ struct netxen_adapter {
 	unsigned char mac_addr[ETH_ALEN];
 	int mtu;
 	int portnum;
+	u8 physical_port;
 
 	struct work_struct watchdog_task;
 	struct timer_list watchdog_timer;
@@ -1169,5 +1170,4 @@ extern int netxen_rom_fast_read(struct netxen_adapter *adapter, int addr,
 
 extern struct ethtool_ops netxen_nic_ethtool_ops;
 
-extern int physical_port[];	/* physical port # from virtual port.*/
 #endif				/* __NETXEN_NIC_H_ */
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 6e98d83..723487b 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -369,7 +369,7 @@ netxen_nic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 		for (i = 3; niu_registers[mode].reg[i - 3] != -1; i++) {
 			/* GB: port specific registers */
 			if (mode == 0 && i >= 19)
-				window = physical_port[adapter->portnum] *
+				window = adapter->physical_port *
 					NETXEN_NIC_PORT_WINDOW;
 
 			NETXEN_NIC_LOCKED_READ_REG(niu_registers[mode].
@@ -527,7 +527,7 @@ netxen_nic_get_pauseparam(struct net_device *dev,
 {
 	struct netxen_adapter *adapter = netdev_priv(dev);
 	__u32 val;
-	int port = physical_port[adapter->portnum];
+	int port = adapter->physical_port;
 
 	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
 		if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
@@ -573,7 +573,7 @@ netxen_nic_set_pauseparam(struct net_device *dev,
 {
 	struct netxen_adapter *adapter = netdev_priv(dev);
 	__u32 val;
-	int port = physical_port[adapter->portnum];
+	int port = adapter->physical_port;
 	/* read mode */
 	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
 		if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index af73564..30316a8 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -1032,15 +1032,15 @@ int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 int netxen_nic_set_mtu_gb(struct netxen_adapter *adapter, int new_mtu)
 {
 	netxen_nic_write_w0(adapter,
-			NETXEN_NIU_GB_MAX_FRAME_SIZE(
-				physical_port[adapter->portnum]), new_mtu);
+		NETXEN_NIU_GB_MAX_FRAME_SIZE(adapter->physical_port),
+		new_mtu);
 	return 0;
 }
 
 int netxen_nic_set_mtu_xgb(struct netxen_adapter *adapter, int new_mtu)
 {
 	new_mtu += NETXEN_NIU_HDRSIZE + NETXEN_NIU_TLRSIZE;
-	if (physical_port[adapter->portnum] == 0)
+	if (adapter->physical_port == 0)
 		netxen_nic_write_w0(adapter, NETXEN_NIU_XGE_MAX_FRAME_SIZE,
 				new_mtu);
 	else
@@ -1051,7 +1051,7 @@ int netxen_nic_set_mtu_xgb(struct netxen_adapter *adapter, int new_mtu)
 
 void netxen_nic_init_niu_gb(struct netxen_adapter *adapter)
 {
-	netxen_niu_gbe_init_port(adapter, physical_port[adapter->portnum]);
+	netxen_niu_gbe_init_port(adapter, adapter->physical_port);
 }
 
 void
diff --git a/drivers/net/netxen/netxen_nic_isr.c b/drivers/net/netxen/netxen_nic_isr.c
index f487615..96cec41 100644
--- a/drivers/net/netxen/netxen_nic_isr.c
+++ b/drivers/net/netxen/netxen_nic_isr.c
@@ -145,7 +145,7 @@ static void netxen_nic_isr_other(struct netxen_adapter *adapter)
 
 	/* verify the offset */
 	val = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_XG_STATE));
-	val = val >> physical_port[adapter->portnum];
+	val = val >> adapter->physical_port;
 	if (val == adapter->ahw.qg_linksup)
 		return;
 
@@ -199,7 +199,7 @@ void netxen_nic_xgbe_handle_phy_intr(struct netxen_adapter *adapter)
 
 	/* WINDOW = 1 */
 	val = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_XG_STATE));
-	val >>= (physical_port[adapter->portnum] * 8);
+	val >>= (adapter->physical_port * 8);
 	val &= 0xff;
 
 	if (adapter->ahw.xg_linkup == 1 && val != XG_LINK_UP) {
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 5a2fd21..f903de0 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -70,8 +70,6 @@ static void netxen_nic_poll_controller(struct net_device *netdev);
 static irqreturn_t netxen_intr(int irq, void *data);
 static irqreturn_t netxen_msi_intr(int irq, void *data);
 
-int physical_port[] = {0, 1, 2, 3};
-
 /*  PCI Device ID Table  */
 static struct pci_device_id netxen_pci_tbl[] __devinitdata = {
 	{PCI_DEVICE(0x4040, 0x0001)},
@@ -647,7 +645,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 */
 	i = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_V2P(adapter->portnum)));
 	if (i != 0x55555555)
-		physical_port[adapter->portnum] = i;
+		adapter->physical_port = i;
 
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index 1c852a7..a3bc7cc 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -94,7 +94,7 @@ int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long reg,
 	long timeout = 0;
 	long result = 0;
 	long restore = 0;
-	long phy = physical_port[adapter->portnum];
+	long phy = adapter->physical_port;
 	__u32 address;
 	__u32 command;
 	__u32 status;
@@ -190,7 +190,7 @@ int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter, long reg,
 	long timeout = 0;
 	long result = 0;
 	long restore = 0;
-	long phy = physical_port[adapter->portnum];
+	long phy = adapter->physical_port;
 	__u32 address;
 	__u32 command;
 	__u32 status;
@@ -456,7 +456,7 @@ int netxen_niu_gbe_init_port(struct netxen_adapter *adapter, int port)
 
 int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port)
 {
-	u32 portnum = physical_port[adapter->portnum];
+	u32 portnum = adapter->physical_port;
 
 	netxen_crb_writelit_adapter(adapter,
 		NETXEN_NIU_XGE_CONFIG_1+(0x10000*portnum), 0x1447);
@@ -573,7 +573,7 @@ static int netxen_niu_macaddr_get(struct netxen_adapter *adapter,
 {
 	u32 stationhigh;
 	u32 stationlow;
-	int phy = physical_port[adapter->portnum];
+	int phy = adapter->physical_port;
 	u8 val[8];
 
 	if (addr == NULL)
@@ -604,7 +604,7 @@ int netxen_niu_macaddr_set(struct netxen_adapter *adapter,
 {
 	u8 temp[4];
 	u32 val;
-	int phy = physical_port[adapter->portnum];
+	int phy = adapter->physical_port;
 	unsigned char mac_addr[6];
 	int i;
 	DECLARE_MAC_BUF(mac);
@@ -724,7 +724,7 @@ int netxen_niu_enable_gbe_port(struct netxen_adapter *adapter,
 int netxen_niu_disable_gbe_port(struct netxen_adapter *adapter)
 {
 	__u32 mac_cfg0;
-	u32 port = physical_port[adapter->portnum];
+	u32 port = adapter->physical_port;
 
 	if (port > NETXEN_NIU_MAX_GBE_PORTS)
 		return -EINVAL;
@@ -740,7 +740,7 @@ int netxen_niu_disable_gbe_port(struct netxen_adapter *adapter)
 int netxen_niu_disable_xg_port(struct netxen_adapter *adapter)
 {
 	__u32 mac_cfg;
-	u32 port = physical_port[adapter->portnum];
+	u32 port = adapter->physical_port;
 
 	if (port > NETXEN_NIU_MAX_XG_PORTS)
 		return -EINVAL;
@@ -757,7 +757,7 @@ int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter,
 				    netxen_niu_prom_mode_t mode)
 {
 	__u32 reg;
-	u32 port = physical_port[adapter->portnum];
+	u32 port = adapter->physical_port;
 
 	if (port > NETXEN_NIU_MAX_GBE_PORTS)
 		return -EINVAL;
@@ -814,7 +814,7 @@ int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter,
 int netxen_niu_xg_macaddr_set(struct netxen_adapter *adapter,
 			      netxen_ethernet_macaddr_t addr)
 {
-	int phy = physical_port[adapter->portnum];
+	int phy = adapter->physical_port;
 	u8 temp[4];
 	u32 val;
 
@@ -867,7 +867,7 @@ int netxen_niu_xg_macaddr_set(struct netxen_adapter *adapter,
 int netxen_niu_xg_macaddr_get(struct netxen_adapter *adapter,
 			      netxen_ethernet_macaddr_t * addr)
 {
-	int phy = physical_port[adapter->portnum];
+	int phy = adapter->physical_port;
 	u32 stationhigh;
 	u32 stationlow;
 	u8 val[8];
@@ -896,7 +896,7 @@ int netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
 				       netxen_niu_prom_mode_t mode)
 {
 	__u32 reg;
-	u32 port = physical_port[adapter->portnum];
+	u32 port = adapter->physical_port;
 
 	if (port > NETXEN_NIU_MAX_XG_PORTS)
 		return -EINVAL;
-- 
1.5.4.3

