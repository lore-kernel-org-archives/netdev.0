From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next-2.6 2/2] qlcnic: Add support for configuring eswitch
 and npars
Date: Tue, 29 Jun 2010 11:01:20 -0700
Message-ID: <alpine.OSX.2.00.1006291055150.30643@macintosh-2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:14245 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753824Ab0F2SBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 14:01:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Forgot to put the From header in the patch. Please ignore the previous one 
in the series and apply this instead.
Sorry for any inconvenience.

-Anirban

From: Rajesh K Borundia <rajesh.borundia@qlogic.com>

Following changes are made:
1.Obtain capabilities of Nic partition.
2.Configure tx bandwidth of particular Nic partition.
3.Configure the eswitch for setting port mirroring, enable mac
learning, promiscous mode.

Signed-off-by: Rajesh K Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |   77 ++++++-
 drivers/net/qlcnic/qlcnic_ctx.c  |   90 ++------
 drivers/net/qlcnic/qlcnic_main.c |  450 +++++++++++++++++++++++++++++++++++++-
 3 files changed, 542 insertions(+), 75 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 3675678..60ea7cb 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -959,8 +959,6 @@ struct qlcnic_adapter {
 	u16 switch_mode;
 	u16 max_tx_ques;
 	u16 max_rx_ques;
-	u16 min_tx_bw;
-	u16 max_tx_bw;
 	u16 max_mtu;
 
 	u32 fw_hal_version;
@@ -984,7 +982,7 @@ struct qlcnic_adapter {
 
 	u64 dev_rst_time;
 
-	struct qlcnic_pci_info *npars;
+	struct qlcnic_npar_info *npars;
 	struct qlcnic_eswitch *eswitch;
 	struct qlcnic_nic_template *nic_ops;
 
@@ -1042,6 +1040,18 @@ struct qlcnic_pci_info {
 	u8	reserved2[106];
 };
 
+struct qlcnic_npar_info {
+	u16	vlan_id;
+	u8	phy_port;
+	u8	type;
+	u8	active;
+	u8	enable_pm;
+	u8	dest_npar;
+	u8	host_vlan_tag;
+	u8	promisc_mode;
+	u8	discard_tagged;
+	u8	mac_learning;
+};
 struct qlcnic_eswitch {
 	u8	port;
 	u8	active_vports;
@@ -1057,6 +1067,63 @@ struct qlcnic_eswitch {
 #define QLCNIC_SWITCH_PORT_MIRRORING	BIT_4
 };
 
+
+/* Return codes for Error handling */
+#define QL_STATUS_INVALID_PARAM	-1
+
+#define MAX_BW			10000
+#define MIN_BW			100
+#define MAX_VLAN_ID		4095
+#define MIN_VLAN_ID		2
+#define MAX_TX_QUEUES		1
+#define MAX_RX_QUEUES		4
+#define DEFAULT_MAC_LEARN	1
+
+#define IS_VALID_VLAN(vlan)	(vlan >= MIN_VLAN_ID && vlan <= MAX_VLAN_ID)
+#define IS_VALID_BW(bw)		(bw >= MIN_BW && bw <= MAX_BW \
+							&& (bw % 100) == 0)
+#define IS_VALID_TX_QUEUES(que)	(que > 0 && que <= MAX_TX_QUEUES)
+#define IS_VALID_RX_QUEUES(que)	(que > 0 && que <= MAX_RX_QUEUES)
+#define IS_VALID_MODE(mode)	(mode == 0 || mode == 1)
+
+struct qlcnic_pci_func_cfg {
+	u16	func_type;
+	u16	min_bw;
+	u16	max_bw;
+	u16	port_num;
+	u8	pci_func;
+	u8	func_state;
+	u8	def_mac_addr[6];
+};
+
+struct qlcnic_npar_func_cfg {
+	u32	fw_capab;
+	u16	port_num;
+	u16	min_bw;
+	u16	max_bw;
+	u16	max_tx_queues;
+	u16	max_rx_queues;
+	u8	pci_func;
+	u8	op_mode;
+};
+
+struct qlcnic_pm_func_cfg {
+	u8	pci_func;
+	u8	action;
+	u8	dest_npar;
+	u8	reserved[5];
+};
+
+struct qlcnic_esw_func_cfg {
+	u16	vlan_id;
+	u8	pci_func;
+	u8	host_vlan_tag;
+	u8	promisc_mode;
+	u8	discard_tagged;
+	u8	mac_learning;
+	u8	reserved;
+};
+
 int qlcnic_fw_cmd_query_phy(struct qlcnic_adapter *adapter, u32 reg, u32 *val);
 int qlcnic_fw_cmd_set_phy(struct qlcnic_adapter *adapter, u32 reg, u32 val);
 
@@ -1169,9 +1236,9 @@ void qlcnic_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring);
 /* Management functions */
 int qlcnic_set_mac_address(struct qlcnic_adapter *, u8*);
 int qlcnic_get_mac_address(struct qlcnic_adapter *, u8*);
-int qlcnic_get_nic_info(struct qlcnic_adapter *, u8);
+int qlcnic_get_nic_info(struct qlcnic_adapter *, struct qlcnic_info *, u8);
 int qlcnic_set_nic_info(struct qlcnic_adapter *, struct qlcnic_info *);
-int qlcnic_get_pci_info(struct qlcnic_adapter *);
+int qlcnic_get_pci_info(struct qlcnic_adapter *, struct qlcnic_pci_info*);
 int qlcnic_reset_partition(struct qlcnic_adapter *, u8);
 
 /*  eSwitch management functions */
diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index 7969a7a..cdd44b4 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -611,7 +611,8 @@ int qlcnic_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac)
 }
 
 /* Get info of a NIC partition */
