From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 05/15] batman-adv: OGMv2 - add basic infrastructure
Date: Mon, 29 Feb 2016 19:05:58 +0800
Message-ID: <1456743968-17562-6-git-send-email-a__17494.3284168423$1456744189$gmane$org@unstable.cc>
References: <1456743968-17562-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:8417 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753928AbcB2LIt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 06:08:49 -0500
In-Reply-To: <1456743968-17562-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

This is the initial implementation of the new OGM protocol
(version 2). It has been designed to work on top of the
newly added ELP.

In the previous version the OGM protocol was used to both
measure link qualities and flood the network with the metric
information. In this version the protocol is in charge of
the latter task only, leaving the former to ELP.

This means being able to decouple the interval used by the
neighbor discovery from the OGM broadcasting, which revealed
to be costly in dense networks and needed to be relaxed so
leading to a less responsive routing protocol.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/Makefile    |   1 +
 net/batman-adv/bat_algo.h  |  13 +++
 net/batman-adv/bat_v.c     |  53 ++++++++-
 net/batman-adv/bat_v_ogm.c | 279 +++++++++++++++++++++++++++++++++++++++++++++
 net/batman-adv/bat_v_ogm.h |  32 ++++++
 net/batman-adv/main.c      |   6 +
 net/batman-adv/main.h      |   1 +
 net/batman-adv/packet.h    |  29 +++++
 net/batman-adv/types.h     |  18 +++
 9 files changed, 428 insertions(+), 4 deletions(-)
 create mode 100644 net/batman-adv/bat_v_ogm.c
 create mode 100644 net/batman-adv/bat_v_ogm.h

diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index ca51686e9f72..797cf2fc88c1 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -20,6 +20,7 @@ obj-$(CONFIG_BATMAN_ADV) += batman-adv.o
 batman-adv-y += bat_iv_ogm.o
 batman-adv-$(CONFIG_BATMAN_ADV_BATMAN_V) += bat_v.o
 batman-adv-$(CONFIG_BATMAN_ADV_BATMAN_V) += bat_v_elp.o
+batman-adv-$(CONFIG_BATMAN_ADV_BATMAN_V) += bat_v_ogm.o
 batman-adv-y += bitarray.o
 batman-adv-$(CONFIG_BATMAN_ADV_BLA) += bridge_loop_avoidance.o
 batman-adv-$(CONFIG_DEBUG_FS) += debugfs.o
diff --git a/net/batman-adv/bat_algo.h b/net/batman-adv/bat_algo.h
index a4e994e26da1..03dafd33d23b 100644
--- a/net/batman-adv/bat_algo.h
+++ b/net/batman-adv/bat_algo.h
@@ -18,11 +18,15 @@
 #ifndef _NET_BATMAN_ADV_BAT_ALGO_H_
 #define _NET_BATMAN_ADV_BAT_ALGO_H_
 
+struct batadv_priv;
+
 int batadv_iv_init(void);
 
 #ifdef CONFIG_BATMAN_ADV_BATMAN_V
 
 int batadv_v_init(void);
+int batadv_v_mesh_init(struct batadv_priv *bat_priv);
+void batadv_v_mesh_free(struct batadv_priv *bat_priv);
 
 #else
 
@@ -31,6 +35,15 @@ static inline int batadv_v_init(void)
 	return 0;
 }
 
+static inline int batadv_v_mesh_init(struct batadv_priv *bat_priv)
+{
+	return 0;
+}
+
+static inline void batadv_v_mesh_free(struct batadv_priv *bat_priv)
+{
+}
+
 #endif /* CONFIG_BATMAN_ADV_BATMAN_V */
 
 #endif /* _NET_BATMAN_ADV_BAT_ALGO_H_ */
diff --git a/net/batman-adv/bat_v.c b/net/batman-adv/bat_v.c
index 0fea894855ff..b90a4dfe8ba6 100644
--- a/net/batman-adv/bat_v.c
+++ b/net/batman-adv/bat_v.c
@@ -22,11 +22,22 @@
 #include <linux/init.h>
 
 #include "bat_v_elp.h"
