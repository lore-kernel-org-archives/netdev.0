From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC] net: dummy: add BPF offload callbacks for test purposes
Date: Tue, 31 Oct 2017 19:29:46 -0700
Message-ID: <20171101022946.27114-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:47314 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932742AbdKAC3w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 22:29:52 -0400
Received: by mail-pg0-f65.google.com with SMTP id r25so867534pgn.4
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 19:29:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add callbacks for BPF offload, a handful of checks and DebugFS
files to be able to test BPF offload without any offload-
-capable HW.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>
---
This was a little useful for testing, I'm not sure we want
it upstream, though?

 drivers/net/dummy.c | 162 +++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 154 insertions(+), 8 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 58483af80bdb..e1a1ad7902de 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -28,6 +28,10 @@
 			Alan Cox, 30th May 1994
 */
 
+#include <linux/bpf.h>
+#include <linux/bpf_verifier.h>
+#include <linux/debugfs.h>
+#include <linux/filter.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
@@ -47,6 +51,7 @@
 
 static int numdummies = 1;
 static int num_vfs;
+static bool debugfs;
 
 struct vf_data_storage {
 	u8	vf_mac[ETH_ALEN];
@@ -61,8 +66,21 @@ struct vf_data_storage {
 	int	link_state;
 };
 
+struct dummy_bpf_offload_prog {
+	struct dummy_priv	*dummy;
+	struct bpf_prog		*prog;
+	const char 		*state;
+	struct list_head	l;
+};
+
 struct dummy_priv {
 	struct vf_data_storage	*vfinfo;
+	struct bpf_prog		*xdp_prog;
+	int			xdp_prog_mode;
+	struct dentry		*ddir;
+	bool			bpf_offload_accept;
+	u32			bpf_offload_verifier_delay;
+	struct list_head	bpf_offload_progs;
 };
 
 static int dummy_num_vf(struct device *dev)
@@ -85,6 +103,35 @@ static struct device dummy_parent = {
 	.release	= release_dummy_parent,
 };
 
+static int dummy_debugfs_bpf_offload_read(struct seq_file *file, void *data)
+{
+	struct dummy_priv *priv = file->private;
+	struct dummy_bpf_offload_prog *state;
+	unsigned int i = 0;
+
+	rtnl_lock();
+	list_for_each_entry(state, &priv->bpf_offload_progs, l)
+		seq_printf(file, "%u %u %s %d\n",
+			   i++, state->prog->aux->id, state->state,
+			   state->prog == state->dummy->xdp_prog);
+	rtnl_unlock();
+
+	return 0;
+}
+
+static int dummy_debugfs_bpf_offload_open(struct inode *inode, struct file *f)
+{
+	return single_open(f, dummy_debugfs_bpf_offload_read, inode->i_private);
+}
+
+static const struct file_operations dummy_bpf_offload_fops = {
+	.owner = THIS_MODULE,
+	.open = dummy_debugfs_bpf_offload_open,
+	.release = single_release,
+	.read = seq_read,
+	.llseek = seq_lseek
+};
+
 /* fake multicast ability */
 static void set_multicast_list(struct net_device *dev)
 {
@@ -141,18 +188,36 @@ static int dummy_dev_init(struct net_device *dev)
 
 	priv->vfinfo = NULL;
 
-	if (!num_vfs)
-		return 0;
+	if (num_vfs) {
+		dev->dev.parent = &dummy_parent;
+		priv->vfinfo = kcalloc(num_vfs, sizeof(struct vf_data_storage),
+				       GFP_KERNEL);
+		if (!priv->vfinfo)
+			goto err_free_dstats;
+	}
 
-	dev->dev.parent = &dummy_parent;
-	priv->vfinfo = kcalloc(num_vfs, sizeof(struct vf_data_storage),
-			       GFP_KERNEL);
-	if (!priv->vfinfo) {
-		free_percpu(dev->dstats);
-		return -ENOMEM;
+	INIT_LIST_HEAD(&priv->bpf_offload_progs);
+	if (debugfs) {
+		priv->ddir = debugfs_create_dir(dev->name, NULL);
+		if (!priv->ddir)
+			goto err_free_vfinfo;
+
+		debugfs_create_bool("bpf_offload_accept", 0600,
+				    priv->ddir, &priv->bpf_offload_accept);
+		debugfs_create_u32("bpf_offload_verifier_delay", 0600,
+				   priv->ddir,
+				   &priv->bpf_offload_verifier_delay);
+		debugfs_create_file("bpf_offload_list", 0600, priv->ddir,
+				    priv, &dummy_bpf_offload_fops);
 	}
 
 	return 0;
+
+err_free_vfinfo:
+	kfree(priv->vfinfo);
+err_free_dstats:
+	free_percpu(dev->dstats);
+	return -ENOMEM;
 }
 
 static void dummy_dev_uninit(struct net_device *dev)
@@ -280,6 +345,81 @@ static int dummy_set_vf_link_state(struct net_device *dev, int vf, int state)
 	return 0;
 }
 
+static int
+dummy_bpf_verify_insn(struct bpf_verifier_env *env, int insn_idx, int prev_insn)
+{
+	struct dummy_bpf_offload_prog *state;
+
+	state = env->prog->aux->offload->dev_priv;
+	if (state->dummy->bpf_offload_verifier_delay && !insn_idx)
+		msleep(state->dummy->bpf_offload_verifier_delay);
+
+	return 0;
+}
+
+static const struct bpf_ext_analyzer_ops dummy_bpf_analyzer_ops = {
+	.insn_hook = dummy_bpf_verify_insn,
+};
+
+static int dummy_bpf(struct net_device *dev, struct netdev_bpf *bpf)
+{
+	struct dummy_priv *priv = netdev_priv(dev);
+	struct dummy_bpf_offload_prog *state;
+
+	ASSERT_RTNL();
+
+	switch (bpf->command) {
+	case BPF_OFFLOAD_VERIFIER_PREP:
+		if (!priv->bpf_offload_accept)
+			return -EOPNOTSUPP;
+
+		state = kzalloc(sizeof(*state), GFP_KERNEL);
+		if (!state)
+			return -ENOMEM;
+		bpf->verifier.prog->aux->offload->dev_priv = state;
+		bpf->verifier.ops = &dummy_bpf_analyzer_ops;
+
+		state->dummy = priv;
+		state->prog = bpf->verifier.prog;
+		state->state = "verify";
+		list_add_tail(&state->l, &priv->bpf_offload_progs);
+		return 0;
+	case BPF_OFFLOAD_TRANSLATE:
+		state = bpf->offload.prog->aux->offload->dev_priv;
+
+		state->state = "xlated";
+		return 0;
+	case BPF_OFFLOAD_DESTROY:
+		state = bpf->offload.prog->aux->offload->dev_priv;
+
+		list_del(&state->l);
+		kfree(state);
+		return 0;
+	case XDP_QUERY_PROG:
+		if (priv->xdp_prog) {
+			bpf->prog_attached = priv->xdp_prog_mode;
+			bpf->prog_id = priv->xdp_prog->aux->id;
+		}
+		return 0;
+	case XDP_SETUP_PROG:
+	case XDP_SETUP_PROG_HW:
+		if (bpf->prog->aux->offload) {
+			WARN_ON(bpf->prog->aux->offload->netdev != dev);
+			state = bpf->prog->aux->offload->dev_priv;
+			WARN_ON(strcmp(state->state, "xlated"));
+		}
+
+		if (priv->xdp_prog)
+			bpf_prog_put(priv->xdp_prog);
+		priv->xdp_prog = bpf->prog;
+		priv->xdp_prog_mode = bpf->command == XDP_SETUP_PROG ?
+			XDP_ATTACHED_DRV : XDP_ATTACHED_HW;
+		return 0;
+	default:
+		return -EINVAL;
+	}
+}
+
 static const struct net_device_ops dummy_netdev_ops = {
 	.ndo_init		= dummy_dev_init,
 	.ndo_uninit		= dummy_dev_uninit,
@@ -297,6 +437,7 @@ static const struct net_device_ops dummy_netdev_ops = {
 	.ndo_get_vf_config	= dummy_get_vf_config,
 	.ndo_set_vf_link_state	= dummy_set_vf_link_state,
 	.ndo_set_vf_rss_query_en = dummy_set_vf_rss_query_en,
+	.ndo_bpf		= dummy_bpf,
 };
 
 static void dummy_get_drvinfo(struct net_device *dev,
@@ -327,6 +468,8 @@ static void dummy_free_netdev(struct net_device *dev)
 {
 	struct dummy_priv *priv = netdev_priv(dev);
 
+	WARN_ON(!list_empty(&priv->bpf_offload_progs));
+	debugfs_remove_recursive(priv->ddir);
 	kfree(priv->vfinfo);
 }
 
@@ -382,6 +525,9 @@ MODULE_PARM_DESC(numdummies, "Number of dummy pseudo devices");
 module_param(num_vfs, int, 0);
 MODULE_PARM_DESC(num_vfs, "Number of dummy VFs per dummy device");
 
+module_param(debugfs, bool, false);
+MODULE_PARM_DESC(debugfs, "Expose control interface in DebugFS");
+
 static int __init dummy_init_one(void)
 {
 	struct net_device *dev_dummy;
-- 
2.14.1
