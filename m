From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (10/11) netrom - convert /proc interface to seq_file
Date: Wed, 13 Aug 2003 15:46:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030813154635.376df59b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeroen Vreeken <pe1rxq@amsat.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert netrom /proc interface to seq_file.

diff -Nru a/include/net/netrom.h b/include/net/netrom.h
--- a/include/net/netrom.h	Wed Aug 13 13:54:19 2003
+++ b/include/net/netrom.h	Wed Aug 13 13:54:19 2003
@@ -209,8 +209,8 @@
 extern int  nr_rt_ioctl(unsigned int, void *);
 extern void nr_link_failed(ax25_cb *, int);
 extern int  nr_route_frame(struct sk_buff *, ax25_cb *);
-extern int  nr_nodes_get_info(char *, char **, off_t, int);
-extern int  nr_neigh_get_info(char *, char **, off_t, int);
+extern struct file_operations nr_nodes_fops;
+extern struct file_operations nr_neigh_fops;
 extern void nr_rt_free(void);
 
 /* nr_subr.c */
diff -Nru a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
--- a/net/netrom/af_netrom.c	Wed Aug 13 13:54:19 2003
+++ b/net/netrom/af_netrom.c	Wed Aug 13 13:54:19 2003
@@ -36,6 +36,7 @@
 #include <linux/notifier.h>
 #include <net/netrom.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <net/ip.h>
 #include <net/tcp.h>
 #include <net/arp.h>
@@ -1234,22 +1235,54 @@
 	return 0;
 }
 
-static int nr_get_info(char *buffer, char **start, off_t offset, int length)
+#ifdef CONFIG_PROC_FS
+
+/* Marker for header entry */
+#define NETROM_PROC_START	((void *)1)
+static void *nr_info_start(struct seq_file *seq, loff_t *pos)
 {
 	struct sock *s;
 	struct hlist_node *node;
+	int i = 1;
+
+	spin_lock_bh(&nr_list_lock);
+	if (*pos == 0)
+		return NETROM_PROC_START;
+
+	sk_for_each(s, node, &nr_list) {
+		if (i == *pos)
+			return s;
+		++i;
+	}
+	return NULL;
+}
+
+static void *nr_info_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	++*pos;
+
+	return (v == NETROM_PROC_START) ? sk_head(&nr_list) 
+		: sk_next((struct sock *)v);
+}
+	
+static void nr_info_stop(struct seq_file *seq, void *v)
+{
+	spin_unlock_bh(&nr_list_lock);
+}
+
+static int nr_info_show(struct seq_file *seq, void *v)
+{
+	struct sock *s = v;
 	struct net_device *dev;
+	nr_cb *nr;
 	const char *devname;
-	int len = 0;
-	off_t pos = 0;
-	off_t begin = 0;
 
-	spin_lock_bh(&nr_list_lock);
+	if (v == NETROM_PROC_START)
+		seq_puts(seq,
+"user_addr dest_node src_node  dev    my  your  st  vs  vr  va    t1     t2     t4      idle   n2  wnd Snd-Q Rcv-Q inode\n");
 
-	len += sprintf(buffer, "user_addr dest_node src_node  dev    my  your  st  vs  vr  va    t1     t2     t4      idle   n2  wnd Snd-Q Rcv-Q inode\n");
+	else {
 
-	sk_for_each(s, node, &nr_list) {
-		nr_cb *nr;
 		bh_lock_sock(s);
 		nr = nr_sk(s);
 
@@ -1258,11 +1291,10 @@
 		else
 			devname = dev->name;
 
-		len += sprintf(buffer + len, "%-9s ",
-			ax2asc(&nr->user_addr));
-		len += sprintf(buffer + len, "%-9s ",
-			ax2asc(&nr->dest_addr));
-		len += sprintf(buffer + len, "%-9s %-3s  %02X/%02X %02X/%02X %2d %3d %3d %3d %3lu/%03lu %2lu/%02lu %3lu/%03lu %3lu/%03lu %2d/%02d %3d %5d %5d %ld\n",
+		seq_printf(seq, "%-9s ", ax2asc(&nr->user_addr));
+		seq_printf(seq, "%-9s ", ax2asc(&nr->dest_addr));
+		seq_printf(seq, 
+"%-9s %-3s  %02X/%02X %02X/%02X %2d %3d %3d %3d %3lu/%03lu %2lu/%02lu %3lu/%03lu %3lu/%03lu %2d/%02d %3d %5d %5d %ld\n",
 			ax2asc(&nr->source_addr),
 			devname,
 			nr->my_index,
@@ -1288,27 +1320,31 @@
 			atomic_read(&s->sk_rmem_alloc),
 			s->sk_socket ? SOCK_INODE(s->sk_socket)->i_ino : 0L);
 
-		pos = begin + len;
-
-		if (pos < offset) {
-			len   = 0;
-			begin = pos;
-		}
 		bh_unlock_sock(s);
-		if (pos > offset + length)
-			break;
 	}
+	return 0;
+}
 
-	spin_unlock_bh(&nr_list_lock);
-
-	*start = buffer + (offset - begin);
-	len   -= (offset - begin);
-
-	if (len > length)
-		len = length;
-
-	return len;
+static struct seq_operations nr_info_seqops = {
+	.start = nr_info_start,
+	.next = nr_info_next,
+	.stop = nr_info_stop,
+	.show = nr_info_show,
+};
+ 
+static int nr_info_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &nr_info_seqops);
 }