+#include "bat_v_ogm.h"
 #include "packet.h"
 
 static int batadv_v_iface_enable(struct batadv_hard_iface *hard_iface)
 {
-	return batadv_v_elp_iface_enable(hard_iface);
+	int ret;
+
+	ret = batadv_v_elp_iface_enable(hard_iface);
+	if (ret < 0)
+		return ret;
+
+	ret = batadv_v_ogm_iface_enable(hard_iface);
+	if (ret < 0)
+		batadv_v_elp_iface_disable(hard_iface);
+
+	return ret;
 }
 
 static void batadv_v_iface_disable(struct batadv_hard_iface *hard_iface)
@@ -41,6 +52,7 @@ static void batadv_v_iface_update_mac(struct batadv_hard_iface *hard_iface)
 static void batadv_v_primary_iface_set(struct batadv_hard_iface *hard_iface)
 {
 	batadv_v_elp_primary_iface_set(hard_iface);
+	batadv_v_ogm_primary_iface_set(hard_iface);
 }
 
 static void
@@ -69,6 +81,27 @@ static struct batadv_algo_ops batadv_batman_v __read_mostly = {
 };
 
 /**
+ * batadv_v_mesh_init - initialize the B.A.T.M.A.N. V private resources for a
+ *  mesh
+ * @bat_priv: the object representing the mesh interface to initialise
+ *
+ * Return: 0 on success or a negative error code otherwise
+ */
+int batadv_v_mesh_init(struct batadv_priv *bat_priv)
+{
+	return batadv_v_ogm_init(bat_priv);
+}
+
+/**
+ * batadv_v_mesh_free - free the B.A.T.M.A.N. V private resources for a mesh
+ * @bat_priv: the object representing the mesh interface to free
+ */
+void batadv_v_mesh_free(struct batadv_priv *bat_priv)
+{
+	batadv_v_ogm_free(bat_priv);
+}
+
+/**
  * batadv_v_init - B.A.T.M.A.N. V initialization function
  *
  * Description: Takes care of initializing all the subcomponents.
@@ -86,10 +119,22 @@ int __init batadv_v_init(void)
 	if (ret < 0)
 		return ret;
 
-	ret = batadv_algo_register(&batadv_batman_v);
-
+	ret = batadv_recv_handler_register(BATADV_OGM2,
+					   batadv_v_ogm_packet_recv);
 	if (ret < 0)
-		batadv_recv_handler_unregister(BATADV_ELP);
+		goto elp_unregister;
+
+	ret = batadv_algo_register(&batadv_batman_v);
+	if (ret < 0)
+		goto ogm_unregister;
+
+	return ret;
+
+ogm_unregister:
+	batadv_recv_handler_unregister(BATADV_OGM2);
+
+elp_unregister:
+	batadv_recv_handler_unregister(BATADV_ELP);
 
 	return ret;
 }
diff --git a/net/batman-adv/bat_v_ogm.c b/net/batman-adv/bat_v_ogm.c
new file mode 100644
index 000000000000..23932f9b85ec
--- /dev/null
+++ b/net/batman-adv/bat_v_ogm.c
@@ -0,0 +1,279 @@
+/* Copyright (C) 2013-2016 B.A.T.M.A.N. contributors:
+ *
+ * Antonio Quartulli
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include "bat_v_ogm.h"
+#include "main.h"
+
+#include <linux/atomic.h>
+#include <linux/byteorder/generic.h>
+#include <linux/errno.h>
+#include <linux/etherdevice.h>
+#include <linux/fs.h>
+#include <linux/if_ether.h>
+#include <linux/jiffies.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/random.h>
+#include <linux/rculist.h>
+#include <linux/rcupdate.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/stddef.h>
+#include <linux/string.h>
+#include <linux/types.h>
+#include <linux/workqueue.h>
+
+#include "hard-interface.h"
+#include "packet.h"
+#include "routing.h"
+#include "send.h"
+#include "translation-table.h"
+
+/**
+ * batadv_v_ogm_start_timer - restart the OGM sending timer
+ * @bat_priv: the bat priv with all the soft interface information
+ */
+static void batadv_v_ogm_start_timer(struct batadv_priv *bat_priv)
+{
+	unsigned long msecs;
+	/* this function may be invoked in different contexts (ogm rescheduling
+	 * or hard_iface activation), but the work timer should not be reset
+	 */
+	if (delayed_work_pending(&bat_priv->bat_v.ogm_wq))
+		return;
+
+	msecs = atomic_read(&bat_priv->orig_interval) - BATADV_JITTER;
+	msecs += prandom_u32() % (2 * BATADV_JITTER);
+	queue_delayed_work(batadv_event_workqueue, &bat_priv->bat_v.ogm_wq,
+			   msecs_to_jiffies(msecs));
+}
+
+/**
+ * batadv_v_ogm_send_to_if - send a batman ogm using a given interface
+ * @skb: the OGM to send
+ * @hard_iface: the interface to use to send the OGM
+ */
+static void batadv_v_ogm_send_to_if(struct sk_buff *skb,
+				    struct batadv_hard_iface *hard_iface)
+{
+	struct batadv_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
+
+	if (hard_iface->if_status != BATADV_IF_ACTIVE)
+		return;
+
+	batadv_inc_counter(bat_priv, BATADV_CNT_MGMT_TX);
+	batadv_add_counter(bat_priv, BATADV_CNT_MGMT_TX_BYTES,
+			   skb->len + ETH_HLEN);
+
+	batadv_send_skb_packet(skb, hard_iface, batadv_broadcast_addr);
+}
+
+/**
+ * batadv_v_ogm_send - periodic worker broadcasting the own OGM
+ * @work: work queue item
+ */
+static void batadv_v_ogm_send(struct work_struct *work)
+{
+	struct batadv_hard_iface *hard_iface;
+	struct batadv_priv_bat_v *bat_v;
+	struct batadv_priv *bat_priv;
+	struct batadv_ogm2_packet *ogm_packet;
+	struct sk_buff *skb, *skb_tmp;
+	unsigned char *ogm_buff, *pkt_buff;
+	int ogm_buff_len;
+	u16 tvlv_len = 0;
+
+	bat_v = container_of(work, struct batadv_priv_bat_v, ogm_wq.work);
+	bat_priv = container_of(bat_v, struct batadv_priv, bat_v);
+
+	if (atomic_read(&bat_priv->mesh_state) == BATADV_MESH_DEACTIVATING)
+		goto out;
+
+	ogm_buff = bat_priv->bat_v.ogm_buff;
+	ogm_buff_len = bat_priv->bat_v.ogm_buff_len;
+	/* tt changes have to be committed before the tvlv data is
+	 * appended as it may alter the tt tvlv container
+	 */
+	batadv_tt_local_commit_changes(bat_priv);
+	tvlv_len = batadv_tvlv_container_ogm_append(bat_priv, &ogm_buff,
+						    &ogm_buff_len,
+						    BATADV_OGM2_HLEN);
+
+	bat_priv->bat_v.ogm_buff = ogm_buff;
+	bat_priv->bat_v.ogm_buff_len = ogm_buff_len;
+
+	skb = netdev_alloc_skb_ip_align(NULL, ETH_HLEN + ogm_buff_len);
+	if (!skb)
+		goto reschedule;
+
+	skb_reserve(skb, ETH_HLEN);
+	pkt_buff = skb_put(skb, ogm_buff_len);
+	memcpy(pkt_buff, ogm_buff, ogm_buff_len);
+
+	ogm_packet = (struct batadv_ogm2_packet *)skb->data;
+	ogm_packet->seqno = htonl(atomic_read(&bat_priv->bat_v.ogm_seqno));
+	atomic_inc(&bat_priv->bat_v.ogm_seqno);
+	ogm_packet->tvlv_len = htons(tvlv_len);
+
+	/* broadcast on every interface */
+	rcu_read_lock();
+	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
+		if (hard_iface->soft_iface != bat_priv->soft_iface)
+			continue;
+
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+			   "Sending own OGM2 packet (originator %pM, seqno %u, throughput %u, TTL %d) on interface %s [%pM]\n",
+			   ogm_packet->orig, ntohl(ogm_packet->seqno),
+			   ntohl(ogm_packet->throughput), ogm_packet->ttl,
+			   hard_iface->net_dev->name,
+			   hard_iface->net_dev->dev_addr);
+
+		/* this skb gets consumed by batadv_v_ogm_send_to_if() */
+		skb_tmp = skb_clone(skb, GFP_ATOMIC);
+		if (!skb_tmp)
+			break;
+
+		batadv_v_ogm_send_to_if(skb_tmp, hard_iface);
+	}
+	rcu_read_unlock();
+
+	consume_skb(skb);
+
+reschedule:
+	batadv_v_ogm_start_timer(bat_priv);
+out:
+	return;
+}
+
+/**
+ * batadv_v_ogm_iface_enable - prepare an interface for B.A.T.M.A.N. V
+ * @hard_iface: the interface to prepare
+ *
+ * Takes care of scheduling own OGM sending routine for this interface.
+ *
+ * Return: 0 on success or a negative error code otherwise
+ */
+int batadv_v_ogm_iface_enable(struct batadv_hard_iface *hard_iface)
+{
+	struct batadv_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
+
+	batadv_v_ogm_start_timer(bat_priv);
+
+	return 0;
+}
+
+/**
+ * batadv_v_ogm_primary_iface_set - set a new primary interface
+ * @primary_iface: the new primary interface
+ */
+void batadv_v_ogm_primary_iface_set(struct batadv_hard_iface *primary_iface)
+{
+	struct batadv_priv *bat_priv = netdev_priv(primary_iface->soft_iface);
+	struct batadv_ogm2_packet *ogm_packet;
+
+	if (!bat_priv->bat_v.ogm_buff)
+		return;
+
+	ogm_packet = (struct batadv_ogm2_packet *)bat_priv->bat_v.ogm_buff;
+	ether_addr_copy(ogm_packet->orig, primary_iface->net_dev->dev_addr);
+}
+
+/**
+ * batadv_v_ogm_packet_recv - OGM2 receiving handler
+ * @skb: the received OGM
+ * @if_incoming: the interface where this OGM has been received
+ *
+ * Return: NET_RX_SUCCESS and consume the skb on success or returns NET_RX_DROP
+ * (without freeing the skb) on failure
+ */
+int batadv_v_ogm_packet_recv(struct sk_buff *skb,
+			     struct batadv_hard_iface *if_incoming)
+{
+	struct batadv_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
+	struct batadv_ogm2_packet *ogm_packet;
+	struct ethhdr *ethhdr = eth_hdr(skb);
+
+	/* did we receive a OGM2 packet on an interface that does not have
+	 * B.A.T.M.A.N. V enabled ?
+	 */
+	if (strcmp(bat_priv->bat_algo_ops->name, "BATMAN_V") != 0)
+		return NET_RX_DROP;
+
+	if (!batadv_check_management_packet(skb, if_incoming, BATADV_OGM2_HLEN))
+		return NET_RX_DROP;
+
+	if (batadv_is_my_mac(bat_priv, ethhdr->h_source))
+		return NET_RX_DROP;
+
+	ogm_packet = (struct batadv_ogm2_packet *)skb->data;
+
+	if (batadv_is_my_mac(bat_priv, ogm_packet->orig))
+		return NET_RX_DROP;
+
+	batadv_inc_counter(bat_priv, BATADV_CNT_MGMT_RX);
+	batadv_add_counter(bat_priv, BATADV_CNT_MGMT_RX_BYTES,
+			   skb->len + ETH_HLEN);
+
+	consume_skb(skb);
+	return NET_RX_SUCCESS;
+}
+
+/**
+ * batadv_v_ogm_init - initialise the OGM2 engine
+ * @bat_priv: the bat priv with all the soft interface information
+ *
+ * Return: 0 on success or a negative error code in case of failure
+ */
+int batadv_v_ogm_init(struct batadv_priv *bat_priv)
+{
+	struct batadv_ogm2_packet *ogm_packet;
+	unsigned char *ogm_buff;
+	u32 random_seqno;
+
+	bat_priv->bat_v.ogm_buff_len = BATADV_OGM2_HLEN;
+	ogm_buff = kzalloc(bat_priv->bat_v.ogm_buff_len, GFP_ATOMIC);
+	if (!ogm_buff)
+		return -ENOMEM;
+
+	bat_priv->bat_v.ogm_buff = ogm_buff;
+	ogm_packet = (struct batadv_ogm2_packet *)ogm_buff;
+	ogm_packet->packet_type = BATADV_OGM2;
+	ogm_packet->version = BATADV_COMPAT_VERSION;
+	ogm_packet->ttl = BATADV_TTL;
+	ogm_packet->flags = BATADV_NO_FLAGS;
+	ogm_packet->throughput = htonl(BATADV_THROUGHPUT_MAX_VALUE);
+
+	/* randomize initial seqno to avoid collision */
+	get_random_bytes(&random_seqno, sizeof(random_seqno));
+	atomic_set(&bat_priv->bat_v.ogm_seqno, random_seqno);
+	INIT_DELAYED_WORK(&bat_priv->bat_v.ogm_wq, batadv_v_ogm_send);
+
+	return 0;
+}
+
+/**
+ * batadv_v_ogm_free - free OGM private resources
+ * @bat_priv: the bat priv with all the soft interface information
+ */
+void batadv_v_ogm_free(struct batadv_priv *bat_priv)
+{
+	cancel_delayed_work_sync(&bat_priv->bat_v.ogm_wq);
+
+	kfree(bat_priv->bat_v.ogm_buff);
+	bat_priv->bat_v.ogm_buff = NULL;
+	bat_priv->bat_v.ogm_buff_len = 0;
+}
diff --git a/net/batman-adv/bat_v_ogm.h b/net/batman-adv/bat_v_ogm.h
new file mode 100644
index 000000000000..d9f178cedcd2
--- /dev/null
+++ b/net/batman-adv/bat_v_ogm.h
@@ -0,0 +1,32 @@
+/* Copyright (C) 2013-2016 B.A.T.M.A.N. contributors:
+ *
+ * Antonio Quartulli
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
+ */
+
+#ifndef _BATMAN_ADV_BATADV_V_OGM_H_
+#define _BATMAN_ADV_BATADV_V_OGM_H_
+
+struct batadv_hard_iface;
+struct batadv_priv;
+struct sk_buff;
+
+int batadv_v_ogm_init(struct batadv_priv *bat_priv);
+void batadv_v_ogm_free(struct batadv_priv *bat_priv);
+int batadv_v_ogm_iface_enable(struct batadv_hard_iface *hard_iface);
+void batadv_v_ogm_primary_iface_set(struct batadv_hard_iface *primary_iface);
+int batadv_v_ogm_packet_recv(struct sk_buff *skb,
+			     struct batadv_hard_iface *if_incoming);
+
+#endif /* _BATMAN_ADV_BATADV_V_OGM_H_ */
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 216057205e10..d64ddb961979 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -160,6 +160,10 @@ int batadv_mesh_init(struct net_device *soft_iface)
 	INIT_HLIST_HEAD(&bat_priv->tvlv.handler_list);
 	INIT_HLIST_HEAD(&bat_priv->softif_vlan_list);
 
