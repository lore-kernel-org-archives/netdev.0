From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH 5/5] ibmveth: Add ethtool statistics for tx and rx large packets
Date: Tue, 14 Apr 2015 15:35:04 -0500
Message-ID: <1429043704-22552-5-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1429043704-22552-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org,
	Brian King <brking@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:59435 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754641AbbDNUfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 16:35:13 -0400
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Tue, 14 Apr 2015 14:35:12 -0600
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 68DA83E40048
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 14:35:10 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3EKYqtS33292494
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 13:34:52 -0700
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3EKZ9gC014775
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 14:35:10 -0600
In-Reply-To: <1429043704-22552-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch includes counters for transmitted and received large
packets.

Cc: Brian King <brking@linux.vnet.ibm.com>
Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmveth.c | 4 ++++
 drivers/net/ethernet/ibm/ibmveth.h | 2 ++
 2 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 05eaca6a..39ab41e 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -100,6 +100,8 @@ struct ibmveth_stat ibmveth_stats[] = {
 	{ "tx_send_failed", IBMVETH_STAT_OFF(tx_send_failed) },
 	{ "fw_enabled_ipv4_csum", IBMVETH_STAT_OFF(fw_ipv4_csum_support) },
 	{ "fw_enabled_ipv6_csum", IBMVETH_STAT_OFF(fw_ipv6_csum_support) },
+	{ "tx_large_packets", IBMVETH_STAT_OFF(tx_large_packets) },
+	{ "rx_large_packets", IBMVETH_STAT_OFF(rx_large_packets) }
 };
 
 /* simple methods of getting data from the current rxq entry */
@@ -1045,6 +1047,7 @@ retry_bounce:
 		 */
 		ip_hdr(skb)->check = 0xffff;
 		tcp_hdr(skb)->check = cpu_to_be16(skb_shinfo(skb)->gso_size);
+		adapter->tx_large_packets++;
 	}
 
 	if (ibmveth_send(adapter, descs)) {
@@ -1147,6 +1150,7 @@ restart_poll:
 					 */
 					if (iph->check == 0xffff)
 						iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
+						adapter->rx_large_packets++;
 				}
 			}
 
diff --git a/drivers/net/ethernet/ibm/ibmveth.h b/drivers/net/ethernet/ibm/ibmveth.h
index 0dc664b..41dedb1 100644
--- a/drivers/net/ethernet/ibm/ibmveth.h
+++ b/drivers/net/ethernet/ibm/ibmveth.h
@@ -161,6 +161,8 @@ struct ibmveth_adapter {
     u64 rx_no_buffer;
     u64 tx_map_failed;
     u64 tx_send_failed;
+    u64 tx_large_packets;
+    u64 rx_large_packets;
 };
 
 /*
-- 
1.8.3.1
