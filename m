From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 7/7] be2net: Enable RSS UDP hashing for Lancer and Skyhawk
Date: Thu, 12 Jul 2012 19:27:47 +0530
Message-ID: <58046138-832a-49a2-84a8-fa682a74162e@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:49180 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161027Ab2GLOB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 10:01:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    3 +++
 drivers/net/ethernet/emulex/benet/be_cmds.c |    7 +++++++
 drivers/net/ethernet/emulex/benet/be_cmds.h |    2 ++
 3 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index e2dfe31..330d59a 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -457,6 +457,9 @@ struct be_adapter {
 #define lancer_chip(adapter)	((adapter->pdev->device == OC_DEVICE_ID3) || \
 				 (adapter->pdev->device == OC_DEVICE_ID4))
 
+#define skyhawk_chip(adapter)	(adapter->pdev->device == OC_DEVICE_ID5)
+
+
 #define be_roce_supported(adapter) ((adapter->if_type == SLI_INTF_TYPE_3 || \
 				adapter->sli_family == SKYHAWK_SLI_FAMILY) && \
 				(adapter->function_mode & RDMA_ENABLED))
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 8730f0e..ddfca65 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1792,6 +1792,13 @@ int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable, u16 table_size)
 	req->if_id = cpu_to_le32(adapter->if_handle);
 	req->enable_rss = cpu_to_le16(RSS_ENABLE_TCP_IPV4 | RSS_ENABLE_IPV4 |
 				      RSS_ENABLE_TCP_IPV6 | RSS_ENABLE_IPV6);
+
+	if (lancer_chip(adapter) || skyhawk_chip(adapter)) {
+		req->hdr.version = 1;
+		req->enable_rss |= cpu_to_le16(RSS_ENABLE_UDP_IPV4 |
+					       RSS_ENABLE_UDP_IPV6);
+	}
+
 	req->cpu_table_size_log2 = cpu_to_le16(fls(table_size) - 1);
 	memcpy(req->cpu_table, rsstable, table_size);
 	memcpy(req->hash, myhash, sizeof(myhash));
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 88f7237..45d70de 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1089,6 +1089,8 @@ struct be_cmd_resp_query_fw_cfg {
 #define RSS_ENABLE_TCP_IPV4			0x2
 #define RSS_ENABLE_IPV6				0x4
 #define RSS_ENABLE_TCP_IPV6			0x8
+#define RSS_ENABLE_UDP_IPV4			0x10
+#define RSS_ENABLE_UDP_IPV6			0x20
 
 struct be_cmd_req_rss_config {
 	struct be_cmd_req_hdr hdr;
-- 
1.6.0.2
