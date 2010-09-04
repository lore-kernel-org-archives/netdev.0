From: Santiago Leon <santil@linux.vnet.ibm.com>
Subject: [patch 10/21] ibmveth: Enable IPv6 checksum offload
Date: Fri, 03 Sep 2010 23:28:52 -0500
Message-ID: <20100904042852.2655.32420.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
References: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Cc: brking@linux.vnet.ibm.com,
	Santiago Leon <santil@linux.vnet.ibm.com>, anton@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:41718 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752931Ab0IDE3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 00:29:21 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o844RJuZ004067
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:27:19 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o844TKHj219130
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:29:20 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o844TK0G000732
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:29:20 -0600
In-Reply-To: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables TCP checksum offload support for IPv6 on ibmveth.
This completely eliminates the generation and checking of the checksum
for IPv6 packets that are completely virtual and never touch a physical
network.  A basic TCPIPV6_STREAM netperf run showed a ~30% throughput
improvement when an MTU of 64000 was used.

This featured is enabled by default, as is the case for IPv4 checksum
offload.  When checksum offload is enabled the driver will negotiate
IPv4 and IPv6 offload with the firmware separately and enable what
is available.  As long as either IPv4 or IPv6 offload is supported
and enabled the device will report that checksum offload is enabled.
The device stats, available through ethtool, will display which 
checksum offload features are supported/enabled by firmware.

Performance testing against a stock kernel shows no regression for IPv4
or IPv6 in terms of throughput or processor utilization with checksum
disabled or enabled.  

Signed-off-by: Robert Jennings <rcj@linux.vnet.ibm.com>
Signed-off-by: Santiago Leon <santil@linux.vnet.ibm.com>
---

Index: b/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig//drivers/net/ibmveth.c	2010-09-03 22:18:59.000000000 -0500
+++ net-next-2.6/drivers/net/ibmveth.c	2010-09-03 22:19:00.000000000 -0500
@@ -50,6 +50,7 @@
 #include <linux/proc_fs.h>
 #include <linux/in.h>
 #include <linux/ip.h>
+#include <linux/ipv6.h>
 #include <linux/slab.h>
 #include <net/net_namespace.h>
 #include <asm/hvcall.h>
@@ -148,6 +149,8 @@ struct ibmveth_stat ibmveth_stats[] = {
 	{ "rx_no_buffer", IBMVETH_STAT_OFF(rx_no_buffer) },
 	{ "tx_map_failed", IBMVETH_STAT_OFF(tx_map_failed) },
 	{ "tx_send_failed", IBMVETH_STAT_OFF(tx_send_failed) },
+	{ "fw_enabled_ipv4_csum", IBMVETH_STAT_OFF(fw_ipv4_csum_support) },
+	{ "fw_enabled_ipv6_csum", IBMVETH_STAT_OFF(fw_ipv6_csum_support) },
 };
 
 /* simple methods of getting data from the current rxq entry */
@@ -773,6 +776,7 @@ static void ibmveth_set_rx_csum_flags(st
 		 */
 		adapter->rx_csum = 0;
 		dev->features &= ~NETIF_F_IP_CSUM;
+		dev->features &= ~NETIF_F_IPV6_CSUM;
 	}
 }
 
