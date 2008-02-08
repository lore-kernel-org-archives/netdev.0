From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/2][SCTP]: Convert sctp_dbg_objcnt to seq files.
Date: Fri, 08 Feb 2008 14:08:09 +0300
Message-ID: <47AC3819.3060507@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	lksctp-developers@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:41403 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758387AbYBHLIS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2008 06:08:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes the code use a good proc API and the text ~50 bytes shorter.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/sctp/objcnt.c |   85 +++++++++++++++++++++++++++-------------------------
 1 files changed, 44 insertions(+), 41 deletions(-)

diff --git a/net/sctp/objcnt.c b/net/sctp/objcnt.c
index 2cf6ad6..2b9ac00 100644
--- a/net/sctp/objcnt.c
+++ b/net/sctp/objcnt.c
@@ -80,61 +80,64 @@ static sctp_dbg_objcnt_entry_t sctp_dbg_objcnt[] = {
 /* Callback from procfs to read out objcount information.
  * Walk through the entries in the sctp_dbg_objcnt array, dumping
  * the raw object counts for each monitored type.
- *
- * This code was modified from similar code in route.c
  */
-static int sctp_dbg_objcnt_read(char *buffer, char **start, off_t offset,
-				int length, int *eof, void *data)
+static int sctp_objcnt_seq_show(struct seq_file *seq, void *v)
 {
-	int len = 0;
-	off_t pos = 0;
-	int entries;
 	int i;
 	char temp[128];
 
-	/* How many entries? */
-	entries = ARRAY_SIZE(sctp_dbg_objcnt);
-
-	/* Walk the entries and print out the debug information
-	 * for proc fs.
-	 */
-	for (i = 0; i < entries; i++) {
-		pos += 128;
-
-		/* Skip ahead. */
-		if (pos <= offset) {
-			len = 0;
-			continue;
-		}
-		/* Print out each entry. */
-		sprintf(temp, "%s: %d",
-			sctp_dbg_objcnt[i].label,
-			atomic_read(sctp_dbg_objcnt[i].counter));
-
-		sprintf(buffer + len, "%-127s\n", temp);
-		len += 128;
-		if (pos >= offset+length)
-			goto done;
-	}
-
-done:
-	*start = buffer + len - (pos - offset);
-	len = pos - offset;
-	if (len > length)
-		len = length;
-
-	return len;
+	i = (int)*(loff_t *)v;
+	sprintf(temp, "%s: %d", sctp_dbg_objcnt[i].label,
+				atomic_read(sctp_dbg_objcnt[i].counter));
+	seq_printf(seq, "%-127s\n", temp);
+	return 0;
+}
+
+static void *sctp_objcnt_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	return (*pos >= ARRAY_SIZE(sctp_dbg_objcnt)) ? NULL : (void *)pos;
+}
+
+static void sctp_objcnt_seq_stop(struct seq_file *seq, void *v)
+{
+}
+
+static void * sctp_objcnt_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	++*pos;
+	return (*pos >= ARRAY_SIZE(sctp_dbg_objcnt)) ? NULL : (void *)pos;
 }
 
+static const struct seq_operations sctp_objcnt_seq_ops = {
+	.start = sctp_objcnt_seq_start,
+	.next  = sctp_objcnt_seq_next,
+	.stop  = sctp_objcnt_seq_stop,
+	.show  = sctp_objcnt_seq_show,
+};
+
+static int sctp_objcnt_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &sctp_objcnt_seq_ops);
+}
+
+static const struct file_operations sctp_objcnt_ops = {
+	.open	 = sctp_objcnt_seq_open,
+	.read	 = seq_read,
+	.llseek	 = seq_lseek,
+	.release = seq_release,
+};
+
 /* Initialize the objcount in the proc filesystem.  */
 void sctp_dbg_objcnt_init(void)
 {
 	struct proc_dir_entry *ent;
-	ent = create_proc_read_entry("sctp_dbg_objcnt", 0, proc_net_sctp,
-			       sctp_dbg_objcnt_read, NULL);
+
+	ent = create_proc_entry("sctp_dbg_objcnt", 0, proc_net_sctp);
 	if (!ent)
 		printk(KERN_WARNING
 			"sctp_dbg_objcnt: Unable to create /proc entry.\n");
+	else
+		ent->proc_fops = &sctp_objcnt_ops;
 }
 
 /* Cleanup the objcount entry in the proc filesystem.  */
-- 
1.5.3.4

