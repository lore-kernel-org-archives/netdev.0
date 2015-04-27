From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net-next v2 4/4] ibmveth: Add support for Large Receive Offload
Date: Mon, 27 Apr 2015 17:10:55 -0500
Message-ID: <1430172655-17606-4-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1430172655-17606-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, nfont@linux.vnet.ibm.com,
	eric.dumazet@gmail.com, Brian King <brking@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:55482 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965246AbbD0WLG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 18:11:06 -0400
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Mon, 27 Apr 2015 16:11:06 -0600
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id AAF493E40047
	for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 16:11:04 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3RMAgDP34996346
	for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 15:10:42 -0700
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3RMB3SQ028891
	for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 16:11:04 -0600
In-Reply-To: <1430172655-17606-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enables receiving large packets from other LPARs. These packets
have a -1 IP header checksum, so we must recalculate to have
a valid checksum.

Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
v2: 
 -Included statistics that were previously in a separate patch
 -Zeroed the IP header checksum before calling ip_fast_csum
  Thanks to Eric Dumazet.

 drivers/net/ethernet/ibm/ibmveth.c | 19 ++++++++++++++++++-
 drivers/net/ethernet/ibm/ibmveth.h |  1 +
 2 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index f0ec4e5..3bab896 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -101,6 +101,7 @@ struct ibmveth_stat ibmveth_stats[] = {
 	{ "fw_enabled_ipv4_csum", IBMVETH_STAT_OFF(fw_ipv4_csum_support) },
 	{ "fw_enabled_ipv6_csum", IBMVETH_STAT_OFF(fw_ipv6_csum_support) },
 	{ "tx_large_packets", IBMVETH_STAT_OFF(tx_large_packets) },
+	{ "rx_large_packets", IBMVETH_STAT_OFF(rx_large_packets) }
 };
 
 /* simple methods of getting data from the current rxq entry */
@@ -1094,6 +1095,7 @@ static int ibmveth_poll(struct napi_struct *napi, int budget)
 	struct net_device *netdev = adapter->netdev;
 	int frames_processed = 0;
 	unsigned long lpar_rc;
+	struct iphdr *iph;
 
 restart_poll:
 	while (frames_processed < budget) {
@@ -1136,8 +1138,23 @@ restart_poll:
 			skb_put(skb, length);
 			skb->protocol = eth_type_trans(skb, netdev);
 
-			if (csum_good)
+			if (csum_good) {
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
+				if (be16_to_cpu(skb->protocol) == ETH_P_IP) {
+					skb_set_network_header(skb, 0);
+					skb_set_transport_header(skb, sizeof(struct iphdr));
+					iph = ip_hdr(skb);
+
+					/* If the IP checksum is not offloaded and if the packet
+					 *  is large send, the checksum must be rebuilt.
+					 */
+					if (iph->check == 0xffff) {
+						iph->check = 0;
+						iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
+						adapter->rx_large_packets++;
+					}
+				}
+			}
 
 			napi_gro_receive(napi, skb);	/* send it up */
 
diff --git a/drivers/net/ethernet/ibm/ibmveth.h b/drivers/net/ethernet/ibm/ibmveth.h
index 56d1e22..41dedb1 100644
--- a/drivers/net/ethernet/ibm/ibmveth.h
+++ b/drivers/net/ethernet/ibm/ibmveth.h
@@ -162,6 +162,7 @@ struct ibmveth_adapter {
     u64 tx_map_failed;
     u64 tx_send_failed;
     u64 tx_large_packets;
+    u64 rx_large_packets;
 };
 
 /*
-- 
1.9.3
