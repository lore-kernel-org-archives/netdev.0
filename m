From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 3/4] netxen: remove netxen_nic_niu.c
Date: Mon, 24 Aug 2009 22:23:27 -0700
Message-ID: <1251177808-16450-3-git-send-email-dhananjay@netxen.com>
References: <1251177808-16450-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-1.pathscale.com ([198.186.3.73]:54413 "HELO unm84.unmin.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1754479AbZHYFX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2009 01:23:28 -0400
In-Reply-To: <1251177808-16450-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consolidate all MAC/PHY access functions into netxen_nic_hw.c

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/Makefile          |    2 +-
 drivers/net/netxen/netxen_nic.h      |   27 +++-
 drivers/net/netxen/netxen_nic_ctx.c  |   38 +++++
 drivers/net/netxen/netxen_nic_hw.c   |   79 ++++++++++
 drivers/net/netxen/netxen_nic_init.c |   10 +-
 drivers/net/netxen/netxen_nic_niu.c  |  275 ----------------------------------
 6 files changed, 141 insertions(+), 290 deletions(-)
 delete mode 100644 drivers/net/netxen/netxen_nic_niu.c

diff --git a/drivers/net/netxen/Makefile b/drivers/net/netxen/Makefile
index cf01a91..a70b682 100644
--- a/drivers/net/netxen/Makefile
+++ b/drivers/net/netxen/Makefile
@@ -31,4 +31,4 @@
 obj-$(CONFIG_NETXEN_NIC) := netxen_nic.o
 
 netxen_nic-y := netxen_nic_hw.o netxen_nic_main.o netxen_nic_init.o \
-	netxen_nic_ethtool.o netxen_nic_niu.o netxen_nic_ctx.o
+	netxen_nic_ethtool.o netxen_nic_ctx.o
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 061e8aa..63e2f79 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -684,7 +684,19 @@ struct netxen_recv_context {
 #define NX_CDRP_CMD_GET_STATISTICS          0x0000000f
 #define NX_CDRP_CMD_DELETE_STATISTICS       0x00000010
 #define NX_CDRP_CMD_SET_MTU                 0x00000012
-#define NX_CDRP_CMD_MAX                     0x00000013
+#define NX_CDRP_CMD_READ_PHY			0x00000013
+#define NX_CDRP_CMD_WRITE_PHY			0x00000014
+#define NX_CDRP_CMD_READ_HW_REG			0x00000015
+#define NX_CDRP_CMD_GET_FLOW_CTL		0x00000016
+#define NX_CDRP_CMD_SET_FLOW_CTL		0x00000017
+#define NX_CDRP_CMD_READ_MAX_MTU		0x00000018
+#define NX_CDRP_CMD_READ_MAX_LRO		0x00000019
+#define NX_CDRP_CMD_CONFIGURE_TOE		0x0000001a
+#define NX_CDRP_CMD_FUNC_ATTRIB			0x0000001b
+#define NX_CDRP_CMD_READ_PEXQ_PARAMETERS	0x0000001c
+#define NX_CDRP_CMD_GET_LIC_CAPABILITIES	0x0000001d
+#define NX_CDRP_CMD_READ_MAX_LRO_PER_BOARD	0x0000001e
+#define NX_CDRP_CMD_MAX				0x0000001f
 
 #define NX_RCODE_SUCCESS		0
 #define NX_RCODE_NO_HOST_MEM		1
@@ -1152,8 +1164,8 @@ struct netxen_adapter {
 	int (*set_mtu) (struct netxen_adapter *, int);
 	int (*set_promisc) (struct netxen_adapter *, u32);
 	void (*set_multi) (struct net_device *);
-	int (*phy_read) (struct netxen_adapter *, long reg, u32 *);
-	int (*phy_write) (struct netxen_adapter *, long reg, u32 val);
+	int (*phy_read) (struct netxen_adapter *, u32 reg, u32 *);
+	int (*phy_write) (struct netxen_adapter *, u32 reg, u32 val);
 	int (*init_port) (struct netxen_adapter *, int);
 	int (*stop_port) (struct netxen_adapter *);
 
@@ -1185,15 +1197,11 @@ struct netxen_adapter {
 	const struct firmware *fw;
 };
 
-int netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
-		u32 mode);
 int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port);
 int netxen_niu_disable_xg_port(struct netxen_adapter *adapter);
 
-int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long reg,
-			    __u32 * readval);
-int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter,
-			     long reg, __u32 val);
+int nx_fw_cmd_query_phy(struct netxen_adapter *adapter, u32 reg, u32 *val);
+int nx_fw_cmd_set_phy(struct netxen_adapter *adapter, u32 reg, u32 val);
 
 /* Functions available from netxen_nic_hw.c */
 int netxen_nic_set_mtu_xgb(struct netxen_adapter *adapter, int new_mtu);
