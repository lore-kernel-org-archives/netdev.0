From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next-2.6 3/4] be2net: Add support for ethtool self test
Date: Thu, 3 Dec 2009 21:48:14 +0530
Message-ID: <20091203161804.GA1382@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:50023 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753806AbZLCQSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 11:18:01 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for ethtool selftest.

From: Suresh R <sureshr@serverengines.com>
Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_cmds.c    |   93 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/benet/be_cmds.h    |   48 ++++++++++++++++++++
 drivers/net/benet/be_ethtool.c |   87 +++++++++++++++++++++++++++++++++++++
 3 files changed, 228 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index bee7b82..1b68bd9 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1478,3 +1478,96 @@ err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
+
+int be_cmd_loopback_test(struct be_adapter *adapter, u32 port_num,
+		u32 loopback_type, u32 pkt_size, u32 num_pkts, u64 pattern)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_loopback_test *req;
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
+				OPCODE_LOWLEVEL_LOOPBACK_TEST);
+
+	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_LOWLEVEL,
+			OPCODE_LOWLEVEL_LOOPBACK_TEST, sizeof(*req));
+
+	req->pattern = cpu_to_le64(pattern);
+	req->src_port = cpu_to_le32(port_num);
+	req->dest_port = cpu_to_le32(port_num);
+	req->pkt_size = cpu_to_le32(pkt_size);
+	req->num_pkts = cpu_to_le32(num_pkts);
+	req->loopback_type = cpu_to_le32(loopback_type);
+
+	status = be_mcc_notify_wait(adapter);
+	if (!status) {
+		struct be_cmd_resp_loopback_test *resp = embedded_payload(wrb);
+		status = le32_to_cpu(resp->status);
+	}
+
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
+
+int be_cmd_ddr_dma_test(struct be_adapter *adapter, u64 pattern,
+				u32 byte_cnt, struct be_dma_mem *cmd)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_ddrdma_test *req;
+	struct be_sge *sge;
+	int status;
+	int i, j = 0;
+
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
+	req = cmd->va;
+	sge = nonembedded_sgl(wrb);
+	be_wrb_hdr_prepare(wrb, cmd->size, false, 1,
+				OPCODE_LOWLEVEL_HOST_DDR_DMA);
+	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_LOWLEVEL,
+			OPCODE_LOWLEVEL_HOST_DDR_DMA, cmd->size);
+
+	sge->pa_hi = cpu_to_le32(upper_32_bits(cmd->dma));
+	sge->pa_lo = cpu_to_le32(cmd->dma & 0xFFFFFFFF);
+	sge->len = cpu_to_le32(cmd->size);
+
+	req->pattern = cpu_to_le64(pattern);
+	req->byte_count = cpu_to_le32(byte_cnt);
+	for (i = 0; i < byte_cnt; i++) {
+		req->snd_buff[i] = (u8)(pattern >> (j*8));
+		j++;
+		if (j > 7)
+			j = 0;
+	}
+
+	status = be_mcc_notify_wait(adapter);
+
+	if (!status) {
+		struct be_cmd_resp_ddrdma_test *resp;
+		resp = cmd->va;
+		if ((memcmp(resp->rcv_buff, req->snd_buff, byte_cnt) != 0) ||
+				resp->snd_err) {
+			status = -1;
+		}
+	}
+
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index e8512a1..e7323be 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -112,6 +112,7 @@ struct be_mcc_mailbox {
 
 #define CMD_SUBSYSTEM_COMMON	0x1
 #define CMD_SUBSYSTEM_ETH 	0x3
+#define CMD_SUBSYSTEM_LOWLEVEL  0xb
 
 #define OPCODE_COMMON_NTWK_MAC_QUERY			1
 #define OPCODE_COMMON_NTWK_MAC_SET			2
@@ -152,6 +153,9 @@ struct be_mcc_mailbox {
 #define OPCODE_ETH_RX_DESTROY           		10
 #define OPCODE_ETH_ACPI_WOL_MAGIC_CONFIG		12
 
+#define OPCODE_LOWLEVEL_HOST_DDR_DMA                    17
+#define OPCODE_LOWLEVEL_LOOPBACK_TEST                   18
+
 struct be_cmd_req_hdr {
 	u8 opcode;		/* dword 0 */
 	u8 subsystem;		/* dword 0 */
@@ -797,6 +801,45 @@ struct be_cmd_req_acpi_wol_magic_config{
 	u8 rsvd2[2];
 } __packed;
 
+/********************** LoopBack test *********************/
+struct be_cmd_req_loopback_test {
+	struct be_cmd_req_hdr hdr;
+	u32 loopback_type;
+	u32 num_pkts;
+	u64 pattern;
+	u32 src_port;
+	u32 dest_port;
+	u32 pkt_size;
+};
+
+struct be_cmd_resp_loopback_test {
+	struct be_cmd_resp_hdr resp_hdr;
+	u32    status;
+	u32    num_txfer;
+	u32    num_rx;
+	u32    miscomp_off;
+	u32    ticks_compl;
+};
+
+/********************** DDR DMA test *********************/
+struct be_cmd_req_ddrdma_test {
+	struct be_cmd_req_hdr hdr;
+	u64 pattern;
+	u32 byte_count;
+	u32 rsvd0;
+	u8  snd_buff[4096];
+	u8  rsvd1[4096];
+};
+
+struct be_cmd_resp_ddrdma_test {
+	struct be_cmd_resp_hdr hdr;
+	u64 pattern;
+	u32 byte_cnt;
+	u32 snd_err;
+	u8  rsvd0[4096];
+	u8  rcv_buff[4096];
+};
+
 extern int be_pci_fnum_get(struct be_adapter *adapter);
 extern int be_cmd_POST(struct be_adapter *adapter);
 extern int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
@@ -864,3 +907,8 @@ extern int be_cmd_enable_magic_wol(struct be_adapter *adapter, u8 *mac,
 				struct be_dma_mem *nonemb_cmd);
 extern int be_cmd_fw_init(struct be_adapter *adapter);
 extern int be_cmd_fw_clean(struct be_adapter *adapter);
+extern int be_cmd_loopback_test(struct be_adapter *adapter, u32 port_num,
+				u32 loopback_type, u32 pkt_size,
+				u32 num_pkts, u64 pattern);
+extern int be_cmd_ddr_dma_test(struct be_adapter *adapter, u64 pattern,
+			u32 byte_cnt, struct be_dma_mem *cmd);
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 83a2fc7..7bfd0b3 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -107,6 +107,18 @@ static const struct be_ethtool_stat et_stats[] = {
 };
 #define ETHTOOL_STATS_NUM ARRAY_SIZE(et_stats)
 
+static const char et_self_tests[][ETH_GSTRING_LEN] = {
+	"MAC Loopback test",
+	"PHY Loopback test",
+	"External Loopback test",
+	"DDR DMA test"
+};
+
+#define BE_NUM_TESTS ARRAY_SIZE(et_self_tests)
+#define BE_MAC_LOOPBACK 0x0
+#define BE_PHY_LOOPBACK 0x1
+#define BE_ONE_PORT_EXT_LOOPBACK 0x2
+
 static void
 be_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
 {
@@ -278,6 +290,12 @@ be_get_stat_strings(struct net_device *netdev, uint32_t stringset,
 			data += ETH_GSTRING_LEN;
 		}
 		break;
+	case ETH_SS_TEST:
+		for (i = 0; i < BE_NUM_TESTS; i++) {
+			memcpy(data, et_self_tests[i], ETH_GSTRING_LEN);
+			data += ETH_GSTRING_LEN;
+		}
+		break;
 	}
 }
 
@@ -442,6 +460,73 @@ be_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 }
 
 static int
+be_test_ddr_dma(struct be_adapter *adapter)
+{
+	int ret, i;
+	struct be_dma_mem ddrdma_cmd;
+	u64 pattern[2] = {0x5a5a5a5a5a5a5a5a, 0xa5a5a5a5a5a5a5a5};
+
+	ddrdma_cmd.size = sizeof(struct be_cmd_req_ddrdma_test);
+	ddrdma_cmd.va = pci_alloc_consistent(adapter->pdev, ddrdma_cmd.size,
+					&ddrdma_cmd.dma);
+	if (!ddrdma_cmd.va) {
+		dev_err(&adapter->pdev->dev, "Memory allocation failure \n");
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < 2; i++) {
+		ret = be_cmd_ddr_dma_test(adapter, pattern[i],
+					4096, &ddrdma_cmd);
+		if (ret != 0)
+			goto err;
+	}
+
+err:
+	pci_free_consistent(adapter->pdev, ddrdma_cmd.size,
+			ddrdma_cmd.va, ddrdma_cmd.dma);
+	return ret;
+}
+
+static int
+be_self_test_count(struct net_device *dev)
+{
+	return BE_NUM_TESTS;
+}
+
+static void
+be_self_test(struct net_device *netdev, struct ethtool_test *test, u64 *data)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+
+	memset(data, 0, sizeof(u64) * BE_NUM_TESTS);
+
+	if (test->flags & ETH_TEST_FL_OFFLINE) {
+		data[0] = be_cmd_loopback_test(adapter, adapter->port_num,
+						BE_MAC_LOOPBACK, 1500,
+						2, 0xabc);
+		if (data[0] != 0)
+			test->flags |= ETH_TEST_FL_FAILED;
+
+		data[1] = be_cmd_loopback_test(adapter, adapter->port_num,
+						BE_PHY_LOOPBACK, 1500,
+						2, 0xabc);
+		if (data[1] != 0)
+			test->flags |= ETH_TEST_FL_FAILED;
+
+		data[2] = be_cmd_loopback_test(adapter, adapter->port_num,
+						BE_ONE_PORT_EXT_LOOPBACK,
+						1500, 2, 0xabc);
+		if (data[2] != 0)
+			test->flags |= ETH_TEST_FL_FAILED;
+
+		data[3] = be_test_ddr_dma(adapter);
+		if (data[3] != 0)
+			test->flags |= ETH_TEST_FL_FAILED;
+	}
+
+}
+
+static int
 be_do_flash(struct net_device *netdev, struct ethtool_flash *efl)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
@@ -479,4 +564,6 @@ const struct ethtool_ops be_ethtool_ops = {
 	.get_sset_count = be_get_sset_count,
 	.get_ethtool_stats = be_get_ethtool_stats,
 	.flash_device = be_do_flash,
+	.self_test = be_self_test,
+	.self_test_count = be_self_test_count
 };
-- 
1.6.3.3

