From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 11/16] batman-adv: Modified forwarding behaviour for multicast packets
Date: Sat, 22 Mar 2014 09:56:11 +0100
Message-ID: <1395478576-10999-12-git-send-email-antonio@meshcoding.com>
References: <1395478576-10999-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:22055 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900AbaCVJN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2014 05:13:59 -0400
In-Reply-To: <1395478576-10999-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@web.de>

With this patch a multicast packet is not always simply flooded anymore=
,
the behaviour for the following cases is changed to reduce
unnecessary overhead:

If all nodes within the horizon of a certain node have signalized
multicast listener announcement capability then an IPv6 multicast packe=
t
with a destination of IPv6 link-local scope (excluding ff02::1) coming
from the upstream of this node...

* ...is dropped if there is no according multicast listener in the
  translation table,
* ...is forwarded via unicast if there is a single node with interested
  multicast listeners
* ...and otherwise still gets flooded.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 Documentation/ABI/testing/sysfs-class-net-mesh |   9 ++
 net/batman-adv/multicast.c                     | 126 +++++++++++++++++=
++++++++
 net/batman-adv/multicast.h                     |  25 +++++
 net/batman-adv/send.c                          |  10 +-
 net/batman-adv/send.h                          |   5 +
 net/batman-adv/soft-interface.c                |  20 +++-
 net/batman-adv/sysfs.c                         |   6 ++
 net/batman-adv/translation-table.c             |  91 ++++++++++++++---=
-
 net/batman-adv/translation-table.h             |   2 +
 net/batman-adv/types.h                         |   7 ++
 10 files changed, 275 insertions(+), 26 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-class-net-mesh b/Documenta=
tion/ABI/testing/sysfs-class-net-mesh
index 4793d3d..c464062 100644
--- a/Documentation/ABI/testing/sysfs-class-net-mesh
+++ b/Documentation/ABI/testing/sysfs-class-net-mesh
@@ -76,6 +76,15 @@ Description:
 		is used to classify clients as "isolated" by the
 		Extended Isolation feature.
=20
+What:           /sys/class/net/<mesh_iface>/mesh/multicast_mode
+Date:           Feb 2014
+Contact:        Linus L=C3=BCssing <linus.luessing@web.de>
+Description:
+                Indicates whether multicast optimizations are enabled
+                or disabled. If set to zero then all nodes in the
+                mesh are going to use classic flooding for any
+                multicast packet with no optimizations.
+
 What:           /sys/class/net/<mesh_iface>/mesh/network_coding
 Date:           Nov 2012
 Contact:        Martin Hundeboll <martin@hundeboll.net>
diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index 3ba9a18..1d1627f 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -20,6 +20,7 @@
 #include "originator.h"
 #include "hard-interface.h"
 #include "translation-table.h"
