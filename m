From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net-next] ibmveth: add support for TSO6
Date: Tue, 14 Jul 2015 10:51:51 -0500
Message-ID: <1436889111-10509-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, nfont@linux.vnet.ibm.com,
	brking@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:46166 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753081AbbGNPv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 11:51:57 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Tue, 14 Jul 2015 09:51:56 -0600
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 17908C90045
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 11:43:00 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t6EFprsn53084354
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 15:51:53 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t6EFprKa023702
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 11:51:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for a new method of signalling the firmware
that TSO packets are being sent. The new method removes the need to
alter the ip and tcp checksums and allows TSO6 support.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmveth.c |  145 +++++++++++++++++++++++++++++------
 drivers/net/ethernet/ibm/ibmveth.h |   18 ++++-
 2 files changed, 135 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 29bbb62..d4b92cd 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -79,6 +79,11 @@ static unsigned int rx_flush __read_mostly = 0;
 module_param(rx_flush, uint, 0644);
 MODULE_PARM_DESC(rx_flush, "Flush receive buffers before use");
 
+static bool old_large_send __read_mostly;
+module_param(old_large_send, bool, S_IRUGO);
+MODULE_PARM_DESC(old_large_send,
+	"Use old large send method on firmware that supports the new method");
+
 struct ibmveth_stat {
 	char name[ETH_GSTRING_LEN];
 	int offset;
@@ -101,7 +106,8 @@ struct ibmveth_stat ibmveth_stats[] = {
 	{ "fw_enabled_ipv4_csum", IBMVETH_STAT_OFF(fw_ipv4_csum_support) },
 	{ "fw_enabled_ipv6_csum", IBMVETH_STAT_OFF(fw_ipv6_csum_support) },
 	{ "tx_large_packets", IBMVETH_STAT_OFF(tx_large_packets) },
-	{ "rx_large_packets", IBMVETH_STAT_OFF(rx_large_packets) }
+	{ "rx_large_packets", IBMVETH_STAT_OFF(rx_large_packets) },
+	{ "fw_enabled_large_send", IBMVETH_STAT_OFF(fw_large_send_support) }
 };
 
 /* simple methods of getting data from the current rxq entry */
@@ -848,25 +854,91 @@ static int ibmveth_set_csum_offload(struct net_device *dev, u32 data)
 	return rc1 ? rc1 : rc2;
 }
 
+static int ibmveth_set_tso(struct net_device *dev, u32 data)
+{
+	struct ibmveth_adapter *adapter = netdev_priv(dev);
+	unsigned long set_attr, clr_attr, ret_attr;
+	long ret1, ret2;
+	int rc1 = 0, rc2 = 0;
+	int restart = 0;
+
+	if (netif_running(dev)) {
+		restart = 1;
+		adapter->pool_config = 1;
+		ibmveth_close(dev);
+		adapter->pool_config = 0;
+	}
+
+	set_attr = 0;
+	clr_attr = 0;
+
+	if (data)
+		set_attr = IBMVETH_ILLAN_LRG_SR_ENABLED;
+	else
+		clr_attr = IBMVETH_ILLAN_LRG_SR_ENABLED;
+
+	ret1 = h_illan_attributes(adapter->vdev->unit_address, 0, 0, &ret_attr);
+
+	if (ret1 == H_SUCCESS && (ret_attr & IBMVETH_ILLAN_LRG_SND_SUPPORT) &&
+	    !old_large_send) {
+		ret2 = h_illan_attributes(adapter->vdev->unit_address, clr_attr,
+					  set_attr, &ret_attr);
+
+		if (ret2 != H_SUCCESS) {
+			netdev_err(dev, "unable to change tso settings. %d rc=%ld\n",
+				   data, ret2);
+
+			h_illan_attributes(adapter->vdev->unit_address,
+					   set_attr, clr_attr, &ret_attr);
+
+			if (data == 1)
+				dev->features &= ~(NETIF_F_TSO | NETIF_F_TSO6);
+			rc1 = -EIO;
+
+		} else {
+			adapter->fw_large_send_support = data;
+			adapter->large_send = data;
+		}
+	} else {
+		/* Older firmware version of large send offload does not
+		 * support tcp6/ipv6
+		 */
+		if (data == 1) {
+			dev->features &= ~NETIF_F_TSO6;
+			netdev_info(dev, "TSO feature requires all partitions to have updated driver");
+		}
+		adapter->large_send = data;
+	}
+
+	if (restart)
+		rc2 = ibmveth_open(dev);
+
+	return rc1 ? rc1 : rc2;
+}
+
 static int ibmveth_set_features(struct net_device *dev,
 	netdev_features_t features)
 {
 	struct ibmveth_adapter *adapter = netdev_priv(dev);
 	int rx_csum = !!(features & NETIF_F_RXCSUM);
-	int rc;
-	netdev_features_t changed = features ^ dev->features;
-
-	if (features & NETIF_F_TSO & changed)
-		netdev_info(dev, "TSO feature requires all partitions to have updated driver");
+	int large_send = !!(features & (NETIF_F_TSO | NETIF_F_TSO6));
+	int rc1 = 0, rc2 = 0;
 
-	if (rx_csum == adapter->rx_csum)
-		return 0;
+	if (rx_csum != adapter->rx_csum) {
+		rc1 = ibmveth_set_csum_offload(dev, rx_csum);
+		if (rc1 && !adapter->rx_csum)
+			dev->features =
+				features & ~(NETIF_F_ALL_CSUM | NETIF_F_RXCSUM);
+	}
 
-	rc = ibmveth_set_csum_offload(dev, rx_csum);
-	if (rc && !adapter->rx_csum)
-		dev->features = features & ~(NETIF_F_ALL_CSUM | NETIF_F_RXCSUM);
+	if (large_send != adapter->large_send) {
+		rc2 = ibmveth_set_tso(dev, large_send);
+		if (rc2 && !adapter->large_send)
+			dev->features =
+				features & ~(NETIF_F_TSO | NETIF_F_TSO6);
+	}
 
-	return rc;
+	return rc1 ? rc1 : rc2;
 }
 
 static void ibmveth_get_strings(struct net_device *dev, u32 stringset, u8 *data)
