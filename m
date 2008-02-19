From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 1/5][SYSCTL]: Merge equal code in sysctl proc handlers.
Date: Tue, 19 Feb 2008 14:56:30 +0300
Message-ID: <47BAC3EE.9030302@openvz.org>
References: <47BAC38F.10100@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:57078 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751170AbYBSL4l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 06:56:41 -0500
In-Reply-To: <47BAC38F.10100@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ->read and ->write callbacks act in a very similar way, so
merge these paths to reduce the number of places to patch later.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 fs/proc/proc_sysctl.c |   50 ++++++++++--------------------------------------
 1 files changed, 11 insertions(+), 39 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 614c34b..5e31585 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -165,8 +165,8 @@ out:
 	return err;
 }
 
-static ssize_t proc_sys_read(struct file *filp, char __user *buf,
-				size_t count, loff_t *ppos)
+static ssize_t proc_sys_call_handler(struct file *filp, void __user *buf,
+		size_t count, loff_t *ppos, int write)
 {
 	struct dentry *dentry = filp->f_dentry;
 	struct ctl_table_header *head;
@@ -190,12 +190,12 @@ static ssize_t proc_sys_read(struct file *filp, char __user *buf,
 	 * and won't be until we finish.
 	 */
 	error = -EPERM;
-	if (sysctl_perm(table, MAY_READ))
+	if (sysctl_perm(table, write ? MAY_WRITE : MAY_READ))
 		goto out;
 
 	/* careful: calling conventions are nasty here */
 	res = count;
-	error = table->proc_handler(table, 0, filp, buf, &res, ppos);
+	error = table->proc_handler(table, write, filp, buf, &res, ppos);
 	if (!error)
 		error = res;
 out:
@@ -204,44 +204,16 @@ out:
 	return error;
 }
 
-static ssize_t proc_sys_write(struct file *filp, const char __user *buf,
+static ssize_t proc_sys_read(struct file *filp, char __user *buf,
 				size_t count, loff_t *ppos)
 {
-	struct dentry *dentry = filp->f_dentry;
-	struct ctl_table_header *head;
-	struct ctl_table *table;
-	ssize_t error;
-	size_t res;
-
-	table = do_proc_sys_lookup(dentry->d_parent, &dentry->d_name, &head);
-	/* Has the sysctl entry disappeared on us? */
-	error = -ENOENT;
-	if (!table)
-		goto out;
-
-	/* Has the sysctl entry been replaced by a directory? */
-	error = -EISDIR;
-	if (!table->proc_handler)
-		goto out;
-
-	/*
-	 * At this point we know that the sysctl was not unregistered
-	 * and won't be until we finish.
-	 */
-	error = -EPERM;
-	if (sysctl_perm(table, MAY_WRITE))
-		goto out;
-
-	/* careful: calling conventions are nasty here */
-	res = count;
-	error = table->proc_handler(table, 1, filp, (char __user *)buf,
-				    &res, ppos);
-	if (!error)
-		error = res;
-out:
-	sysctl_head_finish(head);
+	return proc_sys_call_handler(filp, (void __user *)buf, count, ppos, 0);
+}
 
-	return error;
+static ssize_t proc_sys_write(struct file *filp, const char __user *buf,
+				size_t count, loff_t *ppos)
+{
+	return proc_sys_call_handler(filp, (void __user *)buf, count, ppos, 1);
 }
 
 
-- 
1.5.3.4

