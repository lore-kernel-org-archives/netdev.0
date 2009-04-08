From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 08/11] netxen: sanitize function names
Date: Wed,  8 Apr 2009 01:50:45 -0700
Message-ID: <1239180648-29842-9-git-send-email-dhananjay@netxen.com>
References: <1239180648-29842-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:49850 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762484AbZDHIu6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2009 04:50:58 -0400
In-Reply-To: <1239180648-29842-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace superfluous wrapper functions with two macros:

NXWR32 replaces netxen_nic_reg_write, netxen_nic_write_w0,
netxen_nic_read_w1, netxen_crb_writelit_adapter.

NXRD32 replaces netxen_nic_reg_read, netxen_nic_read_w0,
netxen_nic_read_w1.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h         |   19 +--
 drivers/net/netxen/netxen_nic_ctx.c     |   29 ++---
 drivers/net/netxen/netxen_nic_ethtool.c |   59 +++++------
 drivers/net/netxen/netxen_nic_hw.c      |  187 ++++++++++---------------------
 drivers/net/netxen/netxen_nic_init.c    |   93 +++++++---------
 drivers/net/netxen/netxen_nic_main.c    |   83 +++++---------
 drivers/net/netxen/netxen_nic_niu.c     |  169 ++++++++++------------------
 7 files changed, 233 insertions(+), 406 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 1e4190d..f13fd02 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1312,12 +1312,11 @@ int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter,
 /* Functions available from netxen_nic_hw.c */
 int netxen_nic_set_mtu_xgb(struct netxen_adapter *adapter, int new_mtu);
 int netxen_nic_set_mtu_gb(struct netxen_adapter *adapter, int new_mtu);
-void netxen_nic_reg_write(struct netxen_adapter *adapter, u64 off, u32 val);
-int netxen_nic_reg_read(struct netxen_adapter *adapter, u64 off);
-void netxen_nic_write_w0(struct netxen_adapter *adapter, u32 index, u32 value);
-u32 netxen_nic_read_w0(struct netxen_adapter *adapter, u32 index);
-void netxen_nic_write_w1(struct netxen_adapter *adapter, u32 index, u32 value);
-u32 netxen_nic_read_w1(struct netxen_adapter *adapter, u32 index);
+
+#define NXRD32(adapter, off) \
+	(adapter->hw_read_wx(adapter, off))
+#define NXWR32(adapter, off, val) \
+	(adapter->hw_write_wx(adapter, off, val))
 
 int netxen_nic_get_board_info(struct netxen_adapter *adapter);
 void netxen_nic_get_firmware_info(struct netxen_adapter *adapter);
@@ -1348,8 +1347,6 @@ int netxen_nic_pci_mem_read_2M(struct netxen_adapter *adapter,
 		u64 off, void *data, int size);
 int netxen_nic_pci_mem_write_2M(struct netxen_adapter *adapter,
 		u64 off, void *data, int size);
-void netxen_crb_writelit_adapter(struct netxen_adapter *adapter,
-				 unsigned long off, int data);
 int netxen_nic_pci_write_immediate_2M(struct netxen_adapter *adapter,
 		u64 off, u32 data);
 u32 netxen_nic_pci_read_immediate_2M(struct netxen_adapter *adapter, u64 off);
@@ -1478,8 +1475,7 @@ dma_watchdog_shutdown_request(struct netxen_adapter *adapter)
 
 	/* Send the disable request */
 	netxen_set_dma_watchdog_disable_req(ctrl);
-	netxen_crb_writelit_adapter(adapter,
-		NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL), ctrl);
+	NXWR32(adapter, NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL), ctrl);
 
 	return 0;
 }
@@ -1509,8 +1505,7 @@ dma_watchdog_wakeup(struct netxen_adapter *adapter)
 	/* send the wakeup request */
 	netxen_set_dma_watchdog_enable_req(ctrl);
 
-	netxen_crb_writelit_adapter(adapter,
-		NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL), ctrl);
+	NXWR32(adapter, NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL), ctrl);
 
 	return 0;
 }
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index 7a13ee8..32f4839 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -41,8 +41,7 @@ netxen_api_lock(struct netxen_adapter *adapter)
 
 	for (;;) {
 		/* Acquire PCIE HW semaphore5 */
-		done = netxen_nic_read_w0(adapter,
-			NETXEN_PCIE_REG(PCIE_SEM5_LOCK));
+		done = NXRD32(adapter, NETXEN_PCIE_REG(PCIE_SEM5_LOCK));
 
 		if (done == 1)
 			break;
@@ -56,7 +55,7 @@ netxen_api_lock(struct netxen_adapter *adapter)
 	}
 
 #if 0
-	netxen_nic_write_w1(adapter,
+	NXWR32(adapter,
 		NETXEN_API_LOCK_ID, NX_OS_API_LOCK_DRIVER);
 #endif
 	return 0;
@@ -66,8 +65,7 @@ static int
 netxen_api_unlock(struct netxen_adapter *adapter)
 {
 	/* Release PCIE HW semaphore5 */
-	netxen_nic_read_w0(adapter,
-		NETXEN_PCIE_REG(PCIE_SEM5_UNLOCK));
+	NXRD32(adapter, NETXEN_PCIE_REG(PCIE_SEM5_UNLOCK));
 	return 0;
 }
 
@@ -84,7 +82,7 @@ netxen_poll_rsp(struct netxen_adapter *adapter)
 		if (++timeout > NX_OS_CRB_RETRY_COUNT)
 			return NX_CDRP_RSP_TIMEOUT;
 
-		rsp = netxen_nic_read_w1(adapter, NX_CDRP_CRB_OFFSET);
+		rsp = NXRD32(adapter, NX_CDRP_CRB_OFFSET);
 	} while (!NX_CDRP_IS_RSP(rsp));
 
 	return rsp;
