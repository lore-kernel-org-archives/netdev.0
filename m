From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: convert /proc/net/rt_acct to seq_file
Date: Wed, 25 Nov 2009 10:45:47 +0300
Message-ID: <20091125074547.GA3467@x200.malnet.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:3442 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbZKYHpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 02:45:46 -0500
Received: by ey-out-2122.google.com with SMTP id 4so1454771eyf.19
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2009 23:45:51 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rewrite statistics accumulation to be in terms of structure fields,
not raw u32 additions. Keep them in same order, though.

This is the last user of create_proc_read_entry() in net/,
please NAK all new ones as well as all new ->write_proc, ->read_proc and
create_proc_entry() users. Cc me if there are problems. :-)

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/route.c |   68 ++++++++++++++++++++++++++-----------------------------
 1 file changed, 33 insertions(+), 35 deletions(-)

--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -513,43 +513,42 @@ static const struct file_operations rt_cpu_seq_fops = {
 };
 
 #ifdef CONFIG_NET_CLS_ROUTE
-static int ip_rt_acct_read(char *buffer, char **start, off_t offset,
-			   int length, int *eof, void *data)
-{
-	unsigned int i;
-
-	if ((offset & 3) || (length & 3))
-		return -EIO;
-
-	if (offset >= sizeof(struct ip_rt_acct) * 256) {
-		*eof = 1;
-		return 0;
-	}
-
-	if (offset + length >= sizeof(struct ip_rt_acct) * 256) {
-		length = sizeof(struct ip_rt_acct) * 256 - offset;
-		*eof = 1;
+static int rt_acct_proc_show(struct seq_file *m, void *v)
+{
+	struct ip_rt_acct *dst, *src;
+	unsigned int i, j;
+
+	dst = kcalloc(256, sizeof(struct ip_rt_acct), GFP_KERNEL);
+	if (!dst)
+		return -ENOMEM;
+
+	for_each_possible_cpu(i) {
+		src = (struct ip_rt_acct *)per_cpu_ptr(ip_rt_acct, i);
+		for (j = 0; j < 256; j++) {
+			dst[j].o_bytes   += src[j].o_bytes;
+			dst[j].o_packets += src[j].o_packets;
+			dst[j].i_bytes   += src[j].i_bytes;
+			dst[j].i_packets += src[j].i_packets;
+		}
 	}
 
-	offset /= sizeof(u32);
-
-	if (length > 0) {
-		u32 *dst = (u32 *) buffer;
-
-		*start = buffer;
-		memset(dst, 0, length);
-
-		for_each_possible_cpu(i) {
-			unsigned int j;
-			u32 *src;
+	seq_write(m, dst, 256 * sizeof(struct ip_rt_acct));
+	kfree(dst);
+	return 0;
+}
 
-			src = ((u32 *) per_cpu_ptr(ip_rt_acct, i)) + offset;
-			for (j = 0; j < length/4; j++)
-				dst[j] += src[j];
-		}
-	}
-	return length;
+static int rt_acct_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, rt_acct_proc_show, NULL);
 }
+
+static const struct file_operations rt_acct_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= rt_acct_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
 #endif
 
 static int __net_init ip_rt_do_proc_init(struct net *net)
@@ -567,8 +566,7 @@ static int __net_init ip_rt_do_proc_init(struct net *net)
 		goto err2;
 
 #ifdef CONFIG_NET_CLS_ROUTE
-	pde = create_proc_read_entry("rt_acct", 0, net->proc_net,
-			ip_rt_acct_read, NULL);
+	pde = proc_create("rt_acct", 0, net->proc_net, &rt_acct_proc_fops);
 	if (!pde)
 		goto err3;
 #endif
