From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (7/13) aarp convert to seq_file
Date: Fri, 29 Aug 2003 14:05:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829140533.5f5c5f4e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Schulist <jschlst@samba.org>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert aarp to seq_file interface.  
The output format is slightly changed:
	- address is printed in same format as /proc/net/atalk/interface
	- retry and last_sent are only shown for unresolved entries
	- times shown in seconds.hundreths rather than raw jiffies
	- column headers changed to same format as /proc/net/atalk/interface


diff -Nru a/net/appletalk/aarp.c b/net/appletalk/aarp.c
--- a/net/appletalk/aarp.c	Fri Aug 29 13:31:39 2003
+++ b/net/appletalk/aarp.c	Fri Aug 29 13:31:39 2003
@@ -37,6 +37,7 @@
 #include <linux/atalk.h>
 #include <linux/init.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 
 int sysctl_aarp_expiry_time = AARP_EXPIRY_TIME;
 int sysctl_aarp_tick_time = AARP_TICK_TIME;
@@ -888,96 +889,176 @@
 	write_unlock_bh(&aarp_lock);
 }
 
-/* Called from proc fs */
-static int aarp_get_info(char *buffer, char **start, off_t offset, int length)
+#ifdef CONFIG_PROC_FS
+struct aarp_iter_state {
+	int bucket;
+	struct aarp_entry **table;
+};
+
+/*
+ * Get the aarp entry that is in the chain described
+ * by the iterator. 
+ * If pos is set then skip till that index.
+ * pos = 1 is the first entry
+ */
+static struct aarp_entry *iter_next(struct aarp_iter_state *iter, loff_t *pos)
 {
-	/* we should dump all our AARP entries */
+	int ct = iter->bucket;
+	struct aarp_entry **table = iter->table;
+	loff_t off = 0;
 	struct aarp_entry *entry;
-	int ct, len = sprintf(buffer,
-			      "%-10.10s  %-10.10s%-18.18s%12.12s%12.12s "
-			      "xmit_count  status\n",
-			      "address", "device", "hw addr", "last_sent",
-			      "expires");
+	
+ rescan:
+	while(ct < AARP_HASH_SIZE) {
+		for (entry = table[ct]; entry; entry = entry->next) {
+			if (!pos || ++off == *pos) {
+				iter->table = table;
+				iter->bucket = ct;
+				return entry;
+			}
+		}
+		++ct;
+	}
+
+	if (table == resolved) {
+		ct = 0;
+		table = unresolved;
+		goto rescan;
+	}
+	if (table == unresolved) {
+		ct = 0;
+		table = proxies;
+		goto rescan;
+	}
+	return NULL;
+}
+
+static void *aarp_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	struct aarp_iter_state *iter = seq->private;
 
 	read_lock_bh(&aarp_lock);
+	iter->table     = resolved;
+	iter->bucket    = 0;
 
-	for (ct = 0; ct < AARP_HASH_SIZE; ct++) {
-		for (entry = resolved[ct]; entry; entry = entry->next) {
-			len += sprintf(buffer + len, "%6u:%-3u  ",
-				(unsigned int)ntohs(entry->target_addr.s_net),
-				(unsigned int)(entry->target_addr.s_node));
-			len += sprintf(buffer + len, "%-10.10s",
-				       entry->dev->name);
-			len += sprintf(buffer + len,
-				       "%2.2X:%2.2X:%2.2X:%2.2X:%2.2X:%2.2X",
-				       (int)(entry->hwaddr[0] & 0x000000FF),
-				       (int)(entry->hwaddr[1] & 0x000000FF),
-				       (int)(entry->hwaddr[2] & 0x000000FF),
-				       (int)(entry->hwaddr[3] & 0x000000FF),
-				       (int)(entry->hwaddr[4] & 0x000000FF),
-				       (int)(entry->hwaddr[5] & 0x000000FF));
-			len += sprintf(buffer + len, "%12lu ""%12lu ",
-				       (unsigned long)entry->last_sent,
-				       (unsigned long)entry->expires_at);
-			len += sprintf(buffer + len, "%10u",
-				       (unsigned int)entry->xmit_count);
+	return *pos ? iter_next(iter, pos) : ((void *)1);
+}
 
-			len += sprintf(buffer + len, "   resolved\n");
-		}
-	}
+static void *aarp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct aarp_entry *entry = v;
+	struct aarp_iter_state *iter = seq->private;
 
-	for (ct = 0; ct < AARP_HASH_SIZE; ct++) {
-		for (entry = unresolved[ct]; entry; entry = entry->next) {
-			len += sprintf(buffer + len, "%6u:%-3u  ",
-				(unsigned int)ntohs(entry->target_addr.s_net),
-				(unsigned int)(entry->target_addr.s_node));
-			len += sprintf(buffer + len, "%-10.10s",
-				       entry->dev->name);
-			len += sprintf(buffer + len,
-				       "%2.2X:%2.2X:%2.2X:%2.2X:%2.2X:%2.2X",
-				       (int)(entry->hwaddr[0] & 0x000000FF),
-				       (int)(entry->hwaddr[1] & 0x000000FF),
-				       (int)(entry->hwaddr[2] & 0x000000FF),
-				       (int)(entry->hwaddr[3] & 0x000000FF),
-				       (int)(entry->hwaddr[4] & 0x000000FF),
-				       (int)(entry->hwaddr[5] & 0x000000FF));
-			len += sprintf(buffer + len, "%12lu ""%12lu ",
-				       (unsigned long)entry->last_sent,
-				       (unsigned long)entry->expires_at);
-			len += sprintf(buffer + len, "%10u",
-				       (unsigned int)entry->xmit_count);
-			len += sprintf(buffer + len, " unresolved\n");
-		}
-	}
+	++*pos;
 