@@ -781,10 +785,15 @@ static void ibmveth_set_tx_csum_flags(st
 	struct ibmveth_adapter *adapter = netdev_priv(dev);
 
 	if (data) {
-		dev->features |= NETIF_F_IP_CSUM;
+		if (adapter->fw_ipv4_csum_support)
+			dev->features |= NETIF_F_IP_CSUM;
+		if (adapter->fw_ipv6_csum_support)
+			dev->features |= NETIF_F_IPV6_CSUM;
 		adapter->rx_csum = 1;
-	} else
+	} else {
 		dev->features &= ~NETIF_F_IP_CSUM;
+		dev->features &= ~NETIF_F_IPV6_CSUM;
+	}
 }
 
 static int ibmveth_set_csum_offload(struct net_device *dev, u32 data,
@@ -792,7 +801,8 @@ static int ibmveth_set_csum_offload(stru
 {
 	struct ibmveth_adapter *adapter = netdev_priv(dev);
 	unsigned long set_attr, clr_attr, ret_attr;
-	long ret;
+	unsigned long set_attr6, clr_attr6;
+	long ret, ret6;
 	int rc1 = 0, rc2 = 0;
 	int restart = 0;
 
@@ -806,10 +816,13 @@ static int ibmveth_set_csum_offload(stru
 	set_attr = 0;
 	clr_attr = 0;
 
-	if (data)
+	if (data) {
 		set_attr = IBMVETH_ILLAN_IPV4_TCP_CSUM;
-	else
+		set_attr6 = IBMVETH_ILLAN_IPV6_TCP_CSUM;
+	} else {
 		clr_attr = IBMVETH_ILLAN_IPV4_TCP_CSUM;
+		clr_attr6 = IBMVETH_ILLAN_IPV6_TCP_CSUM;
+	}
 
 	ret = h_illan_attributes(adapter->vdev->unit_address, 0, 0, &ret_attr);
 
@@ -820,14 +833,33 @@ static int ibmveth_set_csum_offload(stru
 					 set_attr, &ret_attr);
 
 		if (ret != H_SUCCESS) {
-			rc1 = -EIO;
-			ibmveth_error_printk("unable to change checksum offload settings."
-					     " %d rc=%ld\n", data, ret);
+			ibmveth_error_printk("unable to change IPv4 checksum "
+					     "offload settings. %d rc=%ld\n",
+					     data, ret);
 
 			ret = h_illan_attributes(adapter->vdev->unit_address,
 						 set_attr, clr_attr, &ret_attr);
 		} else
+			adapter->fw_ipv4_csum_support = data;
+
+		ret6 = h_illan_attributes(adapter->vdev->unit_address,
+					 clr_attr6, set_attr6, &ret_attr);
+
+		if (ret6 != H_SUCCESS) {
+			ibmveth_error_printk("unable to change IPv6 checksum "
+					     "offload settings. %d rc=%ld\n",
+					     data, ret);
+
+			ret = h_illan_attributes(adapter->vdev->unit_address,
+						 set_attr6, clr_attr6,
+						 &ret_attr);
+		} else
+			adapter->fw_ipv6_csum_support = data;
+
+		if (ret == H_SUCCESS || ret6 == H_SUCCESS)
 			done(dev, data);
+		else
+			rc1 = -EIO;
 	} else {
 		rc1 = -EIO;
 		ibmveth_error_printk("unable to change checksum offload settings."
@@ -855,9 +887,9 @@ static int ibmveth_set_tx_csum(struct ne
 	struct ibmveth_adapter *adapter = netdev_priv(dev);
 	int rc = 0;
 
-	if (data && (dev->features & NETIF_F_IP_CSUM))
+	if (data && (dev->features & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM)))
 		return 0;
-	if (!data && !(dev->features & NETIF_F_IP_CSUM))
+	if (!data && !(dev->features & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM)))
 		return 0;
 
 	if (data && !adapter->rx_csum)
@@ -975,7 +1007,12 @@ static netdev_tx_t ibmveth_start_xmit(st
 
 	/* veth can't checksum offload UDP */
 	if (skb->ip_summed == CHECKSUM_PARTIAL &&
-	    ip_hdr(skb)->protocol != IPPROTO_TCP && skb_checksum_help(skb)) {
+	    ((skb->protocol == htons(ETH_P_IP) &&
+	      ip_hdr(skb)->protocol != IPPROTO_TCP) ||
+	     (skb->protocol == htons(ETH_P_IPV6) &&
+	      ipv6_hdr(skb)->nexthdr != IPPROTO_TCP)) &&
+	    skb_checksum_help(skb)) {
+
 		ibmveth_error_printk("tx: failed to checksum packet\n");
 		netdev->stats.tx_dropped++;
 		goto out;
Index: b/drivers/net/ibmveth.h
===================================================================
--- net-next-2.6.orig//drivers/net/ibmveth.h	2010-09-03 22:18:42.000000000 -0500
+++ net-next-2.6/drivers/net/ibmveth.h	2010-09-03 22:19:00.000000000 -0500
@@ -149,6 +149,8 @@ struct ibmveth_adapter {
     void *bounce_buffer;
     dma_addr_t bounce_buffer_dma;
 
+    u64 fw_ipv6_csum_support;
+    u64 fw_ipv4_csum_support;
     /* adapter specific stats */
     u64 replenish_task_cycles;
     u64 replenish_no_mem;
