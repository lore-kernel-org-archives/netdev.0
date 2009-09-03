From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] macvlan: add multiqueue capability
Date: Thu, 03 Sep 2009 12:11:45 +0200
Message-ID: <4A9F9661.7020301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49606 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753440AbZICKLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 06:11:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

macvlan devices are currently not multi-queue capable.

We can do that defining rtnl_link_ops method,
get_tx_queues(), called from rtnl_create_link()

This new method gets num_tx_queues/real_num_tx_queues
from lower device.

macvlan_get_tx_queues() is a copy of vlan_get_tx_queues().

Because macvlan_start_xmit() has to update netdev_queue
stats only (and not dev->stats), I chose to change
tx_errors/tx_aborted_errors accounting to tx_dropped,
since netdev_queue structure doesnt define tx_errors /
tx_aborted_errors.


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/macvlan.c |   33 +++++++++++++++++++++++++++------
 1 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index c85c46d..3aabfd9 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -187,6 +187,8 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 static netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 				      struct net_device *dev)
 {
+	int i = skb_get_queue_mapping(skb);
+	struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
 	const struct macvlan_dev *vlan = netdev_priv(dev);
 	unsigned int len = skb->len;
 	int ret;
@@ -195,12 +197,11 @@ static netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 	ret = dev_queue_xmit(skb);
 
 	if (likely(ret == NET_XMIT_SUCCESS)) {
-		dev->stats.tx_packets++;
-		dev->stats.tx_bytes += len;
-	} else {
-		dev->stats.tx_errors++;
-		dev->stats.tx_aborted_errors++;
-	}
+		txq->tx_packets++;
+		txq->tx_bytes += len;
+	} else
+		txq->tx_dropped++;
+
 	return NETDEV_TX_OK;
 }
 
@@ -484,6 +485,25 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
+static int macvlan_get_tx_queues(struct net *net,
+				 struct nlattr *tb[],
+				 unsigned int *num_tx_queues,
+				 unsigned int *real_num_tx_queues)
+{
+	struct net_device *real_dev;
+
+	if (!tb[IFLA_LINK])
+		return -EINVAL;
+
+	real_dev = __dev_get_by_index(net, nla_get_u32(tb[IFLA_LINK]));
+	if (!real_dev)
+		return -ENODEV;
+
+	*num_tx_queues      = real_dev->num_tx_queues;
+	*real_num_tx_queues = real_dev->real_num_tx_queues;
+	return 0;
+}
+
 static int macvlan_newlink(struct net_device *dev,
 			   struct nlattr *tb[], struct nlattr *data[])
 {
@@ -550,6 +570,7 @@ static void macvlan_dellink(struct net_device *dev)
 static struct rtnl_link_ops macvlan_link_ops __read_mostly = {
 	.kind		= "macvlan",
 	.priv_size	= sizeof(struct macvlan_dev),
+	.get_tx_queues  = macvlan_get_tx_queues,
 	.setup		= macvlan_setup,
 	.validate	= macvlan_validate,
 	.newlink	= macvlan_newlink,
