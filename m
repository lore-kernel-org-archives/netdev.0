From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 2/6] netxen: hw multicast filtering
Date: Sat, 12 Jul 2008 12:25:16 -0700
Message-ID: <1215890720-29744-3-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:33978 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752441AbYGLTZV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jul 2008 15:25:21 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable multicast address filtering capabilities in the hardware.
Upto 16 multicast addresses can be programmed for each physical
port. Support "allmulti" mode, if enabled.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    4 +-
 drivers/net/netxen/netxen_nic_hdr.h  |    3 +
 drivers/net/netxen/netxen_nic_hw.c   |  133 +++++++++++++++++++++++++++++++---
 drivers/net/netxen/netxen_nic_hw.h   |   39 +----------
 drivers/net/netxen/netxen_nic_init.c |    2 -
 drivers/net/netxen/netxen_nic_main.c |   10 +++
 drivers/net/netxen/netxen_nic_niu.c  |    5 ++
 7 files changed, 147 insertions(+), 49 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 149bb60..fa1fbab 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -856,6 +856,9 @@ struct netxen_adapter {
 	int portnum;
 	u8 physical_port;
 
+	uint8_t		mc_enabled;
+	uint8_t		max_mc_count;
+
 	struct work_struct watchdog_task;
 	struct timer_list watchdog_timer;
 	struct work_struct  tx_timeout_task;
@@ -909,7 +912,6 @@ struct netxen_adapter {
 	int (*macaddr_set) (struct netxen_adapter *, netxen_ethernet_macaddr_t);
 	int (*set_mtu) (struct netxen_adapter *, int);
 	int (*set_promisc) (struct netxen_adapter *, netxen_niu_prom_mode_t);
-	int (*unset_promisc) (struct netxen_adapter *, netxen_niu_prom_mode_t);
 	int (*phy_read) (struct netxen_adapter *, long reg, u32 *);
 	int (*phy_write) (struct netxen_adapter *, long reg, u32 val);
 	int (*init_port) (struct netxen_adapter *, int);
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index 24d027e..545180b 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -550,6 +550,9 @@ enum {
 #define NETXEN_MULTICAST_ADDR_HI_2	(NETXEN_CRB_NIU + 0x1018)
 #define NETXEN_MULTICAST_ADDR_HI_3	(NETXEN_CRB_NIU + 0x101c)
 
+#define NETXEN_UNICAST_ADDR_BASE	(NETXEN_CRB_NIU + 0x1080)
+#define	NETXEN_MULTICAST_ADDR_BASE	(NETXEN_CRB_NIU + 0x1100)
+
 #define	NETXEN_NIU_GB_MAC_CONFIG_0(I)		\
 	(NETXEN_CRB_NIU + 0x30000 + (I)*0x10000)
 #define	NETXEN_NIU_GB_MAC_CONFIG_1(I)		\
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index fa6d034..5b12cb8 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -154,7 +154,6 @@ int netxen_nic_set_mac(struct net_device *netdev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
-	DPRINTK(INFO, "valid ether addr\n");
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 
 	if (adapter->macaddr_set)
@@ -163,6 +162,91 @@ int netxen_nic_set_mac(struct net_device *netdev, void *p)
 	return 0;
 }
 
+#define NETXEN_UNICAST_ADDR(port, index) \
+	(NETXEN_UNICAST_ADDR_BASE+(port*32)+(index*8))
+#define NETXEN_MCAST_ADDR(port, index) \
+	(NETXEN_MULTICAST_ADDR_BASE+(port*0x80)+(index*8))
+#define MAC_HI(addr) \
+	((addr[2] << 16) | (addr[1] << 8) | (addr[0]))
+#define MAC_LO(addr) \
+	((addr[5] << 16) | (addr[4] << 8) | (addr[3]))
+
+int
+netxen_nic_enable_mcast_filter(struct netxen_adapter *adapter)
+{
+	u32	val = 0;
+	u16 port = adapter->physical_port;
+	u8 *addr = adapter->netdev->dev_addr;
+
+	if (adapter->mc_enabled)
+		return 0;
+
+	netxen_nic_hw_read_wx(adapter, NETXEN_MAC_ADDR_CNTL_REG, &val, 4);
+	val |= (1UL << (28+port));
+	netxen_nic_hw_write_wx(adapter, NETXEN_MAC_ADDR_CNTL_REG, &val, 4);
+
+	/* add broadcast addr to filter */
+	val = 0xffffff;
+	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port, 0), val);
+	netxen_crb_writelit_adapter(adapter,
+			NETXEN_UNICAST_ADDR(port, 0)+4, val);
+
+	/* add station addr to filter */
+	val = MAC_HI(addr);
+	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port, 1), val);
+	val = MAC_LO(addr);
+	netxen_crb_writelit_adapter(adapter,
+			NETXEN_UNICAST_ADDR(port, 1)+4, val);
+
+	adapter->mc_enabled = 1;
+	return 0;
+}
+
+int
+netxen_nic_disable_mcast_filter(struct netxen_adapter *adapter)
+{
+	u32	val = 0;
+	u16 port = adapter->physical_port;
+	u8 *addr = adapter->netdev->dev_addr;
+
+	if (!adapter->mc_enabled)
+		return 0;
+
+	netxen_nic_hw_read_wx(adapter, NETXEN_MAC_ADDR_CNTL_REG, &val, 4);
+	val &= ~(1UL << (28+port));
+	netxen_nic_hw_write_wx(adapter, NETXEN_MAC_ADDR_CNTL_REG, &val, 4);
+
+	val = MAC_HI(addr);
+	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port, 0), val);
+	val = MAC_LO(addr);
+	netxen_crb_writelit_adapter(adapter,
+			NETXEN_UNICAST_ADDR(port, 0)+4, val);
+
+	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port, 1), 0);
+	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port, 1)+4, 0);
+
+	adapter->mc_enabled = 0;
+	return 0;
+}
+
+int
+netxen_nic_set_mcast_addr(struct netxen_adapter *adapter,
+		int index, u8 *addr)
+{
+	u32 hi = 0, lo = 0;
+	u16 port = adapter->physical_port;
+
+	lo = MAC_LO(addr);
+	hi = MAC_HI(addr);
+
+	netxen_crb_writelit_adapter(adapter,
+			NETXEN_MCAST_ADDR(port, index), hi);
+	netxen_crb_writelit_adapter(adapter,
+			NETXEN_MCAST_ADDR(port, index)+4, lo);
+
+	return 0;
+}
+
 /*
  * netxen_nic_set_multi - Multicast
  */
