From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV6: convert /proc/net/ip6_flowlabel to seq_file
Date: Mon, 30 Jun 2003 23:01:15 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030630.230115.84925092.yoshfuji@linux-ipv6.org>
References: <20030629.015723.75141662.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030629.015723.75141662.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030629.015723.75141662.yoshfuji@linux-ipv6.org> (at Sun, 29 Jun 2003 01:57:23 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> This converts /proc/net/ip6_flowlabel to seq_file{}.
> Thanks.

Oops, this was buggy.  Here's fixed one...

Index: linux25/net/ipv6/ip6_flowlabel.c
===================================================================
RCS file: /cvsroot/usagi/usagi/kernel/linux25/net/ipv6/ip6_flowlabel.c,v
retrieving revision 1.1.1.2
retrieving revision 1.4
diff -u -r1.1.1.2 -r1.4
--- linux25/net/ipv6/ip6_flowlabel.c	24 Feb 2002 03:45:41 -0000	1.1.1.2
+++ linux25/net/ipv6/ip6_flowlabel.c	30 Jun 2003 13:48:40 -0000	1.4
@@ -19,6 +19,7 @@
 #include <linux/in6.h>
 #include <linux/route.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 
 #include <net/sock.h>
 
@@ -554,66 +555,150 @@
 
 #ifdef CONFIG_PROC_FS
 
+struct ip6fl_iter_state {
+	int bucket;
+};
 
-static int ip6_fl_read_proc(char *buffer, char **start, off_t offset,
-			    int length, int *eof, void *data)
-{
-	off_t pos=0;
-	off_t begin=0;
-	int len=0;
-	int i, k;
-	struct ip6_flowlabel *fl;
+#define ip6fl_seq_private(seq)	((struct ip6fl_iter_state *)&(seq)->private)
 
-	len+= sprintf(buffer,"Label S Owner  Users  Linger Expires  "
-		      "Dst                              Opt\n");
+static struct ip6_flowlabel *ip6fl_get_first(struct seq_file *seq)
+{
+	struct ip6_flowlabel *fl = NULL;
+	struct ip6fl_iter_state *state = ip6fl_seq_private(seq);
 
-	read_lock_bh(&ip6_fl_lock);
-	for (i=0; i<=FL_HASH_MASK; i++) {
-		for (fl = fl_ht[i]; fl; fl = fl->next) {
-			len+=sprintf(buffer+len,"%05X %-1d %-6d %-6d %-6d %-8ld ",
-				     (unsigned)ntohl(fl->label),
-				     fl->share,
-				     (unsigned)fl->owner,
-				     atomic_read(&fl->users),
-				     fl->linger/HZ,
-				     (long)(fl->expires - jiffies)/HZ);
-
-			for (k=0; k<16; k++)
-				len+=sprintf(buffer+len, "%02x", fl->dst.s6_addr[k]);
-			buffer[len++]=' ';
-			len+=sprintf(buffer+len, "%-4d", fl->opt ? fl->opt->opt_nflen : 0);
-			buffer[len++]='\n';
-
-			pos=begin+len;
-			if(pos<offset) {
-				len=0;
-				begin=pos;
-			}
-			if(pos>offset+length)
-				goto done;
+	for (state->bucket = 0; state->bucket <= FL_HASH_MASK; ++state->bucket) {
+		if (fl_ht[state->bucket]) {
+			fl = fl_ht[state->bucket];
+			break;
 		}
 	}
-	*eof = 1;
+	return fl;
+}
 
-done:
+static struct ip6_flowlabel *ip6fl_get_next(struct seq_file *seq, struct ip6_flowlabel *fl)
+{
+	struct ip6fl_iter_state *state = ip6fl_seq_private(seq);
+
+	fl = fl->next;
+	while (!fl) {
+		if (++state->bucket <= FL_HASH_MASK)
+			fl = fl_ht[state->bucket];
+	}
+	return fl;
+}
+
+static struct ip6_flowlabel *ip6fl_get_idx(struct seq_file *seq, loff_t pos)
+{
+	struct ip6_flowlabel *fl = ip6fl_get_first(seq);
+	if (fl)
+		while (pos && (fl = ip6fl_get_next(seq, fl)) != NULL)
+			--pos;
+	return pos ? NULL : fl;
+}
+
+static void *ip6fl_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	read_lock_bh(&ip6_fl_lock);
+	return *pos ? ip6fl_get_idx(seq, *pos) : (void *)1;
+}
+
+static void *ip6fl_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct ip6_flowlabel *fl;
+
+	if (v == (void *)1)
+		fl = ip6fl_get_first(seq);
+	else
+		fl = ip6fl_get_next(seq, v);
+	++*pos;
+	return fl;
+}
+
+static void ip6fl_seq_stop(struct seq_file *seq, void *v)
+{
 	read_unlock_bh(&ip6_fl_lock);
-	*start=buffer+(offset-begin);
-	len-=(offset-begin);
-	if(len>length)
-		len=length;
-	if(len<0)
-		len=0;
-	return len;
 }
+
+static void ip6fl_fl_seq_show(struct seq_file *seq, struct ip6_flowlabel *fl)
+{
+	while(fl) {
+		seq_printf(seq,
+			   "%05X %-1d %-6d %-6d %-6d %-8ld "
+			   "%02x%02x%02x%02x%02x%02x%02x%02x "
+			   "%-4d\n",
+			   (unsigned)ntohl(fl->label),
+			   fl->share,
+			   (unsigned)fl->owner,
+			   atomic_read(&fl->users),
+			   fl->linger/HZ,
+			   (long)(fl->expires - jiffies)/HZ,
+			   NIP6(fl->dst),
+			   fl->opt ? fl->opt->opt_nflen : 0);
+		fl = fl->next;
+	}
+}
+
+static int ip6fl_seq_show(struct seq_file *seq, void *v)
+{
+	if (v == (void *)1)
+		seq_printf(seq, "Label S Owner  Users  Linger Expires  "
+				"Dst                              Opt\n");
+	else
+		ip6fl_fl_seq_show(seq, v);
+	return 0;
+}
+
+static struct seq_operations ip6fl_seq_ops = {
+	.start	=	ip6fl_seq_start,
+	.next	=	ip6fl_seq_next,
+	.stop	=	ip6fl_seq_stop,
+	.show	=	ip6fl_seq_show,
+};
+
+static int ip6fl_seq_open(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq;
+	int rc = -ENOMEM;
+	struct ip6fl_iter_state *s = kmalloc(sizeof(*s), GFP_KERNEL);
+
+	if (!s)
+		goto out;
+
+	rc = seq_open(file, &ip6fl_seq_ops);
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
+static struct file_operations ip6fl_seq_fops = {
+	.owner		=	THIS_MODULE,
+	.open		=	ip6fl_seq_open,
+	.read		=	seq_read,
+	.llseek		=	seq_lseek,
+	.release	=	seq_release_private,
+};
 #endif
 
 
 void ip6_flowlabel_init()
 {
+#ifdef CONFIG_PROC_FS
+	struct proc_dir_entry *p;
+#endif
 	init_timer(&ip6_fl_gc_timer);
 	ip6_fl_gc_timer.function = ip6_fl_gc;
 #ifdef CONFIG_PROC_FS
-	create_proc_read_entry("net/ip6_flowlabel", 0, 0, ip6_fl_read_proc, NULL);
+	p = create_proc_entry("ip6_flowlabel", S_IRUGO, proc_net);
+	if (p)
+		p->proc_fops = &ip6fl_seq_fops;
 #endif
 }
 
@@ -621,6 +706,6 @@
 {
 	del_timer(&ip6_fl_gc_timer);
 #ifdef CONFIG_PROC_FS
-	remove_proc_entry("net/ip6_flowlabel", 0);
+	proc_net_remove("ip6_flowlabel");
 #endif
 }

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
