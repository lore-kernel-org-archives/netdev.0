From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] af_netlink - convert to seq_file
Date: Tue, 2 Sep 2003 11:58:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030902115800.23ebdaeb.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert af_netlink to use seq_file interface.
Tested on 2.6.0-test4 bk latest.

diff -Nru a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
--- a/net/netlink/af_netlink.c	Tue Sep  2 11:56:11 2003
+++ b/net/netlink/af_netlink.c	Tue Sep  2 11:56:11 2003
@@ -40,6 +40,7 @@
 #include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/smp_lock.h>
 #include <linux/notifier.h>
 #include <linux/security.h>
@@ -964,62 +965,108 @@
 
 #endif
 
-
 #ifdef CONFIG_PROC_FS
-static int netlink_read_proc(char *buffer, char **start, off_t offset,
-			     int length, int *eof, void *data)
+static struct sock *netlink_seq_socket_idx(struct seq_file *seq, loff_t pos)
 {
-	off_t pos=0;
-	off_t begin=0;
-	int len=0;
 	int i;
 	struct sock *s;
 	struct hlist_node *node;
-	
-	len+= sprintf(buffer,"sk       Eth Pid    Groups   "
-		      "Rmem     Wmem     Dump     Locks\n");
-	
+	loff_t off = 0;
+
 	for (i=0; i<MAX_LINKS; i++) {
-		read_lock(&nl_table_lock);
 		sk_for_each(s, node, &nl_table[i]) {
-			struct netlink_opt *nlk = nlk_sk(s);
+			if (off == pos) {
+				seq->private = (void *) i;
+				return s;
+			}
+			++off;
+		}
+	}
+	return NULL;
+}
 
-			len+=sprintf(buffer+len,"%p %-3d %-6d %08x %-8d %-8d %p %d",
-				     s,
-				     s->sk_protocol,
-				     nlk->pid,
-				     nlk->groups,
-				     atomic_read(&s->sk_rmem_alloc),
-				     atomic_read(&s->sk_wmem_alloc),
-				     nlk->cb,
-				     atomic_read(&s->sk_refcnt)
-				     );
+static void *netlink_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	read_lock(&nl_table_lock);
+	return *pos ? netlink_seq_socket_idx(seq, *pos - 1) : (void *) 1;
+}
+
+static void *netlink_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct sock *s;
+
+	++*pos;
 
-			buffer[len++]='\n';
+	if (v == (void *) 1) 
+		return netlink_seq_socket_idx(seq, 0);
 		
-			pos=begin+len;
-			if(pos<offset) {
-				len=0;
-				begin=pos;
-			}
-			if(pos>offset+length) {
-				read_unlock(&nl_table_lock);
-				goto done;
+	s = sk_next(v);
+	if (!s) {
+		int i = (int) seq->private; 
+
+		while (++i < MAX_LINKS) {
+			s = sk_head(&nl_table[i]);
+			if (s) {
+				seq->private = (void *) i;
+				break;
 			}
 		}
-		read_unlock(&nl_table_lock);
 	}
-	*eof = 1;
+	return s;
+}
 
-done:
-	*start=buffer+(offset-begin);
-	len-=(offset-begin);
-	if(len>length)
-		len=length;
-	if(len<0)
-		len=0;
-	return len;
+static void netlink_seq_stop(struct seq_file *seq, void *v)
+{
+	read_unlock(&nl_table_lock);
+}
+
+
+static int netlink_seq_show(struct seq_file *seq, void *v)
+{
+	if (v == (void *)1) 
+		seq_puts(seq,
+			 "sk       Eth Pid    Groups   "
+			 "Rmem     Wmem     Dump     Locks\n");
+	else {
+		struct sock *s = v;
+		struct netlink_opt *nlk = nlk_sk(s);
+
+		seq_printf(seq, "%p %-3d %-6d %08x %-8d %-8d %p %d\n",
+			   s,
+			   s->sk_protocol,
+			   nlk->pid,
+			   nlk->groups,
+			   atomic_read(&s->sk_rmem_alloc),
+			   atomic_read(&s->sk_wmem_alloc),
+			   nlk->cb,
+			   atomic_read(&s->sk_refcnt)
+			);
+
+	}
+	return 0;
 }
+
+struct seq_operations netlink_seq_ops = {
+	.start  = netlink_seq_start,
+	.next   = netlink_seq_next,
+	.stop   = netlink_seq_stop,
+	.show   = netlink_seq_show,
+};
+
+
+static int netlink_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &netlink_seq_ops);
+}
+
+static struct file_operations netlink_seq_fops = {
+	.owner		= THIS_MODULE,
+	.open		= netlink_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
 #endif
 
 int netlink_register_notifier(struct notifier_block *nb)
@@ -1069,7 +1116,7 @@
 	}
 	sock_register(&netlink_family_ops);
 #ifdef CONFIG_PROC_FS
-	create_proc_read_entry("net/netlink", 0, 0, netlink_read_proc, NULL);
+	proc_net_fops_create("netlink", 0, &netlink_seq_fops);
 #endif
 	/* The netlink device handler may be needed early. */ 
 	rtnetlink_init();
@@ -1079,7 +1126,7 @@
 static void __exit netlink_proto_exit(void)
 {
        sock_unregister(PF_NETLINK);
-       remove_proc_entry("net/netlink", NULL);
+       proc_net_remove("netlink");
 }
 
 core_initcall(netlink_proto_init);