+ 
+static struct file_operations nr_info_fops = {
+	.owner = THIS_MODULE,
+	.open = nr_info_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = seq_release,
+};
+#endif	/* CONFIG_PROC_FS */
 
 static struct net_proto_family nr_family_ops = {
 	.family		=	PF_NETROM,
@@ -1399,10 +1435,11 @@
 
 	nr_loopback_init();
 
-	proc_net_create("nr", 0, nr_get_info);
-	proc_net_create("nr_neigh", 0, nr_neigh_get_info);
-	proc_net_create("nr_nodes", 0, nr_nodes_get_info);
+	proc_net_fops_create("nr", S_IRUGO, &nr_info_fops);
+	proc_net_fops_create("nr_neigh", S_IRUGO, &nr_neigh_fops);
+	proc_net_fops_create("nr_nodes", S_IRUGO, &nr_nodes_fops);
 	return 0;
+
  fail:
 	while (--i >= 0)
 		unregister_netdev(dev_nr[i]);
diff -Nru a/net/netrom/nr_route.c b/net/netrom/nr_route.c
--- a/net/netrom/nr_route.c	Wed Aug 13 13:54:19 2003
+++ b/net/netrom/nr_route.c	Wed Aug 13 13:54:19 2003
@@ -36,6 +36,7 @@
 #include <linux/init.h>
 #include <linux/spinlock.h>
 #include <net/netrom.h>
+#include <linux/seq_file.h>
 
 static unsigned int nr_neigh_no = 1;
 
@@ -839,70 +840,138 @@
 	return ret;
 }
 
-int nr_nodes_get_info(char *buffer, char **start, off_t offset, int length)
+#ifdef CONFIG_PROC_FS
+#define NETROM_PROC_START	((void *) 1)
+
+static void *nr_node_start(struct seq_file *seq, loff_t *pos)
 {
 	struct nr_node *nr_node;
 	struct hlist_node *node;
-	int len     = 0;
-	off_t pos   = 0;
-	off_t begin = 0;
-	int i;
-
-	spin_lock_bh(&nr_node_list_lock);
-	len += sprintf(buffer, "callsign  mnemonic w n qual obs neigh qual obs neigh qual obs neigh\n");
+	int i = 1;
+ 
+ 	spin_lock_bh(&nr_node_list_lock);
+	if (*pos == 0)
+		return NETROM_PROC_START;
 
 	nr_node_for_each(nr_node, node, &nr_node_list) {
+		if (i == *pos)
+			return nr_node;
+		++i;
+	}
+
+	return NULL;
+}
+
+static void *nr_node_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct hlist_node *node;
+	++*pos;
+	
+	node = (v == NETROM_PROC_START)  
+		? nr_node_list.first
+		: ((struct nr_node *)v)->node_node.next;
+
+	return hlist_entry(node, struct nr_node, node_node);
+}
+
+static void nr_node_stop(struct seq_file *seq, void *v)
+{
+	spin_unlock_bh(&nr_node_list_lock);
+}
+
+static int nr_node_show(struct seq_file *seq, void *v)
+{
+	int i;
+
+	if (v == NETROM_PROC_START)
+		seq_puts(seq,
+			 "callsign  mnemonic w n qual obs neigh qual obs neigh qual obs neigh\n");
+	else {
+		struct nr_node *nr_node = v;
 		nr_node_lock(nr_node);
-		len += sprintf(buffer + len, "%-9s %-7s  %d %d",
+		seq_printf(seq, "%-9s %-7s  %d %d",
 			ax2asc(&nr_node->callsign),
 			(nr_node->mnemonic[0] == '\0') ? "*" : nr_node->mnemonic,
 			nr_node->which + 1,
 			nr_node->count);
 
 		for (i = 0; i < nr_node->count; i++) {
-			len += sprintf(buffer + len, "  %3d   %d %05d",
+			seq_printf(seq, "  %3d   %d %05d",
 				nr_node->routes[i].quality,
 				nr_node->routes[i].obs_count,
 				nr_node->routes[i].neighbour->number);
 		}
 		nr_node_unlock(nr_node);
 
-		len += sprintf(buffer + len, "\n");
+		seq_puts(seq, "\n");
+	}
+	return 0;
+}
 
-		pos = begin + len;
+static struct seq_operations nr_node_seqops = {
+	.start = nr_node_start,
+	.next = nr_node_next,
+	.stop = nr_node_stop,
+	.show = nr_node_show,
+};
+
+static int nr_node_info_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &nr_node_seqops);
+}
+
+struct file_operations nr_nodes_fops = {
+	.owner = THIS_MODULE,
+	.open = nr_node_info_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = seq_release,
+};
 
