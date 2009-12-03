From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next-2.6 2/4] be2net: Support for WoL using magic
 packet after suspend.
Date: Thu, 3 Dec 2009 21:46:59 +0530
Message-ID: <20091203161650.GA1357@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:49964 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752001AbZLCQQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 11:16:46 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for WOL using Magic Packet after suspend is done.

Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h         |    1 +
 drivers/net/benet/be_cmds.c    |   36 ++++++++++++++++++++++++++++++++
 drivers/net/benet/be_cmds.h    |   11 ++++++++++
 drivers/net/benet/be_ethtool.c |   32 +++++++++++++++++++++++++++++
 drivers/net/benet/be_hw.h      |    4 +++
 drivers/net/benet/be_main.c    |   44 ++++++++++++++++++++++++++++++++++++++++
 6 files changed, 128 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 1224748..e71cc59 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -269,6 +269,7 @@ struct be_adapter {
 	bool link_up;
 	u32 port_num;
 	bool promiscuous;
+	bool wol;
 	u32 cap;
 	u32 rx_fc;		/* Rx flow control */
 	u32 tx_fc;		/* Tx flow control */
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 5ec61de..bee7b82 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1442,3 +1442,39 @@ err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
+
+extern int be_cmd_enable_magic_wol(struct be_adapter *adapter, u8 *mac,
+				struct be_dma_mem *nonemb_cmd)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_acpi_wol_magic_config *req;
+	struct be_sge *sge;
+	int status;
+
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
+	req = nonemb_cmd->va;
+	sge = nonembedded_sgl(wrb);
+
+	be_wrb_hdr_prepare(wrb, sizeof(*req), false, 1,
+			OPCODE_ETH_ACPI_WOL_MAGIC_CONFIG);
+
+	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH,
+		OPCODE_ETH_ACPI_WOL_MAGIC_CONFIG, sizeof(*req));
+	memcpy(req->magic_mac, mac, ETH_ALEN);
+
+	sge->pa_hi = cpu_to_le32(upper_32_bits(nonemb_cmd->dma));
+	sge->pa_lo = cpu_to_le32(nonemb_cmd->dma & 0xFFFFFFFF);
+	sge->len = cpu_to_le32(nonemb_cmd->size);
+
+	status = be_mcc_notify_wait(adapter);
+
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 8ec6528..e8512a1 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -150,6 +150,7 @@ struct be_mcc_mailbox {
 #define OPCODE_ETH_RX_CREATE            		8
 #define OPCODE_ETH_TX_DESTROY           		9
 #define OPCODE_ETH_RX_DESTROY           		10
+#define OPCODE_ETH_ACPI_WOL_MAGIC_CONFIG		12
 
 struct be_cmd_req_hdr {
 	u8 opcode;		/* dword 0 */
@@ -788,6 +789,14 @@ struct be_cmd_write_flashrom {
 	struct flashrom_params params;
 };
 
+/************************ WOL *******************************/
+struct be_cmd_req_acpi_wol_magic_config{
+	struct be_cmd_req_hdr hdr;
+	u32 rsvd0[145];
+	u8 magic_mac[6];
+	u8 rsvd2[2];
+} __packed;
+
 extern int be_pci_fnum_get(struct be_adapter *adapter);
 extern int be_cmd_POST(struct be_adapter *adapter);
 extern int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
@@ -851,5 +860,7 @@ extern int be_cmd_write_flashrom(struct be_adapter *adapter,
 			struct be_dma_mem *cmd, u32 flash_oper,
 			u32 flash_opcode, u32 buf_size);
 extern int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc);
+extern int be_cmd_enable_magic_wol(struct be_adapter *adapter, u8 *mac,
+				struct be_dma_mem *nonemb_cmd);
 extern int be_cmd_fw_init(struct be_adapter *adapter);
 extern int be_cmd_fw_clean(struct be_adapter *adapter);
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 329560f..83a2fc7 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -411,6 +411,36 @@ be_phys_id(struct net_device *netdev, u32 data)
 	return status;
 }
 