@@ -1313,6 +1321,7 @@ int netxen_process_rcv_ring(struct nx_host_sds_ring *sds_ring, int max);
 void netxen_p2_nic_set_multi(struct net_device *netdev);
 void netxen_p3_nic_set_multi(struct net_device *netdev);
 void netxen_p3_free_mac_list(struct netxen_adapter *adapter);
+int netxen_p2_nic_set_promisc(struct netxen_adapter *adapter, u32 mode);
 int netxen_p3_nic_set_promisc(struct netxen_adapter *adapter, u32);
 int netxen_config_intr_coalesce(struct netxen_adapter *adapter);
 int netxen_config_rss(struct netxen_adapter *adapter, int enable);
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index ef846b4..0f42ab9 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -380,6 +380,44 @@ nx_fw_cmd_destroy_tx_ctx(struct netxen_adapter *adapter)
 	}
 }
 
+int
+nx_fw_cmd_query_phy(struct netxen_adapter *adapter, u32 reg, u32 *val)
+{
+	u32 rcode;
+
+	rcode = netxen_issue_cmd(adapter,
+			adapter->ahw.pci_func,
+			NXHAL_VERSION,
+			reg,
+			0,
+			0,
+			NX_CDRP_CMD_READ_PHY);
+
+	if (rcode != NX_RCODE_SUCCESS)
+		return -EIO;
+
+	return NXRD32(adapter, NX_ARG1_CRB_OFFSET);
+}
+
+int
+nx_fw_cmd_set_phy(struct netxen_adapter *adapter, u32 reg, u32 val)
+{
+	u32 rcode;
+
+	rcode = netxen_issue_cmd(adapter,
+			adapter->ahw.pci_func,
+			NXHAL_VERSION,
+			reg,
+			val,
+			0,
+			NX_CDRP_CMD_WRITE_PHY);
+
+	if (rcode != NX_RCODE_SUCCESS)
+		return -EIO;
+
+	return 0;
+}
+
 static u64 ctx_addr_sig_regs[][3] = {
 	{NETXEN_NIC_REG(0x188), NETXEN_NIC_REG(0x18c), NETXEN_NIC_REG(0x1c0)},
 	{NETXEN_NIC_REG(0x190), NETXEN_NIC_REG(0x194), NETXEN_NIC_REG(0x1c4)},
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index cbfe44c..1a8ad62 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -348,6 +348,35 @@ netxen_pcie_sem_unlock(struct netxen_adapter *adapter, int sem)
 	val = NXRD32(adapter, NETXEN_PCIE_REG(PCIE_SEM_UNLOCK(sem)));
 }
 
+int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port)
+{
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
+		NXWR32(adapter, NETXEN_NIU_XGE_CONFIG_1+(0x10000*port), 0x1447);
+		NXWR32(adapter, NETXEN_NIU_XGE_CONFIG_0+(0x10000*port), 0x5);
+	}
+
+	return 0;
+}
+
+/* Disable an XG interface */
+int netxen_niu_disable_xg_port(struct netxen_adapter *adapter)
+{
+	__u32 mac_cfg;
+	u32 port = adapter->physical_port;
+
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		return 0;
+
+	if (port > NETXEN_NIU_MAX_XG_PORTS)
+		return -EINVAL;
+
+	mac_cfg = 0;
+	if (NXWR32(adapter,
+			NETXEN_NIU_XGE_CONFIG_0 + (0x10000 * port), mac_cfg))
+		return -EIO;
+	return 0;
+}
+
 #define NETXEN_UNICAST_ADDR(port, index) \
 	(NETXEN_UNICAST_ADDR_BASE+(port*32)+(index*8))
 #define NETXEN_MCAST_ADDR(port, index) \
@@ -357,6 +386,56 @@ netxen_pcie_sem_unlock(struct netxen_adapter *adapter, int sem)
 #define MAC_LO(addr) \
 	((addr[5] << 16) | (addr[4] << 8) | (addr[3]))
 
