From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH] ibmveth: set correct gso_size and gso_type
Date: Thu,  8 Dec 2016 16:40:03 -0600
Message-ID: <1481236803-4807-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1477440555-21133-1-git-send-email-jmaxwell37@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:46635 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752295AbcLHWk2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 17:40:28 -0500
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB8MeQYj069322
        for <netdev@vger.kernel.org>; Thu, 8 Dec 2016 17:40:27 -0500
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
        by mx0b-001b2d01.pphosted.com with ESMTP id 277bvxmdqn-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 17:40:27 -0500
Received: from localhost
        by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Thu, 8 Dec 2016 15:40:13 -0700
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
        by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 8A9761FF002A
        for <netdev@vger.kernel.org>; Thu,  8 Dec 2016 15:39:48 -0700 (MST)
Received: from b03ledav004.gho.boulder.ibm.com (b03ledav004.gho.boulder.ibm.com [9.17.130.235])
        by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uB8Me9CS11927962
        for <netdev@vger.kernel.org>; Thu, 8 Dec 2016 15:40:09 -0700
Received: from b03ledav004.gho.boulder.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id 9EC4C78051
        for <netdev@vger.kernel.org>; Thu,  8 Dec 2016 15:40:09 -0700 (MST)
Received: from tlfalcon-workstation.austin.ibm.com (unknown [9.41.92.141])
        by b03ledav004.gho.boulder.ibm.com (Postfix) with ESMTP id 8133078066
        for <netdev@vger.kernel.org>; Thu,  8 Dec 2016 15:40:09 -0700 (MST)
In-Reply-To: <1477440555-21133-1-git-send-email-jmaxwell37@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is based on an earlier one submitted
by Jon Maxwell with the following commit message:

"We recently encountered a bug where a few customers using ibmveth on the
same LPAR hit an issue where a TCP session hung when large receive was
enabled. Closer analysis revealed that the session was stuck because the
one side was advertising a zero window repeatedly.

We narrowed this down to the fact the ibmveth driver did not set gso_size
which is translated by TCP into the MSS later up the stack. The MSS is
used to calculate the TCP window size and as that was abnormally large,
it was calculating a zero window, even although the sockets receive buffer
was completely empty."

We rely on the Virtual I/O Server partition in a pseries
environment to provide the MSS through the TCP header checksum
field. The stipulation is that users should not disable checksum
offloading if rx packet aggregation is enabled through VIOS.

Some firmware offerings provide the MSS in the RX buffer.
This is signalled by a bit in the RX queue descriptor.

Reviewed-by: Brian King <brking@linux.vnet.ibm.com>
Reviewed-by: Pradeep Satyanarayana <pradeeps@linux.vnet.ibm.com>
Reviewed-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Reviewed-by: Jonathan Maxwell <jmaxwell37@gmail.com>
Reviewed-by: David Dai <zdai@us.ibm.com>
Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

---
 drivers/net/ethernet/ibm/ibmveth.c | 65 ++++++++++++++++++++++++++++++++++++--
 drivers/net/ethernet/ibm/ibmveth.h |  1 +
 2 files changed, 64 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index ebe6071..a36022b 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -58,7 +58,7 @@
 
 static const char ibmveth_driver_name[] = "ibmveth";
 static const char ibmveth_driver_string[] = "IBM Power Virtual Ethernet Driver";
-#define ibmveth_driver_version "1.05"
+#define ibmveth_driver_version "1.06"
 
 MODULE_AUTHOR("Santiago Leon <santil@linux.vnet.ibm.com>");
 MODULE_DESCRIPTION("IBM Power Virtual Ethernet Driver");
@@ -137,6 +137,11 @@ static inline int ibmveth_rxq_frame_offset(struct ibmveth_adapter *adapter)
 	return ibmveth_rxq_flags(adapter) & IBMVETH_RXQ_OFF_MASK;
 }
 
