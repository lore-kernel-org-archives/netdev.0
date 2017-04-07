From: Sivakumar Krishnasamy <ksiva@linux.vnet.ibm.com>
Subject: [PATCH] ibmveth: Support to enable LSO/CSO for Trunk VEA.
Date: Fri,  7 Apr 2017 05:57:59 -0400
Message-ID: <1491559079-10855-1-git-send-email-ksiva@linux.vnet.ibm.com>
Cc: tlfalcon@linux.vnet.ibm.com, benh@kernel.crashing.org,
        paulus@samba.org, mpe@ellerman.id.au,
        linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
        brking@linux.vnet.ibm.com, seroyer@linux.vnet.ibm.com,
        Sivakumar Krishnasamy <ksiva@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable largesend and checksum offload for ibmveth configured in trunk mode.
Added support to SKB frag_list in TX path by skb_linearize'ing such SKBs.

Signed-off-by: Sivakumar Krishnasamy <ksiva@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmveth.c | 102 ++++++++++++++++++++++++++++++-------
 drivers/net/ethernet/ibm/ibmveth.h |   1 +
 2 files changed, 85 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 72ab7b6..e1e238d 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -46,6 +46,8 @@
 #include <asm/vio.h>
 #include <asm/iommu.h>
 #include <asm/firmware.h>
+#include <net/tcp.h>
+#include <net/ip6_checksum.h>
 
 #include "ibmveth.h"
 
@@ -808,8 +810,7 @@ static int ibmveth_set_csum_offload(struct net_device *dev, u32 data)
 
 	ret = h_illan_attributes(adapter->vdev->unit_address, 0, 0, &ret_attr);
 
-	if (ret == H_SUCCESS && !(ret_attr & IBMVETH_ILLAN_ACTIVE_TRUNK) &&
-	    !(ret_attr & IBMVETH_ILLAN_TRUNK_PRI_MASK) &&
+	if (ret == H_SUCCESS &&
 	    (ret_attr & IBMVETH_ILLAN_PADDED_PKT_CSUM)) {
 		ret4 = h_illan_attributes(adapter->vdev->unit_address, clr_attr,
 					 set_attr, &ret_attr);
@@ -1040,6 +1041,15 @@ static netdev_tx_t ibmveth_start_xmit(struct sk_buff *skb,
 	dma_addr_t dma_addr;
 	unsigned long mss = 0;
 
+	/* veth doesn't handle frag_list, so linearize the skb.
+	 * When GRO is enabled SKB's can have frag_list.
+	 */
+	if (adapter->is_active_trunk &&
+	    skb_has_frag_list(skb) && __skb_linearize(skb)) {
+		netdev->stats.tx_dropped++;
+		goto out;
+	}
+
 	/*
 	 * veth handles a maximum of 6 segments including the header, so
 	 * we have to linearize the skb if there are more than this.
@@ -1064,9 +1074,6 @@ static netdev_tx_t ibmveth_start_xmit(struct sk_buff *skb,
 
 	desc_flags = IBMVETH_BUF_VALID;
 
-	if (skb_is_gso(skb) && adapter->fw_large_send_support)
-		desc_flags |= IBMVETH_BUF_LRG_SND;
-
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		unsigned char *buf = skb_transport_header(skb) +
 						skb->csum_offset;
@@ -1076,6 +1083,9 @@ static netdev_tx_t ibmveth_start_xmit(struct sk_buff *skb,
 		/* Need to zero out the checksum */
 		buf[0] = 0;
 		buf[1] = 0;
+
+		if (skb_is_gso(skb) && adapter->fw_large_send_support)
+			desc_flags |= IBMVETH_BUF_LRG_SND;
 	}
 
 retry_bounce:
@@ -1128,7 +1138,7 @@ retry_bounce:
 		descs[i+1].fields.address = dma_addr;
 	}
 
-	if (skb_is_gso(skb)) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL && skb_is_gso(skb)) {
 		if (adapter->fw_large_send_support) {
 			mss = (unsigned long)skb_shinfo(skb)->gso_size;
 			adapter->tx_large_packets++;
@@ -1232,6 +1242,66 @@ static void ibmveth_rx_mss_helper(struct sk_buff *skb, u16 mss, int lrg_pkt)
 	}
 }
 