+static void
+be_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+
+	wol->supported = WAKE_MAGIC;
+	if (adapter->wol)
+		wol->wolopts = WAKE_MAGIC;
+	else
+		wol->wolopts = 0;
+	memset(&wol->sopass, 0, sizeof(wol->sopass));
+	return;
+}
+
+static int
+be_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+
+	if (wol->wolopts & ~WAKE_MAGIC)
+		return -EINVAL;
+
+	if (wol->wolopts & WAKE_MAGIC)
+		adapter->wol = true;
+	else
+		adapter->wol = false;
+
+	return 0;
+}
+
 static int
 be_do_flash(struct net_device *netdev, struct ethtool_flash *efl)
 {
@@ -428,6 +458,8 @@ be_do_flash(struct net_device *netdev, struct ethtool_flash *efl)
 const struct ethtool_ops be_ethtool_ops = {
 	.get_settings = be_get_settings,
 	.get_drvinfo = be_get_drvinfo,
+	.get_wol = be_get_wol,
+	.set_wol = be_set_wol,
 	.get_link = ethtool_op_get_link,
 	.get_coalesce = be_get_coalesce,
 	.set_coalesce = be_set_coalesce,
diff --git a/drivers/net/benet/be_hw.h b/drivers/net/benet/be_hw.h
index f53d5ca..e2b3bef 100644
--- a/drivers/net/benet/be_hw.h
+++ b/drivers/net/benet/be_hw.h
@@ -52,6 +52,10 @@
  */
 #define MEMBAR_CTRL_INT_CTRL_HOSTINTR_MASK	(1 << 29) /* bit 29 */
 
+/********* Power managment (WOL) **********/
+#define PCICFG_PM_CONTROL_OFFSET		0x44
+#define PCICFG_PM_CONTROL_MASK			0x108	/* bits 3 & 8 */
+
 /********* ISR0 Register offset **********/
 #define CEV_ISR0_OFFSET 			0xC18
 #define CEV_ISR_SIZE				4
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index f24ac4b..84f686f 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1659,6 +1659,44 @@ ret_sts:
 	return status;
 }
 
+static int be_setup_wol(struct be_adapter *adapter, bool enable)
+{
+	struct be_dma_mem cmd;
+	int status = 0;
+	u8 mac[ETH_ALEN];
+
+	memset(mac, 0, ETH_ALEN);
+
+	cmd.size = sizeof(struct be_cmd_req_acpi_wol_magic_config);
+	cmd.va = pci_alloc_consistent(adapter->pdev, cmd.size, &cmd.dma);
+	if (cmd.va == NULL)
+		return -1;
+	memset(cmd.va, 0, cmd.size);
+
+	if (enable) {
+		status = pci_write_config_dword(adapter->pdev,
+			PCICFG_PM_CONTROL_OFFSET, PCICFG_PM_CONTROL_MASK);
+		if (status) {
+			dev_err(&adapter->pdev->dev,
+				"Could not enable Wake-on-lan \n");
+			pci_free_consistent(adapter->pdev, cmd.size, cmd.va,
+					cmd.dma);
+			return status;
+		}
+		status = be_cmd_enable_magic_wol(adapter,
+				adapter->netdev->dev_addr, &cmd);
+		pci_enable_wake(adapter->pdev, PCI_D3hot, 1);
+		pci_enable_wake(adapter->pdev, PCI_D3cold, 1);
+	} else {
+		status = be_cmd_enable_magic_wol(adapter, mac, &cmd);
+		pci_enable_wake(adapter->pdev, PCI_D3hot, 0);
+		pci_enable_wake(adapter->pdev, PCI_D3cold, 0);
+	}
+
+	pci_free_consistent(adapter->pdev, cmd.size, cmd.va, cmd.dma);
+	return status;
+}
+
 static int be_setup(struct be_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -2282,6 +2320,9 @@ static int be_suspend(struct pci_dev *pdev, pm_message_t state)
 	struct be_adapter *adapter = pci_get_drvdata(pdev);
 	struct net_device *netdev =  adapter->netdev;
 
+	if (adapter->wol)
+		be_setup_wol(adapter, true);
+
 	netif_device_detach(netdev);
 	if (netif_running(netdev)) {
 		rtnl_lock();
@@ -2324,6 +2365,9 @@ static int be_resume(struct pci_dev *pdev)
 		rtnl_unlock();
 	}
 	netif_device_attach(netdev);
+
+	if (adapter->wol)
+		be_setup_wol(adapter, false);
 	return 0;
 }
 
-- 
1.6.3.3

