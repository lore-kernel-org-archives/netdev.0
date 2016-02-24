From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [net-next PATCH] ibmvnic: map L2/L3/L4 header descriptors to firmware
Date: Wed, 24 Feb 2016 13:34:03 -0600
Message-ID: <1456342443-11613-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:43045 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753429AbcBXTeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 14:34:14 -0500
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Wed, 24 Feb 2016 12:34:13 -0700
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 40DE21FF0021
	for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 12:22:19 -0700 (MST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp23033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1OJY92M26607712
	for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 19:34:09 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1OJY79v014217
	for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 14:34:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow the VNIC driver to provide descriptors containing
L2/L3/L4 headers to firmware.  This feature is needed
for greater hardware compatibility and enablement of offloading
technologies for some backing hardware.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 238 ++++++++++++++++++++++++++++++++++++-
 1 file changed, 235 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 7d657084..43c1df6 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -61,6 +61,7 @@
 #include <linux/proc_fs.h>
 #include <linux/in.h>
 #include <linux/ip.h>
+#include <linux/ipv6.h>
 #include <linux/irq.h>
 #include <linux/kthread.h>
 #include <linux/seq_file.h>
@@ -94,6 +95,7 @@ static int ibmvnic_reenable_crq_queue(struct ibmvnic_adapter *);
 static int ibmvnic_send_crq(struct ibmvnic_adapter *, union ibmvnic_crq *);
 static int send_subcrq(struct ibmvnic_adapter *adapter, u64 remote_handle,
 		       union sub_crq *sub_crq);
+static int send_subcrq_indirect(struct ibmvnic_adapter *, u64, u64, u64);
 static irqreturn_t ibmvnic_interrupt_rx(int irq, void *instance);
 static int enable_scrq_irq(struct ibmvnic_adapter *,
 			   struct ibmvnic_sub_crq_queue *);
@@ -561,12 +563,177 @@ static int ibmvnic_close(struct net_device *netdev)
 	return 0;
 }
 
