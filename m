From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 2/4][ATM]: Use seq_open/release_privade instead
 of manual manipulations.
Date: Fri, 29 Feb 2008 16:45:24 +0300
Message-ID: <47C80C74.4010309@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, chas@cmf.nrl.navy.mil
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:43898 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752209AbYB2Np4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 08:45:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

lec_seq_open/lec_seq_release and __vcc_seq_open/vcc_seq_release
do seq_open/release_private's job.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/atm/lec.c b/net/atm/lec.c
index 0e450d1..e2d800d 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -1169,32 +1169,7 @@ static const struct seq_operations lec_seq_ops = {
 
 static int lec_seq_open(struct inode *inode, struct file *file)
 {
-	struct lec_state *state;
-	struct seq_file *seq;
-	int rc = -EAGAIN;
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
-
-out_kfree:
-	kfree(state);
-	goto out;
-}
-
-static int lec_seq_release(struct inode *inode, struct file *file)
-{
-	return seq_release_private(inode, file);
+	return seq_open_private(file, &lec_seq_ops, sizeof(struct lec_state));
 }
 
 static const struct file_operations lec_seq_fops = {
@@ -1202,7 +1177,7 @@ static const struct file_operations lec_seq_fops = {
 	.open = lec_seq_open,
 	.read = seq_read,
 	.llseek = seq_lseek,
-	.release = lec_seq_release,
+	.release = seq_release_private,
 };
 #endif
 
diff --git a/net/atm/proc.c b/net/atm/proc.c
index e9693ae..b995b66 100644
--- a/net/atm/proc.c
+++ b/net/atm/proc.c
@@ -114,31 +114,13 @@ static int __vcc_seq_open(struct inode *inode, struct file *file,
 	int family, const struct seq_operations *ops)
 {
 	struct vcc_state *state;
-	struct seq_file *seq;
-	int rc = -ENOMEM;
 
-	state = kmalloc(sizeof(*state), GFP_KERNEL);
-	if (!state)
-		goto out;
-
-	rc = seq_open(file, ops);
-	if (rc)
-		goto out_kfree;
+	state = __seq_open_private(file, ops, sizeof(*state));
+	if (state == NULL)
+		return -ENOMEM;
 
 	state->family = family;
-
-	seq = file->private_data;
-	seq->private = state;
-out:
-	return rc;
-out_kfree:
-	kfree(state);
-	goto out;
-}
-
-static int vcc_seq_release(struct inode *inode, struct file *file)
-{
-	return seq_release_private(inode, file);
+	return 0;
 }
 
 static void *vcc_seq_start(struct seq_file *seq, loff_t *pos)
@@ -314,7 +296,7 @@ static const struct file_operations pvc_seq_fops = {
 	.open		= pvc_seq_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
-	.release	= vcc_seq_release,
+	.release	= seq_release_private,
 };
 
 static int vcc_seq_show(struct seq_file *seq, void *v)
@@ -348,7 +330,7 @@ static const struct file_operations vcc_seq_fops = {
 	.open		= vcc_seq_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
-	.release	= vcc_seq_release,
+	.release	= seq_release_private,
 };
 
 static int svc_seq_show(struct seq_file *seq, void *v)
@@ -383,7 +365,7 @@ static const struct file_operations svc_seq_fops = {
 	.open		= svc_seq_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
-	.release	= vcc_seq_release,
+	.release	= seq_release_private,
 };
 
 static ssize_t proc_dev_atm_read(struct file *file, char __user *buf,

