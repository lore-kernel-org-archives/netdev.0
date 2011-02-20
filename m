From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 5/6] be2net: add code to display temperature of
 ASIC
Date: Sun, 20 Feb 2011 15:42:07 -0600
Message-ID: <20110220214207.GA13691@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:11629 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754981Ab1BTVmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 16:42:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to display temperature of ASIC via ethtool -S

From: Somnath K <somnath.kotur@emulex.com>
Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be.h         |    7 ++++++
 drivers/net/benet/be_cmds.c    |   44 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/benet/be_cmds.h    |   16 ++++++++++++++
 drivers/net/benet/be_ethtool.c |   11 ++++++++-
 4 files changed, 76 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 7bf8dd4..46b951f 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -225,6 +225,10 @@ struct be_rx_obj {
 	u32 cache_line_barrier[15];
 };
 
+struct be_drv_stats {
+	u8 be_on_die_temperature;
+};
+
 struct be_vf_cfg {
 	unsigned char vf_mac_addr[ETH_ALEN];
 	u32 vf_if_handle;
@@ -234,6 +238,7 @@ struct be_vf_cfg {
 };
 
 #define BE_INVALID_PMAC_ID		0xffffffff
+
 struct be_adapter {
 	struct pci_dev *pdev;
 	struct net_device *netdev;
@@ -269,6 +274,7 @@ struct be_adapter {
 	u32 big_page_size;	/* Compounded page size shared by rx wrbs */
 
 	u8 msix_vec_next_idx;
+	struct be_drv_stats drv_stats;
 
 	struct vlan_group *vlan_grp;
 	u16 vlans_added;
@@ -281,6 +287,7 @@ struct be_adapter {
 	struct be_dma_mem stats_cmd;
 	/* Work queue used to perform periodic tasks like getting statistics */
 	struct delayed_work work;
+	u16 work_counter;
 
 	/* Ethtool knobs and info */
 	bool rx_csum; 		/* BE card must perform rx-checksumming */
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 59d25ac..ff62aae 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -18,6 +18,9 @@
 #include "be.h"
 #include "be_cmds.h"
 
+/* Must be a power of 2 or else MODULO will BUG_ON */
+static int be_get_temp_freq = 32;
+
 static void be_mcc_notify(struct be_adapter *adapter)
 {
 	struct be_queue_info *mccq = &adapter->mcc_obj.q;
@@ -1069,6 +1072,9 @@ int be_cmd_get_stats(struct be_adapter *adapter, struct be_dma_mem *nonemb_cmd)
 	struct be_sge *sge;
 	int status = 0;
 
+	if (MODULO(adapter->work_counter, be_get_temp_freq) == 0)
+		be_cmd_get_die_temperature(adapter);
+
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
@@ -1136,6 +1142,44 @@ err:
 	return status;
 }
 
+/* Uses synchronous mcc */
+int be_cmd_get_die_temperature(struct be_adapter *adapter)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_get_cntl_addnl_attribs *req;
+	int status;
+
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
+	req = embedded_payload(wrb);
+
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+			OPCODE_COMMON_GET_CNTL_ADDITIONAL_ATTRIBUTES);
+
+	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_GET_CNTL_ADDITIONAL_ATTRIBUTES, sizeof(*req));
+
+	status = be_mcc_notify_wait(adapter);
+	if (!status) {
+		struct be_cmd_resp_get_cntl_addnl_attribs *resp =
+						embedded_payload(wrb);
+		adapter->drv_stats.be_on_die_temperature =
+						resp->on_die_temperature;
+	}
+	/* If IOCTL fails once, do not bother issuing it again */
+	else
+		be_get_temp_freq = 0;
+
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
+
 /* Uses Mbox */
 int be_cmd_get_fw_ver(struct be_adapter *adapter, char *fw_ver)
 {
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index a5af296..6e89de8 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -189,6 +189,7 @@ struct be_mcc_mailbox {
 #define OPCODE_COMMON_GET_BEACON_STATE			70
 #define OPCODE_COMMON_READ_TRANSRECV_DATA		73
 #define OPCODE_COMMON_GET_PHY_DETAILS			102
+#define OPCODE_COMMON_GET_CNTL_ADDITIONAL_ATTRIBUTES	121
 
 #define OPCODE_ETH_RSS_CONFIG				1
 #define OPCODE_ETH_ACPI_CONFIG				2
@@ -668,6 +669,20 @@ struct be_cmd_resp_get_stats {
 	struct be_hw_stats hw_stats;
 };
 
+struct be_cmd_req_get_cntl_addnl_attribs {
+	struct be_cmd_req_hdr hdr;
+	u8 rsvd[8];
+};
+
+struct be_cmd_resp_get_cntl_addnl_attribs {
+	struct be_cmd_resp_hdr hdr;
+	u16 ipl_file_number;
+	u8 ipl_file_version;
+	u8 rsvd0;
+	u8 on_die_temperature; /* in degrees centigrade*/
+	u8 rsvd1[3];
+};
+
 struct be_cmd_req_vlan_config {
 	struct be_cmd_req_hdr hdr;
 	u8 interface_id;
@@ -1099,4 +1114,5 @@ extern int be_cmd_get_phy_info(struct be_adapter *adapter,
 		struct be_dma_mem *cmd);
 extern int be_cmd_set_qos(struct be_adapter *adapter, u32 bps, u32 domain);
 extern void be_detect_dump_ue(struct be_adapter *adapter);
+extern int be_cmd_get_die_temperature(struct be_adapter *adapter);
 
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 0833cbd..4766693 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -27,7 +27,7 @@ struct be_ethtool_stat {
 };
 
 enum {NETSTAT, PORTSTAT, MISCSTAT, DRVSTAT_TX, DRVSTAT_RX, ERXSTAT,
-			PMEMSTAT};
+			PMEMSTAT, DRVSTAT};
 #define FIELDINFO(_struct, field) FIELD_SIZEOF(_struct, field), \
 					offsetof(_struct, field)
 #define NETSTAT_INFO(field) 	#field, NETSTAT,\
@@ -46,6 +46,9 @@ enum {NETSTAT, PORTSTAT, MISCSTAT, DRVSTAT_TX, DRVSTAT_RX, ERXSTAT,
 					FIELDINFO(struct be_erx_stats, field)
 #define PMEMSTAT_INFO(field) 	#field, PMEMSTAT,\
 					FIELDINFO(struct be_pmem_stats, field)
+#define	DRVSTAT_INFO(field)	#field, DRVSTAT,\
+					FIELDINFO(struct be_drv_stats, \
+						field)
 
 static const struct be_ethtool_stat et_stats[] = {
 	{NETSTAT_INFO(rx_packets)},
@@ -105,7 +108,8 @@ static const struct be_ethtool_stat et_stats[] = {
 	{MISCSTAT_INFO(rx_drops_mtu)},
 	{MISCSTAT_INFO(port0_jabber_events)},
 	{MISCSTAT_INFO(port1_jabber_events)},
-	{PMEMSTAT_INFO(eth_red_drops)}
+	{PMEMSTAT_INFO(eth_red_drops)},
+	{DRVSTAT_INFO(be_on_die_temperature)}
 };
 #define ETHTOOL_STATS_NUM ARRAY_SIZE(et_stats)
 
@@ -285,6 +289,9 @@ be_get_ethtool_stats(struct net_device *netdev,
 		case PMEMSTAT:
 			p = &hw_stats->pmem;
 			break;
+		case DRVSTAT:
+			p = &adapter->drv_stats;
+			break;
 		}
 
 		p = (u8 *)p + et_stats[i].offset;
-- 
1.7.1

