From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 6/6][NETNS][IPV6]: Use proper net in sockstat6
 file.
Date: Thu, 27 Mar 2008 11:21:14 +0300
Message-ID: <47EB58FA.9070905@openvz.org>
References: <47EB550B.8070401@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <dada1@cosmosbay.com>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:53156 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754676AbYC0IVV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 04:21:21 -0400
In-Reply-To: <47EB550B.8070401@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do with sockstat file what we've already done for sockstat. Same good
side effect - ipv6 reassembling stats are now shown per-net.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv6/proc.c |   41 ++++++++++++++++++++++++++++++++++-------
 1 files changed, 34 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 6a34794..783b30c 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -35,16 +35,18 @@ static struct proc_dir_entry *proc_net_devsnmp6;
 
 static int sockstat6_seq_show(struct seq_file *seq, void *v)
 {
+	struct net *net = seq->private;
+
 	seq_printf(seq, "TCP6: inuse %d\n",
-		       sock_prot_inuse_get(&init_net, &tcpv6_prot));
+		       sock_prot_inuse_get(net, &tcpv6_prot));
 	seq_printf(seq, "UDP6: inuse %d\n",
-		       sock_prot_inuse_get(&init_net, &udpv6_prot));
+		       sock_prot_inuse_get(net, &udpv6_prot));
 	seq_printf(seq, "UDPLITE6: inuse %d\n",
-			sock_prot_inuse_get(&init_net, &udplitev6_prot));
+			sock_prot_inuse_get(net, &udplitev6_prot));
 	seq_printf(seq, "RAW6: inuse %d\n",
-		       sock_prot_inuse_get(&init_net, &rawv6_prot));
+		       sock_prot_inuse_get(net, &rawv6_prot));
 	seq_printf(seq, "FRAG6: inuse %d memory %d\n",
-		       ip6_frag_nqueues(&init_net), ip6_frag_mem(&init_net));
+		       ip6_frag_nqueues(net), ip6_frag_mem(net));
 	return 0;
 }
 
@@ -183,7 +185,32 @@ static int snmp6_seq_show(struct seq_file *seq, void *v)
 
 static int sockstat6_seq_open(struct inode *inode, struct file *file)
 {
-	return single_open(file, sockstat6_seq_show, NULL);
+	int err;
+	struct net *net;
+
+	err = -ENXIO;
+	net = get_proc_net(inode);
+	if (net == NULL)
+		goto err_net;
+
+	err = single_open(file, sockstat6_seq_show, net);
+	if (err < 0)
+		goto err_open;
+
+	return 0;
+
+err_open:
+	put_net(net);
+err_net:
+	return err;
+}
+
+static int sockstat6_seq_release(struct inode *inode, struct file *file)
+{
+	struct net *net = ((struct seq_file *)file->private_data)->private;
+
+	put_net(net);
+	return single_release(inode, file);
 }
 
 static const struct file_operations sockstat6_seq_fops = {
@@ -191,7 +218,7 @@ static const struct file_operations sockstat6_seq_fops = {
 	.open	 = sockstat6_seq_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = single_release,
+	.release = sockstat6_seq_release,
 };
 
 static int snmp6_seq_open(struct inode *inode, struct file *file)
-- 
1.5.3.4

