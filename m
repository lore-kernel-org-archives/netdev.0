From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 7/8 v2] net: introduce rx_handler results and
 logic around that
Date: Sat, 5 Mar 2011 16:31:20 +0100
Message-ID: <20110305153120.GG8573@psychotron.redhat.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com>
 <1299320969-7951-8-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12372 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753099Ab1CEPbf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 10:31:35 -0500
Content-Disposition: inline
In-Reply-To: <1299320969-7951-8-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows rx_handlers to better signalize what to do next to
it's caller. That makes skb->deliver_no_wcard no longer needed.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

v1->v2:
	moved __copy_skb_header hunk from 8/8 here

---
 drivers/net/bonding/bond_main.c |   20 +++++++++++---------
 drivers/net/macvlan.c           |   11 ++++++-----
 include/linux/netdevice.h       |    9 ++++++++-
 include/linux/skbuff.h          |    5 +----
 net/bridge/br_input.c           |   25 +++++++++++++++----------
 net/bridge/br_private.h         |    2 +-
 net/core/dev.c                  |   19 ++++++++++++-------
 net/core/skbuff.c               |    1 -
 8 files changed, 54 insertions(+), 38 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 8ba7faa..ab56190 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1483,20 +1483,23 @@ static bool bond_should_deliver_exact_match(str=
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
@@ -1513,8 +1516,7 @@ static struct sk_buff *bond_handle_frame(struct s=
k_buff *skb)
 	}
=20
 	if (bond_should_deliver_exact_match(skb, slave, bond)) {
-		skb->deliver_no_wcard =3D 1;
-		return skb;
+		return RX_HANDLER_EXACT;
 	}
=20
 	skb->dev =3D bond_dev;
@@ -1527,7 +1529,7 @@ static struct sk_buff *bond_handle_frame(struct s=
k_buff *skb)
 		memcpy(dest, bond_dev->dev_addr, ETH_ALEN);
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
index 8be4056..ff386a4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -390,7 +390,14 @@ enum gro_result {
 };
 typedef enum gro_result gro_result_t;
=20
-typedef struct sk_buff *rx_handler_func_t(struct sk_buff *skb);
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
index 9f66de9..58daddb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3121,6 +3121,7 @@ static int __netif_receive_skb(struct sk_buff *sk=
b)
 	rx_handler_func_t *rx_handler;
 	struct net_device *orig_dev;
 	struct net_device *null_or_dev;
+	bool deliver_exact =3D false;
 	int ret =3D NET_RX_DROP;
 	__be16 type;
=20
@@ -3173,18 +3174,22 @@ ncls:
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
@@ -3202,7 +3207,7 @@ ncls:
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

