From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 02/10] net: dsa: debugfs: add tree
Date: Fri, 08 Sep 2017 10:57:29 -0400
Message-ID: <87k21944rq.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com> <20170828191748.19492-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Chris Healy <cphealy@gmail.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48156 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751166AbdIHPA4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 11:00:56 -0400
In-Reply-To: <20170828191748.19492-3-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg,

You wrote:

> > Can I ask for a quick review of this patch as well? It's the one adding
> > the boilerplate for a single debugfs file, and I'm pretty sure it can be
> > reduced somehow.
> 
> I don't see a patch here :(

Oops, you weren't originally in Cc. Please find the patch below.

> > Also more important, you will notice what seems to be a bug to me:
> > I can read or write a file even if I didn't mask the corresponding mode
> > hence the double check in dsa_debugfs_show and dsa_debugfs_write.
> 
> The mode can be changed by userspace, you shouldn't ever need to check
> it in any debugfs calls, right?

Correct. But this happens even if the file mode isn't changed by
userspace in the meantime, which seemed weird to me. e.g. echo
redirected to a -r--r--r-- debugfs entry will call dsa_debugfs_write.


Thanks,

        Vivien


------ Beginning of the patch ------

This commit adds the boiler plate to create a DSA related debug
filesystem entry as well as a "tree" file, containing the tree index.

    # cat switch1/tree
    0

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/debugfs.c | 107 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 107 insertions(+)

diff --git a/net/dsa/debugfs.c b/net/dsa/debugfs.c
index b6b5e5c97389..54e97e05a9d7 100644
--- a/net/dsa/debugfs.c
+++ b/net/dsa/debugfs.c
@@ -10,6 +10,7 @@
  */
 
 #include <linux/debugfs.h>
+#include <linux/seq_file.h>
 
 #include "dsa_priv.h"
 
@@ -19,6 +20,107 @@
 /* DSA module debugfs directory */
 static struct dentry *dsa_debugfs_dir;
 
+struct dsa_debugfs_ops {
+	int (*read)(struct dsa_switch *ds, int id, struct seq_file *seq);
+	int (*write)(struct dsa_switch *ds, int id, char *buf);
+};
+
+struct dsa_debugfs_priv {
+	const struct dsa_debugfs_ops *ops;
+	struct dsa_switch *ds;
+	int id;
+};
+
+static int dsa_debugfs_show(struct seq_file *seq, void *p)
+{
+	struct dsa_debugfs_priv *priv = seq->private;
+	struct dsa_switch *ds = priv->ds;
+
+	/* Somehow file mode is bypassed... Double check here */
+	if (!priv->ops->read)
+		return -EOPNOTSUPP;
+
+	return priv->ops->read(ds, priv->id, seq);
+}
+
+static ssize_t dsa_debugfs_write(struct file *file, const char __user *user_buf,
+				 size_t count, loff_t *ppos)
+{
+	struct seq_file *seq = file->private_data;
+	struct dsa_debugfs_priv *priv = seq->private;
+	struct dsa_switch *ds = priv->ds;
+	char buf[count + 1];
+	int err;
+
+	/* Somehow file mode is bypassed... Double check here */
+	if (!priv->ops->write)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(buf, user_buf, count))
+		return -EFAULT;
+
+	buf[count] = '\0';
+
+	err = priv->ops->write(ds, priv->id, buf);
+
+	return err ? err : count;
+}
+
+static int dsa_debugfs_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, dsa_debugfs_show, inode->i_private);
+}
+
+static const struct file_operations dsa_debugfs_fops = {
+	.open = dsa_debugfs_open,
+	.read = seq_read,
+	.write = dsa_debugfs_write,
+	.llseek = no_llseek,
+	.release = single_release,
+	.owner = THIS_MODULE,
+};
+
+static int dsa_debugfs_create_file(struct dsa_switch *ds, struct dentry *dir,
+				   char *name, int id,
+				   const struct dsa_debugfs_ops *ops)
+{
+	struct dsa_debugfs_priv *priv;
+	struct dentry *entry;
+	umode_t mode;
+
+	priv = devm_kzalloc(ds->dev, sizeof(*priv), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
+	priv->ops = ops;
+	priv->ds = ds;
+	priv->id = id;
+
+	mode = 0;
+	if (ops->read)
+		mode |= 0444;
+	if (ops->write)
+		mode |= 0200;
+
+	entry = debugfs_create_file(name, mode, dir, priv, &dsa_debugfs_fops);
+	if (IS_ERR_OR_NULL(entry))
+		return -EFAULT;
+
+	return 0;
+}
+
+static int dsa_debugfs_tree_read(struct dsa_switch *ds, int id,
+				 struct seq_file *seq)
+{
+	seq_printf(seq, "%d\n", ds->dst->tree);
+
+	return 0;
+}
+
+static const struct dsa_debugfs_ops dsa_debugfs_tree_ops = {
+	.read = dsa_debugfs_tree_read,
+};
+
 static int dsa_debugfs_create_port(struct dsa_switch *ds, int port)
 {
 	struct dentry *dir;
@@ -48,6 +150,11 @@ static int dsa_debugfs_create_switch(struct dsa_switch *ds)
 	if (IS_ERR_OR_NULL(ds->debugfs_dir))
 		return -EFAULT;
 
+	err = dsa_debugfs_create_file(ds, ds->debugfs_dir, "tree", -1,
+				      &dsa_debugfs_tree_ops);
+	if (err)
+		return err;
+
 	for (i = 0; i < ds->num_ports; i++) {
 		if (ds->enabled_port_mask & BIT(i)) {
 			err = dsa_debugfs_create_port(ds, i);
-- 
2.14.1
