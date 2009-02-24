From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 05/06: make proc/net/ip* print names from foreign NFPROTO
Date: Tue, 24 Feb 2009 15:52:50 +0100 (MET)
Message-ID: <20090224145250.9789.36947.sendpatchset@x2.localnet>
References: <20090224145243.9789.60678.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34673 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756903AbZBXOww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 09:52:52 -0500
In-Reply-To: <20090224145243.9789.60678.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit eb132205ca2f7ad44d8c8c482815b6911200b6a0
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed Feb 18 16:42:19 2009 +0100

    netfilter: make proc/net/ip* print names from foreign NFPROTO
    
    When extensions were moved to the NFPROTO_UNSPEC wildcard in
    ab4f21e6fb1c09b13c4c3cb8357babe8223471bd, they disappeared from the
    procfs files.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index bfbf521..5baccfa 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -827,59 +827,143 @@ static const struct file_operations xt_table_ops = {
 	.release = seq_release_net,
 };
 
-static void *xt_match_seq_start(struct seq_file *seq, loff_t *pos)
+/*
+ * Traverse state for ip{,6}_{tables,matches} for helping crossing
+ * the multi-AF mutexes.
+ */
+struct nf_mttg_trav {
+	struct list_head *head, *curr;
+	uint8_t class, nfproto;
+};
+
+enum {
+	MTTG_TRAV_INIT,
+	MTTG_TRAV_NFP_UNSPEC,
+	MTTG_TRAV_NFP_SPEC,
+	MTTG_TRAV_DONE,
+};
+
+static void *xt_mttg_seq_next(struct seq_file *seq, void *v, loff_t *ppos,
+    bool is_target)
 {
-	struct proc_dir_entry *pde = (struct proc_dir_entry *)seq->private;
-	u_int16_t af = (unsigned long)pde->data;
+	static const uint8_t next_class[] = {
+		[MTTG_TRAV_NFP_UNSPEC] = MTTG_TRAV_NFP_SPEC,
+		[MTTG_TRAV_NFP_SPEC]   = MTTG_TRAV_DONE,
+	};
+	struct nf_mttg_trav *trav = seq->private;
+
+	switch (trav->class) {
+	case MTTG_TRAV_INIT:
+		trav->class = MTTG_TRAV_NFP_UNSPEC;
+		mutex_lock(&xt[NFPROTO_UNSPEC].mutex);
+		trav->head = trav->curr = is_target ?
+			&xt[NFPROTO_UNSPEC].target : &xt[NFPROTO_UNSPEC].match;
+ 		break;
+	case MTTG_TRAV_NFP_UNSPEC:
+		trav->curr = trav->curr->next;
+		if (trav->curr != trav->head)
+			break;
+		mutex_unlock(&xt[NFPROTO_UNSPEC].mutex);
+		mutex_lock(&xt[trav->nfproto].mutex);
+		trav->head = trav->curr = is_target ?
+			&xt[trav->nfproto].target : &xt[trav->nfproto].match;
+		trav->class = next_class[trav->class];
+		break;
+	case MTTG_TRAV_NFP_SPEC:
+		trav->curr = trav->curr->next;
+		if (trav->curr != trav->head)
+			break;
+		/* fallthru, _stop will unlock */
+	default:
+		return NULL;
+	}
 
-	mutex_lock(&xt[af].mutex);
-	return seq_list_start(&xt[af].match, *pos);
+	if (ppos != NULL)
+		++*ppos;
+	return trav;
 }
 
-static void *xt_match_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+static void *xt_mttg_seq_start(struct seq_file *seq, loff_t *pos,
+    bool is_target)
 {
-	struct proc_dir_entry *pde = (struct proc_dir_entry *)seq->private;
-	u_int16_t af = (unsigned long)pde->data;
+	struct nf_mttg_trav *trav = seq->private;
+	unsigned int j;
 
-	return seq_list_next(v, &xt[af].match, pos);
+	trav->class = MTTG_TRAV_INIT;
+	for (j = 0; j < *pos; ++j)
+		if (xt_mttg_seq_next(seq, NULL, NULL, is_target) == NULL)
+			return NULL;
+	return trav;
 }
 
-static void xt_match_seq_stop(struct seq_file *seq, void *v)
+static void xt_mttg_seq_stop(struct seq_file *seq, void *v)
 {
-	struct proc_dir_entry *pde = seq->private;
-	u_int16_t af = (unsigned long)pde->data;
+	struct nf_mttg_trav *trav = seq->private;
+
+	switch (trav->class) {
+	case MTTG_TRAV_NFP_UNSPEC:
+		mutex_unlock(&xt[NFPROTO_UNSPEC].mutex);
+		break;
+	case MTTG_TRAV_NFP_SPEC:
+		mutex_unlock(&xt[trav->nfproto].mutex);
+		break;
+	}
+}
 
-	mutex_unlock(&xt[af].mutex);
+static void *xt_match_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	return xt_mttg_seq_start(seq, pos, false);
 }
 
-static int xt_match_seq_show(struct seq_file *seq, void *v)
+static void *xt_match_seq_next(struct seq_file *seq, void *v, loff_t *ppos)
 {
-	struct xt_match *match = list_entry(v, struct xt_match, list);
+	return xt_mttg_seq_next(seq, v, ppos, false);
+}
 
