From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] bridge: send correct MTU value in PMTU (revised)
Date: Wed, 30 Jul 2008 13:32:59 -0700
Message-ID: <20080730133259.576e0041@extreme>
References: <200807301937.m6UJbZaR012427@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org, simon.wunderlich@s2003.tu-chemnitz.de,
	siwu@hrz.tu-chemnitz.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48070 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753252AbYG3Udp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 16:33:45 -0400
In-Reply-To: <200807301937.m6UJbZaR012427@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When bridging interfaces with different MTUs, the bridge correctly chooses
the minimum of the MTUs of the physical devices as the bridges MTU.  But
when a frame is passed which fits through the incoming, but not through
the outgoing interface, a "Fragmentation Needed" packet is generated.

However, the propagated MTU is hardcoded to 1500, which is wrong in this
situation.  The sender will repeat the packet again with the same frame
size, and the same problem will occur again.

Instead of sending 1500, the (correct) MTU value of the bridge is now sent
via PMTU.  To achieve this, the corresponding rtable structure is stored
in its net_bridge structure.

Modified to get rid of fake_net_device as well.

Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 net/bridge/br_device.c    |    9 +++++-
 net/bridge/br_if.c        |    3 ++
 net/bridge/br_netfilter.c |   64 +++++++++++++++++++++++++---------------------
 net/bridge/br_private.h   |    6 ++++
 4 files changed, 53 insertions(+), 29 deletions(-)

--- a/net/bridge/br_device.c	2008-07-15 15:57:34.000000000 -0700
+++ b/net/bridge/br_device.c	2008-07-15 16:01:37.000000000 -0700
@@ -68,10 +68,17 @@ static int br_dev_stop(struct net_device
 
 static int br_change_mtu(struct net_device *dev, int new_mtu)
 {
-	if (new_mtu < 68 || new_mtu > br_min_mtu(netdev_priv(dev)))
+	struct net_bridge *br = netdev_priv(dev);
+	if (new_mtu < 68 || new_mtu > br_min_mtu(br))
 		return -EINVAL;
 
 	dev->mtu = new_mtu;
+
+#ifdef CONFIG_BRIDGE_NETFILTER
+	/* remember the MTU in the rtable for PMTU */
+	br->fake_rtable.u.dst.metrics[RTAX_MTU - 1] = new_mtu;
+#endif
+
 	return 0;
 }
 
--- a/net/bridge/br_if.c	2008-07-15 15:57:34.000000000 -0700
+++ b/net/bridge/br_if.c	2008-07-15 16:04:46.000000000 -0700
@@ -202,6 +202,9 @@ static struct net_device *new_bridge_dev
 	br->topology_change = 0;
 	br->topology_change_detected = 0;
 	br->ageing_time = 300 * HZ;
+
+	br_netfilter_rtable_init(br);
+
 	INIT_LIST_HEAD(&br->age_list);
 
 	br_stp_timer_init(br);
--- a/net/bridge/br_netfilter.c	2008-07-15 09:15:57.000000000 -0700
+++ b/net/bridge/br_netfilter.c	2008-07-16 14:46:24.000000000 -0700
@@ -101,33 +101,30 @@ static inline __be16 pppoe_proto(const s
 	 pppoe_proto(skb) == htons(PPP_IPV6) && \
 	 brnf_filter_pppoe_tagged)
 
-/* We need these fake structures to make netfilter happy --
- * lots of places assume that skb->dst != NULL, which isn't
- * all that unreasonable.
- *
+/*
+ * Initialize bogus route table used to keep netfilter happy.
  * Currently, we fill in the PMTU entry because netfilter
  * refragmentation needs it, and the rt_flags entry because
  * ipt_REJECT needs it.  Future netfilter modules might
- * require us to fill additional fields. */
-static struct net_device __fake_net_device = {
-	.hard_header_len	= ETH_HLEN,
-#ifdef CONFIG_NET_NS
-	.nd_net			= &init_net,
-#endif
-};
+ * require us to fill additional fields.
+ */
+void br_netfilter_rtable_init(struct net_bridge *br)
+{
+	struct rtable *rt = &br->fake_rtable;
 
-static struct rtable __fake_rtable = {
-	.u = {
-		.dst = {
-			.__refcnt		= ATOMIC_INIT(1),
-			.dev			= &__fake_net_device,
-			.path			= &__fake_rtable.u.dst,
-			.metrics		= {[RTAX_MTU - 1] = 1500},
-			.flags			= DST_NOXFRM,
-		}
-	},
-	.rt_flags	= 0,
-};
+	atomic_set(&rt->u.dst.__refcnt, 1);
+	rt->u.dst.dev = &br->dev;
+	rt->u.dst.path = &rt->u.dst;
+	rt->u.dst.metrics[RTAX_MTU - 1] = 1500;
+	rt->u.dst.flags	= DST_NOXFRM;
+}
+
+static inline struct rtable *bridge_parent_rtable(const struct net_device *dev)
+{
+	struct net_bridge_port *port = rcu_dereference(dev->br_port);
+
+	return port ? &port->br->fake_rtable : NULL;
+}
 
 static inline struct net_device *bridge_parent(const struct net_device *dev)
 {
@@ -226,8 +223,12 @@ static int br_nf_pre_routing_finish_ipv6
 	}
 	nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
 
-	skb->rtable = &__fake_rtable;
-	dst_hold(&__fake_rtable.u.dst);
+	skb->rtable = bridge_parent_rtable(nf_bridge->physindev);
+	if (!skb->rtable) {
+		kfree_skb(skb);
+		return 0;
+	}
+	dst_hold(&skb->rtable->u.dst);
 
 	skb->dev = nf_bridge->physindev;
 	nf_bridge_push_encap_header(skb);
@@ -391,8 +392,12 @@ bridged_dnat:
 			skb->pkt_type = PACKET_HOST;
 		}
 	} else {
-		skb->rtable = &__fake_rtable;
-		dst_hold(&__fake_rtable.u.dst);
+		skb->rtable = bridge_parent_rtable(nf_bridge->physindev);
+		if (!skb->rtable) {
+			kfree_skb(skb);
+			return 0;
+		}
+		dst_hold(&skb->rtable->u.dst);
 	}
 
 	skb->dev = nf_bridge->physindev;
