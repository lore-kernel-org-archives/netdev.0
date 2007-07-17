From: Brian King <brking@linux.vnet.ibm.com>
Subject: [PATCH 2/4] ibmveth: Implement ethtool hooks to enable/disable checksum offload
Date: Tue, 17 Jul 2007 10:17:58 -0500
Message-ID: <200707171517.l6HFHwf2015030@d03av04.boulder.ibm.com>
References: <11846854701127-patch-mail.ibm.com>
Cc: rcjenn@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, brking@linux.vnet.ibm.com
To: santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:39530 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753082AbXGQPSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 11:18:00 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6HFHx67015318
	for <netdev@vger.kernel.org>; Tue, 17 Jul 2007 11:17:59 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6HFHxNx256880
	for <netdev@vger.kernel.org>; Tue, 17 Jul 2007 09:17:59 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6HFHx0V015084
	for <netdev@vger.kernel.org>; Tue, 17 Jul 2007 09:17:59 -0600
In-Reply-To: <11846854701127-patch-mail.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch adds the appropriate ethtool hooks to allow for enabling/disabling
of hypervisor assisted checksum offload for TCP.

Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
---

 linux-2.6-bjking1/drivers/net/ibmveth.c |  120 +++++++++++++++++++++++++++++++-
 linux-2.6-bjking1/drivers/net/ibmveth.h |    1 
 2 files changed, 119 insertions(+), 2 deletions(-)

diff -puN drivers/net/ibmveth.c~ibmveth_csum_offload_ethtool drivers/net/ibmveth.c
--- linux-2.6/drivers/net/ibmveth.c~ibmveth_csum_offload_ethtool	2007-07-12 09:36:01.000000000 -0500
+++ linux-2.6-bjking1/drivers/net/ibmveth.c	2007-07-12 09:41:15.000000000 -0500
@@ -644,12 +644,127 @@ static u32 netdev_get_link(struct net_de
 	return 1;
 }
 
