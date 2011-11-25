From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH 6/6] NFS: remove RPC PipeFS mount point references from NFS
	cache routines
Date: Fri, 25 Nov 2011 17:13:20 +0300
Message-ID: <20111125131320.6271.49000.stgit@localhost6.localdomain6>
References: <20111125130557.6271.95071.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbottomley@parallels.com, bfields@fieldses.org,
	davem@davemloft.net, devel@openvz.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111125130557.6271.95071.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a cleanup patch. We don't need this reference anymore, because DNS
resolver cache now creates it's dentries in per-net operations and on PipeFS
mount/umount notification.
Note that nfs_cache_register_net() now returns 0 instead of -ENOENT in case of
PiepFS superblock absence. This is ok, Dns resolver cache will be regestered on
PipeFS mount event.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/cache_lib.c |   19 ++++---------------
 1 files changed, 4 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/cache_lib.c b/fs/nfs/cache_lib.c
index 5905a31..dded263 100644
--- a/fs/nfs/cache_lib.c
+++ b/fs/nfs/cache_lib.c
@@ -126,24 +126,14 @@ int nfs_cache_register_sb(struct super_block *sb, struct cache_detail *cd)
 
 int nfs_cache_register_net(struct net *net, struct cache_detail *cd)
 {
-	struct vfsmount *mnt;
 	struct super_block *pipefs_sb;
-	int ret;
+	int ret = 0;
 
-	mnt = rpc_get_mount();
-	if (IS_ERR(mnt))
-		return PTR_ERR(mnt);
 	pipefs_sb = rpc_get_sb_net(net);
-	if (!pipefs_sb) {
-		ret = -ENOENT;
-		goto err;
+	if (pipefs_sb) {
+		ret = nfs_cache_register_sb(pipefs_sb, cd);
+		rpc_put_sb_net(net);
 	}
-	ret = nfs_cache_register_sb(pipefs_sb, cd);
-	rpc_put_sb_net(net);
-	if (!ret)
-		return ret;
-err:
-	rpc_put_mount();
 	return ret;
 }
 
@@ -162,7 +152,6 @@ void nfs_cache_unregister_net(struct net *net, struct cache_detail *cd)
 		nfs_cache_unregister_sb(pipefs_sb, cd);
 		rpc_put_sb_net(net);
 	}
-	rpc_put_mount();
 }
 
 void nfs_cache_init(struct cache_detail *cd)
