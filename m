From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: [net-next PATCH] be2net: Adding PCI SRIOV support
Date: Wed, 31 Mar 2010 18:26:12 +0530
Message-ID: <20100331125601.GA9725@serverengines.com>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:63255 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S932101Ab0CaM4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 08:56:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Patch adds support to enable PCI SRIOV in the driver and changes to handle initialization of PCI virtual functions.
- Function handler to change mac addresses for VF from its corresponding PF.

Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
---
 drivers/net/benet/be.h      |    9 ++
 drivers/net/benet/be_cmds.c |    4 +
 drivers/net/benet/be_cmds.h |    2 
 drivers/net/benet/be_hw.h   |    3 +
 drivers/net/benet/be_main.c |  222 ++++++++++++++++++++++++++++++++++---------
 5 files changed, 191 insertions(+), 49 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 8f07525..20842c5 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -83,6 +83,8 @@ #define RX_FRAGS_REFILL_WM	(RX_Q_LEN - M
 
 #define FW_VER_LEN		32
 
+#define BE_MAX_VF		32
+
 struct be_dma_mem {
 	void *va;
 	dma_addr_t dma;
@@ -280,8 +282,15 @@ struct be_adapter {
 	u8 port_type;
 	u8 transceiver;
 	u8 generation;		/* BladeEngine ASIC generation */
+
+	bool sriov_enabled;
+	u32 vf_if_handle[BE_MAX_VF];
+	u32 vf_pmac_id[BE_MAX_VF];
+	u8 base_eq_id;
 };
 
+#define be_physfn(adapter) (!adapter->pdev->is_virtfn)
+
 /* BladeEngine Generation numbers */
 #define BE_GEN2 2
 #define BE_GEN3 3
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 50e6259..9f53d9e 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -843,7 +843,8 @@ int be_cmd_q_destroy(struct be_adapter *
  * Uses mbox
  */
 int be_cmd_if_create(struct be_adapter *adapter, u32 cap_flags, u32 en_flags,
-		u8 *mac, bool pmac_invalid, u32 *if_handle, u32 *pmac_id)
+		u8 *mac, bool pmac_invalid, u32 *if_handle, u32 *pmac_id,
+		u32 domain)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_if_create *req;
@@ -860,6 +861,7 @@ int be_cmd_if_create(struct be_adapter *
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_NTWK_INTERFACE_CREATE, sizeof(*req));
 
+	req->hdr.domain = domain;
 	req->capability_flags = cpu_to_le32(cap_flags);
 	req->enable_flags = cpu_to_le32(en_flags);
 	req->pmac_invalid = pmac_invalid;
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index cce61f9..763dc19 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -878,7 +878,7 @@ extern int be_cmd_pmac_add(struct be_ada
 extern int be_cmd_pmac_del(struct be_adapter *adapter, u32 if_id, u32 pmac_id);
 extern int be_cmd_if_create(struct be_adapter *adapter, u32 cap_flags,
 			u32 en_flags, u8 *mac, bool pmac_invalid,
-			u32 *if_handle, u32 *pmac_id);
+			u32 *if_handle, u32 *pmac_id, u32 domain);
 extern int be_cmd_if_destroy(struct be_adapter *adapter, u32 if_handle);
 extern int be_cmd_eq_create(struct be_adapter *adapter,
 			struct be_queue_info *eq, int eq_delay);
diff --git a/drivers/net/benet/be_hw.h b/drivers/net/benet/be_hw.h
index 2d4a4b8..063026d 100644
--- a/drivers/net/benet/be_hw.h
+++ b/drivers/net/benet/be_hw.h
@@ -99,6 +99,9 @@ #define DB_MCCQ_RING_ID_MASK		0x7FF	/* b
 /* Number of entries posted */
 #define DB_MCCQ_NUM_POSTED_SHIFT	(16)	/* bits 16 - 29 */
 
+/********** SRIOV VF PCICFG OFFSET ********/
+#define SRIOV_VF_PCICFG_OFFSET		(4096)
+
 /* Flashrom related descriptors */
 #define IMAGE_TYPE_FIRMWARE		160
 #define IMAGE_TYPE_BOOTCODE		224
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 50ea056..881c87d 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -26,8 +26,11 @@ MODULE_AUTHOR("ServerEngines Corporation
 MODULE_LICENSE("GPL");
 
 static unsigned int rx_frag_size = 2048;
+static unsigned int num_vfs;
 module_param(rx_frag_size, uint, S_IRUGO);
+module_param(num_vfs, uint, S_IRUGO);
 MODULE_PARM_DESC(rx_frag_size, "Size of a fragment that holds rcvd data.");
+MODULE_PARM_DESC(num_vfs, "Number of PCI VFs to initialize");
 
 static DEFINE_PCI_DEVICE_TABLE(be_dev_ids) = {
 	{ PCI_DEVICE(BE_VENDOR_ID, BE_DEVICE_ID1) },
@@ -138,12 +141,19 @@ static int be_mac_addr_set(struct net_de
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
+	/* MAC addr configuration will be done in hardware for VFs
+	 * by their corresponding PFs. Just copy to netdev addr here
+	 */
+	if (!be_physfn(adapter))
+		goto netdev_addr;
+
 	status = be_cmd_pmac_del(adapter, adapter->if_handle, adapter->pmac_id);
 	if (status)
 		return status;
 
 	status = be_cmd_pmac_add(adapter, (u8 *)addr->sa_data,
 			adapter->if_handle, &adapter->pmac_id);
+netdev_addr:
 	if (!status)
 		memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 
@@ -576,6 +586,9 @@ static void be_vlan_add_vid(struct net_d
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 
+	if (!be_physfn(adapter))
+		return;
+
 	adapter->vlan_tag[vid] = 1;
 	adapter->vlans_added++;
 	if (adapter->vlans_added <= (adapter->max_vlans + 1))
@@ -586,6 +599,9 @@ static void be_vlan_rem_vid(struct net_d
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 
+	if (!be_physfn(adapter))
+		return;
+
 	adapter->vlan_tag[vid] = 0;
 	vlan_group_set_device(adapter->vlan_grp, vid, NULL);
 	adapter->vlans_added--;
@@ -623,6 +639,28 @@ done:
 	return;
 }
 
+static int be_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	int status;
+
+	if (!adapter->sriov_enabled)
+		return -EPERM;
+
+	if (!is_valid_ether_addr(mac) || (vf >= num_vfs))
+		return -EINVAL;
+
+	status = be_cmd_pmac_del(adapter, adapter->vf_if_handle[vf],
+				adapter->vf_pmac_id[vf]);
+
+	status = be_cmd_pmac_add(adapter, mac, adapter->vf_if_handle[vf],
+				&adapter->vf_pmac_id[vf]);
+	if (!status)
+		dev_err(&adapter->pdev->dev, "MAC %pM set on VF %d Failed\n",
+				mac, vf);
+	return status;
+}
+
 static void be_rx_rate_update(struct be_adapter *adapter)
 {
 	struct be_drvr_stats *stats = drvr_stats(adapter);
@@ -1281,6 +1319,8 @@ static int be_tx_queues_create(struct be
 	/* Ask BE to create Tx Event queue */
 	if (be_cmd_eq_create(adapter, eq, adapter->tx_eq.cur_eqd))
 		goto tx_eq_free;
+	adapter->base_eq_id = adapter->tx_eq.q.id;
+
 	/* Alloc TX eth compl queue */
 	cq = &adapter->tx_obj.cq;
 	if (be_queue_alloc(adapter, cq, TX_CQ_LEN,
@@ -1408,7 +1448,7 @@ rx_eq_free:
 /* There are 8 evt ids per func. Retruns the evt id's bit number */
 static inline int be_evt_bit_get(struct be_adapter *adapter, u32 eq_id)
 {
-	return eq_id % 8;
+	return eq_id - adapter->base_eq_id;
 }
 
 static irqreturn_t be_intx(int irq, void *dev)
@@ -1586,6 +1626,28 @@ static void be_msix_enable(struct be_ada
 	return;
 }
 
+static void be_sriov_enable(struct be_adapter *adapter)
+{
+#ifdef CONFIG_PCI_IOV
+	int status;
+	if (be_physfn(adapter) && num_vfs) {
+		status = pci_enable_sriov(adapter->pdev, num_vfs);
+		adapter->sriov_enabled = status ? false : true;
+	}
+#endif
+	return;
+}
+
+static void be_sriov_disable(struct be_adapter *adapter)
+{
+#ifdef CONFIG_PCI_IOV
+	if (adapter->sriov_enabled) {
+		pci_disable_sriov(adapter->pdev);
+		adapter->sriov_enabled = false;
+	}
+#endif
+}
+
 static inline int be_msix_vec_get(struct be_adapter *adapter, u32 eq_id)
 {
 	return adapter->msix_entries[
@@ -1643,6 +1705,9 @@ static int be_irq_register(struct be_ada
 		status = be_msix_register(adapter);
 		if (status == 0)
 			goto done;
+		/* INTx is not supported for VF */
+		if (!be_physfn(adapter))
+			return status;
 	}
 
 	/* INTx */
@@ -1716,14 +1781,17 @@ static int be_open(struct net_device *ne
 		goto ret_sts;
 	be_link_status_update(adapter, link_up);
 
-	status = be_vid_config(adapter);
+	if (be_physfn(adapter))
+		status = be_vid_config(adapter);
 	if (status)
 		goto ret_sts;
 
-	status = be_cmd_set_flow_control(adapter,
-					adapter->tx_fc, adapter->rx_fc);
-	if (status)
-		goto ret_sts;
+	if (be_physfn(adapter)) {
+		status = be_cmd_set_flow_control(adapter,
+				adapter->tx_fc, adapter->rx_fc);
+		if (status)
+			goto ret_sts;
+	}
 
 	schedule_delayed_work(&adapter->work, msecs_to_jiffies(100));
 ret_sts:
@@ -1771,22 +1839,48 @@ static int be_setup_wol(struct be_adapte
 static int be_setup(struct be_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	u32 cap_flags, en_flags;
+	u32 cap_flags, en_flags, vf = 0;
 	int status;
+	u8 mac[ETH_ALEN];
+
+	cap_flags = en_flags = BE_IF_FLAGS_UNTAGGED | BE_IF_FLAGS_BROADCAST;
 
-	cap_flags = BE_IF_FLAGS_UNTAGGED | BE_IF_FLAGS_BROADCAST |
-			BE_IF_FLAGS_MCAST_PROMISCUOUS |
-			BE_IF_FLAGS_PROMISCUOUS |
-			BE_IF_FLAGS_PASS_L3L4_ERRORS;
-	en_flags = BE_IF_FLAGS_UNTAGGED | BE_IF_FLAGS_BROADCAST |
-			BE_IF_FLAGS_PASS_L3L4_ERRORS;
+	if (be_physfn(adapter)) {
+		cap_flags |= BE_IF_FLAGS_MCAST_PROMISCUOUS |
+				BE_IF_FLAGS_PROMISCUOUS |
+				BE_IF_FLAGS_PASS_L3L4_ERRORS;
+		en_flags |= BE_IF_FLAGS_PASS_L3L4_ERRORS;
+	}
 
 	status = be_cmd_if_create(adapter, cap_flags, en_flags,
 			netdev->dev_addr, false/* pmac_invalid */,
-			&adapter->if_handle, &adapter->pmac_id);
+			&adapter->if_handle, &adapter->pmac_id, 0);
 	if (status != 0)
 		goto do_none;
 
+	if (be_physfn(adapter)) {
+		while (vf < num_vfs) {
+			cap_flags = en_flags = BE_IF_FLAGS_UNTAGGED
+					| BE_IF_FLAGS_BROADCAST;
+			status = be_cmd_if_create(adapter, cap_flags, en_flags,
+					mac, true, &adapter->vf_if_handle[vf],
+					NULL, vf+1);
+			if (status) {
+				dev_err(&adapter->pdev->dev,
+				"Interface Create failed for VF %d\n", vf);
+				goto if_destroy;
+			}
+			vf++;
+		} while (vf < num_vfs);
+	} else if (!be_physfn(adapter)) {
+		status = be_cmd_mac_addr_query(adapter, mac,
+			MAC_ADDRESS_TYPE_NETWORK, false, adapter->if_handle);
+		if (!status) {
+			memcpy(adapter->netdev->dev_addr, mac, ETH_ALEN);
+			memcpy(adapter->netdev->perm_addr, mac, ETH_ALEN);
+		}
+	}
+
 	status = be_tx_queues_create(adapter);
 	if (status != 0)
 		goto if_destroy;
@@ -1808,6 +1902,9 @@ rx_qs_destroy:
 tx_qs_destroy:
 	be_tx_queues_destroy(adapter);
 if_destroy:
+	for (vf = 0; vf < num_vfs; vf++)
+		if (adapter->vf_if_handle[vf])
+			be_cmd_if_destroy(adapter, adapter->vf_if_handle[vf]);
 	be_cmd_if_destroy(adapter, adapter->if_handle);
 do_none:
 	return status;
@@ -2088,6 +2185,7 @@ static struct net_device_ops be_netdev_o
 	.ndo_vlan_rx_register	= be_vlan_register,
 	.ndo_vlan_rx_add_vid	= be_vlan_add_vid,
 	.ndo_vlan_rx_kill_vid	= be_vlan_rem_vid,
+	.ndo_set_vf_mac		= be_set_vf_mac
 };
 
 static void be_netdev_init(struct net_device *netdev)
@@ -2129,37 +2227,48 @@ static void be_unmap_pci_bars(struct be_
 		iounmap(adapter->csr);
 	if (adapter->db)
 		iounmap(adapter->db);
-	if (adapter->pcicfg)
+	if (adapter->pcicfg && be_physfn(adapter))
 		iounmap(adapter->pcicfg);
 }
 
 static int be_map_pci_bars(struct be_adapter *adapter)
 {
 	u8 __iomem *addr;
-	int pcicfg_reg;
+	int pcicfg_reg, db_reg;
 
-	addr = ioremap_nocache(pci_resource_start(adapter->pdev, 2),
-			pci_resource_len(adapter->pdev, 2));
-	if (addr == NULL)
-		return -ENOMEM;
-	adapter->csr = addr;
-
-	addr = ioremap_nocache(pci_resource_start(adapter->pdev, 4),
-			128 * 1024);
-	if (addr == NULL)
-		goto pci_map_err;
-	adapter->db = addr;
+	if (be_physfn(adapter)) {
+		addr = ioremap_nocache(pci_resource_start(adapter->pdev, 2),
+				pci_resource_len(adapter->pdev, 2));
+		if (addr == NULL)
+			return -ENOMEM;
+		adapter->csr = addr;
+	}
 
-	if (adapter->generation == BE_GEN2)
+	if (adapter->generation == BE_GEN2) {
 		pcicfg_reg = 1;
-	else
+		db_reg = 4;
+	} else {
 		pcicfg_reg = 0;
-
-	addr = ioremap_nocache(pci_resource_start(adapter->pdev, pcicfg_reg),
-			pci_resource_len(adapter->pdev, pcicfg_reg));
+		if (be_physfn(adapter))
+			db_reg = 4;
+		else
+			db_reg = 0;
+	}
+	addr = ioremap_nocache(pci_resource_start(adapter->pdev, db_reg),
+				pci_resource_len(adapter->pdev, db_reg));
 	if (addr == NULL)
 		goto pci_map_err;
-	adapter->pcicfg = addr;
+	adapter->db = addr;
+
+	if (be_physfn(adapter)) {
+		addr = ioremap_nocache(
+				pci_resource_start(adapter->pdev, pcicfg_reg),
+				pci_resource_len(adapter->pdev, pcicfg_reg));
+		if (addr == NULL)
+			goto pci_map_err;
+		adapter->pcicfg = addr;
+	} else
+		adapter->pcicfg = adapter->db + SRIOV_VF_PCICFG_OFFSET;
 
 	return 0;
 pci_map_err:
@@ -2273,6 +2382,8 @@ static void __devexit be_remove(struct p
 
 	be_ctrl_cleanup(adapter);
 
+	be_sriov_disable(adapter);
+
 	be_msix_disable(adapter);
 
 	pci_set_drvdata(pdev, NULL);
@@ -2297,16 +2408,20 @@ static int be_get_config(struct be_adapt
 		return status;
 
 	memset(mac, 0, ETH_ALEN);
-	status = be_cmd_mac_addr_query(adapter, mac,
+
+	if (be_physfn(adapter)) {
+		status = be_cmd_mac_addr_query(adapter, mac,
 			MAC_ADDRESS_TYPE_NETWORK, true /*permanent */, 0);
-	if (status)
-		return status;
 
-	if (!is_valid_ether_addr(mac))
-		return -EADDRNOTAVAIL;
+		if (status)
+			return status;
 
-	memcpy(adapter->netdev->dev_addr, mac, ETH_ALEN);
-	memcpy(adapter->netdev->perm_addr, mac, ETH_ALEN);
+		if (!is_valid_ether_addr(mac))
+			return -EADDRNOTAVAIL;
+
+		memcpy(adapter->netdev->dev_addr, mac, ETH_ALEN);
+		memcpy(adapter->netdev->perm_addr, mac, ETH_ALEN);
+	}
 
 	if (adapter->cap & 0x400)
 		adapter->max_vlans = BE_NUM_VLANS_SUPPORTED/4;
@@ -2323,6 +2438,7 @@ static int __devinit be_probe(struct pci
 	struct be_adapter *adapter;
 	struct net_device *netdev;
 
+
 	status = pci_enable_device(pdev);
 	if (status)
 		goto do_none;
@@ -2371,24 +2487,28 @@ static int __devinit be_probe(struct pci
 		}
 	}
 
+	be_sriov_enable(adapter);
+
 	status = be_ctrl_init(adapter);
 	if (status)
 		goto free_netdev;
 
 	/* sync up with fw's ready state */
-	status = be_cmd_POST(adapter);
-	if (status)
-		goto ctrl_clean;
+	if (be_physfn(adapter)) {
+		status = be_cmd_POST(adapter);
+		if (status)
+			goto ctrl_clean;
+
+		status = be_cmd_reset_function(adapter);
+		if (status)
+			goto ctrl_clean;
+	}
 
 	/* tell fw we're ready to fire cmds */
 	status = be_cmd_fw_init(adapter);
 	if (status)
 		goto ctrl_clean;
 
-	status = be_cmd_reset_function(adapter);
-	if (status)
-		goto ctrl_clean;
-
 	status = be_stats_init(adapter);
 	if (status)
 		goto ctrl_clean;
@@ -2418,6 +2538,7 @@ ctrl_clean:
 	be_ctrl_cleanup(adapter);
 free_netdev:
 	be_msix_disable(adapter);
+	be_sriov_disable(adapter);
 	free_netdev(adapter->netdev);
 	pci_set_drvdata(pdev, NULL);
 rel_reg:
@@ -2614,6 +2735,13 @@ static int __init be_init_module(void)
 		rx_frag_size = 2048;
 	}
 
+	if (num_vfs > 32) {
+		printk(KERN_WARNING DRV_NAME
+			" : Module param num_vfs must not be greater than 32."
+			"Using 32\n");
+		num_vfs = 32;
+	}
+
 	return pci_register_driver(&be_driver);
 }
 module_init(be_init_module);
-- 
1.4.0

