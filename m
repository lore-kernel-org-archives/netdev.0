From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: [PATCH 2/3] ibmveth: Enable IPv6 checksum offload
Date: Wed, 18 Aug 2010 11:07:38 -0500
Message-ID: <20100818160738.GB29528@linux.vnet.ibm.com>
References: <20100818160515.GA29528@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Santiago Leon <santil@linux.vnet.ibm.com>,
	Brian King <brking@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:42653 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753783Ab0HRQHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 12:07:40 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7IFwoTx023360
	for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 09:58:50 -0600
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o7IG7eVi219402
	for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 10:07:40 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7IG7dNH022091
	for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 10:07:39 -0600
Content-Disposition: inline
In-Reply-To: <20100818160515.GA29528@linux.vnet.ibm.com>
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

---
 drivers/net/ibmveth.c |   59 +++++++++++++++++++++++++++++++++++++++++---------
 drivers/net/ibmveth.h |    2 ++
 2 files changed, 50 insertions(+), 11 deletions(-)

Index: b/drivers/net/ibmveth.c
===================================================================
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -50,6 +50,7 @@
 #include <linux/proc_fs.h>
 #include <linux/in.h>
 #include <linux/ip.h>
+#include <linux/ipv6.h>
 #include <linux/slab.h>
 #include <net/net_namespace.h>
 #include <asm/hvcall.h>
@@ -134,6 +135,8 @@ struct ibmveth_stat ibmveth_stats[] = {
 	{ "rx_no_buffer", IBMVETH_STAT_OFF(rx_no_buffer) },
 	{ "tx_map_failed", IBMVETH_STAT_OFF(tx_map_failed) },
 	{ "tx_send_failed", IBMVETH_STAT_OFF(tx_send_failed) },
+	{ "fw_enabled_ipv4_csum", IBMVETH_STAT_OFF(fw_ipv4_csum_support) },
+	{ "fw_enabled_ipv6_csum", IBMVETH_STAT_OFF(fw_ipv6_csum_support) },
 };
 
 /* simple methods of getting data from the current rxq entry */
@@ -739,6 +742,7 @@ static void ibmveth_set_rx_csum_flags(st
 		 */
 		adapter->rx_csum = 0;
 		dev->features &= ~NETIF_F_IP_CSUM;
+		dev->features &= ~NETIF_F_IPV6_CSUM;
 	}
 }
 
@@ -747,10 +751,15 @@ static void ibmveth_set_tx_csum_flags(st
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
@@ -758,7 +767,8 @@ static int ibmveth_set_csum_offload(stru
 {
 	struct ibmveth_adapter *adapter = netdev_priv(dev);
 	unsigned long set_attr, clr_attr, ret_attr;
-	long ret;
+	unsigned long set_attr6, clr_attr6;
+	long ret, ret6;
 	int rc1 = 0, rc2 = 0;
 	int restart = 0;
 
@@ -772,10 +782,13 @@ static int ibmveth_set_csum_offload(stru
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
 
@@ -786,14 +799,33 @@ static int ibmveth_set_csum_offload(stru
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
@@ -821,9 +853,9 @@ static int ibmveth_set_tx_csum(struct ne
 	struct ibmveth_adapter *adapter = netdev_priv(dev);
 	int rc = 0;
 
-	if (data && (dev->features & NETIF_F_IP_CSUM))
+	if (data && (dev->features & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM)))
 		return 0;
-	if (!data && !(dev->features & NETIF_F_IP_CSUM))
+	if (!data && !(dev->features & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM)))
 		return 0;
 
 	if (data && !adapter->rx_csum)
@@ -910,7 +942,12 @@ static netdev_tx_t ibmveth_start_xmit(st
 	desc.fields.flags_len = IBMVETH_BUF_VALID | skb->len;
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL &&
-	    ip_hdr(skb)->protocol != IPPROTO_TCP && skb_checksum_help(skb)) {
+	    ((skb->protocol == htons(ETH_P_IP) &&
+	      ip_hdr(skb)->protocol != IPPROTO_TCP) ||
+	     (skb->protocol == htons(ETH_P_IPV6) &&
+	      ipv6_hdr(skb)->nexthdr != IPPROTO_TCP)) &&
+	    skb_checksum_help(skb)) {
+
 		ibmveth_error_printk("tx: failed to checksum packet\n");
 		tx_dropped++;
 		goto out;
Index: b/drivers/net/ibmveth.h
===================================================================
--- a/drivers/net/ibmveth.h
+++ b/drivers/net/ibmveth.h
@@ -149,6 +149,8 @@ struct ibmveth_adapter {
     void *bounce_buffer;
     dma_addr_t bounce_buffer_dma;
 
+    u64 fw_ipv6_csum_support;
+    u64 fw_ipv4_csum_support;
     /* adapter specific stats */
     u64 replenish_task_cycles;
     u64 replenish_no_mem;
