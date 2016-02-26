From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next v3 1/5] netdev: introduce ndo_set_rx_headroom
Date: Fri, 26 Feb 2016 10:45:37 +0100
Message-ID: <ec2515e951a931c9c89710a5cd8444bd9b34ca7c.1456412101.git.pabeni@redhat.com>
References: <cover.1456412101.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@kernel.org>,
	Flavio Leitner <fbl@sysclose.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52562 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751761AbcBZJqF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2016 04:46:05 -0500
In-Reply-To: <cover.1456412101.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This method allows the controlling device (i.e. the bridge) to specify
additional headroom to be allocated for skb head on frame reception.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>

---
v1 -> v2:
 - fixed netdev_get_fwd_headroom()
 - added netdev_set_rx_headroom() and netdev_reset_rx_headroom() helpers
v2 -> v3:
 - fix typo in ndo_set_rx_headroom documentation
---
 include/linux/netdevice.h | 31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e52077f..efe7cec 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1093,6 +1093,12 @@ struct tc_to_netdev {
  *	This function is used to get egress tunnel information for given skb.
  *	This is useful for retrieving outer tunnel header parameters while
  *	sampling packet.
+ * void (*ndo_set_rx_headroom)(struct net_device *dev, int needed_headroom);
+ *	This function is used to specify the headroom that the skb must
+ *	consider when allocation skb during packet reception. Setting
+ *	appropriate rx headroom value allows avoiding skb head copy on
+ *	forward. Setting a negative value reset the rx headroom to the
+ *	default value.
  *
  */
 struct net_device_ops {
@@ -1278,6 +1284,8 @@ struct net_device_ops {
 							 bool proto_down);
 	int			(*ndo_fill_metadata_dst)(struct net_device *dev,
 						       struct sk_buff *skb);
+	void			(*ndo_set_rx_headroom)(struct net_device *dev,
+						       int needed_headroom);
 };
 
 /**
@@ -1315,6 +1323,8 @@ struct net_device_ops {
  * @IFF_L3MDEV_SLAVE: device is enslaved to an L3 master device
  * @IFF_TEAM: device is a team device
  * @IFF_RXFH_CONFIGURED: device has had Rx Flow indirection table configured
+ * @IFF_PHONY_HEADROOM: the headroom value is controlled by an external
+ *	entity (i.e. the master device for bridged veth)
  */
 enum netdev_priv_flags {
 	IFF_802_1Q_VLAN			= 1<<0,
@@ -1343,6 +1353,7 @@ enum netdev_priv_flags {
 	IFF_L3MDEV_SLAVE		= 1<<23,
 	IFF_TEAM			= 1<<24,
 	IFF_RXFH_CONFIGURED		= 1<<25,
+	IFF_PHONY_HEADROOM		= 1<<26,
 };
 
 #define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
@@ -1937,6 +1948,26 @@ struct netdev_queue *netdev_pick_tx(struct net_device *dev,
 				    struct sk_buff *skb,
 				    void *accel_priv);
 
+/* returns the headroom that the master device needs to take in account
+ * when forwarding to this dev
+ */
+static inline unsigned netdev_get_fwd_headroom(struct net_device *dev)
+{
+	return dev->priv_flags & IFF_PHONY_HEADROOM ? 0 : dev->needed_headroom;
+}
+
+static inline void netdev_set_rx_headroom(struct net_device *dev, int new_hr)
+{
+	if (dev->netdev_ops->ndo_set_rx_headroom)
+		dev->netdev_ops->ndo_set_rx_headroom(dev, new_hr);
+}
+
+/* set the device rx headroom to the dev's default */
+static inline void netdev_reset_rx_headroom(struct net_device *dev)
+{
+	netdev_set_rx_headroom(dev, -1);
+}
+
 /*
  * Net namespace inlines
  */
-- 
1.8.3.1
