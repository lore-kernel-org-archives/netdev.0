From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next 2/2] macvlan: Remove custom recieve and forward handlers
Date: Wed, 11 Dec 2013 13:27:11 -0500
Message-ID: <1386786431-22592-3-git-send-email-vyasevic@redhat.com>
References: <1386786431-22592-1-git-send-email-vyasevic@redhat.com>
Cc: mst@redhat.com, kaber@trash.net,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24522 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750779Ab3LKS1V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Dec 2013 13:27:21 -0500
In-Reply-To: <1386786431-22592-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since now macvlan and macvtap use the same receive and
forward handlers, we can remove them completely and use
netif_rx and dev_forward_skb() directly.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvlan.c      | 17 +++++------------
 drivers/net/macvtap.c      |  3 +--
 include/linux/if_macvlan.h |  7 +------
 3 files changed, 7 insertions(+), 20 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index cfb9157..24ea994 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -120,7 +120,7 @@ static int macvlan_broadcast_one(struct sk_buff *skb,
 	struct net_device *dev = vlan->dev;
 
 	if (local)
-		return vlan->forward(dev, skb);
+		return dev_forward_skb(dev, skb);
 
 	skb->dev = dev;
 	if (ether_addr_equal_64bits(eth->h_dest, dev->broadcast))
@@ -128,7 +128,7 @@ static int macvlan_broadcast_one(struct sk_buff *skb,
 	else
 		skb->pkt_type = PACKET_MULTICAST;
 
-	return vlan->receive(skb);
+	return netif_rx(skb);
 }
 
 static u32 macvlan_hash_mix(const struct macvlan_dev *vlan)
@@ -251,7 +251,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 	skb->dev = dev;
 	skb->pkt_type = PACKET_HOST;
 
-	ret = vlan->receive(skb);
+	ret = netif_rx(skb);
 
 out:
 	macvlan_count_rx(vlan, len, ret == NET_RX_SUCCESS, 0);
@@ -803,10 +803,7 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
 }
 
 int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
-			   struct nlattr *tb[], struct nlattr *data[],
-			   int (*receive)(struct sk_buff *skb),
-			   int (*forward)(struct net_device *dev,
-					  struct sk_buff *skb))
+			   struct nlattr *tb[], struct nlattr *data[])
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct macvlan_port *port;
@@ -848,8 +845,6 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 	vlan->lowerdev = lowerdev;
 	vlan->dev      = dev;
 	vlan->port     = port;
-	vlan->receive  = receive;
-	vlan->forward  = forward;
 	vlan->set_features = MACVLAN_FEATURES;
 
 	vlan->mode     = MACVLAN_MODE_VEPA;
@@ -894,9 +889,7 @@ EXPORT_SYMBOL_GPL(macvlan_common_newlink);
 static int macvlan_newlink(struct net *src_net, struct net_device *dev,
 			   struct nlattr *tb[], struct nlattr *data[])
 {
-	return macvlan_common_newlink(src_net, dev, tb, data,
-				      netif_rx,
-				      dev_forward_skb);
+	return macvlan_common_newlink(src_net, dev, tb, data);
 }
 
 void macvlan_dellink(struct net_device *dev, struct list_head *head)
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index f9847da..46168d0 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -400,8 +400,7 @@ static int macvtap_newlink(struct net *src_net,
 	/* Don't put anything that may fail after macvlan_common_newlink
 	 * because we can't undo what it does.
 	 */
-	return macvlan_common_newlink(src_net, dev, tb, data,
-				      netif_rx, dev_forward_skb);
+	return macvlan_common_newlink(src_net, dev, tb, data);
 }
 
 static void macvtap_dellink(struct net_device *dev,
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index 84ba5ac..ea22721 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -69,8 +69,6 @@ struct macvlan_dev {
 	netdev_features_t	set_features;
 	enum macvlan_mode	mode;
 	u16			flags;
-	int (*receive)(struct sk_buff *skb);
-	int (*forward)(struct net_device *dev, struct sk_buff *skb);
 	/* This array tracks active taps. */
 	struct macvtap_queue	__rcu *taps[MAX_MACVTAP_QUEUES];
 	/* This list tracks all taps (both enabled and disabled) */
@@ -103,10 +101,7 @@ static inline void macvlan_count_rx(const struct macvlan_dev *vlan,
 extern void macvlan_common_setup(struct net_device *dev);
 
 extern int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
-				  struct nlattr *tb[], struct nlattr *data[],
-				  int (*receive)(struct sk_buff *skb),
-				  int (*forward)(struct net_device *dev,
-						 struct sk_buff *skb));
+				  struct nlattr *tb[], struct nlattr *data[]);
 
 extern void macvlan_count_rx(const struct macvlan_dev *vlan,
 			     unsigned int len, bool success,
-- 
1.8.4.2
