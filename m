From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV{4,6}: fixed /proc/net/raw{,6} seq_file support
Date: Mon, 30 Jun 2003 23:09:55 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030630.230955.65202856.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

There were bugs in /proc/net/raw{,6} seq_file support.
Sorry, my fault.  This patch fixes the problem.

Thanks in advance.

Index: linux-2.5/net/ipv4/raw.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv4/raw.c,v
retrieving revision 1.31
diff -u -r1.31 raw.c
--- linux-2.5/net/ipv4/raw.c	21 Jun 2003 16:20:28 -0000	1.31
+++ linux-2.5/net/ipv4/raw.c	30 Jun 2003 12:48:00 -0000
@@ -801,7 +801,24 @@
 
 static int raw_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &raw_seq_ops);
+	struct seq_file *seq;
+	int rc = -ENOMEM;
+	struct raw_iter_state *s = kmalloc(sizeof(*s), GFP_KERNEL);
+
+	if (!s)
+		goto out;
+	rc = seq_open(file, &raw_seq_ops);
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
 
 static struct file_operations raw_seq_fops = {
@@ -809,7 +826,7 @@
 	.open	 = raw_seq_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_private,
 };
 
 int __init raw_proc_init(void)
Index: linux-2.5/net/ipv6/raw.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/raw.c,v
retrieving revision 1.30
diff -u -r1.30 raw.c
--- linux-2.5/net/ipv6/raw.c	21 Jun 2003 16:20:28 -0000	1.30
+++ linux-2.5/net/ipv6/raw.c	30 Jun 2003 12:48:00 -0000
@@ -1029,7 +1029,22 @@
 
 static int raw6_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &raw6_seq_ops);
+	struct seq_file *seq;
+	int rc = -ENOMEM;
+	struct raw6_iter_state *s = kmalloc(sizeof(*s), GFP_KERNEL);
+	if (!s)
+		goto out;
+	rc = seq_open(file, &raw6_seq_ops);
+	if (rc)
+		goto out_kfree;
+	seq = file->private_data;
+	seq->private = s;
+	memset(s, 0, sizeof(*s));
+out:
+	return rc;
+out_kfree:
+	kfree(s);
+	goto out;
 }
 
 static struct file_operations raw6_seq_fops = {
@@ -1037,7 +1052,7 @@
 	.open =		raw6_seq_open,
 	.read =		seq_read,
 	.llseek =	seq_lseek,
-	.release =	seq_release,
+	.release =	seq_release_private,
 };
 
 int __init raw6_proc_init(void)

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
