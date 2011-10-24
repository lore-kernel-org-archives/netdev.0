From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 1/4] be2net: add vlan/rx-mode/flow-control config to be_setup()
Date: Mon, 24 Oct 2011 18:15:00 +0530
Message-ID: <1319460303-25560-2-git-send-email-sathya.perla@emulex.com>
References: <1319460303-25560-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:57529 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932249Ab1JXMpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 08:45:25 -0400
In-Reply-To: <1319460303-25560-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a card is reset due to EEH error recovery or due to a suspend, rx-mode config (promisc/mc) is not being sent to the FW. be_setup() is called in these flows and is the best place for such config/re-config cmds. Hence include rx-mode, vlan and flow-control config in be_setup().

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |  121 ++++++++++++--------------
 1 files changed, 56 insertions(+), 65 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 706fc59..88c9dca 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -796,7 +796,7 @@ static void be_vlan_rem_vid(struct net_device *netdev, u16 vid)
 		be_vid_config(adapter, false, 0);
 }
 
-static void be_set_multicast_list(struct net_device *netdev)
+static void be_set_rx_mode(struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 
@@ -2352,17 +2352,6 @@ static int be_open(struct net_device *netdev)
 	/* Now that interrupts are on we can process async mcc */
 	be_async_mcc_enable(adapter);
 
-	if (be_physfn(adapter)) {
-		status = be_vid_config(adapter, false, 0);
-		if (status)
-			goto err;
-
-		status = be_cmd_set_flow_control(adapter,
-				adapter->tx_fc, adapter->rx_fc);
-		if (status)
-			goto err;
-	}
-
 	return 0;
 err:
 	be_close(adapter->netdev);
@@ -2450,10 +2439,40 @@ static inline void be_vf_eth_addr_rem(struct be_adapter *adapter)
 	}
 }
 
+static int be_clear(struct be_adapter *adapter)
+{
+	int vf;
+
+	if (be_physfn(adapter) && adapter->sriov_enabled)
+		be_vf_eth_addr_rem(adapter);
+
+	be_mcc_queues_destroy(adapter);
+	be_rx_queues_destroy(adapter);
+	be_tx_queues_destroy(adapter);
+	adapter->eq_next_idx = 0;
+
+	if (be_physfn(adapter) && adapter->sriov_enabled)
+		for (vf = 0; vf < num_vfs; vf++)
+			if (adapter->vf_cfg[vf].vf_if_handle)
+				be_cmd_if_destroy(adapter,
+					adapter->vf_cfg[vf].vf_if_handle,
+					vf + 1);
+
+	be_cmd_if_destroy(adapter, adapter->if_handle,  0);
+
+	adapter->be3_native = false;
+	adapter->promiscuous = false;
+
+	/* tell fw we're done with firing cmds */
+	be_cmd_fw_clean(adapter);
+	return 0;
+}
+
 static int be_setup(struct be_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	u32 cap_flags, en_flags, vf = 0;
+	u32 tx_fc, rx_fc;
 	int status;
 	u8 mac[ETH_ALEN];
 
@@ -2479,7 +2498,7 @@ static int be_setup(struct be_adapter *adapter)
 			netdev->dev_addr, false/* pmac_invalid */,
 			&adapter->if_handle, &adapter->pmac_id, 0);
 	if (status != 0)
