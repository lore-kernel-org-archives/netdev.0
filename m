From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 2/4] batman-adv: B.A.T.M.A.N V - make sure iface is reactivated upon NETDEV_UP event
Date: Sun,  1 May 2016 01:06:01 +0800
Message-ID: <1462035963-28970-3-git-send-email-a@unstable.cc>
References: <1462035963-28970-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <a@unstable.cc>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:30456 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751847AbcD3RGi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Apr 2016 13:06:38 -0400
In-Reply-To: <1462035963-28970-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At the moment there is no explicit reactivation of an hard-interface
upon NETDEV_UP event. In case of B.A.T.M.A.N. IV the interface is
reactivated as soon as the next OGM is scheduled for sending, but this
mechanism does not work with B.A.T.M.A.N. V. The latter does not rely
on the same scheduling mechanism as its predecessor and for this reason
the hard-interface remains deactivated forever after being brought down
once.

This patch fixes the reactivation mechanism by adding a new routing API
which explicitly allows each algorithm to perform any needed operation
upon interface re-activation.

Such API is optional and is implemented by B.A.T.M.A.N. V only and it
just takes care of setting the iface status to ACTIVE

Signed-off-by: Antonio Quartulli <a@unstable.cc>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/bat_v.c          | 12 ++++++++++++
 net/batman-adv/hard-interface.c |  3 +++
 net/batman-adv/types.h          |  3 +++
 3 files changed, 18 insertions(+)

diff --git a/net/batman-adv/bat_v.c b/net/batman-adv/bat_v.c
index 3315b9a598af..4026f198a734 100644
--- a/net/batman-adv/bat_v.c
+++ b/net/batman-adv/bat_v.c
@@ -32,10 +32,21 @@
 
 #include "bat_v_elp.h"
 #include "bat_v_ogm.h"
+#include "hard-interface.h"
 #include "hash.h"
 #include "originator.h"
 #include "packet.h"
 
+static void batadv_v_iface_activate(struct batadv_hard_iface *hard_iface)
+{
+	/* B.A.T.M.A.N. V does not use any queuing mechanism, therefore it can
+	 * set the interface as ACTIVE right away, without any risk of race
+	 * condition
+	 */
+	if (hard_iface->if_status == BATADV_IF_TO_BE_ACTIVATED)
+		hard_iface->if_status = BATADV_IF_ACTIVE;
+}
+
 static int batadv_v_iface_enable(struct batadv_hard_iface *hard_iface)
 {
 	int ret;
@@ -274,6 +285,7 @@ static bool batadv_v_neigh_is_sob(struct batadv_neigh_node *neigh1,
 
 static struct batadv_algo_ops batadv_batman_v __read_mostly = {
 	.name = "BATMAN_V",
+	.bat_iface_activate = batadv_v_iface_activate,
 	.bat_iface_enable = batadv_v_iface_enable,
 	.bat_iface_disable = batadv_v_iface_disable,
 	.bat_iface_update_mac = batadv_v_iface_update_mac,
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index c61d5b0b24d2..0a7deaf2670a 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -407,6 +407,9 @@ batadv_hardif_activate_interface(struct batadv_hard_iface *hard_iface)
 
 	batadv_update_min_mtu(hard_iface->soft_iface);
 
+	if (bat_priv->bat_algo_ops->bat_iface_activate)
+		bat_priv->bat_algo_ops->bat_iface_activate(hard_iface);
+
 out:
 	if (primary_if)
 		batadv_hardif_put(primary_if);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 9abfb3e73c34..443e9b84e07d 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1250,6 +1250,8 @@ struct batadv_forw_packet {
  * struct batadv_algo_ops - mesh algorithm callbacks
  * @list: list node for the batadv_algo_list
  * @name: name of the algorithm
+ * @bat_iface_activate: start routing mechanisms when hard-interface is brought
+ *  up
  * @bat_iface_enable: init routing info when hard-interface is enabled
  * @bat_iface_disable: de-init routing info when hard-interface is disabled
  * @bat_iface_update_mac: (re-)init mac addresses of the protocol information
@@ -1277,6 +1279,7 @@ struct batadv_forw_packet {
 struct batadv_algo_ops {
 	struct hlist_node list;
 	char *name;
+	void (*bat_iface_activate)(struct batadv_hard_iface *hard_iface);
 	int (*bat_iface_enable)(struct batadv_hard_iface *hard_iface);
 	void (*bat_iface_disable)(struct batadv_hard_iface *hard_iface);
 	void (*bat_iface_update_mac)(struct batadv_hard_iface *hard_iface);
-- 
2.8.1