+int netxen_p2_nic_set_promisc(struct netxen_adapter *adapter, u32 mode)
+{
+	__u32 reg;
+	u32 port = adapter->physical_port;
+
+	if (port > NETXEN_NIU_MAX_XG_PORTS)
+		return -EINVAL;
+
+	reg = NXRD32(adapter, NETXEN_NIU_XGE_CONFIG_1 + (0x10000 * port));
+	if (mode == NETXEN_NIU_PROMISC_MODE)
+		reg = (reg | 0x2000UL);
+	else
+		reg = (reg & ~0x2000UL);
+
+	if (mode == NETXEN_NIU_ALLMULTI_MODE)
+		reg = (reg | 0x1000UL);
+	else
+		reg = (reg & ~0x1000UL);
+
+	NXWR32(adapter, NETXEN_NIU_XGE_CONFIG_1 + (0x10000 * port), reg);
+
+	return 0;
+}
+
+int netxen_p2_nic_set_mac_addr(struct netxen_adapter *adapter, u8 *addr)
+{
+	u32 mac_hi, mac_lo;
+	u32 reg_hi, reg_lo;
+
+	u8 phy = adapter->physical_port;
+
+	if (phy >= NETXEN_NIU_MAX_XG_PORTS)
+		return -EINVAL;
+
+	mac_lo = ((u32)addr[0] << 16) | ((u32)addr[1] << 24);
+	mac_hi = addr[2] | ((u32)addr[3] << 8) |
+		((u32)addr[4] << 16) | ((u32)addr[5] << 24);
+
+	reg_lo = NETXEN_NIU_XGE_STATION_ADDR_0_1 + (0x10000 * phy);
+	reg_hi = NETXEN_NIU_XGE_STATION_ADDR_0_HI + (0x10000 * phy);
+
+	/* write twice to flush */
+	if (NXWR32(adapter, reg_lo, mac_lo) || NXWR32(adapter, reg_hi, mac_hi))
+		return -EIO;
+	if (NXWR32(adapter, reg_lo, mac_lo) || NXWR32(adapter, reg_hi, mac_hi))
+		return -EIO;
+
+	return 0;
+}
+
 static int
 netxen_nic_enable_mcast_filter(struct netxen_adapter *adapter)
 {
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 313cd26..8d4aa6f 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -328,17 +328,17 @@ void netxen_initialize_adapter_ops(struct netxen_adapter *adapter)
 		adapter->macaddr_set = netxen_p2_nic_set_mac_addr;
 		adapter->set_multi = netxen_p2_nic_set_multi;
 		adapter->set_mtu = netxen_nic_set_mtu_xgb;
-		adapter->set_promisc = netxen_niu_xg_set_promiscuous_mode;
+		adapter->set_promisc = netxen_p2_nic_set_promisc;
 	} else {
 		adapter->set_mtu = nx_fw_cmd_set_mtu;
 		adapter->set_promisc = netxen_p3_nic_set_promisc;
 		adapter->macaddr_set = netxen_p3_nic_set_mac_addr;
 		adapter->set_multi = netxen_p3_nic_set_multi;
-	}
 
