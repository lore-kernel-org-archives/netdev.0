From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] convert /proc/net/packet to seq_file
Date: Mon, 5 Jan 2004 12:16:54 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040105121654.3cfbdfb6.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert AF_PACKET's /proc interface to seq_file. No change in functionality,
but does fix problem with refcounting on this proc interface.

diff -Nru a/net/packet/af_packet.c b/net/packet/af_packet.c
--- a/net/packet/af_packet.c	Mon Jan  5 12:14:55 2004
+++ b/net/packet/af_packet.c	Mon Jan  5 12:14:55 2004
@@ -64,6 +64,7 @@
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/poll.h>
 #include <linux/module.h>
 #include <linux/init.h>
@@ -1767,61 +1768,86 @@
 };
 
 #ifdef CONFIG_PROC_FS
-static int packet_read_proc(char *buffer, char **start, off_t offset,
-			     int length, int *eof, void *data)
+static inline struct sock *packet_seq_idx(loff_t off)
 {
-	off_t pos=0;
-	off_t begin=0;
-	int len=0;
 	struct sock *s;
 	struct hlist_node *node;
-	
-	len+= sprintf(buffer,"sk       RefCnt Type Proto  Iface R Rmem   User   Inode\n");
 
+	sk_for_each(s, node, &packet_sklist) {
+		if (!off--)
+			return s;
+	}
+	return NULL;
+}
+
+static void *packet_seq_start(struct seq_file *seq, loff_t *pos)
+{
 	read_lock(&packet_sklist_lock);
+	return *pos ? packet_seq_idx(*pos - 1) : SEQ_START_TOKEN;
+}
 
-	sk_for_each(s, node, &packet_sklist) {
-		struct packet_opt *po = pkt_sk(s);
+static void *packet_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	++*pos;
+	return  (v == SEQ_START_TOKEN) 
+		? sk_head(&packet_sklist) 
+		: sk_next((struct sock*)v) ;
+}
 
-		len+=sprintf(buffer+len,"%p %-6d %-4d %04x   %-5d %1d %-6u %-6u %-6lu",
-			     s,
-			     atomic_read(&s->sk_refcnt),
-			     s->sk_type,
-			     ntohs(po->num),
-			     po->ifindex,
-			     po->running,
-			     atomic_read(&s->sk_rmem_alloc),
-			     sock_i_uid(s),
-			     sock_i_ino(s)
-			     );
+static void packet_seq_stop(struct seq_file *seq, void *v)
+{
+	read_unlock(&packet_sklist_lock);		
+}
 
-		buffer[len++]='\n';
-		
-		pos=begin+len;
-		if(pos<offset) {
-			len=0;
-			begin=pos;
-		}
-		if(pos>offset+length)
-			goto done;
+static int packet_seq_show(struct seq_file *seq, void *v) 
+{
+	if (v == SEQ_START_TOKEN)
+		seq_puts(seq, "sk       RefCnt Type Proto  Iface R Rmem   User   Inode\n");
+	else {
+		struct sock *s = v;
+		const struct packet_opt *po = pkt_sk(s);
+
+		seq_printf(seq,
+			   "%p %-6d %-4d %04x   %-5d %1d %-6u %-6u %-6lu\n",
+			   s,
+			   atomic_read(&s->sk_refcnt),
+			   s->sk_type,
+			   ntohs(po->num),
+			   po->ifindex,
+			   po->running,
+			   atomic_read(&s->sk_rmem_alloc),
+			   sock_i_uid(s),
+			   sock_i_ino(s) );
 	}
-	*eof = 1;
 
-done:
-	read_unlock(&packet_sklist_lock);
-	*start=buffer+(offset-begin);
-	len-=(offset-begin);
-	if(len>length)
-		len=length;
-	if(len<0)
-		len=0;
-	return len;
+	return 0;
 }
+
+static struct seq_operations packet_seq_ops = {
+	.start	= packet_seq_start,
+	.next	= packet_seq_next,
+	.stop	= packet_seq_stop,
+	.show	= packet_seq_show,
+};
+
+static int packet_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &packet_seq_ops);
+}
+
+static struct file_operations packet_seq_fops = {
+	.owner		= THIS_MODULE,
+	.open		= packet_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
 #endif
 
 static void __exit packet_exit(void)
 {
-	remove_proc_entry("net/packet", 0);
+	proc_net_remove("packet");
 	unregister_netdevice_notifier(&packet_netdev_notifier);
 	sock_unregister(PF_PACKET);
 	return;
@@ -1831,9 +1857,8 @@
 {
 	sock_register(&packet_family_ops);
 	register_netdevice_notifier(&packet_netdev_notifier);
-#ifdef CONFIG_PROC_FS
-	create_proc_read_entry("net/packet", 0, 0, packet_read_proc, NULL);
-#endif
+	proc_net_fops_create("packet", 0, &packet_seq_fops);
+
 	return 0;
 }
 
