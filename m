From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] veth: Allow setting the L3 MTU
Date: Tue, 03 Mar 2009 20:14:18 -0800
Message-ID: <m1ab813ox1.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:55465 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719AbZCDExd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 23:53:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The limitation to only 1500 byte mtu's limits the utility of the veth
device for testing routing.  So implement implement a configurable
MTU.

For consistency I drop packets on the receive side when they are
larger than the MTU.  I count those drops.  And I allow
a little padding for vlan headers.

I also test the mtu when a new device is created with netlink
because that path currently bypasses the current mtu setting
code.

Signed-off-by: Eric Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/veth.c |   45 +++++++++++++++++++++++++++++++++++++++------
 1 files changed, 39 insertions(+), 6 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 124fe75..015db1c 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -19,12 +19,17 @@
 #define DRV_NAME	"veth"
 #define DRV_VERSION	"1.0"
 
+#define MIN_MTU 68		/* Min L3 MTU */
+#define MAX_MTU 65535		/* Max L3 MTU (arbitrary) */
+#define MTU_PAD (ETH_HLEN + 4)  /* Max difference between L2 and L3 size MTU */
+
 struct veth_net_stats {
 	unsigned long	rx_packets;
 	unsigned long	tx_packets;
 	unsigned long	rx_bytes;
 	unsigned long	tx_bytes;
 	unsigned long	tx_dropped;
+	unsigned long	rx_dropped;
 };
 
 struct veth_priv {
@@ -147,7 +152,7 @@ static int veth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_device *rcv = NULL;
 	struct veth_priv *priv, *rcv_priv;
-	struct veth_net_stats *stats;
+	struct veth_net_stats *stats, *rcv_stats;
 	int length, cpu;
 
 	skb_orphan(skb);
@@ -158,9 +163,13 @@ static int veth_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	cpu = smp_processor_id();
 	stats = per_cpu_ptr(priv->stats, cpu);
+	rcv_stats = per_cpu_ptr(rcv_priv->stats, cpu);
 
 	if (!(rcv->flags & IFF_UP))
-		goto outf;
+		goto tx_drop;
+
+	if (skb->len > (rcv->mtu + MTU_PAD))
+		goto rx_drop;
 
 	skb->pkt_type = PACKET_HOST;
 	skb->protocol = eth_type_trans(skb, rcv);
@@ -178,17 +187,21 @@ static int veth_xmit(struct sk_buff *skb, struct net_device *dev)
 	stats->tx_bytes += length;
 	stats->tx_packets++;
 
-	stats = per_cpu_ptr(rcv_priv->stats, cpu);
-	stats->rx_bytes += length;
-	stats->rx_packets++;
+	rcv_stats->rx_bytes += length;
+	rcv_stats->rx_packets++;
 
 	netif_rx(skb);
 	return 0;
 
-outf:
+tx_drop:
 	kfree_skb(skb);
 	stats->tx_dropped++;
 	return 0;
+
+rx_drop:
+	kfree_skb(skb);
+	rcv_stats->rx_dropped++;
+	return 0;
 }
 
 /*
@@ -210,6 +223,7 @@ static struct net_device_stats *veth_get_stats(struct net_device *dev)
 	dev_stats->rx_bytes = 0;
 	dev_stats->tx_bytes = 0;
 	dev_stats->tx_dropped = 0;
+	dev_stats->rx_dropped = 0;
 
 	for_each_online_cpu(cpu) {
 		stats = per_cpu_ptr(priv->stats, cpu);
@@ -219,6 +233,7 @@ static struct net_device_stats *veth_get_stats(struct net_device *dev)
 		dev_stats->rx_bytes += stats->rx_bytes;
 		dev_stats->tx_bytes += stats->tx_bytes;
 		dev_stats->tx_dropped += stats->tx_dropped;
+		dev_stats->rx_dropped += stats->rx_dropped;
 	}
 
 	return dev_stats;
@@ -249,6 +264,19 @@ static int veth_close(struct net_device *dev)
 	return 0;
 }
 
+static int is_valid_veth_mtu(int new_mtu)
+{
+	return (new_mtu >= MIN_MTU && new_mtu <= MAX_MTU);
+}
+
+static int veth_change_mtu(struct net_device *dev, int new_mtu)
+{
+	if (!is_valid_veth_mtu(new_mtu))
+		return -EINVAL;
+	dev->mtu = new_mtu;
+	return 0;
+}
+
 static int veth_dev_init(struct net_device *dev)
 {
 	struct veth_net_stats *stats;
@@ -277,6 +305,7 @@ static const struct net_device_ops veth_netdev_ops = {
 	.ndo_open            = veth_open,
 	.ndo_stop            = veth_close,
 	.ndo_start_xmit      = veth_xmit,
+	.ndo_change_mtu      = veth_change_mtu,
 	.ndo_get_stats       = veth_get_stats,
 	.ndo_set_mac_address = eth_mac_addr,
 };
@@ -303,6 +332,10 @@ static int veth_validate(struct nlattr *tb[], struct nlattr *data[])
 		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
 			return -EADDRNOTAVAIL;
 	}
+	if (tb[IFLA_MTU]) {
+		if (!is_valid_veth_mtu(nla_get_u32(tb[IFLA_MTU])))
+			return -EINVAL;
+	}
 	return 0;
 }
 
-- 
1.6.1.2.350.g88cc

