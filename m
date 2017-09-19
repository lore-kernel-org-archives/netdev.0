From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH net-next 11/14] net: Add a facility to support application defined GSO
Date: Mon, 18 Sep 2017 17:39:01 -0700
Message-ID: <20170919003904.5124-12-tom@quantonium.net>
References: <20170919003904.5124-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, pablo@netfilter.org, laforge@gnumonks.org,
        rohit@quantonium.net, Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:50972 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751499AbdISAj6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 20:39:58 -0400
Received: by mail-pg0-f51.google.com with SMTP id p5so1089298pgn.7
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 17:39:58 -0700 (PDT)
In-Reply-To: <20170919003904.5124-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow applications or encapsulation protocols to register a GSO segment
function to their specific protocol. To faciliate this I reserved the
upper four bits in the gso_type to indicate the application specific GSO
type. Zero in these bits indicates no application GSO, so there are
fifteen instance that can be defined.

An application registers a a gso_segment using the skb_gso_app_register
this takes a struct skb_gso_app that indicates a callback function as
well as a set of GSO types for which at least one must be matched before
calling he segment function. GSO returns one of the application GSO
types described above (not a fixed value for the applications).
Subsequently, when the application sends a GSO packet the application
gso_type is set in the skb gso_type along with any other types.

skb_gso_app_segment is the function called from another GSO segment
function to handle segmentation of the application or encapsulation
protocol. This function includes check flags that provides context for
the appropriate GSO instance to match. For instance, in order to handle
a protocol encapsulated in UDP (GTP for instance) skb_gso_app_segment is
call from udp_tunnel_segment and check flags would be
SKB_GSO_UDP_TUNNEL_CSUM | SKB_GSO_UDP_TUNNEL.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 include/linux/netdevice.h | 31 +++++++++++++++++++++++++++++++
 include/linux/skbuff.h    | 25 +++++++++++++++++++++++++
 net/core/dev.c            | 47 +++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/ip_tunnel_core.c |  6 ++++++
 net/ipv4/udp_offload.c    | 20 +++++++++++++++-----
 5 files changed, 124 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f535779d9dc1..f3bed4f8ba83 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3932,6 +3932,37 @@ struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
 				    netdev_features_t features);
 
+struct skb_gso_app {
+	unsigned int check_flags;
+	struct sk_buff *(*gso_segment)(struct sk_buff *skb,
+				       netdev_features_t features);
+};
+
+extern struct skb_gso_app *skb_gso_apps[];
+int skb_gso_app_register(const struct skb_gso_app *app);
+void skb_gso_app_unregister(int num, const struct skb_gso_app *app);
+
+/* rcu_read_lock() must be held */
+static inline struct skb_gso_app *skb_gso_app_lookup(struct sk_buff *skb,
+						     netdev_features_t features,
+						     unsigned int check_flags)
+{
+	struct skb_gso_app *app;
+	int type;
+
+	if (!(skb_shinfo(skb)->gso_type & SKB_GSO_APP_MASK))
+		return false;
+
+	type = skb_gso_app_to_index(skb_shinfo(skb)->gso_type);
+
+	app = rcu_dereference(skb_gso_apps[type]);
+	if (app && app->gso_segment &&
+	    (check_flags & app->check_flags))
+		return app;
+
+	return NULL;
+}
+
 struct netdev_bonding_info {
 	ifslave	slave;
 	ifbond	master;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 72299ef00061..ea45fb93897c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -535,6 +535,9 @@ enum {
 	SKB_FCLONE_CLONE,	/* companion fclone skb (from fclone_cache) */
 };
 
+#define SKB_GSO_APP_LOW_SHIFT	28
+#define SKB_GSO_APP_HIGH_SHIFT	31
+
 enum {
 	SKB_GSO_TCPV4 = 1 << 0,
 
@@ -569,8 +572,30 @@ enum {
 	SKB_GSO_SCTP = 1 << 14,
 
 	SKB_GSO_ESP = 1 << 15,
+
+	/* UDP encapsulation specific GSO consumes bits 28 through 31 */
+
+	SKB_GSO_APP_LOW = 1 << SKB_GSO_APP_LOW_SHIFT,
+
+	SKB_GSO_APP_HIGH = 1 << SKB_GSO_APP_HIGH_SHIFT,
 };
 
+#define SKB_GSO_APP_MASK ((-1U << SKB_GSO_APP_LOW_SHIFT) & \
+			  (-1U >> (8*sizeof(u32) - SKB_GSO_APP_HIGH_SHIFT - 1)))
+#define SKB_GSO_APP_NUM (SKB_GSO_APP_MASK >> SKB_GSO_APP_LOW_SHIFT)
+
+static inline int skb_gso_app_to_index(unsigned int x)
+{
+	/* Caller should check that app bits are non-zero */
+
+	return ((SKB_GSO_APP_MASK & x) >> SKB_GSO_APP_LOW_SHIFT) - 1;
+}
+
+static inline int skb_gso_app_to_gso_type(unsigned int x)
+{
+	return (x + 1) << SKB_GSO_APP_LOW_SHIFT;
+}
+
 #if BITS_PER_LONG > 32
 #define NET_SKBUFF_DATA_USES_OFFSET 1
 #endif
diff --git a/net/core/dev.c b/net/core/dev.c
index fb766d906148..c77fca112e67 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -156,6 +156,7 @@
 
 static DEFINE_SPINLOCK(ptype_lock);
 static DEFINE_SPINLOCK(offload_lock);
+static DEFINE_SPINLOCK(skb_gso_app_lock);
 struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
 struct list_head ptype_all __read_mostly;	/* Taps */
 static struct list_head offload_base __read_mostly;
@@ -2725,6 +2726,52 @@ struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
 }
 EXPORT_SYMBOL(skb_mac_gso_segment);
 
