From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] vlan: adds drops accounting
Date: Thu, 03 Sep 2009 12:39:16 +0200
Message-ID: <4A9F9CD4.7040408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50593 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754857AbZICKjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 06:39:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Its hard to tell if vlans are dropping frames, since
every frame given to vlan_???_start_xmit() functions
is accounted as fully transmitted by lower device.

We can test dev_queue_xmit() return values to
properly account for dropped frames.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/8021q/vlan_dev.c |   29 ++++++++++++++++++++++-------
 1 files changed, 22 insertions(+), 7 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 3938c3e..ca1f6a5 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -294,6 +294,8 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 	int i = skb_get_queue_mapping(skb);
 	struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
 	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)(skb->data);
+	unsigned int len;
+	int ret;
 
 	/* Handle non-VLAN frames if they are sent to us, for example by DHCP.
 	 *
@@ -319,11 +321,17 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 			vlan_dev_info(dev)->cnt_inc_headroom_on_tx++;
 	}
 
-	txq->tx_packets++;
-	txq->tx_bytes += skb->len;
 
 	skb->dev = vlan_dev_info(dev)->real_dev;
-	dev_queue_xmit(skb);
+	len = skb->len;
+	ret = dev_queue_xmit(skb);
+
+	if (likely(ret == NET_XMIT_SUCCESS)) {
+		txq->tx_packets++;
+		txq->tx_bytes += len;
+	} else
+		txq->tx_dropped++;
+
 	return NETDEV_TX_OK;
 }
 
@@ -333,16 +341,23 @@ static netdev_tx_t vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
 	int i = skb_get_queue_mapping(skb);
 	struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
 	u16 vlan_tci;
+	unsigned int len;
+	int ret;
 
 	vlan_tci = vlan_dev_info(dev)->vlan_id;
 	vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
 	skb = __vlan_hwaccel_put_tag(skb, vlan_tci);
 
-	txq->tx_packets++;
-	txq->tx_bytes += skb->len;
-
 	skb->dev = vlan_dev_info(dev)->real_dev;
-	dev_queue_xmit(skb);
+	len = skb->len;
+	ret = dev_queue_xmit(skb);
+
+	if (likely(ret == NET_XMIT_SUCCESS)) {
+		txq->tx_packets++;
+		txq->tx_bytes += len;
+	} else
+		txq->tx_dropped++;
+
 	return NETDEV_TX_OK;
 }
 
