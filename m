From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT][PATCH] ax25 using seq_file
Date: Fri, 22 Aug 2003 13:15:47 -0700
Sender: linux-hams-owner@vger.kernel.org
Message-ID: <20030822131547.0d95fb16.shemminger@osdl.org>
References: <20030812194653.A28977@jeroen.pe1rxq.ampr.org>
	<20030812135655.7334887b.shemminger@osdl.org>
	<20030812230951.E28977@jeroen.pe1rxq.ampr.org>
	<20030812153901.6e700dcb.shemminger@osdl.org>
	<20030813010301.K28977@jeroen.pe1rxq.ampr.org>
	<20030812172151.7de0c950.shemminger@osdl.org>
	<20030813031159.6c6c9629.davem@redhat.com>
	<20030813173446.A2604@jeroen.pe1rxq.ampr.org>
	<20030813084252.7b667fb8.davem@redhat.com>
	<20030820204518.C5568@jeroen.pe1rxq.ampr.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@redhat.com>, linux-hams@vger.kernel.org,
	ralf@linux-mips.org, netdev@oss.sgi.com
Return-path: <linux-hams-owner@vger.kernel.org>
To: Jeroen Vreeken <pe1rxq@amsat.org>
In-Reply-To: <20030820204518.C5568@jeroen.pe1rxq.ampr.org>
List-Id: netdev.vger.kernel.org

Convert AX25 to use the seq_file interface for it's /proc hook.

Jeroen could you test this with real hardware, since without hardware
the table always comes up empty which is not a good enough test.

diff -Nru a/include/net/ax25.h b/include/net/ax25.h
--- a/include/net/ax25.h	Fri Aug 22 08:21:10 2003
+++ b/include/net/ax25.h	Fri Aug 22 08:21:10 2003
@@ -314,7 +314,7 @@
 /* ax25_route.c */
 extern void ax25_rt_device_down(struct net_device *);
 extern int  ax25_rt_ioctl(unsigned int, void *);
-extern int  ax25_rt_get_info(char *, char **, off_t, int);
+extern struct file_operations ax25_route_fops;
 extern int  ax25_rt_autobind(ax25_cb *, ax25_address *);
 extern ax25_route *ax25_rt_find_route(ax25_route *, ax25_address *,
 	struct net_device *);
@@ -373,7 +373,7 @@
 extern int  ax25_uid_policy;
 extern ax25_address *ax25_findbyuid(uid_t);
 extern int  ax25_uid_ioctl(int, struct sockaddr_ax25 *);
-extern int  ax25_uid_get_info(char *, char **, off_t, int);
+extern struct file_operations ax25_uid_fops;
 extern void ax25_uid_free(void);
 
 /* sysctl_net_ax25.c */
diff -Nru a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
--- a/net/ax25/af_ax25.c	Fri Aug 22 08:21:10 2003
+++ b/net/ax25/af_ax25.c	Fri Aug 22 08:21:10 2003
@@ -1842,81 +1842,107 @@
 	return res;
 }
 
