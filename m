From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/2) Convert ROSE to seq_file
Date: Tue, 5 Aug 2003 14:46:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030805144622.100f208d.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The existing ROSE /proc interface has no module owner, and doesn't check for
bounds overflow.  Easier to just convert it to the seq_file wrapper functions.

This patch is against 2.6.0-test2 (offsets assume earlier patch).

diff -Nru a/include/net/rose.h b/include/net/rose.h
--- a/include/net/rose.h	Tue Aug  5 14:36:07 2003
+++ b/include/net/rose.h	Tue Aug  5 14:36:07 2003
@@ -140,6 +140,9 @@
 
 #define rose_sk(__sk) ((rose_cb *)(__sk)->sk_protinfo)
 
+/* Magic value indicating first entry in /proc (ie header) */
+#define ROSE_PROC_START ((void *) 1)
+
 /* af_rose.c */
 extern ax25_address rose_callsign;
 extern int  sysctl_rose_restart_request_timeout;
@@ -154,7 +157,7 @@
 extern int  sysctl_rose_window_size;
 extern int  rosecmp(rose_address *, rose_address *);
 extern int  rosecmpm(rose_address *, rose_address *, unsigned short);
-extern char *rose2asc(rose_address *);
+extern const char *rose2asc(const rose_address *);
 extern struct sock *rose_find_socket(unsigned int, struct rose_neigh *);
 extern void rose_kill_by_neigh(struct rose_neigh *);
 extern unsigned int rose_new_lci(struct rose_neigh *);
@@ -193,6 +196,9 @@
 
 /* rose_route.c */
 extern struct rose_neigh *rose_loopback_neigh;
+extern struct file_operations rose_neigh_fops;
+extern struct file_operations rose_nodes_fops;
+extern struct file_operations rose_routes_fops;
 
 extern int  rose_add_loopback_neigh(void);
 extern int  rose_add_loopback_node(rose_address *);
@@ -207,9 +213,6 @@
 extern int  rose_rt_ioctl(unsigned int, void *);
 extern void rose_link_failed(ax25_cb *, int);
 extern int  rose_route_frame(struct sk_buff *, ax25_cb *);
-extern int  rose_nodes_get_info(char *, char **, off_t, int);
-extern int  rose_neigh_get_info(char *, char **, off_t, int);
-extern int  rose_routes_get_info(char *, char **, off_t, int);
 extern void rose_rt_free(void);
 
 /* rose_subr.c */
diff -Nru a/net/rose/af_rose.c b/net/rose/af_rose.c
--- a/net/rose/af_rose.c	Tue Aug  5 14:36:07 2003
+++ b/net/rose/af_rose.c	Tue Aug  5 14:36:07 2003
@@ -39,6 +39,7 @@
 #include <linux/notifier.h>
 #include <net/rose.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <net/tcp.h>
 #include <net/ip.h>
 #include <net/arp.h>
@@ -56,8 +57,8 @@
 int sysctl_rose_maximum_vcs             = ROSE_DEFAULT_MAXVC;
 int sysctl_rose_window_size             = ROSE_DEFAULT_WINDOW_SIZE;
 
-static HLIST_HEAD(rose_list);
-static spinlock_t rose_list_lock = SPIN_LOCK_UNLOCKED;
+HLIST_HEAD(rose_list);
+spinlock_t rose_list_lock = SPIN_LOCK_UNLOCKED;
 
 static struct proto_ops rose_proto_ops;
 
@@ -66,7 +67,7 @@
 /*
  *	Convert a ROSE address into text.
  */
-char *rose2asc(rose_address *addr)
+const char *rose2asc(const rose_address *addr)
 {
 	static char buffer[11];
 
@@ -1332,29 +1333,57 @@
 	return 0;
 }
 
-static int rose_get_info(char *buffer, char **start, off_t offset, int length)
+#ifdef CONFIG_PROC_FS
+static void *rose_info_start(struct seq_file *seq, loff_t *pos)
 {
+	int i;
 	struct sock *s;
 	struct hlist_node *node;
-	struct net_device *dev;
-	const char *devname, *callsign;
-	int len = 0;
-	off_t pos = 0;
-	off_t begin = 0;
 
 	spin_lock_bh(&rose_list_lock);
+	if (*pos == 0)
+		return ROSE_PROC_START;
+	
+	i = 1;
+	sk_for_each(s, node, &rose_list) {
+		if (i == *pos)
+			return s;
+		++i;
+	}
+	return NULL;
+}
 