@@ -104,16 +102,15 @@ netxen_issue_cmd(struct netxen_adapter *adapter,
 	if (netxen_api_lock(adapter))
 		return NX_RCODE_TIMEOUT;
 
-	netxen_nic_write_w1(adapter, NX_SIGN_CRB_OFFSET, signature);
+	NXWR32(adapter, NX_SIGN_CRB_OFFSET, signature);
 
-	netxen_nic_write_w1(adapter, NX_ARG1_CRB_OFFSET, arg1);
+	NXWR32(adapter, NX_ARG1_CRB_OFFSET, arg1);
 
-	netxen_nic_write_w1(adapter, NX_ARG2_CRB_OFFSET, arg2);
+	NXWR32(adapter, NX_ARG2_CRB_OFFSET, arg2);
 
-	netxen_nic_write_w1(adapter, NX_ARG3_CRB_OFFSET, arg3);
+	NXWR32(adapter, NX_ARG3_CRB_OFFSET, arg3);
 
-	netxen_nic_write_w1(adapter, NX_CDRP_CRB_OFFSET,
-			NX_CDRP_FORM_CMD(cmd));
+	NXWR32(adapter, NX_CDRP_CRB_OFFSET, NX_CDRP_FORM_CMD(cmd));
 
 	rsp = netxen_poll_rsp(adapter);
 
@@ -123,7 +120,7 @@ netxen_issue_cmd(struct netxen_adapter *adapter,
 
 		rcode = NX_RCODE_TIMEOUT;
 	} else if (rsp == NX_CDRP_RSP_FAIL) {
-		rcode = netxen_nic_read_w1(adapter, NX_ARG1_CRB_OFFSET);
+		rcode = NXRD32(adapter, NX_ARG1_CRB_OFFSET);
 
 		printk(KERN_ERR "%s: failed card response code:0x%x\n",
 				netxen_nic_driver_name, rcode);
@@ -515,11 +512,11 @@ netxen_init_old_ctx(struct netxen_adapter *adapter)
 	adapter->ctx_desc->sts_ring_addr = cpu_to_le64(sds_ring->phys_addr);
 	adapter->ctx_desc->sts_ring_size = cpu_to_le32(sds_ring->num_desc);
 
-	adapter->hw_write_wx(adapter, CRB_CTX_ADDR_REG_LO(func_id),
+	NXWR32(adapter, CRB_CTX_ADDR_REG_LO(func_id),
 			lower32(adapter->ctx_desc_phys_addr));
-	adapter->hw_write_wx(adapter, CRB_CTX_ADDR_REG_HI(func_id),
+	NXWR32(adapter, CRB_CTX_ADDR_REG_HI(func_id),
 			upper32(adapter->ctx_desc_phys_addr));
-	adapter->hw_write_wx(adapter, CRB_CTX_SIGNATURE_REG(func_id),
+	NXWR32(adapter, CRB_CTX_SIGNATURE_REG(func_id),
 			NETXEN_CTX_SIGNATURE | func_id);
 	return 0;
 }
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 6c5a111..a452b2f 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -92,12 +92,9 @@ netxen_nic_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 	strncpy(drvinfo->driver, netxen_nic_driver_name, 32);
 	strncpy(drvinfo->version, NETXEN_NIC_LINUX_VERSIONID, 32);
 	write_lock_irqsave(&adapter->adapter_lock, flags);
-	fw_major = adapter->hw_read_wx(adapter,
-					NETXEN_FW_VERSION_MAJOR);
-	fw_minor = adapter->hw_read_wx(adapter,
-					NETXEN_FW_VERSION_MINOR);
-	fw_build = adapter->hw_read_wx(adapter,
-					NETXEN_FW_VERSION_SUB);
+	fw_major = NXRD32(adapter, NETXEN_FW_VERSION_MAJOR);
+	fw_minor = NXRD32(adapter, NETXEN_FW_VERSION_MINOR);
+	fw_build = NXRD32(adapter, NETXEN_FW_VERSION_SUB);
 	write_unlock_irqrestore(&adapter->adapter_lock, flags);
 	sprintf(drvinfo->fw_version, "%d.%d.%d", fw_major, fw_minor, fw_build);
 
@@ -135,7 +132,7 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	} else if (adapter->ahw.port_type == NETXEN_NIC_XGBE) {
 		u32 val;
 
-		val = adapter->hw_read_wx(adapter, NETXEN_PORT_MODE_ADDR);
+		val = NXRD32(adapter, NETXEN_PORT_MODE_ADDR);
 		if (val == NETXEN_PORT_MODE_802_3_AP) {
 			ecmd->supported = SUPPORTED_1000baseT_Full;
 			ecmd->advertising = ADVERTISED_1000baseT_Full;
@@ -156,8 +153,7 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
 			u16 pcifn = adapter->ahw.pci_func;
 
-			val = adapter->hw_read_wx(adapter,
-				P3_LINK_SPEED_REG(pcifn));
+			val = NXRD32(adapter, P3_LINK_SPEED_REG(pcifn));
 			ecmd->speed = P3_LINK_SPEED_MHZ *
 					P3_LINK_SPEED_VAL(pcifn, val);
 		} else
@@ -423,12 +419,11 @@ netxen_nic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 	regs->version = (1 << 24) | (adapter->ahw.revision_id << 16) |
 	    (adapter->pdev)->device;
 	/* which mode */
-	regs_buff[0] = adapter->hw_read_wx(adapter, NETXEN_NIU_MODE);
+	regs_buff[0] = NXRD32(adapter, NETXEN_NIU_MODE);
 	mode = regs_buff[0];
 
 	/* Common registers to all the modes */
-	regs_buff[2] = adapter->hw_read_wx(adapter,
-			NETXEN_NIU_STRAP_VALUE_SAVE_HIGHER);
+	regs_buff[2] = NXRD32(adapter, NETXEN_NIU_STRAP_VALUE_SAVE_HIGHER);
 	/* GB/XGB Mode */
 	mode = (mode / 2) - 1;
 	window = 0;
@@ -439,7 +434,7 @@ netxen_nic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 				window = adapter->physical_port *
 					NETXEN_NIC_PORT_WINDOW;
 
-			regs_buff[i] = adapter->hw_read_wx(adapter,
+			regs_buff[i] = NXRD32(adapter,
 				niu_registers[mode].reg[i - 3] + window);
 		}
 
@@ -464,7 +459,7 @@ static u32 netxen_nic_test_link(struct net_device *dev)
 			return !val;
 		}
 	} else if (adapter->ahw.port_type == NETXEN_NIC_XGBE) {
-		val = adapter->hw_read_wx(adapter, CRB_XG_STATE);
+		val = NXRD32(adapter, CRB_XG_STATE);
 		return (val == XG_LINK_UP) ? 0 : 1;
 	}
 	return -EIO;
@@ -528,10 +523,9 @@ netxen_nic_get_pauseparam(struct net_device *dev,
 		if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
 			return;
 		/* get flow control settings */
-		val = netxen_nic_read_w0(adapter,
-				NETXEN_NIU_GB_MAC_CONFIG_0(port));
+		val = NXRD32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port));
 		pause->rx_pause = netxen_gb_get_rx_flowctl(val);
-		val = netxen_nic_read_w0(adapter, NETXEN_NIU_GB_PAUSE_CTL);
+		val = NXRD32(adapter, NETXEN_NIU_GB_PAUSE_CTL);
 		switch (port) {
 			case 0:
 				pause->tx_pause = !(netxen_gb_get_gb0_mask(val));
@@ -551,7 +545,7 @@ netxen_nic_get_pauseparam(struct net_device *dev,
 		if ((port < 0) || (port > NETXEN_NIU_MAX_XG_PORTS))
 			return;
 		pause->rx_pause = 1;
-		val = netxen_nic_read_w0(adapter, NETXEN_NIU_XG_PAUSE_CTL);
+		val = NXRD32(adapter, NETXEN_NIU_XG_PAUSE_CTL);
 		if (port == 0)
 			pause->tx_pause = !(netxen_xg_get_xg0_mask(val));
 		else
@@ -574,18 +568,17 @@ netxen_nic_set_pauseparam(struct net_device *dev,
 		if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
 			return -EIO;
 		/* set flow control */
-		val = netxen_nic_read_w0(adapter,
-					NETXEN_NIU_GB_MAC_CONFIG_0(port));
+		val = NXRD32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port));
 
 		if (pause->rx_pause)
 			netxen_gb_rx_flowctl(val);
 		else
 			netxen_gb_unset_rx_flowctl(val);
 
-		netxen_nic_write_w0(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
+		NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
 				val);
 		/* set autoneg */
-		val = netxen_nic_read_w0(adapter, NETXEN_NIU_GB_PAUSE_CTL);
+		val = NXRD32(adapter, NETXEN_NIU_GB_PAUSE_CTL);
 		switch (port) {
 			case 0:
 				if (pause->tx_pause)
@@ -613,11 +606,11 @@ netxen_nic_set_pauseparam(struct net_device *dev,
 					netxen_gb_set_gb3_mask(val);
 				break;
 		}
-		netxen_nic_write_w0(adapter, NETXEN_NIU_GB_PAUSE_CTL, val);
+		NXWR32(adapter, NETXEN_NIU_GB_PAUSE_CTL, val);
 	} else if (adapter->ahw.port_type == NETXEN_NIC_XGBE) {
 		if ((port < 0) || (port > NETXEN_NIU_MAX_XG_PORTS))
 			return -EIO;
-		val = netxen_nic_read_w0(adapter, NETXEN_NIU_XG_PAUSE_CTL);
+		val = NXRD32(adapter, NETXEN_NIU_XG_PAUSE_CTL);
 		if (port == 0) {
 			if (pause->tx_pause)
 				netxen_xg_unset_xg0_mask(val);
@@ -629,7 +622,7 @@ netxen_nic_set_pauseparam(struct net_device *dev,
 			else
 				netxen_xg_set_xg1_mask(val);
 		}
-		netxen_nic_write_w0(adapter, NETXEN_NIU_XG_PAUSE_CTL, val);
+		NXWR32(adapter, NETXEN_NIU_XG_PAUSE_CTL, val);
 	} else {
 		printk(KERN_ERR "%s: Unknown board type: %x\n",
 				netxen_nic_driver_name,
@@ -643,14 +636,14 @@ static int netxen_nic_reg_test(struct net_device *dev)
 	struct netxen_adapter *adapter = netdev_priv(dev);
 	u32 data_read, data_written;
 
-	data_read = netxen_nic_read_w0(adapter, NETXEN_PCIX_PH_REG(0));
+	data_read = NXRD32(adapter, NETXEN_PCIX_PH_REG(0));
 	if ((data_read & 0xffff) != PHAN_VENDOR_ID)
 	return 1;
 
 	data_written = (u32)0xa5a5a5a5;
 
-	netxen_nic_reg_write(adapter, CRB_SCRATCHPAD_TEST, data_written);
-	data_read = adapter->hw_read_wx(adapter, CRB_SCRATCHPAD_TEST);
+	NXWR32(adapter, CRB_SCRATCHPAD_TEST, data_written);
+	data_read = NXRD32(adapter, CRB_SCRATCHPAD_TEST);
 	if (data_written != data_read)
 		return 1;
 
@@ -767,11 +760,11 @@ netxen_nic_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
 		return;
 
-	wol_cfg = netxen_nic_reg_read(adapter, NETXEN_WOL_CONFIG_NV);
+	wol_cfg = NXRD32(adapter, NETXEN_WOL_CONFIG_NV);
 	if (wol_cfg & (1UL << adapter->portnum))
 		wol->supported |= WAKE_MAGIC;
 
-	wol_cfg = netxen_nic_reg_read(adapter, NETXEN_WOL_CONFIG);
+	wol_cfg = NXRD32(adapter, NETXEN_WOL_CONFIG);
 	if (wol_cfg & (1UL << adapter->portnum))
 		wol->wolopts |= WAKE_MAGIC;
 }
@@ -788,16 +781,16 @@ netxen_nic_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	if (wol->wolopts & ~WAKE_MAGIC)
 		return -EOPNOTSUPP;
 
-	wol_cfg = netxen_nic_reg_read(adapter, NETXEN_WOL_CONFIG_NV);
+	wol_cfg = NXRD32(adapter, NETXEN_WOL_CONFIG_NV);
 	if (!(wol_cfg & (1 << adapter->portnum)))
 		return -EOPNOTSUPP;
 
-	wol_cfg = netxen_nic_reg_read(adapter, NETXEN_WOL_CONFIG);
+	wol_cfg = NXRD32(adapter, NETXEN_WOL_CONFIG);
 	if (wol->wolopts & WAKE_MAGIC)
 		wol_cfg |= 1UL << adapter->portnum;
 	else
 		wol_cfg &= ~(1UL << adapter->portnum);
-	netxen_nic_reg_write(adapter, NETXEN_WOL_CONFIG, wol_cfg);
+	NXWR32(adapter, NETXEN_WOL_CONFIG, wol_cfg);
 
 	return 0;
 }
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 87cda65..9439f89 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -361,22 +361,20 @@ netxen_nic_enable_mcast_filter(struct netxen_adapter *adapter)
 	if (adapter->mc_enabled)
 		return 0;
 
-	val = adapter->hw_read_wx(adapter, NETXEN_MAC_ADDR_CNTL_REG);
+	val = NXRD32(adapter, NETXEN_MAC_ADDR_CNTL_REG);
 	val |= (1UL << (28+port));
-	adapter->hw_write_wx(adapter, NETXEN_MAC_ADDR_CNTL_REG, val);
+	NXWR32(adapter, NETXEN_MAC_ADDR_CNTL_REG, val);
 
 	/* add broadcast addr to filter */
 	val = 0xffffff;
-	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port, 0), val);
-	netxen_crb_writelit_adapter(adapter,
-			NETXEN_UNICAST_ADDR(port, 0)+4, val);
+	NXWR32(adapter, NETXEN_UNICAST_ADDR(port, 0), val);
+	NXWR32(adapter, NETXEN_UNICAST_ADDR(port, 0)+4, val);
 
 	/* add station addr to filter */
 	val = MAC_HI(addr);
-	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port, 1), val);
+	NXWR32(adapter, NETXEN_UNICAST_ADDR(port, 1), val);
 	val = MAC_LO(addr);
-	netxen_crb_writelit_adapter(adapter,
-			NETXEN_UNICAST_ADDR(port, 1)+4, val);
+	NXWR32(adapter, NETXEN_UNICAST_ADDR(port, 1)+4, val);
 
 	adapter->mc_enabled = 1;
 	return 0;
@@ -392,18 +390,17 @@ netxen_nic_disable_mcast_filter(struct netxen_adapter *adapter)
 	if (!adapter->mc_enabled)
 		return 0;
 
-	val = adapter->hw_read_wx(adapter, NETXEN_MAC_ADDR_CNTL_REG);
+	val = NXRD32(adapter, NETXEN_MAC_ADDR_CNTL_REG);
 	val &= ~(1UL << (28+port));
