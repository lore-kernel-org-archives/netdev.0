From: Arvid Brodin <arvid.brodin@alten.se>
Subject: [PATCH net-next 02/10] net/hsr: Switch from dev_add_pack() to netdev_rx_handler_register()
Date: Fri, 4 Jul 2014 23:35:24 +0200
Message-ID: <53B71E1C.1030806@alten.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:51646 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760187AbaGDVkx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2014 17:40:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also move the frame receive handler to hsr_slave.c.

Signed-off-by: Arvid Brodin <arvid.brodin@alten.se>
---
 net/hsr/Makefile     |   3 +-
 net/hsr/hsr_device.c |  13 ++-
 net/hsr/hsr_main.c   | 248 +------------------------------------------=
--------
 net/hsr/hsr_main.h   |   3 +
 net/hsr/hsr_slave.c  | 243 +++++++++++++++++++++++++++++++++++++++++++=
++++++
 net/hsr/hsr_slave.h  |  20 +++++
 6 files changed, 283 insertions(+), 247 deletions(-)
 create mode 100644 net/hsr/hsr_slave.c
 create mode 100644 net/hsr/hsr_slave.h

diff --git a/net/hsr/Makefile b/net/hsr/Makefile
index b68359f..b533b24 100644
--- a/net/hsr/Makefile
+++ b/net/hsr/Makefile
@@ -4,4 +4,5 @@
=20
 obj-$(CONFIG_HSR)	+=3D hsr.o
=20
-hsr-y			:=3D hsr_main.o hsr_framereg.o hsr_device.o hsr_netlink.o
+hsr-y			:=3D hsr_main.o hsr_framereg.o hsr_device.o hsr_netlink.o \
+			   hsr_slave.o
diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
index 4dc2a42..4e5d92a 100644
--- a/net/hsr/hsr_device.c
+++ b/net/hsr/hsr_device.c
@@ -19,6 +19,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/pkt_sched.h>
 #include "hsr_device.h"
+#include "hsr_slave.h"
 #include "hsr_framereg.h"
 #include "hsr_main.h"
=20
@@ -393,7 +394,6 @@ static void restore_slaves(struct net_device *hsr_d=
ev)
=20
 	rtnl_lock();
=20
-	/* Restore promiscuity */
 	for (i =3D 0; i < HSR_MAX_SLAVE; i++) {
 		if (!hsr->slave[i])
 			continue;
@@ -402,8 +402,12 @@ static void restore_slaves(struct net_device *hsr_=
dev)
 			netdev_info(hsr_dev,
 				    "Cannot restore slave promiscuity (%s, %d)\n",
 				    hsr->slave[i]->name, res);
+
+		if (hsr->slave[i]->rx_handler =3D=3D hsr_handle_frame)
+			netdev_rx_handler_unregister(hsr->slave[i]);
 	}
=20
+
 	rtnl_unlock();
 }
=20
@@ -575,6 +579,13 @@ int hsr_dev_finalize(struct net_device *hsr_dev, s=
truct net_device *slave[2],
 		}
 	}
=20
+	for (i =3D 0; i < HSR_MAX_SLAVE; i++) {
+		res =3D netdev_rx_handler_register(slave[i], hsr_handle_frame,
+						 hsr);
+		if (res)
+			goto fail;
+	}
+
 	/* Make sure we recognize frames from ourselves in hsr_rcv() */
 	res =3D hsr_create_self_node(&hsr->self_node_db, hsr_dev->dev_addr,
 				   hsr->slave[1]->dev_addr);
diff --git a/net/hsr/hsr_main.c b/net/hsr/hsr_main.c
index 99b8fc4..bcda901 100644
--- a/net/hsr/hsr_main.c
+++ b/net/hsr/hsr_main.c
@@ -7,10 +7,6 @@
  *
  * Author(s):
  *	2011-2014 Arvid Brodin, arvid.brodin@alten.se
- *
- * In addition to routines for registering and unregistering HSR suppo=
rt, this
- * file also contains the receive routine that handles all incoming fr=
ames with
- * Ethertype (protocol) ETH_P_PRP (HSRv0), and network device event ha=
ndling.
  */
=20
 #include <linux/netdevice.h>
@@ -56,11 +52,10 @@ bool is_hsr_slave(struct net_device *dev)
 	return false;
 }
=20
-
 /* If dev is a HSR slave device, return the virtual master device. Ret=
urn NULL
  * otherwise.
  */
