From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/4) convert irlan to seq_file interface
Date: Mon, 18 Aug 2003 12:27:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818122702.67e9162d.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
   "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert irlan /proc interface to safer seq_file library.


diff -Nru a/include/net/irda/irlan_filter.h b/include/net/irda/irlan_filter.h
--- a/include/net/irda/irlan_filter.h	Mon Aug 18 11:11:02 2003
+++ b/include/net/irda/irlan_filter.h	Mon Aug 18 11:11:02 2003
@@ -28,6 +28,6 @@
 void irlan_check_command_param(struct irlan_cb *self, char *param, 
 			       char *value);
 void handle_filter_request(struct irlan_cb *self, struct sk_buff *skb);
-int irlan_print_filter(int filter_type, char *buf);
+int irlan_print_filter(struct seq_file *seq, int filter_type);
 
 #endif /* IRLAN_FILTER_H */
diff -Nru a/net/irda/irlan/irlan_common.c b/net/irda/irlan/irlan_common.c
--- a/net/irda/irlan/irlan_common.c	Mon Aug 18 11:11:02 2003
+++ b/net/irda/irlan/irlan_common.c	Mon Aug 18 11:11:02 2003
@@ -31,6 +31,7 @@
 #include <linux/init.h>
 #include <linux/errno.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/rtnetlink.h>
@@ -86,6 +87,20 @@
 	"802.3",
 	"802.5"
 };
+
+extern struct proc_dir_entry *proc_irda;
+
+static int irlan_seq_open(struct inode *inode, struct file *file);
+
+static struct file_operations irlan_fops = {
+	.owner	 = THIS_MODULE,
+	.open    = irlan_seq_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release,
+};
+
+extern struct proc_dir_entry *proc_irda;
 #endif /* CONFIG_PROC_FS */
 
 static void __irlan_close(struct irlan_cb *self);
@@ -94,12 +109,6 @@
 				__u8 *value_array, __u16 value_len);
 void irlan_close_tsaps(struct irlan_cb *self);
 
-#ifdef CONFIG_PROC_FS
-static int irlan_proc_read(char *buf, char **start, off_t offset, int len);
-
-extern struct proc_dir_entry *proc_irda;
-#endif /* CONFIG_PROC_FS */
-
 /*
  * Function irlan_init (void)
  *
@@ -112,8 +121,17 @@
 	__u16 hints;
 
 	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+
 #ifdef CONFIG_PROC_FS
-	create_proc_info_entry("irlan", 0, proc_irda, irlan_proc_read);
+	{ struct proc_dir_entry *proc;
+	proc = create_proc_entry("irlan", 0, proc_irda);
+	if (!proc) {
+		printk(KERN_ERR "irlan_init: can't create /proc entry!\n");
+		return -ENODEV;
+	}
+
+	proc->proc_fops = &irlan_fops;
+	}
 #endif /* CONFIG_PROC_FS */
 
 	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
@@ -1050,55 +1068,104 @@
 }
 
 #ifdef CONFIG_PROC_FS
+#define IRLAN_PROC_START_TOKEN	((void *)1)
+
 /*
- * Function irlan_client_proc_read (buf, start, offset, len, unused)
- *
- *    Give some info to the /proc file system
+ * Start of reading /proc entries.
+ * Return entry at pos, 
+ *	or start_token to indicate print header line
+ *	or NULL if end of file
  */
-static int irlan_proc_read(char *buf, char **start, off_t offset, int len)
+static void *irlan_seq_start(struct seq_file *seq, loff_t *pos)
 {
+	int i = 1;
 	struct irlan_cb *self;
-     
-	len = 0;
-	
+
 	rcu_read_lock();
+	if (*pos == 0)
+		return IRLAN_PROC_START_TOKEN;
+
+	list_for_each_entry(self, &irlans, dev_list) {
+		if (*pos == i) 
+			return self;
+		++i;
+	}
+	return NULL;
+}
+
+/* Return entry after v, and increment pos */
+static void *irlan_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct list_head *nxt;
+
+	++*pos;
+	if (v == IRLAN_PROC_START_TOKEN) 
+		nxt = irlans.next;
+	else
+		nxt = ((struct irlan_cb *)v)->dev_list.next;
+
+	return (nxt == &irlans) ? NULL 
+		: list_entry(nxt, struct irlan_cb, dev_list);
+}
+
+/* End of reading /proc file */
+static void irlan_seq_stop(struct seq_file *seq, void *v)
+{
+	rcu_read_unlock();
+}
 
