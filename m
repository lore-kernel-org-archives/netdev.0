From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 4/4] ibmveth: Fix checksum offload failure handling
Date: Thu, 08 Sep 2011 10:41:06 +1000
Message-ID: <20110908004121.819855965@samba.org>
References: <20110908004102.355674129@samba.org>
Cc: netdev@vger.kernel.org
To: Santiago Leon <santil@linux.vnet.ibm.com>,
	brking@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com,
	mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:60652 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757662Ab1IHAp1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Sep 2011 20:45:27 -0400
Content-Disposition: inline; filename=ibmveth_fix_csum2.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a number of issues in ibmveth_set_csum_offload:

- set_attr6 and clr_attr6 may be used uninitialised

- We store the result of the IPV4 checksum change in ret but overwrite
  it in a couple of places before checking it again later. Add ret4
  to make it obvious what we are doing.

- We weren't clearing the NETIF_F_IP_CSUM and NETIF_F_IPV6_CSUM flags
  if the enable of that hypervisor feature failed.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

This patch could do with some review and I haven't marked it -stable
yet.

One thing that stands out is that we need to return an error back
through set_features if any feature bit gets changed.

Index: linux-build/drivers/net/ibmveth.c
===================================================================
--- linux-build.orig/drivers/net/ibmveth.c	2011-09-01 16:06:19.000000000 +1000
+++ linux-build/drivers/net/ibmveth.c	2011-09-02 09:05:57.585353722 +1000
@@ -757,7 +757,7 @@ static int ibmveth_set_csum_offload(stru
 	struct ibmveth_adapter *adapter = netdev_priv(dev);
 	unsigned long set_attr, clr_attr, ret_attr;
 	unsigned long set_attr6, clr_attr6;
-	long ret, ret6;
+	long ret, ret4, ret6;
 	int rc1 = 0, rc2 = 0;
 	int restart = 0;
 
@@ -770,6 +770,8 @@ static int ibmveth_set_csum_offload(stru
 
 	set_attr = 0;
 	clr_attr = 0;
+	set_attr6 = 0;
+	clr_attr6 = 0;
 
 	if (data) {
 		set_attr = IBMVETH_ILLAN_IPV4_TCP_CSUM;
@@ -784,16 +786,20 @@ static int ibmveth_set_csum_offload(stru
 	if (ret == H_SUCCESS && !(ret_attr & IBMVETH_ILLAN_ACTIVE_TRUNK) &&
 	    !(ret_attr & IBMVETH_ILLAN_TRUNK_PRI_MASK) &&
 	    (ret_attr & IBMVETH_ILLAN_PADDED_PKT_CSUM)) {
-		ret = h_illan_attributes(adapter->vdev->unit_address, clr_attr,
+		ret4 = h_illan_attributes(adapter->vdev->unit_address, clr_attr,
 					 set_attr, &ret_attr);
 
-		if (ret != H_SUCCESS) {
+		if (ret4 != H_SUCCESS) {
 			netdev_err(dev, "unable to change IPv4 checksum "
 					"offload settings. %d rc=%ld\n",
-					data, ret);
+					data, ret4);
+
+			h_illan_attributes(adapter->vdev->unit_address,
+					   set_attr, clr_attr, &ret_attr);
+
+			if (data == 1)
+				dev->features &= ~NETIF_F_IP_CSUM;
 
-			ret = h_illan_attributes(adapter->vdev->unit_address,
-						 set_attr, clr_attr, &ret_attr);
 		} else {
 			adapter->fw_ipv4_csum_support = data;
 		}
@@ -804,15 +810,18 @@ static int ibmveth_set_csum_offload(stru
 		if (ret6 != H_SUCCESS) {
 			netdev_err(dev, "unable to change IPv6 checksum "
 					"offload settings. %d rc=%ld\n",
-					data, ret);
+					data, ret6);
+
+			h_illan_attributes(adapter->vdev->unit_address,
+					   set_attr6, clr_attr6, &ret_attr);
+
+			if (data == 1)
+				dev->features &= ~NETIF_F_IPV6_CSUM;
 
-			ret = h_illan_attributes(adapter->vdev->unit_address,
-						 set_attr6, clr_attr6,
-						 &ret_attr);
 		} else
 			adapter->fw_ipv6_csum_support = data;
 
-		if (ret == H_SUCCESS || ret6 == H_SUCCESS)
+		if (ret4 == H_SUCCESS || ret6 == H_SUCCESS)
 			adapter->rx_csum = data;
 		else
 			rc1 = -EIO;
