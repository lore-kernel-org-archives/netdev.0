From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: move lane seq_file ops to lec.c [1/3]
Date: Thu, 25 Sep 2003 12:13:25 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309251613.h8PGDOkT007056@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1455  -> 1.1456 
#	      net/atm/proc.c	1.32    -> 1.33   
#	       net/atm/lec.c	1.39    -> 1.40   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/23	chas@relax.cmf.nrl.navy.mil	1.1456
# [ATM]: move lane seq_file ops to lec.c [1/3]
# --------------------------------------------
#
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	Thu Sep 25 09:25:33 2003
+++ b/net/atm/lec.c	Thu Sep 25 09:25:33 2003
@@ -21,6 +21,8 @@
 #include <net/dst.h>
 #include <linux/proc_fs.h>
 #include <linux/spinlock.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 
 /* TokenRing if needed */
 #ifdef CONFIG_TR
@@ -842,8 +844,264 @@
 	.owner = 	THIS_MODULE
 };
 
+
+#ifdef CONFIG_PROC_FS
+static char* lec_arp_get_status_string(unsigned char status)
+{
+	static char *lec_arp_status_string[] = {
+		"ESI_UNKNOWN       ",
+		"ESI_ARP_PENDING   ",
+		"ESI_VC_PENDING    ",
+		"<Undefined>       ",
+		"ESI_FLUSH_PENDING ",
+		"ESI_FORWARD_DIRECT"
+	};
+
+	if (status > ESI_FORWARD_DIRECT)
+		status = 3;	/* ESI_UNDEFINED */
+	return lec_arp_status_string[status];
+}
+
+static void lec_info(struct seq_file *seq, struct lec_arp_table *entry)
+{
+	int i;
+
+	for (i = 0; i < ETH_ALEN; i++)
+		seq_printf(seq, "%2.2x", entry->mac_addr[i] & 0xff);
+	seq_printf(seq, " ");
+	for (i = 0; i < ATM_ESA_LEN; i++)
+		seq_printf(seq, "%2.2x", entry->atm_addr[i] & 0xff);
+	seq_printf(seq, " %s %4.4x", lec_arp_get_status_string(entry->status),
+		   entry->flags & 0xffff);
+	if (entry->vcc)
+		seq_printf(seq, "%3d %3d ", entry->vcc->vpi, entry->vcc->vci);
+	else
+	        seq_printf(seq, "        ");
+	if (entry->recv_vcc) {
+		seq_printf(seq, "     %3d %3d", entry->recv_vcc->vpi,
+			   entry->recv_vcc->vci);
+        }
+        seq_putc(seq, '\n');
+}
+
+
+struct lec_state {
+	unsigned long flags;
+	struct lec_priv *locked;
+	struct lec_arp_table *entry;
+	struct net_device *dev;
+	int itf;
+	int arp_table;
+	int misc_table;
+};
+
+static void *lec_tbl_walk(struct lec_state *state, struct lec_arp_table *tbl,
+			  loff_t *l)
+{
+	struct lec_arp_table *e = state->entry;
+
+	if (!e)
+		e = tbl;
+	if (e == (void *)1) {
+		e = tbl;
+		--*l;
+	}
+	for (; e; e = e->next) {
+		if (--*l < 0)
+			break;
+	}
+	state->entry = e;
+	return (*l < 0) ? state : NULL;
+}
+
+static void *lec_arp_walk(struct lec_state *state, loff_t *l,
+			      struct lec_priv *priv)
+{
+	void *v = NULL;
+	int p;
+
+	for (p = state->arp_table; p < LEC_ARP_TABLE_SIZE; p++) {
+		v = lec_tbl_walk(state, priv->lec_arp_tables[p], l);
+		if (v)
+			break;
+	}
+	state->arp_table = p;
+	return v;
+}
+
+static void *lec_misc_walk(struct lec_state *state, loff_t *l,
+			   struct lec_priv *priv)
+{
+	struct lec_arp_table *lec_misc_tables[] = {
+		priv->lec_arp_empty_ones,
+		priv->lec_no_forward,
+		priv->mcast_fwds
+	};
+	void *v = NULL;
+	int q;
+
+	for (q = state->misc_table; q < ARRAY_SIZE(lec_misc_tables); q++) {
+		v = lec_tbl_walk(state, lec_misc_tables[q], l);
+		if (v)
+			break;
+	}
+	state->misc_table = q;
+	return v;
+}
+
+static void *lec_priv_walk(struct lec_state *state, loff_t *l,
+			   struct lec_priv *priv)
+{
+	if (!state->locked) {
+		state->locked = priv;
+		spin_lock_irqsave(&priv->lec_arp_lock, state->flags);
+	}
+	if (!lec_arp_walk(state, l, priv) &&
+	    !lec_misc_walk(state, l, priv)) {
+		spin_unlock_irqrestore(&priv->lec_arp_lock, state->flags);
+		state->locked = NULL;
+		/* Partial state reset for the next time we get called */
+		state->arp_table = state->misc_table = 0;
+	}
+	return state->locked;
+}
+
+static void *lec_itf_walk(struct lec_state *state, loff_t *l)
+{
+	struct net_device *dev;
+	void *v;
+
+	dev = state->dev ? state->dev : dev_lec[state->itf];
+	v = (dev && dev->priv) ? lec_priv_walk(state, l, dev->priv) : NULL;
+	if (!v && dev) {
+		dev_put(dev);
+		/* Partial state reset for the next time we get called */
+		dev = NULL;
+	}
+	state->dev = dev;
+	return v;
+}
+
+static void *lec_get_idx(struct lec_state *state, loff_t l)
+{
+	void *v = NULL;
+
+	for (; state->itf < MAX_LEC_ITF; state->itf++) {
+		v = lec_itf_walk(state, &l);
+		if (v)
+			break;
+	}
+	return v; 
+}
+
+static void *lec_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	struct lec_state *state = seq->private;
+
+	state->itf = 0;
+	state->dev = NULL;
+	state->locked = NULL;
+	state->arp_table = 0;
+	state->misc_table = 0;
+	state->entry = (void *)1;
+
+	return *pos ? lec_get_idx(state, *pos) : (void*)1;
+}
+
+static void lec_seq_stop(struct seq_file *seq, void *v)
+{
+	struct lec_state *state = seq->private;
+
+	if (state->dev) {
+		spin_unlock_irqrestore(&state->locked->lec_arp_lock,
+				       state->flags);
+		dev_put(state->dev);
+	}
+}
+
+static void *lec_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct lec_state *state = seq->private;
+
+	v = lec_get_idx(state, 1);
+	*pos += !!PTR_ERR(v);
+	return v;
+}
+
+static int lec_seq_show(struct seq_file *seq, void *v)
+{
+	static char lec_banner[] = "Itf  MAC          ATM destination" 
+		"                          Status            Flags "
+		"VPI/VCI Recv VPI/VCI\n";
+
+	if (v == (void *)1)
+		seq_puts(seq, lec_banner);
+	else {
+		struct lec_state *state = seq->private;
+		struct net_device *dev = state->dev; 
+
+		seq_printf(seq, "%s ", dev->name);
+		lec_info(seq, state->entry);
+	}
+	return 0;
+}
+
+static struct seq_operations lec_seq_ops = {
+	.start	= lec_seq_start,
+	.next	= lec_seq_next,
+	.stop	= lec_seq_stop,
+	.show	= lec_seq_show,
+};
+
+static int lec_seq_open(struct inode *inode, struct file *file)
+{
+	struct lec_state *state;
+	struct seq_file *seq;
+	int rc = -EAGAIN;
+
+	state = kmalloc(sizeof(*state), GFP_KERNEL);
+	if (!state) {
+		rc = -ENOMEM;
+		goto out;
+	}
+
+	rc = seq_open(file, &lec_seq_ops);
+	if (rc)
+		goto out_kfree;
+	seq = file->private_data;
+	seq->private = state;
+out:
+	return rc;
+
+out_kfree:
+	kfree(state);
+	goto out;
+}
+
+static int lec_seq_release(struct inode *inode, struct file *file)
+{
+	return seq_release_private(inode, file);
+}
+
+static struct file_operations lec_seq_fops = {
+	.owner		= THIS_MODULE,
+	.open		= lec_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= lec_seq_release,
+};
+#endif
+
 static int __init lane_module_init(void)
 {
+#ifdef CONFIG_PROC_FS
+	struct proc_dir_entry *p;
+
+	p = create_proc_entry("lec", S_IRUGO, atm_proc_root);
+	if (p)
+		p->proc_fops = &lec_seq_fops;
+#endif
+
         atm_lane_ops_set(&__atm_lane_ops);
         printk("lec.c: " __DATE__ " " __TIME__ " initialized\n");
         return 0;
@@ -853,6 +1111,8 @@
 {
         int i;
         struct lec_priv *priv;
+
+	remove_proc_entry("lec", atm_proc_root);
 
         atm_lane_ops_set(NULL);
 
diff -Nru a/net/atm/proc.c b/net/atm/proc.c
--- a/net/atm/proc.c	Thu Sep 25 09:25:32 2003
+++ b/net/atm/proc.c	Thu Sep 25 09:25:32 2003
@@ -31,11 +31,6 @@
 #include "common.h" /* atm_proc_init prototype */
 #include "signaling.h" /* to get sigd - ugly too */
 
-#if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
-#include "lec.h"
-#include "lec_arpc.h"
-#endif
-
 static ssize_t proc_dev_atm_read(struct file *file,char *buf,size_t count,
     loff_t *pos);
 
@@ -237,49 +232,6 @@
 	seq_putc(seq, '\n');
 }
 
-#if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
-
-static char* lec_arp_get_status_string(unsigned char status)
-{
-	static char *lec_arp_status_string[] = {
-		"ESI_UNKNOWN       ",
-		"ESI_ARP_PENDING   ",
-		"ESI_VC_PENDING    ",
-		"<Unknown>         ",
-		"ESI_FLUSH_PENDING ",
-		"ESI_FORWARD_DIRECT",
-		"<Undefined>"
-	};
-
-	if (status > ESI_FORWARD_DIRECT)
-		status = ESI_FORWARD_DIRECT + 1;
-	return lec_arp_status_string[status];
-}
-
-static void lec_info(struct seq_file *seq, struct lec_arp_table *entry)
-{
-	int i;
-
-	for (i = 0; i < ETH_ALEN; i++)
-		seq_printf(seq, "%2.2x", entry->mac_addr[i] & 0xff);
-	seq_printf(seq, " ");
-	for (i = 0; i < ATM_ESA_LEN; i++)
-		seq_printf(seq, "%2.2x", entry->atm_addr[i] & 0xff);
-	seq_printf(seq, " %s %4.4x", lec_arp_get_status_string(entry->status),
-		   entry->flags & 0xffff);
-	if (entry->vcc)
-		seq_printf(seq, "%3d %3d ", entry->vcc->vpi, entry->vcc->vci);
-	else
-	        seq_printf(seq, "        ");
-	if (entry->recv_vcc) {
-		seq_printf(seq, "     %3d %3d", entry->recv_vcc->vpi,
-			   entry->recv_vcc->vci);
-        }
-        seq_putc(seq, '\n');
-}
-
-#endif /* CONFIG_ATM_LANE */
-
 static int atm_dev_seq_show(struct seq_file *seq, void *v)
 {
 	static char atm_dev_banner[] =
@@ -419,218 +371,6 @@
 	.release	= vcc_seq_release,
 };
 
-#if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
-
-struct lec_state {
-	unsigned long flags;
-	struct lec_priv *locked;
-	struct lec_arp_table *entry;
-	struct net_device *dev;
-	int itf;
-	int arp_table;
-	int misc_table;
-};
-
-static void *lec_tbl_walk(struct lec_state *state, struct lec_arp_table *tbl,
-			  loff_t *l)
-{
-	struct lec_arp_table *e = state->entry;
-
-	if (!e)
-		e = tbl;
-	if (e == (void *)1) {
-		e = tbl;
-		--*l;
-	}
-	for (; e; e = e->next) {
-		if (--*l < 0)
-			break;
-	}
-	state->entry = e;
-	return (*l < 0) ? state : NULL;
-}
-
-static void *lec_arp_walk(struct lec_state *state, loff_t *l,
-			      struct lec_priv *priv)
-{
-	void *v = NULL;
-	int p;
-
-	for (p = state->arp_table; p < LEC_ARP_TABLE_SIZE; p++) {
-		v = lec_tbl_walk(state, priv->lec_arp_tables[p], l);
-		if (v)
-			break;
-	}
-	state->arp_table = p;
-	return v;
-}
-
-static void *lec_misc_walk(struct lec_state *state, loff_t *l,
-			   struct lec_priv *priv)
-{
-	struct lec_arp_table *lec_misc_tables[] = {
-		priv->lec_arp_empty_ones,
-		priv->lec_no_forward,
-		priv->mcast_fwds
-	};
-	void *v = NULL;
-	int q;
-
-	for (q = state->misc_table; q < ARRAY_SIZE(lec_misc_tables); q++) {
-		v = lec_tbl_walk(state, lec_misc_tables[q], l);
-		if (v)
-			break;
-	}
-	state->misc_table = q;
-	return v;
-}
-
-static void *lec_priv_walk(struct lec_state *state, loff_t *l,
-			   struct lec_priv *priv)
-{
-	if (!state->locked) {
-		state->locked = priv;
-		spin_lock_irqsave(&priv->lec_arp_lock, state->flags);
-	}
-	if (!lec_arp_walk(state, l, priv) &&
-	    !lec_misc_walk(state, l, priv)) {
-		spin_unlock_irqrestore(&priv->lec_arp_lock, state->flags);
-		state->locked = NULL;
-		/* Partial state reset for the next time we get called */
-		state->arp_table = state->misc_table = 0;
-	}
-	return state->locked;
-}
-
-static void *lec_itf_walk(struct lec_state *state, loff_t *l)
-{
-	struct net_device *dev;
-	void *v;
-
-	dev = state->dev ? state->dev : atm_lane_ops->get_lec(state->itf);
-	v = (dev && dev->priv) ? lec_priv_walk(state, l, dev->priv) : NULL;
-	if (!v && dev) {
-		dev_put(dev);
-		/* Partial state reset for the next time we get called */
-		dev = NULL;
-	}
-	state->dev = dev;
-	return v;
-}
-
-static void *lec_get_idx(struct lec_state *state, loff_t l)
-{
-	void *v = NULL;
-
-	for (; state->itf < MAX_LEC_ITF; state->itf++) {
-		v = lec_itf_walk(state, &l);
-		if (v)
-			break;
-	}
-	return v; 
-}
-
-static void *lec_seq_start(struct seq_file *seq, loff_t *pos)
-{
-	struct lec_state *state = seq->private;
-
-	state->itf = 0;
-	state->dev = NULL;
-	state->locked = NULL;
-	state->arp_table = 0;
-	state->misc_table = 0;
-	state->entry = (void *)1;
-
-	return *pos ? lec_get_idx(state, *pos) : (void*)1;
-}
-
-static void lec_seq_stop(struct seq_file *seq, void *v)
-{
-	struct lec_state *state = seq->private;
-
-	if (state->dev) {
-		spin_unlock_irqrestore(&state->locked->lec_arp_lock,
-				       state->flags);
-		dev_put(state->dev);
-	}
-}
-
-static void *lec_seq_next(struct seq_file *seq, void *v, loff_t *pos)
-{
-	struct lec_state *state = seq->private;
-
-	v = lec_get_idx(state, 1);
-	*pos += !!PTR_ERR(v);
-	return v;
-}
-
-static int lec_seq_show(struct seq_file *seq, void *v)
-{
-	static char lec_banner[] = "Itf  MAC          ATM destination" 
-		"                          Status            Flags "
-		"VPI/VCI Recv VPI/VCI\n";
-
-	if (v == (void *)1)
-		seq_puts(seq, lec_banner);
-	else {
-		struct lec_state *state = seq->private;
-		struct net_device *dev = state->dev; 
-
-		seq_printf(seq, "%s ", dev->name);
-		lec_info(seq, state->entry);
-	}
-	return 0;
-}
-
-static struct seq_operations lec_seq_ops = {
-	.start	= lec_seq_start,
-	.next	= lec_seq_next,
-	.stop	= lec_seq_stop,
-	.show	= lec_seq_show,
-};
-
-static int lec_seq_open(struct inode *inode, struct file *file)
-{
-	struct lec_state *state;
-	struct seq_file *seq;
-	int rc = -EAGAIN;
-
-	if (!try_atm_lane_ops())
-		goto out;
-
-	state = kmalloc(sizeof(*state), GFP_KERNEL);
-	if (!state) {
-		rc = -ENOMEM;
-		goto out;
-	}
-
-	rc = seq_open(file, &lec_seq_ops);
-	if (rc)
-		goto out_kfree;
-	seq = file->private_data;
-	seq->private = state;
-out:
-	return rc;
-out_kfree:
-	kfree(state);
-	goto out;
-}
-
-static int lec_seq_release(struct inode *inode, struct file *file)
-{
-	module_put(atm_lane_ops->owner);
-	return seq_release_private(inode, file);
-}
-
-static struct file_operations lec_seq_fops = {
-	.open		= lec_seq_open,
-	.read		= seq_read,
-	.llseek		= seq_lseek,
-	.release	= lec_seq_release,
-};
-
-#endif /* CONFIG_ATM_LANE */
-
 static ssize_t proc_dev_atm_read(struct file *file,char *buf,size_t count,
     loff_t *pos)
 {
@@ -720,9 +460,6 @@
 	{ .name = "pvc",	.proc_fops = &pvc_seq_fops },
 	{ .name = "svc",	.proc_fops = &svc_seq_fops },
 	{ .name = "vc",		.proc_fops = &vcc_seq_fops },
-#if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
-	{ .name = "lec",	.proc_fops = &lec_seq_fops },
-#endif
 	{ .name = NULL,		.proc_fops = NULL }
 };
 