-	adapter->hw_write_wx(adapter, NETXEN_MAC_ADDR_CNTL_REG, val);
+	NXWR32(adapter, NETXEN_MAC_ADDR_CNTL_REG, val);
 
 	val = MAC_HI(addr);
-	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port, 0), val);
+	NXWR32(adapter, NETXEN_UNICAST_ADDR(port, 0), val);
 	val = MAC_LO(addr);
-	netxen_crb_writelit_adapter(adapter,
-			NETXEN_UNICAST_ADDR(port, 0)+4, val);
+	NXWR32(adapter, NETXEN_UNICAST_ADDR(port, 0)+4, val);
 
-	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port, 1), 0);
-	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port, 1)+4, 0);
+	NXWR32(adapter, NETXEN_UNICAST_ADDR(port, 1), 0);
+	NXWR32(adapter, NETXEN_UNICAST_ADDR(port, 1)+4, 0);
 
 	adapter->mc_enabled = 0;
 	return 0;
@@ -419,10 +416,8 @@ netxen_nic_set_mcast_addr(struct netxen_adapter *adapter,
 	lo = MAC_LO(addr);
 	hi = MAC_HI(addr);
 
-	netxen_crb_writelit_adapter(adapter,
-			NETXEN_MCAST_ADDR(port, index), hi);
-	netxen_crb_writelit_adapter(adapter,
-			NETXEN_MCAST_ADDR(port, index)+4, lo);
+	NXWR32(adapter, NETXEN_MCAST_ADDR(port, index), hi);
+	NXWR32(adapter, NETXEN_MCAST_ADDR(port, index)+4, lo);
 
 	return 0;
 }
@@ -863,8 +858,8 @@ int netxen_p3_get_mac_addr(struct netxen_adapter *adapter, __le64 *mac)
 	crbaddr = CRB_MAC_BLOCK_START +
 		(4 * ((pci_func/2) * 3)) + (4 * (pci_func & 1));
 
-	mac_lo = adapter->hw_read_wx(adapter, crbaddr);
-	mac_hi = adapter->hw_read_wx(adapter, crbaddr+4);
+	mac_lo = NXRD32(adapter, crbaddr);
+	mac_hi = NXRD32(adapter, crbaddr+4);
 
 	if (pci_func & 1)
 		*mac = le64_to_cpu((mac_lo >> 16) | ((u64)mac_hi << 16));
@@ -882,8 +877,7 @@ static int crb_win_lock(struct netxen_adapter *adapter)
 
 	while (!done) {
 		/* acquire semaphore3 from PCI HW block */
-		done = adapter->hw_read_wx(adapter,
-				NETXEN_PCIE_REG(PCIE_SEM7_LOCK));
+		done = NXRD32(adapter, NETXEN_PCIE_REG(PCIE_SEM7_LOCK));
 		if (done == 1)
 			break;
 		if (timeout >= CRB_WIN_LOCK_TIMEOUT)
@@ -891,8 +885,7 @@ static int crb_win_lock(struct netxen_adapter *adapter)
 		timeout++;
 		udelay(1);
 	}
-	netxen_crb_writelit_adapter(adapter,
-			NETXEN_CRB_WIN_LOCK_ID, adapter->portnum);
+	NXWR32(adapter, NETXEN_CRB_WIN_LOCK_ID, adapter->portnum);
 	return 0;
 }
 
@@ -900,8 +893,7 @@ static void crb_win_unlock(struct netxen_adapter *adapter)
 {
 	int val;
 
-	val = adapter->hw_read_wx(adapter,
-			NETXEN_PCIE_REG(PCIE_SEM7_UNLOCK));
+	val = NXRD32(adapter, NETXEN_PCIE_REG(PCIE_SEM7_UNLOCK));
 }
 
 /*
@@ -1037,8 +1029,7 @@ netxen_do_load_firmware(struct netxen_adapter *adapter, const char *fwname,
 		dev_info(&pdev->dev, "loading firmware from flash\n");
 
 	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
-		adapter->hw_write_wx(adapter,
-				NETXEN_ROMUSB_GLB_CAS_RST, 1);
+		NXWR32(adapter, NETXEN_ROMUSB_GLB_CAS_RST, 1);
 
 	if (fw) {
 		__le64 data;
@@ -1090,13 +1081,10 @@ netxen_do_load_firmware(struct netxen_adapter *adapter, const char *fwname,
 	msleep(1);
 
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
-		adapter->hw_write_wx(adapter,
-				NETXEN_ROMUSB_GLB_SW_RESET, 0x80001d);
+		NXWR32(adapter, NETXEN_ROMUSB_GLB_SW_RESET, 0x80001d);
 	else {
-		adapter->hw_write_wx(adapter,
-				NETXEN_ROMUSB_GLB_CHIP_CLK_CTRL, 0x3fff);
-		adapter->hw_write_wx(adapter,
-				NETXEN_ROMUSB_GLB_CAS_RST, 0);
+		NXWR32(adapter, NETXEN_ROMUSB_GLB_CHIP_CLK_CTRL, 0x3fff);
+		NXWR32(adapter, NETXEN_ROMUSB_GLB_CAS_RST, 0);
 	}
 
 	return 0;
@@ -1154,8 +1142,7 @@ netxen_validate_firmware(struct netxen_adapter *adapter, const char *fwname,
 	if (NETXEN_VERSION_CODE(major, minor, build) > ver)
 		return -EINVAL;
 
-	netxen_nic_reg_write(adapter, NETXEN_CAM_RAM(0x1fc),
-			NETXEN_BDINFO_MAGIC);
+	NXWR32(adapter, NETXEN_CAM_RAM(0x1fc), NETXEN_BDINFO_MAGIC);
 	return 0;
 }
 
@@ -1183,8 +1170,7 @@ request_mn:
 	netxen_rom_fast_read(adapter,
 			NX_FW_VERSION_OFFSET, (int *)&flashed_ver);
 	if (flashed_ver >= NETXEN_VERSION_CODE(4, 0, 220)) {
-		capability = adapter->hw_read_wx(adapter,
-				NX_PEG_TUNE_CAPABILITY);
+		capability = NXRD32(adapter, NX_PEG_TUNE_CAPABILITY);
 		if (capability & NX_PEG_TUNE_MN_PRESENT) {
 			fw_type = NX_P3_MN_ROMIMAGE;
 			goto request_fw;
@@ -1332,38 +1318,6 @@ netxen_nic_hw_read_wx_2M(struct netxen_adapter *adapter, ulong off)
 	return data;
 }
 
-void netxen_nic_reg_write(struct netxen_adapter *adapter, u64 off, u32 val)
-{
-	adapter->hw_write_wx(adapter, off, val);
-}
-
-int netxen_nic_reg_read(struct netxen_adapter *adapter, u64 off)
-{
-	return adapter->hw_read_wx(adapter, off);
-}
-
-/* Change the window to 0, write and change back to window 1. */
-void netxen_nic_write_w0(struct netxen_adapter *adapter, u32 index, u32 value)
-{
-	adapter->hw_write_wx(adapter, index, value);
-}
-
-/* Change the window to 0, read and change back to window 1. */
-u32 netxen_nic_read_w0(struct netxen_adapter *adapter, u32 index)
-{
-	return adapter->hw_read_wx(adapter, index);
-}
-
-void netxen_nic_write_w1(struct netxen_adapter *adapter, u32 index, u32 value)
-{
-	adapter->hw_write_wx(adapter, index, value);
-}
-
-u32 netxen_nic_read_w1(struct netxen_adapter *adapter, u32 index)
-{
-	return adapter->hw_read_wx(adapter, index);
-}
-
 /*
  * check memory access boundary.
  * used by test agent. support ddr access only for now
@@ -1475,10 +1429,9 @@ netxen_nic_pci_set_window_2M(struct netxen_adapter *adapter,
 		/* DDR network side */
 		window = MN_WIN(addr);
 		adapter->ahw.ddr_mn_window = window;