-	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
-		adapter->phy_read = netxen_niu_gbe_phy_read;
-		adapter->phy_write = netxen_niu_gbe_phy_write;
+		if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
+			adapter->phy_read = nx_fw_cmd_query_phy;
+			adapter->phy_write = nx_fw_cmd_set_phy;
+		}
 	}
 }
 
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
deleted file mode 100644
index 1392e89..0000000
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ /dev/null
@@ -1,275 +0,0 @@
-/*
- * Copyright (C) 2003 - 2009 NetXen, Inc.
- * All rights reserved.
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version 2
- * of the License, or (at your option) any later version.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
- * MA  02111-1307, USA.
- *
- * The full GNU General Public License is included in this distribution
- * in the file called LICENSE.
- *
- * Contact Information:
- *    info@netxen.com
- * NetXen Inc,
- * 18922 Forge Drive
- * Cupertino, CA 95014-0701
- *
- */
-
-#include "netxen_nic.h"
-
-/*
- * netxen_niu_gbe_phy_read - read a register from the GbE PHY via
- * mii management interface.
- *
- * Note: The MII management interface goes through port 0.
- *	Individual phys are addressed as follows:
- * @param phy  [15:8]  phy id
- * @param reg  [7:0]   register number
- *
- * @returns  0 on success
- *	  -1 on error
- *
- */
-int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long reg,
-				__u32 * readval)
-{
-	long timeout = 0;
-	long result = 0;
-	long restore = 0;
-	long phy = adapter->physical_port;
-	__u32 address;
-	__u32 command;
-	__u32 status;
-	__u32 mac_cfg0;
-
-	if (netxen_phy_lock(adapter) != 0)
-		return -1;
-
-	/*
-	 * MII mgmt all goes through port 0 MAC interface,
-	 * so it cannot be in reset
-	 */
-
-	mac_cfg0 = NXRD32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0));
-	if (netxen_gb_get_soft_reset(mac_cfg0)) {
-		__u32 temp;
-		temp = 0;
-		netxen_gb_tx_reset_pb(temp);
-		netxen_gb_rx_reset_pb(temp);
-		netxen_gb_tx_reset_mac(temp);
-		netxen_gb_rx_reset_mac(temp);
-		if (NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0), temp))
-			return -EIO;
-		restore = 1;
-	}
-
-	address = 0;
-	netxen_gb_mii_mgmt_reg_addr(address, reg);
-	netxen_gb_mii_mgmt_phy_addr(address, phy);
-	if (NXWR32(adapter, NETXEN_NIU_GB_MII_MGMT_ADDR(0), address))
-		return -EIO;
-	command = 0;		/* turn off any prior activity */
-	if (NXWR32(adapter, NETXEN_NIU_GB_MII_MGMT_COMMAND(0), command))
-		return -EIO;
-	/* send read command */
-	netxen_gb_mii_mgmt_set_read_cycle(command);
-	if (NXWR32(adapter, NETXEN_NIU_GB_MII_MGMT_COMMAND(0), command))
-		return -EIO;
-
-	status = 0;
-	do {
-		status = NXRD32(adapter, NETXEN_NIU_GB_MII_MGMT_INDICATE(0));
-		timeout++;
-	} while ((netxen_get_gb_mii_mgmt_busy(status)
-		  || netxen_get_gb_mii_mgmt_notvalid(status))
-		 && (timeout++ < NETXEN_NIU_PHY_WAITMAX));
-
-	if (timeout < NETXEN_NIU_PHY_WAITMAX) {
-		*readval = NXRD32(adapter, NETXEN_NIU_GB_MII_MGMT_STATUS(0));
-		result = 0;
-	} else
-		result = -1;
-
-	if (restore)
-		if (NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0), mac_cfg0))
-			return -EIO;
-	netxen_phy_unlock(adapter);
-	return result;
-}
-
-/*
- * netxen_niu_gbe_phy_write - write a register to the GbE PHY via
- * mii management interface.
- *
- * Note: The MII management interface goes through port 0.
- *	Individual phys are addressed as follows:
- * @param phy      [15:8]  phy id
- * @param reg      [7:0]   register number
- *
- * @returns  0 on success
- *	  -1 on error
- *
- */
-int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter, long reg,
-				__u32 val)
-{
-	long timeout = 0;
-	long result = 0;
-	long restore = 0;
-	long phy = adapter->physical_port;
-	__u32 address;
-	__u32 command;
-	__u32 status;
-	__u32 mac_cfg0;
-
-	/*
-	 * MII mgmt all goes through port 0 MAC interface, so it
-	 * cannot be in reset
-	 */
-
-	mac_cfg0 = NXRD32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0));
-	if (netxen_gb_get_soft_reset(mac_cfg0)) {
-		__u32 temp;
-		temp = 0;
-		netxen_gb_tx_reset_pb(temp);
-		netxen_gb_rx_reset_pb(temp);
-		netxen_gb_tx_reset_mac(temp);
-		netxen_gb_rx_reset_mac(temp);
-
-		if (NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0), temp))
-			return -EIO;
-		restore = 1;
-	}
-
-	command = 0;		/* turn off any prior activity */
-	if (NXWR32(adapter, NETXEN_NIU_GB_MII_MGMT_COMMAND(0), command))
-		return -EIO;
-
-	address = 0;
-	netxen_gb_mii_mgmt_reg_addr(address, reg);
-	netxen_gb_mii_mgmt_phy_addr(address, phy);
-	if (NXWR32(adapter, NETXEN_NIU_GB_MII_MGMT_ADDR(0), address))
-		return -EIO;
-
-	if (NXWR32(adapter, NETXEN_NIU_GB_MII_MGMT_CTRL(0), val))
-		return -EIO;
-
-	status = 0;
-	do {
-		status = NXRD32(adapter, NETXEN_NIU_GB_MII_MGMT_INDICATE(0));
-		timeout++;
-	} while ((netxen_get_gb_mii_mgmt_busy(status))
-		 && (timeout++ < NETXEN_NIU_PHY_WAITMAX));
-
-	if (timeout < NETXEN_NIU_PHY_WAITMAX)
-		result = 0;
-	else
-		result = -EIO;
-
-	/* restore the state of port 0 MAC in case we tampered with it */
-	if (restore)
-		if (NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0), mac_cfg0))
-			return -EIO;
-
-	return result;
-}
-
-int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port)
-{
-	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
-		NXWR32(adapter, NETXEN_NIU_XGE_CONFIG_1+(0x10000*port), 0x1447);
-		NXWR32(adapter, NETXEN_NIU_XGE_CONFIG_0+(0x10000*port), 0x5);
-	}
-
-	return 0;
-}
-
-/* Disable an XG interface */
-int netxen_niu_disable_xg_port(struct netxen_adapter *adapter)
-{
-	__u32 mac_cfg;
-	u32 port = adapter->physical_port;
-
-	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
-		return 0;
-
-	if (port > NETXEN_NIU_MAX_XG_PORTS)
-		return -EINVAL;
-
-	mac_cfg = 0;
-	if (NXWR32(adapter,
-			NETXEN_NIU_XGE_CONFIG_0 + (0x10000 * port), mac_cfg))
-		return -EIO;
-	return 0;
-}
-
-int netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
-		u32 mode)
-{
-	__u32 reg;
-	u32 port = adapter->physical_port;
-
-	if (port > NETXEN_NIU_MAX_XG_PORTS)
-		return -EINVAL;
-
-	reg = NXRD32(adapter, NETXEN_NIU_XGE_CONFIG_1 + (0x10000 * port));
-	if (mode == NETXEN_NIU_PROMISC_MODE)
-		reg = (reg | 0x2000UL);
-	else
-		reg = (reg & ~0x2000UL);
-
-	if (mode == NETXEN_NIU_ALLMULTI_MODE)
-		reg = (reg | 0x1000UL);
-	else
-		reg = (reg & ~0x1000UL);
-
-	NXWR32(adapter, NETXEN_NIU_XGE_CONFIG_1 + (0x10000 * port), reg);
-
-	return 0;
-}
-
-int netxen_p2_nic_set_mac_addr(struct netxen_adapter *adapter, u8 *addr)
-{
-	u32 mac_hi, mac_lo;
-	u32 reg_hi, reg_lo;
-
-	u8 phy = adapter->physical_port;
-	u8 phy_count = (adapter->ahw.port_type == NETXEN_NIC_XGBE) ?
-		NETXEN_NIU_MAX_XG_PORTS : NETXEN_NIU_MAX_GBE_PORTS;
-
-	if (phy >= phy_count)
-		return -EINVAL;
-
-	mac_lo = ((u32)addr[0] << 16) | ((u32)addr[1] << 24);
-	mac_hi = addr[2] | ((u32)addr[3] << 8) |
-		((u32)addr[4] << 16) | ((u32)addr[5] << 24);
-
-	if (adapter->ahw.port_type == NETXEN_NIC_XGBE) {
-		reg_lo = NETXEN_NIU_XGE_STATION_ADDR_0_1 + (0x10000 * phy);
-		reg_hi = NETXEN_NIU_XGE_STATION_ADDR_0_HI + (0x10000 * phy);
-	} else {
-		reg_lo = NETXEN_NIU_GB_STATION_ADDR_1(phy);
-		reg_hi = NETXEN_NIU_GB_STATION_ADDR_0(phy);
-	}
-
-	/* write twice to flush */
-	if (NXWR32(adapter, reg_lo, mac_lo) || NXWR32(adapter, reg_hi, mac_hi))
-		return -EIO;
-	if (NXWR32(adapter, reg_lo, mac_lo) || NXWR32(adapter, reg_hi, mac_hi))
-		return -EIO;
-
-	return 0;
-}
-- 
1.6.0.2