+static void ibmveth_rx_csum_helper(struct sk_buff *skb,
+				   struct ibmveth_adapter *adapter)
+{
+	struct iphdr *iph = NULL;
+	struct ipv6hdr *iph6 = NULL;
+	__be16 skb_proto = 0;
+	u16 iphlen = 0;
+	u16 iph_proto = 0;
+	u16 tcphdrlen = 0;
+
+	skb_proto = be16_to_cpu(skb->protocol);
+
+	if (skb_proto == ETH_P_IP) {
+		iph = (struct iphdr *)skb->data;
+
+		/* If the IP checksum is not offloaded and if the packet
+		 *  is large send, the checksum must be rebuilt.
+		 */
+		if (iph->check == 0xffff) {
+			iph->check = 0;
+			iph->check = ip_fast_csum((unsigned char *)iph,
+						  iph->ihl);
+		}
+
+		iphlen = iph->ihl * 4;
+		iph_proto = iph->protocol;
+	} else if (skb_proto == ETH_P_IPV6) {
+		iph6 = (struct ipv6hdr *)skb->data;
+		iphlen = sizeof(struct ipv6hdr);
+		iph_proto = iph6->nexthdr;
+	}
+
+	/* In OVS environment, when a flow is not cached, specifically for a
+	 * new TCP connection, the first (SYN) packet information is passed up
+	 * the user space for finding a flow. During this process, OVS computes
+	 * checksum on the packet when CHECKSUM_PARTIAL flag is set.
+	 * Given that we zeroed out TCP checksum field in transmit path as we
+	 * set "no checksum bit", OVS computed checksum will be incorrect w/o
+	 * TCP pseudo checksum in the packet.
+	 * So, re-compute TCP pseudo header checksum.
+	 */
+	if (iph_proto == IPPROTO_TCP && adapter->is_active_trunk) {
+		struct tcphdr *tcph = (struct tcphdr *)(skb->data + iphlen);
+
+		tcphdrlen = skb->len - iphlen;
+
+		if (skb_proto == ETH_P_IP)
+			tcph->check = ~csum_tcpudp_magic(iph->saddr,
+					iph->daddr, tcphdrlen, iph_proto, 0);
+		else if (skb_proto == ETH_P_IPV6)
+			tcph->check = ~csum_ipv6_magic(&iph6->saddr,
+					&iph6->daddr, tcphdrlen, iph_proto, 0);
+
+		/* Setup SKB fields for checksum offload */
+		skb_partial_csum_set(skb, iphlen,
+				     offsetof(struct tcphdr, check));
+		skb_reset_network_header(skb);
+	}
+}
+
 static int ibmveth_poll(struct napi_struct *napi, int budget)
 {
 	struct ibmveth_adapter *adapter =
@@ -1239,7 +1309,6 @@ static int ibmveth_poll(struct napi_struct *napi, int budget)
 	struct net_device *netdev = adapter->netdev;
 	int frames_processed = 0;
 	unsigned long lpar_rc;
-	struct iphdr *iph;
 	u16 mss = 0;
 
 restart_poll:
@@ -1297,17 +1366,7 @@ restart_poll:
 
 			if (csum_good) {
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
-				if (be16_to_cpu(skb->protocol) == ETH_P_IP) {
-					iph = (struct iphdr *)skb->data;
-
-					/* If the IP checksum is not offloaded and if the packet
-					 *  is large send, the checksum must be rebuilt.
-					 */
-					if (iph->check == 0xffff) {
-						iph->check = 0;
-						iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
-					}
-				}
+				ibmveth_rx_csum_helper(skb, adapter);
 			}
 
 			if (length > netdev->mtu + ETH_HLEN) {
@@ -1626,6 +1685,13 @@ static int ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
 		netdev->hw_features |= NETIF_F_TSO;
 	}
 
+	adapter->is_active_trunk = false;
+	if (ret == H_SUCCESS && (ret_attr & IBMVETH_ILLAN_ACTIVE_TRUNK)) {
+		adapter->is_active_trunk = true;
+		netdev->hw_features |= NETIF_F_FRAGLIST;
+		netdev->features |= NETIF_F_FRAGLIST;
+	}
+
 	netdev->min_mtu = IBMVETH_MIN_MTU;
 	netdev->max_mtu = ETH_MAX_MTU;
 
diff --git a/drivers/net/ethernet/ibm/ibmveth.h b/drivers/net/ethernet/ibm/ibmveth.h
index 7acda04..de6e381 100644
--- a/drivers/net/ethernet/ibm/ibmveth.h
+++ b/drivers/net/ethernet/ibm/ibmveth.h
@@ -157,6 +157,7 @@ struct ibmveth_adapter {
     int pool_config;
     int rx_csum;
     int large_send;
+    bool is_active_trunk;
     void *bounce_buffer;
     dma_addr_t bounce_buffer_dma;
 
-- 
2.7.4
