From: Anton Blanchard <anton@samba.org>
Subject: ibmveth: Fix endian issues with MAC addresses
Date: Wed, 5 Mar 2014 14:51:37 +1100
Message-ID: <20140305145137.3460dbe7@kryten>
References: <1387762163-39662-1-git-send-email-agraf@suse.de>
	<20131223173833.0a9a6705@kryten>
	<1387810329.22671.66.camel@joe-AO722>
	<20131224125529.58970f1b@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>, Alexander Graf <agraf@suse.de>,
	Ben Herrenschmidt <benh@kernel.crashing.org>,
	Dinar Valeev <dvaleev@suse.com>,
	Santiago Leon <santil@linux.vnet.ibm.com>,
	tony@bakeyournoodle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38760 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756752AbaCEDvj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2014 22:51:39 -0500
In-Reply-To: <20131224125529.58970f1b@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The code to load a MAC address into a u64 for passing to the
hypervisor via a register is broken on little endian.

Create a helper function called ibmveth_encode_mac_addr
which does the right thing in both big and little endian.

We were storing the MAC address in a long in struct ibmveth_adapter.
It's never used so remove it - we don't need another place in the
driver where we create endian issues with MAC addresses.

Signed-off-by: Anton Blanchard <anton@samba.org>
Cc: stable@vger.kernel.org
---

Index: b/drivers/net/ethernet/ibm/ibmveth.c
===================================================================
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -522,10 +522,21 @@ retry:
 	return rc;
 }
 
+static u64 ibmveth_encode_mac_addr(u8 *mac)
+{
+	int i;
+	u64 encoded = 0;
+
+	for (i = 0; i < ETH_ALEN; i++)
+		encoded = (encoded << 8) | mac[i];
+
+	return encoded;
+}
+
 static int ibmveth_open(struct net_device *netdev)
 {
 	struct ibmveth_adapter *adapter = netdev_priv(netdev);
-	u64 mac_address = 0;
+	u64 mac_address;
 	int rxq_entries = 1;
 	unsigned long lpar_rc;
 	int rc;
@@ -579,8 +590,7 @@ static int ibmveth_open(struct net_devic
 	adapter->rx_queue.num_slots = rxq_entries;
 	adapter->rx_queue.toggle = 1;
 
-	memcpy(&mac_address, netdev->dev_addr, netdev->addr_len);
-	mac_address = mac_address >> 16;
+	mac_address = ibmveth_encode_mac_addr(netdev->dev_addr);
 
 	rxq_desc.fields.flags_len = IBMVETH_BUF_VALID |
 					adapter->rx_queue.queue_len;
@@ -1183,8 +1193,8 @@ static void ibmveth_set_multicast_list(s
 		/* add the addresses to the filter table */
 		netdev_for_each_mc_addr(ha, netdev) {
 			/* add the multicast address to the filter table */
-			unsigned long mcast_addr = 0;
-			memcpy(((char *)&mcast_addr)+2, ha->addr, ETH_ALEN);
+			u64 mcast_addr;
+			mcast_addr = ibmveth_encode_mac_addr(ha->addr);
 			lpar_rc = h_multicast_ctrl(adapter->vdev->unit_address,
 						   IbmVethMcastAddFilter,
 						   mcast_addr);
@@ -1372,9 +1382,6 @@ static int ibmveth_probe(struct vio_dev
 
 	netif_napi_add(netdev, &adapter->napi, ibmveth_poll, 16);
 
-	adapter->mac_addr = 0;
-	memcpy(&adapter->mac_addr, mac_addr_p, ETH_ALEN);
-
 	netdev->irq = dev->irq;
 	netdev->netdev_ops = &ibmveth_netdev_ops;
 	netdev->ethtool_ops = &netdev_ethtool_ops;
@@ -1383,7 +1390,7 @@ static int ibmveth_probe(struct vio_dev
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
 	netdev->features |= netdev->hw_features;
 
-	memcpy(netdev->dev_addr, &adapter->mac_addr, netdev->addr_len);
+	memcpy(netdev->dev_addr, mac_addr_p, ETH_ALEN);
 
 	for (i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++) {
 		struct kobject *kobj = &adapter->rx_buff_pool[i].kobj;
Index: b/drivers/net/ethernet/ibm/ibmveth.h
===================================================================
--- a/drivers/net/ethernet/ibm/ibmveth.h
+++ b/drivers/net/ethernet/ibm/ibmveth.h
@@ -138,7 +138,6 @@ struct ibmveth_adapter {
     struct napi_struct napi;
     struct net_device_stats stats;
     unsigned int mcastFilterSize;
-    unsigned long mac_addr;
     void * buffer_list_addr;
     void * filter_list_addr;
     dma_addr_t buffer_list_dma;
