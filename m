From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [ioctl][6/8] move clip seq_file ops to clip.c (from levon@movementarian.org)
Date: Thu, 25 Sep 2003 12:11:14 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309251611.h8PGBDkT006991@ginger.cmf.nrl.navy.mil>
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
#	           ChangeSet	1.1452  -> 1.1453 
#	      net/atm/proc.c	1.31    -> 1.32   
#	include/linux/atmdev.h	1.31    -> 1.32   
#	      net/atm/clip.c	1.27    -> 1.28   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/23	chas@relax.cmf.nrl.navy.mil	1.1453
#   [ATM]: [ioctl][6/8] move clip seq_file ops to clip.c (from levon@movementarian.org)
# --------------------------------------------
#
diff -Nru a/include/linux/atmdev.h b/include/linux/atmdev.h
--- a/include/linux/atmdev.h	Thu Sep 25 09:24:43 2003
+++ b/include/linux/atmdev.h	Thu Sep 25 09:24:43 2003
@@ -214,6 +214,8 @@
 
 #ifdef CONFIG_PROC_FS
 #include <linux/proc_fs.h>
+
+extern struct proc_dir_entry *atm_proc_root;
 #endif
 
 
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	Thu Sep 25 09:24:43 2003
+++ b/net/atm/clip.c	Thu Sep 25 09:24:43 2003
@@ -24,6 +24,10 @@
 #include <linux/if.h> /* for IFF_UP */
 #include <linux/inetdevice.h>
 #include <linux/bitops.h>
+#ifdef CONFIG_PROC_FS
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+#endif
 #include <net/route.h> /* for struct rtable and routing */
 #include <net/icmp.h> /* icmp_send */
 #include <asm/param.h> /* for HZ */
@@ -768,8 +772,226 @@
 	.owner =		THIS_MODULE
 };
 
