From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH 2/3] net: ipv4: make the ping /proc code AF-independent
Date: Tue, 28 May 2013 23:45:14 +0900
Message-ID: <1369752315-11167-2-git-send-email-lorenzo@google.com>
References: <1369752315-11167-1-git-send-email-lorenzo@google.com>
Cc: Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Vasiliy Kulikov <segoon@openwall.com>,
	Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:38969 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934359Ab3E1Opc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 10:45:32 -0400
Received: by mail-qa0-f74.google.com with SMTP id bs12so311442qab.3
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 07:45:31 -0700 (PDT)
In-Reply-To: <1369752315-11167-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a ping_seq_afinfo structure (similar to its UDP
equivalent) and use it to make some of the ping /proc functions
address-family independent. Rename the remaining ping /proc
functions from ping_* to ping_v4_*.

Compiles and displays reasonable results with CONFIG_IPV6={n,m,y}

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/net/ping.h |  8 ++++++
 net/ipv4/ping.c    | 73 +++++++++++++++++++++++++++++++++++-------------------
 2 files changed, 55 insertions(+), 26 deletions(-)

diff --git a/include/net/ping.h b/include/net/ping.h
index 9242fa0..b9282f0 100644
--- a/include/net/ping.h
+++ b/include/net/ping.h
@@ -49,6 +49,7 @@ struct ping_table {
 struct ping_iter_state {
 	struct seq_net_private  p;
 	int			bucket;
+	sa_family_t		family;
 };
 
 extern struct proto ping_prot;
@@ -87,6 +88,13 @@ int  ping_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 void ping_rcv(struct sk_buff *skb);
 
 #ifdef CONFIG_PROC_FS
+struct ping_seq_afinfo {
+	char				*name;
+	sa_family_t			family;
+	const struct file_operations	*seq_fops;
+	const struct seq_operations	seq_ops;
+};
+
 extern int __init ping_proc_init(void);
 extern void ping_proc_exit(void);
 #endif
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 71f6ad0..8c2da9b 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -1001,7 +1001,8 @@ static struct sock *ping_get_first(struct seq_file *seq, int start)
 			continue;
 
 		sk_nulls_for_each(sk, node, hslot) {
-			if (net_eq(sock_net(sk), net))
+			if (net_eq(sock_net(sk), net) &&
+			    sk->sk_family == state->family)
 				goto found;
 		}
 	}
@@ -1034,16 +1035,23 @@ static struct sock *ping_get_idx(struct seq_file *seq, loff_t pos)
 	return pos ? NULL : sk;
 }
 
-static void *ping_seq_start(struct seq_file *seq, loff_t *pos)
+static void *ping_seq_start(struct seq_file *seq, loff_t *pos,
+			    sa_family_t family)
 {
 	struct ping_iter_state *state = seq->private;
 	state->bucket = 0;
+	state->family = family;
 
 	read_lock_bh(&ping_table.lock);
 
 	return *pos ? ping_get_idx(seq, *pos-1) : SEQ_START_TOKEN;
 }
 
+static void *ping_v4_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	return ping_seq_start(seq, pos, AF_INET);
+}
+
 static void *ping_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct sock *sk;
@@ -1062,7 +1070,7 @@ static void ping_seq_stop(struct seq_file *seq, void *v)
 	read_unlock_bh(&ping_table.lock);
 }
 
