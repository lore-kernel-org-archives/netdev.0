From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH v3] ibmveth: Add function to enable live MAC address changes
Date: Mon,  2 Mar 2015 11:56:12 -0600
Message-ID: <1425318972-19455-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, brking@linux.vnet.ibm.com,
	jiri@resnulli.us, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:54028 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785AbbCBR4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 12:56:20 -0500
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Mon, 2 Mar 2015 10:56:19 -0700
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id CD1541FF0021
	for <netdev@vger.kernel.org>; Mon,  2 Mar 2015 10:47:27 -0700 (MST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t22HuUHt47382562
	for <netdev@vger.kernel.org>; Mon, 2 Mar 2015 10:56:30 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t22HuFWa030402
	for <netdev@vger.kernel.org>; Mon, 2 Mar 2015 10:56:15 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a function that will enable changing the MAC address
of an ibmveth interface while it is still running.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
v3:
   removed text wrapping in error message
v2:
   If h_change_logical_lan_mac fails, dev->dev_addr will not be changed.

 drivers/net/ethernet/ibm/ibmveth.c | 24 +++++++++++++++++++++++-
 1 file changed, 23 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 21978cc..072426a 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1327,6 +1327,28 @@ static unsigned long ibmveth_get_desired_dma(struct vio_dev *vdev)
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
+	mac_address = ibmveth_encode_mac_addr(addr->sa_data);
+	rc = h_change_logical_lan_mac(adapter->vdev->unit_address, mac_address);
+	if (rc) {
+		netdev_err(adapter->netdev, "h_change_logical_lan_mac failed with rc=%d\n", rc);
+		return rc;
+	}
+
+	ether_addr_copy(dev->dev_addr, addr->sa_data);
+
+	return 0;
+}
+
 static const struct net_device_ops ibmveth_netdev_ops = {
 	.ndo_open		= ibmveth_open,
 	.ndo_stop		= ibmveth_close,
@@ -1337,7 +1359,7 @@ static const struct net_device_ops ibmveth_netdev_ops = {
 	.ndo_fix_features	= ibmveth_fix_features,
 	.ndo_set_features	= ibmveth_set_features,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_set_mac_address    = ibmveth_set_mac_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ibmveth_poll_controller,
 #endif
-- 
1.8.3.1
