From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH #2] [8021Q]: Turn off all the hardware VLAN features for
	promisc
Date: Wed, 19 Mar 2008 17:11:10 +0900
Message-ID: <20080319081110.GA12081@tp61p-64>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.187]:64852 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764054AbYCSV12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 17:27:28 -0400
Received: by rn-out-0910.google.com with SMTP id v46so589001rnb.15
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2008 14:27:26 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
This is the 2nd try for the issue about vlan & promisc
resolve: http:/bugzilla.kernel.org/show_bug.cgi?id=8218

An interface which has promisc flag should get/show all the packets on the wire, I believe.
But the hardware VLAN features are breaking it.
We might need to make a compromise with a performance for stand againt it.

The kernel can be polite to tcpdump by turnning off
 HW_TX & HW_RX: shows vlan header
 HW_FILTER: shows vlan id packet that we didn't configure

Thanks,
Joonwoo

---
[PATCH #2] [8021Q]: Turn off all the hardware VLAN features for promisc
Makes the netdev to disable HW_VLAN_TX, HW_VLAN_RX, HW_VLAN_FILTER
for the interfaces which goes into the promiscuous.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 include/linux/if_vlan.h |   24 +++++++++++----
 net/8021q/vlan.c        |   74 +++++++++++++++++++++++++++++++++++++++++++++++
 net/8021q/vlan.h        |    5 +++
 net/8021q/vlan_dev.c    |    9 +++--
 net/core/dev.c          |   11 +++++++
 5 files changed, 113 insertions(+), 10 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 79504b2..ec32a98 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -313,11 +313,11 @@ static inline struct sk_buff *__vlan_hwaccel_put_tag(struct sk_buff *skb, unsign
  */
 static inline struct sk_buff *vlan_put_tag(struct sk_buff *skb, unsigned short tag)
 {
-	if (skb->dev->features & NETIF_F_HW_VLAN_TX) {
+	if (skb->dev->features & NETIF_F_HW_VLAN_TX &&
+	    !(skb->dev->flags & IFF_PROMISC))
 		return __vlan_hwaccel_put_tag(skb, tag);
-	} else {
+	else
 		return __vlan_put_tag(skb, tag);
-	}
 }
 
 /**
@@ -373,13 +373,25 @@ static inline int __vlan_hwaccel_get_tag(const struct sk_buff *skb,
  */
 static inline int vlan_get_tag(const struct sk_buff *skb, unsigned short *tag)
 {
-	if (skb->dev->features & NETIF_F_HW_VLAN_TX) {
+	if (skb->dev->features & NETIF_F_HW_VLAN_TX &&
+	    !(skb->dev->flags & IFF_PROMISC))
 		return __vlan_hwaccel_get_tag(skb, tag);
-	} else {
+	else
 		return __vlan_get_tag(skb, tag);
-	}
 }
 
+#if defined(CONFIG_VLAN_8021Q)
+void vlan_dev_disable_hwaccel(struct net_device *any_dev);
+void vlan_dev_enable_hwaccel(struct net_device *any_dev);
+#else
+static inline void vlan_dev_disable_hwaccel(struct net_device *any_dev)
+{
+}
+static inline void vlan_dev_enable_hwaccel(struct net_device *any_dev)
+{
+}
+#endif
+
 #endif /* __KERNEL__ */
 
 /* VLAN IOCTLs are found in sockios.h */
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index dbc81b9..b1f6fca 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -470,6 +470,80 @@ out:
 	return NOTIFY_DONE;
 }
 
+void vlan_dev_disable_hwaccel(struct net_device *any_dev)
+{
+	struct vlan_group *grp;
+	struct net_device *real_dev;
+	int i;
+
+	ASSERT_RTNL();
+
+	if (any_dev->priv_flags & IFF_802_1Q_VLAN)
+		return;
+
+	real_dev = any_dev;
+
+	grp = __vlan_find_group(real_dev->ifindex);
+	if (!grp)
+		return;
+
+	for (i = 0; i < VLAN_VID_MASK; i++) {
+		struct net_device *dev = vlan_group_get_device(grp, i);
+		if (dev) {
+			if (real_dev->features &
+			    (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER)) {
+				real_dev->vlan_rx_kill_vid(real_dev, i);
+				vlan_group_set_device(grp, i, dev);
+			}
+			if (real_dev->features & NETIF_F_HW_VLAN_TX) {
+				dev->header_ops = &vlan_header_ops;
+				dev->hard_header_len = real_dev->hard_header_len
+					+ VLAN_HLEN;
+				dev->hard_start_xmit = vlan_dev_hard_start_xmit;
+			}
+		}
+	}
+
+	if (real_dev->features & NETIF_F_HW_VLAN_RX)
+		real_dev->vlan_rx_register(real_dev, NULL);
+}
+
+void vlan_dev_enable_hwaccel(struct net_device *any_dev)
+{
+	struct vlan_group *grp;
+	struct net_device *real_dev;
+	int i;
+
+	ASSERT_RTNL();
+
+	if (any_dev->priv_flags & IFF_802_1Q_VLAN)
+		return;
+
+	real_dev = any_dev;
+
+	grp = __vlan_find_group(real_dev->ifindex);
+	if (!grp)
+		return;
+
+	for (i = 0; i < VLAN_VID_MASK; i++) {
+		struct net_device *dev = vlan_group_get_device(grp, i);
+		if (dev) {
+			if (real_dev->features & (NETIF_F_HW_VLAN_FILTER))
+				real_dev->vlan_rx_add_vid(real_dev, i);
+			if (real_dev->features & NETIF_F_HW_VLAN_TX) {
+				dev->header_ops      = real_dev->header_ops;
+				dev->hard_header_len =
+					real_dev->hard_header_len;
+				dev->hard_start_xmit =
+					vlan_dev_hwaccel_hard_start_xmit;
+			}
+		}
+	}
+
+	if (real_dev->features & NETIF_F_HW_VLAN_RX)
+		real_dev->vlan_rx_register(real_dev, grp);
+}
+
 static struct notifier_block vlan_notifier_block __read_mostly = {
 	.notifier_call = vlan_device_event,
 };
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 73efcc7..719849a 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -4,6 +4,7 @@
 #include <linux/if_vlan.h>
 
 extern unsigned short vlan_name_type;
+extern const struct header_ops vlan_header_ops;
 
 #define VLAN_GRP_HASH_SHIFT	5
 #define VLAN_GRP_HASH_SIZE	(1 << VLAN_GRP_HASH_SHIFT)
@@ -35,6 +36,10 @@ int vlan_dev_set_vlan_flag(const struct net_device *dev,
 void vlan_dev_get_realdev_name(const struct net_device *dev, char *result);
 void vlan_dev_get_vid(const struct net_device *dev, unsigned short *result);
 
+int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev);
+int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
+				     struct net_device *dev);
+
 int vlan_check_real_dev(struct net_device *real_dev, unsigned short vlan_id);
 void vlan_setup(struct net_device *dev);
 int register_vlan_dev(struct net_device *dev);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 8fbcefe..e3a0a31 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -362,7 +362,7 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 	return rc;
 }
 
