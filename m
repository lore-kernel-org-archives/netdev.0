From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 6/6] net: introduce rx_handler results and logic around that
Date: Sat, 12 Mar 2011 14:14:39 +0100
Message-ID: <1299935679-18135-7-git-send-email-jpirko@redhat.com>
References: <1299935679-18135-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net, xiaosuo@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37401 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752858Ab1CLNP1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 08:15:27 -0500
In-Reply-To: <1299935679-18135-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows rx_handlers to better signalize what to do next to
it's caller. That makes skb->deliver_no_wcard no longer needed.

kernel-doc for rx_handler_result is taken from Nicolas' patch.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
eviewed-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
---
 drivers/net/bonding/bond_main.c |   22 +++++++++-------
 drivers/net/macvlan.c           |   11 ++++----
 include/linux/netdevice.h       |   50 +++++++++++++++++++++++++++++++=
+++++++-
 include/linux/skbuff.h          |    5 +---
 net/bridge/br_input.c           |   25 +++++++++++-------
 net/bridge/br_private.h         |    2 +-
 net/core/dev.c                  |   21 +++++++++++-----
 net/core/skbuff.c               |    1 -
 8 files changed, 98 insertions(+), 39 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index c3150df..fdba1a1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1480,20 +1480,23 @@ static bool bond_should_deliver_exact_match(str=
uct sk_buff *skb,
 	return false;
 }
=20
-static struct sk_buff *bond_handle_frame(struct sk_buff *skb)
+static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
 {
+	struct sk_buff *skb =3D *pskb;
 	struct slave *slave;
 	struct net_device *bond_dev;
 	struct bonding *bond;
=20
-	skb =3D skb_share_check(skb, GFP_ATOMIC);
-	if (unlikely(!skb))
-		return NULL;
-
 	slave =3D bond_slave_get_rcu(skb->dev);
 	bond_dev =3D ACCESS_ONCE(slave->dev->master);
 	if (unlikely(!bond_dev))
-		return skb;
+		return RX_HANDLER_PASS;
+
+	skb =3D skb_share_check(skb, GFP_ATOMIC);
+	if (unlikely(!skb))
+		return RX_HANDLER_CONSUMED;
+
+	*pskb =3D skb;
=20
 	bond =3D netdev_priv(bond_dev);
=20
@@ -1501,8 +1504,7 @@ static struct sk_buff *bond_handle_frame(struct s=
k_buff *skb)
 		slave->dev->last_rx =3D jiffies;
=20
 	if (bond_should_deliver_exact_match(skb, slave, bond)) {
-		skb->deliver_no_wcard =3D 1;
-		return skb;
+		return RX_HANDLER_EXACT;
 	}
=20
 	skb->dev =3D bond_dev;
@@ -1514,12 +1516,12 @@ static struct sk_buff *bond_handle_frame(struct=
 sk_buff *skb)
 		if (unlikely(skb_cow_head(skb,
 					  skb->data - skb_mac_header(skb)))) {
 			kfree_skb(skb);
-			return NULL;
+			return RX_HANDLER_CONSUMED;
 		}
 		memcpy(eth_hdr(skb)->h_dest, bond_dev->dev_addr, ETH_ALEN);
 	}
=20
-	return skb;
+	return RX_HANDLER_ANOTHER;
 }
=20
 /* enslave device <slave> to bond device <master> */
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 6ed577b..ead9a8f 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -152,9 +152,10 @@ static void macvlan_broadcast(struct sk_buff *skb,
 }
=20
 /* called under rcu_read_lock() from netif_receive_skb */
-static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
+static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 {
 	struct macvlan_port *port;
+	struct sk_buff *skb =3D *pskb;
 	const struct ethhdr *eth =3D eth_hdr(skb);
 	const struct macvlan_dev *vlan;
 	const struct macvlan_dev *src;
@@ -184,7 +185,7 @@ static struct sk_buff *macvlan_handle_frame(struct =
sk_buff *skb)
 			 */
 			macvlan_broadcast(skb, port, src->dev,
 					  MACVLAN_MODE_VEPA);
-		return skb;
+		return RX_HANDLER_PASS;
 	}
=20
 	if (port->passthru)
@@ -192,12 +193,12 @@ static struct sk_buff *macvlan_handle_frame(struc=
t sk_buff *skb)
 	else
 		vlan =3D macvlan_hash_lookup(port, eth->h_dest);
 	if (vlan =3D=3D NULL)