+static inline int ibmveth_rxq_large_packet(struct ibmveth_adapter *adapter)
+{
+	return ibmveth_rxq_flags(adapter) & IBMVETH_RXQ_LRG_PKT;
+}
+
 static inline int ibmveth_rxq_frame_length(struct ibmveth_adapter *adapter)
 {
 	return be32_to_cpu(adapter->rx_queue.queue_addr[adapter->rx_queue.index].length);
@@ -1174,6 +1179,45 @@ static netdev_tx_t ibmveth_start_xmit(struct sk_buff *skb,
 	goto retry_bounce;
 }
 
+static void ibmveth_rx_mss_helper(struct sk_buff *skb, u16 mss, int lrg_pkt)
+{
+	int offset = 0;
+
+	/* only TCP packets will be aggregated */
+	if (skb->protocol == htons(ETH_P_IP)) {
+		struct iphdr *iph = (struct iphdr *)skb->data;
+
+		if (iph->protocol == IPPROTO_TCP) {
+			offset = iph->ihl * 4;
+			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
+		} else {
+			return;
+		}
+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		struct ipv6hdr *iph6 = (struct ipv6hdr *)skb->data;
+
+		if (iph6->nexthdr == IPPROTO_TCP) {
+			offset = sizeof(struct ipv6hdr);
+			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
+		} else {
+			return;
+		}
+	} else {
+		return;
+	}
+	/* if mss is not set through Large Packet bit/mss in rx buffer,
+	 * expect that the mss will be written to the tcp header checksum.
+	 */
+	if (lrg_pkt) {
+		skb_shinfo(skb)->gso_size = mss;
+	} else if (offset) {
+		struct tcphdr *tcph = (struct tcphdr *)(skb->data + offset);
+
+		skb_shinfo(skb)->gso_size = ntohs(tcph->check);
+		tcph->check = 0;
+	}
+}
+
 static int ibmveth_poll(struct napi_struct *napi, int budget)
 {
 	struct ibmveth_adapter *adapter =
@@ -1182,6 +1226,7 @@ static int ibmveth_poll(struct napi_struct *napi, int budget)
 	int frames_processed = 0;
 	unsigned long lpar_rc;
 	struct iphdr *iph;
+	u16 mss = 0;
 
 restart_poll:
 	while (frames_processed < budget) {
@@ -1199,9 +1244,21 @@ static int ibmveth_poll(struct napi_struct *napi, int budget)
 			int length = ibmveth_rxq_frame_length(adapter);
 			int offset = ibmveth_rxq_frame_offset(adapter);
 			int csum_good = ibmveth_rxq_csum_good(adapter);
+			int lrg_pkt = ibmveth_rxq_large_packet(adapter);
 
 			skb = ibmveth_rxq_get_buffer(adapter);
 
+			/* if the large packet bit is set in the rx queue
+			 * descriptor, the mss will be written by PHYP eight
+			 * bytes from the start of the rx buffer, which is
+			 * skb->data at this stage
+			 */
+			if (lrg_pkt) {
+				__be64 *rxmss = (__be64 *)(skb->data + 8);
+
+				mss = (u16)be64_to_cpu(*rxmss);
+			}
+
 			new_skb = NULL;
 			if (length < rx_copybreak)
 				new_skb = netdev_alloc_skb(netdev, length);
@@ -1235,11 +1292,15 @@ static int ibmveth_poll(struct napi_struct *napi, int budget)
 					if (iph->check == 0xffff) {
 						iph->check = 0;
 						iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
-						adapter->rx_large_packets++;
 					}
 				}
 			}
 
+			if (length > netdev->mtu + ETH_HLEN) {
+				ibmveth_rx_mss_helper(skb, mss, lrg_pkt);
+				adapter->rx_large_packets++;
+			}
+
 			napi_gro_receive(napi, skb);	/* send it up */
 
 			netdev->stats.rx_packets++;
diff --git a/drivers/net/ethernet/ibm/ibmveth.h b/drivers/net/ethernet/ibm/ibmveth.h
index 4eade67..7acda04 100644
--- a/drivers/net/ethernet/ibm/ibmveth.h
+++ b/drivers/net/ethernet/ibm/ibmveth.h
@@ -209,6 +209,7 @@ struct ibmveth_rx_q_entry {
 #define IBMVETH_RXQ_TOGGLE		0x80000000
 #define IBMVETH_RXQ_TOGGLE_SHIFT	31
 #define IBMVETH_RXQ_VALID		0x40000000
+#define IBMVETH_RXQ_LRG_PKT		0x04000000
 #define IBMVETH_RXQ_NO_CSUM		0x02000000
 #define IBMVETH_RXQ_CSUM_GOOD		0x01000000
 #define IBMVETH_RXQ_OFF_MASK		0x0000FFFF
-- 
1.8.3.1