+static void ibmveth_set_rx_csum_flags(struct net_device *dev, u32 data)
+{
+	struct ibmveth_adapter *adapter = dev->priv;
+
+	if (data)
+		adapter->rx_csum = 1;
+	else {
+		adapter->rx_csum = 0;
+		dev->features &= ~NETIF_F_IP_CSUM;
+	}
+}
+
+static void ibmveth_set_tx_csum_flags(struct net_device *dev, u32 data)
+{
+	struct ibmveth_adapter *adapter = dev->priv;
+
+	if (data) {
+		dev->features |= NETIF_F_IP_CSUM;
+		adapter->rx_csum = 1;
+	} else
+		dev->features &= ~NETIF_F_IP_CSUM;
+}
+
+static int ibmveth_set_csum_offload(struct net_device *dev, u32 data,
+				    void (*done) (struct net_device *, u32))
+{
+	struct ibmveth_adapter *adapter = dev->priv;
+	union ibmveth_illan_attributes set_attr, clr_attr, ret_attr;
+	long ret;
+	int rc1 = 0, rc2 = 0;
+	int restart = 0;
+
+	if (netif_running(dev)) {
+		restart = 1;
+		adapter->pool_config = 1;
+		ibmveth_close(dev);
+		adapter->pool_config = 0;
+	}
+
+	set_attr.desc = 0;
+	clr_attr.desc = 0;
+
+	if (data)
+		set_attr.fields.tcp_csum_offload_ipv4 = 1;
+	else
+		clr_attr.fields.tcp_csum_offload_ipv4 = 1;
+
+	ret = h_illan_attributes(adapter->vdev->unit_address, 0, 0, &ret_attr.desc);
+
+	if (ret == H_SUCCESS && !ret_attr.fields.active_trunk &&
+	    !ret_attr.fields.trunk_priority &&
+	    ret_attr.fields.csum_offload_padded_pkt_support) {
+		ret = h_illan_attributes(adapter->vdev->unit_address, clr_attr.desc,
+					 set_attr.desc, &ret_attr.desc);
+
+		if (ret != H_SUCCESS) {
+			rc1 = -EIO;
+			ibmveth_error_printk("unable to change checksum offload settings."
+					     " %d rc=%ld\n", data, ret);
+
+			ret = h_illan_attributes(adapter->vdev->unit_address,
+						 set_attr.desc, clr_attr.desc, &ret_attr.desc);
+		} else
+			done(dev, data);
+	} else {
+		rc1 = -EIO;
+		ibmveth_error_printk("unable to change checksum offload settings."
+				     " %d rc=%ld ret_attr=%lx\n", data, ret, ret_attr.desc);
+	}
+
+	if (restart)
+		rc2 = ibmveth_open(dev);
+
+	return rc1 ? rc1 : rc2;
+}
+
+static int ibmveth_set_rx_csum(struct net_device *dev, u32 data)
+{
+	struct ibmveth_adapter *adapter = dev->priv;
+
+	if (data && adapter->rx_csum)
+		return 0;
+	if (!data && !adapter->rx_csum)
+		return 0;
+
+	return ibmveth_set_csum_offload(dev, data, ibmveth_set_rx_csum_flags);
+}
+
+static int ibmveth_set_tx_csum(struct net_device *dev, u32 data)
+{
+	struct ibmveth_adapter *adapter = dev->priv;
+	int rc = 0;
+
+	if (data && (dev->features & NETIF_F_IP_CSUM))
+		return 0;
+	if (!data && !(dev->features & NETIF_F_IP_CSUM))
+		return 0;
+
+	if (data && !adapter->rx_csum)
+		rc = ibmveth_set_csum_offload(dev, data, ibmveth_set_tx_csum_flags);
+	else
+		ibmveth_set_tx_csum_flags(dev, data);
+
+	return rc;
+}
+
+static u32 ibmveth_get_rx_csum(struct net_device *dev)
+{
+	struct ibmveth_adapter *adapter = dev->priv;
+	return adapter->rx_csum;
+}
+
 static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo		= netdev_get_drvinfo,
 	.get_settings		= netdev_get_settings,
 	.get_link		= netdev_get_link,
 	.get_sg			= ethtool_op_get_sg,
 	.get_tx_csum		= ethtool_op_get_tx_csum,
+	.set_tx_csum		= ibmveth_set_tx_csum,
+	.get_rx_csum		= ibmveth_get_rx_csum,
+	.set_rx_csum		= ibmveth_set_rx_csum
 };
 
 static int ibmveth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
@@ -1108,9 +1223,10 @@ static int __devinit ibmveth_probe(struc
 			ret = h_illan_attributes(dev->unit_address, 0, set_attr.desc,
 						 &ret_attr.desc);
 
-			if (ret == H_SUCCESS)
+			if (ret == H_SUCCESS) {
+				adapter->rx_csum = 1;
 				netdev->features |= NETIF_F_IP_CSUM;
-			else
+			} else
 				ret = h_illan_attributes(dev->unit_address, set_attr.desc,
 							 0, &ret_attr.desc);
 		}
diff -puN drivers/net/ibmveth.h~ibmveth_csum_offload_ethtool drivers/net/ibmveth.h
--- linux-2.6/drivers/net/ibmveth.h~ibmveth_csum_offload_ethtool	2007-07-12 09:36:01.000000000 -0500
+++ linux-2.6-bjking1/drivers/net/ibmveth.h	2007-07-12 09:36:01.000000000 -0500
@@ -140,6 +140,7 @@ struct ibmveth_adapter {
     struct ibmveth_buff_pool rx_buff_pool[IbmVethNumBufferPools];
     struct ibmveth_rx_q rx_queue;
     int pool_config;
+    int rx_csum;
 
     /* adapter specific stats */
     u64 replenish_task_cycles;
_