-int qlcnic_get_nic_info(struct qlcnic_adapter *adapter, u8 func_id)
+int qlcnic_get_nic_info(struct qlcnic_adapter *adapter,
+				struct qlcnic_info *npar_info, u8 func_id)
 {
 	int	err;
 	dma_addr_t nic_dma_t;
@@ -635,29 +636,23 @@ int qlcnic_get_nic_info(struct qlcnic_adapter *adapter, u8 func_id)
 			QLCNIC_CDRP_CMD_GET_NIC_INFO);
 
 	if (err == QLCNIC_RCODE_SUCCESS) {
-		adapter->physical_port = le16_to_cpu(nic_info->phys_port);
-		adapter->switch_mode = le16_to_cpu(nic_info->switch_mode);
-		adapter->max_tx_ques = le16_to_cpu(nic_info->max_tx_ques);
-		adapter->max_rx_ques = le16_to_cpu(nic_info->max_rx_ques);
-		adapter->min_tx_bw = le16_to_cpu(nic_info->min_tx_bw);
-		adapter->max_tx_bw = le16_to_cpu(nic_info->max_tx_bw);
-		adapter->max_mtu = le16_to_cpu(nic_info->max_mtu);
-		adapter->capabilities = le32_to_cpu(nic_info->capabilities);
-		adapter->max_mac_filters = nic_info->max_mac_filters;
-
-		if (adapter->capabilities & BIT_6)
-			adapter->flags |= QLCNIC_ESWITCH_ENABLED;
-		else
-			adapter->flags &= ~QLCNIC_ESWITCH_ENABLED;
+		npar_info->phys_port = le16_to_cpu(nic_info->phys_port);
+		npar_info->switch_mode = le16_to_cpu(nic_info->switch_mode);
+		npar_info->max_tx_ques = le16_to_cpu(nic_info->max_tx_ques);
+		npar_info->max_rx_ques = le16_to_cpu(nic_info->max_rx_ques);
+		npar_info->min_tx_bw = le16_to_cpu(nic_info->min_tx_bw);
+		npar_info->max_tx_bw = le16_to_cpu(nic_info->max_tx_bw);
+		npar_info->capabilities = le32_to_cpu(nic_info->capabilities);
+		npar_info->max_mtu = le16_to_cpu(nic_info->max_mtu);
 
 		dev_info(&adapter->pdev->dev,
 			"phy port: %d switch_mode: %d,\n"
 			"\tmax_tx_q: %d max_rx_q: %d min_tx_bw: 0x%x,\n"
 			"\tmax_tx_bw: 0x%x max_mtu:0x%x, capabilities: 0x%x\n",
-			adapter->physical_port, adapter->switch_mode,
-			adapter->max_tx_ques, adapter->max_rx_ques,
-			adapter->min_tx_bw, adapter->max_tx_bw,
-			adapter->max_mtu, adapter->capabilities);
+			npar_info->phys_port, npar_info->switch_mode,
+			npar_info->max_tx_ques, npar_info->max_rx_ques,
+			npar_info->min_tx_bw, npar_info->max_tx_bw,
+			npar_info->max_mtu, npar_info->capabilities);
 	} else {
 		dev_err(&adapter->pdev->dev,
 			"Failed to get nic info%d\n", err);
@@ -672,7 +667,6 @@ int qlcnic_get_nic_info(struct qlcnic_adapter *adapter, u8 func_id)
 int qlcnic_set_nic_info(struct qlcnic_adapter *adapter, struct qlcnic_info *nic)
 {
 	int err = -EIO;
-	u32 func_state;
 	dma_addr_t nic_dma_t;
 	void *nic_info_addr;
 	struct qlcnic_info *nic_info;
@@ -681,17 +675,6 @@ int qlcnic_set_nic_info(struct qlcnic_adapter *adapter, struct qlcnic_info *nic)
 	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
 		return err;
 
-	if (qlcnic_api_lock(adapter))
-		return err;
-
-	func_state = QLCRD32(adapter, QLCNIC_CRB_DEV_REF_COUNT);
-	if (QLC_DEV_CHECK_ACTIVE(func_state, nic->pci_func)) {
-		qlcnic_api_unlock(adapter);
-		return err;
-	}
-
-	qlcnic_api_unlock(adapter);
-
 	nic_info_addr = pci_alloc_consistent(adapter->pdev, nic_size,
 			&nic_dma_t);
 	if (!nic_info_addr)
@@ -716,7 +699,7 @@ int qlcnic_set_nic_info(struct qlcnic_adapter *adapter, struct qlcnic_info *nic)
 			adapter->fw_hal_version,
 			MSD(nic_dma_t),
 			LSD(nic_dma_t),
-			nic_size,
+			((nic->pci_func << 16) | nic_size),
 			QLCNIC_CDRP_CMD_SET_NIC_INFO);
 
 	if (err != QLCNIC_RCODE_SUCCESS) {
@@ -730,7 +713,8 @@ int qlcnic_set_nic_info(struct qlcnic_adapter *adapter, struct qlcnic_info *nic)
 }
 
 /* Get PCI Info of a partition */
-int qlcnic_get_pci_info(struct qlcnic_adapter *adapter)
+int qlcnic_get_pci_info(struct qlcnic_adapter *adapter,
+				struct qlcnic_pci_info *pci_info)
 {
 	int err = 0, i;
 	dma_addr_t pci_info_dma_t;
@@ -745,21 +729,6 @@ int qlcnic_get_pci_info(struct qlcnic_adapter *adapter)
 		return -ENOMEM;
 	memset(pci_info_addr, 0, pci_size);
 
-	if (!adapter->npars)
-		adapter->npars = kzalloc(pci_size, GFP_KERNEL);
-	if (!adapter->npars) {
-		err = -ENOMEM;
-		goto err_npar;
-	}
-
-	if (!adapter->eswitch)
-		adapter->eswitch = kzalloc(sizeof(struct qlcnic_eswitch) *
-				QLCNIC_NIU_MAX_XG_PORTS, GFP_KERNEL);
-	if (!adapter->eswitch) {
-		err = -ENOMEM;
-		goto err_eswitch;
-	}
-
 	npar = (struct qlcnic_pci_info *) pci_info_addr;
 	err = qlcnic_issue_cmd(adapter,
 			adapter->ahw.pci_func,
@@ -770,31 +739,24 @@ int qlcnic_get_pci_info(struct qlcnic_adapter *adapter)
 			QLCNIC_CDRP_CMD_GET_PCI_INFO);
 
 	if (err == QLCNIC_RCODE_SUCCESS) {
-		for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++, npar++) {
-			adapter->npars[i].id = le32_to_cpu(npar->id);
-			adapter->npars[i].active = le32_to_cpu(npar->active);
-			adapter->npars[i].type = le32_to_cpu(npar->type);
-			adapter->npars[i].default_port =
+		for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++, npar++, pci_info++) {
+			pci_info->id = le32_to_cpu(npar->id);
+			pci_info->active = le32_to_cpu(npar->active);
+			pci_info->type = le32_to_cpu(npar->type);
+			pci_info->default_port =
 				le32_to_cpu(npar->default_port);
-			adapter->npars[i].tx_min_bw =
+			pci_info->tx_min_bw =
 				le32_to_cpu(npar->tx_min_bw);
-			adapter->npars[i].tx_max_bw =
+			pci_info->tx_max_bw =
 				le32_to_cpu(npar->tx_max_bw);
-			memcpy(adapter->npars[i].mac, npar->mac, ETH_ALEN);
+			memcpy(pci_info->mac, npar->mac, ETH_ALEN);
 		}
 	} else {
 		dev_err(&adapter->pdev->dev,
 			"Failed to get PCI Info%d\n", err);
-		kfree(adapter->npars);
 		err = -EIO;
 	}
-	goto err_npar;
-
-err_eswitch:
-	kfree(adapter->npars);
-	adapter->npars = NULL;
 
-err_npar:
 	pci_free_consistent(adapter->pdev, pci_size, pci_info_addr,
 		pci_info_dma_t);
 	return err;
@@ -1012,9 +974,7 @@ int qlcnic_config_switch_port(struct qlcnic_adapter *adapter, u8 id,
 	if (err != QLCNIC_RCODE_SUCCESS) {
 		dev_err(&adapter->pdev->dev,
 			"Failed to configure eswitch port%d\n", eswitch->port);
-		eswitch->flags |= QLCNIC_SWITCH_ENABLE;
 	} else {
-		eswitch->flags &= ~QLCNIC_SWITCH_ENABLE;
 		dev_info(&adapter->pdev->dev,
 			"Configured eSwitch for port %d\n", eswitch->port);
 	}
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 981aa91..18e2b2e 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -476,6 +476,53 @@ qlcnic_cleanup_pci_map(struct qlcnic_adapter *adapter)
 }
 
 static int
+qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_pci_info pci_info[QLCNIC_MAX_PCI_FUNC];
+	int i, ret = 0, err;
+	u8 pfn;
+
+	if (!adapter->npars)
+		adapter->npars = kzalloc(sizeof(struct qlcnic_npar_info) *
+				QLCNIC_MAX_PCI_FUNC, GFP_KERNEL);
+	if (!adapter->npars)
+		return -ENOMEM;
+
+	if (!adapter->eswitch)
+		adapter->eswitch = kzalloc(sizeof(struct qlcnic_eswitch) *
+				QLCNIC_NIU_MAX_XG_PORTS, GFP_KERNEL);
+	if (!adapter->eswitch) {
+		err = -ENOMEM;
+		goto err_eswitch;
+	}
+
+	ret = qlcnic_get_pci_info(adapter, pci_info);
+	if (!ret) {
+		for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
+			pfn = pci_info[i].id;
+			if (pfn > QLCNIC_MAX_PCI_FUNC)
+				return QL_STATUS_INVALID_PARAM;
+			adapter->npars[pfn].active = pci_info[i].active;
+			adapter->npars[pfn].type = pci_info[i].type;
+			adapter->npars[pfn].phy_port = pci_info[i].default_port;
+			adapter->npars[pfn].mac_learning = DEFAULT_MAC_LEARN;
+		}
+
+		for (i = 0; i < QLCNIC_NIU_MAX_XG_PORTS; i++)
+			adapter->eswitch[i].flags |= QLCNIC_SWITCH_ENABLE;
+
+		return ret;
+	}
+
+	kfree(adapter->eswitch);
+	adapter->eswitch = NULL;
+err_eswitch:
+	kfree(adapter->npars);
+
+	return ret;
+}
+
+static int
 qlcnic_set_function_modes(struct qlcnic_adapter *adapter)
 {
 	u8 id;
@@ -494,7 +541,7 @@ qlcnic_set_function_modes(struct qlcnic_adapter *adapter)
 
 	if (qlcnic_config_npars) {
 		for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
-			id = adapter->npars[i].id;
+			id = i;
 			if (adapter->npars[i].type != QLCNIC_TYPE_NIC ||
 				id == adapter->ahw.pci_func)
 				continue;
@@ -519,6 +566,7 @@ qlcnic_get_driver_mode(struct qlcnic_adapter *adapter)
 {
 	void __iomem *msix_base_addr;
 	void __iomem *priv_op;
+	struct qlcnic_info nic_info;
 	u32 func;
 	u32 msix_base;
 	u32 op_mode, priv_level;
@@ -533,7 +581,14 @@ qlcnic_get_driver_mode(struct qlcnic_adapter *adapter)
 	func = (func - msix_base)/QLCNIC_MSIX_TBL_PGSIZE;
 	adapter->ahw.pci_func = func;
 
-	qlcnic_get_nic_info(adapter, adapter->ahw.pci_func);
+	if (!qlcnic_get_nic_info(adapter, &nic_info, adapter->ahw.pci_func)) {
+		adapter->capabilities = nic_info.capabilities;
+
+		if (adapter->capabilities & BIT_6)
+			adapter->flags |= QLCNIC_ESWITCH_ENABLED;
+		else
+			adapter->flags &= ~QLCNIC_ESWITCH_ENABLED;
+	}
 
 	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))	{
 		adapter->nic_ops = &qlcnic_ops;
@@ -552,7 +607,7 @@ qlcnic_get_driver_mode(struct qlcnic_adapter *adapter)
 	case QLCNIC_MGMT_FUNC:
 		adapter->op_mode = QLCNIC_MGMT_FUNC;
 		adapter->nic_ops = &qlcnic_ops;
-		qlcnic_get_pci_info(adapter);
+		qlcnic_init_pci_info(adapter);
 		/* Set privilege level for other functions */
 		qlcnic_set_function_modes(adapter);
 		dev_info(&adapter->pdev->dev,
@@ -654,7 +709,7 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 	int i, offset, val;
 	int *ptr32;
 	struct pci_dev *pdev = adapter->pdev;
-
+	struct qlcnic_info nic_info;
 	adapter->driver_mismatch = 0;
 
 	ptr32 = (int *)&serial_num;
@@ -696,7 +751,15 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 		adapter->num_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_1G;
 	}
 
-	qlcnic_get_nic_info(adapter, adapter->ahw.pci_func);
+	if (!qlcnic_get_nic_info(adapter, &nic_info, adapter->ahw.pci_func)) {
+		adapter->physical_port = nic_info.phys_port;
+		adapter->switch_mode = nic_info.switch_mode;
+		adapter->max_tx_ques = nic_info.max_tx_ques;
+		adapter->max_rx_ques = nic_info.max_rx_ques;
+		adapter->capabilities = nic_info.capabilities;
+		adapter->max_mac_filters = nic_info.max_mac_filters;
+		adapter->max_mtu = nic_info.max_mtu;
+	}
 
 	adapter->msix_supported = !!use_msi_x;
 	adapter->rss_supported = !!use_msi_x;
@@ -2822,6 +2885,364 @@ static struct bin_attribute bin_attr_mem = {
 	.write = qlcnic_sysfs_write_mem,
 };
 
+int
+validate_pm_config(struct qlcnic_adapter *adapter,
+			struct qlcnic_pm_func_cfg *pm_cfg, int count)
+{
+
+	u8 src_pci_func, s_esw_id, d_esw_id;
+	u8 dest_pci_func;
+	int i;
+
+	for (i = 0; i < count; i++) {
+		src_pci_func = pm_cfg[i].pci_func;
+		dest_pci_func = pm_cfg[i].dest_npar;
+		if (src_pci_func >= QLCNIC_MAX_PCI_FUNC
+				|| dest_pci_func >= QLCNIC_MAX_PCI_FUNC)
+			return QL_STATUS_INVALID_PARAM;
+
+		if (adapter->npars[src_pci_func].type != QLCNIC_TYPE_NIC)
+			return QL_STATUS_INVALID_PARAM;
+
+		if (adapter->npars[dest_pci_func].type != QLCNIC_TYPE_NIC)
+			return QL_STATUS_INVALID_PARAM;
+
+		if (!IS_VALID_MODE(pm_cfg[i].action))
+			return QL_STATUS_INVALID_PARAM;
+
+		s_esw_id = adapter->npars[src_pci_func].phy_port;
+		d_esw_id = adapter->npars[dest_pci_func].phy_port;
+
+		if (s_esw_id != d_esw_id)
+			return QL_STATUS_INVALID_PARAM;
+
+	}
+	return 0;
+
+}
+
+static ssize_t
+qlcnic_sysfs_write_pm_config(struct file *filp, struct kobject *kobj,
+	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	struct qlcnic_pm_func_cfg *pm_cfg;
+	u32 id, action, pci_func;
+	int count, rem, i, ret;
+
+	count	= size / sizeof(struct qlcnic_pm_func_cfg);
+	rem	= size % sizeof(struct qlcnic_pm_func_cfg);
+	if (rem)
+		return QL_STATUS_INVALID_PARAM;
+
+	pm_cfg = (struct qlcnic_pm_func_cfg *) buf;
+
+	ret = validate_pm_config(adapter, pm_cfg, count);
+	if (ret)
+		return ret;
+	for (i = 0; i < count; i++) {
+		pci_func = pm_cfg[i].pci_func;
+		action = pm_cfg[i].action;
+		id = adapter->npars[pci_func].phy_port;
+		ret = qlcnic_config_port_mirroring(adapter, id,
+						action, pci_func);
+		if (ret)
+			return ret;
+	}
+
+	for (i = 0; i < count; i++) {
+		pci_func = pm_cfg[i].pci_func;
+		id = adapter->npars[pci_func].phy_port;
+		adapter->npars[pci_func].enable_pm = pm_cfg[i].action;
+		adapter->npars[pci_func].dest_npar = id;
+	}
+	return size;
+}
+
+static ssize_t
+qlcnic_sysfs_read_pm_config(struct file *filp, struct kobject *kobj,
+	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	struct qlcnic_pm_func_cfg pm_cfg[QLCNIC_MAX_PCI_FUNC];
+	int i;
+
+	if (size != sizeof(pm_cfg))
+		return QL_STATUS_INVALID_PARAM;
+
+	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
+		if (adapter->npars[i].type != QLCNIC_TYPE_NIC)
+			continue;
+		pm_cfg[i].action = adapter->npars[i].enable_pm;
+		pm_cfg[i].dest_npar = 0;
+		pm_cfg[i].pci_func = i;
+	}
+	memcpy(buf, &pm_cfg, size);
+
+	return size;
+}
+
+int
+validate_esw_config(struct qlcnic_adapter *adapter,
+			struct qlcnic_esw_func_cfg *esw_cfg, int count)
+{
+	u8 pci_func;
+	int i;
+
+	for (i = 0; i < count; i++) {
+		pci_func = esw_cfg[i].pci_func;
+		if (pci_func >= QLCNIC_MAX_PCI_FUNC)
+			return QL_STATUS_INVALID_PARAM;
+
+		if (adapter->npars[i].type != QLCNIC_TYPE_NIC)
+			return QL_STATUS_INVALID_PARAM;
+
+		if (esw_cfg->host_vlan_tag == 1)
+			if (!IS_VALID_VLAN(esw_cfg[i].vlan_id))
+				return QL_STATUS_INVALID_PARAM;
+
+		if (!IS_VALID_MODE(esw_cfg[i].promisc_mode)
+				|| !IS_VALID_MODE(esw_cfg[i].host_vlan_tag)
+				|| !IS_VALID_MODE(esw_cfg[i].mac_learning)
+				|| !IS_VALID_MODE(esw_cfg[i].discard_tagged))
+			return QL_STATUS_INVALID_PARAM;
+	}
+
+	return 0;
+}
+
+static ssize_t
+qlcnic_sysfs_write_esw_config(struct file *file, struct kobject *kobj,
+	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	struct qlcnic_esw_func_cfg *esw_cfg;
+	u8 id, discard_tagged, promsc_mode, mac_learn;
+	u8 vlan_tagging, pci_func, vlan_id;
+	int count, rem, i, ret;
+
+	count	= size / sizeof(struct qlcnic_esw_func_cfg);
+	rem	= size % sizeof(struct qlcnic_esw_func_cfg);
+	if (rem)
+		return QL_STATUS_INVALID_PARAM;
+
+	esw_cfg = (struct qlcnic_esw_func_cfg *) buf;
+	ret = validate_esw_config(adapter, esw_cfg, count);
+	if (ret)
+		return ret;
+
+	for (i = 0; i < count; i++) {
+		pci_func = esw_cfg[i].pci_func;
+		id = adapter->npars[pci_func].phy_port;
+		vlan_tagging = esw_cfg[i].host_vlan_tag;
+		promsc_mode = esw_cfg[i].promisc_mode;
+		mac_learn = esw_cfg[i].mac_learning;
+		vlan_id	= esw_cfg[i].vlan_id;
+		discard_tagged = esw_cfg[i].discard_tagged;
+		ret = qlcnic_config_switch_port(adapter, id, vlan_tagging,
+						discard_tagged,
+						promsc_mode,
+						mac_learn,
+						pci_func,
+						vlan_id);
+		if (ret)
+			return ret;
+	}
+
+	for (i = 0; i < count; i++) {
+		pci_func = esw_cfg[i].pci_func;
+		adapter->npars[pci_func].promisc_mode = esw_cfg[i].promisc_mode;
+		adapter->npars[pci_func].mac_learning =	esw_cfg[i].mac_learning;
+		adapter->npars[pci_func].vlan_id = esw_cfg[i].vlan_id;
+		adapter->npars[pci_func].discard_tagged	=
+						esw_cfg[i].discard_tagged;
+		adapter->npars[pci_func].host_vlan_tag =
+						esw_cfg[i].host_vlan_tag;
+	}
+
+	return size;
+}
+
+static ssize_t
+qlcnic_sysfs_read_esw_config(struct file *file, struct kobject *kobj,
+	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	struct qlcnic_esw_func_cfg esw_cfg[QLCNIC_MAX_PCI_FUNC];
+	int i;
+
+	if (size != sizeof(esw_cfg))
+		return QL_STATUS_INVALID_PARAM;
+
+	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
+		if (adapter->npars[i].type != QLCNIC_TYPE_NIC)
+			continue;
+
+		esw_cfg[i].host_vlan_tag = adapter->npars[i].host_vlan_tag;
+		esw_cfg[i].promisc_mode = adapter->npars[i].promisc_mode;
+		esw_cfg[i].discard_tagged = adapter->npars[i].discard_tagged;
+		esw_cfg[i].vlan_id = adapter->npars[i].vlan_id;
+		esw_cfg[i].mac_learning = adapter->npars[i].mac_learning;
+	}
+	memcpy(buf, &esw_cfg, size);
+
+	return size;
+}
+
+int
+validate_npar_config(struct qlcnic_adapter *adapter,
+				struct qlcnic_npar_func_cfg *np_cfg, int count)
+{
+	u8 pci_func, i;
+
+	for (i = 0; i < count; i++) {
+		pci_func = np_cfg[i].pci_func;
+		if (pci_func >= QLCNIC_MAX_PCI_FUNC)
+			return QL_STATUS_INVALID_PARAM;
+
+		if (adapter->npars[pci_func].type != QLCNIC_TYPE_NIC)
+			return QL_STATUS_INVALID_PARAM;
+
+		if (!IS_VALID_BW(np_cfg[i].min_bw)
+				|| !IS_VALID_BW(np_cfg[i].max_bw)
+				|| !IS_VALID_RX_QUEUES(np_cfg[i].max_rx_queues)
+				|| !IS_VALID_TX_QUEUES(np_cfg[i].max_tx_queues))
+			return QL_STATUS_INVALID_PARAM;
+	}
+	return 0;
+}
+
+static ssize_t
+qlcnic_sysfs_write_npar_config(struct file *file, struct kobject *kobj,
+	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	struct qlcnic_info nic_info;
+	struct qlcnic_npar_func_cfg *np_cfg;
+	int i, count, rem, ret;
+	u8 pci_func;
+
+	count	= size / sizeof(struct qlcnic_npar_func_cfg);
+	rem	= size % sizeof(struct qlcnic_npar_func_cfg);
+	if (rem)
+		return QL_STATUS_INVALID_PARAM;
+
+	np_cfg = (struct qlcnic_npar_func_cfg *) buf;
+	ret = validate_npar_config(adapter, np_cfg, count);
+	if (ret)
+		return ret;
+
+	for (i = 0; i < count ; i++) {
+		pci_func = np_cfg[i].pci_func;
+		ret = qlcnic_get_nic_info(adapter, &nic_info, pci_func);
+		if (ret)
+			return ret;
+		nic_info.pci_func = pci_func;
+		nic_info.min_tx_bw = np_cfg[i].min_bw;
+		nic_info.max_tx_bw = np_cfg[i].max_bw;
+		ret = qlcnic_set_nic_info(adapter, &nic_info);
+		if (ret)
+			return ret;
+	}
+
+	return size;
+
+}
+static ssize_t
+qlcnic_sysfs_read_npar_config(struct file *file, struct kobject *kobj,
+	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	struct qlcnic_info nic_info;
+	struct qlcnic_npar_func_cfg np_cfg[QLCNIC_MAX_PCI_FUNC];
+	int i, ret;
+
+	if (size != sizeof(np_cfg))
+		return QL_STATUS_INVALID_PARAM;
+
+	for (i = 0; i < QLCNIC_MAX_PCI_FUNC ; i++) {
+		if (adapter->npars[i].type != QLCNIC_TYPE_NIC)
+			continue;
+		ret = qlcnic_get_nic_info(adapter, &nic_info, i);
+		if (ret)
+			return ret;
+
+		np_cfg[i].pci_func = i;
+		np_cfg[i].op_mode = nic_info.op_mode;
+		np_cfg[i].port_num = nic_info.phys_port;
+		np_cfg[i].fw_capab = nic_info.capabilities;
+		np_cfg[i].min_bw = nic_info.min_tx_bw ;
+		np_cfg[i].max_bw = nic_info.max_tx_bw;
+		np_cfg[i].max_tx_queues = nic_info.max_tx_ques;
+		np_cfg[i].max_rx_queues = nic_info.max_rx_ques;
+	}
+	memcpy(buf, &np_cfg, size);
+	return size;
+}
+
+static ssize_t
+qlcnic_sysfs_read_pci_config(struct file *file, struct kobject *kobj,
+	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	struct qlcnic_pci_func_cfg pci_cfg[QLCNIC_MAX_PCI_FUNC];
+	struct qlcnic_pci_info	pci_info[QLCNIC_MAX_PCI_FUNC];
+	int i, ret;
+
+	if (size != sizeof(pci_cfg))
+		return QL_STATUS_INVALID_PARAM;
+
+	ret = qlcnic_get_pci_info(adapter, pci_info);
+	if (ret)
+		return ret;
+
+	for (i = 0; i < QLCNIC_MAX_PCI_FUNC ; i++) {
+		pci_cfg[i].pci_func = pci_info[i].id;
+		pci_cfg[i].func_type = pci_info[i].type;
+		pci_cfg[i].port_num = pci_info[i].default_port;
+		pci_cfg[i].min_bw = pci_info[i].tx_min_bw;
+		pci_cfg[i].max_bw = pci_info[i].tx_max_bw;
+		memcpy(&pci_cfg[i].def_mac_addr, &pci_info[i].mac, ETH_ALEN);
+	}
+	memcpy(buf, &pci_cfg, size);
+	return size;
+
+}
+static struct bin_attribute bin_attr_npar_config = {
+	.attr = {.name = "npar_config", .mode = (S_IRUGO | S_IWUSR)},
+	.size = 0,
+	.read = qlcnic_sysfs_read_npar_config,
+	.write = qlcnic_sysfs_write_npar_config,
+};
+
+static struct bin_attribute bin_attr_pci_config = {
+	.attr = {.name = "pci_config", .mode = (S_IRUGO | S_IWUSR)},
+	.size = 0,
+	.read = qlcnic_sysfs_read_pci_config,
+	.write = NULL,
+};
+
+static struct bin_attribute bin_attr_esw_config = {
+	.attr = {.name = "esw_config", .mode = (S_IRUGO | S_IWUSR)},
+	.size = 0,
+	.read = qlcnic_sysfs_read_esw_config,
+	.write = qlcnic_sysfs_write_esw_config,
+};
+
+static struct bin_attribute bin_attr_pm_config = {
+	.attr = {.name = "pm_config", .mode = (S_IRUGO | S_IWUSR)},
+	.size = 0,
+	.read = qlcnic_sysfs_read_pm_config,
+	.write = qlcnic_sysfs_write_pm_config,
+};
+
 static void
 qlcnic_create_sysfs_entries(struct qlcnic_adapter *adapter)
 {
@@ -2853,6 +3274,18 @@ qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 		dev_info(dev, "failed to create crb sysfs entry\n");
 	if (device_create_bin_file(dev, &bin_attr_mem))
 		dev_info(dev, "failed to create mem sysfs entry\n");
+	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED) ||
+			adapter->op_mode != QLCNIC_MGMT_FUNC)
+		return;
+	if (device_create_bin_file(dev, &bin_attr_pci_config))
+		dev_info(dev, "failed to create pci config sysfs entry");
+	if (device_create_bin_file(dev, &bin_attr_npar_config))
+		dev_info(dev, "failed to create npar config sysfs entry");
+	if (device_create_bin_file(dev, &bin_attr_esw_config))
+		dev_info(dev, "failed to create esw config sysfs entry");
+	if (device_create_bin_file(dev, &bin_attr_pm_config))
+		dev_info(dev, "failed to create pm config sysfs entry");
+
 }
 
 
@@ -2864,6 +3297,13 @@ qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
 	device_remove_file(dev, &dev_attr_diag_mode);
 	device_remove_bin_file(dev, &bin_attr_crb);
 	device_remove_bin_file(dev, &bin_attr_mem);
+	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED) ||
+			adapter->op_mode != QLCNIC_MGMT_FUNC)
+		return;
+	device_remove_bin_file(dev, &bin_attr_pci_config);
+	device_remove_bin_file(dev, &bin_attr_npar_config);
+	device_remove_bin_file(dev, &bin_attr_esw_config);
+	device_remove_bin_file(dev, &bin_attr_pm_config);
 }
 
 #ifdef CONFIG_INET
-- 
1.7.1