-		if (pos < offset) {
-			len   = 0;
-			begin = pos;
-		}
+static void *nr_neigh_start(struct seq_file *seq, loff_t *pos)
+{
+	struct nr_neigh *nr_neigh;
+	struct hlist_node *node;
+	int i = 1;
 
-		if (pos > offset + length)
-			break;
+	spin_lock_bh(&nr_neigh_list_lock);
+	if (*pos == 0)
+		return NETROM_PROC_START;
+
+	nr_neigh_for_each(nr_neigh, node, &nr_neigh_list) {
+		if (i == *pos)
+			return nr_neigh;
 	}
-	spin_unlock_bh(&nr_node_list_lock);
+	return NULL;
+}
 
-	*start = buffer + (offset - begin);
-	len   -= (offset - begin);
+static void *nr_neigh_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct hlist_node *node;
+	++*pos;
+	
+	node = (v == NETROM_PROC_START)  
+		? nr_neigh_list.first
+		: ((struct nr_neigh *)v)->neigh_node.next;
 
-	if (len > length) len = length;
+	return hlist_entry(node, struct nr_neigh, neigh_node);
+}
 
-	return len;
+static void nr_neigh_stop(struct seq_file *seq, void *v)
+{
+	spin_unlock_bh(&nr_neigh_list_lock);
 }
 
-int nr_neigh_get_info(char *buffer, char **start, off_t offset, int length)
+static int nr_neigh_show(struct seq_file *seq, void *v)
 {
-	struct nr_neigh *nr_neigh;
-	struct hlist_node *node;
-	int len     = 0;
-	off_t pos   = 0;
-	off_t begin = 0;
 	int i;
 
-	spin_lock_bh(&nr_neigh_list_lock);
-	len += sprintf(buffer, "addr  callsign  dev  qual lock count failed digipeaters\n");
+	if (v == NETROM_PROC_START)
+		seq_puts(seq, "addr  callsign  dev  qual lock count failed digipeaters\n");
+	else {
+		struct nr_neigh *nr_neigh = v;
 
-	nr_neigh_for_each(nr_neigh, node, &nr_neigh_list) {
-		len += sprintf(buffer + len, "%05d %-9s %-4s  %3d    %d   %3d    %3d",
+		seq_printf(seq, "%05d %-9s %-4s  %3d    %d   %3d    %3d",
 			nr_neigh->number,
 			ax2asc(&nr_neigh->callsign),
 			nr_neigh->dev ? nr_neigh->dev->name : "???",
@@ -913,31 +982,36 @@
 
 		if (nr_neigh->digipeat != NULL) {
 			for (i = 0; i < nr_neigh->digipeat->ndigi; i++)
-				len += sprintf(buffer + len, " %s", ax2asc(&nr_neigh->digipeat->calls[i]));
+				seq_printf(seq, " %s", 
+					   ax2asc(&nr_neigh->digipeat->calls[i]));
 		}
 
-		len += sprintf(buffer + len, "\n");
-
-		pos = begin + len;
-
-		if (pos < offset) {
-			len   = 0;
-			begin = pos;
-		}
-
-		if (pos > offset + length)
-			break;
+		seq_puts(seq, "\n");
 	}
+	return 0;
+}
 
-	spin_unlock_bh(&nr_neigh_list_lock);
-
-	*start = buffer + (offset - begin);
-	len   -= (offset - begin);
-
-	if (len > length) len = length;
+static struct seq_operations nr_neigh_seqops = {
+	.start = nr_neigh_start,
+	.next = nr_neigh_next,
+	.stop = nr_neigh_stop,
+	.show = nr_neigh_show,
+};
+
+static int nr_neigh_info_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &nr_neigh_seqops);
+}
+
+struct file_operations nr_neigh_fops = {
+	.owner = THIS_MODULE,
+	.open = nr_neigh_info_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = seq_release,
+};
 
-	return len;
-}
+#endif
 
 /*
  *	Free all memory associated with the nodes and routes lists.
