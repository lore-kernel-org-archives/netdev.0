From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net-next v3] ibmvnic: Enable TSO support
Date: Fri, 26 May 2017 11:15:46 -0500
Message-ID: <1495815346-5638-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: davem@davemloft.net, Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        Nathan Fontenot <nfont@linux.vnet.ibm.com>,
        John Allen <jallen@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:57293 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753037AbdEZQP4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 12:15:56 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4QGEllN050721
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 12:15:55 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2apknxba5a-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 12:15:55 -0400
Received: from localhost
        by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Fri, 26 May 2017 10:15:54 -0600
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
v3: Remove module parameter, TSO will be set through ethtool
    include ibmvnic_fix_features to manage scatter-gather
v2: Fix kbuild robot warning from module parameter init
---
 drivers/net/ethernet/ibm/ibmvnic.c | 42 +++++++++++++++++++++++++++++++++++---
 1 file changed, 39 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index abe2b6e..b1f4a95 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -149,6 +149,20 @@ struct ibmvnic_stat {
 	{"internal_mac_rx_errors", IBMVNIC_STAT_OFF(internal_mac_rx_errors)},
 };
 
+static netdev_features_t ibmvnic_fix_features(struct net_device *dev,
+					      netdev_features_t features)
+{
+	/* Scatter-gather is not currently supported by firmware.
+	 * It will only be enabled to support TSO operations.
+	 */
+	if (!(features & (NETIF_F_TSO | NETIF_F_TSO6)))
+		features &= ~NETIF_F_SG;
+	else
+		features |= NETIF_F_SG;
+
+	return features;
+}
+
 static long h_reg_sub_crq(unsigned long unit_address, unsigned long token,
 			  unsigned long length, unsigned long *number,
 			  unsigned long *irq)
@@ -1025,6 +1039,17 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
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
@@ -1082,6 +1107,11 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
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
@@ -1520,6 +1550,7 @@ static void ibmvnic_netpoll_controller(struct net_device *dev)
 	.ndo_set_mac_address	= ibmvnic_set_mac,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_tx_timeout		= ibmvnic_tx_timeout,
+	.ndo_fix_features	= ibmvnic_fix_features,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ibmvnic_netpoll_controller,
 #endif
@@ -2629,10 +2660,10 @@ static void handle_query_ip_offload_rsp(struct ibmvnic_adapter *adapter)
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
 
@@ -2648,6 +2679,11 @@ static void handle_query_ip_offload_rsp(struct ibmvnic_adapter *adapter)
 	    (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM)))
 		adapter->netdev->features |= NETIF_F_RXCSUM;
 
+	if (buf->large_tx_ipv4)
+		adapter->netdev->hw_features |= NETIF_F_TSO;
+	if (buf->large_tx_ipv6)
+		adapter->netdev->hw_features |= NETIF_F_TSO6;
+
 	memset(&crq, 0, sizeof(crq));
 	crq.control_ip_offload.first = IBMVNIC_CRQ_CMD;
 	crq.control_ip_offload.cmd = CONTROL_IP_OFFLOAD;
-- 
1.8.3.1
