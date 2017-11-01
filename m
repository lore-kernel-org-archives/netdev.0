From: Desnes Augusto Nunes do Rosario <desnesn@linux.vnet.ibm.com>
Subject: [PATCH FEAT] ibmvnic: Feature implementation of Vital Product Data (VPD) for the ibmvnic driver
Date: Wed,  1 Nov 2017 12:39:59 -0200
Message-ID: <20171101143959.14992-1-desnesn@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, tlfalcon@linux.vnet.ibm.com,
        nfont@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:53334 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932796AbdKAOmj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 10:42:39 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vA1EfKsh102185
        for <netdev@vger.kernel.org>; Wed, 1 Nov 2017 10:42:38 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dye04r3bu-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 10:42:37 -0400
Received: from localhost
        by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <desnesn@linux.vnet.ibm.com>;
        Wed, 1 Nov 2017 08:42:36 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements and enables VDP support for the ibmvnic driver. Moreover, it includes the implementation of suitable structs, signal transmission/handling and fuctions which allows the retrival of firmware information from the ibmvnic card.

Co-Authored-By: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 140 ++++++++++++++++++++++++++++++++++++-
 drivers/net/ethernet/ibm/ibmvnic.h |  27 ++++++-
 2 files changed, 164 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index d0cff28..120f3c0 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -107,6 +107,9 @@ static union sub_crq *ibmvnic_next_scrq(struct ibmvnic_adapter *,
 					struct ibmvnic_sub_crq_queue *);
 static int ibmvnic_poll(struct napi_struct *napi, int data);
 static void send_map_query(struct ibmvnic_adapter *adapter);
+static int ibmvnic_get_vpd(struct ibmvnic_adapter *);
+static void handle_vpd_size_rsp(union ibmvnic_crq *, struct ibmvnic_adapter *);
+static void handle_vpd_rsp(union ibmvnic_crq *,struct ibmvnic_adapter *);
 static void send_request_map(struct ibmvnic_adapter *, dma_addr_t, __be32, u8);
 static void send_request_unmap(struct ibmvnic_adapter *, u8);
 static void send_login(struct ibmvnic_adapter *adapter);
@@ -573,6 +576,15 @@ static int reset_tx_pools(struct ibmvnic_adapter *adapter)
 	return 0;
 }
 