-	len += sprintf(buffer, "dest_addr  dest_call src_addr   src_call  dev   lci neigh st vs vr va   t  t1  t2  t3  hb    idle Snd-Q Rcv-Q inode\n");
+static void *rose_info_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	++*pos;
 
-	sk_for_each(s, node, &rose_list) {
+	return (v == ROSE_PROC_START) ? sk_head(&rose_list) 
+		: sk_next((struct sock *)v);
+}
+	
+static void rose_info_stop(struct seq_file *seq, void *v)
+{
+	spin_unlock_bh(&rose_list_lock);
+}
+
+static int rose_info_show(struct seq_file *seq, void *v)
+{
+	if (v == ROSE_PROC_START)
+		seq_puts(seq, 
+			 "dest_addr  dest_call src_addr   src_call  dev   lci neigh st vs vr va   t  t1  t2  t3  hb    idle Snd-Q Rcv-Q inode\n");
+
+	else {
+		struct sock *s = v;
 		rose_cb *rose = rose_sk(s);
+		const char *devname, *callsign;
+		const struct net_device *dev = rose->device;
 
-		if ((dev = rose->device) == NULL)
+		if (!dev)
 			devname = "???";
 		else
 			devname = dev->name;
-
-		len += sprintf(buffer + len, "%-10s %-9s ",
+		
+		seq_printf(seq, "%-10s %-9s ",
 			rose2asc(&rose->dest_addr),
 			ax2asc(&rose->dest_call));
 
@@ -1363,7 +1392,8 @@
 		else
 			callsign = ax2asc(&rose->source_call);
 
-		len += sprintf(buffer + len, "%-10s %-9s %-5s %3.3X %05d  %d  %d  %d  %d %3lu %3lu %3lu %3lu %3lu %3lu/%03lu %5d %5d %ld\n",
+		seq_printf(seq,
+			   "%-10s %-9s %-5s %3.3X %05d  %d  %d  %d  %d %3lu %3lu %3lu %3lu %3lu %3lu/%03lu %5d %5d %ld\n",
 			rose2asc(&rose->source_addr),
 			callsign,
 			devname,
@@ -1383,27 +1413,32 @@
 			atomic_read(&s->sk_wmem_alloc),
 			atomic_read(&s->sk_rmem_alloc),
 			s->sk_socket ? SOCK_INODE(s->sk_socket)->i_ino : 0L);
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
 	}
-	spin_unlock_bh(&rose_list_lock);
 
-	*start = buffer + (offset - begin);
-	len   -= (offset - begin);
+	return 0;
+}
 
-	if (len > length) len = length;
+static struct seq_operations rose_info_seqops = {
+	.start = rose_info_start,
+	.next = rose_info_next,
+	.stop = rose_info_stop,
+	.show = rose_info_show,
+};
 
-	return len;
+static int rose_info_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &rose_info_seqops);
 }
 
+static struct file_operations rose_info_fops = {
+	.owner = THIS_MODULE,
+	.open = rose_info_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = seq_release,
+};
+#endif	/* CONFIG_PROC_FS */
+
 static struct net_proto_family rose_family_ops = {
 	.family		=	PF_ROSE,
 	.create		=	rose_create,
@@ -1499,10 +1534,11 @@
 
 	rose_add_loopback_neigh();
 
-	proc_net_create("rose", 0, rose_get_info);
-	proc_net_create("rose_neigh", 0, rose_neigh_get_info);
-	proc_net_create("rose_nodes", 0, rose_nodes_get_info);
-	proc_net_create("rose_routes", 0, rose_routes_get_info);
+	proc_net_fops_create("rose", S_IRUGO, &rose_info_fops);
+	proc_net_fops_create("rose_neigh", S_IRUGO, &rose_neigh_fops);
+	proc_net_fops_create("rose_nodes", S_IRUGO, &rose_nodes_fops);
+	proc_net_fops_create("rose_routes", S_IRUGO, &rose_routes_fops);
+
 	return 0;
 }
 module_init(rose_proto_init);
