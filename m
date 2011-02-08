From: "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH v3, RESEND 12/16] sunrpc: introduce get_rpc_pipefs()
Date: Tue,  8 Feb 2011 20:42:03 +0200
Message-ID: <1297190527-19925-13-git-send-email-kas@openvz.org>
References: <1297190527-19925-1-git-send-email-kas@openvz.org>
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1297190527-19925-1-git-send-email-kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Get rpc_pipefs mount point by path. If path is NULL, we use first
rpc_pipefs from mount table visible from current root directory.

Signed-off-by: Kirill A. Shutemov <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Reviewed-by: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
---
 include/linux/sunrpc/rpc_pipe_fs.h |    1 +
 net/sunrpc/rpc_pipe.c              |   51 ++++++++++++++++++++++++++++++++++++
 2 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index f5216f1..4a8830a 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -46,6 +46,7 @@ RPC_I(struct inode *inode)
 
 extern struct vfsmount *init_rpc_pipefs;
 
+extern struct vfsmount *get_rpc_pipefs(const char *path);
 extern int rpc_pipefs_add_destroy_cb(struct super_block *sb,
 		void (*destroy_cb)(void *data), void *data);
 
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 58312fa..1261f27 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -16,6 +16,9 @@
 #include <linux/namei.h>
 #include <linux/fsnotify.h>
 #include <linux/kernel.h>
+#include <linux/nsproxy.h>
+#include <linux/mnt_namespace.h>
+#include <linux/fs_struct.h>
 
 #include <asm/ioctls.h>
 #include <linux/fs.h>
@@ -939,6 +942,54 @@ static const struct super_operations s_ops = {
 
 #define RPCAUTH_GSSMAGIC 0x67596969
 
+static int check_rpc_pipefs(struct vfsmount *mnt, void *arg)
+{
+	struct vfsmount **rpcmount = arg;
+	struct path path = {
+		.mnt = mnt,
+		.dentry = mnt->mnt_root,
+	};
+
+	if (!mnt->mnt_sb)
+		return 0;
+	if (mnt->mnt_sb->s_magic != RPCAUTH_GSSMAGIC)
+		return 0;
+
+	if (!path_is_under(&path, &current->fs->root))
+		return 0;
+
+	*rpcmount = mntget(mnt);
+	return 1;
+}
+
+struct vfsmount *get_rpc_pipefs(const char *p)
+{
+	int error;
+	struct vfsmount *rpcmount = ERR_PTR(-EINVAL);
+	struct path path;
+
+	if (!p) {
+		iterate_mounts(check_rpc_pipefs, &rpcmount,
+				current->nsproxy->mnt_ns->root);
+
+		if (IS_ERR(rpcmount) && (current->nsproxy->mnt_ns ==
+					init_task.nsproxy->mnt_ns))
+			return mntget(init_rpc_pipefs);
+
+		return rpcmount;
+	}
+
+	error = kern_path(p, LOOKUP_FOLLOW | LOOKUP_DIRECTORY, &path);
+	if (error)
+		return ERR_PTR(error);
+
+	check_rpc_pipefs(path.mnt, &rpcmount);
+	path_put(&path);
+
+	return rpcmount;
+}
+EXPORT_SYMBOL_GPL(get_rpc_pipefs);
+
 struct destroy_cb {
 	struct list_head list;
 	void (*callback)(void *data);
-- 
1.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