-static struct hsr_priv *get_hsr_master(struct net_device *dev)
+struct hsr_priv *get_hsr_master(struct net_device *dev)
 {
 	struct hsr_priv *hsr;
=20
@@ -76,12 +71,11 @@ static struct hsr_priv *get_hsr_master(struct net_d=
evice *dev)
 	return NULL;
 }
=20
-
 /* If dev is a HSR slave device, return the other slave device. Return=
 NULL
  * otherwise.
  */
-static struct net_device *get_other_slave(struct hsr_priv *hsr,
-					  struct net_device *dev)
+struct net_device *get_other_slave(struct hsr_priv *hsr,
+				   struct net_device *dev)
 {
 	if (dev =3D=3D hsr->slave[0])
 		return hsr->slave[1];
@@ -197,239 +191,6 @@ static void prune_nodes_all(unsigned long data)
 }
=20
=20
-static struct sk_buff *hsr_pull_tag(struct sk_buff *skb)
-{
-	struct hsr_tag *hsr_tag;
-	struct sk_buff *skb2;
-
-	skb2 =3D skb_share_check(skb, GFP_ATOMIC);
-	if (unlikely(!skb2))
-		goto err_free;
-	skb =3D skb2;
-
-	if (unlikely(!pskb_may_pull(skb, HSR_HLEN)))
-		goto err_free;
-
-	hsr_tag =3D (struct hsr_tag *) skb->data;
-	skb->protocol =3D hsr_tag->encap_proto;
-	skb_pull(skb, HSR_HLEN);
-
-	return skb;
-
-err_free:
-	kfree_skb(skb);
-	return NULL;
-}
-
-
-/* The uses I can see for these HSR supervision frames are:
- * 1) Use the frames that are sent after node initialization ("HSR_TLV=
=2EType =3D
- *    22") to reset any sequence_nr counters belonging to that node. U=
seful if
- *    the other node's counter has been reset for some reason.
- *    --
- *    Or not - resetting the counter and bridging the frame would crea=
te a
- *    loop, unfortunately.
- *
- * 2) Use the LifeCheck frames to detect ring breaks. I.e. if no LifeC=
heck
- *    frame is received from a particular node, we know something is w=
rong.
- *    We just register these (as with normal frames) and throw them aw=
ay.
- *
- * 3) Allow different MAC addresses for the two slave interfaces, usin=
g the
- *    MacAddressA field.
- */
-static bool is_supervision_frame(struct hsr_priv *hsr, struct sk_buff =
*skb)
-{
-	struct hsr_sup_tag *hsr_stag;
-
-	if (!ether_addr_equal(eth_hdr(skb)->h_dest,
-			      hsr->sup_multicast_addr))
-		return false;
-
-	hsr_stag =3D (struct hsr_sup_tag *) skb->data;
-	if (get_hsr_stag_path(hsr_stag) !=3D 0x0f)
-		return false;
-	if ((hsr_stag->HSR_TLV_Type !=3D HSR_TLV_ANNOUNCE) &&
-	    (hsr_stag->HSR_TLV_Type !=3D HSR_TLV_LIFE_CHECK))
-		return false;
-	if (hsr_stag->HSR_TLV_Length !=3D 12)
-		return false;
-
-	return true;
-}
-
-
-/* Implementation somewhat according to IEC-62439-3, p. 43
- */
-static int hsr_rcv(struct sk_buff *skb, struct net_device *dev,
-		   struct packet_type *pt, struct net_device *orig_dev)
-{
-	struct hsr_priv *hsr;
-	struct net_device *other_slave;
-	struct hsr_node *node;
-	bool deliver_to_self;
-	struct sk_buff *skb_deliver;
-	enum hsr_dev_idx dev_in_idx, dev_other_idx;
-	bool dup_out;
-	int ret;
-
-	hsr =3D get_hsr_master(dev);
-
-	if (!hsr) {
-		/* Non-HSR-slave device 'dev' is connected to a HSR network */
-		kfree_skb(skb);
-		dev->stats.rx_errors++;
-		return NET_RX_SUCCESS;
-	}
-
-	if (dev =3D=3D hsr->slave[0]) {
-		dev_in_idx =3D HSR_DEV_SLAVE_A;
-		dev_other_idx =3D HSR_DEV_SLAVE_B;
-	} else {
-		dev_in_idx =3D HSR_DEV_SLAVE_B;
-		dev_other_idx =3D HSR_DEV_SLAVE_A;
-	}
-
-	node =3D hsr_find_node(&hsr->self_node_db, skb);
-	if (node) {
-		/* Always kill frames sent by ourselves */
-		kfree_skb(skb);
-		return NET_RX_SUCCESS;
-	}
-
-	/* Is this frame a candidate for local reception? */
-	deliver_to_self =3D false;
-	if ((skb->pkt_type =3D=3D PACKET_HOST) ||
-	    (skb->pkt_type =3D=3D PACKET_MULTICAST) ||
-	    (skb->pkt_type =3D=3D PACKET_BROADCAST))
-		deliver_to_self =3D true;
-	else if (ether_addr_equal(eth_hdr(skb)->h_dest,
-				     hsr->dev->dev_addr)) {
-		skb->pkt_type =3D PACKET_HOST;
-		deliver_to_self =3D true;
-	}
-
-
-	rcu_read_lock(); /* node_db */
-	node =3D hsr_find_node(&hsr->node_db, skb);
-
-	if (is_supervision_frame(hsr, skb)) {
-		skb_pull(skb, sizeof(struct hsr_sup_tag));
-		node =3D hsr_merge_node(hsr, node, skb, dev_in_idx);
-		if (!node) {
-			rcu_read_unlock(); /* node_db */
-			kfree_skb(skb);
-			hsr->dev->stats.rx_dropped++;
-			return NET_RX_DROP;
-		}
-		skb_push(skb, sizeof(struct hsr_sup_tag));
-		deliver_to_self =3D false;
-	}
-
-	if (!node) {
-		/* Source node unknown; this might be a HSR frame from
-		 * another net (different multicast address). Ignore it.
-		 */
-		rcu_read_unlock(); /* node_db */
-		kfree_skb(skb);
-		return NET_RX_SUCCESS;
-	}
-
-	/* Register ALL incoming frames as outgoing through the other interfa=
ce.
-	 * This allows us to register frames as incoming only if they are val=
id
-	 * for the receiving interface, without using a specific counter for
-	 * incoming frames.
-	 */
-	dup_out =3D hsr_register_frame_out(node, dev_other_idx, skb);
-	if (!dup_out)
-		hsr_register_frame_in(node, dev_in_idx);
-
-	/* Forward this frame? */
-	if (!dup_out && (skb->pkt_type !=3D PACKET_HOST))
-		other_slave =3D get_other_slave(hsr, dev);
-	else
-		other_slave =3D NULL;
-
-	if (hsr_register_frame_out(node, HSR_DEV_MASTER, skb))
-		deliver_to_self =3D false;
-
-	rcu_read_unlock(); /* node_db */
-
-	if (!deliver_to_self && !other_slave) {
-		kfree_skb(skb);
-		/* Circulated frame; silently remove it. */
-		return NET_RX_SUCCESS;
-	}
-
-	skb_deliver =3D skb;
-	if (deliver_to_self && other_slave) {
-		/* skb_clone() is not enough since we will strip the hsr tag
-		 * and do address substitution below
-		 */
-		skb_deliver =3D pskb_copy(skb, GFP_ATOMIC);
-		if (!skb_deliver) {
-			deliver_to_self =3D false;
-			hsr->dev->stats.rx_dropped++;
-		}
-	}
-
-	if (deliver_to_self) {
-		bool multicast_frame;
-
-		skb_deliver =3D hsr_pull_tag(skb_deliver);
-		if (!skb_deliver) {
-			hsr->dev->stats.rx_dropped++;
-			goto forward;
-		}
-#if !defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
-		/* Move everything in the header that is after the HSR tag,
-		 * to work around alignment problems caused by the 6-byte HSR
-		 * tag. In practice, this removes/overwrites the HSR tag in
-		 * the header and restores a "standard" packet.
-		 */
-		memmove(skb_deliver->data - HSR_HLEN, skb_deliver->data,
-			skb_headlen(skb_deliver));
-
-		/* Adjust skb members so they correspond with the move above.
-		 * This cannot possibly underflow skb->data since hsr_pull_tag()
-		 * above succeeded.
-		 * At this point in the protocol stack, the transport and
-		 * network headers have not been set yet, and we haven't touched
-		 * the mac header nor the head. So we only need to adjust data
-		 * and tail:
-		 */
-		skb_deliver->data -=3D HSR_HLEN;
-		skb_deliver->tail -=3D HSR_HLEN;
-#endif
-		skb_deliver->dev =3D hsr->dev;
-		hsr_addr_subst_source(hsr, skb_deliver);
-		multicast_frame =3D (skb_deliver->pkt_type =3D=3D PACKET_MULTICAST);
-		ret =3D netif_rx(skb_deliver);
-		if (ret =3D=3D NET_RX_DROP) {
-			hsr->dev->stats.rx_dropped++;
-		} else {
-			hsr->dev->stats.rx_packets++;
-			hsr->dev->stats.rx_bytes +=3D skb->len;
-			if (multicast_frame)
-				hsr->dev->stats.multicast++;
-		}
-	}
-
-forward:
-	if (other_slave) {
-		skb_push(skb, ETH_HLEN);
-		skb->dev =3D other_slave;
-		dev_queue_xmit(skb);
-	}
-
-	return NET_RX_SUCCESS;
-}
-
-
-static struct packet_type hsr_pt __read_mostly =3D {
-	.type =3D htons(ETH_P_PRP),
-	.func =3D hsr_rcv,
-};
-
 static struct notifier_block hsr_nb =3D {
 	.notifier_call =3D hsr_netdev_notify,	/* Slave event notifications */
 };