-	for (ct = 0; ct < AARP_HASH_SIZE; ct++) {
-		for (entry = proxies[ct]; entry; entry = entry->next) {
-			len += sprintf(buffer + len, "%6u:%-3u  ",
-				(unsigned int)ntohs(entry->target_addr.s_net),
-				(unsigned int)(entry->target_addr.s_node));
-			len += sprintf(buffer + len, "%-10.10s",
-				       entry->dev->name);
-			len += sprintf(buffer + len,
-				       "%2.2X:%2.2X:%2.2X:%2.2X:%2.2X:%2.2X",
-				       (int)(entry->hwaddr[0] & 0x000000FF),
-				       (int)(entry->hwaddr[1] & 0x000000FF),
-				       (int)(entry->hwaddr[2] & 0x000000FF),
-				       (int)(entry->hwaddr[3] & 0x000000FF),
-				       (int)(entry->hwaddr[4] & 0x000000FF),
-				       (int)(entry->hwaddr[5] & 0x000000FF));
-			len += sprintf(buffer + len, "%12lu ""%12lu ",
-				       (unsigned long)entry->last_sent,
-				       (unsigned long)entry->expires_at);
-			len += sprintf(buffer + len, "%10u",
-				       (unsigned int)entry->xmit_count);
-			len += sprintf(buffer + len, "      proxy\n");
-		}
+	/* first line after header */
+	if (v == ((void *)1)) 
+		entry = iter_next(iter, NULL);
+		
+	/* next entry in current bucket */
+	else if (entry->next)
+		entry = entry->next;
+
+	/* next bucket or table */
+	else {
+		++iter->bucket;
+		entry = iter_next(iter, NULL);
 	}
+	return entry;
+}
 
+static void aarp_seq_stop(struct seq_file *seq, void *v)
+{
 	read_unlock_bh(&aarp_lock);
-	return len;
 }
 
+static const char *dt2str(unsigned long ticks)
+{
+	static char buf[32];
+
+	sprintf(buf, "%ld.%02ld", ticks / HZ, ((ticks % HZ) * 100 ) / HZ);
+
+	return buf;
+}
+
+static int aarp_seq_show(struct seq_file *seq, void *v)
+{
+	struct aarp_iter_state *iter = seq->private;
+	struct aarp_entry *entry = v;
+	unsigned long now = jiffies;
+
+	if (v == ((void *)1))
+		seq_puts(seq, 
+			 "Address  Interface   Hardware Address"
+			 "   Expires LastSend  Retry Status\n");
+	else {
+		seq_printf(seq, "%04X:%02X  %-12s",
+			   ntohs(entry->target_addr.s_net),
+			   (unsigned int) entry->target_addr.s_node,
+			   entry->dev ? entry->dev->name : "????");
+		seq_printf(seq, "%02X:%02X:%02X:%02X:%02X:%02X",
+			   entry->hwaddr[0] & 0xFF,
+			   entry->hwaddr[1] & 0xFF,
+			   entry->hwaddr[2] & 0xFF,
+			   entry->hwaddr[3] & 0xFF,
+			   entry->hwaddr[4] & 0xFF,
+			   entry->hwaddr[5] & 0xFF);
+		seq_printf(seq, " %8s",
+			   dt2str((long)entry->expires_at - (long)now));
+		if (iter->table == unresolved)
+			seq_printf(seq, " %8s %6hu",
+				   dt2str(now - entry->last_sent),
+				   entry->xmit_count);
+		else
+			seq_puts(seq, "                ");
+		seq_printf(seq, " %s\n",
+			   (iter->table == resolved) ? "resolved"
+			   : (iter->table == unresolved) ? "unresolved"
+			   : (iter->table == proxies) ? "proxies"
+			   : "unknown");
+	}				 
+	return 0;
+}
+
+static struct seq_operations aarp_seq_ops = {
+	.start  = aarp_seq_start,
+	.next   = aarp_seq_next,
+	.stop   = aarp_seq_stop,
+	.show   = aarp_seq_show,
+};
+
+static int aarp_seq_open(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq;
+	int rc = -ENOMEM;
+	struct aarp_iter_state *s = kmalloc(sizeof(*s), GFP_KERNEL);
+       
+	if (!s)
+		goto out;
+
+	rc = seq_open(file, &aarp_seq_ops);
+	if (rc)
+		goto out_kfree;
+
+	seq	     = file->private_data;
+	seq->private = s;
+	memset(s, 0, sizeof(*s));
+out:
+	return rc;
+out_kfree:
+	kfree(s);
+	goto out;
+}
+
+struct file_operations atalk_seq_arp_fops = {
+	.owner		= THIS_MODULE,
+	.open           = aarp_seq_open,
+	.read           = seq_read,
+	.llseek         = seq_lseek,
+	.release	= seq_release_private,
+};
+#endif
+
 /* General module cleanup. Called from cleanup_module() in ddp.c. */
 void aarp_cleanup_module(void)
 {
@@ -990,7 +1071,7 @@
 #ifdef CONFIG_PROC_FS
 void aarp_register_proc_fs(void)
 {
-	proc_net_create("aarp", 0, aarp_get_info);
+	proc_net_fops_create("aarp", S_IRUGO, &atalk_seq_arp_fops);
 }
 
 void aarp_unregister_proc_fs(void)
