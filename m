From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 03/11] net: dsa: debugfs: add tree
Date: Mon, 14 Aug 2017 18:22:34 -0400
Message-ID: <20170814222242.10643-4-vivien.didelot@savoirfairelinux.com>
References: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Maxime Hadjinlian <maxime@devialet.com>,
        Chris Healy <cphealy@gmail.com>,
        Maxim Uvarov <muvarov@gmail.com>,
        Stefan Eichenberger <eichest@gmail.com>,
        Jason Cobham <jcobham@questertangent.com>,
        Juergen Borleis <jbe@pengutronix.de>,
        Tobias Waldekranz <tobias@waldekranz.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit adds the boiler plate to create a DSA related debug
filesystem entry as well as a "tree" file, containing the tree index.

    # cat switch1/tree
    0

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/debugfs.c | 108 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 108 insertions(+)

diff --git a/net/dsa/debugfs.c b/net/dsa/debugfs.c
index 68caf5a2c0c3..5607efdb924d 100644
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
@@ -36,6 +138,7 @@ static int dsa_debugfs_create_port(struct dsa_switch *ds, int port)
 static int dsa_debugfs_create_switch(struct dsa_switch *ds)
 {
 	char name[32];
+	int err;
 	int i;
 
 	/* skip if there is no debugfs support */
@@ -48,6 +151,11 @@ static int dsa_debugfs_create_switch(struct dsa_switch *ds)
 	if (IS_ERR_OR_NULL(ds->debugfs_dir))
 		return -EFAULT;
 
+	err = dsa_debugfs_create_file(ds, ds->debugfs_dir, "tree", -1,
+				      &dsa_debugfs_tree_ops);
+	if (err)
+		return err;
+
 	for (i = 0; i < ds->num_ports; i++) {
 		if (!ds->ports[i].dn)
 			continue;
-- 
2.14.0