-		adapter->hw_write_wx(adapter,
-				adapter->ahw.mn_win_crb | NETXEN_PCI_CRBSPACE,
+		NXWR32(adapter, adapter->ahw.mn_win_crb | NETXEN_PCI_CRBSPACE,
 				window);
-		win_read = adapter->hw_read_wx(adapter,
+		win_read = NXRD32(adapter,
 				adapter->ahw.mn_win_crb | NETXEN_PCI_CRBSPACE);
 		if ((win_read << 17) != window) {
 			printk(KERN_INFO "Written MNwin (0x%x) != "
@@ -1494,10 +1447,9 @@ netxen_nic_pci_set_window_2M(struct netxen_adapter *adapter,
 
 		window = OCM_WIN(addr);
 		adapter->ahw.ddr_mn_window = window;
-		adapter->hw_write_wx(adapter,
-				adapter->ahw.mn_win_crb | NETXEN_PCI_CRBSPACE,
+		NXWR32(adapter, adapter->ahw.mn_win_crb | NETXEN_PCI_CRBSPACE,
 				window);
-		win_read = adapter->hw_read_wx(adapter,
+		win_read = NXRD32(adapter,
 				adapter->ahw.mn_win_crb | NETXEN_PCI_CRBSPACE);
 		if ((win_read >> 7) != window) {
 			printk(KERN_INFO "%s: Written OCMwin (0x%x) != "
@@ -1511,10 +1463,9 @@ netxen_nic_pci_set_window_2M(struct netxen_adapter *adapter,
 		/* QDR network side */
 		window = MS_WIN(addr);
 		adapter->ahw.qdr_sn_window = window;
-		adapter->hw_write_wx(adapter,
-				adapter->ahw.ms_win_crb | NETXEN_PCI_CRBSPACE,
+		NXWR32(adapter, adapter->ahw.ms_win_crb | NETXEN_PCI_CRBSPACE,
 				window);
-		win_read = adapter->hw_read_wx(adapter,
+		win_read = NXRD32(adapter,
 				adapter->ahw.ms_win_crb | NETXEN_PCI_CRBSPACE);
 		if (win_read != window) {
 			printk(KERN_INFO "%s: Written MSwin (0x%x) != "
@@ -1961,27 +1912,20 @@ netxen_nic_pci_mem_write_2M(struct netxen_adapter *adapter,
 
 	for (i = 0; i < loop; i++) {
 		temp = off8 + (i << 3);
-		adapter->hw_write_wx(adapter,
-				mem_crb+MIU_TEST_AGT_ADDR_LO, temp);
+		NXWR32(adapter, mem_crb+MIU_TEST_AGT_ADDR_LO, temp);
 		temp = 0;
-		adapter->hw_write_wx(adapter,
-				mem_crb+MIU_TEST_AGT_ADDR_HI, temp);
+		NXWR32(adapter, mem_crb+MIU_TEST_AGT_ADDR_HI, temp);
 		temp = word[i] & 0xffffffff;
-		adapter->hw_write_wx(adapter,
-				mem_crb+MIU_TEST_AGT_WRDATA_LO, temp);
+		NXWR32(adapter, mem_crb+MIU_TEST_AGT_WRDATA_LO, temp);
 		temp = (word[i] >> 32) & 0xffffffff;
-		adapter->hw_write_wx(adapter,
-				mem_crb+MIU_TEST_AGT_WRDATA_HI, temp);
+		NXWR32(adapter, mem_crb+MIU_TEST_AGT_WRDATA_HI, temp);
 		temp = MIU_TA_CTL_ENABLE | MIU_TA_CTL_WRITE;
-		adapter->hw_write_wx(adapter,
-				mem_crb+MIU_TEST_AGT_CTRL, temp);
+		NXWR32(adapter, mem_crb+MIU_TEST_AGT_CTRL, temp);
 		temp = MIU_TA_CTL_START | MIU_TA_CTL_ENABLE | MIU_TA_CTL_WRITE;
-		adapter->hw_write_wx(adapter,
-				mem_crb+MIU_TEST_AGT_CTRL, temp);
+		NXWR32(adapter, mem_crb+MIU_TEST_AGT_CTRL, temp);
 
 		for (j = 0; j < MAX_CTL_CHECK; j++) {
-			temp = adapter->hw_read_wx(adapter,
-					mem_crb + MIU_TEST_AGT_CTRL);
+			temp = NXRD32(adapter, mem_crb + MIU_TEST_AGT_CTRL);
 			if ((temp & MIU_TA_CTL_BUSY) == 0)
 				break;
 		}
@@ -2038,21 +1982,16 @@ netxen_nic_pci_mem_read_2M(struct netxen_adapter *adapter,
 
 	for (i = 0; i < loop; i++) {
 		temp = off8 + (i << 3);
-		adapter->hw_write_wx(adapter,
-				mem_crb + MIU_TEST_AGT_ADDR_LO, temp);
+		NXWR32(adapter, mem_crb + MIU_TEST_AGT_ADDR_LO, temp);
 		temp = 0;
-		adapter->hw_write_wx(adapter,
-				mem_crb + MIU_TEST_AGT_ADDR_HI, temp);
+		NXWR32(adapter, mem_crb + MIU_TEST_AGT_ADDR_HI, temp);
 		temp = MIU_TA_CTL_ENABLE;
-		adapter->hw_write_wx(adapter,
-				mem_crb + MIU_TEST_AGT_CTRL, temp);
+		NXWR32(adapter, mem_crb + MIU_TEST_AGT_CTRL, temp);
 		temp = MIU_TA_CTL_START | MIU_TA_CTL_ENABLE;
-		adapter->hw_write_wx(adapter,
-				mem_crb + MIU_TEST_AGT_CTRL, temp);
+		NXWR32(adapter, mem_crb + MIU_TEST_AGT_CTRL, temp);
 
 		for (j = 0; j < MAX_CTL_CHECK; j++) {
-			temp = adapter->hw_read_wx(adapter,
-					mem_crb + MIU_TEST_AGT_CTRL);
+			temp = NXRD32(adapter, mem_crb + MIU_TEST_AGT_CTRL);
 			if ((temp & MIU_TA_CTL_BUSY) == 0)
 				break;
 		}
@@ -2067,7 +2006,7 @@ netxen_nic_pci_mem_read_2M(struct netxen_adapter *adapter,
 		start = off0[i] >> 2;
 		end   = (off0[i] + sz[i] - 1) >> 2;
 		for (k = start; k <= end; k++) {
-			temp = adapter->hw_read_wx(adapter,
+			temp = NXRD32(adapter,
 				mem_crb + MIU_TEST_AGT_RDDATA(k));
 			word[i] |= ((uint64_t)temp << (32 * k));
 		}
@@ -2111,14 +2050,14 @@ netxen_nic_pci_mem_read_2M(struct netxen_adapter *adapter,
 int netxen_nic_pci_write_immediate_2M(struct netxen_adapter *adapter,
 		u64 off, u32 data)
 {
-	adapter->hw_write_wx(adapter, off, data);
+	NXWR32(adapter, off, data);
 
 	return 0;
 }
 
 u32 netxen_nic_pci_read_immediate_2M(struct netxen_adapter *adapter, u64 off)
 {
-	return adapter->hw_read_wx(adapter, off);
+	return NXRD32(adapter, off);
 }
 
 int netxen_nic_get_board_info(struct netxen_adapter *adapter)
@@ -2152,8 +2091,7 @@ int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 	adapter->ahw.board_type = board_type;
 
 	if (board_type == NETXEN_BRDTYPE_P3_4_GB_MM) {
-		u32 gpio = netxen_nic_reg_read(adapter,
-				NETXEN_ROMUSB_GLB_PAD_GPIO_I);
+		u32 gpio = NXRD32(adapter, NETXEN_ROMUSB_GLB_PAD_GPIO_I);
 		if ((gpio & 0x8000) == 0)
 			board_type = NETXEN_BRDTYPE_P3_10G_TP;
 	}
@@ -2205,8 +2143,7 @@ int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 int netxen_nic_set_mtu_gb(struct netxen_adapter *adapter, int new_mtu)
 {
 	new_mtu += MTU_FUDGE_FACTOR;
-	netxen_nic_write_w0(adapter,
-		NETXEN_NIU_GB_MAX_FRAME_SIZE(adapter->physical_port),
+	NXWR32(adapter, NETXEN_NIU_GB_MAX_FRAME_SIZE(adapter->physical_port),
 		new_mtu);
 	return 0;
 }
@@ -2215,21 +2152,12 @@ int netxen_nic_set_mtu_xgb(struct netxen_adapter *adapter, int new_mtu)
 {
 	new_mtu += MTU_FUDGE_FACTOR;
 	if (adapter->physical_port == 0)
-		netxen_nic_write_w0(adapter, NETXEN_NIU_XGE_MAX_FRAME_SIZE,
-				new_mtu);
+		NXWR32(adapter, NETXEN_NIU_XGE_MAX_FRAME_SIZE, new_mtu);
 	else
-		netxen_nic_write_w0(adapter, NETXEN_NIU_XG1_MAX_FRAME_SIZE,
-				new_mtu);
+		NXWR32(adapter, NETXEN_NIU_XG1_MAX_FRAME_SIZE, new_mtu);
 	return 0;
 }
 
-void
-netxen_crb_writelit_adapter(struct netxen_adapter *adapter,
-		unsigned long off, int data)
-{
-	adapter->hw_write_wx(adapter, off, data);
-}
-
 void netxen_nic_set_link_parameters(struct netxen_adapter *adapter)
 {
 	__u32 status;
@@ -2244,8 +2172,7 @@ void netxen_nic_set_link_parameters(struct netxen_adapter *adapter)
 	}
 
 	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
-		port_mode = adapter->hw_read_wx(adapter,
-				NETXEN_PORT_MODE_ADDR);
+		port_mode = NXRD32(adapter, NETXEN_PORT_MODE_ADDR);
 		if (port_mode == NETXEN_PORT_MODE_802_3_AP) {
 			adapter->link_speed   = SPEED_1000;
 			adapter->link_duplex  = DUPLEX_FULL;
@@ -2322,9 +2249,9 @@ void netxen_nic_get_firmware_info(struct netxen_adapter *adapter)
 		addr += sizeof(u32);
 	}
 
-	fw_major = adapter->hw_read_wx(adapter, NETXEN_FW_VERSION_MAJOR);
-	fw_minor = adapter->hw_read_wx(adapter, NETXEN_FW_VERSION_MINOR);
-	fw_build = adapter->hw_read_wx(adapter, NETXEN_FW_VERSION_SUB);
+	fw_major = NXRD32(adapter, NETXEN_FW_VERSION_MAJOR);
+	fw_minor = NXRD32(adapter, NETXEN_FW_VERSION_MINOR);
+	fw_build = NXRD32(adapter, NETXEN_FW_VERSION_SUB);
 
 	adapter->fw_major = fw_major;
 	adapter->fw_version = NETXEN_VERSION_CODE(fw_major, fw_minor, fw_build);
@@ -2347,7 +2274,7 @@ void netxen_nic_get_firmware_info(struct netxen_adapter *adapter)
 			fw_major, fw_minor, fw_build);
 
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
-		i = adapter->hw_read_wx(adapter, NETXEN_MIU_MN_CONTROL);
+		i = NXRD32(adapter, NETXEN_MIU_MN_CONTROL);
 		adapter->ahw.cut_through = (i & 0x4) ? 1 : 0;
 		dev_info(&pdev->dev, "firmware running in %s mode\n",
 		adapter->ahw.cut_through ? "cut-through" : "legacy");
@@ -2362,9 +2289,9 @@ netxen_nic_wol_supported(struct netxen_adapter *adapter)
 	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
 		return 0;
 
-	wol_cfg = netxen_nic_reg_read(adapter, NETXEN_WOL_CONFIG_NV);
+	wol_cfg = NXRD32(adapter, NETXEN_WOL_CONFIG_NV);
 	if (wol_cfg & (1UL << adapter->portnum)) {
-		wol_cfg = netxen_nic_reg_read(adapter, NETXEN_WOL_CONFIG);
+		wol_cfg = NXRD32(adapter, NETXEN_WOL_CONFIG);
 		if (wol_cfg & (1 << adapter->portnum))
 			return 1;
 	}
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 83116c2..0c91238 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -368,8 +368,7 @@ static int rom_lock(struct netxen_adapter *adapter)
 
 	while (!done) {
 		/* acquire semaphore2 from PCI HW block */
-		done = netxen_nic_read_w0(adapter,
-				NETXEN_PCIE_REG(PCIE_SEM2_LOCK));
+		done = NXRD32(adapter, NETXEN_PCIE_REG(PCIE_SEM2_LOCK));
 		if (done == 1)
 			break;
 		if (timeout >= rom_lock_timeout)
@@ -386,7 +385,7 @@ static int rom_lock(struct netxen_adapter *adapter)
 				cpu_relax();	/*This a nop instr on i386 */
 		}
 	}
-	netxen_nic_reg_write(adapter, NETXEN_ROM_LOCK_ID, ROM_LOCK_DRIVER);
+	NXWR32(adapter, NETXEN_ROM_LOCK_ID, ROM_LOCK_DRIVER);
 	return 0;
 }
 
@@ -398,7 +397,7 @@ static int netxen_wait_rom_done(struct netxen_adapter *adapter)
 	cond_resched();
 
 	while (done == 0) {
-		done = netxen_nic_reg_read(adapter, NETXEN_ROMUSB_GLB_STATUS);
+		done = NXRD32(adapter, NETXEN_ROMUSB_GLB_STATUS);
 		done &= 2;
 		timeout++;
 		if (timeout >= rom_max_timeout) {
@@ -412,27 +411,27 @@ static int netxen_wait_rom_done(struct netxen_adapter *adapter)
 static void netxen_rom_unlock(struct netxen_adapter *adapter)
 {
 	/* release semaphore2 */
-	netxen_nic_read_w0(adapter, NETXEN_PCIE_REG(PCIE_SEM2_UNLOCK));
+	NXRD32(adapter, NETXEN_PCIE_REG(PCIE_SEM2_UNLOCK));
 
 }
 
 static int do_rom_fast_read(struct netxen_adapter *adapter,
 			    int addr, int *valp)
 {
-	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ADDRESS, addr);
-	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
-	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 3);
-	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_INSTR_OPCODE, 0xb);
+	NXWR32(adapter, NETXEN_ROMUSB_ROM_ADDRESS, addr);
+	NXWR32(adapter, NETXEN_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
+	NXWR32(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 3);
+	NXWR32(adapter, NETXEN_ROMUSB_ROM_INSTR_OPCODE, 0xb);
 	if (netxen_wait_rom_done(adapter)) {
 		printk("Error waiting for rom done\n");
 		return -EIO;
 	}
 	/* reset abyte_cnt and dummy_byte_cnt */
-	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 0);
+	NXWR32(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 0);
 	udelay(10);
-	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
+	NXWR32(adapter, NETXEN_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
 
-	*valp = netxen_nic_reg_read(adapter, NETXEN_ROMUSB_ROM_RDATA);
+	*valp = NXRD32(adapter, NETXEN_ROMUSB_ROM_RDATA);
 	return 0;
 }
 
@@ -496,8 +495,7 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 
 	/* resetall */
 	rom_lock(adapter);
-	netxen_crb_writelit_adapter(adapter, NETXEN_ROMUSB_GLB_SW_RESET,
-				    0xffffffff);
+	NXWR32(adapter, NETXEN_ROMUSB_GLB_SW_RESET, 0xffffffff);
 	netxen_rom_unlock(adapter);
 
 	if (verbose) {
@@ -621,7 +619,7 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 			}
 		}
 
-		adapter->hw_write_wx(adapter, off, buf[i].data);
+		NXWR32(adapter, off, buf[i].data);
 
 		msleep(init_delay);
 	}
@@ -631,33 +629,31 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 
 	/* unreset_net_cache */
 	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
-		val = adapter->hw_read_wx(adapter,
-				NETXEN_ROMUSB_GLB_SW_RESET);
-		netxen_crb_writelit_adapter(adapter,
-				NETXEN_ROMUSB_GLB_SW_RESET, (val & 0xffffff0f));
+		val = NXRD32(adapter, NETXEN_ROMUSB_GLB_SW_RESET);
+		NXWR32(adapter, NETXEN_ROMUSB_GLB_SW_RESET, (val & 0xffffff0f));
 	}
 
 	/* p2dn replyCount */
-	netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_D + 0xec, 0x1e);
+	NXWR32(adapter, NETXEN_CRB_PEG_NET_D + 0xec, 0x1e);
 	/* disable_peg_cache 0 */
-	netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_D + 0x4c, 8);
+	NXWR32(adapter, NETXEN_CRB_PEG_NET_D + 0x4c, 8);
 	/* disable_peg_cache 1 */
-	netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_I + 0x4c, 8);
+	NXWR32(adapter, NETXEN_CRB_PEG_NET_I + 0x4c, 8);
 
 	/* peg_clr_all */
 
 	/* peg_clr 0 */
-	netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_0 + 0x8, 0);
-	netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_0 + 0xc, 0);
+	NXWR32(adapter, NETXEN_CRB_PEG_NET_0 + 0x8, 0);
+	NXWR32(adapter, NETXEN_CRB_PEG_NET_0 + 0xc, 0);
 	/* peg_clr 1 */
-	netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_1 + 0x8, 0);
-	netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_1 + 0xc, 0);
+	NXWR32(adapter, NETXEN_CRB_PEG_NET_1 + 0x8, 0);
+	NXWR32(adapter, NETXEN_CRB_PEG_NET_1 + 0xc, 0);
 	/* peg_clr 2 */
-	netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_2 + 0x8, 0);
-	netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_2 + 0xc, 0);
+	NXWR32(adapter, NETXEN_CRB_PEG_NET_2 + 0x8, 0);
+	NXWR32(adapter, NETXEN_CRB_PEG_NET_2 + 0xc, 0);
 	/* peg_clr 3 */
-	netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_3 + 0x8, 0);
-	netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_3 + 0xc, 0);
+	NXWR32(adapter, NETXEN_CRB_PEG_NET_3 + 0x8, 0);
+	NXWR32(adapter, NETXEN_CRB_PEG_NET_3 + 0xc, 0);
 	return 0;
 }
 
@@ -681,12 +677,12 @@ int netxen_initialize_adapter_offload(struct netxen_adapter *adapter)
 	hi = (addr >> 32) & 0xffffffff;
 	lo = addr & 0xffffffff;
 
-	adapter->hw_write_wx(adapter, CRB_HOST_DUMMY_BUF_ADDR_HI, hi);
-	adapter->hw_write_wx(adapter, CRB_HOST_DUMMY_BUF_ADDR_LO, lo);
+	NXWR32(adapter, CRB_HOST_DUMMY_BUF_ADDR_HI, hi);
+	NXWR32(adapter, CRB_HOST_DUMMY_BUF_ADDR_LO, lo);
 
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
 		uint32_t temp = 0;
-		adapter->hw_write_wx(adapter, CRB_HOST_DUMMY_BUF, temp);
+		NXWR32(adapter, CRB_HOST_DUMMY_BUF, temp);
 	}
 
 	return 0;
@@ -728,8 +724,7 @@ int netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val)
 
 	if (!pegtune_val) {
 		do {
-			val = adapter->hw_read_wx(adapter,
-					CRB_CMDPEG_STATE);
+			val = NXRD32(adapter, CRB_CMDPEG_STATE);
 
 			if (val == PHAN_INITIALIZE_COMPLETE ||
 				val == PHAN_INITIALIZE_ACK)
@@ -740,7 +735,7 @@ int netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val)
 		} while (--retries);
 
 		if (!retries) {
-			pegtune_val = adapter->hw_read_wx(adapter,
+			pegtune_val = NXRD32(adapter,
 					NETXEN_ROMUSB_GLB_PEGTUNE_DONE);
 			printk(KERN_WARNING "netxen_phantom_init: init failed, "
 					"pegtune_val=%x\n", pegtune_val);
@@ -758,7 +753,7 @@ netxen_receive_peg_ready(struct netxen_adapter *adapter)
 	int retries = 2000;
 
 	do {
-		val = adapter->hw_read_wx(adapter, CRB_RCVPEG_STATE);
+		val = NXRD32(adapter, CRB_RCVPEG_STATE);
 
 		if (val == PHAN_PEG_RCV_INITIALIZED)
 			return 0;
@@ -784,18 +779,13 @@ int netxen_init_firmware(struct netxen_adapter *adapter)
 	if (err)
 		return err;
 
-	adapter->hw_write_wx(adapter,
-			CRB_NIC_CAPABILITIES_HOST, INTR_SCHEME_PERPORT);
-	adapter->hw_write_wx(adapter,
-			CRB_NIC_MSI_MODE_HOST, MSI_MODE_MULTIFUNC);
-	adapter->hw_write_wx(adapter,
-			CRB_MPORT_MODE, MPORT_MULTI_FUNCTION_MODE);
-	adapter->hw_write_wx(adapter,
-			CRB_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
+	NXWR32(adapter, CRB_NIC_CAPABILITIES_HOST, INTR_SCHEME_PERPORT);
+	NXWR32(adapter, CRB_NIC_MSI_MODE_HOST, MSI_MODE_MULTIFUNC);
+	NXWR32(adapter, CRB_MPORT_MODE, MPORT_MULTI_FUNCTION_MODE);
+	NXWR32(adapter, CRB_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
 
 	if (adapter->fw_version >= NETXEN_VERSION_CODE(4, 0, 222)) {
-		adapter->capabilities = netxen_nic_reg_read(adapter,
-				CRB_FW_CAPABILITIES_1);
+		adapter->capabilities = NXRD32(adapter, CRB_FW_CAPABILITIES_1);
 	}
 
 	return err;
@@ -1057,8 +1047,7 @@ skip:
 
 	if (count) {
 		sds_ring->consumer = consumer;
-		adapter->hw_write_wx(adapter,
-				sds_ring->crb_sts_consumer, consumer);
+		NXWR32(adapter, sds_ring->crb_sts_consumer, consumer);
 	}
 
 	return count;
@@ -1176,8 +1165,7 @@ netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ringid,
 
 	if (count) {
 		rds_ring->producer = producer;
-		adapter->hw_write_wx(adapter,
-				rds_ring->crb_rcv_producer,
+		NXWR32(adapter, rds_ring->crb_rcv_producer,
 				(producer-1) & (rds_ring->num_desc-1));
 
 		if (adapter->fw_major < 4) {
@@ -1237,8 +1225,7 @@ netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
 
 	if (count) {
 		rds_ring->producer = producer;
-		adapter->hw_write_wx(adapter,
-			rds_ring->crb_rcv_producer,
+		NXWR32(adapter, rds_ring->crb_rcv_producer,
 				(producer - 1) & (rds_ring->num_desc - 1));
 			wmb();
 	}
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index a79e265..1c85b74 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -109,8 +109,7 @@ void
 netxen_nic_update_cmd_producer(struct netxen_adapter *adapter,
 		struct nx_host_tx_ring *tx_ring, u32 producer)
 {
-	adapter->hw_write_wx(adapter,
-			tx_ring->crb_cmd_producer, producer);
+	NXWR32(adapter, tx_ring->crb_cmd_producer, producer);
 }
 
 static uint32_t crb_cmd_consumer[4] = {
@@ -122,8 +121,7 @@ static inline void
 netxen_nic_update_cmd_consumer(struct netxen_adapter *adapter,
 		struct nx_host_tx_ring *tx_ring, u32 consumer)
 {
-	adapter->hw_write_wx(adapter,
-			tx_ring->crb_cmd_consumer, consumer);
+	NXWR32(adapter, tx_ring->crb_cmd_consumer, consumer);
 }
 
 static uint32_t msi_tgt_status[8] = {
@@ -139,14 +137,14 @@ static inline void netxen_nic_disable_int(struct nx_host_sds_ring *sds_ring)
 {
 	struct netxen_adapter *adapter = sds_ring->adapter;
 
-	adapter->hw_write_wx(adapter, sds_ring->crb_intr_mask, 0);
+	NXWR32(adapter, sds_ring->crb_intr_mask, 0);
 }
 
 static inline void netxen_nic_enable_int(struct nx_host_sds_ring *sds_ring)
 {
 	struct netxen_adapter *adapter = sds_ring->adapter;
 
-	adapter->hw_write_wx(adapter, sds_ring->crb_intr_mask, 0x1);
+	NXWR32(adapter, sds_ring->crb_intr_mask, 0x1);
 
 	if (!NETXEN_IS_MSI_FAMILY(adapter))
 		adapter->pci_write_immediate(adapter,
@@ -262,7 +260,7 @@ nx_update_dma_mask(struct netxen_adapter *adapter)
 
 	change = 0;
 
-	shift = netxen_nic_reg_read(adapter, CRB_DMA_SHIFT);
+	shift = NXRD32(adapter, CRB_DMA_SHIFT);
 	if (shift >= 32)
 		return 0;
 
@@ -309,42 +307,34 @@ netxen_check_hw_init(struct netxen_adapter *adapter, int first_boot)
 
 	if (first_boot == 0x55555555) {
 		/* This is the first boot after power up */
-		adapter->hw_write_wx(adapter,
-			NETXEN_CAM_RAM(0x1fc), NETXEN_BDINFO_MAGIC);
+		NXWR32(adapter, NETXEN_CAM_RAM(0x1fc), NETXEN_BDINFO_MAGIC);
 
 		if (!NX_IS_REVISION_P2(adapter->ahw.revision_id))
 			return 0;
 
 		/* PCI bus master workaround */
-		first_boot = adapter->hw_read_wx(adapter, NETXEN_PCIE_REG(0x4));
+		first_boot = NXRD32(adapter, NETXEN_PCIE_REG(0x4));
 		if (!(first_boot & 0x4)) {
 			first_boot |= 0x4;
-			adapter->hw_write_wx(adapter,
-				NETXEN_PCIE_REG(0x4), first_boot);
-			first_boot = adapter->hw_read_wx(adapter,
-				NETXEN_PCIE_REG(0x4));
+			NXWR32(adapter, NETXEN_PCIE_REG(0x4), first_boot);
+			first_boot = NXRD32(adapter, NETXEN_PCIE_REG(0x4));
 		}
 
 		/* This is the first boot after power up */
-		first_boot = adapter->hw_read_wx(adapter,
-			NETXEN_ROMUSB_GLB_SW_RESET);
+		first_boot = NXRD32(adapter, NETXEN_ROMUSB_GLB_SW_RESET);
 		if (first_boot != 0x80000f) {
 			/* clear the register for future unloads/loads */
-			adapter->hw_write_wx(adapter,
-					NETXEN_CAM_RAM(0x1fc), 0);
+			NXWR32(adapter, NETXEN_CAM_RAM(0x1fc), 0);
 			return -EIO;
 		}
 
 		/* Start P2 boot loader */
-		val = adapter->hw_read_wx(adapter,
-				NETXEN_ROMUSB_GLB_PEGTUNE_DONE);
-		adapter->hw_write_wx(adapter,
-				NETXEN_ROMUSB_GLB_PEGTUNE_DONE, val | 0x1);
+		val = NXRD32(adapter, NETXEN_ROMUSB_GLB_PEGTUNE_DONE);
+		NXWR32(adapter, NETXEN_ROMUSB_GLB_PEGTUNE_DONE, val | 0x1);
 		timeout = 0;
 		do {
 			msleep(1);
-			val = adapter->hw_read_wx(adapter,
-					NETXEN_CAM_RAM(0x1fc));
+			val = NXRD32(adapter, NETXEN_CAM_RAM(0x1fc));
 
 			if (++timeout > 5000)
 				return -EIO;
@@ -363,24 +353,19 @@ static void netxen_set_port_mode(struct netxen_adapter *adapter)
 		(val == NETXEN_BRDTYPE_P3_XG_LOM)) {
 		if (port_mode == NETXEN_PORT_MODE_802_3_AP) {
 			data = NETXEN_PORT_MODE_802_3_AP;
-			adapter->hw_write_wx(adapter,
-				NETXEN_PORT_MODE_ADDR, data);
+			NXWR32(adapter, NETXEN_PORT_MODE_ADDR, data);
 		} else if (port_mode == NETXEN_PORT_MODE_XG) {
 			data = NETXEN_PORT_MODE_XG;
-			adapter->hw_write_wx(adapter,
-				NETXEN_PORT_MODE_ADDR, data);
+			NXWR32(adapter, NETXEN_PORT_MODE_ADDR, data);
 		} else if (port_mode == NETXEN_PORT_MODE_AUTO_NEG_1G) {
 			data = NETXEN_PORT_MODE_AUTO_NEG_1G;
-			adapter->hw_write_wx(adapter,
-				NETXEN_PORT_MODE_ADDR, data);
+			NXWR32(adapter, NETXEN_PORT_MODE_ADDR, data);
 		} else if (port_mode == NETXEN_PORT_MODE_AUTO_NEG_XG) {
 			data = NETXEN_PORT_MODE_AUTO_NEG_XG;
-			adapter->hw_write_wx(adapter,
-				NETXEN_PORT_MODE_ADDR, data);
+			NXWR32(adapter, NETXEN_PORT_MODE_ADDR, data);
 		} else {
 			data = NETXEN_PORT_MODE_AUTO_NEG;
-			adapter->hw_write_wx(adapter,
-				NETXEN_PORT_MODE_ADDR, data);
+			NXWR32(adapter, NETXEN_PORT_MODE_ADDR, data);
 		}
 
 		if ((wol_port_mode != NETXEN_PORT_MODE_802_3_AP) &&
@@ -389,8 +374,7 @@ static void netxen_set_port_mode(struct netxen_adapter *adapter)
 			(wol_port_mode != NETXEN_PORT_MODE_AUTO_NEG_XG)) {
 			wol_port_mode = NETXEN_PORT_MODE_AUTO_NEG;
 		}
-		adapter->hw_write_wx(adapter, NETXEN_WOL_PORT_MODE,
-			wol_port_mode);
+		NXWR32(adapter, NETXEN_WOL_PORT_MODE, wol_port_mode);
 	}
 }
 
@@ -674,8 +658,7 @@ netxen_start_firmware(struct netxen_adapter *adapter)
 	if (!first_driver)
 		return 0;
 
-	first_boot = adapter->hw_read_wx(adapter,
-			NETXEN_CAM_RAM(0x1fc));
+	first_boot = NXRD32(adapter, NETXEN_CAM_RAM(0x1fc));
 
 	err = netxen_check_hw_init(adapter, first_boot);
 	if (err) {
@@ -684,13 +667,12 @@ netxen_start_firmware(struct netxen_adapter *adapter)
 	}
 
 	if (first_boot != 0x55555555) {
-		adapter->hw_write_wx(adapter,
-					CRB_CMDPEG_STATE, 0);
+		NXWR32(adapter, CRB_CMDPEG_STATE, 0);
 		netxen_pinit_from_rom(adapter, 0);
 		msleep(1);
 	}
 
-	netxen_nic_reg_write(adapter, CRB_DMA_SHIFT, 0x55555555);
+	NXWR32(adapter, CRB_DMA_SHIFT, 0x55555555);
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
 		netxen_set_port_mode(adapter);
 
@@ -702,8 +684,7 @@ netxen_start_firmware(struct netxen_adapter *adapter)
 		val = 0x7654;
 		if (adapter->ahw.port_type == NETXEN_NIC_XGBE)
 			val |= 0x0f000000;
-		netxen_crb_writelit_adapter(adapter,
-				NETXEN_MAC_ADDR_CNTL_REG, val);
+		NXWR32(adapter, NETXEN_MAC_ADDR_CNTL_REG, val);
 
 	}
 
@@ -717,7 +698,7 @@ netxen_start_firmware(struct netxen_adapter *adapter)
 	val = (_NETXEN_NIC_LINUX_MAJOR << 16)
 		| ((_NETXEN_NIC_LINUX_MINOR << 8))
 		| (_NETXEN_NIC_LINUX_SUBVERSION);
-	adapter->hw_write_wx(adapter, CRB_DRIVER_VERSION, val);
+	NXWR32(adapter, CRB_DRIVER_VERSION, val);
 
 	/* Handshake with the card before we register the devices. */
 	err = netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
@@ -1032,8 +1013,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 */
 	adapter->physical_port = adapter->portnum;
 	if (adapter->fw_major < 4) {
-		i = adapter->hw_read_wx(adapter,
-				CRB_V2P(adapter->portnum));
+		i = NXRD32(adapter, CRB_V2P(adapter->portnum));
 		if (i != 0x55555555)
 			adapter->physical_port = i;
 	}
@@ -1480,7 +1460,7 @@ static int netxen_nic_check_temp(struct netxen_adapter *adapter)
 	uint32_t temp, temp_state, temp_val;
 	int rv = 0;
 
-	temp = adapter->hw_read_wx(adapter, CRB_TEMP_STATE);
+	temp = NXRD32(adapter, CRB_TEMP_STATE);
 
 	temp_state = nx_get_temp_state(temp);
 	temp_val = nx_get_temp_val(temp);
@@ -1551,11 +1531,11 @@ static void netxen_nic_handle_phy_intr(struct netxen_adapter *adapter)
 	port = adapter->physical_port;
 
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
-		val = adapter->hw_read_wx(adapter, CRB_XG_STATE_P3);
+		val = NXRD32(adapter, CRB_XG_STATE_P3);
 		val = XG_LINK_STATE_P3(adapter->ahw.pci_func, val);
 		linkup = (val == XG_LINK_UP_P3);
 	} else {
-		val = adapter->hw_read_wx(adapter, CRB_XG_STATE);
+		val = NXRD32(adapter, CRB_XG_STATE);
 		if (adapter->ahw.port_type == NETXEN_NIC_GBE)
 			linkup = (val >> port) & 1;
 		else {
@@ -1650,15 +1630,14 @@ static irqreturn_t netxen_intr(int irq, void *data)
 	} else {
 		unsigned long our_int = 0;
 
-		our_int = adapter->hw_read_wx(adapter, CRB_INT_VECTOR);
+		our_int = NXRD32(adapter, CRB_INT_VECTOR);
 
 		/* not our interrupt */
 		if (!test_and_clear_bit((7 + adapter->portnum), &our_int))
 			return IRQ_NONE;
 
 		/* claim interrupt */
-		adapter->hw_write_wx(adapter,
-				CRB_INT_VECTOR, (our_int & 0xffffffff));
+		NXWR32(adapter, CRB_INT_VECTOR, (our_int & 0xffffffff));
 	}
 
 	/* clear interrupt */
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index b54a63a..5e2698b 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -43,8 +43,7 @@ static int phy_lock(struct netxen_adapter *adapter)
 	int done = 0, timeout = 0;
 
 	while (!done) {
-		done = netxen_nic_reg_read(adapter,
-				NETXEN_PCIE_REG(PCIE_SEM3_LOCK));
+		done = NXRD32(adapter, NETXEN_PCIE_REG(PCIE_SEM3_LOCK));
 		if (done == 1)
 			break;
 		if (timeout >= phy_lock_timeout) {
@@ -59,8 +58,7 @@ static int phy_lock(struct netxen_adapter *adapter)
 		}
 	}
 
-	netxen_crb_writelit_adapter(adapter,
-			NETXEN_PHY_LOCK_ID, PHY_LOCK_DRIVER);
+	NXWR32(adapter, NETXEN_PHY_LOCK_ID, PHY_LOCK_DRIVER);
 	return 0;
 }
 
@@ -105,7 +103,7 @@ int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long reg,
 	 * so it cannot be in reset
 	 */
 
-	mac_cfg0 = adapter->hw_read_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0));
+	mac_cfg0 = NXRD32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0));
 	if (netxen_gb_get_soft_reset(mac_cfg0)) {
 		__u32 temp;
 		temp = 0;
@@ -113,8 +111,7 @@ int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long reg,
 		netxen_gb_rx_reset_pb(temp);
 		netxen_gb_tx_reset_mac(temp);
 		netxen_gb_rx_reset_mac(temp);
-		if (adapter->hw_write_wx(adapter,
-				   NETXEN_NIU_GB_MAC_CONFIG_0(0), temp))
+		if (NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0), temp))
 			return -EIO;
 		restore = 1;
 	}
@@ -122,38 +119,32 @@ int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long reg,
 	address = 0;
 	netxen_gb_mii_mgmt_reg_addr(address, reg);
 	netxen_gb_mii_mgmt_phy_addr(address, phy);
-	if (adapter->hw_write_wx(adapter,
-				NETXEN_NIU_GB_MII_MGMT_ADDR(0), address))
+	if (NXWR32(adapter, NETXEN_NIU_GB_MII_MGMT_ADDR(0), address))
 		return -EIO;
 	command = 0;		/* turn off any prior activity */
-	if (adapter->hw_write_wx(adapter,
-				NETXEN_NIU_GB_MII_MGMT_COMMAND(0), command))
+	if (NXWR32(adapter, NETXEN_NIU_GB_MII_MGMT_COMMAND(0), command))
 		return -EIO;
 	/* send read command */
 	netxen_gb_mii_mgmt_set_read_cycle(command);
-	if (adapter->hw_write_wx(adapter,
-				NETXEN_NIU_GB_MII_MGMT_COMMAND(0), command))
+	if (NXWR32(adapter, NETXEN_NIU_GB_MII_MGMT_COMMAND(0), command))
 		return -EIO;
 
 	status = 0;
 	do {
-		status = adapter->hw_read_wx(adapter,
-					  NETXEN_NIU_GB_MII_MGMT_INDICATE(0));
+		status = NXRD32(adapter, NETXEN_NIU_GB_MII_MGMT_INDICATE(0));
 		timeout++;
 	} while ((netxen_get_gb_mii_mgmt_busy(status)
 		  || netxen_get_gb_mii_mgmt_notvalid(status))
 		 && (timeout++ < NETXEN_NIU_PHY_WAITMAX));
 
 	if (timeout < NETXEN_NIU_PHY_WAITMAX) {
-		*readval = adapter->hw_read_wx(adapter,
-					  NETXEN_NIU_GB_MII_MGMT_STATUS(0));
+		*readval = NXRD32(adapter, NETXEN_NIU_GB_MII_MGMT_STATUS(0));
 		result = 0;
 	} else
 		result = -1;
 
 	if (restore)
-		if (adapter->hw_write_wx(adapter,
-				   NETXEN_NIU_GB_MAC_CONFIG_0(0), mac_cfg0))
+		if (NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0), mac_cfg0))
 			return -EIO;
 	phy_unlock(adapter);
 	return result;
@@ -189,7 +180,7 @@ int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter, long reg,
 	 * cannot be in reset
 	 */
 
-	mac_cfg0 = adapter->hw_read_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0));
+	mac_cfg0 = NXRD32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0));
 	if (netxen_gb_get_soft_reset(mac_cfg0)) {
 		__u32 temp;
 		temp = 0;
@@ -198,32 +189,27 @@ int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter, long reg,
 		netxen_gb_tx_reset_mac(temp);
 		netxen_gb_rx_reset_mac(temp);
 
-		if (adapter->hw_write_wx(adapter,
-					NETXEN_NIU_GB_MAC_CONFIG_0(0), temp))
+		if (NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0), temp))
 			return -EIO;
 		restore = 1;
 	}
 
 	command = 0;		/* turn off any prior activity */
