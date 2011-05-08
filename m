From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 3/8] batman-adv: Remove unnecessary
	hardif_list_lock
Date: Sun,  8 May 2011 17:24:39 +0200
Message-ID: <1304868284-9364-4-git-send-email-sven@narfation.org>
References: <1304868284-9364-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1304868284-9364-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

hardif_list_lock is unneccessary because we already ensure that no
multiple admin operations can take place through rtnl_lock.
hardif_list_lock only adds additional overhead and complexity.

Critical functions now check whether they are called with rtnl_lock
using ASSERT_RTNL.

It indirectly fixes the problem that orig_hash_del_if() expects that
only one interface is deleted from hardif_list at a time, but
hardif_remove_interfaces() removes all at once and then calls
orig_hash_del_if().

Reported-by: Linus L=C3=BCssing <linus.luessing-S0/GAf8tV78@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/bat_sysfs.c      |    2 ++
 net/batman-adv/hard-interface.c |   30 +++++++-----------------------
 net/batman-adv/main.c           |    3 +++
 net/batman-adv/soft-interface.c |    2 +-
 4 files changed, 13 insertions(+), 24 deletions(-)

diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index e449bf6..85ba20d 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -502,7 +502,9 @@ static ssize_t store_mesh_iface(struct kobject *kobj,=
 struct attribute *attr,
 		rtnl_unlock();
 	}
=20
+	rtnl_lock();
 	ret =3D hardif_enable_interface(hard_iface, buff);
+	rtnl_unlock();
=20
 out:
 	hardif_free_ref(hard_iface);
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interf=
ace.c
index 3e888f1..7e2f772 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -31,9 +31,6 @@
=20
 #include <linux/if_arp.h>
=20
-/* protect update critical side of hardif_list - but not the content */
-static DEFINE_SPINLOCK(hardif_list_lock);
-
=20
 static int batman_skb_recv(struct sk_buff *skb,
 			   struct net_device *dev,
@@ -136,7 +133,7 @@ static void primary_if_select(struct bat_priv *bat_pr=
iv,
 	struct hard_iface *curr_hard_iface;
 	struct batman_packet *batman_packet;
=20
-	spin_lock_bh(&hardif_list_lock);
+	ASSERT_RTNL();
=20
 	if (new_hard_iface && !atomic_inc_not_zero(&new_hard_iface->refcount))
 		new_hard_iface =3D NULL;
@@ -148,7 +145,7 @@ static void primary_if_select(struct bat_priv *bat_pr=
iv,
 		hardif_free_ref(curr_hard_iface);
=20
 	if (!new_hard_iface)
-		goto out;
+		return;
=20
 	batman_packet =3D (struct batman_packet *)(new_hard_iface->packet_buff)=
;
 	batman_packet->flags =3D PRIMARIES_FIRST_HOP;
@@ -161,9 +158,6 @@ static void primary_if_select(struct bat_priv *bat_pr=
iv,
 	 * our new primary interface
 	 */
 	atomic_set(&bat_priv->hna_local_changed, 1);
-
-out:
-	spin_unlock_bh(&hardif_list_lock);
 }
=20
 static bool hardif_is_iface_up(struct hard_iface *hard_iface)
@@ -456,6 +450,8 @@ static struct hard_iface *hardif_add_interface(struct=
 net_device *net_dev)
 	struct hard_iface *hard_iface;
 	int ret;
=20
+	ASSERT_RTNL();
+
 	ret =3D is_valid_iface(net_dev);
 	if (ret !=3D 1)
 		goto out;
@@ -482,10 +478,7 @@ static struct hard_iface *hardif_add_interface(struc=
t net_device *net_dev)
 	atomic_set(&hard_iface->refcount, 2);
=20
 	check_known_mac_addr(hard_iface->net_dev);
-
-	spin_lock(&hardif_list_lock);
 	list_add_tail_rcu(&hard_iface->list, &hardif_list);
-	spin_unlock(&hardif_list_lock);
=20
 	return hard_iface;
=20
@@ -499,6 +492,8 @@ out:
=20
 static void hardif_remove_interface(struct hard_iface *hard_iface)
 {
+	ASSERT_RTNL();
+
 	/* first deactivate interface */
 	if (hard_iface->if_status !=3D IF_NOT_IN_USE)
 		hardif_disable_interface(hard_iface);
@@ -514,20 +509,11 @@ static void hardif_remove_interface(struct hard_ifa=
ce *hard_iface)
 void hardif_remove_interfaces(void)
 {
 	struct hard_iface *hard_iface, *hard_iface_tmp;
-	struct list_head if_queue;
=20
-	INIT_LIST_HEAD(&if_queue);
-
-	spin_lock(&hardif_list_lock);
+	rtnl_lock();
 	list_for_each_entry_safe(hard_iface, hard_iface_tmp,
 				 &hardif_list, list) {
 		list_del_rcu(&hard_iface->list);
-		list_add_tail(&hard_iface->list, &if_queue);
-	}
-	spin_unlock(&hardif_list_lock);
-
-	rtnl_lock();
-	list_for_each_entry_safe(hard_iface, hard_iface_tmp, &if_queue, list) {
 		hardif_remove_interface(hard_iface);
 	}
 	rtnl_unlock();
@@ -556,9 +542,7 @@ static int hard_if_event(struct notifier_block *this,
 		hardif_deactivate_interface(hard_iface);
 		break;
 	case NETDEV_UNREGISTER:
-		spin_lock(&hardif_list_lock);
 		list_del_rcu(&hard_iface->list);
-		spin_unlock(&hardif_list_lock);
=20
 		hardif_remove_interface(hard_iface);
 		break;
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 705e8be..7edf8d7 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -33,6 +33,9 @@
 #include "vis.h"
 #include "hash.h"
=20
+
+/* List manipulations on hardif_list have to be rtnl_lock()'ed,
+ * list traversals just rcu-locked */
 struct list_head hardif_list;
=20
 unsigned char broadcast_addr[] =3D {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interf=
ace.c
index 8cb13a0..9301e21 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -819,7 +819,7 @@ struct net_device *softif_create(char *name)
 		goto out;
 	}
=20
-	ret =3D register_netdev(soft_iface);
+	ret =3D register_netdevice(soft_iface);
 	if (ret < 0) {
 		pr_err("Unable to register the batman interface '%s': %i\n",
 		       name, ret);
--=20
1.7.5.1