-		goto do_none;
+		goto err;
 
 	if (be_physfn(adapter)) {
 		if (adapter->sriov_enabled) {
@@ -2494,7 +2513,7 @@ static int be_setup(struct be_adapter *adapter)
 					dev_err(&adapter->pdev->dev,
 					"Interface Create failed for VF %d\n",
 					vf);
-					goto if_destroy;
+					goto err;
 				}
 				adapter->vf_cfg[vf].vf_pmac_id =
 							BE_INVALID_PMAC_ID;
@@ -2512,71 +2531,47 @@ static int be_setup(struct be_adapter *adapter)
 
 	status = be_tx_queues_create(adapter);
 	if (status != 0)
-		goto if_destroy;
+		goto err;
 
 	status = be_rx_queues_create(adapter);
 	if (status != 0)
-		goto tx_qs_destroy;
+		goto err;
 
 	/* Allow all priorities by default. A GRP5 evt may modify this */
 	adapter->vlan_prio_bmap = 0xff;
 
 	status = be_mcc_queues_create(adapter);
 	if (status != 0)
-		goto rx_qs_destroy;
+		goto err;
 
 	adapter->link_speed = -1;
 
 	be_cmd_get_fw_ver(adapter, adapter->fw_ver, NULL);
 
+	status = be_vid_config(adapter, false, 0);
+	if (status)
+		goto err;
+
+	be_set_rx_mode(adapter->netdev);
+
+	status = be_cmd_get_flow_control(adapter, &tx_fc, &rx_fc);
+	if (status)
+		goto err;
+	if (rx_fc != adapter->rx_fc || tx_fc != adapter->tx_fc) {
+		status = be_cmd_set_flow_control(adapter, adapter->tx_fc,
+					adapter->rx_fc);
+		if (status)
+			goto err;
+	}	
+
 	pcie_set_readrq(adapter->pdev, 4096);
 	return 0;
 
-rx_qs_destroy:
-	be_rx_queues_destroy(adapter);
-tx_qs_destroy:
-	be_tx_queues_destroy(adapter);
-if_destroy:
-	if (be_physfn(adapter) && adapter->sriov_enabled)
-		for (vf = 0; vf < num_vfs; vf++)
-			if (adapter->vf_cfg[vf].vf_if_handle)
-				be_cmd_if_destroy(adapter,
-					adapter->vf_cfg[vf].vf_if_handle,
-					vf + 1);
-	be_cmd_if_destroy(adapter, adapter->if_handle, 0);
-do_none:
+err:
+	be_clear(adapter);
 	return status;
 }
 
-static int be_clear(struct be_adapter *adapter)
-{
-	int vf;
-
-	if (be_physfn(adapter) && adapter->sriov_enabled)
-		be_vf_eth_addr_rem(adapter);
-
-	be_mcc_queues_destroy(adapter);
-	be_rx_queues_destroy(adapter);
-	be_tx_queues_destroy(adapter);
-	adapter->eq_next_idx = 0;
-
-	if (be_physfn(adapter) && adapter->sriov_enabled)
-		for (vf = 0; vf < num_vfs; vf++)
-			if (adapter->vf_cfg[vf].vf_if_handle)
-				be_cmd_if_destroy(adapter,
-					adapter->vf_cfg[vf].vf_if_handle,
-					vf + 1);
-
-	be_cmd_if_destroy(adapter, adapter->if_handle,  0);
-
-	adapter->be3_native = 0;
-
-	/* tell fw we're done with firing cmds */
-	be_cmd_fw_clean(adapter);
-	return 0;
-}
-
-
 #define FW_FILE_HDR_SIGN 	"ServerEngines Corp. "
 static bool be_flash_redboot(struct be_adapter *adapter,
 			const u8 *p, u32 img_start, int image_size,
@@ -2915,7 +2910,7 @@ static struct net_device_ops be_netdev_ops = {
 	.ndo_open		= be_open,
 	.ndo_stop		= be_close,
 	.ndo_start_xmit		= be_xmit,
-	.ndo_set_rx_mode	= be_set_multicast_list,
+	.ndo_set_rx_mode	= be_set_rx_mode,
 	.ndo_set_mac_address	= be_mac_addr_set,
 	.ndo_change_mtu		= be_change_mtu,
 	.ndo_get_stats64	= be_get_stats64,
@@ -2948,10 +2943,6 @@ static void be_netdev_init(struct net_device *netdev)
 
 	netdev->flags |= IFF_MULTICAST;
 
-	/* Default settings for Rx and Tx flow control */
-	adapter->rx_fc = true;
-	adapter->tx_fc = true;
-
 	netif_set_gso_max_size(netdev, 65535);
 
 	BE_SET_NETDEV_OPS(netdev, &be_netdev_ops);
@@ -3373,6 +3364,7 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	be_msix_enable(adapter);
 
 	INIT_DELAYED_WORK(&adapter->work, be_worker);
+	adapter->rx_fc = adapter->tx_fc = true;
 
 	status = be_setup(adapter);
 	if (status)
@@ -3448,7 +3440,6 @@ static int be_suspend(struct pci_dev *pdev, pm_message_t state)
 		be_close(netdev);
 		rtnl_unlock();
 	}
-	be_cmd_get_flow_control(adapter, &adapter->tx_fc, &adapter->rx_fc);
 	be_clear(adapter);
 
 	be_msix_disable(adapter);
-- 
1.7.4