-static int ax25_get_info(char *buffer, char **start, off_t offset, int length)
+#ifdef CONFIG_PROC_FS
+
+static void *ax25_info_start(struct seq_file *seq, loff_t *pos)
 {
-	ax25_cb *ax25;
-	int k;
-	int len = 0;
-	off_t pos = 0;
-	off_t begin = 0;
+	struct ax25_cb *ax25;
 	struct hlist_node *node;
+	int i = 0;
 
 	spin_lock_bh(&ax25_list_lock);
+	ax25_for_each(ax25, node, &ax25_list) {
+		if (i == *pos)
+			return ax25;
+		++i;
+	}
+	return NULL;
+}
+
+static void *ax25_info_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	++*pos;
+
+	return hlist_entry( ((struct ax25_cb *)v)->ax25_node.next,
+			    struct ax25_cb, ax25_node);
+}
+	
+static void ax25_info_stop(struct seq_file *seq, void *v)
+{
+	spin_unlock_bh(&ax25_list_lock);
+}
+
+static int ax25_info_show(struct seq_file *seq, void *v)
+{
+	ax25_cb *ax25 = v;
+	int k;
+
 
 	/*
 	 * New format:
 	 * magic dev src_addr dest_addr,digi1,digi2,.. st vs vr va t1 t1 t2 t2 t3 t3 idle idle n2 n2 rtt window paclen Snd-Q Rcv-Q inode
 	 */
 
-	ax25_for_each(ax25, node, &ax25_list) {
-		len += sprintf(buffer+len, "%8.8lx %s %s%s ",
-				(long) ax25,
-				ax25->ax25_dev == NULL? "???" : ax25->ax25_dev->dev->name,
-				ax2asc(&ax25->source_addr),
-				ax25->iamdigi? "*":"");
-
-		len += sprintf(buffer+len, "%s", ax2asc(&ax25->dest_addr));
-
-		for (k=0; (ax25->digipeat != NULL) && (k < ax25->digipeat->ndigi); k++) {
-			len += sprintf(buffer+len, ",%s%s",
-					ax2asc(&ax25->digipeat->calls[k]),
-					ax25->digipeat->repeated[k]? "*":"");
-		}
-
-		len += sprintf(buffer+len, " %d %d %d %d %lu %lu %lu %lu %lu %lu %lu %lu %d %d %lu %d %d",
-			ax25->state,
-			ax25->vs, ax25->vr, ax25->va,
-			ax25_display_timer(&ax25->t1timer) / HZ, ax25->t1 / HZ,
-			ax25_display_timer(&ax25->t2timer) / HZ, ax25->t2 / HZ,
-			ax25_display_timer(&ax25->t3timer) / HZ, ax25->t3 / HZ,
-			ax25_display_timer(&ax25->idletimer) / (60 * HZ),
-			ax25->idle / (60 * HZ),
-			ax25->n2count, ax25->n2,
-			ax25->rtt / HZ,
-			ax25->window,
-			ax25->paclen);
-
-		if (ax25->sk != NULL) {
-			bh_lock_sock(ax25->sk);
-			len += sprintf(buffer + len, " %d %d %ld\n",
-				atomic_read(&ax25->sk->sk_wmem_alloc),
-				atomic_read(&ax25->sk->sk_rmem_alloc),
-				ax25->sk->sk_socket != NULL ? SOCK_INODE(ax25->sk->sk_socket)->i_ino : 0L);
-			bh_unlock_sock(ax25->sk);
-		} else {
-			len += sprintf(buffer + len, " * * *\n");
-		}
-
-		pos = begin + len;
-
-		if (pos < offset) {
-			len   = 0;
-			begin = pos;
-		}
+	seq_printf(seq, "%8.8lx %s %s%s ",
+		   (long) ax25,
+		   ax25->ax25_dev == NULL? "???" : ax25->ax25_dev->dev->name,
+		   ax2asc(&ax25->source_addr),
+		   ax25->iamdigi? "*":"");
+	seq_printf(seq, "%s", ax2asc(&ax25->dest_addr));
+
+	for (k=0; (ax25->digipeat != NULL) && (k < ax25->digipeat->ndigi); k++) {
+		seq_printf(seq, ",%s%s",
+			   ax2asc(&ax25->digipeat->calls[k]),
+			   ax25->digipeat->repeated[k]? "*":"");
+	}
 
-		if (pos > offset + length)
-			break;
+	seq_printf(seq, " %d %d %d %d %lu %lu %lu %lu %lu %lu %lu %lu %d %d %lu %d %d",
+		   ax25->state,
+		   ax25->vs, ax25->vr, ax25->va,
+		   ax25_display_timer(&ax25->t1timer) / HZ, ax25->t1 / HZ,
+		   ax25_display_timer(&ax25->t2timer) / HZ, ax25->t2 / HZ,
+		   ax25_display_timer(&ax25->t3timer) / HZ, ax25->t3 / HZ,
+		   ax25_display_timer(&ax25->idletimer) / (60 * HZ),
+		   ax25->idle / (60 * HZ),
+		   ax25->n2count, ax25->n2,
+		   ax25->rtt / HZ,
+		   ax25->window,
+		   ax25->paclen);
+
+	if (ax25->sk != NULL) {
+		bh_lock_sock(ax25->sk);
+		seq_printf(seq," %d %d %ld\n",
+			   atomic_read(&ax25->sk->sk_wmem_alloc),
+			   atomic_read(&ax25->sk->sk_rmem_alloc),
+			   ax25->sk->sk_socket != NULL ? SOCK_INODE(ax25->sk->sk_socket)->i_ino : 0L);
+		bh_unlock_sock(ax25->sk);
+	} else {
+		seq_puts(seq, " * * *\n");
 	}
+	return 0;
+}
 
-	spin_unlock_bh(&ax25_list_lock);
+static struct seq_operations ax25_info_seqops = {
+	.start = ax25_info_start,
+	.next = ax25_info_next,
+	.stop = ax25_info_stop,
+	.show = ax25_info_show,
+};
 
-	*start = buffer + (offset - begin);
-	len   -= (offset - begin);
+static int ax25_info_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &ax25_info_seqops);
+}
 