-		return skb;
+		return RX_HANDLER_PASS;
=20
 	dev =3D vlan->dev;
 	if (unlikely(!(dev->flags & IFF_UP))) {
 		kfree_skb(skb);
-		return NULL;
+		return RX_HANDLER_CONSUMED;
 	}
 	len =3D skb->len + ETH_HLEN;
 	skb =3D skb_share_check(skb, GFP_ATOMIC);
@@ -211,7 +212,7 @@ static struct sk_buff *macvlan_handle_frame(struct =
sk_buff *skb)
=20
 out:
 	macvlan_count_rx(vlan, len, ret =3D=3D NET_RX_SUCCESS, 0);
-	return NULL;
+	return RX_HANDLER_CONSUMED;
 }
=20
 static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *=
dev)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6bd5d46..6275a95 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -390,7 +390,55 @@ enum gro_result {
 };
 typedef enum gro_result gro_result_t;
=20
-typedef struct sk_buff *rx_handler_func_t(struct sk_buff *skb);
+/*
+ * enum rx_handler_result - Possible return values for rx_handlers.
+ * @RX_HANDLER_CONSUMED: skb was consumed by rx_handler, do not proces=
s it
+ * further.
+ * @RX_HANDLER_ANOTHER: Do another round in receive path. This is indi=
cated in
+ * case skb->dev was changed by rx_handler.
+ * @RX_HANDLER_EXACT: Force exact delivery, no wildcard.
+ * @RX_HANDLER_PASS: Do nothing, passe the skb as if no rx_handler was=
 called.
+ *
+ * rx_handlers are functions called from inside __netif_receive_skb(),=
 to do
+ * special processing of the skb, prior to delivery to protocol handle=
rs.
+ *
+ * Currently, a net_device can only have a single rx_handler registere=
d. Trying
+ * to register a second rx_handler will return -EBUSY.
+ *
+ * To register a rx_handler on a net_device, use netdev_rx_handler_reg=
ister().
+ * To unregister a rx_handler on a net_device, use
+ * netdev_rx_handler_unregister().
+ *
+ * Upon return, rx_handler is expected to tell __netif_receive_skb() w=
hat to
+ * do with the skb.
+ *
+ * If the rx_handler consumed to skb in some way, it should return
+ * RX_HANDLER_CONSUMED. This is appropriate when the rx_handler arrang=
ed for
+ * the skb to be delivered in some other ways.
+ *
+ * If the rx_handler changed skb->dev, to divert the skb to another
+ * net_device, it should return RX_HANDLER_ANOTHER. The rx_handler for=
 the
+ * new device will be called if it exists.
+ *
+ * If the rx_handler consider the skb should be ignored, it should ret=
urn
+ * RX_HANDLER_EXACT. The skb will only be delivered to protocol handle=
rs that
+ * are registred on exact device (ptype->dev =3D=3D skb->dev).
+ *
+ * If the rx_handler didn't changed skb->dev, but want the skb to be n=
ormally
+ * delivered, it should return RX_HANDLER_PASS.
+ *
+ * A device without a registered rx_handler will behave as if rx_handl=
er
+ * returned RX_HANDLER_PASS.
+ */
+
+enum rx_handler_result {
+	RX_HANDLER_CONSUMED,
+	RX_HANDLER_ANOTHER,
+	RX_HANDLER_EXACT,
+	RX_HANDLER_PASS,
+};
+typedef enum rx_handler_result rx_handler_result_t;
+typedef rx_handler_result_t rx_handler_func_t(struct sk_buff **pskb);
=20
 extern void __napi_schedule(struct napi_struct *n);
=20
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
@@ -139,21 +139,22 @@ static inline int is_link_local(const unsigned ch=
ar *dest)
  * Return NULL if skb is handled
  * note: already called with rcu_read_lock
  */
