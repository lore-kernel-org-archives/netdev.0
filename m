From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 4/9] batman-adv: network coding - add the initial infrastructure code
Date: Wed, 13 Mar 2013 23:56:34 +0100
Message-ID: <1363215399-18875-5-git-send-email-ordex@autistici.org>
References: <1363215399-18875-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@hundeboll.net>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:20050 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934356Ab3CMW6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 18:58:01 -0400
In-Reply-To: <1363215399-18875-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Martin Hundeb=C3=B8ll <martin@hundeboll.net>

Network coding exploits the 802.11 shared medium to allow multiple
packets to be sent in a single transmission. In brief, a relay can XOR
two packets, and send the coded packet to two destinations. The
receivers can decode one of the original packets by XOR'ing the coded
packet with the other original packet. This will lead to increased
throughput in topologies where two packets cross one relay.

In a simple topology with three nodes, it takes four transmissions
without network coding to get one packet from Node A to Node B and one
from Node B to Node A:

 1.  Node A  ---- p1 --->  Node R                Node B
 2.  Node A                Node R  <--- p2 ----  Node B
 3.  Node A  <--- p2 ----  Node R                Node B
 4.  Node A                Node R  ---- p1 --->  Node B

With network coding, the relay only needs one transmission, which saves
us one slot of valuable airtime:

 1.  Node A  ---- p1 --->  Node R                Node B
 2.  Node A                Node R  <--- p2 ----  Node B
 3.  Node A  <- p1 x p2 -  Node R  - p1 x p2 ->  Node B

The same principle holds for a topology including five nodes. Here the
packets from Node A and Node B are overheard by Node C and Node D,
respectively. This allows Node R to send a network coded packet to save
one transmission:

   Node A                  Node B

    |     \              /    |
    |      p1          p2     |
    |       \          /      |
    p1       > Node R <       p2
    |                         |
    |         /      \        |
    |    p1 x p2    p1 x p2   |
    v       /          \      v
           /            \
   Node C <              > Node D

More information is available on the open-mesh.org wiki[1].

This patch adds the initial code to support network coding in
batman-adv. It sets up a worker thread to do house keeping and adds a
sysfs file to enable/disable network coding. The feature is disabled by
default, as it requires a wifi-driver with working promiscuous mode, an=
d
also because it adds a small delay at each hop.

[1] http://www.open-mesh.org/projects/batman-adv/wiki/Catwoman

Signed-off-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 Documentation/ABI/testing/sysfs-class-net-mesh |  8 +++
 net/batman-adv/Kconfig                         | 14 +++++
 net/batman-adv/Makefile                        |  1 +
 net/batman-adv/main.c                          |  6 ++
 net/batman-adv/main.h                          |  4 +-
 net/batman-adv/network-coding.c                | 81 ++++++++++++++++++=
++++++++
 net/batman-adv/network-coding.h                | 48 +++++++++++++++
 net/batman-adv/soft-interface.c                |  3 +
 net/batman-adv/sysfs.c                         |  6 ++
 net/batman-adv/types.h                         | 14 +++++
 10 files changed, 184 insertions(+), 1 deletion(-)
 create mode 100644 net/batman-adv/network-coding.c
 create mode 100644 net/batman-adv/network-coding.h

diff --git a/Documentation/ABI/testing/sysfs-class-net-mesh b/Documenta=
tion/ABI/testing/sysfs-class-net-mesh
index bc41da6..bdcd8b4 100644
--- a/Documentation/ABI/testing/sysfs-class-net-mesh
+++ b/Documentation/ABI/testing/sysfs-class-net-mesh
@@ -67,6 +67,14 @@ Description:
                 Defines the penalty which will be applied to an
                 originator message's tq-field on every hop.
=20
+What:           /sys/class/net/<mesh_iface>/mesh/network_coding
+Date:           Nov 2012
+Contact:        Martin Hundeboll <martin@hundeboll.net>
+Description:
+                Controls whether Network Coding (using some magic
+                to send fewer wifi packets but still the same
+                content) is enabled or not.
+
 What:           /sys/class/net/<mesh_iface>/mesh/orig_interval
 Date:           May 2010
 Contact:        Marek Lindner <lindner_marek@yahoo.de>
diff --git a/net/batman-adv/Kconfig b/net/batman-adv/Kconfig
index 8d8afb1..fa780b7 100644
--- a/net/batman-adv/Kconfig
+++ b/net/batman-adv/Kconfig
@@ -36,6 +36,20 @@ config BATMAN_ADV_DAT
 	  mesh networks. If you think that your network does not need
 	  this option you can safely remove it and save some space.
=20
+config BATMAN_ADV_NC
+	bool "Network Coding"
+	depends on BATMAN_ADV
+	default n
+	help
+	  This option enables network coding, a mechanism that aims to
+	  increase the overall network throughput by fusing multiple
+	  packets in one transmission.
+	  Note that interfaces controlled by batman-adv must be manually
+	  configured to have promiscuous mode enabled in order to make
+	  network coding work.
+	  If you think that your network does not need this feature you
+	  can safely disable it and save some space.
+
 config BATMAN_ADV_DEBUG
 	bool "B.A.T.M.A.N. debugging"
 	depends on BATMAN_ADV
diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index e45e3b4..4b8f192 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -30,6 +30,7 @@ batman-adv-y +=3D hard-interface.o
 batman-adv-y +=3D hash.o
 batman-adv-y +=3D icmp_socket.o
 batman-adv-y +=3D main.o
+batman-adv-$(CONFIG_BATMAN_ADV_NC) +=3D network-coding.o
 batman-adv-y +=3D originator.o
 batman-adv-y +=3D ring_buffer.o
 batman-adv-y +=3D routing.o
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 0488d70..0495a7d 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -35,6 +35,7 @@
 #include "vis.h"
 #include "hash.h"
 #include "bat_algo.h"
+#include "network-coding.h"
=20
=20
 /* List manipulations on hardif_list have to be rtnl_lock()'ed,
@@ -135,6 +136,10 @@ int batadv_mesh_init(struct net_device *soft_iface=
)
 	if (ret < 0)
 		goto err;
=20
+	ret =3D batadv_nc_init(bat_priv);
+	if (ret < 0)
+		goto err;
+
 	atomic_set(&bat_priv->gw.reselect, 0);
 	atomic_set(&bat_priv->mesh_state, BATADV_MESH_ACTIVE);
=20
@@ -157,6 +162,7 @@ void batadv_mesh_free(struct net_device *soft_iface=
)
=20
 	batadv_gw_node_purge(bat_priv);
 	batadv_originator_free(bat_priv);
+	batadv_nc_free(bat_priv);
=20
 	batadv_tt_free(bat_priv);
=20
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index ced08b9..59ba2ff 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -185,6 +185,7 @@ __be32 batadv_skb_crc32(struct sk_buff *skb, u8 *pa=
yload_ptr);
  * @BATADV_DBG_TT: translation table messages
  * @BATADV_DBG_BLA: bridge loop avoidance messages
  * @BATADV_DBG_DAT: ARP snooping and DAT related messages
+ * @BATADV_DBG_NC: network coding related messages
  * @BATADV_DBG_ALL: the union of all the above log levels
  */
 enum batadv_dbg_level {
@@ -193,7 +194,8 @@ enum batadv_dbg_level {
 	BATADV_DBG_TT	  =3D BIT(2),
 	BATADV_DBG_BLA    =3D BIT(3),
 	BATADV_DBG_DAT    =3D BIT(4),
-	BATADV_DBG_ALL    =3D 31,
+	BATADV_DBG_NC	  =3D BIT(5),
+	BATADV_DBG_ALL    =3D 63,
 };
=20
 #ifdef CONFIG_BATMAN_ADV_DEBUG
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-c=
oding.c
new file mode 100644
index 0000000..9c2d54b
--- /dev/null
+++ b/net/batman-adv/network-coding.c
@@ -0,0 +1,81 @@
+/* Copyright (C) 2012-2013 B.A.T.M.A.N. contributors:
+ *
+ * Martin Hundeb=C3=B8ll, Jeppe Ledet-Pedersen
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
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#include "main.h"
+#include "network-coding.h"
+
+static void batadv_nc_worker(struct work_struct *work);
+
+/**
+ * batadv_nc_start_timer - initialise the nc periodic worker
+ * @bat_priv: the bat priv with all the soft interface information
+ */
+static void batadv_nc_start_timer(struct batadv_priv *bat_priv)
+{
+	queue_delayed_work(batadv_event_workqueue, &bat_priv->nc.work,
+			   msecs_to_jiffies(10));
+}
+
+/**
+ * batadv_nc_init - initialise coding hash table and start house keepi=
ng
+ * @bat_priv: the bat priv with all the soft interface information
+ */
+int batadv_nc_init(struct batadv_priv *bat_priv)
+{
+	INIT_DELAYED_WORK(&bat_priv->nc.work, batadv_nc_worker);
+	batadv_nc_start_timer(bat_priv);
+
+	return 0;
+}
+
+/**
+ * batadv_nc_init_bat_priv - initialise the nc specific bat_priv varia=
bles
+ * @bat_priv: the bat priv with all the soft interface information
+ */
+void batadv_nc_init_bat_priv(struct batadv_priv *bat_priv)
+{
+	atomic_set(&bat_priv->network_coding, 1);
+}
+
+/**
+ * batadv_nc_worker - periodic task for house keeping related to netwo=
rk coding
+ * @work: kernel work struct
+ */
+static void batadv_nc_worker(struct work_struct *work)
+{
+	struct delayed_work *delayed_work;
+	struct batadv_priv_nc *priv_nc;
+	struct batadv_priv *bat_priv;
+
+	delayed_work =3D container_of(work, struct delayed_work, work);
+	priv_nc =3D container_of(delayed_work, struct batadv_priv_nc, work);
+	bat_priv =3D container_of(priv_nc, struct batadv_priv, nc);
+
+	/* Schedule a new check */
+	batadv_nc_start_timer(bat_priv);
+}
+
+/**
+ * batadv_nc_free - clean up network coding memory
+ * @bat_priv: the bat priv with all the soft interface information
+ */
+void batadv_nc_free(struct batadv_priv *bat_priv)
+{
+	cancel_delayed_work_sync(&bat_priv->nc.work);
+}
diff --git a/net/batman-adv/network-coding.h b/net/batman-adv/network-c=
oding.h
new file mode 100644
index 0000000..7483cba
--- /dev/null
+++ b/net/batman-adv/network-coding.h
@@ -0,0 +1,48 @@
+/* Copyright (C) 2012-2013 B.A.T.M.A.N. contributors:
+ *
+ * Martin Hundeb=C3=B8ll, Jeppe Ledet-Pedersen
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
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#ifndef _NET_BATMAN_ADV_NETWORK_CODING_H_
+#define _NET_BATMAN_ADV_NETWORK_CODING_H_
+
+#ifdef CONFIG_BATMAN_ADV_NC
+
+int batadv_nc_init(struct batadv_priv *bat_priv);
+void batadv_nc_free(struct batadv_priv *bat_priv);
+void batadv_nc_init_bat_priv(struct batadv_priv *bat_priv);
+
+#else /* ifdef CONFIG_BATMAN_ADV_NC */
+
+static inline int batadv_nc_init(struct batadv_priv *bat_priv)
+{
+	return 0;
+}
+
+static inline void batadv_nc_free(struct batadv_priv *bat_priv)
+{
+	return;
+}
+
+static inline void batadv_nc_init_bat_priv(struct batadv_priv *bat_pri=
v)
+{
+	return;
+}
+
+#endif /* ifdef CONFIG_BATMAN_ADV_NC */
+
+#endif /* _NET_BATMAN_ADV_NETWORK_CODING_H_ */
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 2711e87..7188e07 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -37,6 +37,7 @@
 #include <linux/if_ether.h>
 #include "unicast.h"
 #include "bridge_loop_avoidance.h"
+#include "network-coding.h"
=20
=20
 static int batadv_get_settings(struct net_device *dev, struct ethtool_=
cmd *cmd);
@@ -544,6 +545,8 @@ struct net_device *batadv_softif_create(const char =
*name)
 	if (ret < 0)
 		goto unreg_soft_iface;
=20
+	batadv_nc_init_bat_priv(bat_priv);
+
 	ret =3D batadv_sysfs_add_meshif(soft_iface);
 	if (ret < 0)
 		goto unreg_soft_iface;
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 6a44fed..ce39f62 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -442,6 +442,9 @@ static BATADV_ATTR(gw_bandwidth, S_IRUGO | S_IWUSR,=
 batadv_show_gw_bwidth,
 #ifdef CONFIG_BATMAN_ADV_DEBUG
 BATADV_ATTR_SIF_UINT(log_level, S_IRUGO | S_IWUSR, 0, BATADV_DBG_ALL, =
NULL);
 #endif
+#ifdef CONFIG_BATMAN_ADV_NC
+BATADV_ATTR_SIF_BOOL(network_coding, S_IRUGO | S_IWUSR, NULL);
+#endif
=20
 static struct batadv_attribute *batadv_mesh_attrs[] =3D {
 	&batadv_attr_aggregated_ogms,
@@ -464,6 +467,9 @@ static struct batadv_attribute *batadv_mesh_attrs[]=
 =3D {
 #ifdef CONFIG_BATMAN_ADV_DEBUG
 	&batadv_attr_log_level,
 #endif
+#ifdef CONFIG_BATMAN_ADV_NC
+	&batadv_attr_network_coding,
+#endif
 	NULL,
 };
=20
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 4cd87a0..83bfe7c 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -428,6 +428,14 @@ struct batadv_priv_dat {
 #endif
=20
 /**
+ * struct batadv_priv_nc - per mesh interface network coding private d=
ata
+ * @work: work queue callback item for cleanup
+ */
+struct batadv_priv_nc {
+	struct delayed_work work;
+};
+
+/**
  * struct batadv_priv - per mesh interface data
  * @mesh_state: current status of the mesh (inactive/active/deactivati=
ng)
  * @soft_iface: net device which holds this struct as private data
@@ -470,6 +478,8 @@ struct batadv_priv_dat {
  * @tt: translation table data
  * @vis: vis data
  * @dat: distributed arp table data
+ * @network_coding: bool indicating whether network coding is enabled
+ * @batadv_priv_nc: network coding data
  */
 struct batadv_priv {
 	atomic_t mesh_state;
@@ -522,6 +532,10 @@ struct batadv_priv {
 #ifdef CONFIG_BATMAN_ADV_DAT
 	struct batadv_priv_dat dat;
 #endif
+#ifdef CONFIG_BATMAN_ADV_NC
+	atomic_t network_coding;
+	struct batadv_priv_nc nc;
+#endif /* CONFIG_BATMAN_ADV_NC */
 };
=20
 /**
--=20
1.8.1.5