+#include "multicast.h"
=20
 /**
  * batadv_mcast_mla_softif_get - get softif multicast listeners
@@ -247,6 +248,131 @@ out:
 }
=20
 /**
+ * batadv_mcast_forw_mode_check_ipv6 - check for optimized forwarding =
potential
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: the IPv6 packet to check
+ *
+ * Checks whether the given IPv6 packet has the potential to be forwar=
ded with a
+ * mode more optimal than classic flooding.
+ *
+ * If so then returns 0. Otherwise -EINVAL is returned or -ENOMEM if w=
e are out
+ * of memory.
+ */
+static int batadv_mcast_forw_mode_check_ipv6(struct batadv_priv *bat_p=
riv,
+					     struct sk_buff *skb)
+{
+	struct ipv6hdr *ip6hdr;
+
+	/* We might fail due to out-of-memory -> drop it */
+	if (!pskb_may_pull(skb, sizeof(struct ethhdr) + sizeof(*ip6hdr)))
+		return -ENOMEM;
+
+	ip6hdr =3D ipv6_hdr(skb);
+
+	/* TODO: Implement Multicast Router Discovery (RFC4286),
+	 * then allow scope > link local, too
+	 */
+	if (IPV6_ADDR_MC_SCOPE(&ip6hdr->daddr) !=3D IPV6_ADDR_SCOPE_LINKLOCAL=
)
+		return -EINVAL;
+
+	/* link-local-all-nodes multicast listeners behind a bridge are
+	 * not snoopable (see RFC4541, section 3, paragraph 3)
+	 */
+	if (ipv6_addr_is_ll_all_nodes(&ip6hdr->daddr))
+		return -EINVAL;
+
+	return 0;
+}
+
+/**
+ * batadv_mcast_forw_mode_check - check for optimized forwarding poten=
tial
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: the multicast frame to check
+ *
+ * Checks whether the given multicast ethernet frame has the potential=
 to be
+ * forwarded with a mode more optimal than classic flooding.
+ *
+ * If so then returns 0. Otherwise -EINVAL is returned or -ENOMEM if w=
e are out
+ * of memory.
+ */
+static int batadv_mcast_forw_mode_check(struct batadv_priv *bat_priv,
+					struct sk_buff *skb)
+{
+	struct ethhdr *ethhdr =3D eth_hdr(skb);
+
+	if (!atomic_read(&bat_priv->multicast_mode))
+		return -EINVAL;
+
+	if (atomic_read(&bat_priv->mcast.num_disabled))
+		return -EINVAL;
+
+	switch (ntohs(ethhdr->h_proto)) {
+	case ETH_P_IPV6:
+		return batadv_mcast_forw_mode_check_ipv6(bat_priv, skb);
+	default:
+		return -EINVAL;
+	}
+}
+
+/**
+ * batadv_mcast_forw_tt_node_get - get a multicast tt node
+ * @bat_priv: the bat priv with all the soft interface information
+ * @ethhdr: the ether header containing the multicast destination
+ *
+ * Returns an orig_node matching the multicast address provided by eth=
hdr
+ * via a translation table lookup. This increases the returned nodes r=
efcount.
+ */
+static struct batadv_orig_node *
+batadv_mcast_forw_tt_node_get(struct batadv_priv *bat_priv,
+			      struct ethhdr *ethhdr)
+{
+	return batadv_transtable_search(bat_priv, ethhdr->h_source,
+					ethhdr->h_dest, BATADV_NO_FLAGS);
+}
+
+/**
+ * batadv_mcast_forw_mode - check on how to forward a multicast packet
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: The multicast packet to check
+ * @orig: an originator to be set to forward the skb to
+ *
+ * Returns the forwarding mode as enum batadv_forw_mode and in case of
+ * BATADV_FORW_SINGLE set the orig to the single originator the skb
+ * should be forwarded to.
+ */
+enum batadv_forw_mode
+batadv_mcast_forw_mode(struct batadv_priv *bat_priv, struct sk_buff *s=
kb,
+		       struct batadv_orig_node **orig)
+{
+	struct ethhdr *ethhdr;
+	int ret, tt_count;
+
+	ret =3D batadv_mcast_forw_mode_check(bat_priv, skb);
+	if (ret =3D=3D -ENOMEM)
+		return BATADV_FORW_NONE;
+	else if (ret < 0)
+		return BATADV_FORW_ALL;
+
+	ethhdr =3D eth_hdr(skb);
+
+	tt_count =3D batadv_tt_global_hash_count(bat_priv, ethhdr->h_dest,
+					       BATADV_NO_FLAGS);
+
+	switch (tt_count) {
+	case 1:
+		*orig =3D batadv_mcast_forw_tt_node_get(bat_priv, ethhdr);
+		if (*orig)
+			return BATADV_FORW_SINGLE;
+
+		/* fall through */
+	case 0:
+		return BATADV_FORW_NONE;
+	default:
+		return BATADV_FORW_ALL;
+	}
+}
+
+/**
  * batadv_mcast_tvlv_ogm_handler_v1 - process incoming multicast tvlv =
container
  * @bat_priv: the bat priv with all the soft interface information
  * @orig: the orig_node of the ogm
diff --git a/net/batman-adv/multicast.h b/net/batman-adv/multicast.h
index c029eac..73b5d45 100644
--- a/net/batman-adv/multicast.h
+++ b/net/batman-adv/multicast.h
@@ -18,10 +18,28 @@
 #ifndef _NET_BATMAN_ADV_MULTICAST_H_
 #define _NET_BATMAN_ADV_MULTICAST_H_
=20
+/**
+ * batadv_forw_mode - the way a packet should be forwarded as
+ * @BATADV_FORW_ALL: forward the packet to all nodes (currently via cl=
assic
+ *  flooding)
+ * @BATADV_FORW_SINGLE: forward the packet to a single node (currently=
 via the
+ *  BATMAN unicast routing protocol)
+ * @BATADV_FORW_NONE: don't forward, drop it
+ */
+enum batadv_forw_mode {
+	BATADV_FORW_ALL,
+	BATADV_FORW_SINGLE,
+	BATADV_FORW_NONE,
+};
+
 #ifdef CONFIG_BATMAN_ADV_MCAST