diff -Nru a/net/rose/rose_route.c b/net/rose/rose_route.c
--- a/net/rose/rose_route.c	Tue Aug  5 14:36:07 2003
+++ b/net/rose/rose_route.c	Tue Aug  5 14:36:07 2003
@@ -35,12 +35,13 @@
 #include <linux/netfilter.h>
 #include <linux/init.h>
 #include <net/rose.h>
+#include <linux/seq_file.h>
 
 static unsigned int rose_neigh_no = 1;
 
 static struct rose_node  *rose_node_list;
 static spinlock_t rose_node_list_lock = SPIN_LOCK_UNLOCKED;
-static struct rose_neigh *rose_neigh_list;
+struct rose_neigh *rose_neigh_list;
 static spinlock_t rose_neigh_list_lock = SPIN_LOCK_UNLOCKED;
 static struct rose_route *rose_route_list;
 static spinlock_t rose_route_list_lock = SPIN_LOCK_UNLOCKED;
@@ -1066,165 +1067,248 @@
 	return res;
 }
 
-int rose_nodes_get_info(char *buffer, char **start, off_t offset, int length)
+#ifdef CONFIG_PROC_FS
+
+static void *rose_node_start(struct seq_file *seq, loff_t *pos)
 {
 	struct rose_node *rose_node;
-	int len     = 0;
-	off_t pos   = 0;
-	off_t begin = 0;
-	int i;
+	int i = 1;
 
 	spin_lock_bh(&rose_neigh_list_lock);
+	if (*pos == 0)
+		return ROSE_PROC_START;
+
+	for (rose_node = rose_node_list; rose_node && i < *pos; 
+	     rose_node = rose_node->next, ++i);
+
+	return (i == *pos) ? rose_node : NULL;
+}
 
-	len += sprintf(buffer, "address    mask n neigh neigh neigh\n");
+static void *rose_node_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	++*pos;
+	
+	return (v == ROSE_PROC_START) ? rose_node_list 
+		: ((struct rose_node *)v)->next;
+}
 
-	for (rose_node = rose_node_list; rose_node != NULL; rose_node = rose_node->next) {
+static void rose_node_stop(struct seq_file *seq, void *v)
+{
+	spin_unlock_bh(&rose_neigh_list_lock);
+}
+
+static int rose_node_show(struct seq_file *seq, void *v)
+{
+	int i;
+
+	if (v == ROSE_PROC_START)
+		seq_puts(seq, "address    mask n neigh neigh neigh\n");
+	else {
+		const struct rose_node *rose_node = v;
 		/* if (rose_node->loopback) {
-			len += sprintf(buffer + len, "%-10s %04d 1 loopback\n",
+			seq_printf(seq, "%-10s %04d 1 loopback\n",
 				rose2asc(&rose_node->address),
 				rose_node->mask);
 		} else { */
-			len += sprintf(buffer + len, "%-10s %04d %d",
+			seq_printf(seq, "%-10s %04d %d",
 				rose2asc(&rose_node->address),
 				rose_node->mask,
 				rose_node->count);
 
 			for (i = 0; i < rose_node->count; i++)
-				len += sprintf(buffer + len, " %05d",
+				seq_printf(seq, " %05d",
 					rose_node->neighbour[i]->number);
 
-			len += sprintf(buffer + len, "\n");
+			seq_puts(seq, "\n");
 		/* } */
+	}
+	return 0;
+}
 
-		pos = begin + len;
+static struct seq_operations rose_node_seqops = {
+	.start = rose_node_start,
+	.next = rose_node_next,
+	.stop = rose_node_stop,
+	.show = rose_node_show,
+};
+
+static int rose_nodes_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &rose_node_seqops);
+}
+
+struct file_operations rose_nodes_fops = {
+	.owner = THIS_MODULE,
+	.open = rose_nodes_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = seq_release,
+};
 
-		if (pos < offset) {
-			len   = 0;
-			begin = pos;
-		}
+static void *rose_neigh_start(struct seq_file *seq, loff_t *pos)
+{
+	struct rose_neigh *rose_neigh;
+	int i = 1;
 
-		if (pos > offset + length)
-			break;
-	}
-	spin_unlock_bh(&rose_neigh_list_lock);
+	spin_lock_bh(&rose_neigh_list_lock);
+	if (*pos == 0)
+		return ROSE_PROC_START;
 
-	*start = buffer + (offset - begin);
-	len   -= (offset - begin);
+	for (rose_neigh = rose_neigh_list; rose_neigh && i < *pos; 
+	     rose_neigh = rose_neigh->next, ++i);
 
-	if (len > length)
-		len = length;
+	return (i == *pos) ? rose_neigh : NULL;
+}
 
