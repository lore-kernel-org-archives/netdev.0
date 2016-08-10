From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: [PATCH v2 3/3] net: make net namespace sysctls belong to container's owner
Date: Wed, 10 Aug 2016 14:36:02 -0700
Message-ID: <1470864962-25056-4-git-send-email-dmitry.torokhov@gmail.com>
References: <1470864962-25056-1-git-send-email-dmitry.torokhov@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470864962-25056-1-git-send-email-dmitry.torokhov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If net namespace is attached to a user namespace let's make container's
root owner of sysctls affecting said network namespace instead of global
root.

This also allows us to clean up net_ctl_permissions() because we do not
need to fudge permissions anymore for the container's owner since it now
owns the objects in question.

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
---
 fs/proc/proc_sysctl.c  |  5 +++++
 include/linux/sysctl.h |  4 ++++
 net/sysctl_net.c       | 29 ++++++++++++++++++++---------
 3 files changed, 29 insertions(+), 9 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 5e57c3e..28f9085 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -430,6 +430,7 @@ static int sysctl_perm(struct ctl_table_header *head, struct ctl_table *table, i
 static struct inode *proc_sys_make_inode(struct super_block *sb,
 		struct ctl_table_header *head, struct ctl_table *table)
 {
+	struct ctl_table_root *root = head->root;
 	struct inode *inode;
 	struct proc_inode *ei;
 
@@ -457,6 +458,10 @@ static struct inode *proc_sys_make_inode(struct super_block *sb,
 		if (is_empty_dir(head))
 			make_empty_dir_inode(inode);
 	}
+
+	if (root->set_ownership)
+		root->set_ownership(head, table, &inode->i_uid, &inode->i_gid);
+
 out:
 	return inode;
 }
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index fa7bc29..55bec2f 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -25,6 +25,7 @@
 #include <linux/rcupdate.h>
 #include <linux/wait.h>
 #include <linux/rbtree.h>
+#include <linux/uidgid.h>
 #include <uapi/linux/sysctl.h>
 
 /* For the /proc/sys support */
@@ -156,6 +157,9 @@ struct ctl_table_root {
 	struct ctl_table_set default_set;
 	struct ctl_table_set *(*lookup)(struct ctl_table_root *root,
 					   struct nsproxy *namespaces);
+	void (*set_ownership)(struct ctl_table_header *head,
+			      struct ctl_table *table,
+			      kuid_t *uid, kgid_t *gid);
 	int (*permissions)(struct ctl_table_header *head, struct ctl_table *table);
 };
 
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index ed98c1f..5bc1a3d 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -42,26 +42,37 @@ static int net_ctl_permissions(struct ctl_table_header *head,
 			       struct ctl_table *table)
 {
 	struct net *net = container_of(head->set, struct net, sysctls);
-	kuid_t root_uid = make_kuid(net->user_ns, 0);
-	kgid_t root_gid = make_kgid(net->user_ns, 0);
 
 	/* Allow network administrator to have same access as root. */
-	if (ns_capable(net->user_ns, CAP_NET_ADMIN) ||
-	    uid_eq(root_uid, current_euid())) {
+	if (ns_capable(net->user_ns, CAP_NET_ADMIN)) {
 		int mode = (table->mode >> 6) & 7;
 		return (mode << 6) | (mode << 3) | mode;
 	}
-	/* Allow netns root group to have the same access as the root group */
-	if (in_egroup_p(root_gid)) {
-		int mode = (table->mode >> 3) & 7;
-		return (mode << 3) | mode;
-	}
+
 	return table->mode;
 }
 
+static void net_ctl_set_ownership(struct ctl_table_header *head,
+				  struct ctl_table *table,
+				  kuid_t *uid, kgid_t *gid)
+{
+	struct net *net = container_of(head->set, struct net, sysctls);
+	kuid_t ns_root_uid;
+	kgid_t ns_root_gid;
+
+	ns_root_uid = make_kuid(net->user_ns, 0);
+	if (uid_valid(ns_root_uid))
+		*uid = ns_root_uid;
+
+	ns_root_gid = make_kgid(net->user_ns, 0);
+	if (gid_valid(ns_root_gid))
+		*gid = ns_root_gid;
+}
+
 static struct ctl_table_root net_sysctl_root = {
 	.lookup = net_ctl_header_lookup,
 	.permissions = net_ctl_permissions,
+	.set_ownership = net_ctl_set_ownership,
 };
 
 static int __net_init sysctl_net_init(struct net *net)
-- 
2.8.0.rc3.226.g39d4020
