From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 08/16] batman-adv: Multicast Listener Announcements via Translation Table
Date: Sat, 22 Mar 2014 09:56:08 +0100
Message-ID: <1395478576-10999-9-git-send-email-antonio@meshcoding.com>
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
Received: from s3.neomailbox.net ([178.209.62.157]:25467 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070AbaCVI44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2014 04:56:56 -0400
In-Reply-To: <1395478576-10999-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@web.de>

With this patch a node which has no bridge interface on top of its soft
interface announces its local multicast listeners via the translation
table.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/Kconfig             |   9 ++
 net/batman-adv/Makefile            |   1 +
 net/batman-adv/main.c              |   6 +
 net/batman-adv/main.h              |   1 +
 net/batman-adv/multicast.c         | 218 +++++++++++++++++++++++++++++=
++++++++
 net/batman-adv/multicast.h         |  41 +++++++
 net/batman-adv/translation-table.c |  22 +++-
 net/batman-adv/types.h             |  24 ++++
 8 files changed, 318 insertions(+), 4 deletions(-)
 create mode 100644 net/batman-adv/multicast.c
 create mode 100644 net/batman-adv/multicast.h

diff --git a/net/batman-adv/Kconfig b/net/batman-adv/Kconfig
index fa780b7..11660a3 100644
--- a/net/batman-adv/Kconfig
+++ b/net/batman-adv/Kconfig
@@ -50,6 +50,15 @@ config BATMAN_ADV_NC
 	  If you think that your network does not need this feature you
 	  can safely disable it and save some space.
=20
+config BATMAN_ADV_MCAST
+	bool "Multicast optimisation"
+	depends on BATMAN_ADV
+	default n
+	help
+	  This option enables the multicast optimisation which aims to
+	  reduce the air overhead while improving the reliability of
+	  multicast messages.
+
 config BATMAN_ADV_DEBUG
 	bool "B.A.T.M.A.N. debugging"
 	depends on BATMAN_ADV
diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index 42df18f..eb7d8c03 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -36,3 +36,4 @@ batman-adv-y +=3D send.o
 batman-adv-y +=3D soft-interface.o
 batman-adv-y +=3D sysfs.o
 batman-adv-y +=3D translation-table.o
+batman-adv-$(CONFIG_BATMAN_ADV_MCAST) +=3D multicast.o
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index fbeaebd..58e98c8 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -34,6 +34,7 @@
 #include "gateway_client.h"
 #include "bridge_loop_avoidance.h"
 #include "distributed-arp-table.h"
+#include "multicast.h"
 #include "gateway_common.h"
 #include "hash.h"
 #include "bat_algo.h"
@@ -120,6 +121,9 @@ int batadv_mesh_init(struct net_device *soft_iface)
 	INIT_LIST_HEAD(&bat_priv->tt.changes_list);
 	INIT_LIST_HEAD(&bat_priv->tt.req_list);
 	INIT_LIST_HEAD(&bat_priv->tt.roam_list);
+#ifdef CONFIG_BATMAN_ADV_MCAST
+	INIT_HLIST_HEAD(&bat_priv->mcast.mla_list);
+#endif
 	INIT_HLIST_HEAD(&bat_priv->tvlv.container_list);
 	INIT_HLIST_HEAD(&bat_priv->tvlv.handler_list);
 	INIT_HLIST_HEAD(&bat_priv->softif_vlan_list);
@@ -169,6 +173,8 @@ void batadv_mesh_free(struct net_device *soft_iface=
)
 	batadv_dat_free(bat_priv);
 	batadv_bla_free(bat_priv);
=20
+	batadv_mcast_free(bat_priv);
+
 	/* Free the TT and the originator tables only after having terminated
 	 * all the other depending components which may use these structures =
for
 	 * their purposes.
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 9374f1a..aa4f73a 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -176,6 +176,7 @@ enum batadv_uev_type {
 #include <linux/percpu.h>
 #include <linux/slab.h>
 #include <net/sock.h>		/* struct sock */
+#include <net/addrconf.h>	/* ipv6 address stuff */
 #include <net/rtnetlink.h>
 #include <linux/jiffies.h>
 #include <linux/seq_file.h>
diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
new file mode 100644
index 0000000..e099fd6
--- /dev/null
+++ b/net/batman-adv/multicast.c
@@ -0,0 +1,218 @@
+/* Copyright (C) 2014 B.A.T.M.A.N. contributors:
+ *
+ * Linus L=C3=BCssing
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
+ * along with this program; if not, see <http://www.gnu.org/licenses/>=
=2E
+ */
+
+#include "main.h"
+#include "multicast.h"
+#include "originator.h"
+#include "hard-interface.h"
+#include "translation-table.h"
+
+/**
+ * batadv_mcast_mla_softif_get - get softif multicast listeners
+ * @dev: the device to collect multicast addresses from
+ * @mcast_list: a list to put found addresses into
+ *
+ * Collect multicast addresses of the local multicast listeners
+ * on the given soft interface, dev, in the given mcast_list.
+ *
+ * Returns -ENOMEM on memory allocation error or the number of
+ * items added to the mcast_list otherwise.
+ */
+static int batadv_mcast_mla_softif_get(struct net_device *dev,
+				       struct hlist_head *mcast_list)
+{
+	struct netdev_hw_addr *mc_list_entry;
+	struct batadv_hw_addr *new;
+	int ret =3D 0;
+
+	netif_addr_lock_bh(dev);
+	netdev_for_each_mc_addr(mc_list_entry, dev) {
+		new =3D kmalloc(sizeof(*new), GFP_ATOMIC);
+		if (!new) {
+			ret =3D -ENOMEM;
+			break;
+		}
+
+		ether_addr_copy(new->addr, mc_list_entry->addr);
+		hlist_add_head(&new->list, mcast_list);
+		ret++;
+	}
+	netif_addr_unlock_bh(dev);
+
+	return ret;
+}
+
+/**
+ * batadv_mcast_mla_is_duplicate - check whether an address is in a li=
st
+ * @mcast_addr: the multicast address to check
+ * @mcast_list: the list with multicast addresses to search in
+ *
+ * Returns true if the given address is already in the given list.
+ * Otherwise returns false.
+ */
+static bool batadv_mcast_mla_is_duplicate(uint8_t *mcast_addr,
+					  struct hlist_head *mcast_list)
+{
+	struct batadv_hw_addr *mcast_entry;
+
+	hlist_for_each_entry(mcast_entry, mcast_list, list)
+		if (batadv_compare_eth(mcast_entry->addr, mcast_addr))
+			return true;
+
+	return false;
+}
+
+/**
+ * batadv_mcast_mla_list_free - free a list of multicast addresses
+ * @mcast_list: the list to free
+ *
+ * Removes and frees all items in the given mcast_list.
+ */
+static void batadv_mcast_mla_list_free(struct hlist_head *mcast_list)
+{
+	struct batadv_hw_addr *mcast_entry;
+	struct hlist_node *tmp;
+
+	hlist_for_each_entry_safe(mcast_entry, tmp, mcast_list, list) {
+		hlist_del(&mcast_entry->list);
+		kfree(mcast_entry);
+	}
+}
+
+/**
+ * batadv_mcast_mla_tt_retract - clean up multicast listener announcem=
ents
+ * @bat_priv: the bat priv with all the soft interface information
+ * @mcast_list: a list of addresses which should _not_ be removed
+ *
+ * Retracts the announcement of any multicast listener from the
+ * translation table except the ones listed in the given mcast_list.
+ *
+ * If mcast_list is NULL then all are retracted.
+ */
+static void batadv_mcast_mla_tt_retract(struct batadv_priv *bat_priv,
+					struct hlist_head *mcast_list)
+{
+	struct batadv_hw_addr *mcast_entry;
+	struct hlist_node *tmp;
+
+	hlist_for_each_entry_safe(mcast_entry, tmp, &bat_priv->mcast.mla_list=
,
+				  list) {
+		if (mcast_list &&
+		    batadv_mcast_mla_is_duplicate(mcast_entry->addr,
+						  mcast_list))
+			continue;
+
+		batadv_tt_local_remove(bat_priv, mcast_entry->addr,
+				       BATADV_NO_FLAGS,
+				       "mcast TT outdated", false);
+
+		hlist_del(&mcast_entry->list);
+		kfree(mcast_entry);
+	}
+}
+
+/**
+ * batadv_mcast_mla_tt_add - add multicast listener announcements
+ * @bat_priv: the bat priv with all the soft interface information
+ * @mcast_list: a list of addresses which are going to get added
+ *
+ * Adds multicast listener announcements from the given mcast_list to =
the
+ * translation table if they have not been added yet.
+ */
+static void batadv_mcast_mla_tt_add(struct batadv_priv *bat_priv,
+				    struct hlist_head *mcast_list)
+{
+	struct batadv_hw_addr *mcast_entry;
+	struct hlist_node *tmp;
+
+	if (!mcast_list)
+		return;
+
+	hlist_for_each_entry_safe(mcast_entry, tmp, mcast_list, list) {
+		if (batadv_mcast_mla_is_duplicate(mcast_entry->addr,
+						  &bat_priv->mcast.mla_list))
+			continue;
+
+		if (!batadv_tt_local_add(bat_priv->soft_iface,
+					 mcast_entry->addr, BATADV_NO_FLAGS,
+					 BATADV_NULL_IFINDEX, BATADV_NO_MARK))
+			continue;
+
+		hlist_del(&mcast_entry->list);
+		hlist_add_head(&mcast_entry->list, &bat_priv->mcast.mla_list);
+	}
+}
+
+/**
+ * batadv_mcast_has_bridge - check whether the soft-iface is bridged
+ * @bat_priv: the bat priv with all the soft interface information
+ *
+ * Checks whether there is a bridge on top of our soft interface. Retu=
rns
+ * true if so, false otherwise.
+ */
+static bool batadv_mcast_has_bridge(struct batadv_priv *bat_priv)
+{
+	struct net_device *upper =3D bat_priv->soft_iface;
+
+	rcu_read_lock();
+	do {
+		upper =3D netdev_master_upper_dev_get_rcu(upper);
+	} while (upper && !(upper->priv_flags & IFF_EBRIDGE));
+	rcu_read_unlock();
+
+	return upper;
+}
+
+/**
+ * batadv_mcast_mla_update - update the own MLAs
+ * @bat_priv: the bat priv with all the soft interface information
+ *
+ * Update the own multicast listener announcements in the translation
+ * table.
+ */
+void batadv_mcast_mla_update(struct batadv_priv *bat_priv)
+{
+	struct net_device *soft_iface =3D bat_priv->soft_iface;
+	struct hlist_head mcast_list =3D HLIST_HEAD_INIT;
+	int ret;
+
+	/* Avoid attaching MLAs, if there is a bridge on top of our soft
+	 * interface, we don't support that yet (TODO)
+	 */
+	if (batadv_mcast_has_bridge(bat_priv))
+		goto update;
+
+	ret =3D batadv_mcast_mla_softif_get(soft_iface, &mcast_list);
+	if (ret < 0)
+		goto out;
+
+update:
+	batadv_mcast_mla_tt_retract(bat_priv, &mcast_list);
+	batadv_mcast_mla_tt_add(bat_priv, &mcast_list);
+
+out:
+	batadv_mcast_mla_list_free(&mcast_list);
+}
+
+/**
+ * batadv_mcast_free - free the multicast optimizations structures
+ * @bat_priv: the bat priv with all the soft interface information
+ */
+void batadv_mcast_free(struct batadv_priv *bat_priv)
+{
+	batadv_mcast_mla_tt_retract(bat_priv, NULL);
+}
diff --git a/net/batman-adv/multicast.h b/net/batman-adv/multicast.h
new file mode 100644
index 0000000..7513e02
--- /dev/null
+++ b/net/batman-adv/multicast.h
@@ -0,0 +1,41 @@
+/* Copyright (C) 2014 B.A.T.M.A.N. contributors:
+ *
+ * Linus L=C3=BCssing
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
+ * along with this program; if not, see <http://www.gnu.org/licenses/>=
=2E
+ */
+
+#ifndef _NET_BATMAN_ADV_MULTICAST_H_
+#define _NET_BATMAN_ADV_MULTICAST_H_
+
+#ifdef CONFIG_BATMAN_ADV_MCAST
+
+void batadv_mcast_mla_update(struct batadv_priv *bat_priv);
+
+void batadv_mcast_free(struct batadv_priv *bat_priv);
+
+#else
+
+static inline void batadv_mcast_mla_update(struct batadv_priv *bat_pri=
v)
+{
+	return;
+}
+
+static inline void batadv_mcast_free(struct batadv_priv *bat_priv)
+{
+	return;
+}
+
+#endif /* CONFIG_BATMAN_ADV_MCAST */
+
+#endif /* _NET_BATMAN_ADV_MULTICAST_H_ */
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/transl=
ation-table.c
index 6d0da58..4082d05 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -24,6 +24,7 @@
 #include "originator.h"
 #include "routing.h"
 #include "bridge_loop_avoidance.h"
+#include "multicast.h"
=20
 #include <linux/crc32c.h>
=20
@@ -484,7 +485,7 @@ bool batadv_tt_local_add(struct net_device *soft_if=
ace, const uint8_t *addr,
 {
 	struct batadv_priv *bat_priv =3D netdev_priv(soft_iface);
 	struct batadv_tt_local_entry *tt_local;
-	struct batadv_tt_global_entry *tt_global;
+	struct batadv_tt_global_entry *tt_global =3D NULL;
 	struct net_device *in_dev =3D NULL;
 	struct hlist_head *head;
 	struct batadv_tt_orig_list_entry *orig_entry;
@@ -497,7 +498,9 @@ bool batadv_tt_local_add(struct net_device *soft_if=
ace, const uint8_t *addr,
 		in_dev =3D dev_get_by_index(&init_net, ifindex);
=20
 	tt_local =3D batadv_tt_local_hash_find(bat_priv, addr, vid);
-	tt_global =3D batadv_tt_global_hash_find(bat_priv, addr, vid);
+
+	if (!is_multicast_ether_addr(addr))
+		tt_global =3D batadv_tt_global_hash_find(bat_priv, addr, vid);
=20
 	if (tt_local) {
 		tt_local->last_seen =3D jiffies;
@@ -562,8 +565,11 @@ bool batadv_tt_local_add(struct net_device *soft_i=
face, const uint8_t *addr,
 	tt_local->last_seen =3D jiffies;
 	tt_local->common.added_at =3D tt_local->last_seen;
=20
-	/* the batman interface mac address should never be purged */
-	if (batadv_compare_eth(addr, soft_iface->dev_addr))
+	/* the batman interface mac and multicast addresses should never be
+	 * purged
+	 */
+	if (batadv_compare_eth(addr, soft_iface->dev_addr) ||
+	    is_multicast_ether_addr(addr))
 		tt_local->common.flags |=3D BATADV_TT_CLIENT_NOPURGE;
=20
 	hash_added =3D batadv_hash_add(bat_priv->tt.local_hash, batadv_compar=
e_tt,
@@ -1361,6 +1367,11 @@ add_orig_entry:
 	ret =3D true;
=20
 out_remove:
+	/* Do not remove multicast addresses from the local hash on
+	 * global additions
+	 */
+	if (is_multicast_ether_addr(tt_addr))
+		goto out;
=20
 	/* remove address from local hash if present */
 	local_flags =3D batadv_tt_local_remove(bat_priv, tt_addr, vid,
@@ -3120,6 +3131,9 @@ static void batadv_tt_local_purge_pending_clients=
(struct batadv_priv *bat_priv)
  */
 static void batadv_tt_local_commit_changes_nolock(struct batadv_priv *=
bat_priv)
 {
+	/* Update multicast addresses in local translation table */
+	batadv_mcast_mla_update(bat_priv);
+
 	if (atomic_read(&bat_priv->tt.local_changes) < 1) {
 		if (!batadv_atomic_dec_not_zero(&bat_priv->tt.ogm_append_cnt))
 			batadv_tt_tvlv_container_update(bat_priv);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 9f52517..d553264 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -607,6 +607,16 @@ struct batadv_priv_dat {
 };
 #endif
=20
+#ifdef CONFIG_BATMAN_ADV_MCAST
+/**
+ * struct batadv_priv_mcast - per mesh interface mcast data
+ * @mla_list: list of multicast addresses we are currently announcing =
via TT
+ */
+struct batadv_priv_mcast {
+	struct hlist_head mla_list;
+};
+#endif
+
 /**
  * struct batadv_priv_nc - per mesh interface network coding private d=
ata
  * @work: work queue callback item for cleanup
@@ -702,6 +712,7 @@ struct batadv_softif_vlan {
  * @tt: translation table data
  * @tvlv: type-version-length-value data
  * @dat: distributed arp table data
+ * @mcast: multicast data
  * @network_coding: bool indicating whether network coding is enabled
  * @batadv_priv_nc: network coding data
  */
@@ -759,6 +770,9 @@ struct batadv_priv {
 #ifdef CONFIG_BATMAN_ADV_DAT
 	struct batadv_priv_dat dat;
 #endif
+#ifdef CONFIG_BATMAN_ADV_MCAST
+	struct batadv_priv_mcast mcast;
+#endif
 #ifdef CONFIG_BATMAN_ADV_NC
 	atomic_t network_coding;
 	struct batadv_priv_nc nc;
@@ -1116,6 +1130,16 @@ struct batadv_dat_entry {
 };
=20
 /**
+ * struct batadv_hw_addr - a list entry for a MAC address
+ * @list: list node for the linking of entries
+ * @addr: the MAC address of this list entry
+ */
+struct batadv_hw_addr {
+	struct hlist_node list;
+	unsigned char addr[ETH_ALEN];
+};
+
+/**
  * struct batadv_dat_candidate - candidate destination for DAT operati=
ons
  * @type: the type of the selected candidate. It can one of the follow=
ing:
  *	  - BATADV_DAT_CANDIDATE_NOT_FOUND
--=20
1.8.3.2
