From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: [net-next-2.6 PATCH] be2net: implements ethtool function to read
 eeprom data.
Date: Wed, 6 Jan 2010 21:40:07 +0530
Message-ID: <20100106160957.GA19519@serverengines.com>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:63828 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755068Ab0AFQJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 11:09:44 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch implements a firmware command to fetch the eeprom data.

Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
---
 drivers/net/benet/be_cmds.c    |   30 +++++++++++++++++++++++++++
 drivers/net/benet/be_cmds.h    |   16 ++++++++++++++
 drivers/net/benet/be_ethtool.c |   45 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 91 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 1b68bd9..b748c19 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1571,3 +1571,33 @@ err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
+
+extern int be_cmd_get_seeprom_data(struct be_adapter *adapter,
+				struct be_dma_mem *nonemb_cmd)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_seeprom_read *req;
+	struct be_sge *sge;
+	int status;
+
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	req = nonemb_cmd->va;
+	sge = nonembedded_sgl(wrb);
+
+	be_wrb_hdr_prepare(wrb, sizeof(*req), false, 1,
+			OPCODE_COMMON_SEEPROM_READ);
+
+	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			OPCODE_COMMON_SEEPROM_READ, sizeof(*req));
+
+	sge->pa_hi = cpu_to_le32(upper_32_bits(nonemb_cmd->dma));
+	sge->pa_lo = cpu_to_le32(nonemb_cmd->dma & 0xFFFFFFFF);
+	sge->len = cpu_to_le32(nonemb_cmd->size);
+
+	status = be_mcc_notify_wait(adapter);
+
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 92b87ef..6eed512 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -124,6 +124,7 @@ #define OPCODE_COMMON_WRITE_FLASHROM			7
 #define OPCODE_COMMON_CQ_CREATE				12
 #define OPCODE_COMMON_EQ_CREATE				13
 #define OPCODE_COMMON_MCC_CREATE        		21
+#define OPCODE_COMMON_SEEPROM_READ			30
 #define OPCODE_COMMON_NTWK_RX_FILTER    		34
 #define OPCODE_COMMON_GET_FW_VERSION			35
 #define OPCODE_COMMON_SET_FLOW_CONTROL			36
@@ -840,6 +841,19 @@ struct be_cmd_resp_ddrdma_test {
 	u8  rcv_buff[4096];
 };
 
+/*********************** SEEPROM Read ***********************/
+
+#define BE_READ_SEEPROM_LEN 1024
+struct be_cmd_req_seeprom_read {
+	struct be_cmd_req_hdr hdr;
+	u8 rsvd0[BE_READ_SEEPROM_LEN];
+};
+
+struct be_cmd_resp_seeprom_read {
+	struct be_cmd_req_hdr hdr;
+	u8 seeprom_data[BE_READ_SEEPROM_LEN];
+};
+
 extern int be_pci_fnum_get(struct be_adapter *adapter);
 extern int be_cmd_POST(struct be_adapter *adapter);
 extern int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
@@ -912,3 +926,5 @@ extern int be_cmd_loopback_test(struct b
 				u32 num_pkts, u64 pattern);
 extern int be_cmd_ddr_dma_test(struct be_adapter *adapter, u64 pattern,
 			u32 byte_cnt, struct be_dma_mem *cmd);
+extern int be_cmd_get_seeprom_data(struct be_adapter *adapter,
+				struct be_dma_mem *nonemb_cmd);
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 298b92c..c5afc02 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -536,12 +536,57 @@ be_do_flash(struct net_device *netdev, s
 	return be_load_fw(adapter, file_name);
 }
 
+static int
+be_get_eeprom_len(struct net_device *netdev)
+{
+	return BE_READ_SEEPROM_LEN;
+}
+
+static int
+be_read_eeprom(struct net_device *netdev, struct ethtool_eeprom *eeprom,
+			uint8_t *data)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	struct be_dma_mem eeprom_cmd;
+	struct be_cmd_resp_seeprom_read *resp;
+	int status;
+
+	if (!eeprom->len)
+		return -EINVAL;
+
+	eeprom->magic = BE_VENDOR_ID | (adapter->pdev->device<<16);
+
+	memset(&eeprom_cmd, 0, sizeof(struct be_dma_mem));
+	eeprom_cmd.size = sizeof(struct be_cmd_req_seeprom_read);
+	eeprom_cmd.va = pci_alloc_consistent(adapter->pdev, eeprom_cmd.size,
+				&eeprom_cmd.dma);
+
+	if (!eeprom_cmd.va) {
+		dev_err(&adapter->pdev->dev,
+			"Memory allocation failure. Could not read eeprom\n");
+		return -ENOMEM;
+	}
+
+	status = be_cmd_get_seeprom_data(adapter, &eeprom_cmd);
+
+	if (!status) {
+		resp = (struct be_cmd_resp_seeprom_read *) eeprom_cmd.va;
+		memcpy(data, resp->seeprom_data, eeprom->len);
+	}
+	pci_free_consistent(adapter->pdev, eeprom_cmd.size, eeprom_cmd.va,
+			eeprom_cmd.dma);
+
+	return status;
+}
+
 const struct ethtool_ops be_ethtool_ops = {
 	.get_settings = be_get_settings,
 	.get_drvinfo = be_get_drvinfo,
 	.get_wol = be_get_wol,
 	.set_wol = be_set_wol,
 	.get_link = ethtool_op_get_link,
+	.get_eeprom_len = be_get_eeprom_len,
+	.get_eeprom = be_read_eeprom,
 	.get_coalesce = be_get_coalesce,
 	.set_coalesce = be_set_coalesce,
 	.get_ringparam = be_get_ringparam,
-- 
1.4.0

