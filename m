From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] seq_file conversion 5/5: /proc/net/anycast6
Date: Tue, 01 Jul 2003 14:48:57 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030701.144857.99268305.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, jmorris@intercode.com.au
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

5/5: convert /proc/net/anycast6 to seq_file.

Index: linux-2.5/net/ipv6/af_inet6.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/af_inet6.c,v
retrieving revision 1.46
diff -u -r1.46 af_inet6.c
--- linux-2.5/net/ipv6/af_inet6.c	9 Jun 2003 17:26:52 -0000	1.46
+++ linux-2.5/net/ipv6/af_inet6.c	30 Jun 2003 16:36:55 -0000
@@ -85,7 +85,8 @@
 extern void udp6_proc_exit(void);
 extern int ipv6_misc_proc_init(void);
 extern void ipv6_misc_proc_exit(void);
-extern int anycast6_get_info(char *, char **, off_t, int);
+extern int ac6_proc_init(void);
+extern void ac6_proc_exit(void);
 extern int if6_proc_init(void);
 extern void if6_proc_exit(void);
 #endif
@@ -799,7 +800,7 @@
 	if (ipv6_misc_proc_init())
 		goto proc_misc6_fail;
 
-	if (!proc_net_create("anycast6", 0, anycast6_get_info))
+	if (ac6_proc_init())
 		goto proc_anycast6_fail;
 	if (if6_proc_init())
 		goto proc_if6_fail;
@@ -825,7 +826,7 @@
 
 #ifdef CONFIG_PROC_FS
 proc_if6_fail:
-	proc_net_remove("anycast6");
+	ac6_proc_exit();
 proc_anycast6_fail:
 	ipv6_misc_proc_exit();
 proc_misc6_fail:
@@ -863,7 +864,7 @@
 	sock_unregister(PF_INET6);
 #ifdef CONFIG_PROC_FS
 	if6_proc_exit();
- 	proc_net_remove("anycast6");
+	ac6_proc_exit();
  	ipv6_misc_proc_exit();
  	udp6_proc_exit();
  	tcp6_proc_exit();
Index: linux-2.5/net/ipv6/anycast.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/anycast.c,v
retrieving revision 1.3
diff -u -r1.3 anycast.c
--- linux-2.5/net/ipv6/anycast.c	22 May 2003 07:38:17 -0000	1.3
+++ linux-2.5/net/ipv6/anycast.c	30 Jun 2003 16:36:55 -0000
@@ -29,6 +29,7 @@
 #include <linux/route.h>
 #include <linux/init.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 
 #include <net/sock.h>
 #include <net/snmp.h>
@@ -435,56 +436,159 @@
 
 
 #ifdef CONFIG_PROC_FS
-int anycast6_get_info(char *buffer, char **start, off_t offset, int length)
-{
-	off_t pos=0, begin=0;
-	struct ifacaddr6 *im;
-	int len=0;
+struct ac6_iter_state {
 	struct net_device *dev;
-	
-	read_lock(&dev_base_lock);
-	for (dev = dev_base; dev; dev = dev->next) {
-		struct inet6_dev *idev;
+	struct inet6_dev *idev;
+};
 
-		if ((idev = in6_dev_get(dev)) == NULL)
-			continue;
+#define ac6_seq_private(seq)	((struct ac6_iter_state *)&seq->private)
 
-		read_lock_bh(&idev->lock);
-		for (im = idev->ac_list; im; im = im->aca_next) {
-			int i;
+static inline struct ifacaddr6 *ac6_get_first(struct seq_file *seq)
+{
+	struct ifacaddr6 *im = NULL;
+	struct ac6_iter_state *state = ac6_seq_private(seq);
 
-			len += sprintf(buffer+len,"%-4d %-15s ", dev->ifindex, dev->name);
+	for (state->dev = dev_base, state->idev = NULL;
+	     state->dev;
+	     state->dev = state->dev->next) {
+		struct inet6_dev *idev;
+		idev = in6_dev_get(state->dev);
+		if (!idev)
+			continue;
+		read_lock_bh(&idev->lock);
+		im = idev->ac_list;
+		if (im) {
+			state->idev = idev;
+			break;
+		}
+		read_unlock_bh(&idev->lock);
+	}
+	return im;
+}
 
-			for (i=0; i<16; i++)
-				len += sprintf(buffer+len, "%02x", im->aca_addr.s6_addr[i]);
+static struct ifacaddr6 *ac6_get_next(struct seq_file *seq, struct ifacaddr6 *im)
+{
+	struct ac6_iter_state *state = ac6_seq_private(seq);
 
-			len += sprintf(buffer+len, " %5d\n", im->aca_users);
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
+	im = im->aca_next;
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
+		im = state->idev->ac_list;
 	}
+	return im;
+}
 
-done:
+static struct ifacaddr6 *ac6_get_idx(struct seq_file *seq, loff_t pos)
+{
+	struct ifacaddr6 *im = ac6_get_first(seq);
+	if (im)
+		while (pos && (im = ac6_get_next(seq, im)) != NULL)
+			--pos;
+	return pos ? NULL : im;
+}
+
+static void *ac6_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	read_lock(&dev_base_lock);
+	return *pos ? ac6_get_idx(seq, *pos) : ac6_get_first(seq);
+}
+
+static void *ac6_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct ifacaddr6 *im;
+	im = ac6_get_next(seq, v);
+	++*pos;
+	return im;
+}
+
+static void ac6_seq_stop(struct seq_file *seq, void *v)
+{
+	struct ac6_iter_state *state = ac6_seq_private(seq);
+	if (likely(state->idev != NULL)) {
+		read_unlock_bh(&state->idev->lock);
+		in6_dev_put(state->idev);
+	}
 	read_unlock(&dev_base_lock);
+}
+
+static int ac6_seq_show(struct seq_file *seq, void *v)
+{
+	struct ifacaddr6 *im = (struct ifacaddr6 *)v;
+	struct ac6_iter_state *state = ac6_seq_private(seq);
 
-	*start=buffer+(offset-begin);
-	len-=(offset-begin);
-	if(len>length)
-		len=length;
-	if (len<0)
-		len=0;
-	return len;
+	seq_printf(seq,
+		   "%-4d %-15s "
+		   "%04x%04x%04x%04x%04x%04x%04x%04x "
+		   "%5d\n",
+		   state->dev->ifindex, state->dev->name,
+		   NIP6(im->aca_addr),
+		   im->aca_users);
+	return 0;
 }
 
+static struct seq_operations ac6_seq_ops = {
+	.start	=	ac6_seq_start,
+	.next	=	ac6_seq_next,
+	.stop	=	ac6_seq_stop,
+	.show	=	ac6_seq_show,
+};
+
+static int ac6_seq_open(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq;
+	int rc = -ENOMEM;
+	struct ac6_iter_state *s = kmalloc(sizeof(*s), GFP_KERNEL);
+
+	if (!s)
+		goto out;
+
+	rc = seq_open(file, &ac6_seq_ops);
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
+static struct file_operations ac6_seq_fops = {
+	.owner		=	THIS_MODULE,
+	.open		=	ac6_seq_open,
+	.read		=	seq_read,
+	.llseek		=	seq_lseek,
+	.release	=	seq_release_private,
+};
+
+int __init ac6_proc_init(void)
+{
+	struct proc_dir_entry *p;
+
+	p = create_proc_entry("anycast6", S_IRUGO, proc_net);
+	if (p)
+		p->proc_fops = &ac6_seq_fops;
+	return 0;
+}
+
+void ac6_proc_exit(void)
+{
+	proc_net_remove("anycast6");
+}
 #endif
+


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
