From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] convert ircomm to seq_file interface
Date: Mon, 18 Aug 2003 12:31:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818123142.6369fbff.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
   "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert ircomm /proc interface to seq_file.

Note: don't need spin_lock_irq because list is not ever locked
from inside interrupt context.

Last IRDA patch for today ;-)

diff -Nru a/net/irda/ircomm/ircomm_core.c b/net/irda/ircomm/ircomm_core.c
--- a/net/irda/ircomm/ircomm_core.c	Mon Aug 18 12:30:42 2003
+++ b/net/irda/ircomm/ircomm_core.c	Mon Aug 18 12:30:42 2003
@@ -33,6 +33,7 @@
 #include <linux/module.h>
 #include <linux/sched.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/init.h>
 
 #include <net/irda/irda.h>
@@ -53,7 +54,15 @@
 				      struct sk_buff *skb, int clen);
 
 #ifdef CONFIG_PROC_FS
-static int ircomm_proc_read(char *buf, char **start, off_t offset, int len);
+static int ircomm_seq_open(struct inode *inode, struct file *file);
+
+static struct file_operations ircomm_fops = {
+	.owner	 = THIS_MODULE,
+	.open    = ircomm_seq_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release,
+};
 
 extern struct proc_dir_entry *proc_irda;
 #endif /* CONFIG_PROC_FS */
@@ -69,7 +78,15 @@
 	}
 	
 #ifdef CONFIG_PROC_FS
-	create_proc_info_entry("ircomm", 0, proc_irda, ircomm_proc_read);
+	{ struct proc_dir_entry *proc;
+	  proc = create_proc_entry("ircomm", 0, proc_irda);
+	  if (!proc) {
+		printk(KERN_ERR "ircomm_init: can't create /proc entry!\n");
+		return -ENODEV;
+	  }
+
+	  proc->proc_fops = &ircomm_fops;
+	}
 #endif /* CONFIG_PROC_FS */
 	
 	MESSAGE("IrCOMM protocol (Dag Brattli)\n");
@@ -497,49 +514,80 @@
 
 #ifdef CONFIG_PROC_FS
 /*
- * Function ircomm_proc_read (buf, start, offset, len, unused)
- *
- *    
- *
+ * Start of reading /proc entries.
+ * Return entry at pos, or NULL if end of file
  */
-int ircomm_proc_read(char *buf, char **start, off_t offset, int len)
-{ 	
+static void *ircomm_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	int i = 0;
 	struct ircomm_cb *self;
-	unsigned long flags;
-	
-	len = 0;
 
-	spin_lock_irqsave(&ircomm->hb_spinlock, flags);
+	spin_lock(&ircomm->hb_spinlock);
+	for (self = (struct ircomm_cb *) hashbin_get_first(ircomm);
+	     self != NULL;
+	     self = (struct ircomm_cb *) hashbin_get_next(ircomm)) {
+		if (*pos == i) 
+			return self;
+		++i;
+	}
+	return NULL;
+}
 
-	self = (struct ircomm_cb *) hashbin_get_first(ircomm);
-	while (self != NULL) {
-		ASSERT(self->magic == IRCOMM_MAGIC, break;);
-
-		if(self->line < 0x10)
-			len += sprintf(buf+len, "ircomm%d", self->line);
-		else
-			len += sprintf(buf+len, "irlpt%d", self->line - 0x10);
-		len += sprintf(buf+len, " state: %s, ",
-			       ircomm_state[ self->state]);
-		len += sprintf(buf+len, 
-			       "slsap_sel: %#02x, dlsap_sel: %#02x, mode:",
-			       self->slsap_sel, self->dlsap_sel); 
-		if(self->service_type & IRCOMM_3_WIRE_RAW)
-			len += sprintf(buf+len, " 3-wire-raw");
-		if(self->service_type & IRCOMM_3_WIRE)
-			len += sprintf(buf+len, " 3-wire");
-		if(self->service_type & IRCOMM_9_WIRE)
-			len += sprintf(buf+len, " 9-wire");
-		if(self->service_type & IRCOMM_CENTRONICS)
-			len += sprintf(buf+len, " Centronics");
-		len += sprintf(buf+len, "\n");
-
-		self = (struct ircomm_cb *) hashbin_get_next(ircomm);
- 	} 
-	spin_unlock_irqrestore(&ircomm->hb_spinlock, flags);
+/* Return entry after v, and increment pos */
+static void *ircomm_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	++*pos;
+	return hashbin_get_next(ircomm);
+}
 
-	return len;
+/* End of reading /proc file */
+static void ircomm_seq_stop(struct seq_file *seq, void *v)
+{
+	spin_unlock(&ircomm->hb_spinlock);
 }
+
+
+/*
+ * Show one entry in /proc file.
+ */
+static int ircomm_seq_show(struct seq_file *seq, void *v)
+{
+	const struct ircomm_cb *self = v;
+
+	if(self->line < 0x10)
+		seq_printf(seq, "ircomm%d", self->line);
+	else
+		seq_printf(seq, "irlpt%d", self->line - 0x10);
+	seq_printf(seq, " state: %s, ", ircomm_state[self->state]);
+	seq_printf(seq, "slsap_sel: %#02x, dlsap_sel: %#02x, mode:",
+		   self->slsap_sel, self->dlsap_sel); 
+
+	if(self->service_type & IRCOMM_3_WIRE_RAW)
+		seq_puts(seq, " 3-wire-raw");
+	if(self->service_type & IRCOMM_3_WIRE)
+		seq_puts(seq, " 3-wire");
+	if(self->service_type & IRCOMM_9_WIRE)
+		seq_puts(seq, " 9-wire");
+	if(self->service_type & IRCOMM_CENTRONICS)
+		seq_puts(seq, " Centronics");
+	seq_putc(seq, '\n');
+
+
+	return 0;
+}
+
+static struct seq_operations ircomm_seq_ops = {
+	.start = ircomm_seq_start,
+	.next  = ircomm_seq_next,
+	.stop  = ircomm_seq_stop,
+	.show  = ircomm_seq_show,
+};
+
+static int ircomm_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &ircomm_seq_ops);
+}
+
 #endif /* CONFIG_PROC_FS */
 
 MODULE_AUTHOR("Dag Brattli <dag@brattli.net>");
