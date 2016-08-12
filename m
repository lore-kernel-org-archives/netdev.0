From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 07/19] batman-adv: Avoid sysfs name collision
	for netns moves
Date: Fri, 12 Aug 2016 10:56:43 +0200
Message-ID: <1470992215-11009-8-git-send-email-sw@simonwunderlich.de>
References: <1470992215-11009-1-git-send-email-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
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

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>

The kobject_put is only removing the sysfs entry and corresponding entries
when its reference counter becomes zero. This tends to lead to collisions
when a device is moved between two different network namespaces because
some of the sysfs files have to be removed first and then added again to
the already moved sysfs entry.

    WARNING: CPU: 0 PID: 290 at lib/kobject.c:240 kobject_add_internal+0x5ec/0x8a0
    kobject_add_internal failed for batman_adv with -EEXIST, don't try to register things with the same name in the same directory.

But the caller of kobject_put can already remove the sysfs entry before it
does the kobject_put. This removal is done even when the reference counter
is not yet zero and thus avoids the problem.

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 net/batman-adv/sysfs.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 8528959..4e06cb7 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -713,6 +713,8 @@ rem_attr:
 	for (bat_attr = batadv_mesh_attrs; *bat_attr; ++bat_attr)
 		sysfs_remove_file(bat_priv->mesh_obj, &((*bat_attr)->attr));
 
+	kobject_uevent(bat_priv->mesh_obj, KOBJ_REMOVE);
+	kobject_del(bat_priv->mesh_obj);
 	kobject_put(bat_priv->mesh_obj);
 	bat_priv->mesh_obj = NULL;
 out:
@@ -727,6 +729,8 @@ void batadv_sysfs_del_meshif(struct net_device *dev)
 	for (bat_attr = batadv_mesh_attrs; *bat_attr; ++bat_attr)
 		sysfs_remove_file(bat_priv->mesh_obj, &((*bat_attr)->attr));
 
+	kobject_uevent(bat_priv->mesh_obj, KOBJ_REMOVE);
+	kobject_del(bat_priv->mesh_obj);
 	kobject_put(bat_priv->mesh_obj);
 	bat_priv->mesh_obj = NULL;
 }
@@ -782,6 +786,10 @@ rem_attr:
 	for (bat_attr = batadv_vlan_attrs; *bat_attr; ++bat_attr)
 		sysfs_remove_file(vlan->kobj, &((*bat_attr)->attr));
 
+	if (vlan->kobj != bat_priv->mesh_obj) {
+		kobject_uevent(vlan->kobj, KOBJ_REMOVE);
+		kobject_del(vlan->kobj);
+	}
 	kobject_put(vlan->kobj);
 	vlan->kobj = NULL;
 out:
@@ -801,6 +809,10 @@ void batadv_sysfs_del_vlan(struct batadv_priv *bat_priv,
 	for (bat_attr = batadv_vlan_attrs; *bat_attr; ++bat_attr)
 		sysfs_remove_file(vlan->kobj, &((*bat_attr)->attr));
 
+	if (vlan->kobj != bat_priv->mesh_obj) {
+		kobject_uevent(vlan->kobj, KOBJ_REMOVE);
+		kobject_del(vlan->kobj);
+	}
 	kobject_put(vlan->kobj);
 	vlan->kobj = NULL;
 }
@@ -1103,6 +1115,8 @@ out:
 
 void batadv_sysfs_del_hardif(struct kobject **hardif_obj)
 {
+	kobject_uevent(*hardif_obj, KOBJ_REMOVE);
+	kobject_del(*hardif_obj);
 	kobject_put(*hardif_obj);
 	*hardif_obj = NULL;
 }
-- 
2.8.1
