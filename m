From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 3/3] netxen: ethtool fixes
Date: Mon, 3 Sep 2007 10:33:35 +0530 (IST)
Message-ID: <Pine.LNX.4.64.0709031029110.2882@stellar.unminc.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jeff@garzik.org, rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:33192 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750890AbXICFDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2007 01:03:40 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Resubmitting the patch. 

This patch improves ethtool support for printing correct ring statistics,
segmentation offload status, etc.

Signed-off by: Dhananjay Phadke <dhananjay@netxen.com>

Index: netdev-2.6/drivers/net/netxen/netxen_nic.h
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic.h
+++ netdev-2.6/drivers/net/netxen/netxen_nic.h
@@ -918,7 +918,7 @@ struct netxen_adapter {
 	u16 link_duplex;
 	u16 state;
 	u16 link_autoneg;
-	int rcsum;
+	int rx_csum;
 	int status;
 	spinlock_t stats_lock;
 
Index: netdev-2.6/drivers/net/netxen/netxen_nic_ethtool.c
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic_ethtool.c
+++ netdev-2.6/drivers/net/netxen/netxen_nic_ethtool.c
@@ -518,17 +518,17 @@ netxen_nic_get_ringparam(struct net_devi
 	ring->rx_jumbo_pending = 0;
 	for (i = 0; i < MAX_RCV_CTX; ++i) {
 		ring->rx_pending += adapter->recv_ctx[i].
-		    rcv_desc[RCV_DESC_NORMAL_CTXID].rcv_pending;
+		    rcv_desc[RCV_DESC_NORMAL_CTXID].max_rx_desc_count;
 		ring->rx_jumbo_pending += adapter->recv_ctx[i].
-		    rcv_desc[RCV_DESC_JUMBO_CTXID].rcv_pending;
+		    rcv_desc[RCV_DESC_JUMBO_CTXID].max_rx_desc_count;
 	}
+	ring->tx_pending = adapter->max_tx_desc_count;
 
-	ring->rx_max_pending = adapter->max_rx_desc_count;
-	ring->tx_max_pending = adapter->max_tx_desc_count;
-	ring->rx_jumbo_max_pending = adapter->max_jumbo_rx_desc_count;
+	ring->rx_max_pending = MAX_RCV_DESCRIPTORS;
+	ring->tx_max_pending = MAX_CMD_DESCRIPTORS_HOST;
+	ring->rx_jumbo_max_pending = MAX_JUMBO_RCV_DESCRIPTORS;
 	ring->rx_mini_max_pending = 0;
 	ring->rx_mini_pending = 0;
-	ring->rx_jumbo_pending = 0;
 }
 
 static void
@@ -731,6 +731,19 @@ netxen_nic_get_ethtool_stats(struct net_
 	}
 }
 
+static u32 netxen_nic_get_rx_csum(struct net_device *dev)
+{
+	struct netxen_adapter *adapter = netdev_priv(dev);
+	return adapter->rx_csum;
+}
+
+static int netxen_nic_set_rx_csum(struct net_device *dev, u32 data)
+{
+	struct netxen_adapter *adapter = netdev_priv(dev);
+	adapter->rx_csum = !!data;
+	return 0;
+}
+
 struct ethtool_ops netxen_nic_ethtool_ops = {
 	.get_settings = netxen_nic_get_settings,
 	.set_settings = netxen_nic_set_settings,
@@ -755,4 +768,7 @@ struct ethtool_ops netxen_nic_ethtool_op
 	.get_strings = netxen_nic_get_strings,
 	.get_stats_count = netxen_nic_get_stats_count,
 	.get_ethtool_stats = netxen_nic_get_ethtool_stats,
+	.get_rx_csum = netxen_nic_get_rx_csum,
+	.set_rx_csum = netxen_nic_set_rx_csum,
+	.get_ufo = ethtool_op_get_ufo,
 };
Index: netdev-2.6/drivers/net/netxen/netxen_nic_main.c
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic_main.c
+++ netdev-2.6/drivers/net/netxen/netxen_nic_main.c
@@ -408,6 +408,7 @@ netxen_nic_probe(struct pci_dev *pdev, c
 	/* This will be reset for mezz cards  */
 	adapter->portnum = pci_func_id;
 	adapter->status   &= ~NETXEN_NETDEV_STATUS;
+	adapter->rx_csum = 1;
 
 	netdev->open		   = netxen_nic_open;
 	netdev->stop		   = netxen_nic_close;
Index: netdev-2.6/drivers/net/netxen/netxen_nic_init.c
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic_init.c
+++ netdev-2.6/drivers/net/netxen/netxen_nic_init.c
@@ -1118,10 +1118,13 @@ netxen_process_rcv(struct netxen_adapter
 
 	skb = (struct sk_buff *)buffer->skb;
 
-	if (likely(netxen_get_sts_status(desc) == STATUS_CKSUM_OK)) {
+	if (likely(adapter->rx_csum &&
+				netxen_get_sts_status(desc) == STATUS_CKSUM_OK)) {
 		adapter->stats.csummed++;
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
-	}
+	} else
+		skb->ip_summed = CHECKSUM_NONE;
+
 	skb->dev = netdev;
 	if (desc_ctx == RCV_DESC_LRO_CTXID) {
 		/* True length was only available on the last pkt */
