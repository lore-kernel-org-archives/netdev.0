From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH v3 4/7] SUNRPC: pipefs dentry lookup helper introduced
Date: Mon, 26 Dec 2011 15:39:22 +0300
Message-ID: <20111226113922.13216.45211.stgit@localhost6.localdomain6>
References: <20111226113504.13216.19798.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbottomley@parallels.com, bfields@fieldses.org,
	davem@davemloft.net, devel@openvz.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111226113504.13216.19798.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In all places, where pipefs dentries are created, only directory inode is
actually required to create new dentry. And all this directories has root
pipefs dentry as their parent. So we actually don't need this pipefs mount
point at all if some pipefs lookup method will be provided.
IOW, all we really need is just superblock and simple lookup method to find
root's child dentry with appropriate name. And this patch introduces this
method.
Note, that no locking implemented in rpc_d_lookup_sb(). So it can be used only
in case of assurance, that pipefs superblock still exist. IOW, we can use this
method only in pipefs mount-umount notification subscribers callbacks.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 include/linux/sunrpc/rpc_pipe_fs.h |    3 +++
 net/sunrpc/rpc_pipe.c              |   16 ++++++++++++++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index 733ef50..4585985 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -51,6 +51,9 @@ enum {
 	RPC_PIPEFS_UMOUNT,
 };
 
+extern struct dentry *rpc_d_lookup_sb(const struct super_block *sb,
+				      const unsigned char *dir_name);
+
 extern ssize_t rpc_pipe_generic_upcall(struct file *, struct rpc_pipe_msg *,
 				       char __user *, size_t);
 extern int rpc_queue_upcall(struct inode *, struct rpc_pipe_msg *);
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 07fb7dd..1de840d 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1008,6 +1008,22 @@ static const struct rpc_filelist files[] = {
 	},
 };
 
+/*
+ * This call can be used only in RPC pipefs mount notification hooks.
+ */
+struct dentry *rpc_d_lookup_sb(const struct super_block *sb,
+			       const unsigned char *dir_name)
+{
+	struct qstr dir = {
+		.name = dir_name,
+		.len = strlen(dir_name),
+		.hash = full_name_hash(dir_name, strlen(dir_name)),
+	};
+
+	return d_lookup(sb->s_root, &dir);
+}
+EXPORT_SYMBOL_GPL(rpc_d_lookup_sb);
+
 static int
 rpc_fill_super(struct super_block *sb, void *data, int silent)
 {