-	return len;
+static void *rose_neigh_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	++*pos;
+	
+	return (v == ROSE_PROC_START) ? rose_neigh_list 
+		: ((struct rose_neigh *)v)->next;
 }
 
-int rose_neigh_get_info(char *buffer, char **start, off_t offset, int length)
+static void rose_neigh_stop(struct seq_file *seq, void *v)
 {
-	struct rose_neigh *rose_neigh;
-	int len     = 0;
-	off_t pos   = 0;
-	off_t begin = 0;
-	int i;
+	spin_unlock_bh(&rose_neigh_list_lock);
+}
 
-	spin_lock_bh(&rose_neigh_list_lock);
+static int rose_neigh_show(struct seq_file *seq, void *v)
+{
+	int i;
 
-	len += sprintf(buffer, "addr  callsign  dev  count use mode restart  t0  tf digipeaters\n");
+	if (v == ROSE_PROC_START)
+		seq_puts(seq, 
+			 "addr  callsign  dev  count use mode restart  t0  tf digipeaters\n");
+	else {
+		struct rose_neigh *rose_neigh = v;
 
-	for (rose_neigh = rose_neigh_list; rose_neigh != NULL; rose_neigh = rose_neigh->next) {
 		/* if (!rose_neigh->loopback) { */
-			len += sprintf(buffer + len, "%05d %-9s %-4s   %3d %3d  %3s     %3s %3lu %3lu",
-				rose_neigh->number,
-				(rose_neigh->loopback) ? "RSLOOP-0" : ax2asc(&rose_neigh->callsign),
-				rose_neigh->dev ? rose_neigh->dev->name : "???",
-				rose_neigh->count,
-				rose_neigh->use,
-				(rose_neigh->dce_mode) ? "DCE" : "DTE",
-				(rose_neigh->restarted) ? "yes" : "no",
-				ax25_display_timer(&rose_neigh->t0timer) / HZ,
-				ax25_display_timer(&rose_neigh->ftimer)  / HZ);
-
-			if (rose_neigh->digipeat != NULL) {
-				for (i = 0; i < rose_neigh->digipeat->ndigi; i++)
-					len += sprintf(buffer + len, " %s", ax2asc(&rose_neigh->digipeat->calls[i]));
-			}
-
-			len += sprintf(buffer + len, "\n");
-
-			pos = begin + len;
-
-			if (pos < offset) {
-				len   = 0;
-				begin = pos;
-			}
+		seq_printf(seq, "%05d %-9s %-4s   %3d %3d  %3s     %3s %3lu %3lu",
+			   rose_neigh->number,
+			   (rose_neigh->loopback) ? "RSLOOP-0" : ax2asc(&rose_neigh->callsign),
+			   rose_neigh->dev ? rose_neigh->dev->name : "???",
+			   rose_neigh->count,
+			   rose_neigh->use,
+			   (rose_neigh->dce_mode) ? "DCE" : "DTE",
+			   (rose_neigh->restarted) ? "yes" : "no",
+			   ax25_display_timer(&rose_neigh->t0timer) / HZ,
+			   ax25_display_timer(&rose_neigh->ftimer)  / HZ);
+
+		if (rose_neigh->digipeat != NULL) {
+			for (i = 0; i < rose_neigh->digipeat->ndigi; i++)
+				seq_printf(seq, " %s", ax2asc(&rose_neigh->digipeat->calls[i]));
+		}
 
-			if (pos > offset + length)
-				break;
-		/* } */
+		seq_puts(seq, "\n");
 	}
+	return 0;
+}
 
-	spin_unlock_bh(&rose_neigh_list_lock);
-
-	*start = buffer + (offset - begin);
-	len   -= (offset - begin);
 
-	if (len > length)
-		len = length;
+static struct seq_operations rose_neigh_seqops = {
+	.start = rose_neigh_start,
+	.next = rose_neigh_next,
+	.stop = rose_neigh_stop,
+	.show = rose_neigh_show,
+};
 
-	return len;
+static int rose_neigh_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &rose_neigh_seqops);
 }
 