-	if (len > length) len = length;
+static struct file_operations ax25_info_fops = {
+	.owner = THIS_MODULE,
+	.open = ax25_info_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = seq_release,
+};
 
-	return(len);
-}
+#endif
 
 static struct net_proto_family ax25_family_ops = {
 	.family =	PF_AX25,
@@ -1986,9 +2012,9 @@
 	register_netdevice_notifier(&ax25_dev_notifier);
 	ax25_register_sysctl();
 
-	proc_net_create("ax25_route", 0, ax25_rt_get_info);
-	proc_net_create("ax25", 0, ax25_get_info);
-	proc_net_create("ax25_calls", 0, ax25_uid_get_info);
+	proc_net_fops_create("ax25_route", S_IRUGO, &ax25_route_fops);
+	proc_net_fops_create("ax25", S_IRUGO, &ax25_info_fops);
+	proc_net_fops_create("ax25_calls", S_IRUGO, &ax25_uid_fops);
 
 	printk(banner);
 	return 0;
diff -Nru a/net/ax25/ax25_route.c b/net/ax25/ax25_route.c
--- a/net/ax25/ax25_route.c	Fri Aug 22 08:21:10 2003
+++ b/net/ax25/ax25_route.c	Fri Aug 22 08:21:10 2003
@@ -34,6 +34,7 @@
 #include <linux/mm.h>
 #include <linux/interrupt.h>
 #include <linux/init.h>
+#include <linux/seq_file.h>
 
 static ax25_route *ax25_route_list;
 static rwlock_t ax25_route_lock = RW_LOCK_UNLOCKED;
@@ -278,66 +279,100 @@
 	}
 }
 
-int ax25_rt_get_info(char *buffer, char **start, off_t offset, int length)
-{
-	ax25_route *ax25_rt;
-	int len     = 0;
-	off_t pos   = 0;
-	off_t begin = 0;
-	char *callsign;
-	int i;
+#ifdef CONFIG_PROC_FS
 
-	read_lock(&ax25_route_lock);
+#define AX25_PROC_START	((void *)1)
 
-	len += sprintf(buffer, "callsign  dev  mode digipeaters\n");
+static void *ax25_rt_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	struct ax25_route *ax25_rt;
+	int i = 1;
+ 
+ 	read_lock(&ax25_route_lock);
+	if (*pos == 0)
+		return AX25_PROC_START;
 
 	for (ax25_rt = ax25_route_list; ax25_rt != NULL; ax25_rt = ax25_rt->next) {
+		if (i == *pos)
+			return ax25_rt;
+		++i;
+	}
+
+	return NULL;
+}
+
+static void *ax25_rt_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	++*pos;
+	return (v == AX25_PROC_START) ? ax25_route_list : 
+		((struct ax25_route *) v)->next;
+}
+
+static void ax25_rt_seq_stop(struct seq_file *seq, void *v)
+{
+	read_unlock(&ax25_route_lock);
+}
+
+static int ax25_rt_seq_show(struct seq_file *seq, void *v)
+{
+	if (v == AX25_PROC_START)
+		seq_puts(seq, "callsign  dev  mode digipeaters\n");
+	else {
+		struct ax25_route *ax25_rt = v;
+		const char *callsign;
+		int i;
+
 		if (ax25cmp(&ax25_rt->callsign, &null_ax25_address) == 0)
 			callsign = "default";
 		else
 			callsign = ax2asc(&ax25_rt->callsign);
-		len += sprintf(buffer + len, "%-9s %-4s",
+
+		seq_printf(seq, "%-9s %-4s",
 			callsign,
 			ax25_rt->dev ? ax25_rt->dev->name : "???");
 
 		switch (ax25_rt->ip_mode) {
 		case 'V':
-			len += sprintf(buffer + len, "   vc");
+			seq_puts(seq, "   vc");
 			break;
 		case 'D':
-			len += sprintf(buffer + len, "   dg");
+			seq_puts(seq, "   dg");
 			break;
 		default:
-			len += sprintf(buffer + len, "    *");
+			seq_puts(seq, "    *");
 			break;
 		}
 
 		if (ax25_rt->digipeat != NULL)
 			for (i = 0; i < ax25_rt->digipeat->ndigi; i++)
-				len += sprintf(buffer + len, " %s", ax2asc(&ax25_rt->digipeat->calls[i]));
-
-		len += sprintf(buffer + len, "\n");
+				seq_printf(seq, " %s", ax2asc(&ax25_rt->digipeat->calls[i]));
 
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
-	read_unlock(&ax25_route_lock);
-
-	*start = buffer + (offset - begin);
-	len   -= (offset - begin);
+	return 0;
+}
 
-	if (len > length)
-		len = length;
+static struct seq_operations ax25_rt_seqops = {
+	.start = ax25_rt_seq_start,
+	.next = ax25_rt_seq_next,
+	.stop = ax25_rt_seq_stop,
+	.show = ax25_rt_seq_show,
+};
 
-	return len;
+static int ax25_rt_info_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &ax25_rt_seqops);
 }