+/**
+ * build_hdr_data - creates L2/L3/L4 header data buffer
+ * @hdr_field - bitfield determining needed headers
+ * @skb - socket buffer
+ * @hdr_len - array of header lengths
+ * @tot_len - total length of data
+ *
+ * Reads hdr_field to determine which headers are needed by firmware.
+ * Builds a buffer containing these headers.  Saves individual header
+ * lengths and total buffer length to be used to build descriptors.
+ */
+static unsigned char *build_hdr_data(u8 hdr_field, struct sk_buff *skb,
+				     int *hdr_len, int *tot_len)
+{
+	unsigned char *hdr_data;
+	unsigned char *hdrs[3];
+	u8 proto = 0;
+	int len = 0;
+	int i;
+
+	if ((hdr_field >> 6) & 1) {
+		hdrs[0] = skb_mac_header(skb);
+		hdr_len[0] = sizeof(struct ethhdr);
+	}
+
+	if ((hdr_field >> 5) & 1) {
+		hdrs[1] = skb_network_header(skb);
+		if (skb->protocol == htons(ETH_P_IP))
+			hdr_len[1] = ip_hdr(skb)->ihl * 4;
+		else if (skb->protocol == htons(ETH_P_IPV6))
+			hdr_len[1] = sizeof(struct ipv6hdr);
+	}
+
+	if ((hdr_field >> 4) & 1) {
+		hdrs[2] = skb_transport_header(skb);
+		if (skb->protocol == htons(ETH_P_IP))
+			proto = ip_hdr(skb)->protocol;
+		else if (skb->protocol == htons(ETH_P_IPV6))
+			proto = ipv6_hdr(skb)->nexthdr;
+
+		if (proto == IPPROTO_TCP)
+			hdr_len[2] = tcp_hdrlen(skb);
+		else if (proto == IPPROTO_UDP)
+			hdr_len[2] = sizeof(struct udphdr);
+	}
+
+	*tot_len = hdr_len[0] + hdr_len[1] + hdr_len[2];
+
+	hdr_data = kmalloc(*tot_len, GFP_KERNEL);
+	if (!hdr_data)
+		return NULL;
+
+	for (i = 0; i < 3; i++) {
+		if (hdrs[i])
+			memcpy(hdr_data, hdrs[i] + len, hdr_len[i]);
+		len += hdr_len[i];
+	}
+	return hdr_data;
+}
+
+/**
+ * create_hdr_descs - create header and header extension descriptors
+ * @hdr_field - bitfield determining needed headers
+ * @data - buffer containing header data
+ * @len - length of data buffer
+ * @hdr_len - array of individual header lengths
+ * @scrq_arr - descriptor array
+ *
+ * Creates header and, if needed, header extension descriptors and
+ * places them in a descriptor array, scrq_arr
+ */
+
+void create_hdr_descs(u8 hdr_field, unsigned char *data, int len, int *hdr_len,
+		      union sub_crq *scrq_arr)
+{
+	union sub_crq hdr_desc;
+	int tmp_len = len;
+	int tmp;
+
+	while (tmp_len > 0) {
+		unsigned char *cur = data + len - tmp_len;
+
+		memset(&hdr_desc, 0, sizeof(hdr_desc));
+		if (cur != data) {
+			tmp = tmp_len > 29 ? 29 : tmp_len;
+			hdr_desc.hdr_ext.first = IBMVNIC_CRQ_CMD;
+			hdr_desc.hdr_ext.type = IBMVNIC_HDR_EXT_DESC;
+			hdr_desc.hdr_ext.len = tmp;
+		} else {
+			tmp = tmp_len > 24 ? 24 : tmp_len;
+			hdr_desc.hdr.first = IBMVNIC_CRQ_CMD;
+			hdr_desc.hdr.type = IBMVNIC_HDR_DESC;
+			hdr_desc.hdr.len = tmp;
+			hdr_desc.hdr.l2_len = (u8)hdr_len[0];
+			hdr_desc.hdr.l3_len = (u16)hdr_len[1];
+			hdr_desc.hdr.l4_len = (u8)hdr_len[2];
+			hdr_desc.hdr.flag = hdr_field << 1;
+		}
+		memcpy(hdr_desc.hdr.data, cur, tmp);
+		tmp_len -= tmp;
+		*scrq_arr = hdr_desc;
+		scrq_arr++;
+	}
+}
+
+static int calc_num_hdr_descs(int len)
+{
+	int num_descs = 1;
+
+	len -= 24;
+	if (len > 0)
+		num_descs += len % 29 ? len / 29 + 1 : len / 29;
+	return num_descs;
+}
+
+static union sub_crq *alloc_scrq_array(int num, union sub_crq subcrq)
+{
+	union sub_crq *scrq_arr;
+
+	scrq_arr = kcalloc(num, sizeof(*scrq_arr), GFP_KERNEL);
+	if (!scrq_arr)
+		return NULL;
+	scrq_arr[0] = subcrq;
+	return scrq_arr;
+}
+
+/**
+ * build_hdr_descs_arr - build a header descriptor array
+ * @skb - socket buffer
+ * @num_entries - number of descriptors to be sent
+ * @subcrq - first TX descriptor
+ * @hdr_field - bit field determining which headers will be sent
+ *
+ * This function will build a TX with descriptor array with applicable
+ * L2/L3/L4 packet header descriptors to be sent by send_subcrq_indirect.
+ */
+
+static union sub_crq *build_hdr_descs_arr(struct sk_buff *skb,
+					  int *num_entries,
+					  union sub_crq subcrq, u8 hdr_field)
+{
+	unsigned char *hdr_data;
+	union sub_crq *entries;
+	int hdr_len[3] = {0};
+	int tot_len;
+
+	hdr_data = bld_hdr_data(hdr_field, skb, hdr_len, &tot_len);
+	if (!hdr_data)
+		return NULL;
+
+	*num_entries += calc_num_hdr_descs(tot_len);
+
+	entries = alloc_scrq_array(*num_entries, subcrq);
+	if (!entries) {
+		kfree(hdr_data);
+		return NULL;
+	}
+
+	create_hdr_descs(hdr_field, hdr_data, tot_len, hdr_len, entries + 1);
+	kfree(hdr_data);
+	return entries;
+}
+
 static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
 	int queue_num = skb_get_queue_mapping(skb);
+	u8 *hdrs = (u8 *)&adapter->tx_rx_desc_req;
 	struct device *dev = &adapter->vdev->dev;
 	struct ibmvnic_tx_buff *tx_buff = NULL;
+	union sub_crq *indir_arr = NULL;
 	struct ibmvnic_tx_pool *tx_pool;
 	unsigned int tx_send_failed = 0;
 	unsigned int tx_map_failed = 0;
@@ -576,9 +743,11 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 	dma_addr_t data_dma_addr;
 	struct netdev_queue *txq;
 	bool used_bounce = false;