@@ -170,17 +254,48 @@ void netxen_nic_set_multi(struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
 	struct dev_mc_list *mc_ptr;
+	u8 null_addr[6];
+	int index = 0;
+
+	memset(null_addr, 0, 6);
 
-	mc_ptr = netdev->mc_list;
 	if (netdev->flags & IFF_PROMISC) {
-		if (adapter->set_promisc)
-			adapter->set_promisc(adapter,
-					     NETXEN_NIU_PROMISC_MODE);
-	} else {
-		if (adapter->unset_promisc)
-			adapter->unset_promisc(adapter,
-					       NETXEN_NIU_NON_PROMISC_MODE);
+
+		adapter->set_promisc(adapter,
+				NETXEN_NIU_PROMISC_MODE);
+
+		/* Full promiscuous mode */
+		netxen_nic_disable_mcast_filter(adapter);
+
+		return;
 	}
+
+	if (netdev->mc_count == 0) {
+		adapter->set_promisc(adapter,
+				NETXEN_NIU_NON_PROMISC_MODE);
+		netxen_nic_disable_mcast_filter(adapter);
+		return;
+	}
+
+	adapter->set_promisc(adapter, NETXEN_NIU_ALLMULTI_MODE);
+	if (netdev->flags & IFF_ALLMULTI ||
+			netdev->mc_count > adapter->max_mc_count) {
+		netxen_nic_disable_mcast_filter(adapter);
+		return;
+	}
+
+	netxen_nic_enable_mcast_filter(adapter);
+
+	for (mc_ptr = netdev->mc_list; mc_ptr; mc_ptr = mc_ptr->next, index++)
+		netxen_nic_set_mcast_addr(adapter, index, mc_ptr->dmi_addr);
+
+	if (index != netdev->mc_count)
+		printk(KERN_WARNING "%s: %s multicast address count mismatch\n",
+			netxen_nic_driver_name, netdev->name);
+
+	/* Clear out remaining addresses */
+	for (; index < adapter->max_mc_count; index++)
+		netxen_nic_set_mcast_addr(adapter, index, null_addr);
 }
 
 /*
diff --git a/drivers/net/netxen/netxen_nic_hw.h b/drivers/net/netxen/netxen_nic_hw.h
index a3ea1dd..90dd057 100644
--- a/drivers/net/netxen/netxen_nic_hw.h
+++ b/drivers/net/netxen/netxen_nic_hw.h
@@ -432,7 +432,8 @@ typedef enum {
 /* Promiscous mode options (GbE mode only) */
 typedef enum {
 	NETXEN_NIU_PROMISC_MODE = 0,
-	NETXEN_NIU_NON_PROMISC_MODE
+	NETXEN_NIU_NON_PROMISC_MODE,
+	NETXEN_NIU_ALLMULTI_MODE
 } netxen_niu_prom_mode_t;
 
 /*
@@ -478,42 +479,6 @@ typedef enum {
 #define netxen_xg_soft_reset(config_word)	\
 		((config_word) |= 1 << 4)
 
-/*
- * MAC Control Register
- *
- * Bit 0-1   : id_pool0
- * Bit 2     : enable_xtnd0
- * Bit 4-5   : id_pool1
- * Bit 6     : enable_xtnd1
- * Bit 8-9   : id_pool2
- * Bit 10    : enable_xtnd2
- * Bit 12-13 : id_pool3
- * Bit 14    : enable_xtnd3
- * Bit 24-25 : mode_select
- * Bit 28-31 : enable_pool
- */
-
-#define netxen_nic_mcr_set_id_pool0(config, val)	\
-		((config) |= ((val) &0x03))
-#define netxen_nic_mcr_set_enable_xtnd0(config)	\
-		((config) |= 1 << 3)
-#define netxen_nic_mcr_set_id_pool1(config, val)	\
-		((config) |= (((val) & 0x03) << 4))
-#define netxen_nic_mcr_set_enable_xtnd1(config)	\
-		((config) |= 1 << 6)
-#define netxen_nic_mcr_set_id_pool2(config, val)	\
-		((config) |= (((val) & 0x03) << 8))
-#define netxen_nic_mcr_set_enable_xtnd2(config)	\
-		((config) |= 1 << 10)
-#define netxen_nic_mcr_set_id_pool3(config, val)	\
-		((config) |= (((val) & 0x03) << 12))
-#define netxen_nic_mcr_set_enable_xtnd3(config)	\
-		((config) |= 1 << 14)
-#define netxen_nic_mcr_set_mode_select(config, val)	\
-		((config) |= (((val) & 0x03) << 24))
-#define netxen_nic_mcr_set_enable_pool(config, val)	\
-		((config) |= (((val) & 0x0f) << 28))
-
 /* Set promiscuous mode for a GbE interface */
 int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter,
 				    netxen_niu_prom_mode_t mode);
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 37fd6bc..e35f1a4 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -195,7 +195,6 @@ void netxen_initialize_adapter_ops(struct netxen_adapter *adapter)
 		adapter->macaddr_set = netxen_niu_macaddr_set;
 		adapter->set_mtu = netxen_nic_set_mtu_gb;
 		adapter->set_promisc = netxen_niu_set_promiscuous_mode;
