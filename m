From: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH 3/5] NFS: blocklayout PipeFS notifier introduced
Date: Tue, 29 Nov 2011 13:10:29 +0300
Message-ID: <20111129091029.20730.3239.stgit@localhost6.localdomain6>
References: <20111129090754.20730.64567.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111129090754.20730.64567.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch subscribes blocklayout pipes to RPC pipefs notifications. Notifier
is registering on blocklayout module load. This notifier callback is
responsible for creation/destruction of PipeFS blocklayout pipe dentry.
Note that no locking required in notifier callback because PipeFS superblock
pointer is passed as an argument from it's creation or destruction routine and
thus we can be sure about it's validity.

Signed-off-by: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>

---
 fs/nfs/blocklayout/blocklayout.c |   48 +++++++++++++++++++++++++++++++++++++-
 1 files changed, 47 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index bf20187..acf7ac9 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -984,6 +984,46 @@ static void nfs4blocklayout_unregister_sb(struct super_block *sb,
 		rpc_unlink(pipe->dentry);
 }
 
+static int rpc_pipefs_event(struct notifier_block *nb, unsigned long event,
+			   void *ptr)
+{
+	struct super_block *sb = ptr;
+	struct net *net = sb->s_fs_info;
+	struct nfs_net *nn = net_generic(net, nfs_net_id);
+	struct dentry *dentry;
+	int ret = 0;
+
+	if (!try_module_get(THIS_MODULE))
+		return 0;
+
+	if (nn->bl_device_pipe == NULL)
+		return 0;
+
+	switch (event) {
+	case RPC_PIPEFS_MOUNT:
+		dentry = nfs4blocklayout_register_sb(sb, nn->bl_device_pipe);
+		if (IS_ERR(dentry)) {
+			ret = PTR_ERR(dentry);
+			break;
+		}
+		nn->bl_device_pipe->dentry = dentry;
+		break;
+	case RPC_PIPEFS_UMOUNT:
+		if (nn->bl_device_pipe->dentry)
+			nfs4blocklayout_unregister_sb(sb, nn->bl_device_pipe);
+		break;
+	default:
+		ret = -ENOTSUPP;
+		break;
+	}
+	module_put(THIS_MODULE);
+	return ret;
+}
+
+static struct notifier_block nfs4blocklayout_block = {
+	.notifier_call = rpc_pipefs_event,
+};
+
 static struct dentry *nfs4blocklayout_register_net(struct net *net,
 						   struct rpc_pipe *pipe)
 {
@@ -1059,12 +1099,17 @@ static int __init nfs4blocklayout_init(void)
 		ret = PTR_ERR(mnt);
 		goto out_remove;
 	}
-	ret = register_pernet_subsys(&nfs4blocklayout_net_ops);
+	ret = rpc_pipefs_notifier_register(&nfs4blocklayout_block);
 	if (ret)
 		goto out_remove;
+	ret = register_pernet_subsys(&nfs4blocklayout_net_ops);
+	if (ret)
+		goto out_notifier;
 out:
 	return ret;
 
+out_notifier:
+	rpc_pipefs_notifier_unregister(&nfs4blocklayout_block);
 out_remove:
 	pnfs_unregister_layoutdriver(&blocklayout_type);
 	return ret;
@@ -1075,6 +1120,7 @@ static void __exit nfs4blocklayout_exit(void)
 	dprintk("%s: NFSv4 Block Layout Driver Unregistering...\n",
 	       __func__);
 
+	rpc_pipefs_notifier_unregister(&nfs4blocklayout_block);
 	unregister_pernet_subsys(&nfs4blocklayout_net_ops);
 	pnfs_unregister_layoutdriver(&blocklayout_type);
 }

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
