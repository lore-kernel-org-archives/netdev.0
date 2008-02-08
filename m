From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/2][KEY]: Convert net/pfkey to use seq files.
Date: Fri, 08 Feb 2008 15:14:06 +0300
Message-ID: <47AC478E.3070507@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:53017 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754111AbYBHMOG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2008 07:14:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The seq files API disposes the caller of the difficulty of
checking file position, the length of data to produce and
the size of provided buffer.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/key/af_key.c |   94 +++++++++++++++++++++++++++++++++--------------------
 1 files changed, 58 insertions(+), 36 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 162fcea..9793511 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3734,21 +3734,15 @@ static struct net_proto_family pfkey_family_ops = {
 };
 
 #ifdef CONFIG_PROC_FS
-static int pfkey_read_proc(char *buffer, char **start, off_t offset,
-			   int length, int *eof, void *data)
+static int pfkey_seq_show(struct seq_file *f, void *v)
 {
-	off_t pos = 0;
-	off_t begin = 0;
-	int len = 0;
 	struct sock *s;
-	struct hlist_node *node;
-
-	len += sprintf(buffer,"sk       RefCnt Rmem   Wmem   User   Inode\n");
-
-	read_lock(&pfkey_table_lock);
-
-	sk_for_each(s, node, &pfkey_table) {
-		len += sprintf(buffer+len,"%p %-6d %-6u %-6u %-6u %-6lu",
+		
+	s = (struct sock *)v;
+	if (v == SEQ_START_TOKEN)
+		seq_printf(f ,"sk       RefCnt Rmem   Wmem   User   Inode\n");
+	else
+		seq_printf(f ,"%p %-6d %-6u %-6u %-6u %-6lu\n",
 			       s,
 			       atomic_read(&s->sk_refcnt),
 			       atomic_read(&s->sk_rmem_alloc),
@@ -3756,40 +3750,68 @@ static int pfkey_read_proc(char *buffer, char **start, off_t offset,
 			       sock_i_uid(s),
 			       sock_i_ino(s)
 			       );
+	return 0;
+}
 
-		buffer[len++] = '\n';
+static void *pfkey_seq_start(struct seq_file *f, loff_t *ppos)
+{
+	struct sock *s;
+	struct hlist_node *node;
+	loff_t pos = *ppos;
 
-		pos = begin + len;
-		if (pos < offset) {
-			len = 0;
-			begin = pos;
-		}
-		if(pos > offset + length)
-			goto done;
-	}
-	*eof = 1;
+	read_lock(&pfkey_table_lock);
+	if (pos == 0)
+		return SEQ_START_TOKEN;
 
-done:
-	read_unlock(&pfkey_table_lock);
+	sk_for_each(s, node, &pfkey_table)
+		if (pos-- == 1)
+			return s;
 
-	*start = buffer + (offset - begin);
-	len -= (offset - begin);
+	return NULL;
+}
 
-	if (len > length)
-		len = length;
-	if (len < 0)
-		len = 0;
+static void *pfkey_seq_next(struct seq_file *f, void *v, loff_t *ppos)
+{
+	++*ppos;
+	return (v == SEQ_START_TOKEN) ?
+		sk_head(&pfkey_table) :
+			sk_next((struct sock *)v);
+}
+
+static void pfkey_seq_stop(struct seq_file *f, void *v)
+{
+	read_unlock(&pfkey_table_lock);
+}
+
+static struct seq_operations pfkey_seq_ops = {
+	.start	= pfkey_seq_start,
+	.next	= pfkey_seq_next,
+	.stop	= pfkey_seq_stop,
+	.show	= pfkey_seq_show,
+};
 
-	return len;
+static int pfkey_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &pfkey_seq_ops);
 }
 
+static struct file_operations pfkey_proc_ops = {
+	.open	 = pfkey_seq_open,
+	.read	 = seq_read,
+	.llseek	 = seq_lseek,
+	.release = seq_release,
+};
+
 static int pfkey_init_proc(void)
 {
-	if (create_proc_read_entry("pfkey", 0, init_net.proc_net,
-				pfkey_read_proc, NULL) == NULL)
+	struct proc_dir_entry *e;
+
+	e = create_proc_entry("pfkey", 0, init_net.proc_net);
+	if (e == NULL)
 		return -ENOMEM;
-	else
-		return 0;
+
+	e->proc_fops = &pfkey_proc_ops;
+	return 0;
 }
 
 static void pfkey_exit_proc(void)
-- 
1.5.3.4