+struct skb_gso_app *skb_gso_apps[SKB_GSO_APP_NUM];
+EXPORT_SYMBOL(skb_gso_apps);
+
+int skb_gso_app_register(const struct skb_gso_app *app)
+{
+	int i, ret = 0;
+
+	spin_lock(&skb_gso_app_lock);
+
+	for (i = 0; i < SKB_GSO_APP_NUM; i++) {
+		if (!rcu_dereference_protected(skb_gso_apps[i],
+				lockdep_is_held(&skb_gso_app_lock))) {
+			/* Found an empty slot */
+			rcu_assign_pointer(skb_gso_apps[i], app);
+
+			ret = skb_gso_app_to_gso_type(i);
+
+			break;
+		}
+	}
+
+	spin_unlock(&skb_gso_app_lock);
+
+	return ret;
+return 0;
+}
+EXPORT_SYMBOL(skb_gso_app_register);
+
+void skb_gso_app_unregister(int num, const struct skb_gso_app *app)
+{
+	if (!num)
+		return;
+
+	num = skb_gso_app_to_index(num);
+
+	spin_lock(&skb_gso_app_lock);
+
+	if (app == rcu_dereference_protected(skb_gso_apps[num],
+				lockdep_is_held(&skb_gso_app_lock))) {
+		/* Matched entry */
+		rcu_assign_pointer(skb_gso_apps[num], NULL);
+	}
+
+	spin_unlock(&skb_gso_app_lock);
+}
+EXPORT_SYMBOL(skb_gso_app_unregister);
 
 /* openvswitch calls this on rx path, so we need a different check.
  */
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 2f39479be92f..f2fd96d55c4e 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -171,6 +171,12 @@ int iptunnel_handle_offloads(struct sk_buff *skb,
 		err = skb_header_unclone(skb, GFP_ATOMIC);
 		if (unlikely(err))
 			return err;
+		if (!!(gso_type_mask & SKB_GSO_APP_MASK) &&
+		    !!(skb_shinfo(skb)->gso_type & SKB_GSO_APP_MASK)) {
+			/* Only allow one GSO app per packet */
+			return -EALREADY;
+		}
+
 		skb_shinfo(skb)->gso_type |= gso_type_mask;
 		return 0;
 	}
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 97658bfc1b58..ba58b36b35b2 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -152,19 +152,29 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 				       netdev_features_t features,
 				       bool is_ipv6)
 {
-	__be16 protocol = skb->protocol;
-	const struct net_offload **offloads;
-	const struct net_offload *ops;
-	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	struct sk_buff *(*gso_inner_segment)(struct sk_buff *skb,
 					     netdev_features_t features);
+	const struct net_offload **offloads;
+	__be16 protocol = skb->protocol;
+	struct skb_gso_app *gso_app;
+	const struct net_offload *ops;
+	struct sk_buff *segs;
+
+	segs = ERR_PTR(-EINVAL);
 
 	rcu_read_lock();
 
+	gso_app = skb_gso_app_lookup(skb, features,
+				     SKB_GSO_UDP_TUNNEL_CSUM |
+				     SKB_GSO_UDP_TUNNEL);
+
 	switch (skb->inner_protocol_type) {
 	case ENCAP_TYPE_ETHER:
 		protocol = skb->inner_protocol;
-		gso_inner_segment = skb_mac_gso_segment;
+		if (gso_app && gso_app->gso_segment)
+			gso_inner_segment = gso_app->gso_segment;
+		else
+			gso_inner_segment = skb_mac_gso_segment;
 		break;
 	case ENCAP_TYPE_IPPROTO:
 		offloads = is_ipv6 ? inet6_offloads : inet_offloads;
-- 
2.11.0