+	ret = batadv_v_mesh_init(bat_priv);
+	if (ret < 0)
+		goto err;
+
 	ret = batadv_originator_init(bat_priv);
 	if (ret < 0)
 		goto err;
@@ -202,6 +206,8 @@ void batadv_mesh_free(struct net_device *soft_iface)
 	batadv_purge_outstanding_packets(bat_priv, NULL);
 
 	batadv_gw_node_free(bat_priv);
+
+	batadv_v_mesh_free(bat_priv);
 	batadv_nc_mesh_free(bat_priv);
 	batadv_dat_free(bat_priv);
 	batadv_bla_free(bat_priv);
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index d91bae270f42..fa0b067e589d 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -30,6 +30,7 @@
 /* B.A.T.M.A.N. parameters */
 
 #define BATADV_TQ_MAX_VALUE 255
+#define BATADV_THROUGHPUT_MAX_VALUE 0xFFFFFFFF
 #define BATADV_JITTER 20
 
 /* Time To Live of broadcast messages */
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index c698b6452953..8a8d7ca1a5cf 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -27,6 +27,7 @@
  * @BATADV_BCAST: broadcast packets carrying broadcast payload
  * @BATADV_CODED: network coded packets
  * @BATADV_ELP: echo location packets for B.A.T.M.A.N. V