@@ -917,7 +989,7 @@ static int ibmveth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 #define page_offset(v) ((unsigned long)(v) & ((1 << 12) - 1))
 
 static int ibmveth_send(struct ibmveth_adapter *adapter,
-			union ibmveth_buf_desc *descs)
+			union ibmveth_buf_desc *descs, unsigned long mss)
 {
 	unsigned long correlator;
 	unsigned int retry_count;
@@ -934,7 +1006,8 @@ static int ibmveth_send(struct ibmveth_adapter *adapter,
 					     descs[0].desc, descs[1].desc,
 					     descs[2].desc, descs[3].desc,
 					     descs[4].desc, descs[5].desc,
-					     correlator, &correlator);
+					     correlator, &correlator, mss,
+					     adapter->fw_large_send_support);
 	} while ((ret == H_BUSY) && (retry_count--));
 
 	if (ret != H_SUCCESS && ret != H_DROPPED) {
@@ -955,6 +1028,7 @@ static netdev_tx_t ibmveth_start_xmit(struct sk_buff *skb,
 	int last, i;
 	int force_bounce = 0;
 	dma_addr_t dma_addr;
+	unsigned long mss = 0;
 
 	/*
 	 * veth handles a maximum of 6 segments including the header, so
@@ -980,6 +1054,9 @@ static netdev_tx_t ibmveth_start_xmit(struct sk_buff *skb,
 
 	desc_flags = IBMVETH_BUF_VALID;
 
+	if (skb_is_gso(skb) && adapter->fw_large_send_support)
+		desc_flags |= IBMVETH_BUF_LRG_SND;
+
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		unsigned char *buf = skb_transport_header(skb) +
 						skb->csum_offset;
@@ -1007,7 +1084,7 @@ retry_bounce:
 		descs[0].fields.flags_len = desc_flags | skb->len;
 		descs[0].fields.address = adapter->bounce_buffer_dma;
 
-		if (ibmveth_send(adapter, descs)) {
+		if (ibmveth_send(adapter, descs, 0)) {
 			adapter->tx_send_failed++;
 			netdev->stats.tx_dropped++;
 		} else {
@@ -1041,16 +1118,23 @@ retry_bounce:
 		descs[i+1].fields.address = dma_addr;
 	}
 
-	if (skb_is_gso(skb) && !skb_is_gso_v6(skb)) {
-		/* Put -1 in the IP checksum to tell phyp it
-		 *  is a largesend packet and put the mss in the TCP checksum.
-		 */
-		ip_hdr(skb)->check = 0xffff;
-		tcp_hdr(skb)->check = cpu_to_be16(skb_shinfo(skb)->gso_size);
-		adapter->tx_large_packets++;
+	if (skb_is_gso(skb)) {
+		if (adapter->fw_large_send_support) {
+			mss = (unsigned long)skb_shinfo(skb)->gso_size;
+			adapter->tx_large_packets++;
+		} else if (!skb_is_gso_v6(skb)) {
+			/* Put -1 in the IP checksum to tell phyp it
+			 * is a largesend packet. Put the mss in
+			 * the TCP checksum.
+			 */
+			ip_hdr(skb)->check = 0xffff;
+			tcp_hdr(skb)->check =
+				cpu_to_be16(skb_shinfo(skb)->gso_size);
+			adapter->tx_large_packets++;
+		}
 	}
 
-	if (ibmveth_send(adapter, descs)) {
+	if (ibmveth_send(adapter, descs, mss)) {
 		adapter->tx_send_failed++;
 		netdev->stats.tx_dropped++;
 	} else {
@@ -1401,6 +1485,8 @@ static int ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
 	struct ibmveth_adapter *adapter;
 	unsigned char *mac_addr_p;
 	unsigned int *mcastFilterSize_p;
+	long ret;
+	unsigned long ret_attr;
 
 	dev_dbg(&dev->dev, "entering ibmveth_probe for UA 0x%x\n",
 		dev->unit_address);
@@ -1449,10 +1535,19 @@ static int ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
 	SET_NETDEV_DEV(netdev, &dev->dev);
 	netdev->hw_features = NETIF_F_SG | NETIF_F_RXCSUM |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
+
 	netdev->features |= netdev->hw_features;
 
-	/* TSO is disabled by default */
-	netdev->hw_features |= NETIF_F_TSO;
+	ret = h_illan_attributes(adapter->vdev->unit_address, 0, 0, &ret_attr);
+
+	/* If running older firmware, TSO should not be enabled by default */
+	if (ret == H_SUCCESS && (ret_attr & IBMVETH_ILLAN_LRG_SND_SUPPORT) &&
+	    !old_large_send) {
+		netdev->hw_features |= NETIF_F_TSO | NETIF_F_TSO6;
+		netdev->features |= netdev->hw_features;
+	} else {
+		netdev->hw_features |= NETIF_F_TSO;
+	}
 
 	memcpy(netdev->dev_addr, mac_addr_p, ETH_ALEN);
 
diff --git a/drivers/net/ethernet/ibm/ibmveth.h b/drivers/net/ethernet/ibm/ibmveth.h
index 41dedb1..4eade67 100644
--- a/drivers/net/ethernet/ibm/ibmveth.h
+++ b/drivers/net/ethernet/ibm/ibmveth.h
@@ -40,6 +40,8 @@
 #define IbmVethMcastRemoveFilter     0x2UL
 #define IbmVethMcastClearFilterTable 0x3UL
 
+#define IBMVETH_ILLAN_LRG_SR_ENABLED	0x0000000000010000UL
+#define IBMVETH_ILLAN_LRG_SND_SUPPORT	0x0000000000008000UL
 #define IBMVETH_ILLAN_PADDED_PKT_CSUM	0x0000000000002000UL
 #define IBMVETH_ILLAN_TRUNK_PRI_MASK	0x0000000000000F00UL
 #define IBMVETH_ILLAN_IPV6_TCP_CSUM		0x0000000000000004UL
@@ -59,13 +61,20 @@
 static inline long h_send_logical_lan(unsigned long unit_address,
 		unsigned long desc1, unsigned long desc2, unsigned long desc3,
 		unsigned long desc4, unsigned long desc5, unsigned long desc6,
-		unsigned long corellator_in, unsigned long *corellator_out)
+		unsigned long corellator_in, unsigned long *corellator_out,
+		unsigned long mss, unsigned long large_send_support)
 {
 	long rc;
 	unsigned long retbuf[PLPAR_HCALL9_BUFSIZE];
 
-	rc = plpar_hcall9(H_SEND_LOGICAL_LAN, retbuf, unit_address, desc1,
-			desc2, desc3, desc4, desc5, desc6, corellator_in);
+	if (large_send_support)
+		rc = plpar_hcall9(H_SEND_LOGICAL_LAN, retbuf, unit_address,
+				  desc1, desc2, desc3, desc4, desc5, desc6,
+				  corellator_in, mss);
+	else
+		rc = plpar_hcall9(H_SEND_LOGICAL_LAN, retbuf, unit_address,
+				  desc1, desc2, desc3, desc4, desc5, desc6,
+				  corellator_in);
 
 	*corellator_out = retbuf[0];
 
@@ -147,11 +156,13 @@ struct ibmveth_adapter {
     struct ibmveth_rx_q rx_queue;
     int pool_config;
     int rx_csum;
+    int large_send;
     void *bounce_buffer;
     dma_addr_t bounce_buffer_dma;
 
     u64 fw_ipv6_csum_support;
     u64 fw_ipv4_csum_support;
+    u64 fw_large_send_support;
     /* adapter specific stats */
     u64 replenish_task_cycles;
     u64 replenish_no_mem;
@@ -182,6 +193,7 @@ struct ibmveth_buf_desc_fields {
 #endif
 #define IBMVETH_BUF_VALID	0x80000000
 #define IBMVETH_BUF_TOGGLE	0x40000000
+#define IBMVETH_BUF_LRG_SND     0x04000000
 #define IBMVETH_BUF_NO_CSUM	0x02000000
 #define IBMVETH_BUF_CSUM_GOOD	0x01000000
 #define IBMVETH_BUF_LEN_MASK	0x00FFFFFF
-- 
1.7.1
