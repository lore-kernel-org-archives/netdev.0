From: Patrick McHardy <kaber@trash.net>
Subject: [RFC vlan 03/03]: propagate transmission state
Date: Tue,  9 Jun 2009 18:17:02 +0200 (MEST)
Message-ID: <20090609161702.6730.72574.sendpatchset@x2.localnet>
References: <20090609161658.6730.59754.sendpatchset@x2.localnet>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33728 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756681AbZFIQRB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 12:17:01 -0400
In-Reply-To: <20090609161658.6730.59754.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit b124eaaf852e982c7af9b130ee81cfc293ae30ff
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Jun 9 18:01:11 2009 +0200

    vlan: propagate transmission state
    
    Propagate transmission state to upper layers and maintain error statistics.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 96bad8f..39a8e03 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -292,6 +292,8 @@ static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct netdev_queue *txq = netdev_get_tx_queue(dev, 0);
 	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)(skb->data);
+	unsigned int len;
+	int err;
 
 	/* Handle non-VLAN frames if they are sent to us, for example by DHCP.
 	 *
@@ -317,19 +319,25 @@ static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			vlan_dev_info(dev)->cnt_inc_headroom_on_tx++;
 	}
 
-	txq->tx_packets++;
-	txq->tx_bytes += skb->len;
-
 	skb->dev = vlan_dev_info(dev)->real_dev;
-	dev_queue_xmit(skb);
-	return NETDEV_TX_OK;
+	len = skb->len;
+	err = dev_queue_xmit(skb);
+	if (err == NET_XMIT_SUCCESS) {
+		txq->tx_packets++;
+		txq->tx_bytes += len;
+	} else
+		txq->tx_dropped++;
+
+	return err;
 }
 
 static int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev)
 {
 	struct netdev_queue *txq = netdev_get_tx_queue(dev, 0);
+	unsigned int len;
 	u16 vlan_tci;
+	int err;
 
 	vlan_tci = vlan_dev_info(dev)->vlan_id;
 	vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
@@ -339,8 +347,15 @@ static int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
 	txq->tx_bytes += skb->len;
 
 	skb->dev = vlan_dev_info(dev)->real_dev;
-	dev_queue_xmit(skb);
-	return NETDEV_TX_OK;
+	len = skb->len;
+	err = dev_queue_xmit(skb);
+	if (err == NET_XMIT_SUCCESS) {
+		txq->tx_packets++;
+		txq->tx_bytes += len;
+	} else
+		txq->tx_dropped++;
+
+	return err;
 }
 
 static int vlan_dev_change_mtu(struct net_device *dev, int new_mtu)