-	if (adapter->hw_write_wx(adapter,
-				NETXEN_NIU_GB_MII_MGMT_COMMAND(0), command))
+	if (NXWR32(adapter, NETXEN_NIU_GB_MII_MGMT_COMMAND(0), command))
 		return -EIO;
 
 	address = 0;
 	netxen_gb_mii_mgmt_reg_addr(address, reg);
 	netxen_gb_mii_mgmt_phy_addr(address, phy);
-	if (adapter->hw_write_wx(adapter,
-				NETXEN_NIU_GB_MII_MGMT_ADDR(0), address))
+	if (NXWR32(adapter, NETXEN_NIU_GB_MII_MGMT_ADDR(0), address))
 		return -EIO;
 
-	if (adapter->hw_write_wx(adapter,
-				NETXEN_NIU_GB_MII_MGMT_CTRL(0), val))
+	if (NXWR32(adapter, NETXEN_NIU_GB_MII_MGMT_CTRL(0), val))
 		return -EIO;
 
 	status = 0;
 	do {
-		status = adapter->hw_read_wx(adapter,
-					  NETXEN_NIU_GB_MII_MGMT_INDICATE(0));
+		status = NXRD32(adapter, NETXEN_NIU_GB_MII_MGMT_INDICATE(0));
 		timeout++;
 	} while ((netxen_get_gb_mii_mgmt_busy(status))
 		 && (timeout++ < NETXEN_NIU_PHY_WAITMAX));
