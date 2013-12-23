From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] ibmveth: Fix more little endian issues
Date: Mon, 23 Dec 2013 17:38:33 +1100
Message-ID: <20131223173833.0a9a6705@kryten>
References: <1387762163-39662-1-git-send-email-agraf@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org,
	Ben Herrenschmidt <benh@kernel.crashing.org>,
	Dinar Valeev <dvaleev@suse.com>,
	Santiago Leon <santil@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Alexander Graf <agraf@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:57761 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757016Ab3LWGie (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Dec 2013 01:38:34 -0500
In-Reply-To: <1387762163-39662-1-git-send-email-agraf@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Alex,

> The ibmveth driver is memcpy()'ing the mac address between a variable
> (register) and memory. This assumes a certain endianness of the
> system, so let's make that implicit assumption work again.

Nice catch! I don't like how the driver has two different methods
for creating these MAC addresses, both without comments. How does
this look?

Anton
--

The hypervisor expects MAC addresses passed in registers to be big
endian u64. Create a helper function called ibmveth_encode_mac_addr
which does the right thing in both big and little endian.

We were storing the MAC address in a long in struct ibmveth_adapter.
It's never used so remove it - we don't need another place in the
driver where we create endian issues with MAC addresses.

Reported-by: Alexander Graf <agraf@suse.de>
Signed-off-by: Anton Blanchard <anton@samba.org>
---

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 952d795..044178b 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -523,6 +523,17 @@ retry:
 	return rc;
 }
 
+/*
+ * The hypervisor expects MAC addresses passed in registers to be
+ * big endian u64.
+ */
+static unsigned long ibmveth_encode_mac_addr(char *mac)
+{
+	unsigned long encoded = 0;
+	memcpy(((char *)&encoded) + 2, mac, ETH_ALEN);
+	return cpu_to_be64(encoded);
+}
+
 static int ibmveth_open(struct net_device *netdev)
 {
 	struct ibmveth_adapter *adapter = netdev_priv(netdev);
@@ -580,8 +591,7 @@ static int ibmveth_open(struct net_device *netdev)
 	adapter->rx_queue.num_slots = rxq_entries;
 	adapter->rx_queue.toggle = 1;
 
-	memcpy(&mac_address, netdev->dev_addr, netdev->addr_len);
-	mac_address = mac_address >> 16;
+	mac_address = ibmveth_encode_mac_addr(netdev->dev_addr);
 
 	rxq_desc.fields.flags_len = IBMVETH_BUF_VALID |
 					adapter->rx_queue.queue_len;
@@ -1184,8 +1194,8 @@ static void ibmveth_set_multicast_list(struct net_device *netdev)
 		/* add the addresses to the filter table */
 		netdev_for_each_mc_addr(ha, netdev) {
 			/* add the multicast address to the filter table */
-			unsigned long mcast_addr = 0;
-			memcpy(((char *)&mcast_addr)+2, ha->addr, ETH_ALEN);
+			unsigned long mcast_addr;
+			mcast_addr = ibmveth_encode_mac_addr(ha->addr);
 			lpar_rc = h_multicast_ctrl(adapter->vdev->unit_address,
 						   IbmVethMcastAddFilter,
 						   mcast_addr);
@@ -1369,9 +1379,6 @@ static int ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
 
 	netif_napi_add(netdev, &adapter->napi, ibmveth_poll, 16);
 
-	adapter->mac_addr = 0;
-	memcpy(&adapter->mac_addr, mac_addr_p, ETH_ALEN);
-
 	netdev->irq = dev->irq;
 	netdev->netdev_ops = &ibmveth_netdev_ops;
 	netdev->ethtool_ops = &netdev_ethtool_ops;
@@ -1380,7 +1387,7 @@ static int ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
 	netdev->features |= netdev->hw_features;
 
-	memcpy(netdev->dev_addr, &adapter->mac_addr, netdev->addr_len);
+	memcpy(netdev->dev_addr, mac_addr_p, ETH_ALEN);
 
 	for (i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++) {
 		struct kobject *kobj = &adapter->rx_buff_pool[i].kobj;
diff --git a/drivers/net/ethernet/ibm/ibmveth.h b/drivers/net/ethernet/ibm/ibmveth.h
index 84066ba..2c636cb 100644
--- a/drivers/net/ethernet/ibm/ibmveth.h
+++ b/drivers/net/ethernet/ibm/ibmveth.h
@@ -139,7 +139,6 @@ struct ibmveth_adapter {
     struct napi_struct napi;
     struct net_device_stats stats;
     unsigned int mcastFilterSize;
-    unsigned long mac_addr;
     void * buffer_list_addr;
     void * filter_list_addr;
     dma_addr_t buffer_list_dma;
