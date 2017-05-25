From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net-next v2] ibmvnic: Enable TSO support
Date: Thu, 25 May 2017 08:55:36 -0500
Message-ID: <1495720536-16301-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        Nathan Fontenot <nfont@linux.vnet.ibm.com>,
        John Allen <jallen@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:40708 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S965991AbdEYNzt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 09:55:49 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4PDriM8023242
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 09:55:49 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2ans8xuyyr-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 09:55:49 -0400
Received: from localhost
        by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Thu, 25 May 2017 09:55:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable TSO in the ibmvnic driver. Scatter-gather is also enabled,
though there currently is no support for scatter-gather in
vNIC-compatible hardware, resulting in forced linearization
of all fragmented SKB's. Though not ideal, given the throughput
improvement gained by enabling TSO, it has been decided
that this is an acceptable tradeoff.

The feature is also enabled by a module parameter.
This parameter is necessary because TSO can not easily be
enabled or disabled in firmware without reinitializing the driver.

CC: Nathan Fontenot <nfont@linux.vnet.ibm.com>
CC: John Allen <jallen@linux.vnet.ibm.com>
Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
v2: Fix kbuild robot warning from module parameter init
---
 drivers/net/ethernet/ibm/ibmvnic.c | 39 +++++++++++++++++++++++++++++++++++---
 1 file changed, 36 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index abe2b6e..29cb2c4 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -81,6 +81,11 @@
 static const char ibmvnic_driver_name[] = "ibmvnic";
 static const char ibmvnic_driver_string[] = "IBM System i/p Virtual NIC Driver";
 
+static bool large_send_offload;
+module_param(large_send_offload, bool, 0644);
+MODULE_PARM_DESC(large_send_offload,
+		 "Determines whether large send offload is enabled");
+
 MODULE_AUTHOR("Santiago Leon <santi_leon@yahoo.com>");
 MODULE_DESCRIPTION("IBM System i/p Virtual NIC Driver");
 MODULE_LICENSE("GPL");
@@ -1025,6 +1030,17 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 		goto out;
 	}
 
+	/* All scatter-gather SKB's will be linearized for the time being, but
+	 * scatter-gather is only enabled if the user wishes to use TSO.
+	 */
+	if (skb_shinfo(skb)->nr_frags && __skb_linearize(skb)) {
+		dev_kfree_skb_any(skb);
+		tx_send_failed++;
+		tx_dropped++;
+		ret = NETDEV_TX_OK;
+		goto out;
+	}
+
 	tx_pool = &adapter->tx_pool[queue_num];
 	tx_scrq = adapter->tx_scrq[queue_num];
 	txq = netdev_get_tx_queue(netdev, skb_get_queue_mapping(skb));
@@ -1082,6 +1098,11 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 		tx_crq.v1.flags1 |= IBMVNIC_TX_CHKSUM_OFFLOAD;
 		hdrs += 2;
 	}
+	if (skb_is_gso(skb)) {
+		tx_crq.v1.flags1 |= IBMVNIC_TX_LSO;
+		tx_crq.v1.mss = cpu_to_be16(skb_shinfo(skb)->gso_size);
+		hdrs += 2;
+	}
 	/* determine if l2/3/4 headers are sent to firmware */
 	if ((*hdrs >> 7) & 1 &&
 	    (skb->protocol == htons(ETH_P_IP) ||
@@ -2629,10 +2650,10 @@ static void handle_query_ip_offload_rsp(struct ibmvnic_adapter *adapter)
 	adapter->ip_offload_ctrl.udp_ipv4_chksum = buf->udp_ipv4_chksum;
 	adapter->ip_offload_ctrl.tcp_ipv6_chksum = buf->tcp_ipv6_chksum;
 	adapter->ip_offload_ctrl.udp_ipv6_chksum = buf->udp_ipv6_chksum;
+	adapter->ip_offload_ctrl.large_tx_ipv4 = buf->large_tx_ipv4;
+	adapter->ip_offload_ctrl.large_tx_ipv6 = buf->large_tx_ipv6;
 
-	/* large_tx/rx disabled for now, additional features needed */
-	adapter->ip_offload_ctrl.large_tx_ipv4 = 0;
-	adapter->ip_offload_ctrl.large_tx_ipv6 = 0;
+	/* large_rx disabled for now, additional features needed */
 	adapter->ip_offload_ctrl.large_rx_ipv4 = 0;
 	adapter->ip_offload_ctrl.large_rx_ipv6 = 0;
 
@@ -2648,6 +2669,18 @@ static void handle_query_ip_offload_rsp(struct ibmvnic_adapter *adapter)
 	    (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM)))
 		adapter->netdev->features |= NETIF_F_RXCSUM;
 
+	if (large_send_offload) {
+		/* Scatter-gather is not currently supported by firmware.
+		 * It will only be enabled to support TSO operations.
+		 */
+		adapter->netdev->features = NETIF_F_SG;
+
+		if (buf->large_tx_ipv4)
+			adapter->netdev->features |= NETIF_F_TSO;
+		if (buf->large_tx_ipv6)
+			adapter->netdev->features |= NETIF_F_TSO6;
+	}
+
 	memset(&crq, 0, sizeof(crq));
 	crq.control_ip_offload.first = IBMVNIC_CRQ_CMD;
 	crq.control_ip_offload.cmd = CONTROL_IP_OFFLOAD;
-- 
1.8.3.1
