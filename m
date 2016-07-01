From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 15/17] batman-adv: Add multicast optimization
	support for bridged setups
Date: Fri,  1 Jul 2016 15:09:07 +0200
Message-ID: <1467378549-9646-16-git-send-email-sw@simonwunderlich.de>
References: <1467378549-9646-1-git-send-email-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1467378549-9646-1-git-send-email-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Linus L=C3=BCssing <linus.luessing-djzkFPsfvsizQB+pC5nmwQ@public.gmane.org>

With this patch we are finally able to support multicast optimizations
in bridged setups, too. So far, if a bridge was added on top of a
soft-interface (e.g. bat0) the batman-adv multicast optimizations
needed to be disabled to avoid packetloss.

Current Linux bridge implementations and API can now provide us
with the so far missing information about interested but "remote"
multicast receivers behind bridge ports.

The Linux bridge performs the detection of remote participants
interested in multicast packets with its own and mature so
called IGMP and MLD snooping code and stores that in its
database. With the new API provided by the bridge batman-adv can
now simply hook into this database.

We then reliably announce the gathered multicast listeners to
other nodes through the batman-adv translation table.

Additionally, the Linux bridge provides us with the information about
whether an IGMP/MLD querier exists. If there is none then we need to
disable multicast optimizations as we cannot learn about multicast
listeners on external, bridged-in host then.

Tested-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Signed-off-by: Linus L=C3=BCssing <linus.luessing-djzkFPsfvsizQB+pC5nmwQ@public.gmane.org>
Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 net/batman-adv/Kconfig     |   2 +-
 net/batman-adv/multicast.c | 181 +++++++++++++++++++++++++++++++++++++++=
+-----
 net/batman-adv/types.h     |  13 ++++
 3 files changed, 177 insertions(+), 19 deletions(-)

diff --git a/net/batman-adv/Kconfig b/net/batman-adv/Kconfig
index b7ba97d..833bb14 100644
--- a/net/batman-adv/Kconfig
+++ b/net/batman-adv/Kconfig
@@ -66,7 +66,7 @@ config BATMAN_ADV_NC
=20
 config BATMAN_ADV_MCAST
 	bool "Multicast optimisation"
-	depends on BATMAN_ADV && INET
+	depends on BATMAN_ADV && INET && !(BRIDGE=3Dm && BATMAN_ADV=3Dy)
 	default n
 	help
 	  This option enables the multicast optimisation which aims to
diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index 4673328..eb30316 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -26,6 +26,7 @@
 #include <linux/etherdevice.h>
 #include <linux/fs.h>
 #include <linux/icmpv6.h>
+#include <linux/if_bridge.h>
 #include <linux/if_ether.h>
 #include <linux/igmp.h>
 #include <linux/in.h>
@@ -36,6 +37,7 @@
 #include <linux/list.h>
 #include <linux/lockdep.h>
 #include <linux/netdevice.h>
+#include <linux/printk.h>
 #include <linux/rculist.h>
 #include <linux/rcupdate.h>
 #include <linux/skbuff.h>
@@ -45,18 +47,53 @@
 #include <linux/string.h>
 #include <linux/types.h>
 #include <net/addrconf.h>
+#include <net/if_inet6.h>
+#include <net/ip.h>
 #include <net/ipv6.h>
=20
 #include "packet.h"
 #include "translation-table.h"