+static void release_vpd_data(struct ibmvnic_adapter *adapter)
+{
+	if(!adapter->vpd)
+		return;
+
+	kfree(adapter->vpd->buff);
+	kfree(adapter->vpd);
+}
+
 static void release_tx_pools(struct ibmvnic_adapter *adapter)
 {
 	struct ibmvnic_tx_pool *tx_pool;
@@ -753,6 +765,8 @@ static void release_resources(struct ibmvnic_adapter *adapter)
 {
 	int i;
 
+	release_vpd_data(adapter);
+
 	release_tx_pools(adapter);
 	release_rx_pools(adapter);
 
@@ -850,6 +864,10 @@ static int init_resources(struct ibmvnic_adapter *adapter)
 	if (rc)
 		return rc;
 
+	adapter->vpd = kzalloc(sizeof(struct ibmvnic_vpd), GFP_KERNEL);
+	if (!adapter->vpd)
+		return -ENOMEM;
+
 	adapter->map_id = 1;
 	adapter->napi = kcalloc(adapter->req_rx_queues,
 				sizeof(struct napi_struct), GFP_KERNEL);
@@ -950,6 +968,10 @@ static int ibmvnic_open(struct net_device *netdev)
 
 	rc = __ibmvnic_open(netdev);
 	netif_carrier_on(netdev);
+
+	/* Vital Product Data (VPD) */
+	ibmvnic_get_vpd(adapter);
+
 	mutex_unlock(&adapter->reset_lock);
 
 	return rc;
@@ -1878,11 +1900,15 @@ static int ibmvnic_get_link_ksettings(struct net_device *netdev,
 	return 0;
 }
 
-static void ibmvnic_get_drvinfo(struct net_device *dev,
+static void ibmvnic_get_drvinfo(struct net_device *netdev,
 				struct ethtool_drvinfo *info)
 {
+	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
+
 	strlcpy(info->driver, ibmvnic_driver_name, sizeof(info->driver));
 	strlcpy(info->version, IBMVNIC_DRIVER_VERSION, sizeof(info->version));
+	strlcpy(info->fw_version, adapter->fw_version,
+		sizeof(info->fw_version));
 }
 
 static u32 ibmvnic_get_msglevel(struct net_device *netdev)
@@ -2923,6 +2947,110 @@ static void send_login(struct ibmvnic_adapter *adapter)
 	return;
 }
 
+static int ibmvnic_get_vpd(struct ibmvnic_adapter *adapter)
+{
+	struct device *dev = &adapter->vdev->dev;
+	union ibmvnic_crq crq;
+	dma_addr_t dma_addr;
+	int len;
+
+	if (adapter->vpd->buff)
+		len = adapter->vpd->len;
+
+	reinit_completion(&adapter->fw_done);
+	crq.get_vpd_size.first = IBMVNIC_CRQ_CMD;
+	crq.get_vpd_size.cmd = GET_VPD_SIZE;
+	ibmvnic_send_crq(adapter, &crq);
+	wait_for_completion(&adapter->fw_done);
+
+	if (!adapter->vpd->buff)
+		adapter->vpd->buff = kzalloc(adapter->vpd->len, GFP_KERNEL);
+	else if (adapter->vpd->len != len)
+		adapter->vpd->buff =
+			krealloc(adapter->vpd->buff,
+				 adapter->vpd->len, GFP_KERNEL);
+
+	if (!adapter->vpd->buff) {
+		dev_err(dev, "Could allocate VPD buffer\n");
+		return -ENOMEM;
+	}
+
+	adapter->vpd->dma_addr =
+		dma_map_single(dev, adapter->vpd->buff, adapter->vpd->len,
+			       DMA_FROM_DEVICE);
+	if (dma_mapping_error(dev, dma_addr)) {
+		dev_err(dev, "Could not map VPD buffer\n");
+		return -ENOMEM;
+	}
+
+	reinit_completion(&adapter->fw_done);
+	crq.get_vpd.first = IBMVNIC_CRQ_CMD;
+	crq.get_vpd.cmd = GET_VPD;
+	crq.get_vpd.ioba = cpu_to_be32(adapter->vpd->dma_addr);
+	crq.get_vpd.len = cpu_to_be32((u32)adapter->vpd->len);
+	ibmvnic_send_crq(adapter, &crq);
+	wait_for_completion(&adapter->fw_done);
+
+	return 0;
+}
+
+static void handle_vpd_size_rsp(union ibmvnic_crq *crq,
+				   struct ibmvnic_adapter *adapter)
+{
+	struct device *dev = &adapter->vdev->dev;
+
+	if (crq->get_vpd_size_rsp.rc.code) {
+		dev_err(dev, "Error retrieving VPD size, rc=%x\n",
+			crq->get_vpd_size_rsp.rc.code);
+		complete(&adapter->fw_done);
+		return;
+	}
+
+	adapter->vpd->len = be64_to_cpu(crq->get_vpd_size_rsp.len);
+	complete(&adapter->fw_done);
+}
+
+static void handle_vpd_rsp(union ibmvnic_crq *crq,
+			      struct ibmvnic_adapter *adapter)
+{
+	struct device *dev = &adapter->vdev->dev;
+	char *substr = NULL, *ptr = NULL;
+	u8 fw_level_len = 0;
+
+	dma_unmap_single(dev, adapter->vpd->dma_addr, adapter->vpd->len,
+			 DMA_FROM_DEVICE);
+
+	if (crq->get_vpd_rsp.rc.code) {
+		dev_err(dev, "Error retrieving VPD, rc=%x\n",
+			crq->get_vpd_rsp.rc.code);
+		complete(&adapter->fw_done);
+		return;
+	}
+
+	/* get the position of the firmware version info
+	 * located after the ASCII 'RM' substring in the buffer
+	 */
+	substr = strnstr(adapter->vpd->buff, "RM", adapter->vpd->len);
+	if (substr == NULL) {
+		dev_info(dev, "No FW level provided by VPD\n");
+		complete(&adapter->fw_done);
+		return;
+	}
+
+	/* get length of firmware level ASCII substring */
+	fw_level_len = *(substr + 2);
+
+	/* copy firmware version string from vpd into adapter */
+	ptr = strncpy((char *)adapter->fw_version,
+			  substr + 3, fw_level_len);
+	if (!ptr) {
+		dev_err(dev, "Failed to isolate FW level string\n");
+		memset(adapter->fw_version, 0, 32);
+	}
+
+	complete(&adapter->fw_done);
+}
+
 static void send_request_map(struct ibmvnic_adapter *adapter, dma_addr_t addr,
 			     u32 len, u8 map_id)
 {
@@ -3807,6 +3939,12 @@ static void ibmvnic_handle_crq(union ibmvnic_crq *crq,
 		netdev_dbg(netdev, "Got Collect firmware trace Response\n");
 		complete(&adapter->fw_done);
 		break;
+	case GET_VPD_SIZE_RSP:
+		handle_vpd_size_rsp(crq, adapter);
+		break;
+	case GET_VPD_RSP:
+		handle_vpd_rsp(crq, adapter);
+		break;
 	default:
 		netdev_err(netdev, "Got an invalid cmd type 0x%02x\n",
 			   gen_crq->cmd);
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index 4670af8..d3a6959 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -558,6 +558,12 @@ struct ibmvnic_multicast_ctrl {
 	struct ibmvnic_rc rc;
 } __packed __aligned(8);
 
+struct ibmvnic_get_vpd_size {
+	u8 first;
+	u8 cmd;
+	u8 reserved[14];
+} __packed __aligned(8);
+
 struct ibmvnic_get_vpd_size_rsp {
 	u8 first;
 	u8 cmd;
@@ -575,6 +581,13 @@ struct ibmvnic_get_vpd {
 	u8 reserved[4];
 } __packed __aligned(8);
 
+struct ibmvnic_get_vpd_rsp {
+	u8 first;
+	u8 cmd;
+	u8 reserved[10];
+	struct ibmvnic_rc rc;
+} __packed __aligned(8);
+
 struct ibmvnic_acl_change_indication {
 	u8 first;
 	u8 cmd;
@@ -700,10 +713,10 @@ union ibmvnic_crq {
 	struct ibmvnic_change_mac_addr change_mac_addr_rsp;
 	struct ibmvnic_multicast_ctrl multicast_ctrl;
 	struct ibmvnic_multicast_ctrl multicast_ctrl_rsp;
-	struct ibmvnic_generic_crq get_vpd_size;
+	struct ibmvnic_get_vpd_size get_vpd_size;
 	struct ibmvnic_get_vpd_size_rsp get_vpd_size_rsp;
 	struct ibmvnic_get_vpd get_vpd;
-	struct ibmvnic_generic_crq get_vpd_rsp;
+	struct ibmvnic_get_vpd_rsp get_vpd_rsp;
 	struct ibmvnic_acl_change_indication acl_change_indication;
 	struct ibmvnic_acl_query acl_query;
 	struct ibmvnic_generic_crq acl_query_rsp;
@@ -937,6 +950,12 @@ struct ibmvnic_error_buff {
 	__be32 error_id;
 };
 
+struct ibmvnic_vpd {
+	unsigned char *buff;
+	dma_addr_t dma_addr;
+	u64 len;
+};
+
 enum vnic_state {VNIC_PROBING = 1,
 		 VNIC_PROBED,
 		 VNIC_OPENING,
@@ -978,6 +997,10 @@ struct ibmvnic_adapter {
 	dma_addr_t ip_offload_ctrl_tok;
 	u32 msg_enable;
 
+	/* Vital Product Data (VPD) */
+	struct ibmvnic_vpd *vpd;
+	char fw_version[32];
+
 	/* Statistics */
 	struct ibmvnic_statistics stats;
 	dma_addr_t stats_token;
-- 
2.9.5
