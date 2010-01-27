From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 1/3] net: maintain namespace isolation between vlan and real device
Date: Wed, 27 Jan 2010 11:05:15 +0100
Message-ID: <201001271105.15733.arnd@arndb.de>
References: <201001271104.20607.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@voltaire.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756015Ab0A0VLe@vger.kernel.org>
In-Reply-To: <201001271104.20607.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the vlan and macvlan drivers, the start_xmit function forwards
data to the dev_queue_xmit function for another device, which may
potentially belong to a different namespace.

To make sure that classification stays within a single namespace,
this resets the potentially critical fields.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/macvlan.c     |    2 +-
 include/linux/netdevice.h |    9 +++++++++
 net/8021q/vlan_dev.c      |    2 +-
 net/core/dev.c            |   35 +++++++++++++++++++++++++++++++----
 4 files changed, 42 insertions(+), 6 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index bad1303..e0436fd 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -269,7 +269,7 @@ static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 xmit_world:
-	skb->dev = vlan->lowerdev;
+	skb_set_dev(skb, vlan->lowerdev);
 	return dev_queue_xmit(skb);
 }
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 93a32a5..622ba5a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1004,6 +1004,15 @@ static inline bool netdev_uses_dsa_tags(struct net_device *dev)
 	return 0;
 }
 
+#ifndef CONFIG_NET_NS
+static inline void skb_set_dev(struct sk_buff *skb, struct net_device *dev)
+{
+	skb->dev = dev;
+}
+#else /* CONFIG_NET_NS */
+void skb_set_dev(struct sk_buff *skb, struct net_device *dev);
+#endif
+
 static inline bool netdev_uses_trailer_tags(struct net_device *dev)
 {
 #ifdef CONFIG_NET_DSA_TAG_TRAILER
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 77a49ff..95034a8 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -322,7 +322,7 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 	}
 
 
-	skb->dev = vlan_dev_info(dev)->real_dev;
+	skb_set_dev(skb, vlan_dev_info(dev)->real_dev);
 	len = skb->len;
 	ret = dev_queue_xmit(skb);
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 2cba5c5..e80403a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1448,13 +1448,10 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 	if (skb->len > (dev->mtu + dev->hard_header_len))
 		return NET_RX_DROP;
 
-	skb_dst_drop(skb);
+	skb_set_dev(skb, dev);
 	skb->tstamp.tv64 = 0;
 	skb->pkt_type = PACKET_HOST;
 	skb->protocol = eth_type_trans(skb, dev);
-	skb->mark = 0;
-	secpath_reset(skb);
-	nf_reset(skb);
 	return netif_rx(skb);
 }
 EXPORT_SYMBOL_GPL(dev_forward_skb);
@@ -1614,6 +1611,36 @@ static bool dev_can_checksum(struct net_device *dev, struct sk_buff *skb)
 	return false;
 }
 
+/**
+ * skb_dev_set -- assign a buffer to a new device
+ * @skb: buffer for the new device
+ * @dev: network device
+ *
+ * If an skb is owned by a device already, we have to reset
+ * all data private to the namespace a device belongs to
+ * before assigning it a new device.
+ */
+#ifdef CONFIG_NET_NS
+void skb_set_dev(struct sk_buff *skb, struct net_device *dev)
+{
+	skb_dst_drop(skb);
+	if (skb->dev && !net_eq(dev_net(skb->dev), dev_net(dev))) {
+		secpath_reset(skb);
+		nf_reset(skb);
+		skb_init_secmark(skb);
+		skb->mark = 0;
+		skb->priority = 0;
+		skb->nf_trace = 0;
+		skb->ipvs_property = 0;
+#ifdef CONFIG_NET_SCHED
+		skb->tc_index = 0;
+#endif
+	}
+	skb->dev = dev;
+}
+EXPORT_SYMBOL(skb_set_dev);
+#endif /* CONFIG_NET_NS */
+
 /*
  * Invalidate hardware checksum when packet is to be mangled, and
  * complete checksum manually on outgoing path.
-- 
1.6.3.3