=20
 void batadv_mcast_mla_update(struct batadv_priv *bat_priv);
=20
+enum batadv_forw_mode
+batadv_mcast_forw_mode(struct batadv_priv *bat_priv, struct sk_buff *s=
kb,
+		       struct batadv_orig_node **mcast_single_orig);
+
 void batadv_mcast_init(struct batadv_priv *bat_priv);
=20
 void batadv_mcast_free(struct batadv_priv *bat_priv);
@@ -35,6 +53,13 @@ static inline void batadv_mcast_mla_update(struct ba=
tadv_priv *bat_priv)
 	return;
 }
=20
+static inline enum batadv_forw_mode
+batadv_mcast_forw_mode(struct batadv_priv *bat_priv, struct sk_buff *s=
kb,
+		       struct batadv_orig_node **mcast_single_orig)
+{
+	return BATADV_FORW_ALL;
+}
+
 static inline int batadv_mcast_init(struct batadv_priv *bat_priv)
 {
 	return 0;
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index ce163d5..8bee5e8 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -248,11 +248,11 @@ out:
  *
  * Returns NET_XMIT_DROP in case of error or NET_XMIT_SUCCESS otherwis=
e.
  */
-static int batadv_send_skb_unicast(struct batadv_priv *bat_priv,
-				   struct sk_buff *skb, int packet_type,
-				   int packet_subtype,
-				   struct batadv_orig_node *orig_node,
-				   unsigned short vid)
+int batadv_send_skb_unicast(struct batadv_priv *bat_priv,
+			    struct sk_buff *skb, int packet_type,
+			    int packet_subtype,
+			    struct batadv_orig_node *orig_node,
+			    unsigned short vid)
 {
 	struct ethhdr *ethhdr;
 	struct batadv_unicast_packet *unicast_packet;
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index 31e8781..38d0ec1 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -36,6 +36,11 @@ bool batadv_send_skb_prepare_unicast_4addr(struct ba=
tadv_priv *bat_priv,
 					   struct sk_buff *skb,
 					   struct batadv_orig_node *orig_node,
 					   int packet_subtype);
+int batadv_send_skb_unicast(struct batadv_priv *bat_priv,
+			    struct sk_buff *skb, int packet_type,
+			    int packet_subtype,
+			    struct batadv_orig_node *orig_node,
+			    unsigned short vid);
 int batadv_send_skb_via_tt_generic(struct batadv_priv *bat_priv,
 				   struct sk_buff *skb, int packet_type,
 				   int packet_subtype, uint8_t *dst_hint,
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 8ff47b7..1a643fe6 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -32,6 +32,7 @@
 #include <linux/ethtool.h>
 #include <linux/etherdevice.h>
 #include <linux/if_vlan.h>
+#include "multicast.h"
 #include "bridge_loop_avoidance.h"
 #include "network-coding.h"
=20
@@ -170,6 +171,8 @@ static int batadv_interface_tx(struct sk_buff *skb,
 	unsigned short vid;
 	uint32_t seqno;
 	int gw_mode;
+	enum batadv_forw_mode forw_mode;
+	struct batadv_orig_node *mcast_single_orig =3D NULL;
=20
 	if (atomic_read(&bat_priv->mesh_state) !=3D BATADV_MESH_ACTIVE)
 		goto dropped;
@@ -247,9 +250,19 @@ static int batadv_interface_tx(struct sk_buff *skb=
,
 			 * directed to a DHCP server
 			 */
 			goto dropped;
-	}
=20
 send:
+		if (do_bcast && !is_broadcast_ether_addr(ethhdr->h_dest)) {
+			forw_mode =3D batadv_mcast_forw_mode(bat_priv, skb,
+							   &mcast_single_orig);
+			if (forw_mode =3D=3D BATADV_FORW_NONE)
+				goto dropped;
+
+			if (forw_mode =3D=3D BATADV_FORW_SINGLE)
+				do_bcast =3D false;
+		}
+	}
+
 	batadv_skb_set_priority(skb, 0);
=20
 	/* ethernet packet should be broadcasted */
@@ -301,6 +314,10 @@ send:
 			if (ret)
 				goto dropped;
 			ret =3D batadv_send_skb_via_gw(bat_priv, skb, vid);
+		} else if (mcast_single_orig) {
+			ret =3D batadv_send_skb_unicast(bat_priv, skb,
+						      BATADV_UNICAST, 0,
+						      mcast_single_orig, vid);
 		} else {
 			if (batadv_dat_snoop_outgoing_arp_request(bat_priv,
 								  skb))
@@ -691,6 +708,7 @@ static int batadv_softif_init_late(struct net_devic=
e *dev)
 #endif
 #ifdef CONFIG_BATMAN_ADV_MCAST
 	bat_priv->mcast.flags =3D BATADV_NO_FLAGS;
+	atomic_set(&bat_priv->multicast_mode, 1);
 	atomic_set(&bat_priv->mcast.num_disabled, 0);
 #endif
 	atomic_set(&bat_priv->gw_mode, BATADV_GW_MODE_OFF);
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index e456bf6..1ebb0d9 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -539,6 +539,9 @@ BATADV_ATTR_SIF_UINT(gw_sel_class, S_IRUGO | S_IWUS=
R, 1, BATADV_TQ_MAX_VALUE,
 		     batadv_post_gw_reselect);
 static BATADV_ATTR(gw_bandwidth, S_IRUGO | S_IWUSR, batadv_show_gw_bwi=
dth,
 		   batadv_store_gw_bwidth);
+#ifdef CONFIG_BATMAN_ADV_MCAST
+BATADV_ATTR_SIF_BOOL(multicast_mode, S_IRUGO | S_IWUSR, NULL);
+#endif
 #ifdef CONFIG_BATMAN_ADV_DEBUG
 BATADV_ATTR_SIF_UINT(log_level, S_IRUGO | S_IWUSR, 0, BATADV_DBG_ALL, =
NULL);
 #endif
@@ -558,6 +561,9 @@ static struct batadv_attribute *batadv_mesh_attrs[]=
 =3D {
 #ifdef CONFIG_BATMAN_ADV_DAT
 	&batadv_attr_distributed_arp_table,
 #endif
+#ifdef CONFIG_BATMAN_ADV_MCAST
+	&batadv_attr_multicast_mode,
+#endif
 	&batadv_attr_fragmentation,
 	&batadv_attr_routing_algo,
 	&batadv_attr_gw_mode,
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/transl=
ation-table.c
index f641dfe..d636bde 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -193,6 +193,31 @@ batadv_tt_global_entry_free_ref(struct batadv_tt_g=
lobal_entry *tt_global_entry)
 	}
 }
=20
+/**
+ * batadv_tt_global_hash_count - count the number of orig entries
+ * @hash: hash table containing the tt entries
+ * @addr: the mac address of the client to count entries for
+ * @vid: VLAN identifier
+ *
+ * Return the number of originators advertising the given address/data
+ * (excluding ourself).
+ */
+int batadv_tt_global_hash_count(struct batadv_priv *bat_priv,
+				const uint8_t *addr, unsigned short vid)
+{
+	struct batadv_tt_global_entry *tt_global_entry;
+	int count;
+
+	tt_global_entry =3D batadv_tt_global_hash_find(bat_priv, addr, vid);
+	if (!tt_global_entry)
+		return 0;
+
+	count =3D atomic_read(&tt_global_entry->orig_list_count);
+	batadv_tt_global_entry_free_ref(tt_global_entry);
+
+	return count;
+}
+
 static void batadv_tt_orig_list_entry_free_rcu(struct rcu_head *rcu)
 {
 	struct batadv_tt_orig_list_entry *orig_entry;
@@ -1225,6 +1250,8 @@ batadv_tt_global_orig_entry_add(struct batadv_tt_=
global_entry *tt_global,
 	hlist_add_head_rcu(&orig_entry->list,
 			   &tt_global->orig_list);
 	spin_unlock_bh(&tt_global->list_lock);
+	atomic_inc(&tt_global->orig_list_count);
+
 out:
 	if (orig_entry)
 		batadv_tt_orig_list_entry_free_ref(orig_entry);
@@ -1298,6 +1325,7 @@ static bool batadv_tt_global_add(struct batadv_pr=
iv *bat_priv,
 		common->added_at =3D jiffies;
=20
 		INIT_HLIST_HEAD(&tt_global_entry->orig_list);
+		atomic_set(&tt_global_entry->orig_list_count, 0);
 		spin_lock_init(&tt_global_entry->list_lock);
=20
 		hash_added =3D batadv_hash_add(bat_priv->tt.global_hash,
@@ -1563,6 +1591,25 @@ out:
 	return 0;
 }
=20
+/**
+ * batadv_tt_global_del_orig_entry - remove and free an orig_entry
+ * @tt_global_entry: the global entry to remove the orig_entry from
+ * @orig_entry: the orig entry to remove and free
+ *
+ * Remove an orig_entry from its list in the given tt_global_entry and
+ * free this orig_entry afterwards.
+ */
+static void
+batadv_tt_global_del_orig_entry(struct batadv_tt_global_entry *tt_glob=
al_entry,
+				struct batadv_tt_orig_list_entry *orig_entry)
+{
+	batadv_tt_global_size_dec(orig_entry->orig_node,
+				  tt_global_entry->common.vid);
+	atomic_dec(&tt_global_entry->orig_list_count);
+	hlist_del_rcu(&orig_entry->list);
+	batadv_tt_orig_list_entry_free_ref(orig_entry);
+}
+
 /* deletes the orig list of a tt_global_entry */
 static void
 batadv_tt_global_del_orig_list(struct batadv_tt_global_entry *tt_globa=
l_entry)
@@ -1573,20 +1620,26 @@ batadv_tt_global_del_orig_list(struct batadv_tt=
_global_entry *tt_global_entry)
=20
 	spin_lock_bh(&tt_global_entry->list_lock);
 	head =3D &tt_global_entry->orig_list;
-	hlist_for_each_entry_safe(orig_entry, safe, head, list) {
-		hlist_del_rcu(&orig_entry->list);
-		batadv_tt_global_size_dec(orig_entry->orig_node,
-					  tt_global_entry->common.vid);
-		batadv_tt_orig_list_entry_free_ref(orig_entry);
-	}
+	hlist_for_each_entry_safe(orig_entry, safe, head, list)
+		batadv_tt_global_del_orig_entry(tt_global_entry, orig_entry);
 	spin_unlock_bh(&tt_global_entry->list_lock);
 }
=20
+/**
+ * batadv_tt_global_del_orig_node - remove orig_node from a global tt =
entry
+ * @bat_priv: the bat priv with all the soft interface information
+ * @tt_global_entry: the global entry to remove the orig_node from
+ * @orig_node: the originator announcing the client
+ * @message: message to append to the log on deletion
+ *
+ * Remove the given orig_node and its according orig_entry from the gi=
ven
+ * global tt entry.
+ */
 static void
-batadv_tt_global_del_orig_entry(struct batadv_priv *bat_priv,
-				struct batadv_tt_global_entry *tt_global_entry,
-				struct batadv_orig_node *orig_node,
-				const char *message)
+batadv_tt_global_del_orig_node(struct batadv_priv *bat_priv,
+			       struct batadv_tt_global_entry *tt_global_entry,
+			       struct batadv_orig_node *orig_node,
+			       const char *message)
 {
 	struct hlist_head *head;
 	struct hlist_node *safe;
@@ -1603,10 +1656,8 @@ batadv_tt_global_del_orig_entry(struct batadv_pr=
iv *bat_priv,
 				   orig_node->orig,
 				   tt_global_entry->common.addr,
 				   BATADV_PRINT_VID(vid), message);
-			hlist_del_rcu(&orig_entry->list);
-			batadv_tt_global_size_dec(orig_node,
-						  tt_global_entry->common.vid);
-			batadv_tt_orig_list_entry_free_ref(orig_entry);
+			batadv_tt_global_del_orig_entry(tt_global_entry,
+							orig_entry);
 		}
 	}
 	spin_unlock_bh(&tt_global_entry->list_lock);
@@ -1648,8 +1699,8 @@ batadv_tt_global_del_roaming(struct batadv_priv *=
bat_priv,
 		/* there is another entry, we can simply delete this
 		 * one and can still use the other one.
 		 */
-		batadv_tt_global_del_orig_entry(bat_priv, tt_global_entry,
-						orig_node, message);
+		batadv_tt_global_del_orig_node(bat_priv, tt_global_entry,
+					       orig_node, message);
 }
=20
 /**
@@ -1675,8 +1726,8 @@ static void batadv_tt_global_del(struct batadv_pr=
iv *bat_priv,
 		goto out;
=20
 	if (!roaming) {
-		batadv_tt_global_del_orig_entry(bat_priv, tt_global_entry,
-						orig_node, message);
+		batadv_tt_global_del_orig_node(bat_priv, tt_global_entry,
+					       orig_node, message);
=20
 		if (hlist_empty(&tt_global_entry->orig_list))
 			batadv_tt_global_free(bat_priv, tt_global_entry,
@@ -1759,8 +1810,8 @@ void batadv_tt_global_del_orig(struct batadv_priv=
 *bat_priv,
 						 struct batadv_tt_global_entry,
 						 common);
=20
-			batadv_tt_global_del_orig_entry(bat_priv, tt_global,
-							orig_node, message);
+			batadv_tt_global_del_orig_node(bat_priv, tt_global,
+						       orig_node, message);
=20
 			if (hlist_empty(&tt_global->orig_list)) {
 				vid =3D tt_global->common.vid;
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/transl=
ation-table.h
index 20a1d78..ad84d7b 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -29,6 +29,8 @@ int batadv_tt_global_seq_print_text(struct seq_file *=
seq, void *offset);
 void batadv_tt_global_del_orig(struct batadv_priv *bat_priv,
 			       struct batadv_orig_node *orig_node,
 			       int32_t match_vid, const char *message);
+int batadv_tt_global_hash_count(struct batadv_priv *bat_priv,
+				const uint8_t *addr, unsigned short vid);
 struct batadv_orig_node *batadv_transtable_search(struct batadv_priv *=
bat_priv,
 						  const uint8_t *src,
 						  const uint8_t *addr,
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 96ee0d2..c28fc4a 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -696,6 +696,8 @@ struct batadv_softif_vlan {
  *  enabled
  * @distributed_arp_table: bool indicating whether distributed ARP tab=
le is
  *  enabled
+ * @multicast_mode: Enable or disable multicast optimizations on this =
node's
+ *  sender/originating side
  * @gw_mode: gateway operation: off, client or server (see batadv_gw_m=
odes)
  * @gw_sel_class: gateway selection class (applies if gw_mode client)
  * @orig_interval: OGM broadcast interval in milliseconds
@@ -746,6 +748,9 @@ struct batadv_priv {
 #ifdef CONFIG_BATMAN_ADV_DAT
 	atomic_t distributed_arp_table;
 #endif
+#ifdef CONFIG_BATMAN_ADV_MCAST
+	atomic_t multicast_mode;
+#endif
 	atomic_t gw_mode;
 	atomic_t gw_sel_class;
 	atomic_t orig_interval;
@@ -909,12 +914,14 @@ struct batadv_tt_local_entry {
  * struct batadv_tt_global_entry - translation table global entry data
  * @common: general translation table data
  * @orig_list: list of orig nodes announcing this non-mesh client
+ * @orig_list_count: number of items in the orig_list
  * @list_lock: lock protecting orig_list
  * @roam_at: time at which TT_GLOBAL_ROAM was set
  */
 struct batadv_tt_global_entry {
 	struct batadv_tt_common_entry common;
 	struct hlist_head orig_list;
+	atomic_t orig_list_count;
 	spinlock_t list_lock;	/* protects orig_list */
 	unsigned long roam_at;
 };
--=20
1.8.3.2
