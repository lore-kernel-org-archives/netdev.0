From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH v3 3/3] net: ipv6: Implement /proc/net/icmp6.
Date: Wed, 29 May 2013 14:47:39 +0900
Message-ID: <1369806459-26901-4-git-send-email-lorenzo@google.com>
References: <ko3rsc@ger.gmane.org>
 <1369806459-26901-1-git-send-email-lorenzo@google.com>
Cc: Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Vasiliy Kulikov <segoon@openwall.com>,
	Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f74.google.com ([209.85.212.74]:47854 "EHLO
	mail-vb0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754425Ab3E2Fry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 01:47:54 -0400
Received: by mail-vb0-f74.google.com with SMTP id w15so759184vbf.5
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 22:47:53 -0700 (PDT)
In-Reply-To: <1369806459-26901-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The format is based on /proc/net/icmp and /proc/net/{udp,raw}6.

Compiles and displays reasonable results with CONFIG_IPV6={n,m,y}
Couldn't figure out how to test without CONFIG_PROC_FS enabled.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/net/ping.h |   8 +++++
 net/ipv4/ping.c    |  21 ++++++-----
 net/ipv6/ping.c    | 102 +++++++++++++++++++++++++++++++++++++++++------------
 3 files changed, 99 insertions(+), 32 deletions(-)

diff --git a/include/net/ping.h b/include/net/ping.h
index b9282f0..db04802 100644
--- a/include/net/ping.h
+++ b/include/net/ping.h
@@ -95,6 +95,14 @@ struct ping_seq_afinfo {
 	const struct seq_operations	seq_ops;
 };
 
+extern const struct file_operations ping_seq_fops;
+
+void *ping_seq_start(struct seq_file *seq, loff_t *pos, sa_family_t family);
+void *ping_seq_next(struct seq_file *seq, void *v, loff_t *pos);
+void ping_seq_stop(struct seq_file *seq, void *v);
+int ping_proc_register(struct net *net, struct ping_seq_afinfo *afinfo);
+void ping_proc_unregister(struct net *net, struct ping_seq_afinfo *afinfo);
+
 extern int __init ping_proc_init(void);
 extern void ping_proc_exit(void);
 #endif
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 8c2da9b..3552a45 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -1035,8 +1035,7 @@ static struct sock *ping_get_idx(struct seq_file *seq, loff_t pos)
 	return pos ? NULL : sk;
 }
 
-static void *ping_seq_start(struct seq_file *seq, loff_t *pos,
-			    sa_family_t family)
+void *ping_seq_start(struct seq_file *seq, loff_t *pos, sa_family_t family)
 {
 	struct ping_iter_state *state = seq->private;
 	state->bucket = 0;
@@ -1046,13 +1045,14 @@ static void *ping_seq_start(struct seq_file *seq, loff_t *pos,
 
 	return *pos ? ping_get_idx(seq, *pos-1) : SEQ_START_TOKEN;
 }
+EXPORT_SYMBOL_GPL(ping_seq_start);
 
 static void *ping_v4_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	return ping_seq_start(seq, pos, AF_INET);
 }
 
-static void *ping_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+void *ping_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct sock *sk;
 
@@ -1064,11 +1064,13 @@ static void *ping_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	++*pos;
 	return sk;
 }
+EXPORT_SYMBOL_GPL(ping_seq_next);
 
-static void ping_seq_stop(struct seq_file *seq, void *v)
+void ping_seq_stop(struct seq_file *seq, void *v)
 {
 	read_unlock_bh(&ping_table.lock);
 }
+EXPORT_SYMBOL_GPL(ping_seq_stop);
 
 static void ping_v4_format_sock(struct sock *sp, struct seq_file *f,
 		int bucket, int *len)
@@ -1122,12 +1124,13 @@ static int ping_seq_open(struct inode *inode, struct file *file)
 			   sizeof(struct ping_iter_state));
 }
 