+
+struct file_operations ax25_route_fops = {
+	.owner = THIS_MODULE,
+	.open = ax25_rt_info_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = seq_release,
+};
+
+#endif
 
 /*
  *	Find AX.25 route
diff -Nru a/net/ax25/ax25_uid.c b/net/ax25/ax25_uid.c
--- a/net/ax25/ax25_uid.c	Fri Aug 22 08:21:10 2003
+++ b/net/ax25/ax25_uid.c	Fri Aug 22 08:21:10 2003
@@ -30,6 +30,7 @@
 #include <linux/interrupt.h>
 #include <linux/notifier.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/stat.h>
 #include <linux/netfilter.h>
 #include <linux/sysctl.h>
@@ -141,39 +142,73 @@
 	return -EINVAL;	/*NOTREACHED */
 }
 
-int ax25_uid_get_info(char *buffer, char **start, off_t offset, int length)
+#ifdef CONFIG_PROC_FS
+
+#define AX25_PROC_START	((void *)1)
+
+static void *ax25_uid_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	ax25_uid_assoc *pt;
-	int len     = 0;
-	off_t pos   = 0;
-	off_t begin = 0;
+	struct ax25_uid_assoc *pt;
+	int i = 1;
 
 	read_lock(&ax25_uid_lock);
-	len += sprintf(buffer, "Policy: %d\n", ax25_uid_policy);
+	if (*pos == 0)
+		return AX25_PROC_START;
 
 	for (pt = ax25_uid_list; pt != NULL; pt = pt->next) {
-		len += sprintf(buffer + len, "%6d %s\n", pt->uid, ax2asc(&pt->call));
-
-		pos = begin + len;
+		if (i == *pos)
+			return pt;
+		++i;
+	}
+	return NULL;
+}
 
-		if (pos < offset) {
-			len = 0;
-			begin = pos;
-		}
+static void *ax25_uid_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	++*pos;
+	return (v == AX25_PROC_START) ? ax25_uid_list : 
+		((struct ax25_uid_assoc *) v)->next;
+}
 
-		if (pos > offset + length)
-			break;
-	}
+static void ax25_uid_seq_stop(struct seq_file *seq, void *v)
+{
 	read_unlock(&ax25_uid_lock);
+}
+
+static int ax25_uid_seq_show(struct seq_file *seq, void *v)
+{
+	if (v == AX25_PROC_START)
+		seq_printf(seq, "Policy: %d\n", ax25_uid_policy);
+	else {
+		struct ax25_uid_assoc *pt = v;
+		
 
-	*start = buffer + (offset - begin);
-	len   -= offset - begin;
+		seq_printf(seq, "%6d %s\n", pt->uid, ax2asc(&pt->call));
+	}
+	return 0;
+}
 
-	if (len > length)
-		len = length;
+static struct seq_operations ax25_uid_seqops = {
+	.start = ax25_uid_seq_start,
+	.next = ax25_uid_seq_next,
+	.stop = ax25_uid_seq_stop,
+	.show = ax25_uid_seq_show,
+};
 
-	return len;
+static int ax25_uid_info_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &ax25_uid_seqops);
 }
+
+struct file_operations ax25_uid_fops = {
+	.owner = THIS_MODULE,
+	.open = ax25_uid_info_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = seq_release,
+};
+
+#endif
 
 /*
  *	Free all memory associated with UID/Callsign structures.
