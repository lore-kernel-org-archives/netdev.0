From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next 4/7] be2net: code to support tx rate configuration
 on virtual functions
Date: Fri, 23 Jul 2010 17:22:13 +0530
Message-ID: <20100723115201.GA24975@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:25041 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758012Ab0GWLv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 07:51:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h      |    1 +
 drivers/net/benet/be_cmds.c |   34 ++++++++++++++++++++++++++++++++++
 drivers/net/benet/be_cmds.h |   18 ++++++++++++++++++
 drivers/net/benet/be_main.c |   27 ++++++++++++++++++++++++++-
 4 files changed, 79 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index f693b9e..8cfe3c4 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -225,6 +225,7 @@ struct be_vf_cfg {
 	u32 vf_if_handle;
 	u32 vf_pmac_id;
 	u16 vf_vlan_tag;
+	u32 vf_tx_rate;
 };
 
 #define BE_NUM_MSIX_VECTORS		2	/* 1 each for Tx and Rx */
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 344e062..32ae324 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1730,3 +1730,37 @@ err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
+
+int be_cmd_set_qos(struct be_adapter *adapter, u32 bps, u32 domain)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_set_qos *req;
+	int status;
+
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
+
+	req = embedded_payload(wrb);
+
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+				OPCODE_COMMON_SET_QOS);
+
+	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			OPCODE_COMMON_SET_QOS, sizeof(*req));
+
+	req->hdr.domain = domain;
+	req->valid_bits = BE_QOS_BITS_NIC;
+	req->max_bps_nic = bps;
+
+	status = be_mcc_notify_wait(adapter);
+
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
+
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 912a058..3b69e71 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -124,6 +124,7 @@ struct be_mcc_mailbox {
 #define OPCODE_COMMON_CQ_CREATE				12
 #define OPCODE_COMMON_EQ_CREATE				13
 #define OPCODE_COMMON_MCC_CREATE        		21
+#define OPCODE_COMMON_SET_QOS				28
 #define OPCODE_COMMON_SEEPROM_READ			30
 #define OPCODE_COMMON_NTWK_RX_FILTER    		34
 #define OPCODE_COMMON_GET_FW_VERSION			35
@@ -894,6 +895,22 @@ struct be_cmd_resp_get_phy_info {
 	u32 future_use[4];
 };
 
+/*********************** Set QOS ***********************/
+
+#define BE_QOS_BITS_NIC				1
+
+struct be_cmd_req_set_qos {
+	struct be_cmd_req_hdr hdr;
+	u32 valid_bits;
+	u32 max_bps_nic;
+	u32 rsvd[7];
+};
+
+struct be_cmd_resp_set_qos {
+	struct be_cmd_resp_hdr hdr;
+	u32 rsvd;
+};
+
 extern int be_pci_fnum_get(struct be_adapter *adapter);
 extern int be_cmd_POST(struct be_adapter *adapter);
 extern int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
@@ -974,4 +991,5 @@ extern int be_cmd_set_loopback(struct be_adapter *adapter, u8 port_num,
 				u8 loopback_type, u8 enable);
 extern int be_cmd_get_phy_info(struct be_adapter *adapter,
 		struct be_dma_mem *cmd);
+extern int be_cmd_set_qos(struct be_adapter *adapter, u32 bps, u32 domain);
 
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 46f087e..79adcdd 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -695,7 +695,7 @@ static int be_get_vf_config(struct net_device *netdev, int vf,
 		return -EINVAL;
 
 	vi->vf = vf;
-	vi->tx_rate = 0;
+	vi->tx_rate = adapter->vf_cfg[vf].vf_tx_rate;
 	vi->vlan = adapter->vf_cfg[vf].vf_vlan_tag;
 	vi->qos = 0;
 	memcpy(&vi->mac, adapter->vf_cfg[vf].vf_mac_addr, ETH_ALEN);
@@ -731,6 +731,30 @@ static int be_set_vf_vlan(struct net_device *netdev,
 	return status;
 }
 
+static int be_set_vf_tx_rate(struct net_device *netdev,
+			int vf, int rate)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	int status = 0;
+
+	if (!adapter->sriov_enabled)
+		return -EPERM;
+
+	if ((vf >= num_vfs) || (rate < 0))
+		return -EINVAL;
+
+	if (rate > 10000)
+		rate = 10000;
+
+	adapter->vf_cfg[vf].vf_tx_rate = rate;
+	status = be_cmd_set_qos(adapter, rate / 10, vf);
+
+	if (status)
+		dev_info(&adapter->pdev->dev,
+				"tx rate %d on VF %d failed\n", rate, vf);
+	return status;
+}
+
 static void be_rx_rate_update(struct be_adapter *adapter)
 {
 	struct be_drvr_stats *stats = drvr_stats(adapter);
@@ -2256,6 +2280,7 @@ static struct net_device_ops be_netdev_ops = {
 	.ndo_vlan_rx_kill_vid	= be_vlan_rem_vid,
 	.ndo_set_vf_mac		= be_set_vf_mac,
 	.ndo_set_vf_vlan	= be_set_vf_vlan,
+	.ndo_set_vf_tx_rate	= be_set_vf_tx_rate,
 	.ndo_get_vf_config	= be_get_vf_config
 };
 
-- 
1.7.0.4