@@ -235,8 +221,7 @@ int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter, long reg,
 
 	/* restore the state of port 0 MAC in case we tampered with it */
 	if (restore)
-		if (adapter->hw_write_wx(adapter,
-				   NETXEN_NIU_GB_MAC_CONFIG_0(0), mac_cfg0))
+		if (NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0), mac_cfg0))
 			return -EIO;
 
 	return result;
@@ -244,7 +229,7 @@ int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter, long reg,
 
 int netxen_niu_xgbe_enable_phy_interrupts(struct netxen_adapter *adapter)
 {
-	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_INT_MASK, 0x3f);
+	NXWR32(adapter, NETXEN_NIU_INT_MASK, 0x3f);
 	return 0;
 }
 
@@ -267,7 +252,7 @@ int netxen_niu_gbe_enable_phy_interrupts(struct netxen_adapter *adapter)
 
 int netxen_niu_xgbe_disable_phy_interrupts(struct netxen_adapter *adapter)
 {
-	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_INT_MASK, 0x7f);
+	NXWR32(adapter, NETXEN_NIU_INT_MASK, 0x7f);
 	return 0;
 }
 
@@ -301,30 +286,21 @@ static int netxen_niu_gbe_clear_phy_interrupts(struct netxen_adapter *adapter)
 static void netxen_niu_gbe_set_mii_mode(struct netxen_adapter *adapter,
 					int port, long enable)
 {
-	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_MODE, 0x2);
-	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
-				    0x80000000);
-	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
-				    0x0000f0025);
-	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB_MAC_CONFIG_1(port),
-				    0xf1ff);
-	netxen_crb_writelit_adapter(adapter,
-				    NETXEN_NIU_GB0_GMII_MODE + (port << 3), 0);
-	netxen_crb_writelit_adapter(adapter,
-				    NETXEN_NIU_GB0_MII_MODE + (port << 3), 1);
-	netxen_crb_writelit_adapter(adapter,
-				    (NETXEN_NIU_GB0_HALF_DUPLEX + port * 4), 0);
-	netxen_crb_writelit_adapter(adapter,
-				    NETXEN_NIU_GB_MII_MGMT_CONFIG(port), 0x7);
+	NXWR32(adapter, NETXEN_NIU_MODE, 0x2);
+	NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port), 0x80000000);
+	NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port), 0x0000f0025);
+	NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_1(port), 0xf1ff);
+	NXWR32(adapter, NETXEN_NIU_GB0_GMII_MODE + (port << 3), 0);
+	NXWR32(adapter, NETXEN_NIU_GB0_MII_MODE + (port << 3), 1);
+	NXWR32(adapter, (NETXEN_NIU_GB0_HALF_DUPLEX + port * 4), 0);
+	NXWR32(adapter, NETXEN_NIU_GB_MII_MGMT_CONFIG(port), 0x7);
 
 	if (enable) {
 		/*
 		 * Do NOT enable flow control until a suitable solution for
 		 *  shutting down pause frames is found.
 		 */
-		netxen_crb_writelit_adapter(adapter,
-					    NETXEN_NIU_GB_MAC_CONFIG_0(port),
-					    0x5);
+		NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port), 0x5);
 	}
 
 	if (netxen_niu_gbe_enable_phy_interrupts(adapter))
