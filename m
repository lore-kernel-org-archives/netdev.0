From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 12/16] batman-adv: Add IPv4 link-local/IPv6-ll-all-nodes multicast support
Date: Sat, 22 Mar 2014 09:56:12 +0100
Message-ID: <1395478576-10999-13-git-send-email-antonio@meshcoding.com>
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
Received: from s3.neomailbox.net ([178.209.62.157]:45663 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750841AbaCVJNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2014 05:13:54 -0400
In-Reply-To: <1395478576-10999-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@web.de>

With this patch a node may additionally perform the dropping or
unicasting behaviour for a link-local IPv4 and link-local-all-nodes
IPv6 multicast packet, too.

The extra counter and BATADV_MCAST_WANT_ALL_UNSNOOPABLES flag is needed
because with a future bridge snooping support integration a node with a
bridge on top of its soft interface is not able to reliably detect its
multicast listeners for IPv4 link-local and the IPv6
link-local-all-nodes addresses anymore (see RFC4541, section 2.1.2.2
and section 3).

Even though this new flag does make "no difference" now, it'll ensure
a seamless integration of multicast bridge support without needing to
break compatibility later.

Also note, that even with multicast bridge support it won't be possible
to optimize 224.0.0.x and ff02::1 towards nodes with bridges, they will
always receive these ranges.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/main.c           |   6 ++
 net/batman-adv/main.h           |   1 +
 net/batman-adv/multicast.c      | 135 ++++++++++++++++++++++++++++++++=
+++++---
 net/batman-adv/packet.h         |   9 +++
 net/batman-adv/soft-interface.c |   1 +
 net/batman-adv/types.h          |  12 ++++
 6 files changed, 156 insertions(+), 8 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 8f11b67..57b09fa 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -111,6 +111,9 @@ int batadv_mesh_init(struct net_device *soft_iface)
 	spin_lock_init(&bat_priv->tt.last_changeset_lock);
 	spin_lock_init(&bat_priv->tt.commit_lock);
 	spin_lock_init(&bat_priv->gw.list_lock);
+#ifdef CONFIG_BATMAN_ADV_MCAST
+	spin_lock_init(&bat_priv->mcast.want_lists_lock);
+#endif
 	spin_lock_init(&bat_priv->tvlv.container_list_lock);
 	spin_lock_init(&bat_priv->tvlv.handler_list_lock);
 	spin_lock_init(&bat_priv->softif_vlan_list_lock);
@@ -118,6 +121,9 @@ int batadv_mesh_init(struct net_device *soft_iface)
 	INIT_HLIST_HEAD(&bat_priv->forw_bat_list);
 	INIT_HLIST_HEAD(&bat_priv->forw_bcast_list);
 	INIT_HLIST_HEAD(&bat_priv->gw.list);
+#ifdef CONFIG_BATMAN_ADV_MCAST
+	INIT_HLIST_HEAD(&bat_priv->mcast.want_all_unsnoopables_list);
+#endif
 	INIT_LIST_HEAD(&bat_priv->tt.changes_list);
 	INIT_LIST_HEAD(&bat_priv->tt.req_list);
 	INIT_LIST_HEAD(&bat_priv->tt.roam_list);
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index aa4f73a..515dce7 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -177,6 +177,7 @@ enum batadv_uev_type {
 #include <linux/slab.h>
 #include <net/sock.h>		/* struct sock */
 #include <net/addrconf.h>	/* ipv6 address stuff */
+#include <linux/ip.h>
 #include <net/rtnetlink.h>
 #include <linux/jiffies.h>
 #include <linux/seq_file.h>
diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index 1d1627f..a4804fa 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -248,9 +248,48 @@ out:
 }
=20
 /**
+ * batadv_mcast_forw_mode_check_ipv4 - check for optimized forwarding =
potential
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: the IPv4 packet to check
+ * @is_unsnoopable: stores whether the destination is snoopable
+ *
+ * Checks whether the given IPv4 packet has the potential to be forwar=
ded with a
+ * mode more optimal than classic flooding.
+ *
+ * If so then returns 0. Otherwise -EINVAL is returned or -ENOMEM in c=
ase of
+ * memory allocation failure.
+ */
+static int batadv_mcast_forw_mode_check_ipv4(struct batadv_priv *bat_p=
riv,
+					     struct sk_buff *skb,
+					     bool *is_unsnoopable)
+{
+	struct iphdr *iphdr;
+
+	/* We might fail due to out-of-memory -> drop it */
+	if (!pskb_may_pull(skb, sizeof(struct ethhdr) + sizeof(*iphdr)))
+		return -ENOMEM;
+
+	iphdr =3D ip_hdr(skb);
+
+	/* TODO: Implement Multicast Router Discovery (RFC4286),
+	 * then allow scope > link local, too
+	 */
+	if (!ipv4_is_local_multicast(iphdr->daddr))
+		return -EINVAL;
+
+	/* link-local multicast listeners behind a bridge are
+	 * not snoopable (see RFC4541, section 2.1.2.2)
+	 */
+	*is_unsnoopable =3D true;
+
+	return 0;
+}
+
+/**
  * batadv_mcast_forw_mode_check_ipv6 - check for optimized forwarding =
potential
  * @bat_priv: the bat priv with all the soft interface information
  * @skb: the IPv6 packet to check
+ * @is_unsnoopable: stores whether the destination is snoopable
  *
  * Checks whether the given IPv6 packet has the potential to be forwar=
ded with a
  * mode more optimal than classic flooding.
@@ -259,7 +298,8 @@ out:
  * of memory.
  */
 static int batadv_mcast_forw_mode_check_ipv6(struct batadv_priv *bat_p=
riv,
-					     struct sk_buff *skb)
+					     struct sk_buff *skb,
+					     bool *is_unsnoopable)
 {
 	struct ipv6hdr *ip6hdr;
=20
@@ -279,7 +319,7 @@ static int batadv_mcast_forw_mode_check_ipv6(struct=
 batadv_priv *bat_priv,
 	 * not snoopable (see RFC4541, section 3, paragraph 3)
 	 */
 	if (ipv6_addr_is_ll_all_nodes(&ip6hdr->daddr))
-		return -EINVAL;
+		*is_unsnoopable =3D true;
=20
 	return 0;
 }
@@ -288,6 +328,7 @@ static int batadv_mcast_forw_mode_check_ipv6(struct=
 batadv_priv *bat_priv,
  * batadv_mcast_forw_mode_check - check for optimized forwarding poten=
tial
  * @bat_priv: the bat priv with all the soft interface information
  * @skb: the multicast frame to check
+ * @is_unsnoopable: stores whether the destination is snoopable
  *
  * Checks whether the given multicast ethernet frame has the potential=
 to be
  * forwarded with a mode more optimal than classic flooding.
@@ -296,7 +337,8 @@ static int batadv_mcast_forw_mode_check_ipv6(struct=
 batadv_priv *bat_priv,
  * of memory.
  */
 static int batadv_mcast_forw_mode_check(struct batadv_priv *bat_priv,
-					struct sk_buff *skb)
+					struct sk_buff *skb,
+					bool *is_unsnoopable)
 {
 	struct ethhdr *ethhdr =3D eth_hdr(skb);
=20
@@ -307,8 +349,12 @@ static int batadv_mcast_forw_mode_check(struct bat=
adv_priv *bat_priv,
 		return -EINVAL;
=20
 	switch (ntohs(ethhdr->h_proto)) {
+	case ETH_P_IP:
+		return batadv_mcast_forw_mode_check_ipv4(bat_priv, skb,
+							 is_unsnoopable);
 	case ETH_P_IPV6:
-		return batadv_mcast_forw_mode_check_ipv6(bat_priv, skb);
+		return batadv_mcast_forw_mode_check_ipv6(bat_priv, skb,
+							 is_unsnoopable);
 	default:
 		return -EINVAL;
 	}
@@ -331,6 +377,33 @@ batadv_mcast_forw_tt_node_get(struct batadv_priv *=
bat_priv,
 }
=20
 /**
+ * batadv_mcast_want_forw_unsnoop_node_get - get a node with an unsnoo=
pable flag
+ * @bat_priv: the bat priv with all the soft interface information
+ *
+ * Returns an orig_node which has the BATADV_MCAST_WANT_ALL_UNSNOOPABL=
ES flag
+ * set and increases its refcount.
+ */
+static struct batadv_orig_node *
+batadv_mcast_forw_unsnoop_node_get(struct batadv_priv *bat_priv)
+{
+	struct batadv_orig_node *tmp_orig_node, *orig_node =3D NULL;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(tmp_orig_node,
+				 &bat_priv->mcast.want_all_unsnoopables_list,
+				 mcast_want_all_unsnoopables_node) {
+		if (!atomic_inc_not_zero(&orig_node->refcount))
+			continue;
+
+		orig_node =3D tmp_orig_node;
+		break;
+	}
+	rcu_read_unlock();
+
+	return orig_node;
+}
+
+/**
  * batadv_mcast_forw_mode - check on how to forward a multicast packet
  * @bat_priv: the bat priv with all the soft interface information
  * @skb: The multicast packet to check
@@ -344,10 +417,11 @@ enum batadv_forw_mode
 batadv_mcast_forw_mode(struct batadv_priv *bat_priv, struct sk_buff *s=
kb,
 		       struct batadv_orig_node **orig)
 {
+	int ret, tt_count, unsnoop_count, total_count;
+	bool is_unsnoopable =3D false;
 	struct ethhdr *ethhdr;
-	int ret, tt_count;
=20
-	ret =3D batadv_mcast_forw_mode_check(bat_priv, skb);
+	ret =3D batadv_mcast_forw_mode_check(bat_priv, skb, &is_unsnoopable);
 	if (ret =3D=3D -ENOMEM)
 		return BATADV_FORW_NONE;
 	else if (ret < 0)
@@ -357,10 +431,18 @@ batadv_mcast_forw_mode(struct batadv_priv *bat_pr=
iv, struct sk_buff *skb,
=20
 	tt_count =3D batadv_tt_global_hash_count(bat_priv, ethhdr->h_dest,
 					       BATADV_NO_FLAGS);
+	unsnoop_count =3D !is_unsnoopable ? 0 :
+			atomic_read(&bat_priv->mcast.num_want_all_unsnoopables);
=20
-	switch (tt_count) {
+	total_count =3D tt_count + unsnoop_count;
+
+	switch (total_count) {
 	case 1:
-		*orig =3D batadv_mcast_forw_tt_node_get(bat_priv, ethhdr);
+		if (tt_count)
+			*orig =3D batadv_mcast_forw_tt_node_get(bat_priv, ethhdr);
+		else if (unsnoop_count)
+			*orig =3D batadv_mcast_forw_unsnoop_node_get(bat_priv);
+
 		if (*orig)
 			return BATADV_FORW_SINGLE;
=20
@@ -373,6 +455,39 @@ batadv_mcast_forw_mode(struct batadv_priv *bat_pri=
v, struct sk_buff *skb,
 }
=20
 /**
+ * batadv_mcast_want_unsnoop_update - update unsnoop counter and list
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig: the orig_node which multicast state might have changed of
+ * @mcast_flags: flags indicating the new multicast state
+ *
+ * If the BATADV_MCAST_WANT_ALL_UNSNOOPABLES flag of this originator,
+ * orig, has toggled then this method updates counter and list accordi=
ngly.
+ */
+static void batadv_mcast_want_unsnoop_update(struct batadv_priv *bat_p=
riv,
+					     struct batadv_orig_node *orig,
+					     uint8_t mcast_flags)
+{
+	/* switched from flag unset to set */
+	if (mcast_flags & BATADV_MCAST_WANT_ALL_UNSNOOPABLES &&
+	    !(orig->mcast_flags & BATADV_MCAST_WANT_ALL_UNSNOOPABLES)) {
+		atomic_inc(&bat_priv->mcast.num_want_all_unsnoopables);
+
+		spin_lock_bh(&bat_priv->mcast.want_lists_lock);
+		hlist_add_head_rcu(&orig->mcast_want_all_unsnoopables_node,
+				   &bat_priv->mcast.want_all_unsnoopables_list);
+		spin_unlock_bh(&bat_priv->mcast.want_lists_lock);
+	/* switched from flag set to unset */
+	} else if (!(mcast_flags & BATADV_MCAST_WANT_ALL_UNSNOOPABLES) &&
+		   orig->mcast_flags & BATADV_MCAST_WANT_ALL_UNSNOOPABLES) {
+		atomic_dec(&bat_priv->mcast.num_want_all_unsnoopables);
+
+		spin_lock_bh(&bat_priv->mcast.want_lists_lock);
+		hlist_del_rcu(&orig->mcast_want_all_unsnoopables_node);
+		spin_unlock_bh(&bat_priv->mcast.want_lists_lock);
+	}
+}
+
+/**
  * batadv_mcast_tvlv_ogm_handler_v1 - process incoming multicast tvlv =
container
  * @bat_priv: the bat priv with all the soft interface information
  * @orig: the orig_node of the ogm
@@ -416,6 +531,8 @@ static void batadv_mcast_tvlv_ogm_handler_v1(struct=
 batadv_priv *bat_priv,
 	    (tvlv_value_len >=3D sizeof(mcast_flags)))
 		mcast_flags =3D *(uint8_t *)tvlv_value;
=20
+	batadv_mcast_want_unsnoop_update(bat_priv, orig, mcast_flags);
+
 	orig->mcast_flags =3D mcast_flags;
 }
=20
@@ -452,4 +569,6 @@ void batadv_mcast_purge_orig(struct batadv_orig_nod=
e *orig)
=20
 	if (!(orig->capabilities & BATADV_ORIG_CAPA_HAS_MCAST))
 		atomic_dec(&bat_priv->mcast.num_disabled);
+
+	batadv_mcast_want_unsnoop_update(bat_priv, orig, BATADV_NO_FLAGS);
 }
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index e8c483d..d061e26 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -89,6 +89,15 @@ enum batadv_icmp_packettype {
 	BATADV_PARAMETER_PROBLEM       =3D 12,
 };
=20
+/**
+ * enum batadv_mcast_flags - flags for multicast capabilities and sett=
ings
+ * @BATADV_MCAST_WANT_ALL_UNSNOOPABLES: we want all packets destined f=
or
+ *  224.0.0.0/24 or ff02::1
+ */
+enum batadv_mcast_flags {
+	BATADV_MCAST_WANT_ALL_UNSNOOPABLES	=3D BIT(0),
+};
+
 /* tt data subtypes */
 #define BATADV_TT_DATA_TYPE_MASK 0x0F
=20
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 1a643fe6..db6feca 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -710,6 +710,7 @@ static int batadv_softif_init_late(struct net_devic=
e *dev)
 	bat_priv->mcast.flags =3D BATADV_NO_FLAGS;
 	atomic_set(&bat_priv->multicast_mode, 1);
 	atomic_set(&bat_priv->mcast.num_disabled, 0);
+	atomic_set(&bat_priv->mcast.num_want_all_unsnoopables, 0);
 #endif
 	atomic_set(&bat_priv->gw_mode, BATADV_GW_MODE_OFF);
 	atomic_set(&bat_priv->gw_sel_class, 20);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index c28fc4a..1a674cb 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -205,6 +205,8 @@ struct batadv_orig_bat_iv {
  * @last_seen: time when last packet from this node was received
  * @bcast_seqno_reset: time when the broadcast seqno window was reset
  * @mcast_flags: multicast flags announced by the orig node
+ * @mcast_want_all_unsnoop_node: a list node for the
+ *  mcast.want_all_unsnoopables list
  * @capabilities: announced capabilities of this originator
  * @capa_initialized: bitfield to remember whether a capability was in=
itialized
  * @last_ttvn: last seen translation table version number
@@ -249,6 +251,7 @@ struct batadv_orig_node {
 	unsigned long bcast_seqno_reset;
 #ifdef CONFIG_BATMAN_ADV_MCAST
 	uint8_t mcast_flags;
+	struct hlist_node mcast_want_all_unsnoopables_node;
 #endif
 	uint8_t capabilities;
 	uint8_t capa_initialized;
@@ -619,15 +622,24 @@ struct batadv_priv_dat {
 /**
  * struct batadv_priv_mcast - per mesh interface mcast data
  * @mla_list: list of multicast addresses we are currently announcing =
via TT
+ * @want_all_unsnoopables_list: a list of orig_nodes wanting all unsno=
opable
+ *  multicast traffic
  * @flags: the flags we have last sent in our mcast tvlv
  * @enabled: whether the multicast tvlv is currently enabled
  * @num_disabled: number of nodes that have no mcast tvlv
+ * @num_want_all_unsnoopables: number of nodes wanting unsnoopable IP =
traffic
+ * @want_lists_lock: lock for protecting modifications to mcast want l=
ists
+ *  (traversals are rcu-locked)
  */
 struct batadv_priv_mcast {
 	struct hlist_head mla_list;
+	struct hlist_head want_all_unsnoopables_list;
 	uint8_t flags;
 	bool enabled;
 	atomic_t num_disabled;
+	atomic_t num_want_all_unsnoopables;
+	/* protects want_all_unsnoopables_list */
+	spinlock_t want_lists_lock;
 };
 #endif
=20
--=20
1.8.3.2
