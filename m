From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 7/8] net: introduce rx_handler results and logic around that
Date: Sat,  5 Mar 2011 09:29:53 +0100
Message-ID: <1299313794-5218-8-git-send-email-jpirko@redhat.com>
References: <1299313794-5218-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26175 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752415Ab1CEIaY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 03:30:24 -0500
In-Reply-To: <1299313794-5218-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_main.c |   20 +++++++++++---------
 drivers/net/macvlan.c           |   11 ++++++-----
 include/linux/netdevice.h       |    9 ++++++++-
 include/linux/skbuff.h          |    5 +----
 net/bridge/br_input.c           |   25 +++++++++++++++----------
 net/bridge/br_private.h         |    2 +-
 net/core/dev.c                  |   19 ++++++++++++-------
 7 files changed, 54 insertions(+), 37 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 8ba7faa..ab56190 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1483,20 +1483,23 @@ static bool bond_should_deliver_exact_match(struct sk_buff *skb,
 	return false;
 }
 
-static struct sk_buff *bond_handle_frame(struct sk_buff *skb)
+static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
 {
+	struct sk_buff *skb = *pskb;
 	struct slave *slave;
 	struct net_device *bond_dev;
 	struct bonding *bond;
 
-	skb = skb_share_check(skb, GFP_ATOMIC);
-	if (unlikely(!skb))
-		return NULL;
-
 	slave = bond_slave_get_rcu(skb->dev);
 	bond_dev = ACCESS_ONCE(slave->dev->master);
 	if (unlikely(!bond_dev))
-		return skb;
+		return RX_HANDLER_PASS;
+
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (unlikely(!skb))
+		return RX_HANDLER_CONSUMED;
+
+	*pskb = skb;
 
 	bond = netdev_priv(bond_dev);
 
@@ -1513,8 +1516,7 @@ static struct sk_buff *bond_handle_frame(struct sk_buff *skb)
 	}
 
 	if (bond_should_deliver_exact_match(skb, slave, bond)) {
-		skb->deliver_no_wcard = 1;
-		return skb;
+		return RX_HANDLER_EXACT;
 	}
 
 	skb->dev = bond_dev;
@@ -1527,7 +1529,7 @@ static struct sk_buff *bond_handle_frame(struct sk_buff *skb)
 		memcpy(dest, bond_dev->dev_addr, ETH_ALEN);
 	}
 
-	return skb;
+	return RX_HANDLER_ANOTHER;
 }
 
 /* enslave device <slave> to bond device <master> */
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 6ed577b..ead9a8f 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -152,9 +152,10 @@ static void macvlan_broadcast(struct sk_buff *skb,
 }
 
 /* called under rcu_read_lock() from netif_receive_skb */
-static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
+static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 {
 	struct macvlan_port *port;
+	struct sk_buff *skb = *pskb;
 	const struct ethhdr *eth = eth_hdr(skb);
 	const struct macvlan_dev *vlan;
 	const struct macvlan_dev *src;
@@ -184,7 +185,7 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 			 */
 			macvlan_broadcast(skb, port, src->dev,
 					  MACVLAN_MODE_VEPA);
-		return skb;
+		return RX_HANDLER_PASS;
 	}
 
 	if (port->passthru)
@@ -192,12 +193,12 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 	else
 		vlan = macvlan_hash_lookup(port, eth->h_dest);
 	if (vlan == NULL)
-		return skb;
+		return RX_HANDLER_PASS;
 
 	dev = vlan->dev;
 	if (unlikely(!(dev->flags & IFF_UP))) {
 		kfree_skb(skb);
-		return NULL;
+		return RX_HANDLER_CONSUMED;
 	}
 	len = skb->len + ETH_HLEN;
 	skb = skb_share_check(skb, GFP_ATOMIC);
@@ -211,7 +212,7 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 
 out:
 	macvlan_count_rx(vlan, len, ret == NET_RX_SUCCESS, 0);
-	return NULL;
+	return RX_HANDLER_CONSUMED;
 }
 
 static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8be4056..ff386a4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -390,7 +390,14 @@ enum gro_result {
 };
 typedef enum gro_result gro_result_t;
 