@@ -339,30 +315,21 @@ static void netxen_niu_gbe_set_mii_mode(struct netxen_adapter *adapter,
 static void netxen_niu_gbe_set_gmii_mode(struct netxen_adapter *adapter,
 					 int port, long enable)
 {
-	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_MODE, 0x2);
-	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
-				    0x80000000);
-	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
-				    0x0000f0025);
-	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB_MAC_CONFIG_1(port),
-				    0xf2ff);
-	netxen_crb_writelit_adapter(adapter,
-				    NETXEN_NIU_GB0_MII_MODE + (port << 3), 0);
-	netxen_crb_writelit_adapter(adapter,
-				    NETXEN_NIU_GB0_GMII_MODE + (port << 3), 1);
-	netxen_crb_writelit_adapter(adapter,
-				    (NETXEN_NIU_GB0_HALF_DUPLEX + port * 4), 0);
-	netxen_crb_writelit_adapter(adapter,
-				    NETXEN_NIU_GB_MII_MGMT_CONFIG(port), 0x7);
+	NXWR32(adapter, NETXEN_NIU_MODE, 0x2);
+	NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port), 0x80000000);
+	NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port), 0x0000f0025);
+	NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_1(port), 0xf2ff);
+	NXWR32(adapter, NETXEN_NIU_GB0_MII_MODE + (port << 3), 0);
+	NXWR32(adapter, NETXEN_NIU_GB0_GMII_MODE + (port << 3), 1);
+	NXWR32(adapter, (NETXEN_NIU_GB0_HALF_DUPLEX + port * 4), 0);
+	NXWR32(adapter, NETXEN_NIU_GB_MII_MGMT_CONFIG(port), 0x7);
 
 	if (enable) {
 		/*
 		 * Do NOT enable flow control until a suitable solution for
 		 *  shutting down pause frames is found.
 		 */
-		netxen_crb_writelit_adapter(adapter,
-					    NETXEN_NIU_GB_MAC_CONFIG_0(port),
-					    0x5);
+		NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port), 0x5);
 	}
 
 	if (netxen_niu_gbe_enable_phy_interrupts(adapter))
