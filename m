From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: [PATCH RFCv2 3/4] batman-adv: Forward IGMP/MLD reports to
 selected querier (only)
Date: Wed,  1 Apr 2015 10:04:38 +0200
Message-ID: <1427875479-9240-4-git-send-email-linus.luessing@c0d3.blue>
References: <1427875479-9240-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
To: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1427875479-9240-1-git-send-email-linus.luessing@c0d3.blue>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

With this patch IGMP or MLD reports are only forwarded to the selected
IGMP/MLD querier as RFC4541 suggests. This is necessary to avoid
multicast packet loss in bridged scenarios later:

An IGMPv2/MLDv1 querier does not actively join the multicast group the
reports are sent to. Because of this, this leads to snooping
bridges/switches not being able to learn of multicast listeners in the
mesh and wrongly shutting down ports for multicast traffic to the mesh.
---
 net/batman-adv/main.h           |    6 +-
 net/batman-adv/multicast.c      |  248 +++++++++++++++++++++++++++++++++=
+++++-
 net/batman-adv/multicast.h      |    8 ++
 net/batman-adv/soft-interface.c |   11 ++
 net/batman-adv/types.h          |   14 +++
 5 files changed, 280 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 4d23188..b6d3a73 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -178,9 +178,11 @@ enum batadv_uev_type {
 #include <net/addrconf.h>	/* ipv6 address stuff */
 #include <linux/ip.h>
 #include <net/rtnetlink.h>
+#include <net/mld.h>
 #include <linux/jiffies.h>
 #include <linux/seq_file.h>
 #include <linux/if_vlan.h>
+#include <linux/igmp.h>
=20
 #include "types.h"
=20
@@ -221,6 +223,7 @@ __be32 batadv_skb_crc32(struct sk_buff *skb, u8 *payl=
oad_ptr);
  * @BATADV_DBG_BLA: bridge loop avoidance messages
  * @BATADV_DBG_DAT: ARP snooping and DAT related messages
  * @BATADV_DBG_NC: network coding related messages
+ * @BATADV_DBG_MCAST: multicast related messages
  * @BATADV_DBG_ALL: the union of all the above log levels
  */
 enum batadv_dbg_level {
@@ -230,7 +233,8 @@ enum batadv_dbg_level {
 	BATADV_DBG_BLA    =3D BIT(3),
 	BATADV_DBG_DAT    =3D BIT(4),
 	BATADV_DBG_NC	  =3D BIT(5),
-	BATADV_DBG_ALL    =3D 63,
+	BATADV_DBG_MCAST  =3D BIT(6),
+	BATADV_DBG_ALL    =3D 127,
 };
=20
 #ifdef CONFIG_BATMAN_ADV_DEBUG
diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index b24e4bb..055f55b 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -247,10 +247,76 @@ out:
 }
=20
 /**
+ * batadv_mcast_is_report_ipv4 -=E2=80=AFcheck for IGMP reports (and que=
ries)
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: the ethernet frame destined for the mesh
+ * @orig: if IGMP report:=E2=80=AFto be set to the querier to forward th=
e skb to
+ *
+ * Checks whether the given frame is an IGMP report and if so sets the
+ * orig pointer to the originator of the selected IGMP querier if one ex=
ists
+ * and returns true. Otherwise returns false.
+ *
+ * If the packet is a general IGMP query instead then we delete the memo=
rized,
+ * foreign IGMP querier (if one exists): We became the selected querier =
and
+ * therefore do not need to forward reports into the mesh.
+ *
+ * This call might reallocate skb data.
+ */
+static bool batadv_mcast_is_report_ipv4(struct batadv_priv *bat_priv,
+					struct sk_buff *skb,
+					struct batadv_orig_node **orig)
+{
+	struct batadv_mcast_querier_state *querier;
+	struct batadv_orig_node *orig_node;
+
+	if (ip_mc_check_igmp(skb, NULL) < 0)
+		return false;
+
+	querier =3D &bat_priv->mcast.querier_ipv4;
+
+	switch (igmp_hdr(skb)->type) {
+	case IGMP_HOST_MEMBERSHIP_REPORT:
+	case IGMPV2_HOST_MEMBERSHIP_REPORT:
+	case IGMPV3_HOST_MEMBERSHIP_REPORT:
+		rcu_read_lock();
+		orig_node =3D rcu_dereference(querier->orig);
+		if (orig_node && atomic_inc_not_zero(&orig_node->refcount)) {
+			/* TODO: include multicast routers via MRD (RFC4286) */
+			batadv_dbg(BATADV_DBG_MCAST, bat_priv,
+				   "Redirecting IGMP Report to %pM\n",
+				   orig_node->orig);
+			*orig =3D orig_node;
+		}
+		rcu_read_unlock();
+
+		return true;
+	case IGMP_HOST_MEMBERSHIP_QUERY:
+		/* RFC4541, section 2.1.1.1.b) says:
+		 * ignore general queries from 0.0.0.0
+		 */
+		if (!ip_hdr(skb)->saddr || igmp_hdr(skb)->group)
+			break;
+
+		spin_lock_bh(&querier->orig_lock);
+		orig_node =3D rcu_dereference(querier->orig);
+		if (orig_node)
+			rcu_assign_pointer(querier->orig, NULL);
+		spin_unlock_bh(&querier->orig_lock);
+
+		batadv_dbg(BATADV_DBG_MCAST, bat_priv,
+			   "Snooped own IGMP Query\n");
+		break;
+	}
+
+	return false;
+}
+
+/**
  * batadv_mcast_forw_mode_check_ipv4 - check for optimized forwarding po=
tential
  * @bat_priv: the bat priv with all the soft interface information
  * @skb: the IPv4 packet to check
  * @is_unsnoopable: stores whether the destination is snoopable
+ * @orig: for IGMP reports:=E2=80=AFto be set to the querier to forward =
the skb to
  *
  * Checks whether the given IPv4 packet has the potential to be forwarde=
d with a
  * mode more optimal than classic flooding.
@@ -260,7 +326,8 @@ out:
  */
 static int batadv_mcast_forw_mode_check_ipv4(struct batadv_priv *bat_pri=
v,
 					     struct sk_buff *skb,
-					     bool *is_unsnoopable)
+					     bool *is_unsnoopable,
+					     struct batadv_orig_node **orig)
 {
 	struct iphdr *iphdr;
=20
@@ -268,6 +335,9 @@ static int batadv_mcast_forw_mode_check_ipv4(struct b=
atadv_priv *bat_priv,
 	if (!pskb_may_pull(skb, sizeof(struct ethhdr) + sizeof(*iphdr)))
 		return -ENOMEM;
=20
+	if (batadv_mcast_is_report_ipv4(bat_priv, skb, orig))
+		return 0;
+
 	iphdr =3D ip_hdr(skb);
=20
 	/* TODO: Implement Multicast Router Discovery (RFC4286),
@@ -285,10 +355,72 @@ static int batadv_mcast_forw_mode_check_ipv4(struct=
 batadv_priv *bat_priv,
 }
=20
 /**
+ * batadv_mcast_is_report_ipv6 -=E2=80=AFcheck for MLD reports (and quer=
ies)
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: the ethernet frame destined for the mesh
+ * @orig: if MLD report:=E2=80=AFto be set to the querier to forward the=
 skb to
+ *
+ * Checks whether the given frame is an MLD report and if so sets the
+ * orig pointer to the originator of the selected MLD querier if one exi=
sts
+ * and returns true. Otherwise returns false.
+ *
+ * If the packet is a general MLD query instead then we delete the memor=
ized,
+ * foreign MLD querier (if one exists): We became the selected querier a=
nd
+ * therefore do not need to forward reports into the mesh.
+ *
+ * This call might reallocate skb data.
+ */
+static bool batadv_mcast_is_report_ipv6(struct batadv_priv *bat_priv,
+					struct sk_buff *skb,
+					struct batadv_orig_node **orig)
+{
+	struct mld_msg *mld;
+	struct batadv_mcast_querier_state *querier;
+	struct batadv_orig_node *orig_node;
+	int ret;
+
+	if (ipv6_mc_check_mld(skb, NULL) < 0)
+		return false;
+
+	querier =3D &bat_priv->mcast.querier_ipv6;
+	mld =3D (struct mld_msg *)icmp6_hdr(skb);
+
+	switch (mld->mld_type) {
+	case ICMPV6_MGM_REPORT:
+	case ICMPV6_MLD2_REPORT:
+		rcu_read_lock();
+		orig_node =3D rcu_dereference(querier->orig);
+		if (orig_node && atomic_inc_not_zero(&orig_node->refcount)) {
+			/* TODO: include multicast routers via MRD (RFC4286) */
+			batadv_dbg(BATADV_DBG_MCAST, bat_priv,
+				   "Redirecting MLD Report to %pM\n",
+				   orig_node->orig);
+			*orig =3D orig_node;
+		}
+		rcu_read_unlock();
+
+		return true;
+	case ICMPV6_MGM_QUERY:
+		spin_lock_bh(&querier->orig_lock);
+		orig_node =3D rcu_dereference(querier->orig);
+		if (orig_node)
+			rcu_assign_pointer(querier->orig, NULL);
+		spin_unlock_bh(&querier->orig_lock);
+
+		batadv_dbg(BATADV_DBG_MCAST, bat_priv,
+			   "Snooped own MLD Query\n");
+		break;
+	}
+
+	return false;
+}
+
+/**
  * batadv_mcast_forw_mode_check_ipv6 - check for optimized forwarding po=
tential
  * @bat_priv: the bat priv with all the soft interface information
  * @skb: the IPv6 packet to check
  * @is_unsnoopable: stores whether the destination is snoopable
+ * @orig: for MLD reports:=E2=80=AFto be set to the querier to forward t=
he skb to
  *
  * Checks whether the given IPv6 packet has the potential to be forwarde=
d with a
  * mode more optimal than classic flooding.
@@ -298,7 +430,8 @@ static int batadv_mcast_forw_mode_check_ipv4(struct b=
atadv_priv *bat_priv,
  */
 static int batadv_mcast_forw_mode_check_ipv6(struct batadv_priv *bat_pri=
v,
 					     struct sk_buff *skb,
-					     bool *is_unsnoopable)
+					     bool *is_unsnoopable,
+					     struct batadv_orig_node **orig)
 {
 	struct ipv6hdr *ip6hdr;
=20
@@ -306,6 +439,9 @@ static int batadv_mcast_forw_mode_check_ipv6(struct b=
atadv_priv *bat_priv,
 	if (!pskb_may_pull(skb, sizeof(struct ethhdr) + sizeof(*ip6hdr)))
 		return -ENOMEM;
=20
+	if (batadv_mcast_is_report_ipv6(bat_priv, skb, orig))
+		return 0;
+
 	ip6hdr =3D ipv6_hdr(skb);
=20
 	/* TODO: Implement Multicast Router Discovery (RFC4286),
@@ -337,7 +473,8 @@ static int batadv_mcast_forw_mode_check_ipv6(struct b=
atadv_priv *bat_priv,
  */
 static int batadv_mcast_forw_mode_check(struct batadv_priv *bat_priv,
 					struct sk_buff *skb,
-					bool *is_unsnoopable)
+					bool *is_unsnoopable,
+					struct batadv_orig_node **orig)
 {
 	struct ethhdr *ethhdr =3D eth_hdr(skb);
=20
@@ -350,10 +487,10 @@ static int batadv_mcast_forw_mode_check(struct bata=
dv_priv *bat_priv,
 	switch (ntohs(ethhdr->h_proto)) {
 	case ETH_P_IP:
 		return batadv_mcast_forw_mode_check_ipv4(bat_priv, skb,
-							 is_unsnoopable);
+							 is_unsnoopable, orig);
 	case ETH_P_IPV6:
 		return batadv_mcast_forw_mode_check_ipv6(bat_priv, skb,
-							 is_unsnoopable);
+							 is_unsnoopable, orig);
 	default:
 		return -EINVAL;
 	}
@@ -521,12 +658,16 @@ batadv_mcast_forw_mode(struct batadv_priv *bat_priv=
, struct sk_buff *skb,
 	bool is_unsnoopable =3D false;
 	struct ethhdr *ethhdr;
=20
-	ret =3D batadv_mcast_forw_mode_check(bat_priv, skb, &is_unsnoopable);
+	ret =3D batadv_mcast_forw_mode_check(bat_priv, skb, &is_unsnoopable,
+					   orig);
 	if (ret =3D=3D -ENOMEM)
 		return BATADV_FORW_NONE;
 	else if (ret < 0)
 		return BATADV_FORW_ALL;
=20
+	if (*orig)
+		return BATADV_FORW_SINGLE;
+
 	ethhdr =3D eth_hdr(skb);
=20
 	tt_count =3D batadv_tt_global_hash_count(bat_priv, ethhdr->h_dest,
@@ -558,6 +699,101 @@ batadv_mcast_forw_mode(struct batadv_priv *bat_priv=
, struct sk_buff *skb,
 }
=20
 /**
+ * batadv_mcast_snoop_query_ipv4 -=E2=80=AFsnoop for the selected MLD qu=
erier
+ * @skb: the unencapsulated ethernet frame coming from the mesh
+ * @orig_node: the originator this frame came from
+ *
+ * Checks whether the given frame is a general IGMP query from the selec=
ted
+ * querier and if so memorizes the originator this frame came from.
+ */
+static void batadv_mcast_snoop_query_ipv4(struct sk_buff *skb,
+					  struct batadv_orig_node *orig_node)
+{
+	struct batadv_mcast_querier_state *querier;
+
+	if (ip_mc_check_igmp(skb, NULL) < 0)
+		return;
+
+	/* we are only interested in general queries (group =3D=3D 0.0.0.0) */
+	if (igmp_hdr(skb)->type !=3D IGMP_HOST_MEMBERSHIP_QUERY ||
+	    igmp_hdr(skb)->group)
+		return;
+
+	/* RFC4541, section 2.1.1.1.b) says: ignore queries from 0.0.0.0 */
+	if (!ip_hdr(skb)->saddr)
+		return;
+
+	querier =3D &orig_node->bat_priv->mcast.querier_ipv4;
+
+	spin_lock_bh(&querier->orig_lock);
+	rcu_assign_pointer(querier->orig, orig_node);
+	spin_unlock_bh(&querier->orig_lock);
+
+	batadv_dbg(BATADV_DBG_MCAST, orig_node->bat_priv,
+		   "Snooped IGMP Query from originator %pM\n", orig_node->orig);
+}
+
+/**
+ * batadv_mcast_snoop_query_ipv6 -=E2=80=AFsnoop for the selected MLD qu=
erier
+ * @skb: the unencapsulated ethernet frame coming from the mesh
+ * @orig_node: the originator this frame came from
+ *
+ * Checks whether the given frame is a general MLD query from the select=
ed
+ * querier and if so memorizes the originator this frame came from.
+ */
+static void batadv_mcast_snoop_query_ipv6(struct sk_buff *skb,
+					  struct batadv_orig_node *orig_node)
+{
+	struct mld_msg *mld;
+	struct batadv_mcast_querier_state *querier;
+
+	if (ipv6_mc_check_mld(skb, NULL) < 0)
+		return;
+
+	mld =3D (struct mld_msg *)icmp6_hdr(skb);
+
+	/* we are only interested in general queries (mca =3D=3D=E2=80=AF::) */
+	if (mld->mld_type !=3D ICMPV6_MGM_QUERY ||
+	    !ipv6_addr_any(&mld->mld_mca))
+		return;
+
+	querier =3D &orig_node->bat_priv->mcast.querier_ipv6;
+
+	spin_lock_bh(&querier->orig_lock);
+	rcu_assign_pointer(querier->orig, orig_node);
+	spin_unlock_bh(&querier->orig_lock);
+
+	batadv_dbg(BATADV_DBG_MCAST, orig_node->bat_priv,
+		   "Snooped MLD Query from originator %pM\n", orig_node->orig);
+}
+
+/**
+ * batadv_mcast_snoop_query -=E2=80=AFsnoop the selected IGMP/MLD querie=
r
+ * @skb: the unencapsulated ethernet frame coming from the mesh
+ * @orig_node: the originator this frame came from
+ *
+ * Checks whether the given frame is a general IGMP or MLD query
+ * from the selected querier and if so memorizes the originator
+ * this frame came from.
+ *
+ * This call might reallocate skb data.
+ */
+void batadv_mcast_snoop_query(struct sk_buff *skb,
+			      struct batadv_orig_node *orig_node)
+{
+	struct ethhdr *ethhdr =3D eth_hdr(skb);
+
+	switch (ntohs(ethhdr->h_proto)) {
+	case ETH_P_IP:
+		batadv_mcast_snoop_query_ipv4(skb, orig_node);
+		break;
+	case ETH_P_IPV6:
+		batadv_mcast_snoop_query_ipv6(skb, orig_node);
+		break;
+	}
+}
+
+/**
  * batadv_mcast_want_unsnoop_update - update unsnoop counter and list
  * @bat_priv: the bat priv with all the soft interface information
  * @orig: the orig_node which multicast state might have changed of
diff --git a/net/batman-adv/multicast.h b/net/batman-adv/multicast.h
index 3a44ebd..3727beb 100644
--- a/net/batman-adv/multicast.h
+++ b/net/batman-adv/multicast.h
@@ -40,6 +40,9 @@ enum batadv_forw_mode
 batadv_mcast_forw_mode(struct batadv_priv *bat_priv, struct sk_buff *skb=
,
 		       struct batadv_orig_node **mcast_single_orig);
=20
+void batadv_mcast_snoop_query(struct sk_buff *skb,
+			      struct batadv_orig_node *orig_node);
+
 void batadv_mcast_init(struct batadv_priv *bat_priv);
=20
 void batadv_mcast_free(struct batadv_priv *bat_priv);
@@ -59,6 +62,11 @@ batadv_mcast_forw_mode(struct batadv_priv *bat_priv, s=
truct sk_buff *skb,
 	return BATADV_FORW_ALL;
 }
=20
+static inline void batadv_mcast_snoop_query(struct sk_buff *skb,
+					    struct batadv_orig_node *orig_node)
+{
+}
+
 static inline int batadv_mcast_init(struct batadv_priv *bat_priv)
 {
 	return 0;
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interf=
ace.c
index 5ec31d7..445d80e 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -176,6 +176,8 @@ static int batadv_interface_tx(struct sk_buff *skb,
 	if (atomic_read(&bat_priv->mesh_state) !=3D BATADV_MESH_ACTIVE)
 		goto dropped;
=20
+	skb_set_network_header(skb, ETH_HLEN);
+
 	soft_iface->trans_start =3D jiffies;
 	vid =3D batadv_get_vid(skb, 0);
 	ethhdr =3D eth_hdr(skb);
@@ -366,6 +368,7 @@ void batadv_interface_rx(struct net_device *soft_ifac=
e,
=20
 	skb_pull_rcsum(skb, hdr_size);
 	skb_reset_mac_header(skb);
+	skb_set_network_header(skb, ETH_HLEN);
=20
 	/* clean the netfilter state now that the batman-adv header has been
 	 * removed
@@ -428,6 +431,9 @@ void batadv_interface_rx(struct net_device *soft_ifac=
e,
 			skb->mark &=3D ~bat_priv->isolation_mark_mask;
 			skb->mark |=3D bat_priv->isolation_mark;
 		}
+
+		if (orig_node)
+			batadv_mcast_snoop_query(skb, orig_node);
 	} else if (batadv_is_ap_isolated(bat_priv, ethhdr->h_source,
 					 ethhdr->h_dest, vid)) {
 		goto dropped;
@@ -738,6 +744,11 @@ static int batadv_softif_init_late(struct net_device=
 *dev)
 	atomic_set(&bat_priv->distributed_arp_table, 1);
 #endif
 #ifdef CONFIG_BATMAN_ADV_MCAST
+	rcu_assign_pointer(bat_priv->mcast.querier_ipv4.orig, NULL);
+	spin_lock_init(&bat_priv->mcast.querier_ipv4.orig_lock);
+	rcu_assign_pointer(bat_priv->mcast.querier_ipv6.orig, NULL);
+	spin_lock_init(&bat_priv->mcast.querier_ipv6.orig_lock);
+
 	bat_priv->mcast.flags =3D BATADV_NO_FLAGS;
 	atomic_set(&bat_priv->multicast_mode, 1);
 	atomic_set(&bat_priv->mcast.num_disabled, 0);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 9398c3f..a0f5bf8 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -623,12 +623,24 @@ struct batadv_priv_dat {
=20
 #ifdef CONFIG_BATMAN_ADV_MCAST
 /**
+ * struct batadv_mcast_querier_state - IGMP/MLD querier state when bridg=
ed
+ * @orig: node on which=E2=80=AFthe selected querier resides
+ * @orig_lock:=E2=80=AFprotects updates of the selected querier in 'orig=
'
+ */
+struct batadv_mcast_querier_state {
+	struct batadv_orig_node __rcu *orig; /* rcu protected pointer */
+	spinlock_t orig_lock; /* protects updates of orig */
+};
+
+/**
  * struct batadv_priv_mcast - per mesh interface mcast data
  * @mla_list: list of multicast addresses we are currently announcing vi=
a TT
  * @want_all_unsnoopables_list: a list of orig_nodes wanting all unsnoop=
able
  *  multicast traffic
  * @want_all_ipv4_list: a list of orig_nodes wanting all IPv4 multicast =
traffic
  * @want_all_ipv6_list: a list of orig_nodes wanting all IPv6 multicast =
traffic
+ * @querier_ipv4: the current state of an IGMP querier in the mesh
+ * @querier_ipv6: the current state of an MLD querier in the mesh
  * @flags: the flags we have last sent in our mcast tvlv
  * @enabled: whether the multicast tvlv is currently enabled
  * @num_disabled: number of nodes that have no mcast tvlv
@@ -643,6 +655,8 @@ struct batadv_priv_mcast {
 	struct hlist_head want_all_unsnoopables_list;
 	struct hlist_head want_all_ipv4_list;
 	struct hlist_head want_all_ipv6_list;
+	struct batadv_mcast_querier_state querier_ipv4;
+	struct batadv_mcast_querier_state querier_ipv6;
 	uint8_t flags;
 	bool enabled;
 	atomic_t num_disabled;
--=20
1.7.10.4
