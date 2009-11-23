From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next-2.6 PATCH 3/5] be2net: Issue fw_init/clean cmds to fw
Date: Mon, 23 Nov 2009 13:32:03 +0530
Message-ID: <20091123080203.GA7778@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:44436 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752896AbZKWICG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 03:02:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These cmds are issued to the fw in probe/resume and remove/suspend
paths to help fw execute some initialization and cleanup code.

This change needed the be_hw_up() code to be refactored as be_get_config().

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_cmds.c |   51 +++++++++++++++++++++++++++++++++++++++++++
 drivers/net/benet/be_cmds.h |    2 +
 drivers/net/benet/be_main.c |   50 ++++++++++++++++++++++++++++-------------
 3 files changed, 87 insertions(+), 16 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 31980f8..2af87f1 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -357,6 +357,57 @@ static struct be_mcc_wrb *wrb_from_mccq(struct be_adapter *adapter)
 	return wrb;
 }
 
+/* Tell fw we're about to start firing cmds by writing a
+ * special pattern across the wrb hdr; uses mbox
+ */
+int be_cmd_fw_init(struct be_adapter *adapter)
+{
+	u8 *wrb;
+	int status;
+
+	spin_lock(&adapter->mbox_lock);
+
+	wrb = (u8 *)wrb_from_mbox(adapter);
+	*wrb++ = 0xFF;
+	*wrb++ = 0x12;
+	*wrb++ = 0x34;
+	*wrb++ = 0xFF;
+	*wrb++ = 0xFF;
+	*wrb++ = 0x56;
+	*wrb++ = 0x78;
+	*wrb = 0xFF;
+
+	status = be_mbox_notify_wait(adapter);
+
+	spin_unlock(&adapter->mbox_lock);
+	return status;
+}
+
+/* Tell fw we're done with firing cmds by writing a
+ * special pattern across the wrb hdr; uses mbox
+ */
+int be_cmd_fw_clean(struct be_adapter *adapter)
+{
+	u8 *wrb;
+	int status;
+
+	spin_lock(&adapter->mbox_lock);
+
+	wrb = (u8 *)wrb_from_mbox(adapter);
+	*wrb++ = 0xFF;
+	*wrb++ = 0xAA;
+	*wrb++ = 0xBB;
+	*wrb++ = 0xFF;
+	*wrb++ = 0xFF;
+	*wrb++ = 0xCC;
+	*wrb++ = 0xDD;
+	*wrb = 0xFF;
+
+	status = be_mbox_notify_wait(adapter);
+
+	spin_unlock(&adapter->mbox_lock);
+	return status;
+}
 int be_cmd_eq_create(struct be_adapter *adapter,
 		struct be_queue_info *eq, int eq_delay)
 {
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 3b31abc..8ec6528 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -851,3 +851,5 @@ extern int be_cmd_write_flashrom(struct be_adapter *adapter,
 			struct be_dma_mem *cmd, u32 flash_oper,
 			u32 flash_opcode, u32 buf_size);
 extern int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc);
+extern int be_cmd_fw_init(struct be_adapter *adapter);
+extern int be_cmd_fw_clean(struct be_adapter *adapter);
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index d309f67..9d894c8 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1682,6 +1682,8 @@ static int be_clear(struct be_adapter *adapter)
 
 	be_cmd_if_destroy(adapter, adapter->if_handle);
 
+	/* tell fw we're done with firing cmds */
+	be_cmd_fw_clean(adapter);
 	return 0;
 }
 
@@ -2117,25 +2119,28 @@ static void __devexit be_remove(struct pci_dev *pdev)
 	free_netdev(adapter->netdev);
 }
 
-static int be_hw_up(struct be_adapter *adapter)
+static int be_get_config(struct be_adapter *adapter)
 {
 	int status;
+	u8 mac[ETH_ALEN];
 
-	status = be_cmd_POST(adapter);
+	status = be_cmd_get_fw_ver(adapter, adapter->fw_ver);
 	if (status)
 		return status;
 
-	status = be_cmd_reset_function(adapter);
+	status = be_cmd_query_fw_cfg(adapter,
+				&adapter->port_num, &adapter->cap);
 	if (status)
 		return status;
 
-	status = be_cmd_get_fw_ver(adapter, adapter->fw_ver);
+	memset(mac, 0, ETH_ALEN);
+	status = be_cmd_mac_addr_query(adapter, mac,
+			MAC_ADDRESS_TYPE_NETWORK, true /*permanent */, 0);
 	if (status)
 		return status;
+	memcpy(adapter->netdev->dev_addr, mac, ETH_ALEN);
 
-	status = be_cmd_query_fw_cfg(adapter,
-				&adapter->port_num, &adapter->cap);
-	return status;
+	return 0;
 }
 
 static int __devinit be_probe(struct pci_dev *pdev,
@@ -2144,7 +2149,6 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	int status = 0;
 	struct be_adapter *adapter;
 	struct net_device *netdev;
-	u8 mac[ETH_ALEN];
 
 	status = pci_enable_device(pdev);
 	if (status)
@@ -2164,6 +2168,8 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	adapter->pdev = pdev;
 	pci_set_drvdata(pdev, adapter);
 	adapter->netdev = netdev;
+	be_netdev_init(netdev);
+	SET_NETDEV_DEV(netdev, &pdev->dev);
 
 	be_msix_enable(adapter);
 
@@ -2182,27 +2188,34 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	if (status)
 		goto free_netdev;
 
-	status = be_stats_init(adapter);
+	/* sync up with fw's ready state */
+	status = be_cmd_POST(adapter);
 	if (status)
 		goto ctrl_clean;
 
-	status = be_hw_up(adapter);
+	/* tell fw we're ready to fire cmds */
+	status = be_cmd_fw_init(adapter);
 	if (status)
-		goto stats_clean;
+		goto ctrl_clean;
+
+	status = be_cmd_reset_function(adapter);
+	if (status)
+		goto ctrl_clean;
 
-	status = be_cmd_mac_addr_query(adapter, mac, MAC_ADDRESS_TYPE_NETWORK,
-			true /* permanent */, 0);
+	status = be_stats_init(adapter);
+	if (status)
+		goto ctrl_clean;
+
+	status = be_get_config(adapter);
 	if (status)
 		goto stats_clean;
-	memcpy(netdev->dev_addr, mac, ETH_ALEN);
 
 	INIT_DELAYED_WORK(&adapter->work, be_worker);
-	be_netdev_init(netdev);
-	SET_NETDEV_DEV(netdev, &adapter->pdev->dev);
 
 	status = be_setup(adapter);
 	if (status)
 		goto stats_clean;
+
 	status = register_netdev(netdev);
 	if (status != 0)
 		goto unsetup;
@@ -2262,6 +2275,11 @@ static int be_resume(struct pci_dev *pdev)
 	pci_set_power_state(pdev, 0);
 	pci_restore_state(pdev);
 
+	/* tell fw we're ready to fire cmds */
+	status = be_cmd_fw_init(adapter);
+	if (status)
+		return status;
+
 	be_setup(adapter);
 	if (netif_running(netdev)) {
 		rtnl_lock();
-- 
1.6.5.2