-typedef struct sk_buff *rx_handler_func_t(struct sk_buff *skb);
+enum rx_handler_result {
+	RX_HANDLER_CONSUMED,
+	RX_HANDLER_ANOTHER,
+	RX_HANDLER_EXACT,
+	RX_HANDLER_PASS,
+};
+typedef enum rx_handler_result rx_handler_result_t;
+typedef rx_handler_result_t rx_handler_func_t(struct sk_buff **pskb);
 
 extern void __napi_schedule(struct napi_struct *n);
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 31f02d0..24cfa62 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -388,10 +388,7 @@ struct sk_buff {
 	kmemcheck_bitfield_begin(flags2);
 	__u16			queue_mapping:16;
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
-	__u8			ndisc_nodetype:2,
-				deliver_no_wcard:1;
-#else
-	__u8			deliver_no_wcard:1;
+	__u8			ndisc_nodetype:2;
 #endif
 	__u8			ooo_okay:1;
 	kmemcheck_bitfield_end(flags2);
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 88e4aa9..e216079 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -139,21 +139,22 @@ static inline int is_link_local(const unsigned char *dest)
  * Return NULL if skb is handled
  * note: already called with rcu_read_lock
  */
-struct sk_buff *br_handle_frame(struct sk_buff *skb)
+rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 {
 	struct net_bridge_port *p;
+	struct sk_buff *skb = *pskb;
 	const unsigned char *dest = eth_hdr(skb)->h_dest;
 	br_should_route_hook_t *rhook;
 
 	if (unlikely(skb->pkt_type == PACKET_LOOPBACK))
-		return skb;
+		return RX_HANDLER_PASS;
 
 	if (!is_valid_ether_addr(eth_hdr(skb)->h_source))
 		goto drop;
 
 	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (!skb)
-		return NULL;
+		return RX_HANDLER_CONSUMED;
 
 	p = br_port_get_rcu(skb->dev);
 
@@ -167,10 +168,12 @@ struct sk_buff *br_handle_frame(struct sk_buff *skb)
 			goto forward;
 
 		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
-			    NULL, br_handle_local_finish))
-			return NULL;	/* frame consumed by filter */
-		else
-			return skb;	/* continue processing */
+			    NULL, br_handle_local_finish)) {
+			return RX_HANDLER_CONSUMED; /* consumed by filter */
+		} else {
+			*pskb = skb;
+			return RX_HANDLER_PASS;	/* continue processing */
+		}
 	}
 
 forward:
@@ -178,8 +181,10 @@ forward:
 	case BR_STATE_FORWARDING:
 		rhook = rcu_dereference(br_should_route_hook);
 		if (rhook) {
-			if ((*rhook)(skb))
-				return skb;
+			if ((*rhook)(skb)) {
+				*pskb = skb;
+				return RX_HANDLER_PASS;
+			}
 			dest = eth_hdr(skb)->h_dest;
 		}
 		/* fall through */
@@ -194,5 +199,5 @@ forward:
 drop:
 		kfree_skb(skb);
 	}
-	return NULL;
+	return RX_HANDLER_CONSUMED;
 }
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index f7afc36..19e2f46 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -379,7 +379,7 @@ extern void br_features_recompute(struct net_bridge *br);
 
 /* br_input.c */
 extern int br_handle_frame_finish(struct sk_buff *skb);
-extern struct sk_buff *br_handle_frame(struct sk_buff *skb);
+extern rx_handler_result_t br_handle_frame(struct sk_buff **pskb);
 
 /* br_ioctl.c */
 extern int br_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
diff --git a/net/core/dev.c b/net/core/dev.c
index 9f66de9..58daddb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3121,6 +3121,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	rx_handler_func_t *rx_handler;
 	struct net_device *orig_dev;
 	struct net_device *null_or_dev;
+	bool deliver_exact = false;
 	int ret = NET_RX_DROP;
 	__be16 type;
 
@@ -3173,18 +3174,22 @@ ncls:
 
 	rx_handler = rcu_dereference(skb->dev->rx_handler);
 	if (rx_handler) {
-		struct net_device *prev_dev;
-
 		if (pt_prev) {
 			ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = NULL;
 		}
-		prev_dev = skb->dev;
-		skb = rx_handler(skb);
-		if (!skb)
+		switch (rx_handler(&skb)) {
+		case RX_HANDLER_CONSUMED:
 			goto out;
-		if (skb->dev != prev_dev)
+		case RX_HANDLER_ANOTHER:
 			goto another_round;
+		case RX_HANDLER_EXACT:
+			deliver_exact = true;
+		case RX_HANDLER_PASS:
+			break;
+		default:
+			BUG();
+		}
 	}
 
 	if (vlan_tx_tag_present(skb)) {
@@ -3202,7 +3207,7 @@ ncls:
 	vlan_on_bond_hook(skb);
 
 	/* deliver only exact match when indicated */
-	null_or_dev = skb->deliver_no_wcard ? skb->dev : NULL;
+	null_or_dev = deliver_exact ? skb->dev : NULL;
 
 	type = skb->protocol;
 	list_for_each_entry_rcu(ptype,
-- 
1.7.4