-int rose_routes_get_info(char *buffer, char **start, off_t offset, int length)
+struct file_operations rose_neigh_fops = {
+	.owner = THIS_MODULE,
+	.open = rose_neigh_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = seq_release,
+};
+
+
+static void *rose_route_start(struct seq_file *seq, loff_t *pos)
 {
 	struct rose_route *rose_route;
-	int len     = 0;
-	off_t pos   = 0;
-	off_t begin = 0;
+	int i = 1;
 
 	spin_lock_bh(&rose_route_list_lock);
+	if (*pos == 0)
+		return ROSE_PROC_START;
 
-	len += sprintf(buffer, "lci  address     callsign   neigh  <-> lci  address     callsign   neigh\n");
+	for (rose_route = rose_route_list; rose_route && i < *pos; 
+	     rose_route = rose_route->next, ++i);
 
-	for (rose_route = rose_route_list; rose_route != NULL; rose_route = rose_route->next) {
-		if (rose_route->neigh1 != NULL) {
-			len += sprintf(buffer + len, "%3.3X  %-10s  %-9s  %05d      ",
-				rose_route->lci1,
-				rose2asc(&rose_route->src_addr),
-				ax2asc(&rose_route->src_call),
-				rose_route->neigh1->number);
-		} else {
-			len += sprintf(buffer + len, "000  *           *          00000      ");
-		}
+	return (i == *pos) ? rose_route : NULL;
+}
+
+static void *rose_route_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	++*pos;
+	
+	return (v == ROSE_PROC_START) ? rose_route_list 
+		: ((struct rose_route *)v)->next;
+}
 
-		if (rose_route->neigh2 != NULL) {
-			len += sprintf(buffer + len, "%3.3X  %-10s  %-9s  %05d\n",
+static void rose_route_stop(struct seq_file *seq, void *v)
+{
+	spin_unlock_bh(&rose_route_list_lock);
+}
+
+static int rose_route_show(struct seq_file *seq, void *v)
+{
+	if (v == ROSE_PROC_START)
+		seq_puts(seq, 
+			 "lci  address     callsign   neigh  <-> lci  address     callsign   neigh\n");
+	else {
+		struct rose_route *rose_route = v;
+
+		if (rose_route->neigh1) 
+			seq_printf(seq,
+				   "%3.3X  %-10s  %-9s  %05d      ",
+				   rose_route->lci1,
+				   rose2asc(&rose_route->src_addr),
+				   ax2asc(&rose_route->src_call),
+				   rose_route->neigh1->number);
+		else 
+			seq_puts(seq, 
+				 "000  *           *          00000      ");
+
+		if (rose_route->neigh2) 
+			seq_printf(seq,
+				   "%3.3X  %-10s  %-9s  %05d\n",
 				rose_route->lci2,
 				rose2asc(&rose_route->dest_addr),
 				ax2asc(&rose_route->dest_call),
 				rose_route->neigh2->number);
-		} else {
-			len += sprintf(buffer + len, "000  *           *          00000\n");
-		}
-
-		pos = begin + len;
-
-		if (pos < offset) {
-			len   = 0;
-			begin = pos;
+		 else 
+			 seq_puts(seq,
+				  "000  *           *          00000\n");
 		}
+	return 0;
+}
 
-		if (pos > offset + length)
-			break;
-	}
-
-	spin_unlock_bh(&rose_route_list_lock);
-
-	*start = buffer + (offset - begin);
-	len   -= (offset - begin);
-
-	if (len > length)
-		len = length;
+static struct seq_operations rose_route_seqops = {
+	.start = rose_route_start,
+	.next = rose_route_next,
+	.stop = rose_route_stop,
+	.show = rose_route_show,
+};
+
+static int rose_route_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &rose_route_seqops);
+}
+
+struct file_operations rose_routes_fops = {
+	.owner = THIS_MODULE,
+	.open = rose_route_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = seq_release,
+};
 
-	return len;
-}
+#endif /* CONFIG_PROC_FS */
 
 /*
  *	Release all memory associated with ROSE routing structures.