-	if (strlen(match->name))
-		return seq_printf(seq, "%s\n", match->name);
-	else
-		return 0;
+static int xt_match_seq_show(struct seq_file *seq, void *v)
+{
+	const struct nf_mttg_trav *trav = seq->private;
+	const struct xt_match *match;
+
+	switch (trav->class) {
+	case MTTG_TRAV_NFP_UNSPEC:
+	case MTTG_TRAV_NFP_SPEC:
+		if (trav->curr == trav->head)
+			return 0;
+		match = list_entry(trav->curr, struct xt_match, list);
+		return (*match->name == '\0') ? 0 :
+		       seq_printf(seq, "%s\n", match->name);
+	}
+	return 0;
 }
 
 static const struct seq_operations xt_match_seq_ops = {
 	.start	= xt_match_seq_start,
 	.next	= xt_match_seq_next,
-	.stop	= xt_match_seq_stop,
+	.stop	= xt_mttg_seq_stop,
 	.show	= xt_match_seq_show,
 };
 
 static int xt_match_open(struct inode *inode, struct file *file)
 {
+	struct seq_file *seq;
+	struct nf_mttg_trav *trav;
 	int ret;
 
-	ret = seq_open(file, &xt_match_seq_ops);
-	if (!ret) {
-		struct seq_file *seq = file->private_data;
+	trav = kmalloc(sizeof(*trav), GFP_KERNEL);
+	if (trav == NULL)
+		return -ENOMEM;
 
-		seq->private = PDE(inode);
+	ret = seq_open(file, &xt_match_seq_ops);
+	if (ret < 0) {
+		kfree(trav);
+		return ret;
 	}
-	return ret;
+
+	seq = file->private_data;
+	seq->private = trav;
+	trav->nfproto = (unsigned long)PDE(inode)->data;
+	return 0;
 }
 
 static const struct file_operations xt_match_ops = {
@@ -887,62 +971,63 @@ static const struct file_operations xt_match_ops = {
 	.open	 = xt_match_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_private,
 };
 
 static void *xt_target_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	struct proc_dir_entry *pde = (struct proc_dir_entry *)seq->private;
-	u_int16_t af = (unsigned long)pde->data;
-
-	mutex_lock(&xt[af].mutex);
-	return seq_list_start(&xt[af].target, *pos);
+	return xt_mttg_seq_start(seq, pos, true);
 }
 
-static void *xt_target_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+static void *xt_target_seq_next(struct seq_file *seq, void *v, loff_t *ppos)
 {
-	struct proc_dir_entry *pde = (struct proc_dir_entry *)seq->private;
-	u_int16_t af = (unsigned long)pde->data;
-
-	return seq_list_next(v, &xt[af].target, pos);
-}
-
-static void xt_target_seq_stop(struct seq_file *seq, void *v)
-{
-	struct proc_dir_entry *pde = seq->private;
-	u_int16_t af = (unsigned long)pde->data;
-
-	mutex_unlock(&xt[af].mutex);
+	return xt_mttg_seq_next(seq, v, ppos, true);
 }
 
 static int xt_target_seq_show(struct seq_file *seq, void *v)
 {
-	struct xt_target *target = list_entry(v, struct xt_target, list);
-
-	if (strlen(target->name))
-		return seq_printf(seq, "%s\n", target->name);
-	else
-		return 0;
+	const struct nf_mttg_trav *trav = seq->private;
+	const struct xt_target *target;
+
+	switch (trav->class) {
+	case MTTG_TRAV_NFP_UNSPEC:
+	case MTTG_TRAV_NFP_SPEC:
+		if (trav->curr == trav->head)
+			return 0;
+		target = list_entry(trav->curr, struct xt_target, list);
+		return (*target->name == '\0') ? 0 :
+		       seq_printf(seq, "%s\n", target->name);
+	}
+	return 0;
 }
 
 static const struct seq_operations xt_target_seq_ops = {
 	.start	= xt_target_seq_start,
 	.next	= xt_target_seq_next,
-	.stop	= xt_target_seq_stop,
+	.stop	= xt_mttg_seq_stop,
 	.show	= xt_target_seq_show,
 };
 
 static int xt_target_open(struct inode *inode, struct file *file)
 {
+	struct seq_file *seq;
+	struct nf_mttg_trav *trav;
 	int ret;
 
-	ret = seq_open(file, &xt_target_seq_ops);
-	if (!ret) {
-		struct seq_file *seq = file->private_data;
+	trav = kmalloc(sizeof(*trav), GFP_KERNEL);
+	if (trav == NULL)
+		return -ENOMEM;
 
-		seq->private = PDE(inode);
+	ret = seq_open(file, &xt_target_seq_ops);
+	if (ret < 0) {
+		kfree(trav);
+		return ret;
 	}
-	return ret;
+
+	seq = file->private_data;
+	seq->private = trav;
+	trav->nfproto = (unsigned long)PDE(inode)->data;
+	return 0;
 }
 
 static const struct file_operations xt_target_ops = {
@@ -950,7 +1035,7 @@ static const struct file_operations xt_target_ops = {
 	.open	 = xt_target_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_private,
 };
 
 #define FORMAT_TABLES	"_tables_names"
