From: Santiago Leon <santil@linux.vnet.ibm.com>
Subject: [patch 09/21] ibmveth: Remove duplicate checksum offload setup code
Date: Fri, 03 Sep 2010 23:28:47 -0500
Message-ID: <20100904042847.2655.3579.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
References: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Cc: brking@linux.vnet.ibm.com,
	Santiago Leon <santil@linux.vnet.ibm.com>, anton@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:39535 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752931Ab0IDE3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 00:29:16 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o844J0U1019679
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:19:00 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o844TF2k194598
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:29:15 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o844TEBr000539
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:29:14 -0600
In-Reply-To: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove code in the device probe function where we set up the checksum
offload feature and replace it with a call to an existing function that
is doing the same.  This is done to clean up the driver in preparation
of adding IPv6 checksum offload support.

Signed-off-by: Robert Jennings <rcj@linux.vnet.ibm.com>
Signed-off-by: Santiago Leon <santil@linux.vnet.ibm.com>
---

Index: b/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig//drivers/net/ibmveth.c	2010-09-03 22:18:57.000000000 -0500
+++ net-next-2.6/drivers/net/ibmveth.c	2010-09-03 22:18:57.000000000 -0500
@@ -1338,10 +1338,8 @@ static const struct net_device_ops ibmve
 static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
 {
 	int rc, i;
-	long ret;
 	struct net_device *netdev;
 	struct ibmveth_adapter *adapter;
-	unsigned long set_attr, ret_attr;
 
 	unsigned char *mac_addr_p;
 	unsigned int *mcastFilterSize_p;
@@ -1425,21 +1423,7 @@ static int __devinit ibmveth_probe(struc
 
 	ibmveth_debug_printk("registering netdev...\n");
 
-	ret = h_illan_attributes(dev->unit_address, 0, 0, &ret_attr);
-
-	if (ret == H_SUCCESS && !(ret_attr & IBMVETH_ILLAN_ACTIVE_TRUNK) &&
-	    !(ret_attr & IBMVETH_ILLAN_TRUNK_PRI_MASK) &&
-	    (ret_attr & IBMVETH_ILLAN_PADDED_PKT_CSUM)) {
-		set_attr = IBMVETH_ILLAN_IPV4_TCP_CSUM;
-
-		ret = h_illan_attributes(dev->unit_address, 0, set_attr, &ret_attr);
-
-		if (ret == H_SUCCESS) {
-			adapter->rx_csum = 1;
-			netdev->features |= NETIF_F_IP_CSUM;
-		} else
-			ret = h_illan_attributes(dev->unit_address, set_attr, 0, &ret_attr);
-	}
+	ibmveth_set_csum_offload(netdev, 1, ibmveth_set_tx_csum_flags);
 
 	rc = register_netdev(netdev);
 