-struct sk_buff *br_handle_frame(struct sk_buff *skb)
+rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 {
 	struct net_bridge_port *p;
+	struct sk_buff *skb =3D *pskb;
 	const unsigned char *dest =3D eth_hdr(skb)->h_dest;
 	br_should_route_hook_t *rhook;
=20
 	if (unlikely(skb->pkt_type =3D=3D PACKET_LOOPBACK))
-		return skb;
+		return RX_HANDLER_PASS;
=20
 	if (!is_valid_ether_addr(eth_hdr(skb)->h_source))
 		goto drop;
=20
 	skb =3D skb_share_check(skb, GFP_ATOMIC);
 	if (!skb)
-		return NULL;
+		return RX_HANDLER_CONSUMED;
=20
 	p =3D br_port_get_rcu(skb->dev);
=20
@@ -167,10 +168,12 @@ struct sk_buff *br_handle_frame(struct sk_buff *s=
kb)
 			goto forward;
=20
 		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
-			    NULL, br_handle_local_finish))
-			return NULL;	/* frame consumed by filter */
-		else
-			return skb;	/* continue processing */
+			    NULL, br_handle_local_finish)) {
+			return RX_HANDLER_CONSUMED; /* consumed by filter */
+		} else {
+			*pskb =3D skb;
+			return RX_HANDLER_PASS;	/* continue processing */
+		}
 	}
=20
 forward:
@@ -178,8 +181,10 @@ forward:
 	case BR_STATE_FORWARDING:
 		rhook =3D rcu_dereference(br_should_route_hook);
 		if (rhook) {
-			if ((*rhook)(skb))
-				return skb;
+			if ((*rhook)(skb)) {
+				*pskb =3D skb;
+				return RX_HANDLER_PASS;
+			}
 			dest =3D eth_hdr(skb)->h_dest;
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
@@ -379,7 +379,7 @@ extern void br_features_recompute(struct net_bridge=
 *br);
=20
 /* br_input.c */
 extern int br_handle_frame_finish(struct sk_buff *skb);
-extern struct sk_buff *br_handle_frame(struct sk_buff *skb);
+extern rx_handler_result_t br_handle_frame(struct sk_buff **pskb);
=20
 /* br_ioctl.c */
 extern int br_dev_ioctl(struct net_device *dev, struct ifreq *rq, int =
cmd);
diff --git a/net/core/dev.c b/net/core/dev.c
index 9f66de9..329e670 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3062,6 +3062,8 @@ out:
  *	on a failure.
  *
  *	The caller must hold the rtnl_mutex.
+ *
+ *	For a general description of rx_handler, see enum rx_handler_result=
=2E
  */
 int netdev_rx_handler_register(struct net_device *dev,
 			       rx_handler_func_t *rx_handler,
@@ -3121,6 +3123,7 @@ static int __netif_receive_skb(struct sk_buff *sk=
b)
 	rx_handler_func_t *rx_handler;
 	struct net_device *orig_dev;
 	struct net_device *null_or_dev;
+	bool deliver_exact =3D false;
 	int ret =3D NET_RX_DROP;
 	__be16 type;
=20
@@ -3173,18 +3176,22 @@ ncls:
=20
 	rx_handler =3D rcu_dereference(skb->dev->rx_handler);
 	if (rx_handler) {
-		struct net_device *prev_dev;
-
 		if (pt_prev) {
 			ret =3D deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev =3D NULL;
 		}
-		prev_dev =3D skb->dev;
-		skb =3D rx_handler(skb);
-		if (!skb)
+		switch (rx_handler(&skb)) {
+		case RX_HANDLER_CONSUMED:
 			goto out;
-		if (skb->dev !=3D prev_dev)
+		case RX_HANDLER_ANOTHER:
 			goto another_round;
+		case RX_HANDLER_EXACT:
+			deliver_exact =3D true;
+		case RX_HANDLER_PASS:
+			break;
+		default:
+			BUG();
+		}
 	}
=20
 	if (vlan_tx_tag_present(skb)) {
@@ -3202,7 +3209,7 @@ ncls:
 	vlan_on_bond_hook(skb);
=20
 	/* deliver only exact match when indicated */
-	null_or_dev =3D skb->deliver_no_wcard ? skb->dev : NULL;
+	null_or_dev =3D deliver_exact ? skb->dev : NULL;
=20
 	type =3D skb->protocol;
 	list_for_each_entry_rcu(ptype,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 1eb526a..801dd08 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -523,7 +523,6 @@ static void __copy_skb_header(struct sk_buff *new, =
const struct sk_buff *old)
 	new->ip_summed		=3D old->ip_summed;
 	skb_copy_queue_mapping(new, old);
 	new->priority		=3D old->priority;
-	new->deliver_no_wcard	=3D old->deliver_no_wcard;
 #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
 	new->ipvs_property	=3D old->ipvs_property;
 #endif
--=20
1.7.4