-	len += sprintf(buf+len, "IrLAN instances:\n");
-	
-	list_for_each_entry_rcu(self, &irlans, dev_list) {
 
-		ASSERT(self->magic == IRLAN_MAGIC, break;);
+/*
+ * Show one entry in /proc file.
+ */
+static int irlan_seq_show(struct seq_file *seq, void *v)
+{
+	if (v == IRLAN_PROC_START_TOKEN)
+		seq_puts(seq, "IrLAN instances:\n");
+	else {
+		struct irlan_cb *self = v;
 		
-		len += sprintf(buf+len, "ifname: %s,\n",
+		ASSERT(self != NULL, return -1;);
+		ASSERT(self->magic == IRLAN_MAGIC, return -1;);
+
+		seq_printf(seq,"ifname: %s,\n",
 			       self->dev->name);
-		len += sprintf(buf+len, "client state: %s, ",
+		seq_printf(seq,"client state: %s, ",
 			       irlan_state[ self->client.state]);
-		len += sprintf(buf+len, "provider state: %s,\n",
+		seq_printf(seq,"provider state: %s,\n",
 			       irlan_state[ self->provider.state]);
-		len += sprintf(buf+len, "saddr: %#08x, ",
+		seq_printf(seq,"saddr: %#08x, ",
 			       self->saddr);
-		len += sprintf(buf+len, "daddr: %#08x\n",
+		seq_printf(seq,"daddr: %#08x\n",
 			       self->daddr);
-		len += sprintf(buf+len, "version: %d.%d,\n",
+		seq_printf(seq,"version: %d.%d,\n",
 			       self->version[1], self->version[0]);
-		len += sprintf(buf+len, "access type: %s\n", 
+		seq_printf(seq,"access type: %s\n", 
 			       irlan_access[self->client.access_type]);
-		len += sprintf(buf+len, "media: %s\n", 
+		seq_printf(seq,"media: %s\n", 
 			       irlan_media[self->media]);
 		
-		len += sprintf(buf+len, "local filter:\n");
-		len += sprintf(buf+len, "remote filter: ");
-		len += irlan_print_filter(self->client.filter_type, 
-					  buf+len);
-			
-		len += sprintf(buf+len, "tx busy: %s\n", 
+		seq_printf(seq,"local filter:\n");
+		seq_printf(seq,"remote filter: ");
+		irlan_print_filter(seq, self->client.filter_type);
+		seq_printf(seq,"tx busy: %s\n", 
 			       netif_queue_stopped(self->dev) ? "TRUE" : "FALSE");
 			
-		len += sprintf(buf+len, "\n");
- 	} 
-	rcu_read_unlock();
+		seq_putc(seq,'\n');
+	}
+	return 0;
+}
 
-	return len;
+static struct seq_operations irlan_seq_ops = {
+	.start = irlan_seq_start,
+	.next  = irlan_seq_next,
+	.stop  = irlan_seq_stop,
+	.show  = irlan_seq_show,
+};
+
+static int irlan_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &irlan_seq_ops);
 }
 #endif
 
diff -Nru a/net/irda/irlan/irlan_filter.c b/net/irda/irlan/irlan_filter.c
--- a/net/irda/irlan/irlan_filter.c	Mon Aug 18 11:11:02 2003
+++ b/net/irda/irlan/irlan_filter.c	Mon Aug 18 11:11:02 2003
@@ -24,6 +24,7 @@
 
 #include <linux/skbuff.h>
 #include <linux/random.h>
+#include <linux/seq_file.h>
 
 #include <net/irda/irlan_common.h>
 
@@ -216,26 +217,24 @@
  *    Print status of filter. Used by /proc file system
  *
  */
-int irlan_print_filter(int filter_type, char *buf)
+#ifdef CONFIG_PROC_FS
+void irlan_print_filter(struct seq_file *seq, int filter_type)
 {
-	int len = 0;
-
 	if (filter_type & IRLAN_DIRECTED)
-		len += sprintf(buf+len, "%s", "DIRECTED ");
+		seq_printf(seq, "%s", "DIRECTED ");
 	if (filter_type & IRLAN_FUNCTIONAL)
-		len += sprintf(buf+len, "%s", "FUNCTIONAL ");
+		seq_printf(seq, "%s", "FUNCTIONAL ");
 	if (filter_type & IRLAN_GROUP)
-		len += sprintf(buf+len, "%s", "GROUP ");
+		seq_printf(seq, "%s", "GROUP ");
 	if (filter_type & IRLAN_MAC_FRAME)
-		len += sprintf(buf+len, "%s", "MAC_FRAME ");
+		seq_printf(seq, "%s", "MAC_FRAME ");
 	if (filter_type & IRLAN_MULTICAST)
-		len += sprintf(buf+len, "%s", "MULTICAST ");
+		seq_printf(seq, "%s", "MULTICAST ");
 	if (filter_type & IRLAN_BROADCAST)
-		len += sprintf(buf+len, "%s", "BROADCAST ");
+		seq_printf(seq, "%s", "BROADCAST ");
 	if (filter_type & IRLAN_IPX_SOCKET)
-		len += sprintf(buf+len, "%s", "IPX_SOCKET");
-
-	len += sprintf(buf+len, "\n");
+		seq_printf(seq, "%s", "IPX_SOCKET");
 
-	return len;
+	seq_putc(seq, '\n');
 }
+#endif
