From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 5/6][NETNS][IPV4]: Use proper net in sockstat file.
Date: Thu, 27 Mar 2008 11:19:45 +0300
Message-ID: <47EB58A1.6060101@openvz.org>
References: <47EB550B.8070401@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <dada1@cosmosbay.com>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:52721 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751878AbYC0ITv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 04:19:51 -0400
In-Reply-To: <47EB550B.8070401@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now show the per-net inuse values in sockstat file.

Besides, now we can see per-net fragments statistics in the
same file, since this stats is already per-net.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/proc.c |   41 ++++++++++++++++++++++++++++++++++-------
 1 files changed, 34 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 24ae23b..552169b 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -51,27 +51,54 @@
  */
 static int sockstat_seq_show(struct seq_file *seq, void *v)
 {
+	struct net *net = seq->private;
+
 	socket_seq_show(seq);
 	seq_printf(seq, "TCP: inuse %d orphan %d tw %d alloc %d mem %d\n",
-		   sock_prot_inuse_get(&init_net, &tcp_prot),
+		   sock_prot_inuse_get(net, &tcp_prot),
 		   atomic_read(&tcp_orphan_count),
 		   tcp_death_row.tw_count, atomic_read(&tcp_sockets_allocated),
 		   atomic_read(&tcp_memory_allocated));
 	seq_printf(seq, "UDP: inuse %d mem %d\n",
-		   sock_prot_inuse_get(&init_net, &udp_prot),
+		   sock_prot_inuse_get(net, &udp_prot),
 		   atomic_read(&udp_memory_allocated));
 	seq_printf(seq, "UDPLITE: inuse %d\n",
-		   sock_prot_inuse_get(&init_net, &udplite_prot));
+		   sock_prot_inuse_get(net, &udplite_prot));
 	seq_printf(seq, "RAW: inuse %d\n",
-		   sock_prot_inuse_get(&init_net, &raw_prot));
+		   sock_prot_inuse_get(net, &raw_prot));
 	seq_printf(seq,  "FRAG: inuse %d memory %d\n",
-			ip_frag_nqueues(&init_net), ip_frag_mem(&init_net));
+			ip_frag_nqueues(net), ip_frag_mem(net));
 	return 0;
 }
 
 static int sockstat_seq_open(struct inode *inode, struct file *file)
 {
-	return single_open(file, sockstat_seq_show, NULL);
+	int err;
+	struct net *net;
+
+	err = -ENXIO;
+	net = get_proc_net(inode);
+	if (net == NULL)
+		goto err_net;
+
+	err = single_open(file, sockstat_seq_show, net);
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
+static int sockstat_seq_release(struct inode *inode, struct file *file)
+{
+	struct net *net = ((struct seq_file *)file->private_data)->private;
+
+	put_net(net);
+	return single_release(inode, file);
 }
 
 static const struct file_operations sockstat_seq_fops = {
@@ -79,7 +106,7 @@ static const struct file_operations sockstat_seq_fops = {
 	.open	 = sockstat_seq_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = single_release,
+	.release = sockstat_seq_release,
 };
 
 /* snmp items */
-- 
1.5.3.4