-		adapter->unset_promisc = netxen_niu_set_promiscuous_mode;
 		adapter->phy_read = netxen_niu_gbe_phy_read;
 		adapter->phy_write = netxen_niu_gbe_phy_write;
 		adapter->init_niu = netxen_nic_init_niu_gb;
@@ -212,7 +211,6 @@ void netxen_initialize_adapter_ops(struct netxen_adapter *adapter)
 		adapter->set_mtu = netxen_nic_set_mtu_xgb;
 		adapter->init_port = netxen_niu_xg_init_port;
 		adapter->set_promisc = netxen_niu_xg_set_promiscuous_mode;
-		adapter->unset_promisc = netxen_niu_xg_set_promiscuous_mode;
 		adapter->stop_port = netxen_niu_disable_xg_port;
 		break;
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 91b02eb..0ec6e7e 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -377,6 +377,8 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter->portnum = pci_func_id;
 	adapter->status   &= ~NETXEN_NETDEV_STATUS;
 	adapter->rx_csum = 1;
+	adapter->max_mc_count = 16;
+	adapter->mc_enabled = 0;
 
 	netdev->open		   = netxen_nic_open;
 	netdev->stop		   = netxen_nic_close;
@@ -589,6 +591,14 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			msleep(1);
 			netxen_load_firmware(adapter);
 			netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
+
+			/* Initialize multicast addr pool owners */
+			val = 0x7654;
+			if (adapter->ahw.board_type == NETXEN_NIC_XGBE)
+				val |= 0x0f000000;
+			netxen_crb_writelit_adapter(adapter,
+					NETXEN_MAC_ADDR_CNTL_REG, val);
+
 		}
 
 		/* clear the register for future unloads/loads */
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index a3bc7cc..d9664a0 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -909,6 +909,11 @@ int netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
 	else
 		reg = (reg & ~0x2000UL);
 
+	if (mode == NETXEN_NIU_ALLMULTI_MODE)
+		reg = (reg | 0x1000UL);
+	else
+		reg = (reg & ~0x1000UL);
+
 	netxen_crb_writelit_adapter(adapter,
 		NETXEN_NIU_XGE_CONFIG_1 + (0x10000 * port), reg);
 
-- 
1.5.4.3

