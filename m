From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 09/19] batman-adv: make the GW selection
	class algorithm specific
Date: Fri, 12 Aug 2016 10:56:45 +0200
Message-ID: <1470992215-11009-10-git-send-email-sw@simonwunderlich.de>
References: <1470992215-11009-1-git-send-email-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, Antonio Quartulli <a@unstable.cc>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1470992215-11009-1-git-send-email-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
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

From: Antonio Quartulli <a@unstable.cc>

The B.A.T.M.A.N. V algorithm uses a different metric compared to its
predecessor and for this reason the logic used to compute the best
Gateway is also changed. This means that the GW selection class
fed to this logic has a semantics that depends on the algorithm being
used.

Make the parsing and printing routine of the GW selection class
routing algorithm specific. Each algorithm can now parse (and print)
this value independently.

If no API is provided by any algorithm, the default is to use the
current mechanism of considering such value like an integer between
1 and 255.

Signed-off-by: Antonio Quartulli <a@unstable.cc>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 net/batman-adv/bat_v.c | 34 ++++++++++++++++++++++++++++++++++
 net/batman-adv/sysfs.c | 34 ++++++++++++++++++++++++++++++++--
 net/batman-adv/types.h | 13 +++++++++++++
 3 files changed, 79 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/bat_v.c b/net/batman-adv/bat_v.c
index 0366cbf..90fd5ee 100644
--- a/net/batman-adv/bat_v.c
+++ b/net/batman-adv/bat_v.c
@@ -21,8 +21,10 @@
 #include <linux/atomic.h>
 #include <linux/bug.h>
 #include <linux/cache.h>
+#include <linux/errno.h>
 #include <linux/init.h>
 #include <linux/jiffies.h>
+#include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/rculist.h>
 #include <linux/rcupdate.h>
@@ -34,6 +36,8 @@
 #include "bat_algo.h"
 #include "bat_v_elp.h"
 #include "bat_v_ogm.h"
+#include "gateway_client.h"
+#include "gateway_common.h"
 #include "hard-interface.h"
 #include "hash.h"
 #include "originator.h"
@@ -320,6 +324,32 @@ err_ifinfo1:
 	return ret;
 }
 
+static ssize_t batadv_v_store_sel_class(struct batadv_priv *bat_priv,
+					char *buff, size_t count)
+{
+	u32 old_class, class;
+
+	if (!batadv_parse_throughput(bat_priv->soft_iface, buff,
+				     "B.A.T.M.A.N. V GW selection class",
+				     &class))
+		return -EINVAL;
+
+	old_class = atomic_read(&bat_priv->gw.sel_class);
+	atomic_set(&bat_priv->gw.sel_class, class);
+
+	if (old_class != class)
+		batadv_gw_reselect(bat_priv);
+
+	return count;
+}
+
+static ssize_t batadv_v_show_sel_class(struct batadv_priv *bat_priv, char *buff)
+{
+	u32 class = atomic_read(&bat_priv->gw.sel_class);
+
+	return sprintf(buff, "%u.%u MBit\n", class / 10, class % 10);
+}
+
 static struct batadv_algo_ops batadv_batman_v __read_mostly = {
 	.name = "BATMAN_V",
 	.iface = {
@@ -338,6 +368,10 @@ static struct batadv_algo_ops batadv_batman_v __read_mostly = {
 	.orig = {
 		.print = batadv_v_orig_print,
 	},
+	.gw = {
+		.store_sel_class = batadv_v_store_sel_class,
+		.show_sel_class = batadv_v_show_sel_class,
+	},
 };
 
 /**
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 4e06cb7..e78bd7f 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -515,6 +515,36 @@ static ssize_t batadv_store_gw_mode(struct kobject *kobj,
 	return count;
 }
 
+static ssize_t batadv_show_gw_sel_class(struct kobject *kobj,
+					struct attribute *attr, char *buff)
+{
+	struct batadv_priv *bat_priv = batadv_kobj_to_batpriv(kobj);
+
+	if (bat_priv->algo_ops->gw.show_sel_class)
+		return bat_priv->algo_ops->gw.show_sel_class(bat_priv, buff);
+
+	return sprintf(buff, "%i\n", atomic_read(&bat_priv->gw.sel_class));
+}
+
+static ssize_t batadv_store_gw_sel_class(struct kobject *kobj,
+					 struct attribute *attr, char *buff,
+					 size_t count)
+{
+	struct batadv_priv *bat_priv = batadv_kobj_to_batpriv(kobj);
+
+	if (buff[count - 1] == '\n')
+		buff[count - 1] = '\0';
+
+	if (bat_priv->algo_ops->gw.store_sel_class)
+		return bat_priv->algo_ops->gw.store_sel_class(bat_priv, buff,
+							      count);
+
+	return __batadv_store_uint_attr(buff, count, 1, BATADV_TQ_MAX_VALUE,
+					batadv_post_gw_reselect, attr,
+					&bat_priv->gw.sel_class,
+					bat_priv->soft_iface);
+}
+
 static ssize_t batadv_show_gw_bwidth(struct kobject *kobj,
 				     struct attribute *attr, char *buff)
 {
@@ -626,8 +656,8 @@ BATADV_ATTR_SIF_UINT(orig_interval, orig_interval, S_IRUGO | S_IWUSR,
 		     2 * BATADV_JITTER, INT_MAX, NULL);
 BATADV_ATTR_SIF_UINT(hop_penalty, hop_penalty, S_IRUGO | S_IWUSR, 0,
 		     BATADV_TQ_MAX_VALUE, NULL);
-BATADV_ATTR_SIF_UINT(gw_sel_class, gw.sel_class, S_IRUGO | S_IWUSR, 1,
-		     BATADV_TQ_MAX_VALUE, batadv_post_gw_reselect);
+static BATADV_ATTR(gw_sel_class, S_IRUGO | S_IWUSR, batadv_show_gw_sel_class,
+		   batadv_store_gw_sel_class);
 static BATADV_ATTR(gw_bandwidth, S_IRUGO | S_IWUSR, batadv_show_gw_bwidth,
 		   batadv_store_gw_bwidth);
 #ifdef CONFIG_BATMAN_ADV_MCAST
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 96af6da..deaadba 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1450,12 +1450,24 @@ struct batadv_algo_orig_ops {
 };
 
 /**
+ * struct batadv_algo_gw_ops - mesh algorithm callbacks (GW specific)
+ * @store_sel_class: parse and stores a new GW selection class (optional)
+ * @show_sel_class: prints the current GW selection class (optional)
+ */
+struct batadv_algo_gw_ops {
+	ssize_t (*store_sel_class)(struct batadv_priv *bat_priv, char *buff,
+				   size_t count);
+	ssize_t (*show_sel_class)(struct batadv_priv *bat_priv, char *buff);
+};
+
+/**
  * struct batadv_algo_ops - mesh algorithm callbacks
  * @list: list node for the batadv_algo_list
  * @name: name of the algorithm
  * @iface: callbacks related to interface handling
  * @neigh: callbacks related to neighbors handling
  * @orig: callbacks related to originators handling
+ * @gw: callbacks related to GW mode
  */
 struct batadv_algo_ops {
 	struct hlist_node list;
@@ -1463,6 +1475,7 @@ struct batadv_algo_ops {
 	struct batadv_algo_iface_ops iface;
 	struct batadv_algo_neigh_ops neigh;
 	struct batadv_algo_orig_ops orig;
+	struct batadv_algo_gw_ops gw;
 };
 
 /**
-- 
2.8.1
