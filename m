From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] convert /proc/net/dev_mcast to seq_file
Date: Mon, 12 Jan 2004 13:50:33 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040112135033.3b08f0e9.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert /proc/net/dev_mcast for 2.6 so it will work with large number of interfaces.

diff -Nru a/net/core/dev_mcast.c b/net/core/dev_mcast.c
--- a/net/core/dev_mcast.c	Mon Jan 12 13:51:34 2004
+++ b/net/core/dev_mcast.c	Mon Jan 12 13:51:34 2004
@@ -41,6 +41,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/init.h>
 #include <net/ip.h>
 #include <net/route.h>
@@ -219,59 +220,78 @@
 }
 
 #ifdef CONFIG_PROC_FS
-static int dev_mc_read_proc(char *buffer, char **start, off_t offset,
-			    int length, int *eof, void *data)
+static void *dev_mc_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	off_t pos = 0, begin = 0;
-	struct dev_mc_list *m;
-	int len = 0;
 	struct net_device *dev;
+	loff_t off = 0;
 
 	read_lock(&dev_base_lock);
 	for (dev = dev_base; dev; dev = dev->next) {
-		spin_lock_bh(&dev->xmit_lock);
-		for (m = dev->mc_list; m; m = m->next) {
-			int i;
-
-			len += sprintf(buffer+len,"%-4d %-15s %-5d %-5d ", dev->ifindex,
-				       dev->name, m->dmi_users, m->dmi_gusers);
-
-			for (i = 0; i < m->dmi_addrlen; i++)
-				len += sprintf(buffer+len, "%02x", m->dmi_addr[i]);
-
-			len += sprintf(buffer+len, "\n");
-
-			pos = begin + len;
-			if (pos < offset) {
-				len = 0;
-				begin = pos;
-			}
-			if (pos > offset + length) {
-				spin_unlock_bh(&dev->xmit_lock);
-				goto done;
-			}
-		}
-		spin_unlock_bh(&dev->xmit_lock);
+		if (off++ == *pos) 
+			return dev;
 	}
-	*eof = 1;
+	return NULL;
+}
 
-done:
+static void *dev_mc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct net_device *dev = v;
+	++*pos;
+	return dev->next;
+}
+
+static void dev_mc_seq_stop(struct seq_file *seq, void *v)
+{
 	read_unlock(&dev_base_lock);
-	*start = buffer + (offset - begin);
-	len -= (offset - begin);
-	if (len > length)
-		len = length;
-	if (len < 0)
-		len = 0;
-	return len;
 }
+
+
+static int dev_mc_seq_show(struct seq_file *seq, void *v)
+{
+	struct dev_mc_list *m;
+	struct net_device *dev = v;
+
+	spin_lock_bh(&dev->xmit_lock);
+	for (m = dev->mc_list; m; m = m->next) {
+		int i;
+
+		seq_printf(seq, "%-4d %-15s %-5d %-5d ", dev->ifindex,
+			   dev->name, m->dmi_users, m->dmi_gusers);
+
+		for (i = 0; i < m->dmi_addrlen; i++)
+			seq_printf(seq, "%02x", m->dmi_addr[i]);
+
+		seq_putc(seq, '\n');
+	}
+	spin_unlock_bh(&dev->xmit_lock);
+	return 0;
+}
+
+static struct seq_operations dev_mc_seq_ops = {
+	.start = dev_mc_seq_start,
+	.next  = dev_mc_seq_next,
+	.stop  = dev_mc_seq_stop,
+	.show  = dev_mc_seq_show,
+};
+
+static int dev_mc_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &dev_mc_seq_ops);
+}
+
+static struct file_operations dev_mc_seq_fops = {
+	.owner	 = THIS_MODULE,
+	.open    = dev_mc_seq_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release,
+};
+
 #endif
 
 void __init dev_mcast_init(void)
 {
-#ifdef CONFIG_PROC_FS
-	create_proc_read_entry("net/dev_mcast", 0, 0, dev_mc_read_proc, NULL);
-#endif
+	proc_net_fops_create("dev_mcast", 0, &dev_mc_seq_fops);
 }
 
 EXPORT_SYMBOL(dev_mc_add);
