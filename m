From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: [net-2.6 PATCH 2/3] be2net: Bug fix to config NIC appropriately
 before loopback test
Date: Wed, 23 Dec 2009 20:11:44 +0530
Message-ID: <20091223144134.GA23401@serverengines.com>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:11466 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756036AbZLWOli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 09:41:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NIC controller has to be set to an appropriate mode before doing a loopback 
test. Test will fail otherwise.

Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
---
 drivers/net/benet/be_cmds.c    |   35 +++++++++++++++++++++++++++++++++++
 drivers/net/benet/be_cmds.h    |   16 ++++++++++++++++
 drivers/net/benet/be_ethtool.c |   37 +++++++++++++++++++++++--------------
 3 files changed, 74 insertions(+), 14 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index a27fdb3..102ade1 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1479,6 +1479,41 @@ err:
 	return status;
 }
 
+int be_cmd_set_loopback(struct be_adapter *adapter, u8 port_num,
+			u8 loopback_type, u8 enable)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_set_lmode *req;
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
+				OPCODE_LOWLEVEL_SET_LOOPBACK_MODE);
+
+	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_LOWLEVEL,
+			OPCODE_LOWLEVEL_SET_LOOPBACK_MODE,
+			sizeof(*req));
+
+	req->src_port = port_num;
+	req->dest_port = port_num;
+	req->loopback_type = loopback_type;
+	req->loopback_state = enable;
+
+	status = be_mcc_notify_wait(adapter);
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
+
 int be_cmd_loopback_test(struct be_adapter *adapter, u32 port_num,
 		u32 loopback_type, u32 pkt_size, u32 num_pkts, u64 pattern)
 {
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 92b87ef..c002b83 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -155,6 +155,7 @@ #define OPCODE_ETH_ACPI_WOL_MAGIC_CONFIG
 
 #define OPCODE_LOWLEVEL_HOST_DDR_DMA                    17
 #define OPCODE_LOWLEVEL_LOOPBACK_TEST                   18
+#define OPCODE_LOWLEVEL_SET_LOOPBACK_MODE		19
 
 struct be_cmd_req_hdr {
 	u8 opcode;		/* dword 0 */
@@ -821,6 +822,19 @@ struct be_cmd_resp_loopback_test {
 	u32    ticks_compl;
 };
 
+struct be_cmd_req_set_lmode {
+	struct be_cmd_req_hdr hdr;
+	u8 src_port;
+	u8 dest_port;
+	u8 loopback_type;
+	u8 loopback_state;
+};
+
+struct be_cmd_resp_set_lmode {
+	struct be_cmd_resp_hdr resp_hdr;
+	u8 rsvd0[4];
+};
+
 /********************** DDR DMA test *********************/
 struct be_cmd_req_ddrdma_test {
 	struct be_cmd_req_hdr hdr;
@@ -912,3 +926,5 @@ extern int be_cmd_loopback_test(struct b
 				u32 num_pkts, u64 pattern);
 extern int be_cmd_ddr_dma_test(struct be_adapter *adapter, u64 pattern,
 			u32 byte_cnt, struct be_dma_mem *cmd);
+extern int be_cmd_set_loopback(struct be_adapter *adapter, u8 port_num,
+				u8 loopback_type, u8 enable);
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 298b92c..da66d15 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -118,6 +118,7 @@ #define ETHTOOL_TESTS_NUM ARRAY_SIZE(et_
 #define BE_MAC_LOOPBACK 0x0
 #define BE_PHY_LOOPBACK 0x1
 #define BE_ONE_PORT_EXT_LOOPBACK 0x2
+#define BE_NO_LOOPBACK 0xff
 
 static void
 be_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
@@ -489,6 +490,19 @@ err:
 	return ret;
 }
 
+static u64 be_loopback_test(struct be_adapter *adapter, u8 loopback_type,
+				u64 *status)
+{
+	be_cmd_set_loopback(adapter, adapter->port_num,
+				loopback_type, 1);
+	*status = be_cmd_loopback_test(adapter, adapter->port_num,
+				loopback_type, 1500,
+				2, 0xabc);
+	be_cmd_set_loopback(adapter, adapter->port_num,
+				BE_NO_LOOPBACK, 1);
+	return *status;
+}
+
 static void
 be_self_test(struct net_device *netdev, struct ethtool_test *test, u64 *data)
 {
@@ -497,23 +511,18 @@ be_self_test(struct net_device *netdev, 
 	memset(data, 0, sizeof(u64) * ETHTOOL_TESTS_NUM);
 
 	if (test->flags & ETH_TEST_FL_OFFLINE) {
-		data[0] = be_cmd_loopback_test(adapter, adapter->port_num,
-						BE_MAC_LOOPBACK, 1500,
-						2, 0xabc);
-		if (data[0] != 0)
+		if (be_loopback_test(adapter, BE_MAC_LOOPBACK,
+						&data[0]) != 0) {
 			test->flags |= ETH_TEST_FL_FAILED;
-
-		data[1] = be_cmd_loopback_test(adapter, adapter->port_num,
-						BE_PHY_LOOPBACK, 1500,
-						2, 0xabc);
-		if (data[1] != 0)
+		}
+		if (be_loopback_test(adapter, BE_PHY_LOOPBACK,
+						&data[1]) != 0) {
 			test->flags |= ETH_TEST_FL_FAILED;
-
-		data[2] = be_cmd_loopback_test(adapter, adapter->port_num,
-						BE_ONE_PORT_EXT_LOOPBACK,
-						1500, 2, 0xabc);
-		if (data[2] != 0)
+		}
+		if (be_loopback_test(adapter, BE_ONE_PORT_EXT_LOOPBACK,
+						&data[2]) != 0) {
 			test->flags |= ETH_TEST_FL_FAILED;
+		}
 
 		data[3] = be_test_ddr_dma(adapter);
 		if (data[3] != 0)
-- 
1.4.0

