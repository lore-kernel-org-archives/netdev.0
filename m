From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 11/17] batman-adv: init ELP tweaking options
	only once
Date: Fri,  1 Jul 2016 15:09:03 +0200
Message-ID: <1467378549-9646-12-git-send-email-sw@simonwunderlich.de>
References: <1467378549-9646-1-git-send-email-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, Antonio Quartulli <a@unstable.cc>
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

From: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>

The ELP interval and throughput override interface settings are initialized
with default settings on every time an interface is added to a mesh.
This patch prevents this behavior by moving the configuration init to the
interface detection routine which runs only once per interface.

Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
[a@unstable.cc: move initialization to batadv_v_hardif_init]
Signed-off-by: Antonio Quartulli <a@unstable.cc>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 net/batman-adv/bat_algo.h       |  7 ++++++-
 net/batman-adv/bat_v.c          | 19 ++++++++++++++-----
 net/batman-adv/bat_v_elp.c      |  1 -
 net/batman-adv/hard-interface.c |  3 +++
 4 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/bat_algo.h b/net/batman-adv/bat_algo.h
index 03dafd3..3654296 100644
--- a/net/batman-adv/bat_algo.h
+++ b/net/batman-adv/bat_algo.h
@@ -18,13 +18,14 @@
 #ifndef _NET_BATMAN_ADV_BAT_ALGO_H_
 #define _NET_BATMAN_ADV_BAT_ALGO_H_
 
-struct batadv_priv;
+#include "main.h"
 
 int batadv_iv_init(void);
 
 #ifdef CONFIG_BATMAN_ADV_BATMAN_V
 
 int batadv_v_init(void);
+void batadv_v_hardif_init(struct batadv_hard_iface *hardif);
 int batadv_v_mesh_init(struct batadv_priv *bat_priv);
 void batadv_v_mesh_free(struct batadv_priv *bat_priv);
 
@@ -35,6 +36,10 @@ static inline int batadv_v_init(void)
 	return 0;
 }
 
+static inline void batadv_v_hardif_init(struct batadv_hard_iface *hardif)
+{
+}
+
 static inline int batadv_v_mesh_init(struct batadv_priv *bat_priv)
 {
 	return 0;
diff --git a/net/batman-adv/bat_v.c b/net/batman-adv/bat_v.c
index c16cd44..c2fea81 100644
--- a/net/batman-adv/bat_v.c
+++ b/net/batman-adv/bat_v.c
@@ -70,11 +70,6 @@ static int batadv_v_iface_enable(struct batadv_hard_iface *hard_iface)
 	if (ret < 0)
 		batadv_v_elp_iface_disable(hard_iface);
 
-	/* enable link throughput auto-detection by setting the throughput
-	 * override to zero
-	 */
-	atomic_set(&hard_iface->bat_v.throughput_override, 0);
-
 	return ret;
 }
 
@@ -339,6 +334,20 @@ static struct batadv_algo_ops batadv_batman_v __read_mostly = {
 };
 
 /**
+ * batadv_v_hardif_init - initialize the algorithm specific fields in the
+ *  hard-interface object
+ * @hard_iface: the hard-interface to initialize
+ */
+void batadv_v_hardif_init(struct batadv_hard_iface *hard_iface)
+{
+	/* enable link throughput auto-detection by setting the throughput
+	 * override to zero
+	 */
+	atomic_set(&hard_iface->bat_v.throughput_override, 0);
+	atomic_set(&hard_iface->bat_v.elp_interval, 500);
+}
+
+/**
  * batadv_v_mesh_init - initialize the B.A.T.M.A.N. V private resources for a
  *  mesh
  * @bat_priv: the object representing the mesh interface to initialise
diff --git a/net/batman-adv/bat_v_elp.c b/net/batman-adv/bat_v_elp.c
index 8909d1e..cf0262b 100644
--- a/net/batman-adv/bat_v_elp.c
+++ b/net/batman-adv/bat_v_elp.c
@@ -344,7 +344,6 @@ int batadv_v_elp_iface_enable(struct batadv_hard_iface *hard_iface)
 	/* randomize initial seqno to avoid collision */
 	get_random_bytes(&random_seqno, sizeof(random_seqno));
 	atomic_set(&hard_iface->bat_v.elp_seqno, random_seqno);
-	atomic_set(&hard_iface->bat_v.elp_interval, 500);
 
 	/* assume full-duplex by default */
 	hard_iface->bat_v.flags |= BATADV_FULL_DUPLEX;
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index db2009d..3696929 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -37,6 +37,7 @@
 #include <linux/spinlock.h>
 #include <linux/workqueue.h>
 
+#include "bat_algo.h"
 #include "bridge_loop_avoidance.h"
 #include "debugfs.h"
 #include "distributed-arp-table.h"
@@ -683,6 +684,8 @@ batadv_hardif_add_interface(struct net_device *net_dev)
 	if (batadv_is_wifi_netdev(net_dev))
 		hard_iface->num_bcasts = BATADV_NUM_BCASTS_WIRELESS;
 
+	batadv_v_hardif_init(hard_iface);
+
 	/* extra reference for return */
 	kref_init(&hard_iface->refcount);
 	kref_get(&hard_iface->refcount);
-- 
2.8.1