@@ -402,17 +369,12 @@ int netxen_niu_gbe_init_port(struct netxen_adapter *adapter, int port)
 			 * plugged in.
 			 */
 
-			netxen_crb_writelit_adapter(adapter,
-						    NETXEN_NIU_GB_MAC_CONFIG_0
-						    (port),
+			NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
 						    NETXEN_GB_MAC_SOFT_RESET);
-			netxen_crb_writelit_adapter(adapter,
-						    NETXEN_NIU_GB_MAC_CONFIG_0
-						    (port),
-						    NETXEN_GB_MAC_RESET_PROT_BLK
-						    | NETXEN_GB_MAC_ENABLE_TX_RX
-						    |
-						    NETXEN_GB_MAC_PAUSED_FRMS);
+			NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
+					    NETXEN_GB_MAC_RESET_PROT_BLK |
+					    NETXEN_GB_MAC_ENABLE_TX_RX |
+					    NETXEN_GB_MAC_PAUSED_FRMS);
 			if (netxen_niu_gbe_clear_phy_interrupts(adapter))
 				printk(KERN_ERR
 				       "ERROR clearing PHY interrupts\n");
@@ -433,10 +395,8 @@ int netxen_niu_gbe_init_port(struct netxen_adapter *adapter, int port)
 int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port)
 {
 	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
-		netxen_crb_writelit_adapter(adapter,
-			NETXEN_NIU_XGE_CONFIG_1+(0x10000*port), 0x1447);
-		netxen_crb_writelit_adapter(adapter,
-			NETXEN_NIU_XGE_CONFIG_0+(0x10000*port), 0x5);
+		NXWR32(adapter, NETXEN_NIU_XGE_CONFIG_1+(0x10000*port), 0x1447);
+		NXWR32(adapter, NETXEN_NIU_XGE_CONFIG_0+(0x10000*port), 0x5);
 	}
 
 	return 0;
@@ -459,10 +419,8 @@ static int netxen_niu_macaddr_get(struct netxen_adapter *adapter,
 	if ((phy < 0) || (phy > 3))
 		return -EINVAL;
 
-	stationhigh = adapter->hw_read_wx(adapter,
-			NETXEN_NIU_GB_STATION_ADDR_0(phy));
-	stationlow = adapter->hw_read_wx(adapter,
-			NETXEN_NIU_GB_STATION_ADDR_1(phy));
+	stationhigh = NXRD32(adapter, NETXEN_NIU_GB_STATION_ADDR_0(phy));
+	stationlow = NXRD32(adapter, NETXEN_NIU_GB_STATION_ADDR_1(phy));
 	((__le32 *)val)[1] = cpu_to_le32(stationhigh);
 	((__le32 *)val)[0] = cpu_to_le32(stationlow);
 
@@ -491,14 +449,12 @@ int netxen_niu_macaddr_set(struct netxen_adapter *adapter,
 		temp[0] = temp[1] = 0;
 		memcpy(temp + 2, addr, 2);
 		val = le32_to_cpu(*(__le32 *)temp);
-		if (adapter->hw_write_wx(adapter,
-				NETXEN_NIU_GB_STATION_ADDR_1(phy), val))
+		if (NXWR32(adapter, NETXEN_NIU_GB_STATION_ADDR_1(phy), val))
 			return -EIO;
 
 		memcpy(temp, ((u8 *) addr) + 2, sizeof(__le32));
 		val = le32_to_cpu(*(__le32 *)temp);
-		if (adapter->hw_write_wx(adapter,
-				NETXEN_NIU_GB_STATION_ADDR_0(phy), val))
+		if (NXWR32(adapter, NETXEN_NIU_GB_STATION_ADDR_0(phy), val))
 			return -2;
 
 		netxen_niu_macaddr_get(adapter,
@@ -529,8 +485,7 @@ int netxen_niu_disable_gbe_port(struct netxen_adapter *adapter)
 		return -EINVAL;
 	mac_cfg0 = 0;
 	netxen_gb_soft_reset(mac_cfg0);
-	if (adapter->hw_write_wx(adapter,
-				NETXEN_NIU_GB_MAC_CONFIG_0(port), mac_cfg0))
+	if (NXWR32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port), mac_cfg0))
 		return -EIO;
 	return 0;
 }
@@ -548,8 +503,8 @@ int netxen_niu_disable_xg_port(struct netxen_adapter *adapter)
 		return -EINVAL;
 
 	mac_cfg = 0;
-	if (adapter->hw_write_wx(adapter,
-		NETXEN_NIU_XGE_CONFIG_0 + (0x10000 * port), mac_cfg))
+	if (NXWR32(adapter,
+			NETXEN_NIU_XGE_CONFIG_0 + (0x10000 * port), mac_cfg))
 		return -EIO;
 	return 0;
 }
@@ -565,7 +520,7 @@ int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter,
 		return -EINVAL;
 
 	/* save previous contents */
-	reg = adapter->hw_read_wx(adapter, NETXEN_NIU_GB_DROP_WRONGADDR);
+	reg = NXRD32(adapter, NETXEN_NIU_GB_DROP_WRONGADDR);
 	if (mode == NETXEN_NIU_PROMISC_MODE) {
 		switch (port) {
 		case 0:
@@ -601,7 +556,7 @@ int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter,
 			return -EIO;
 		}
 	}
-	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_DROP_WRONGADDR, reg))
+	if (NXWR32(adapter, NETXEN_NIU_GB_DROP_WRONGADDR, reg))
 		return -EIO;
 	return 0;
 }
@@ -628,28 +583,24 @@ int netxen_niu_xg_macaddr_set(struct netxen_adapter *adapter,
 	case 0:
 	    memcpy(temp + 2, addr, 2);
 	    val = le32_to_cpu(*(__le32 *)temp);
-	    if (adapter->hw_write_wx(adapter,
-				    NETXEN_NIU_XGE_STATION_ADDR_0_1, val))
+	    if (NXWR32(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_1, val))
 		return -EIO;
 
 	    memcpy(&temp, ((u8 *) addr) + 2, sizeof(__le32));
 	    val = le32_to_cpu(*(__le32 *)temp);
-	    if (adapter->hw_write_wx(adapter,
-				    NETXEN_NIU_XGE_STATION_ADDR_0_HI, val))
+	    if (NXWR32(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_HI, val))
 		return -EIO;
 	    break;
 
 	case 1:
 	    memcpy(temp + 2, addr, 2);
 	    val = le32_to_cpu(*(__le32 *)temp);
-	    if (adapter->hw_write_wx(adapter,
-				    NETXEN_NIU_XG1_STATION_ADDR_0_1, val))
+	    if (NXWR32(adapter, NETXEN_NIU_XG1_STATION_ADDR_0_1, val))
 		return -EIO;
 
 	    memcpy(&temp, ((u8 *) addr) + 2, sizeof(__le32));
 	    val = le32_to_cpu(*(__le32 *)temp);
-	    if (adapter->hw_write_wx(adapter,
-				    NETXEN_NIU_XG1_STATION_ADDR_0_HI, val))
+	    if (NXWR32(adapter, NETXEN_NIU_XG1_STATION_ADDR_0_HI, val))
 		return -EIO;
 	    break;
 
@@ -670,8 +621,7 @@ int netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
 	if (port > NETXEN_NIU_MAX_XG_PORTS)
 		return -EINVAL;
 
-	reg = adapter->hw_read_wx(adapter,
-		NETXEN_NIU_XGE_CONFIG_1 + (0x10000 * port));
+	reg = NXRD32(adapter, NETXEN_NIU_XGE_CONFIG_1 + (0x10000 * port));
 	if (mode == NETXEN_NIU_PROMISC_MODE)
 		reg = (reg | 0x2000UL);
 	else
@@ -682,8 +632,7 @@ int netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
 	else
 		reg = (reg & ~0x1000UL);
 
-	netxen_crb_writelit_adapter(adapter,
-		NETXEN_NIU_XGE_CONFIG_1 + (0x10000 * port), reg);
+	NXWR32(adapter, NETXEN_NIU_XGE_CONFIG_1 + (0x10000 * port), reg);
 
 	return 0;
 }
-- 
1.6.0.2

