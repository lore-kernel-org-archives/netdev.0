From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] seq_file conversion 2/5: /proc/net/igmp6
Date: Tue, 01 Jul 2003 14:48:50 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030701.144850.120945416.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, jmorris@intercode.com.au
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

2/5: convert /proc/net/igmp6 to seq_file.

Index: linux-2.5/net/ipv6/mcast.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/mcast.c,v
retrieving revision 1.24
diff -u -r1.24 mcast.c
--- linux-2.5/net/ipv6/mcast.c	24 Jun 2003 19:45:24 -0000	1.24
+++ linux-2.5/net/ipv6/mcast.c	30 Jun 2003 15:28:16 -0000
@@ -44,6 +44,7 @@
 #include <linux/route.h>
 #include <linux/init.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 
 #include <net/sock.h>
 #include <net/snmp.h>
@@ -2039,64 +2040,145 @@
 }
 
 #ifdef CONFIG_PROC_FS
-static int igmp6_read_proc(char *buffer, char **start, off_t offset,
-			   int length, int *eof, void *data)
-{
-	off_t pos=0, begin=0;
-	struct ifmcaddr6 *im;
-	int len=0;
+struct igmp6_mc_iter_state {
 	struct net_device *dev;
-	
-	read_lock(&dev_base_lock);
-	for (dev = dev_base; dev; dev = dev->next) {
-		struct inet6_dev *idev;
+	struct inet6_dev *idev;
+};
 
-		if ((idev = in6_dev_get(dev)) == NULL)
-			continue;
+#define igmp6_mc_seq_private(seq)	((struct igmp6_mc_iter_state *)&seq->private)
 
-		read_lock_bh(&idev->lock);
-		for (im = idev->mc_list; im; im = im->next) {
-			int i;
+static inline struct ifmcaddr6 *igmp6_mc_get_first(struct seq_file *seq)
+{
+	struct ifmcaddr6 *im = NULL;
+	struct igmp6_mc_iter_state *state = igmp6_mc_seq_private(seq);
 
-			len += sprintf(buffer+len,"%-4d %-15s ", dev->ifindex, dev->name);
+	for (state->dev = dev_base, state->idev = NULL;
+	     state->dev; 
+	     state->dev = state->dev->next) {
+		struct inet6_dev *idev;
+		idev = in6_dev_get(state->dev);
+		if (!idev)
+			continue;
+		read_lock_bh(&idev->lock);
+		im = idev->mc_list;
+		if (im) {
+			state->idev = idev;
+			break;
+		}
+		read_unlock_bh(&idev->lock);
+	}
+	return im;
+}
 
-			for (i=0; i<16; i++)
-				len += sprintf(buffer+len, "%02x", im->mca_addr.s6_addr[i]);
+static struct ifmcaddr6 *igmp6_mc_get_next(struct seq_file *seq, struct ifmcaddr6 *im)
+{
+	struct igmp6_mc_iter_state *state = igmp6_mc_seq_private(seq);
 
-			len+=sprintf(buffer+len,
-				     " %5d %08X %ld\n",
-				     im->mca_users,
-				     im->mca_flags,
-				     (im->mca_flags&MAF_TIMER_RUNNING) ? im->mca_timer.expires-jiffies : 0);
-
-			pos=begin+len;
-			if (pos < offset) {
-				len=0;
-				begin=pos;
-			}
-			if (pos > offset+length) {
-				read_unlock_bh(&idev->lock);
-				in6_dev_put(idev);
-				goto done;
-			}
+	im = im->next;
+	while (!im) {
+		if (likely(state->idev != NULL)) {
+			read_unlock_bh(&state->idev->lock);
+			in6_dev_put(state->idev);
 		}
-		read_unlock_bh(&idev->lock);
-		in6_dev_put(idev);
+		state->dev = state->dev->next;
+		if (!state->dev) {
+			state->idev = NULL;
+			break;
+		}
+		state->idev = in6_dev_get(state->dev);
+		if (!state->idev)
+			continue;
+		read_lock_bh(&state->idev->lock);
+		im = state->idev->mc_list;
 	}
-	*eof = 1;
+	return im;
+}
 
-done:
+static struct ifmcaddr6 *igmp6_mc_get_idx(struct seq_file *seq, loff_t pos)
+{
+	struct ifmcaddr6 *im = igmp6_mc_get_first(seq);
+	if (im)
+		while (pos && (im = igmp6_mc_get_next(seq, im)) != NULL)
+			--pos;
+	return pos ? NULL : im;
+}
+
+static void *igmp6_mc_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	read_lock(&dev_base_lock);
+	return *pos ? igmp6_mc_get_idx(seq, *pos) : igmp6_mc_get_first(seq);
+}
+
+static void *igmp6_mc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct ifmcaddr6 *im;
+	im = igmp6_mc_get_next(seq, v);
+	++*pos;
+	return im;
+}
+
+static void igmp6_mc_seq_stop(struct seq_file *seq, void *v)
+{
+	struct igmp6_mc_iter_state *state = igmp6_mc_seq_private(seq);
+	if (likely(state->idev != NULL)) {
+		read_unlock_bh(&state->idev->lock);
+		in6_dev_put(state->idev);
+	}
 	read_unlock(&dev_base_lock);
+}
 
-	*start=buffer+(offset-begin);
-	len-=(offset-begin);
-	if(len>length)
-		len=length;
-	if (len<0)
-		len=0;
-	return len;
+static int igmp6_mc_seq_show(struct seq_file *seq, void *v)
+{
+	struct ifmcaddr6 *im = (struct ifmcaddr6 *)v;
+	struct igmp6_mc_iter_state *state = igmp6_mc_seq_private(seq);
+
+	seq_printf(seq,
+		   "%-4d %-15s %04x%04x%04x%04x%04x%04x%04x%04x %5d %08X %ld\n", 
+		   state->dev->ifindex, state->dev->name,
+		   NIP6(im->mca_addr),
+		   im->mca_users, im->mca_flags,
+		   (im->mca_flags&MAF_TIMER_RUNNING) ? im->mca_timer.expires-jiffies : 0);
+	return 0;
 }
 
+static struct seq_operations igmp6_mc_seq_ops = {
+	.start	=	igmp6_mc_seq_start,
+	.next	=	igmp6_mc_seq_next,
+	.stop	=	igmp6_mc_seq_stop,
+	.show	=	igmp6_mc_seq_show,
+};
+
+static int igmp6_mc_seq_open(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq;
+	int rc = -ENOMEM;
+	struct igmp6_mc_iter_state *s = kmalloc(sizeof(*s), GFP_KERNEL);
+
+	if (!s)
+		goto out;
+
+	rc = seq_open(file, &igmp6_mc_seq_ops);
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
+}
+
+static struct file_operations igmp6_mc_seq_fops = {
+	.owner		=	THIS_MODULE,
+	.open		=	igmp6_mc_seq_open,
+	.read		=	seq_read,
+	.llseek		=	seq_lseek,
+	.release	=	seq_release_private,
+};
+
 static int ip6_mcf_read_proc(char *buffer, char **start, off_t offset,
 			   int length, int *eof, void *data)
 {
@@ -2178,6 +2260,9 @@
 	struct ipv6_pinfo *np;
 	struct sock *sk;
 	int err;
+#ifdef CONFIG_PROC_FS
+	struct proc_dir_entry *p;
+#endif
 
 	err = sock_create(PF_INET6, SOCK_RAW, IPPROTO_ICMPV6, &igmp6_socket);
 	if (err < 0) {
@@ -2194,8 +2279,11 @@
 
 	np = inet6_sk(sk);
 	np->hop_limit = 1;
+
 #ifdef CONFIG_PROC_FS
-	create_proc_read_entry("net/igmp6", 0, 0, igmp6_read_proc, NULL);
+	p = create_proc_entry("igmp6", S_IRUGO, proc_net);
+	if (p)
+		p->proc_fops = &igmp6_mc_seq_fops;
 	create_proc_read_entry("net/mcfilter6", 0, 0, ip6_mcf_read_proc, NULL);
 #endif
 
@@ -2207,6 +2295,6 @@
 	sock_release(igmp6_socket);
 	igmp6_socket = NULL; /* for safety */
 #ifdef CONFIG_PROC_FS
-	remove_proc_entry("net/igmp6", 0);
+	proc_net_remove("igmp6");
 #endif
 }

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
