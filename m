From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV4: convert /proc/net/igmp to seq_file
Date: Tue, 01 Jul 2003 01:57:46 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030701.015746.56567539.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

This converts /proc/net/igmp to seq_file.
Thanks.

Index: linux-2.5/include/net/ip.h
===================================================================
RCS file: /home/cvs/linux-2.5/include/net/ip.h,v
retrieving revision 1.20
diff -u -r1.20 ip.h
--- linux-2.5/include/net/ip.h	7 Jun 2003 00:22:34 -0000	1.20
+++ linux-2.5/include/net/ip.h	30 Jun 2003 15:28:13 -0000
@@ -79,7 +79,7 @@
 
 extern void		ip_mc_dropsocket(struct sock *);
 extern void		ip_mc_dropdevice(struct net_device *dev);
-extern int		ip_mc_procinfo(char *, char **, off_t, int);
+extern int		igmp_mc_proc_init(void);
 extern int		ip_mcf_procinfo(char *, char **, off_t, int);
 
 /*
Index: linux-2.5/net/ipv4/igmp.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv4/igmp.c,v
retrieving revision 1.28
diff -u -r1.28 igmp.c
--- linux-2.5/net/ipv4/igmp.c	26 Jun 2003 03:45:59 -0000	1.28
+++ linux-2.5/net/ipv4/igmp.c	30 Jun 2003 15:28:13 -0000
@@ -99,7 +99,10 @@
 #ifdef CONFIG_IP_MROUTE
 #include <linux/mroute.h>
 #endif
-
+#ifdef CONFIG_PROC_FS
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+#endif
 
 #define IP_MAX_MEMBERSHIPS 20
 
@@ -2090,65 +2093,162 @@
 	return rv;
 }
 
-
-int ip_mc_procinfo(char *buffer, char **start, off_t offset, int length)
-{
-	off_t pos=0, begin=0;
-	struct ip_mc_list *im;
-	int len=0;
+#if defined(CONFIG_PROC_FS)
+struct igmp_mc_iter_state {
 	struct net_device *dev;
+	struct in_device *in_dev;
+};
 
-	len=sprintf(buffer,"Idx\tDevice    : Count Querier\tGroup    Users Timer\tReporter\n");  
+#define	igmp_mc_seq_private(seq)	((struct igmp_mc_iter_state *)&seq->private)
 
-	read_lock(&dev_base_lock);
-	for(dev = dev_base; dev; dev = dev->next) {
-		struct in_device *in_dev = in_dev_get(dev);
-		char   *querier = "NONE";
+static inline struct ip_mc_list *igmp_mc_get_first(struct seq_file *seq)
+{
+	struct ip_mc_list *im = NULL;
+	struct igmp_mc_iter_state *state = igmp_mc_seq_private(seq);
 
-		if (in_dev == NULL)
+	for (state->dev = dev_base, state->in_dev = NULL;
+	     state->dev; 
+	     state->dev = state->dev->next) {
+		struct in_device *in_dev;
+		in_dev = in_dev_get(state->dev);
+		if (!in_dev)
 			continue;
-
-#ifdef CONFIG_IP_MULTICAST
-		querier = IGMP_V1_SEEN(in_dev) ? "V1" : "V2";
-#endif
-
-		len+=sprintf(buffer+len,"%d\t%-10s: %5d %7s\n",
-			     dev->ifindex, dev->name, dev->mc_count, querier);
-
 		read_lock(&in_dev->lock);
-		for (im = in_dev->mc_list; im; im = im->next) {
-			len+=sprintf(buffer+len,
-				     "\t\t\t\t%08lX %5d %d:%08lX\t\t%d\n",
-				     im->multiaddr, im->users,
-				     im->tm_running, im->timer.expires-jiffies, im->reporter);
-
-			pos=begin+len;
-			if(pos<offset)
-			{
-				len=0;
-				begin=pos;
-			}
-			if(pos>offset+length) {
-				read_unlock(&in_dev->lock);
-				in_dev_put(in_dev);
-				goto done;
-			}
+		im = in_dev->mc_list;
+		if (im) {
+			state->in_dev = in_dev;
+			break;
 		}
 		read_unlock(&in_dev->lock);
-		in_dev_put(in_dev);
 	}
-done:
+	return im;
+}
+
+static struct ip_mc_list *igmp_mc_get_next(struct seq_file *seq, struct ip_mc_list *im)
+{
+	struct igmp_mc_iter_state *state = igmp_mc_seq_private(seq);
+	im = im->next;
+	while (!im) {
+		if (likely(state->in_dev != NULL)) {
+			read_unlock(&state->in_dev->lock);
+			in_dev_put(state->in_dev);
+		}
+		state->dev = state->dev->next;
+		if (!state->dev) {
+			state->in_dev = NULL;
+			break;
+		}
+		state->in_dev = in_dev_get(state->dev);
+		if (!state->in_dev)
+			continue;
+		read_lock(&state->in_dev->lock);
+		im = state->in_dev->mc_list;
+	}
+	return im;
+}
+
+static struct ip_mc_list *igmp_mc_get_idx(struct seq_file *seq, loff_t pos)
+{
+	struct ip_mc_list *im = igmp_mc_get_first(seq);
+	if (im)
+		while (pos && (im = igmp_mc_get_next(seq, im)) != NULL)
+			--pos;
+	return pos ? NULL : im;
+}
+
+static void *igmp_mc_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	read_lock(&dev_base_lock);
+	return *pos ? igmp_mc_get_idx(seq, *pos) : (void *)1;
+}
+
+static void *igmp_mc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct ip_mc_list *im;
+	if (v == (void *)1)
+		im = igmp_mc_get_first(seq);
+	else
+		im = igmp_mc_get_next(seq, v);
+	++*pos;
+	return im;
+}
+
+static void igmp_mc_seq_stop(struct seq_file *seq, void *v)
+{
+	struct igmp_mc_iter_state *state = igmp_mc_seq_private(seq);
+	if (likely(state->in_dev != NULL)) {
+		read_unlock(state->in_dev->lock);
+		in_dev_put(state->in_dev);
+	}
 	read_unlock(&dev_base_lock);
+}
 
-	*start=buffer+(offset-begin);
-	len-=(offset-begin);
-	if(len>length)
-		len=length;
-	if(len<0)
-		len=0;
-	return len;
+static int igmp_mc_seq_show(struct seq_file *seq, void *v)
+{
+	if (v == (void *)1)
+		seq_printf(seq, 
+			   "Idx\tDevice    : Count Querier\tGroup    Users Timer\tReporter\n");
+	else {
+		struct ip_mc_list *im = (struct ip_mc_list *)v;
+		struct igmp_mc_iter_state *state = igmp_mc_seq_private(seq);
+		char   *querier;
+#ifdef CONFIG_IP_MULTICAST
+		querier = IGMP_V1_SEEN(state->in_dev) ? "V1" : "V2";
+#else
+		querier = "NONE";
+#endif
+
+		if (state->in_dev->mc_list == im) {
+			seq_printf(seq, "%d\t%-10s: %5d %7s\n",
+				   state->dev->ifindex, state->dev->name, state->dev->mc_count, querier);
+		}
+
+		seq_printf(seq,
+			   "\t\t\t\t%08lX %5d %d:%08lX\t\t%d\n",
+			   im->multiaddr, im->users,
+			   im->tm_running, im->timer.expires-jiffies, im->reporter);
+	}
+	return 0;
+}
+
+static struct seq_operations igmp_mc_seq_ops = {
+	.start	=	igmp_mc_seq_start,
+	.next	=	igmp_mc_seq_next,
+	.stop	=	igmp_mc_seq_stop,
+	.show	=	igmp_mc_seq_show,
+};
+
+static int igmp_mc_seq_open(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq;
+	int rc = -ENOMEM;
+	struct igmp_mc_iter_state *s = kmalloc(sizeof(*s), GFP_KERNEL);
+
+	if (!s)
+		goto out;
+	rc = seq_open(file, &igmp_mc_seq_ops);
+	if (rc)
+		goto out_kfree;
+
+	seq = file->private_data;
+	seq->private = s;
+	memset(s, 0, sizeof(*s));
+out:
+	return rc;
+out_kfree:
+	kfree(s);
+	goto out;
 }
 
+static struct file_operations igmp_mc_seq_fops = {
+	.owner		=	THIS_MODULE,
+	.open		=	igmp_mc_seq_open,
+	.read		=	seq_read,
+	.llseek		=	seq_lseek,
+	.release	=	seq_release_private,
+};
+#endif
+
 int ip_mcf_procinfo(char *buffer, char **start, off_t offset, int length)
 {
 	off_t pos=0, begin=0;
@@ -2213,4 +2313,16 @@
 		len=0;
 	return len;
 }
+
+#ifdef CONFIG_PROC_FS
+int __init igmp_mc_proc_init(void)
+{
+	struct proc_dir_entry *p;
+
+	p = create_proc_entry("igmp", S_IRUGO, proc_net);
+	if (p)
+		p->proc_fops = &igmp_mc_seq_fops;
+	return 0;
+}
+#endif
 
Index: linux-2.5/net/ipv4/ip_output.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv4/ip_output.c,v
retrieving revision 1.34
diff -u -r1.34 ip_output.c
--- linux-2.5/net/ipv4/ip_output.c	21 Jun 2003 16:20:41 -0000	1.34
+++ linux-2.5/net/ipv4/ip_output.c	30 Jun 2003 15:28:13 -0000
@@ -1314,7 +1314,7 @@
 	inet_initpeers();
 
 #ifdef CONFIG_IP_MULTICAST
-	proc_net_create("igmp", 0, ip_mc_procinfo);
+	igmp_mc_proc_init();
 #endif
 	proc_net_create("mcfilter", 0, ip_mcf_procinfo);
 }


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