+ * @BATADV_OGM2: originator messages for B.A.T.M.A.N. V
  *
  * @BATADV_UNICAST: unicast packets carrying unicast payload traffic
  * @BATADV_UNICAST_FRAG: unicast packets carrying a fragment of the original
@@ -42,6 +43,7 @@ enum batadv_packettype {
 	BATADV_BCAST            = 0x01,
 	BATADV_CODED            = 0x02,
 	BATADV_ELP		= 0x03,
+	BATADV_OGM2		= 0x04,
 	/* 0x40 - 0x7f: unicast */
 #define BATADV_UNICAST_MIN     0x40
 	BATADV_UNICAST          = 0x40,
@@ -237,6 +239,33 @@ struct batadv_ogm_packet {
 #define BATADV_OGM_HLEN sizeof(struct batadv_ogm_packet)
 
 /**
+ * struct batadv_ogm2_packet - ogm2 (routing protocol) packet
+ * @packet_type: batman-adv packet type, part of the general header
+ * @version: batman-adv protocol version, part of the general header
+ * @ttl: time to live for this packet, part of the general header
+ * @flags: reseved for routing relevant flags - currently always 0
+ * @seqno: sequence number
+ * @orig: originator mac address
+ * @tvlv_len: length of the appended tvlv buffer (in bytes)
+ * @throughput: the currently flooded path throughput
+ */
+struct batadv_ogm2_packet {
+	u8     packet_type;
+	u8     version;
+	u8     ttl;
+	u8     flags;
+	__be32 seqno;
+	u8     orig[ETH_ALEN];
+	__be16 tvlv_len;
+	__be32 throughput;
+	/* __packed is not needed as the struct size is divisible by 4,
+	 * and the largest data type in this struct has a size of 4.
+	 */
+};
+
+#define BATADV_OGM2_HLEN sizeof(struct batadv_ogm2_packet)
+
+/**
  * struct batadv_elp_packet - elp (neighbor discovery) packet
  * @packet_type: batman-adv packet type, part of the general header
  * @version: batman-adv protocol version, part of the genereal header
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 7fc82a5d4ac4..e213ccdd4c6c 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -802,6 +802,20 @@ struct batadv_softif_vlan {
 };
 
 /**
+ * struct batadv_priv_bat_v - B.A.T.M.A.N. V per soft-interface private data
+ * @ogm_buff: buffer holding the OGM packet
+ * @ogm_buff_len: length of the OGM packet buffer
+ * @ogm_seqno: OGM sequence number - used to identify each OGM
+ * @ogm_wq: workqueue used to schedule OGM transmissions
+ */
+struct batadv_priv_bat_v {
+	unsigned char *ogm_buff;
+	int ogm_buff_len;
+	atomic_t ogm_seqno;
+	struct delayed_work ogm_wq;
+};
+
+/**
  * struct batadv_priv - per mesh interface data
  * @mesh_state: current status of the mesh (inactive/active/deactivating)
  * @soft_iface: net device which holds this struct as private data
@@ -855,6 +869,7 @@ struct batadv_softif_vlan {
  * @mcast: multicast data
  * @network_coding: bool indicating whether network coding is enabled
  * @nc: network coding data
+ * @bat_v: B.A.T.M.A.N. V per soft-interface private data
  */
 struct batadv_priv {
 	atomic_t mesh_state;
@@ -920,6 +935,9 @@ struct batadv_priv {
 	atomic_t network_coding;
 	struct batadv_priv_nc nc;
 #endif /* CONFIG_BATMAN_ADV_NC */
+#ifdef CONFIG_BATMAN_ADV_BATMAN_V
+	struct batadv_priv_bat_v bat_v;
+#endif
 };
 
 /**
-- 
2.7.2
