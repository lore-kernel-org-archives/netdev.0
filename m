From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][IBMVETH]: Use single_open instead of manual manipulations.
Date: Mon, 18 Feb 2008 13:55:10 +0300
Message-ID: <47B9640E.8000701@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Brian King <brking@linux.vnet.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:50530 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755417AbYBRK5U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2008 05:57:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code opening proc entry for each device makes the
same thing, as the single_open does, so remove the
unneeded code.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 57772be..bb31e09 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -1259,26 +1259,7 @@ static void ibmveth_proc_unregister_driver(void)
 	remove_proc_entry(IBMVETH_PROC_DIR, init_net.proc_net);
 }
 
-static void *ibmveth_seq_start(struct seq_file *seq, loff_t *pos)
-{
-	if (*pos == 0) {
-		return (void *)1;
-	} else {
-		return NULL;
-	}
-}
-
-static void *ibmveth_seq_next(struct seq_file *seq, void *v, loff_t *pos)
-{
-	++*pos;
-	return NULL;
-}
-
-static void ibmveth_seq_stop(struct seq_file *seq, void *v)
-{
-}
-
-static int ibmveth_seq_show(struct seq_file *seq, void *v)
+static int ibmveth_show(struct seq_file *seq, void *v)
 {
 	struct ibmveth_adapter *adapter = seq->private;
 	char *current_mac = ((char*) &adapter->netdev->dev_addr);
@@ -1302,27 +1283,10 @@ static int ibmveth_seq_show(struct seq_file *seq, void *v)
 
 	return 0;
 }
-static struct seq_operations ibmveth_seq_ops = {
-	.start = ibmveth_seq_start,
-	.next  = ibmveth_seq_next,
-	.stop  = ibmveth_seq_stop,
-	.show  = ibmveth_seq_show,
-};
 
 static int ibmveth_proc_open(struct inode *inode, struct file *file)
 {
-	struct seq_file *seq;
-	struct proc_dir_entry *proc;
-	int rc;
-
-	rc = seq_open(file, &ibmveth_seq_ops);
-	if (!rc) {
-		/* recover the pointer buried in proc_dir_entry data */
-		seq = file->private_data;
-		proc = PDE(inode);
-		seq->private = proc->data;
-	}
-	return rc;
+	return single_open(file, ibmveth_show, PDE(inode)->data);
 }
 
 static const struct file_operations ibmveth_proc_fops = {
@@ -1330,7 +1294,7 @@ static const struct file_operations ibmveth_proc_fops = {
 	.open    = ibmveth_proc_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release,
+	.release = single_release,
 };
 
 static void ibmveth_proc_register_adapter(struct ibmveth_adapter *adapter)
