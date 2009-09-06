From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 1/6] netxen: handle firmware load errors
Date: Sat,  5 Sep 2009 20:43:07 -0700
Message-ID: <1252208592-2240-2-git-send-email-dhananjay@netxen.com>
References: <1252208592-2240-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-1.pathscale.com ([198.186.3.73]:25067 "HELO unm84.unmin.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1754019AbZIFDnM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Sep 2009 23:43:12 -0400
In-Reply-To: <1252208592-2240-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unwind allocations and release file firmware when
when firmware load fails.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_hw.c   |    3 +++
 drivers/net/netxen/netxen_nic_init.c |    1 +
 drivers/net/netxen/netxen_nic_main.c |   20 ++++++++++++++++----
 3 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index db510ce..d0ac8fa 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -566,6 +566,9 @@ netxen_send_cmd_descs(struct netxen_adapter *adapter,
 
 	i = 0;
 
+	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
+		return -EIO;
+
 	tx_ring = adapter->tx_ring;
 	__netif_tx_lock_bh(tx_ring->txq);
 
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 04e36f2..534994d 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -905,6 +905,7 @@ netxen_release_firmware(struct netxen_adapter *adapter)
 {
 	if (adapter->fw)
 		release_firmware(adapter->fw);
+	adapter->fw = NULL;
 }
 
 int netxen_init_dummy_dma(struct netxen_adapter *adapter)
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 41b2967..47aede6 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -757,7 +757,7 @@ netxen_start_firmware(struct netxen_adapter *adapter, int request_fw)
 
 	err = netxen_need_fw_reset(adapter);
 	if (err < 0)
-		return err;
+		goto err_out;
 	if (err == 0)
 		goto wait_init;
 
@@ -771,7 +771,9 @@ netxen_start_firmware(struct netxen_adapter *adapter, int request_fw)
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
 		netxen_set_port_mode(adapter);
 
-	netxen_load_firmware(adapter);
+	err = netxen_load_firmware(adapter);
+	if (err)
+		goto err_out;
 
 	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
 
@@ -785,7 +787,7 @@ netxen_start_firmware(struct netxen_adapter *adapter, int request_fw)
 
 	err = netxen_init_dummy_dma(adapter);
 	if (err)
-		return err;
+		goto err_out;
 
 	/*
 	 * Tell the hardware our version number.
@@ -800,7 +802,7 @@ wait_init:
 	err = netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
 	if (err) {
 		netxen_free_dummy_dma(adapter);
-		return err;
+		goto err_out;
 	}
 
 	nx_update_dma_mask(adapter);
@@ -808,6 +810,10 @@ wait_init:
 	netxen_nic_get_firmware_info(adapter);
 
 	return 0;
+
+err_out:
+	netxen_release_firmware(adapter);
+	return err;
 }
 
 static int
@@ -876,6 +882,9 @@ netxen_nic_up(struct netxen_adapter *adapter, struct net_device *netdev)
 {
 	int err;
 
+	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
+		return -EIO;
+
 	err = adapter->init_port(adapter, adapter->physical_port);
 	if (err) {
 		printk(KERN_ERR "%s: Failed to initialize port %d\n",
@@ -914,6 +923,9 @@ netxen_nic_up(struct netxen_adapter *adapter, struct net_device *netdev)
 static void
 netxen_nic_down(struct netxen_adapter *adapter, struct net_device *netdev)
 {
+	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
+		return;
+
 	spin_lock(&adapter->tx_clean_lock);
 	netif_carrier_off(netdev);
 	netif_tx_disable(netdev);
-- 
1.6.0.2

