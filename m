From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net-next v3 2/4] ibmveth: Add support for TSO
Date: Wed, 29 Apr 2015 16:25:45 -0500
Message-ID: <1430342747-16774-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1430342747-16774-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, nfont@linux.vnet.ibm.com,
	eric.dumazet@gmail.com, Brian King <brking@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:39568 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbbD2VZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 17:25:54 -0400
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Wed, 29 Apr 2015 15:25:54 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id A56193E40047
	for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 15:25:52 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3TLNrWQ29425760
	for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 14:23:53 -0700
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3TLPoCg021621
	for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 15:25:52 -0600
In-Reply-To: <1430342747-16774-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for TSO.  TSO is turned off by default and
must be enabled and configured by the user.  The driver
version number is increased so that users can be sure
that they are using ibmveth with TSO support.

Cc: Brian King <brking@linux.vnet.ibm.com>
Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
v2: Included statistics that were previously in a separate patch

 drivers/net/ethernet/ibm/ibmveth.c | 19 ++++++++++++++++++-
 drivers/net/ethernet/ibm/ibmveth.h |  1 +
 2 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 0210622..25cfc26 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -58,7 +58,7 @@ static struct kobj_type ktype_veth_pool;
 
 static const char ibmveth_driver_name[] = "ibmveth";
 static const char ibmveth_driver_string[] = "IBM Power Virtual Ethernet Driver";
-#define ibmveth_driver_version "1.04"
+#define ibmveth_driver_version "1.05"
 
 MODULE_AUTHOR("Santiago Leon <santil@linux.vnet.ibm.com>");
 MODULE_DESCRIPTION("IBM Power Virtual Ethernet Driver");
@@ -100,6 +100,7 @@ struct ibmveth_stat ibmveth_stats[] = {
 	{ "tx_send_failed", IBMVETH_STAT_OFF(tx_send_failed) },
 	{ "fw_enabled_ipv4_csum", IBMVETH_STAT_OFF(fw_ipv4_csum_support) },
 	{ "fw_enabled_ipv6_csum", IBMVETH_STAT_OFF(fw_ipv6_csum_support) },
+	{ "tx_large_packets", IBMVETH_STAT_OFF(tx_large_packets) },
 };
 
 /* simple methods of getting data from the current rxq entry */
@@ -852,6 +853,10 @@ static int ibmveth_set_features(struct net_device *dev,
 	struct ibmveth_adapter *adapter = netdev_priv(dev);
 	int rx_csum = !!(features & NETIF_F_RXCSUM);
 	int rc;
+	netdev_features_t changed = features ^ dev->features;
+
+	if (features & NETIF_F_TSO & changed)
+		netdev_info(dev, "TSO feature requires all partitions to have updated driver");
 
 	if (rx_csum == adapter->rx_csum)
 		return 0;
@@ -1035,6 +1040,15 @@ retry_bounce:
 		descs[i+1].fields.address = dma_addr;
 	}
 
+	if (skb_is_gso(skb) && !skb_is_gso_v6(skb)) {
+		/* Put -1 in the IP checksum to tell phyp it
+		 *  is a largesend packet and put the mss in the TCP checksum.
+		 */
+		ip_hdr(skb)->check = 0xffff;
+		tcp_hdr(skb)->check = cpu_to_be16(skb_shinfo(skb)->gso_size);
+		adapter->tx_large_packets++;
+	}
+
 	if (ibmveth_send(adapter, descs)) {
 		adapter->tx_send_failed++;
 		netdev->stats.tx_dropped++;
@@ -1422,6 +1436,9 @@ static int ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
 	netdev->features |= netdev->hw_features;
 
+	/* TSO is disabled by default */
+	netdev->hw_features |= NETIF_F_TSO;
+
 	memcpy(netdev->dev_addr, mac_addr_p, ETH_ALEN);
 
 	if (firmware_has_feature(FW_FEATURE_CMO))
diff --git a/drivers/net/ethernet/ibm/ibmveth.h b/drivers/net/ethernet/ibm/ibmveth.h
index 0dc664b..56d1e22 100644
--- a/drivers/net/ethernet/ibm/ibmveth.h
+++ b/drivers/net/ethernet/ibm/ibmveth.h
@@ -161,6 +161,7 @@ struct ibmveth_adapter {
     u64 rx_no_buffer;
     u64 tx_map_failed;
     u64 tx_send_failed;
+    u64 tx_large_packets;
 };
 
 /*
-- 
1.9.3