-static const struct file_operations ping_seq_fops = {
+const struct file_operations ping_seq_fops = {
 	.open		= ping_seq_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
 	.release	= seq_release_net,
 };
+EXPORT_SYMBOL_GPL(ping_seq_fops);
 
 static struct ping_seq_afinfo ping_v4_seq_afinfo = {
 	.name		= "icmp",
@@ -1141,7 +1144,7 @@ static struct ping_seq_afinfo ping_v4_seq_afinfo = {
 	},
 };
 
-static int ping_proc_register(struct net *net, struct ping_seq_afinfo *afinfo)
+int ping_proc_register(struct net *net, struct ping_seq_afinfo *afinfo)
 {
 	struct proc_dir_entry *p;
 	p = proc_create_data(afinfo->name, S_IRUGO, net->proc_net,
@@ -1150,13 +1153,13 @@ static int ping_proc_register(struct net *net, struct ping_seq_afinfo *afinfo)
 		return -ENOMEM;
 	return 0;
 }
+EXPORT_SYMBOL_GPL(ping_proc_register);
 
-static void ping_proc_unregister(struct net *net,
-				 struct ping_seq_afinfo *afinfo)
+void ping_proc_unregister(struct net *net, struct ping_seq_afinfo *afinfo)
 {
 	remove_proc_entry(afinfo->name, net->proc_net);
 }
-
+EXPORT_SYMBOL_GPL(ping_proc_unregister);
 
 static int __net_init ping_v4_proc_init_net(struct net *net)
 {
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index a6462d6..62ac5f2 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -78,29 +78,6 @@ int dummy_ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
 	return 0;
 }
 
-int __init pingv6_init(void)
-{
-	pingv6_ops.ipv6_recv_error = ipv6_recv_error;
-	pingv6_ops.ip6_datagram_recv_ctl = ip6_datagram_recv_ctl;
-	pingv6_ops.icmpv6_err_convert = icmpv6_err_convert;
-	pingv6_ops.ipv6_icmp_error = ipv6_icmp_error;
-	pingv6_ops.ipv6_chk_addr = ipv6_chk_addr;
-	return inet6_register_protosw(&pingv6_protosw);
-}
-
-/* This never gets called because it's not possible to unload the ipv6 module,
- * but just in case.
- */
-void pingv6_exit(void)
-{
-	pingv6_ops.ipv6_recv_error = dummy_ipv6_recv_error;
-	pingv6_ops.ip6_datagram_recv_ctl = dummy_ip6_datagram_recv_ctl;
-	pingv6_ops.icmpv6_err_convert = dummy_icmpv6_err_convert;
-	pingv6_ops.ipv6_icmp_error = dummy_ipv6_icmp_error;
-	pingv6_ops.ipv6_chk_addr = dummy_ipv6_chk_addr;
-	inet6_unregister_protosw(&pingv6_protosw);
-}
-
 int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		    size_t len)
 {
@@ -214,3 +191,82 @@ int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	return err;
 }
+
+#ifdef CONFIG_PROC_FS
+static void *ping_v6_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	return ping_seq_start(seq, pos, AF_INET6);
+}
+
+int ping_v6_seq_show(struct seq_file *seq, void *v)
+{
+	if (v == SEQ_START_TOKEN) {
+		seq_puts(seq, IPV6_SEQ_DGRAM_HEADER);
+	} else {
+		int bucket = ((struct ping_iter_state *) seq->private)->bucket;
+		struct inet_sock *inet = inet_sk(v);
+		__u16 srcp = ntohs(inet->inet_sport);
+		__u16 destp = ntohs(inet->inet_dport);
+		ip6_dgram_sock_seq_show(seq, v, srcp, destp, bucket);
+	}
+	return 0;
+}
+
+static struct ping_seq_afinfo ping_v6_seq_afinfo = {
+	.name		= "icmp6",
+	.family		= AF_INET6,
+	.seq_fops       = &ping_seq_fops,
+	.seq_ops	= {
+		.start		= ping_v6_seq_start,
+		.show		= ping_v6_seq_show,
+		.next		= ping_seq_next,
+		.stop		= ping_seq_stop,
+	},
+};
+
+static int __net_init ping_v6_proc_init_net(struct net *net)
+{
+	return ping_proc_register(net, &ping_v6_seq_afinfo);
+}
+
+static void __net_init ping_v6_proc_exit_net(struct net *net)
+{
+	return ping_proc_unregister(net, &ping_v6_seq_afinfo);
+}
+
+static struct pernet_operations ping_v6_net_ops = {
+	.init = ping_v6_proc_init_net,
+	.exit = ping_v6_proc_exit_net,
+};
+#endif
+
+int __init pingv6_init(void)
+{
+#ifdef CONFIG_PROC_FS
+	int ret = register_pernet_subsys(&ping_v6_net_ops);
+	if (ret)
+		return ret;
+#endif
+	pingv6_ops.ipv6_recv_error = ipv6_recv_error;
+	pingv6_ops.ip6_datagram_recv_ctl = ip6_datagram_recv_ctl;
+	pingv6_ops.icmpv6_err_convert = icmpv6_err_convert;
+	pingv6_ops.ipv6_icmp_error = ipv6_icmp_error;
+	pingv6_ops.ipv6_chk_addr = ipv6_chk_addr;
+	return inet6_register_protosw(&pingv6_protosw);
+}
+
+/* This never gets called because it's not possible to unload the ipv6 module,
+ * but just in case.
+ */
+void pingv6_exit(void)
+{
+	pingv6_ops.ipv6_recv_error = dummy_ipv6_recv_error;
+	pingv6_ops.ip6_datagram_recv_ctl = dummy_ip6_datagram_recv_ctl;
+	pingv6_ops.icmpv6_err_convert = dummy_icmpv6_err_convert;
+	pingv6_ops.ipv6_icmp_error = dummy_ipv6_icmp_error;
+	pingv6_ops.ipv6_chk_addr = dummy_ipv6_chk_addr;
+#ifdef CONFIG_PROC_FS
+	unregister_pernet_subsys(&ping_v6_net_ops);
+#endif
+	inet6_unregister_protosw(&pingv6_protosw);
+}
-- 
1.8.2.1