+#ifdef CONFIG_PROC_FS
+
+static void svc_addr(struct seq_file *seq, struct sockaddr_atmsvc *addr)
+{
+	static int code[] = { 1,2,10,6,1,0 };
+	static int e164[] = { 1,8,4,6,1,0 };
+
+	if (*addr->sas_addr.pub) {
+		seq_printf(seq, "%s", addr->sas_addr.pub);
+		if (*addr->sas_addr.prv)
+			seq_putc(seq, '+');
+	} else if (!*addr->sas_addr.prv) {
+		seq_printf(seq, "%s", "(none)");
+		return;
+	}
+	if (*addr->sas_addr.prv) {
+		unsigned char *prv = addr->sas_addr.prv;
+		int *fields;
+		int i, j;
+
+		fields = *prv == ATM_AFI_E164 ? e164 : code;
+		for (i = 0; fields[i]; i++) {
+			for (j = fields[i]; j; j--)
+				seq_printf(seq, "%02X", *prv++);
+			if (fields[i+1])
+				seq_putc(seq, '.');
+		}
+	}
+}
+
+static void atmarp_info(struct seq_file *seq, struct net_device *dev,
+			struct atmarp_entry *entry, struct clip_vcc *clip_vcc)
+{
+	char buf[17];
+	int svc, off;
+
+	svc = !clip_vcc || clip_vcc->vcc->sk->sk_family == AF_ATMSVC;
+	seq_printf(seq, "%-6s%-4s%-4s%5ld ", dev->name, svc ? "SVC" : "PVC",
+	    !clip_vcc || clip_vcc->encap ? "LLC" : "NULL",
+	    (jiffies-(clip_vcc ? clip_vcc->last_use : entry->neigh->used))/HZ);
+
+	off = snprintf(buf, sizeof(buf) - 1, "%d.%d.%d.%d", NIPQUAD(entry->ip));
+	while (off < 16)
+		buf[off++] = ' ';
+	buf[off] = '\0';
+	seq_printf(seq, "%s", buf);
+
+	if (!clip_vcc) {
+		if (time_before(jiffies, entry->expires))
+			seq_printf(seq, "(resolving)\n");
+		else
+			seq_printf(seq, "(expired, ref %d)\n",
+				   atomic_read(&entry->neigh->refcnt));
+	} else if (!svc) {
+		seq_printf(seq, "%d.%d.%d\n", clip_vcc->vcc->dev->number,
+			   clip_vcc->vcc->vpi, clip_vcc->vcc->vci);
+	} else {
+		svc_addr(seq, &clip_vcc->vcc->remote);
+		seq_putc(seq, '\n');
+	}
+}
+
+struct arp_state {
+	int bucket;
+  	struct neighbour *n;
+	struct clip_vcc *vcc;
+};
+  
+static void *arp_vcc_walk(struct arp_state *state,
+			  struct atmarp_entry *e, loff_t *l)
+{
+	struct clip_vcc *vcc = state->vcc;
+
+	if (!vcc)
+		vcc = e->vccs;
+	if (vcc == (void *)1) {
+		vcc = e->vccs;
+		--*l;
+  	}
+	for (; vcc; vcc = vcc->next) {
+		if (--*l < 0)
+			break;
+	}
+	state->vcc = vcc;
+	return (*l < 0) ? state : NULL;
+}
+  
+static void *arp_get_idx(struct arp_state *state, loff_t l)
+{
+	void *v = NULL;
+
+	for (; state->bucket <= NEIGH_HASHMASK; state->bucket++) {
+		for (; state->n; state->n = state->n->next) {
+			v = arp_vcc_walk(state, NEIGH2ENTRY(state->n), &l);
+			if (v)
+				goto done;
+  		}
+		state->n = clip_tbl_hook->hash_buckets[state->bucket + 1];
+	}
+done:
+	return v;
+}
+
+static void *arp_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	struct arp_state *state = seq->private;
+	void *ret = (void *)1;
+
+	if (!clip_tbl_hook) {
+		state->bucket = -1;
+		goto out;
+	}
+
+	read_lock_bh(&clip_tbl_hook->lock);
+	state->bucket = 0;
+	state->n = clip_tbl_hook->hash_buckets[0];
+	state->vcc = (void *)1;
+	if (*pos)
+		ret = arp_get_idx(state, *pos);
+out:
+	return ret;
+}
+
+static void arp_seq_stop(struct seq_file *seq, void *v)
+{
+	struct arp_state *state = seq->private;
+
+	if (state->bucket != -1)
+		read_unlock_bh(&clip_tbl_hook->lock);
+}
+
+static void *arp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct arp_state *state = seq->private;
+
+	v = arp_get_idx(state, 1);
+	*pos += !!PTR_ERR(v);
+	return v;
+}
+
+static int arp_seq_show(struct seq_file *seq, void *v)
+{
+	static char atm_arp_banner[] = 
+		"IPitf TypeEncp Idle IP address      ATM address\n";
+
+	if (v == (void *)1)
+		seq_puts(seq, atm_arp_banner);
+	else {
+		struct arp_state *state = seq->private;
+		struct neighbour *n = state->n;	
+		struct clip_vcc *vcc = state->vcc;
+
+		atmarp_info(seq, n->dev, NEIGH2ENTRY(n), vcc);
+	}
+  	return 0;
+}
+
+static struct seq_operations arp_seq_ops = {
+	.start	= arp_seq_start,
+	.next	= arp_seq_next,
+	.stop	= arp_seq_stop,
+	.show	= arp_seq_show,
+};
+
+static int arp_seq_open(struct inode *inode, struct file *file)
+{
+	struct arp_state *state;
+	struct seq_file *seq;
+	int rc = -EAGAIN;
+
+	if (!try_atm_clip_ops())
+		goto out;
+
+	state = kmalloc(sizeof(*state), GFP_KERNEL);
+	if (!state) {
+		rc = -ENOMEM;
+		goto out_put;
+	}
+
+	rc = seq_open(file, &arp_seq_ops);
+	if (rc)
+		goto out_kfree;
+
+	seq = file->private_data;
+	seq->private = state;
+out:
+	return rc;
+
+out_put:
+	module_put(atm_clip_ops->owner);
+out_kfree:
+	kfree(state);
+	goto out;
+}
+
+static int arp_seq_release(struct inode *inode, struct file *file)
+{
+	module_put(atm_clip_ops->owner);
+	return seq_release_private(inode, file);
+}
+
+static struct file_operations arp_seq_fops = {
+	.open		= arp_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= arp_seq_release,
+	.owner		= THIS_MODULE
+};
+#endif
+
 static int __init atm_clip_init(void)
 {
+#ifdef CONFIG_PROC_FS
+	struct proc_dir_entry *p;
+
+	p = create_proc_entry("arp", S_IRUGO, atm_proc_root);
+	if (p)
+		p->proc_fops = &arp_seq_fops;
+#endif
+
 	/* we should use neigh_table_init() */
 	clip_tbl.lock = RW_LOCK_UNLOCKED;
 	clip_tbl.kmem_cachep = kmem_cache_create(clip_tbl.id,
@@ -790,6 +1012,8 @@
 static void __exit atm_clip_exit(void)
 {
 	struct net_device *dev, *next;
+
+	remove_proc_entry("arp", atm_proc_root);
 
 	atm_clip_ops_set(NULL);
 
diff -Nru a/net/atm/proc.c b/net/atm/proc.c
--- a/net/atm/proc.c	Thu Sep 25 09:24:43 2003
+++ b/net/atm/proc.c	Thu Sep 25 09:24:43 2003
@@ -22,8 +22,6 @@
 #include <linux/atmdev.h>
 #include <linux/netdevice.h>
 #include <linux/atmclip.h>
-#include <linux/atmarp.h>
-#include <linux/if_arp.h>
 #include <linux/init.h> /* for __init */
 #include <net/atmclip.h>
 #include <asm/uaccess.h>
@@ -70,70 +68,6 @@
 	seq_putc(seq, '\n');
 }
 
-#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-
-static void svc_addr(struct seq_file *seq, struct sockaddr_atmsvc *addr)
-{
-	static int code[] = { 1,2,10,6,1,0 };
-	static int e164[] = { 1,8,4,6,1,0 };
-
-	if (*addr->sas_addr.pub) {
-		seq_printf(seq, "%s", addr->sas_addr.pub);
-		if (*addr->sas_addr.prv)
-			seq_putc(seq, '+');
-	} else if (!*addr->sas_addr.prv) {
-		seq_printf(seq, "%s", "(none)");
-		return;
-	}
-	if (*addr->sas_addr.prv) {
-		unsigned char *prv = addr->sas_addr.prv;
-		int *fields;
-		int i, j;
-
-		fields = *prv == ATM_AFI_E164 ? e164 : code;
-		for (i = 0; fields[i]; i++) {
-			for (j = fields[i]; j; j--)
-				seq_printf(seq, "%02X", *prv++);
-			if (fields[i+1])
-				seq_putc(seq, '.');
-		}
-	}
-}
-
-static void atmarp_info(struct seq_file *seq, struct net_device *dev,
-			struct atmarp_entry *entry, struct clip_vcc *clip_vcc)
-{
-	char buf[17];
-	int svc, off;
-
-	svc = !clip_vcc || clip_vcc->vcc->sk->sk_family == AF_ATMSVC;
-	seq_printf(seq, "%-6s%-4s%-4s%5ld ", dev->name, svc ? "SVC" : "PVC",
-	    !clip_vcc || clip_vcc->encap ? "LLC" : "NULL",
-	    (jiffies-(clip_vcc ? clip_vcc->last_use : entry->neigh->used))/HZ);
-
-	off = snprintf(buf, sizeof(buf) - 1, "%d.%d.%d.%d", NIPQUAD(entry->ip));
-	while (off < 16)
-		buf[off++] = ' ';
-	buf[off] = '\0';
-	seq_printf(seq, "%s", buf);
-
-	if (!clip_vcc) {
-		if (time_before(jiffies, entry->expires))
-			seq_printf(seq, "(resolving)\n");
-		else
-			seq_printf(seq, "(expired, ref %d)\n",
-				   atomic_read(&entry->neigh->refcnt));
-	} else if (!svc) {
-		seq_printf(seq, "%d.%d.%d\n", clip_vcc->vcc->dev->number,
-			   clip_vcc->vcc->vpi, clip_vcc->vcc->vci);
-	} else {
-		svc_addr(seq, &clip_vcc->vcc->remote);
-		seq_putc(seq, '\n');
-	}
-}
-
-#endif /* CONFIG_ATM_CLIP */
-
 struct vcc_state {
 	struct sock *sk;
 	int family;
@@ -485,156 +419,6 @@
 	.release	= vcc_seq_release,
 };
 
-#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-
-struct arp_state {
-	int bucket;
-  	struct neighbour *n;
-	struct clip_vcc *vcc;
-};
-  
-static void *arp_vcc_walk(struct arp_state *state,
-			  struct atmarp_entry *e, loff_t *l)
-{
-	struct clip_vcc *vcc = state->vcc;
-
-	if (!vcc)
-		vcc = e->vccs;
-	if (vcc == (void *)1) {
-		vcc = e->vccs;
-		--*l;
-  	}
-	for (; vcc; vcc = vcc->next) {
-		if (--*l < 0)
-			break;
-	}
-	state->vcc = vcc;
-	return (*l < 0) ? state : NULL;
-}
-  
-static void *arp_get_idx(struct arp_state *state, loff_t l)
-{
-	void *v = NULL;
-
-	for (; state->bucket <= NEIGH_HASHMASK; state->bucket++) {
-		for (; state->n; state->n = state->n->next) {
-			v = arp_vcc_walk(state, NEIGH2ENTRY(state->n), &l);
-			if (v)
-				goto done;
-  		}
-		state->n = clip_tbl_hook->hash_buckets[state->bucket + 1];
-	}
-done:
-	return v;
-}
-
-static void *arp_seq_start(struct seq_file *seq, loff_t *pos)
-{
-	struct arp_state *state = seq->private;
-	void *ret = (void *)1;
-
-	if (!clip_tbl_hook) {
-		state->bucket = -1;
-		goto out;
-	}
-
-	read_lock_bh(&clip_tbl_hook->lock);
-	state->bucket = 0;
-	state->n = clip_tbl_hook->hash_buckets[0];
-	state->vcc = (void *)1;
-	if (*pos)
-		ret = arp_get_idx(state, *pos);
-out:
-	return ret;
-}
-
-static void arp_seq_stop(struct seq_file *seq, void *v)
-{
-	struct arp_state *state = seq->private;
-
-	if (state->bucket != -1)
-		read_unlock_bh(&clip_tbl_hook->lock);
-}
-
-static void *arp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
-{
-	struct arp_state *state = seq->private;
-
-	v = arp_get_idx(state, 1);
-	*pos += !!PTR_ERR(v);
-	return v;
-}
-
-static int arp_seq_show(struct seq_file *seq, void *v)
-{
-	static char atm_arp_banner[] = 
-		"IPitf TypeEncp Idle IP address      ATM address\n";
-
-	if (v == (void *)1)
-		seq_puts(seq, atm_arp_banner);
-	else {
-		struct arp_state *state = seq->private;
-		struct neighbour *n = state->n;	
-		struct clip_vcc *vcc = state->vcc;
-
-		atmarp_info(seq, n->dev, NEIGH2ENTRY(n), vcc);
-	}
-  	return 0;
-}
-
-static struct seq_operations arp_seq_ops = {
-	.start	= arp_seq_start,
-	.next	= arp_seq_next,
-	.stop	= arp_seq_stop,
-	.show	= arp_seq_show,
-};
-
-static int arp_seq_open(struct inode *inode, struct file *file)
-{
-	struct arp_state *state;
-	struct seq_file *seq;
-	int rc = -EAGAIN;
-
-	if (!try_atm_clip_ops())
-		goto out;
-
-	state = kmalloc(sizeof(*state), GFP_KERNEL);
-	if (!state) {
-		rc = -ENOMEM;
-		goto out_put;
-	}
-
-	rc = seq_open(file, &arp_seq_ops);
-	if (rc)
-		goto out_kfree;
-
-	seq = file->private_data;
-	seq->private = state;
-out:
-	return rc;
-
-out_put:
-	module_put(atm_clip_ops->owner);
-out_kfree:
-	kfree(state);
-	goto out;
-}
-
-static int arp_seq_release(struct inode *inode, struct file *file)
-{
-	module_put(atm_clip_ops->owner);
-	return seq_release_private(inode, file);
-}
-
-static struct file_operations arp_seq_fops = {
-	.open		= arp_seq_open,
-	.read		= seq_read,
-	.llseek		= seq_lseek,
-	.release	= arp_seq_release,
-};
-
-#endif /* CONFIG_ATM_CLIP */
-
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
 
 struct lec_state {
@@ -936,9 +720,6 @@
 	{ .name = "pvc",	.proc_fops = &pvc_seq_fops },
 	{ .name = "svc",	.proc_fops = &svc_seq_fops },
 	{ .name = "vc",		.proc_fops = &vcc_seq_fops },
-#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-	{ .name = "arp",	.proc_fops = &arp_seq_fops },
-#endif
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
 	{ .name = "lec",	.proc_fops = &lec_seq_fops },
 #endif