-static void ping_format_sock(struct sock *sp, struct seq_file *f,
+static void ping_v4_format_sock(struct sock *sp, struct seq_file *f,
 		int bucket, int *len)
 {
 	struct inet_sock *inet = inet_sk(sp);
@@ -1083,7 +1091,7 @@ static void ping_format_sock(struct sock *sp, struct seq_file *f,
 		atomic_read(&sp->sk_drops), len);
 }
 
-static int ping_seq_show(struct seq_file *seq, void *v)
+static int ping_v4_seq_show(struct seq_file *seq, void *v)
 {
 	if (v == SEQ_START_TOKEN)
 		seq_printf(seq, "%-127s\n",
@@ -1094,22 +1102,23 @@ static int ping_seq_show(struct seq_file *seq, void *v)
 		struct ping_iter_state *state = seq->private;
 		int len;
 
-		ping_format_sock(v, seq, state->bucket, &len);
+		ping_v4_format_sock(v, seq, state->bucket, &len);
 		seq_printf(seq, "%*s\n", 127 - len, "");
 	}
 	return 0;
 }
 
-static const struct seq_operations ping_seq_ops = {
-	.show		= ping_seq_show,
-	.start		= ping_seq_start,
+static const struct seq_operations ping_v4_seq_ops = {
+	.show		= ping_v4_seq_show,
+	.start		= ping_v4_seq_start,
 	.next		= ping_seq_next,
 	.stop		= ping_seq_stop,
 };
 
 static int ping_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open_net(inode, file, &ping_seq_ops,
+	struct ping_seq_afinfo *afinfo = PDE_DATA(inode);
+	return seq_open_net(inode, file, &afinfo->seq_ops,
 			   sizeof(struct ping_iter_state));
 }
 
@@ -1120,46 +1129,58 @@ static const struct file_operations ping_seq_fops = {
 	.release	= seq_release_net,
 };
 
-static int ping_proc_register(struct net *net)
+static struct ping_seq_afinfo ping_v4_seq_afinfo = {
+	.name		= "icmp",
+	.family		= AF_INET,
+	.seq_fops	= &ping_seq_fops,
+	.seq_ops	= {
+		.start		= ping_v4_seq_start,
+		.show		= ping_v4_seq_show,
+		.next		= ping_seq_next,
+		.stop		= ping_seq_stop,
+	},
+};
+
+static int ping_proc_register(struct net *net, struct ping_seq_afinfo *afinfo)
 {
 	struct proc_dir_entry *p;
-	int rc = 0;
-
-	p = proc_create("icmp", S_IRUGO, net->proc_net, &ping_seq_fops);
+	p = proc_create_data(afinfo->name, S_IRUGO, net->proc_net,
+			     afinfo->seq_fops, afinfo);
 	if (!p)
-		rc = -ENOMEM;
-	return rc;
+		return -ENOMEM;
+	return 0;
 }
 
-static void ping_proc_unregister(struct net *net)
+static void ping_proc_unregister(struct net *net,
+				 struct ping_seq_afinfo *afinfo)
 {
-	remove_proc_entry("icmp", net->proc_net);
+	remove_proc_entry(afinfo->name, net->proc_net);
 }
 
 
-static int __net_init ping_proc_init_net(struct net *net)
+static int __net_init ping_v4_proc_init_net(struct net *net)
 {
-	return ping_proc_register(net);
+	return ping_proc_register(net, &ping_v4_seq_afinfo);
 }
 
-static void __net_exit ping_proc_exit_net(struct net *net)
+static void __net_exit ping_v4_proc_exit_net(struct net *net)
 {
-	ping_proc_unregister(net);
+	ping_proc_unregister(net, &ping_v4_seq_afinfo);
 }
 
-static struct pernet_operations ping_net_ops = {
-	.init = ping_proc_init_net,
-	.exit = ping_proc_exit_net,
+static struct pernet_operations ping_v4_net_ops = {
+	.init = ping_v4_proc_init_net,
+	.exit = ping_v4_proc_exit_net,
 };
 
 int __init ping_proc_init(void)
 {
-	return register_pernet_subsys(&ping_net_ops);
+	return register_pernet_subsys(&ping_v4_net_ops);
 }
 
 void ping_proc_exit(void)
 {
-	unregister_pernet_subsys(&ping_net_ops);
+	unregister_pernet_subsys(&ping_v4_net_ops);
 }
 
 #endif
-- 
1.8.2.1