@@ -441,8 +202,6 @@ static int __init hsr_init(void)
=20
 	BUILD_BUG_ON(sizeof(struct hsr_tag) !=3D HSR_HLEN);
=20
-	dev_add_pack(&hsr_pt);
-
 	init_timer(&prune_timer);
 	prune_timer.function =3D prune_nodes_all;
 	prune_timer.data =3D 0;
@@ -461,7 +220,6 @@ static void __exit hsr_exit(void)
 	unregister_netdevice_notifier(&hsr_nb);
 	del_timer_sync(&prune_timer);
 	hsr_netlink_exit();
-	dev_remove_pack(&hsr_pt);
 }
=20
 module_init(hsr_init);
diff --git a/net/hsr/hsr_main.h b/net/hsr/hsr_main.h
index 360a49a..d919321 100644
--- a/net/hsr/hsr_main.h
+++ b/net/hsr/hsr_main.h
@@ -162,5 +162,8 @@ struct hsr_priv {
 void register_hsr_master(struct hsr_priv *hsr);
 void unregister_hsr_master(struct hsr_priv *hsr);
 bool is_hsr_slave(struct net_device *dev);
+struct hsr_priv *get_hsr_master(struct net_device *dev);
+struct net_device *get_other_slave(struct hsr_priv *hsr,
+				   struct net_device *dev);
=20
 #endif /*  __HSR_PRIVATE_H */
diff --git a/net/hsr/hsr_slave.c b/net/hsr/hsr_slave.c
new file mode 100644
index 0000000..7028146
--- /dev/null
+++ b/net/hsr/hsr_slave.c
@@ -0,0 +1,243 @@
+/* Copyright 2011-2014 Autronica Fire and Security AS
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of the GNU General Public License as published by t=
he Free
+ * Software Foundation; either version 2 of the License, or (at your o=
ption)
+ * any later version.
+ *
+ * Author(s):
+ *	2011-2014 Arvid Brodin, arvid.brodin@alten.se
+ */
+
+#include "hsr_slave.h"
+#include <linux/etherdevice.h>
+#include "hsr_main.h"
+#include "hsr_framereg.h"
+
+
+static struct sk_buff *hsr_pull_tag(struct sk_buff *skb)
+{
+	struct hsr_tag *hsr_tag;
+	struct sk_buff *skb2;
+
+	skb2 =3D skb_share_check(skb, GFP_ATOMIC);
+	if (unlikely(!skb2))
+		goto err_free;
+	skb =3D skb2;
+
+	if (unlikely(!pskb_may_pull(skb, HSR_HLEN)))
+		goto err_free;
+
+	hsr_tag =3D (struct hsr_tag *) skb->data;
+	skb->protocol =3D hsr_tag->encap_proto;
+	skb_pull(skb, HSR_HLEN);
+
+	return skb;
+
+err_free:
+	kfree_skb(skb);
+	return NULL;
+}
+
+
+/* The uses I can see for these HSR supervision frames are:
+ * 1) Use the frames that are sent after node initialization ("HSR_TLV=
=2EType =3D
+ *    22") to reset any sequence_nr counters belonging to that node. U=
seful if
+ *    the other node's counter has been reset for some reason.
+ *    --
+ *    Or not - resetting the counter and bridging the frame would crea=
te a
+ *    loop, unfortunately.
+ *
+ * 2) Use the LifeCheck frames to detect ring breaks. I.e. if no LifeC=
heck
+ *    frame is received from a particular node, we know something is w=
rong.
+ *    We just register these (as with normal frames) and throw them aw=
ay.
+ *
+ * 3) Allow different MAC addresses for the two slave interfaces, usin=
g the
+ *    MacAddressA field.
+ */
+static bool is_supervision_frame(struct hsr_priv *hsr, struct sk_buff =
*skb)
+{
+	struct hsr_sup_tag *hsr_stag;
+
+	if (!ether_addr_equal(eth_hdr(skb)->h_dest,
+			      hsr->sup_multicast_addr))
+		return false;
+
+	hsr_stag =3D (struct hsr_sup_tag *) skb->data;
+	if (get_hsr_stag_path(hsr_stag) !=3D 0x0f)
+		return false;
+	if ((hsr_stag->HSR_TLV_Type !=3D HSR_TLV_ANNOUNCE) &&
+	    (hsr_stag->HSR_TLV_Type !=3D HSR_TLV_LIFE_CHECK))
+		return false;
+	if (hsr_stag->HSR_TLV_Length !=3D 12)
+		return false;
+
+	return true;
+}
+
+
+/* Implementation somewhat according to IEC-62439-3, p. 43
+ */
+rx_handler_result_t hsr_handle_frame(struct sk_buff **pskb)
+{
+	struct sk_buff *skb =3D *pskb;
+	struct net_device *dev =3D skb->dev;
+	struct hsr_priv *hsr;
+	struct net_device *other_slave;
+	struct hsr_node *node;
+	bool deliver_to_self;
+	struct sk_buff *skb_deliver;
+	enum hsr_dev_idx dev_in_idx, dev_other_idx;
+	bool dup_out;
+	int ret;
+
+	if (eth_hdr(skb)->h_proto !=3D htons(ETH_P_PRP))
+		return RX_HANDLER_PASS;
+
+	hsr =3D get_hsr_master(dev);
+	if (!hsr) {
+		WARN_ON_ONCE(1);
+		return RX_HANDLER_PASS;
+	}
+
+	if (dev =3D=3D hsr->slave[0]) {
+		dev_in_idx =3D HSR_DEV_SLAVE_A;
+		dev_other_idx =3D HSR_DEV_SLAVE_B;
+	} else {
+		dev_in_idx =3D HSR_DEV_SLAVE_B;
+		dev_other_idx =3D HSR_DEV_SLAVE_A;
+	}
+
+	node =3D hsr_find_node(&hsr->self_node_db, skb);
+	if (node) {
+		/* Always kill frames sent by ourselves */
+		kfree_skb(skb);
+		return RX_HANDLER_CONSUMED;
+	}
+
+	/* Is this frame a candidate for local reception? */
+	deliver_to_self =3D false;
+	if ((skb->pkt_type =3D=3D PACKET_HOST) ||
+	    (skb->pkt_type =3D=3D PACKET_MULTICAST) ||
+	    (skb->pkt_type =3D=3D PACKET_BROADCAST))
+		deliver_to_self =3D true;
+	else if (ether_addr_equal(eth_hdr(skb)->h_dest, hsr->dev->dev_addr)) =
{
+		skb->pkt_type =3D PACKET_HOST;
+		deliver_to_self =3D true;
+	}
+
+
+	rcu_read_lock(); /* node_db */
+	node =3D hsr_find_node(&hsr->node_db, skb);
+
+	if (is_supervision_frame(hsr, skb)) {
+		skb_pull(skb, sizeof(struct hsr_sup_tag));
+		node =3D hsr_merge_node(hsr, node, skb, dev_in_idx);
+		if (!node) {
+			rcu_read_unlock(); /* node_db */
+			kfree_skb(skb);
+			hsr->dev->stats.rx_dropped++;
+			return RX_HANDLER_CONSUMED;
+		}
+		skb_push(skb, sizeof(struct hsr_sup_tag));
+		deliver_to_self =3D false;
+	}
+
+	if (!node) {
+		/* Source node unknown; this might be a HSR frame from
+		 * another net (different multicast address). Ignore it.
+		 */
+		rcu_read_unlock(); /* node_db */
+		kfree_skb(skb);
+		return RX_HANDLER_CONSUMED;
+	}
+
+	/* Register ALL incoming frames as outgoing through the other interfa=
ce.
+	 * This allows us to register frames as incoming only if they are val=
id
+	 * for the receiving interface, without using a specific counter for
+	 * incoming frames.
+	 */
+	dup_out =3D hsr_register_frame_out(node, dev_other_idx, skb);
+	if (!dup_out)
+		hsr_register_frame_in(node, dev_in_idx);
+
+	/* Forward this frame? */
+	if (!dup_out && (skb->pkt_type !=3D PACKET_HOST))
+		other_slave =3D get_other_slave(hsr, dev);
+	else
+		other_slave =3D NULL;
+
+	if (hsr_register_frame_out(node, HSR_DEV_MASTER, skb))
+		deliver_to_self =3D false;
+
+	rcu_read_unlock(); /* node_db */
+
+	if (!deliver_to_self && !other_slave) {
+		kfree_skb(skb);
+		/* Circulated frame; silently remove it. */
+		return RX_HANDLER_CONSUMED;
+	}
+
+	skb_deliver =3D skb;
+	if (deliver_to_self && other_slave) {
+		/* skb_clone() is not enough since we will strip the hsr tag
+		 * and do address substitution below
+		 */
+		skb_deliver =3D pskb_copy(skb, GFP_ATOMIC);
+		if (!skb_deliver) {
+			deliver_to_self =3D false;
+			hsr->dev->stats.rx_dropped++;
+		}
+	}
+
+	if (deliver_to_self) {
+		bool multicast_frame;
+
+		skb_deliver =3D hsr_pull_tag(skb_deliver);
+		if (!skb_deliver) {
+			hsr->dev->stats.rx_dropped++;
+			goto forward;
+		}
+#if !defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
+		/* Move everything in the header that is after the HSR tag,
+		 * to work around alignment problems caused by the 6-byte HSR
+		 * tag. In practice, this removes/overwrites the HSR tag in
+		 * the header and restores a "standard" packet.
+		 */
+		memmove(skb_deliver->data - HSR_HLEN, skb_deliver->data,
+			skb_headlen(skb_deliver));
+
+		/* Adjust skb members so they correspond with the move above.
+		 * This cannot possibly underflow skb->data since hsr_pull_tag()
+		 * above succeeded.
+		 * At this point in the protocol stack, the transport and
+		 * network headers have not been set yet, and we haven't touched
+		 * the mac header nor the head. So we only need to adjust data
+		 * and tail:
+		 */
+		skb_deliver->data -=3D HSR_HLEN;
+		skb_deliver->tail -=3D HSR_HLEN;
+#endif
+		skb_deliver->dev =3D hsr->dev;
+		hsr_addr_subst_source(hsr, skb_deliver);
+		multicast_frame =3D (skb_deliver->pkt_type =3D=3D PACKET_MULTICAST);
+		ret =3D netif_rx(skb_deliver);
+		if (ret =3D=3D NET_RX_DROP) {
+			hsr->dev->stats.rx_dropped++;
+		} else {
+			hsr->dev->stats.rx_packets++;
+			hsr->dev->stats.rx_bytes +=3D skb->len;
+			if (multicast_frame)
+				hsr->dev->stats.multicast++;
+		}
+	}
+
+forward:
+	if (other_slave) {
+		skb_push(skb, ETH_HLEN);
+		skb->dev =3D other_slave;
+		dev_queue_xmit(skb);
+	}
+
+	return RX_HANDLER_CONSUMED;
+}
diff --git a/net/hsr/hsr_slave.h b/net/hsr/hsr_slave.h
new file mode 100644
index 0000000..ae90c8d
--- /dev/null
+++ b/net/hsr/hsr_slave.h
@@ -0,0 +1,20 @@
+/* Copyright 2011-2014 Autronica Fire and Security AS
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of the GNU General Public License as published by t=
he Free
+ * Software Foundation; either version 2 of the License, or (at your o=
ption)
+ * any later version.
+ *
+ * Author(s):
+ *	2011-2014 Arvid Brodin, arvid.brodin@alten.se
+ */
+
+#ifndef __HSR_SLAVE_H
+#define __HSR_SLAVE_H
+
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+
+rx_handler_result_t hsr_handle_frame(struct sk_buff **pskb);
+
+#endif /* __HSR_SLAVE_H */
--=20
1.8.3.2

--=20
Arvid Brodin | Consultant (Linux)
ALTEN | Knarrarn=C3=A4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/
