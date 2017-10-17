From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net-next 1/3] ibmvnic: Enable scatter-gather support
Date: Tue, 17 Oct 2017 12:36:54 -0500
Message-ID: <1508261816-3145-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1508261816-3145-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:49854 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755745AbdJQRhL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 13:37:11 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9HHaoh9051618
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 13:37:11 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2dnkbrht7v-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 13:37:11 -0400
Received: from localhost
        by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Tue, 17 Oct 2017 11:37:10 -0600
In-Reply-To: <1508261816-3145-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables scatter gather support. Since there is no
HW/FW scatter-gather support at this time, the driver needs to
loop through each fragment and copy it to a contiguous, pre-mapped
buffer entry.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 23 +++++++++++++++++++++--
 1 file changed, 21 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 4bc14a9..b508877 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1204,9 +1204,28 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 	offset = index * adapter->req_mtu;
 	dst = tx_pool->long_term_buff.buff + offset;
 	memset(dst, 0, adapter->req_mtu);
-	skb_copy_from_linear_data(skb, dst, skb->len);
 	data_dma_addr = tx_pool->long_term_buff.addr + offset;
 
+	if (skb_shinfo(skb)->nr_frags) {
+		int cur, i;
+
+		/* Copy the head */
+		skb_copy_from_linear_data(skb, dst, skb_headlen(skb));
+		cur = skb_headlen(skb);
+
+		/* Copy the frags */
+		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+			const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+
+			memcpy(dst + cur,
+			       page_address(skb_frag_page(frag)) +
+			       frag->page_offset, skb_frag_size(frag));
+			cur += skb_frag_size(frag);
+		}
+	} else {
+		skb_copy_from_linear_data(skb, dst, skb->len);
+	}
+
 	tx_pool->consumer_index =
 	    (tx_pool->consumer_index + 1) %
 		adapter->req_tx_entries_per_subcrq;
@@ -2948,7 +2967,7 @@ static void handle_query_ip_offload_rsp(struct ibmvnic_adapter *adapter)
 	adapter->ip_offload_ctrl.large_rx_ipv4 = 0;
 	adapter->ip_offload_ctrl.large_rx_ipv6 = 0;
 
-	adapter->netdev->features = NETIF_F_GSO;
+	adapter->netdev->features = NETIF_F_SG | NETIF_F_GSO;
 
 	if (buf->tcp_ipv4_chksum || buf->udp_ipv4_chksum)
 		adapter->netdev->features |= NETIF_F_IP_CSUM;
-- 
1.8.3.1
