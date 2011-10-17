From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [RFC PATCH 1/5] SUNRPC: hold current network namespace while pipefs
	superblock is active
Date: Mon, 17 Oct 2011 16:10:27 +0300
Message-ID: <20111017121027.4541.66778.stgit@localhost6.localdomain6>
References: <20111017120629.4541.67395.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bfields@fieldses.org, davem@davemloft.net, devel@openvz.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111017120629.4541.67395.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We want to be sure that network namespace is still alive while we have pipefs
mounted.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/rpc_pipe.c |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index b181e34..8322080 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -27,6 +27,9 @@
 #include <linux/workqueue.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/sunrpc/cache.h>
+#include <linux/nsproxy.h>
+
+#include "netns.h"
 
 static struct vfsmount *rpc_mnt __read_mostly;
 static int rpc_mount_count;
@@ -1006,6 +1009,7 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 {
 	struct inode *inode;
 	struct dentry *root;
+	struct net *net = current->nsproxy->net_ns;
 
 	sb->s_blocksize = PAGE_CACHE_SIZE;
 	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
@@ -1023,6 +1027,7 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 	}
 	if (rpc_populate(root, files, RPCAUTH_lockd, RPCAUTH_RootEOF, NULL))
 		return -ENOMEM;
+	sb->s_fs_info = get_net(net);
 	return 0;
 }
 
@@ -1033,11 +1038,19 @@ rpc_mount(struct file_system_type *fs_type,
 	return mount_single(fs_type, flags, data, rpc_fill_super);
 }
 
+void rpc_kill_sb(struct super_block *sb)
+{
+	struct net *net = sb->s_fs_info;
+
+	put_net(net);
+	kill_litter_super(sb);
+}
+
 static struct file_system_type rpc_pipe_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "rpc_pipefs",
 	.mount		= rpc_mount,
-	.kill_sb	= kill_litter_super,
+	.kill_sb	= rpc_kill_sb,
 };
 
 static void