+	dma_addr_t indir_ioba;
 	unsigned long lpar_rc;
 	union sub_crq tx_crq;
 	unsigned int offset;
+	int num_entries = 1;
 	unsigned char *dst;
 	u64 *handle_array;
 	int index = 0;
@@ -644,10 +813,47 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 			tx_crq.v1.flags1 |= IBMVNIC_TX_PROT_UDP;
 	}
 
-	if (skb->ip_summed == CHECKSUM_PARTIAL)
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		tx_crq.v1.flags1 |= IBMVNIC_TX_CHKSUM_OFFLOAD;
+		hdrs += 2;
+	}
+
+	/* determine if l2/3/4 headers are sent to firmware */
+	if ((*hdrs >> 7) & 1 &&
+	    (skb->protocol == htons(ETH_P_IP) ||
+	     skb->protocol == htons(ETH_P_IPV6))) {
+		indir_arr = build_hdr_descs_arr(skb,
+						&num_entries,
+						tx_crq, *hdrs);
+		if (!indir_arr) {
+			dev_err(dev, "tx: unable to create descriptor array\n");
+			tx_send_failed++;
+			tx_dropped++;
+			ret = NETDEV_TX_BUSY;
+			goto out;
+		}
+		tx_crq.v1.n_crq_elem = num_entries;
+		indir_ioba = dma_map_single(dev, indir_arr,
+					    num_entries * sizeof(*indir_arr),
+					    DMA_TO_DEVICE);
+		if (dma_mapping_error(dev, indir_ioba)) {
+			if (!firmware_has_feature(FW_FEATURE_CMO))
+				dev_err(dev, "tx: unable to map descriptor array\n");
+			tx_map_failed++;
+			tx_dropped++;
+			ret = NETDEV_TX_BUSY;
+			goto out;
+		}
 
-	lpar_rc = send_subcrq(adapter, handle_array[0], &tx_crq);
+		lpar_rc = send_subcrq_indirect(adapter, handle_array[0],
+					       (u64)indir_ioba,
+					       (u64)num_entries);
+		dma_unmap_single(dev, indir_ioba,
+				 num_entries * sizeof(*indir_arr),
+				 DMA_TO_DEVICE);
+	} else {
+		lpar_rc = send_subcrq(adapter, handle_array[0], &tx_crq);
+	}
 
 	if (lpar_rc != H_SUCCESS) {
 		dev_err(dev, "tx failed with code %ld\n", lpar_rc);
@@ -674,6 +880,7 @@ out:
 	netdev->stats.tx_packets += tx_packets;
 	adapter->tx_send_failed += tx_send_failed;
 	adapter->tx_map_failed += tx_map_failed;
+	kfree(indir_arr);
 
 	return ret;
 }
@@ -1494,6 +1701,30 @@ static int send_subcrq(struct ibmvnic_adapter *adapter, u64 remote_handle,
 	return rc;
 }
 
+static int send_subcrq_indirect(struct ibmvnic_adapter *adapter,
+				u64 remote_handle, u64 ioba, u64 num_entries)
+{
+	unsigned int ua = adapter->vdev->unit_address;
+	struct device *dev = &adapter->vdev->dev;
+	int rc;
+
+	/* Make sure the hypervisor sees the complete request */
+	mb();
+
+	rc = plpar_hcall_norets(H_SEND_SUB_CRQ_INDIRECT, ua,
+				cpu_to_be64(remote_handle),
+				cpu_to_be64(ioba),
+				cpu_to_be64(num_entries));
+
+	if (rc) {
+		if (rc == H_CLOSED)
+			dev_warn(dev, "CRQ Queue closed\n");
+		dev_err(dev, "Send (indirect) error (rc=%d)\n", rc);
+	}
+
+	return rc;
+}
+
 static int ibmvnic_send_crq(struct ibmvnic_adapter *adapter,
 			    union ibmvnic_crq *crq)
 {
@@ -2447,7 +2678,8 @@ static void handle_query_cap_rsp(union ibmvnic_crq *crq,
 			   adapter->opt_rxba_entries_per_subcrq);
 		break;
 	case TX_RX_DESC_REQ:
-		adapter->tx_rx_desc_req = crq->query_capability.number;
+		adapter->tx_rx_desc_req =
+				be64_to_cpu(crq->query_capability.number);
 		netdev_dbg(netdev, "tx_rx_desc_req = %llx\n",
 			   adapter->tx_rx_desc_req);
 		break;
-- 
1.8.3.1
