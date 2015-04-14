From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH 2/5] ibmveth: Add support for TSO
Date: Tue, 14 Apr 2015 15:35:01 -0500
Message-ID: <1429043704-22552-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1429043704-22552-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org,
	Brian King <brking@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:42017 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754570AbbDNUfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 16:35:09 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Tue, 14 Apr 2015 14:35:08 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id B1E171FF0025
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 14:26:17 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3EKZ60948300040
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 13:35:06 -0700
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3EKZ6FE014461
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 14:35:06 -0600
In-Reply-To: <1429043704-22552-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for TSO.  TSO is turned off by default and
must be enabled and configured by the user.  The driver
version number is increased so that users can be sure
that they are using ibmveth with TSO support.

Cc: Brian King <brking@linux.vnet.ibm.com>
Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmveth.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 0210622..2911a57 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -58,7 +58,7 @@ static struct kobj_type ktype_veth_pool;
 
 static const char ibmveth_driver_name[] = "ibmveth";
 static const char ibmveth_driver_string[] = "IBM Power Virtual Ethernet Driver";
-#define ibmveth_driver_version "1.04"
+#define ibmveth_driver_version "1.05"
 
 MODULE_AUTHOR("Santiago Leon <santil@linux.vnet.ibm.com>");
 MODULE_DESCRIPTION("IBM Power Virtual Ethernet Driver");
@@ -852,6 +852,10 @@ static int ibmveth_set_features(struct net_device *dev,
 	struct ibmveth_adapter *adapter = netdev_priv(dev);
 	int rx_csum = !!(features & NETIF_F_RXCSUM);
 	int rc;
+	netdev_features_t changed = features ^ dev->features;
+
+	if (features & NETIF_F_TSO & changed)
+		netdev_info(dev, "TSO feature requires all partitions to have updated driver");
 
 	if (rx_csum == adapter->rx_csum)
 		return 0;
@@ -1035,6 +1039,14 @@ retry_bounce:
 		descs[i+1].fields.address = dma_addr;
 	}
 
+	if (skb_is_gso(skb) && !skb_is_gso_v6(skb)) {
+		/* Put -1 in the IP checksum to tell phyp it
+		 *  is a largesend packet and put the mss in the TCP checksum.
+		 */
+		ip_hdr(skb)->check = 0xffff;
+		tcp_hdr(skb)->check = cpu_to_be16(skb_shinfo(skb)->gso_size);
+	}
+
 	if (ibmveth_send(adapter, descs)) {
 		adapter->tx_send_failed++;
 		netdev->stats.tx_dropped++;
@@ -1422,6 +1434,9 @@ static int ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
 	netdev->features |= netdev->hw_features;
 
+	/* TSO is disabled by default */
+	netdev->hw_features |= NETIF_F_TSO;
+
 	memcpy(netdev->dev_addr, mac_addr_p, ETH_ALEN);
 
 	if (firmware_has_feature(FW_FEATURE_CMO))
-- 
1.8.3.1
