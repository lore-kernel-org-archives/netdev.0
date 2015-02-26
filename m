From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH] ibmveth: Add function to enable live MAC address changes
Date: Wed, 25 Feb 2015 18:34:24 -0600
Message-ID: <1424910864-32266-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:40414 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752868AbbBZAf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 19:35:26 -0500
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Wed, 25 Feb 2015 17:35:25 -0700
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 9A39819D803F
	for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 17:26:31 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t1Q0ZFhZ36110366
	for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 17:35:23 -0700
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t1Q0YonR022317
	for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 17:34:50 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a function that will enable changing the MAC address
of an ibmveth interface while it is still running.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmveth.c | 20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 21978cc..6e44357 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1327,6 +1327,24 @@ static unsigned long ibmveth_get_desired_dma(struct vio_dev *vdev)
 	return ret;
 }
 
+static int ibmveth_set_mac_addr(struct net_device *dev, void *p)
+{
+	struct ibmveth_adapter *adapter = netdev_priv(dev);
+	struct sockaddr *addr = p;
+	u64 mac_address;
+	int rc;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	ether_addr_copy(dev->dev_addr, addr->sa_data);
+
+	mac_address = ibmveth_encode_mac_addr(dev->dev_addr);
+	rc = h_change_logical_lan_mac(adapter->vdev->unit_address, mac_address);
+
+	return rc;
+}
+
 static const struct net_device_ops ibmveth_netdev_ops = {
 	.ndo_open		= ibmveth_open,
 	.ndo_stop		= ibmveth_close,
@@ -1337,7 +1355,7 @@ static const struct net_device_ops ibmveth_netdev_ops = {
 	.ndo_fix_features	= ibmveth_fix_features,
 	.ndo_set_features	= ibmveth_set_features,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_set_mac_address    = ibmveth_set_mac_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ibmveth_poll_controller,
 #endif
-- 
1.9.3