=20
 /**
+ * batadv_mcast_get_bridge - get the bridge on top of the softif if it e=
xists
+ * @soft_iface: netdev struct of the mesh interface
+ *
+ * If the given soft interface has a bridge on top then the refcount
+ * of the according net device is increased.
+ *
+ * Return: NULL if no such bridge exists. Otherwise the net device of th=
e
+ * bridge.
+ */
+static struct net_device *batadv_mcast_get_bridge(struct net_device *sof=
t_iface)
+{
+	struct net_device *upper =3D soft_iface;
+
+	rcu_read_lock();
+	do {
+		upper =3D netdev_master_upper_dev_get_rcu(upper);
+	} while (upper && !(upper->priv_flags & IFF_EBRIDGE));
+
+	if (upper)
+		dev_hold(upper);
+	rcu_read_unlock();
+
+	return upper;
+}
+
+/**
  * batadv_mcast_mla_softif_get - get softif multicast listeners
  * @dev: the device to collect multicast addresses from
  * @mcast_list: a list to put found addresses into
  *
- * Collect multicast addresses of the local multicast listeners
- * on the given soft interface, dev, in the given mcast_list.
+ * Collects multicast addresses of multicast listeners residing
+ * on this kernel on the given soft interface, dev, in
+ * the given mcast_list. In general, multicast listeners provided by
+ * your multicast receiving applications run directly on this node.
+ *
+ * If there is a bridge interface on top of dev, collects from that one
+ * instead. Just like with IP addresses and routes, multicast listeners
+ * will(/should) register to the bridge interface instead of an
+ * enslaved bat0.
  *
  * Return: -ENOMEM on memory allocation error or the number of
  * items added to the mcast_list otherwise.
@@ -64,12 +101,13 @@
 static int batadv_mcast_mla_softif_get(struct net_device *dev,
 				       struct hlist_head *mcast_list)
 {
+	struct net_device *bridge =3D batadv_mcast_get_bridge(dev);
 	struct netdev_hw_addr *mc_list_entry;
 	struct batadv_hw_addr *new;
 	int ret =3D 0;
=20
-	netif_addr_lock_bh(dev);
-	netdev_for_each_mc_addr(mc_list_entry, dev) {
+	netif_addr_lock_bh(bridge ? bridge : dev);
+	netdev_for_each_mc_addr(mc_list_entry, bridge ? bridge : dev) {
 		new =3D kmalloc(sizeof(*new), GFP_ATOMIC);
 		if (!new) {
 			ret =3D -ENOMEM;
@@ -80,7 +118,10 @@ static int batadv_mcast_mla_softif_get(struct net_dev=
ice *dev,
 		hlist_add_head(&new->list, mcast_list);
 		ret++;
 	}
-	netif_addr_unlock_bh(dev);
+	netif_addr_unlock_bh(bridge ? bridge : dev);
+
+	if (bridge)
+		dev_put(bridge);
=20
 	return ret;
 }
@@ -106,6 +147,83 @@ static bool batadv_mcast_mla_is_duplicate(u8 *mcast_=
addr,
 }
=20
 /**
+ * batadv_mcast_mla_br_addr_cpy - copy a bridge multicast address
+ * @dst: destination to write to - a multicast MAC address
+ * @src: source to read from - a multicast IP address
+ *
+ * Converts a given multicast IPv4/IPv6 address from a bridge
+ * to its matching multicast MAC address and copies it into the given
+ * destination buffer.
+ *
+ * Caller needs to make sure the destination buffer can hold
+ * at least ETH_ALEN bytes.
+ */
+static void batadv_mcast_mla_br_addr_cpy(char *dst, const struct br_ip *=
src)
+{
+	if (src->proto =3D=3D htons(ETH_P_IP))
+		ip_eth_mc_map(src->u.ip4, dst);
+#if IS_ENABLED(CONFIG_IPV6)
+	else if (src->proto =3D=3D htons(ETH_P_IPV6))
+		ipv6_eth_mc_map(&src->u.ip6, dst);
+#endif
+	else
+		eth_zero_addr(dst);
+}
+
+/**
+ * batadv_mcast_mla_bridge_get - get bridged-in multicast listeners
+ * @dev: a bridge slave whose bridge to collect multicast addresses from
+ * @mcast_list: a list to put found addresses into
+ *
+ * Collects multicast addresses of multicast listeners residing
+ * on foreign, non-mesh devices which we gave access to our mesh via
+ * a bridge on top of the given soft interface, dev, in the given
+ * mcast_list.
+ *
+ * Return: -ENOMEM on memory allocation error or the number of
+ * items added to the mcast_list otherwise.
+ */
+static int batadv_mcast_mla_bridge_get(struct net_device *dev,
+				       struct hlist_head *mcast_list)
+{
+	struct list_head bridge_mcast_list =3D LIST_HEAD_INIT(bridge_mcast_list=
);
+	struct br_ip_list *br_ip_entry, *tmp;
+	struct batadv_hw_addr *new;
+	u8 mcast_addr[ETH_ALEN];
+	int ret;
+
+	/* we don't need to detect these devices/listeners, the IGMP/MLD
+	 * snooping code of the Linux bridge already does that for us
+	 */
+	ret =3D br_multicast_list_adjacent(dev, &bridge_mcast_list);
+	if (ret < 0)
+		goto out;
+
+	list_for_each_entry(br_ip_entry, &bridge_mcast_list, list) {
+		batadv_mcast_mla_br_addr_cpy(mcast_addr, &br_ip_entry->addr);
+		if (batadv_mcast_mla_is_duplicate(mcast_addr, mcast_list))
+			continue;
+
+		new =3D kmalloc(sizeof(*new), GFP_ATOMIC);
+		if (!new) {
+			ret =3D -ENOMEM;
+			break;
+		}
+
+		ether_addr_copy(new->addr, mcast_addr);
+		hlist_add_head(&new->list, mcast_list);
+	}
+
+out:
+	list_for_each_entry_safe(br_ip_entry, tmp, &bridge_mcast_list, list) {
+		list_del(&br_ip_entry->list);
+		kfree(br_ip_entry);
+	}
+
+	return ret;
+}
+
+/**
  * batadv_mcast_mla_list_free - free a list of multicast addresses
  * @bat_priv: the bat priv with all the soft interface information
  * @mcast_list: the list to free
@@ -222,29 +340,51 @@ static bool batadv_mcast_has_bridge(struct batadv_p=
riv *bat_priv)
  * Updates the own multicast tvlv with our current multicast related set=
tings,
  * capabilities and inabilities.
  *
- * Return: true if the tvlv container is registered afterwards. Otherwis=
e
- * returns false.
+ * Return: false if we want all IPv4 && IPv6 multicast traffic and true
+ * otherwise.
  */
 static bool batadv_mcast_mla_tvlv_update(struct batadv_priv *bat_priv)
 {
 	struct batadv_tvlv_mcast_data mcast_data;
+	struct batadv_mcast_querier_state querier4 =3D {false, false};
+	struct batadv_mcast_querier_state querier6 =3D {false, false};
+	struct net_device *dev =3D bat_priv->soft_iface;
=20
 	mcast_data.flags =3D BATADV_NO_FLAGS;
 	memset(mcast_data.reserved, 0, sizeof(mcast_data.reserved));
=20
-	/* Avoid attaching MLAs, if there is a bridge on top of our soft
-	 * interface, we don't support that yet (TODO)
+	bat_priv->mcast.bridged =3D batadv_mcast_has_bridge(bat_priv);
+	if (!bat_priv->mcast.bridged)
+		goto update;
+
+#if !IS_ENABLED(CONFIG_BRIDGE_IGMP_SNOOPING)
+	pr_warn_once("No bridge IGMP snooping compiled - multicast optimization=
s disabled\n");
+#endif
+
+	querier4.exists =3D br_multicast_has_querier_anywhere(dev, ETH_P_IP);
+	querier4.shadowing =3D br_multicast_has_querier_adjacent(dev, ETH_P_IP)=
;
+
+	querier6.exists =3D br_multicast_has_querier_anywhere(dev, ETH_P_IPV6);
+	querier6.shadowing =3D br_multicast_has_querier_adjacent(dev, ETH_P_IPV=
6);
+
+	mcast_data.flags |=3D BATADV_MCAST_WANT_ALL_UNSNOOPABLES;
+
+	/* 1) If no querier exists at all, then multicast listeners on
+	 *    our local TT clients behind the bridge will keep silent.
+	 * 2) If the selected querier is on one of our local TT clients,
+	 *    behind the bridge, then this querier might shadow multicast
+	 *    listeners on our local TT clients, behind this bridge.
+	 *
+	 * In both cases, we will signalize other batman nodes that
+	 * we need all multicast traffic of the according protocol.
 	 */
-	if (batadv_mcast_has_bridge(bat_priv)) {
-		if (bat_priv->mcast.enabled) {
-			batadv_tvlv_container_unregister(bat_priv,
-							 BATADV_TVLV_MCAST, 2);
-			bat_priv->mcast.enabled =3D false;
-		}
+	if (!querier4.exists || querier4.shadowing)
+		mcast_data.flags |=3D BATADV_MCAST_WANT_ALL_IPV4;
=20
-		return false;
-	}
+	if (!querier6.exists || querier6.shadowing)
+		mcast_data.flags |=3D BATADV_MCAST_WANT_ALL_IPV6;
=20
+update:
 	if (!bat_priv->mcast.enabled ||
 	    mcast_data.flags !=3D bat_priv->mcast.flags) {
 		batadv_tvlv_container_register(bat_priv, BATADV_TVLV_MCAST, 2,
@@ -253,7 +393,8 @@ static bool batadv_mcast_mla_tvlv_update(struct batad=
v_priv *bat_priv)
 		bat_priv->mcast.enabled =3D true;
 	}
=20
-	return true;
+	return !(mcast_data.flags &
+		 (BATADV_MCAST_WANT_ALL_IPV4 + BATADV_MCAST_WANT_ALL_IPV6));
 }
=20
 /**
@@ -276,6 +417,10 @@ void batadv_mcast_mla_update(struct batadv_priv *bat=
_priv)
 	if (ret < 0)
 		goto out;
=20
+	ret =3D batadv_mcast_mla_bridge_get(soft_iface, &mcast_list);
+	if (ret < 0)
+		goto out;
+
 update:
 	batadv_mcast_mla_tt_retract(bat_priv, &mcast_list);
 	batadv_mcast_mla_tt_add(bat_priv, &mcast_list);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 32c6d0e..83303c2 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -755,6 +755,17 @@ struct batadv_priv_dat {
=20
 #ifdef CONFIG_BATMAN_ADV_MCAST
 /**
+ * struct batadv_mcast_querier_state - IGMP/MLD querier state when bridg=
ed
+ * @exists: whether a querier exists in the mesh
+ * @shadowing: if a querier exists, whether it is potentially shadowing
+ *  multicast listeners (i.e. querier is behind our own bridge segment)
+ */
+struct batadv_mcast_querier_state {
+	bool exists;
+	bool shadowing;
+};
+
+/**
  * struct batadv_priv_mcast - per mesh interface mcast data
  * @mla_list: list of multicast addresses we are currently announcing vi=
a TT
  * @want_all_unsnoopables_list: a list of orig_nodes wanting all unsnoop=
able
@@ -763,6 +774,7 @@ struct batadv_priv_dat {
  * @want_all_ipv6_list: a list of orig_nodes wanting all IPv6 multicast =
traffic
  * @flags: the flags we have last sent in our mcast tvlv
  * @enabled: whether the multicast tvlv is currently enabled
+ * @bridged: whether the soft interface has a bridge on top
  * @num_disabled: number of nodes that have no mcast tvlv
  * @num_want_all_unsnoopables: number of nodes wanting unsnoopable IP tr=
affic
  * @num_want_all_ipv4: counter for items in want_all_ipv4_list
@@ -777,6 +789,7 @@ struct batadv_priv_mcast {
 	struct hlist_head want_all_ipv6_list;
 	u8 flags;
 	bool enabled;
+	bool bridged;
 	atomic_t num_disabled;
 	atomic_t num_want_all_unsnoopables;
 	atomic_t num_want_all_ipv4;
--=20
2.8.1