@@ -611,8 +616,8 @@ static unsigned int br_nf_local_in(unsig
 				   const struct net_device *out,
 				   int (*okfn)(struct sk_buff *))
 {
-	if (skb->rtable == &__fake_rtable) {
-		dst_release(&__fake_rtable.u.dst);
+	if (skb->rtable && skb->rtable == bridge_parent_rtable(in)) {
+		dst_release(&skb->rtable->u.dst);
 		skb->rtable = NULL;
 	}
 
--- a/net/bridge/br_private.h	2008-07-15 15:57:34.000000000 -0700
+++ b/net/bridge/br_private.h	2008-07-15 16:12:55.000000000 -0700
@@ -15,6 +15,7 @@
 
 #include <linux/netdevice.h>
 #include <linux/if_bridge.h>
+#include <net/route.h>
 
 #define BR_HASH_BITS 8
 #define BR_HASH_SIZE (1 << BR_HASH_BITS)
@@ -92,6 +93,9 @@ struct net_bridge
 	struct hlist_head		hash[BR_HASH_SIZE];
 	struct list_head		age_list;
 	unsigned long			feature_mask;
+#ifdef CONFIG_BRIDGE_NETFILTER
+	struct rtable 			fake_rtable;
+#endif
 	unsigned long			flags;
 #define BR_SET_MAC_ADDR		0x00000001
 
@@ -197,9 +201,11 @@ extern int br_ioctl_deviceless_stub(stru
 #ifdef CONFIG_BRIDGE_NETFILTER
 extern int br_netfilter_init(void);
 extern void br_netfilter_fini(void);
+extern void br_netfilter_rtable_init(struct net_bridge *);
 #else
 #define br_netfilter_init()	(0)
 #define br_netfilter_fini()	do { } while(0)
+#define br_netfilter_rtable_init(x)
 #endif
 
 /* br_stp.c */

