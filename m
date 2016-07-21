From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH v2 10/10] mntns: Add a limit on the number of mount namespaces.
Date: Thu, 21 Jul 2016 11:40:14 -0500
Message-ID: <20160721164014.17534-10-ebiederm@xmission.com>
References: <87d1m754jc.fsf@x220.int.ebiederm.org>
 <20160721164014.17534-1-ebiederm@xmission.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Jann Horn <jann@thejh.net>,
	Kees Cook <keescook@chromium.org>,
	Nikolay Borisov <kernel@kyup.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Seth Forshee <seth.forshee@canonical.com>,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Linux Containers <containers@lists.linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20160721164014.17534-1-ebiederm@xmission.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 fs/namespace.c                 | 19 ++++++++++++++++++-
 include/linux/user_namespace.h |  1 +
 kernel/user_namespace.c        |  1 +
 3 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index aabe8e397fc3..3942ae6c34f5 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2718,9 +2718,20 @@ dput_out:
 	return retval;
 }
 
+static bool inc_mnt_namespaces(struct user_namespace *ns)
+{
+	return inc_ucount(ns, UCOUNT_MNT_NAMESPACES);
+}
+
+static void dec_mnt_namespaces(struct user_namespace *ns)
+{
+	dec_ucount(ns, UCOUNT_MNT_NAMESPACES);
+}
+
 static void free_mnt_ns(struct mnt_namespace *ns)
 {
 	ns_free_inum(&ns->ns);
+	dec_mnt_namespaces(ns->user_ns);
 	put_user_ns(ns->user_ns);
 	kfree(ns);
 }
@@ -2739,12 +2750,18 @@ static struct mnt_namespace *alloc_mnt_ns(struct user_namespace *user_ns)
 	struct mnt_namespace *new_ns;
 	int ret;
 
+	if (!inc_mnt_namespaces(user_ns))
+		return ERR_PTR(-ENFILE);
+
 	new_ns = kmalloc(sizeof(struct mnt_namespace), GFP_KERNEL);
-	if (!new_ns)
+	if (!new_ns) {
+		dec_mnt_namespaces(user_ns);
 		return ERR_PTR(-ENOMEM);
+	}
 	ret = ns_alloc_inum(&new_ns->ns);
 	if (ret) {
 		kfree(new_ns);
+		dec_mnt_namespaces(user_ns);
 		return ERR_PTR(ret);
 	}
 	new_ns->ns.ops = &mntns_operations;
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index f86afa536baf..ee0e9d7b2e67 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -28,6 +28,7 @@ enum ucounts {
 	UCOUNT_UTS_NAMESPACES,
 	UCOUNT_IPC_NAMESPACES,
 	UCOUNT_NET_NAMESPACES,
+	UCOUNT_MNT_NAMESPACES,
 	UCOUNT_CGROUP_NAMESPACES,
 	UCOUNT_COUNTS,
 };
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index e326ca722ae0..f6702d84afab 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -81,6 +81,7 @@ static struct ctl_table userns_table[] = {
 	UCOUNT_ENTRY("max_uts_namespaces"),
 	UCOUNT_ENTRY("max_ipc_namespaces"),
 	UCOUNT_ENTRY("max_net_namespaces"),
+	UCOUNT_ENTRY("max_mnt_namespaces"),
 	UCOUNT_ENTRY("max_cgroup_namespaces"),
 	{ }
 };
-- 
2.8.3