-static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_device_stats *stats = &dev->stats;
 	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)(skb->data);
@@ -421,7 +421,7 @@ static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
-static int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
+int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev)
 {
 	struct net_device_stats *stats = &dev->stats;
@@ -648,7 +648,7 @@ static void vlan_dev_set_rx_mode(struct net_device *vlan_dev)
  */
 static struct lock_class_key vlan_netdev_xmit_lock_key;
 
-static const struct header_ops vlan_header_ops = {
+const struct header_ops vlan_header_ops = {
 	.create	 = vlan_dev_hard_header,
 	.rebuild = vlan_dev_rebuild_header,
 	.parse	 = eth_header_parse,
@@ -674,7 +674,8 @@ static int vlan_dev_init(struct net_device *dev)
 	if (is_zero_ether_addr(dev->broadcast))
 		memcpy(dev->broadcast, real_dev->broadcast, dev->addr_len);
 
-	if (real_dev->features & NETIF_F_HW_VLAN_TX) {
+	if (real_dev->features & NETIF_F_HW_VLAN_TX &&
+	    !(real_dev->flags & IFF_PROMISC)) {
 		dev->header_ops      = real_dev->header_ops;
 		dev->hard_header_len = real_dev->hard_header_len;
 		dev->hard_start_xmit = vlan_dev_hwaccel_hard_start_xmit;
diff --git a/net/core/dev.c b/net/core/dev.c
index fcdf03c..958c248 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -119,6 +119,7 @@
 #include <linux/err.h>
 #include <linux/ctype.h>
 #include <linux/if_arp.h>
+#include <linux/if_vlan.h>
 
 #include "net-sysfs.h"
 
@@ -2738,6 +2739,14 @@ int netdev_set_master(struct net_device *slave, struct net_device *master)
 	return 0;
 }
 
+static void dev_set_hw_vlan(struct net_device *dev, int en)
+{
+	if (en)
+		vlan_dev_enable_hwaccel(dev);
+	else
+		vlan_dev_disable_hwaccel(dev);
+}
+
 static void __dev_set_promiscuity(struct net_device *dev, int inc)
 {
 	unsigned short old_flags = dev->flags;
@@ -2764,6 +2773,8 @@ static void __dev_set_promiscuity(struct net_device *dev, int inc)
 
 		if (dev->change_rx_flags)
 			dev->change_rx_flags(dev, IFF_PROMISC);
+
+		dev_set_hw_vlan(dev, !(dev->flags & IFF_PROMISC));
 	}
 }
 
-- 
1.5.2.5
---

