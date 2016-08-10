From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: [PATCH v2 2/3] proc: make proc entries inherit ownership from parent
Date: Wed, 10 Aug 2016 14:36:01 -0700
Message-ID: <1470864962-25056-3-git-send-email-dmitry.torokhov@gmail.com>
References: <1470864962-25056-1-git-send-email-dmitry.torokhov@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470864962-25056-1-git-send-email-dmitry.torokhov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are certain parameters that belong to net namespace and that are
exported in /proc. They should be controllable by the container's owner,
but are currently owned by global root and thus not available.

Let's change proc code to inherit ownership of parent entry, and when
create per-ns "net" proc entry set it up as owned by container's owner.

Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
---
 fs/proc/generic.c  |  2 ++
 fs/proc/proc_net.c | 13 +++++++++++++
 2 files changed, 15 insertions(+)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index c633476..bca66d8 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -390,6 +390,8 @@ static struct proc_dir_entry *__proc_create(struct proc_dir_entry **parent,
 	atomic_set(&ent->count, 1);
 	spin_lock_init(&ent->pde_unload_lock);
 	INIT_LIST_HEAD(&ent->pde_openers);
+	proc_set_user(ent, (*parent)->uid, (*parent)->gid);
+
 out:
 	return ent;
 }
diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index c8bbc68..7ae6b1d 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -21,6 +21,7 @@
 #include <linux/bitops.h>
 #include <linux/mount.h>
 #include <linux/nsproxy.h>
+#include <linux/uidgid.h>
 #include <net/net_namespace.h>
 #include <linux/seq_file.h>
 
@@ -185,6 +186,8 @@ const struct file_operations proc_net_operations = {
 static __net_init int proc_net_ns_init(struct net *net)
 {
 	struct proc_dir_entry *netd, *net_statd;
+	kuid_t uid;
+	kgid_t gid;
 	int err;
 
 	err = -ENOMEM;
@@ -199,6 +202,16 @@ static __net_init int proc_net_ns_init(struct net *net)
 	netd->parent = &proc_root;
 	memcpy(netd->name, "net", 4);
 
+	uid = make_kuid(net->user_ns, 0);
+	if (!uid_valid(uid))
+		uid = netd->uid;
+
+	gid = make_kgid(net->user_ns, 0);
+	if (!gid_valid(gid))
+		gid = netd->gid;
+
+	proc_set_user(netd, uid, gid);
+
 	err = -EEXIST;
 	net_statd = proc_net_mkdir(net, "stat", netd);
 	if (!net_statd)
-- 
2.8.0.rc3.226.g39d4020
