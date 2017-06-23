From: Ivan Delalande <colona@arista.com>
Subject: [PATCH 2/2] tcp: md5: export all configured signature keys in /proc/net
Date: Thu, 22 Jun 2017 18:40:28 -0700
Message-ID: <20170623014028.28257-2-colona@arista.com>
References: <20170623014028.28257-1-colona@arista.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Ivan Delalande <colona@arista.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170623014028.28257-1-colona@arista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add files "tcpmd5" and "tcp6md5" in /proc/net containing all the TCP
MD5 keys configured for sockets using this signature option (RFC2385).
These files contain a line for each key configured on each socket, with
the index number of the socket (as found in /proc/net/tcp{,6}), its
inode number, the address, prefix length and the key itself.

Note that IPv4-mapped IPv6 addresses will be printed as a regular IPv4
address in the tcp6md5 file.

Signed-off-by: Ani Sinha <ani@arista.com>
Signed-off-by: Ken Kofman <kkofman@arista.com>
Signed-off-by: Ivan Delalande <colona@arista.com>
---
 Documentation/filesystems/proc.txt |  2 ++
 include/net/tcp.h                  |  1 +
 net/ipv4/tcp.c                     | 55 ++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_ipv4.c                | 29 +++++++++++++++++++-
 net/ipv6/tcp_ipv6.c                | 29 +++++++++++++++++++-
 5 files changed, 114 insertions(+), 2 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 4cddbce85ac9..d52a03b2e534 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -1105,6 +1105,7 @@ Table 1-8: IPv6 info in /proc/net
  File       Content                                               
  udp6       UDP sockets (IPv6)                                    
  tcp6       TCP sockets (IPv6)                                    
+ tcp6md5    MD5 signature keys configured on IPv6 TCP sockets
  raw6       Raw device statistics (IPv6)                          
  igmp6      IP multicast addresses, which this host joined (IPv6) 
  if_inet6   List of IPv6 interface addresses                      
@@ -1136,6 +1137,7 @@ Table 1-9: Network info in /proc/net
  snmp          SNMP data                                                       
  sockstat      Socket statistics                                               
  tcp           TCP  sockets                                                    
+ tcpmd5        MD5 signature keys configured on IPv4 TCP sockets
  udp           UDP sockets                                                     
  unix          UNIX domain sockets                                             
  wireless      Wireless interface data (Wavelan etc)                           
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5d78f9af309e..95c9dc47e0c5 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1450,6 +1450,7 @@ struct tcp_md5sig_key *tcp_v4_md5_lookup(const struct sock *sk,
 struct tcp_md5sig_key *tcp_md5_do_lookup(const struct sock *sk,
 					 const union tcp_md5_addr *addr,
 					 int family);
+int tcp_md5_seq_show(struct seq_file *seq, void *v);
 #define tcp_twsk_md5_key(twsk)	((twsk)->tw_md5_key)
 #else
 static inline struct tcp_md5sig_key *tcp_md5_do_lookup(const struct sock *sk,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 2a68221d2e55..47bcaeed3605 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3279,6 +3279,61 @@ int tcp_md5_hash_key(struct tcp_md5sig_pool *hp, const struct tcp_md5sig_key *ke
 }
 EXPORT_SYMBOL(tcp_md5_hash_key);
 
+static void do_md5_seq_print_key(struct seq_file *seq,
+				 const struct tcp_iter_state *st,
+				 const struct tcp_md5sig_key *key,
+				 unsigned long ino)
+{
+	if (key->keylen == 0)
+		return;
+
+	seq_printf(seq, "%4d: %6lu ", st->num, ino);
+	if (key->family == AF_INET)
+		seq_printf(seq, "%39pI4/%-3u ", &key->addr.a4, key->prefixlen);
+	else
+		seq_printf(seq, "%39pI6c/%-3u ", &key->addr.a6, key->prefixlen);
+	seq_printf(seq, "%*pE\n", key->keylen, key->key);
+}
+
+int tcp_md5_seq_show(struct seq_file *seq, void *v)
+{
+	struct sock *sp = v;
+	const struct tcp_sock *tp = tcp_sk(sp);
+	const struct tcp_iter_state *st = seq->private;
+	const struct tcp_md5sig_info *md5sig;
+	const struct tcp_md5sig_key *key;
+	unsigned long ino;
+
+	if (v == SEQ_START_TOKEN) {
+		seq_puts(seq, "  sl  inode  addr                                        key\n");
+		goto out;
+	}
+
+	if (sp->sk_state == TCP_TIME_WAIT) {
+		const struct tcp_timewait_sock *tcptw = tcp_twsk(sp);
+
+		key = tcptw->tw_md5_key;
+		if (key)
+			do_md5_seq_print_key(seq, st, key, 0);
+		goto out;
+	}
+
+	ino = sock_i_ino(sp);
+	rcu_read_lock();
+	md5sig = rcu_dereference(tp->md5sig_info);
+	if (!md5sig)
+		goto out_unlock;
+
+	hlist_for_each_entry_rcu(key, &md5sig->head, node) {
+		do_md5_seq_print_key(seq, st, key, ino);
+	}
+
+out_unlock:
+	rcu_read_unlock();
+out:
+	return 0;
+}
+EXPORT_SYMBOL(tcp_md5_seq_show);
 #endif
 
 void tcp_done(struct sock *sk)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0ae3d7cd59a3..d15a6e3cbdb2 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2395,13 +2395,40 @@ static struct tcp_seq_afinfo tcp4_seq_afinfo = {
 	},
 };
 
+#ifdef CONFIG_TCP_MD5SIG
+static struct tcp_seq_afinfo tcp4_md5_seq_afinfo = {
+	.name = "tcpmd5",
+	.family = AF_INET,
+	.seq_fops = &tcp_afinfo_seq_fops,
+	.seq_ops = {
+		.show = tcp_md5_seq_show,
+	}
+};
+#endif
+
 static int __net_init tcp4_proc_init_net(struct net *net)
 {
-	return tcp_proc_register(net, &tcp4_seq_afinfo, S_IRUGO);
+	if (tcp_proc_register(net, &tcp4_seq_afinfo, S_IRUGO))
+		goto out_tcp;
+#ifdef CONFIG_TCP_MD5SIG
+	if (tcp_proc_register(net, &tcp4_md5_seq_afinfo, S_IRUSR))
+		goto out_tcpmd5;
+#endif
+	return 0;
+
+#ifdef CONFIG_TCP_MD5SIG
+out_tcpmd5:
+	tcp_proc_unregister(net, &tcp4_seq_afinfo);
+#endif
+out_tcp:
+	return -ENOMEM;
 }
 
 static void __net_exit tcp4_proc_exit_net(struct net *net)
 {
+#ifdef CONFIG_TCP_MD5SIG
+	tcp_proc_unregister(net, &tcp4_md5_seq_afinfo);
+#endif
 	tcp_proc_unregister(net, &tcp4_seq_afinfo);
 }
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index d97d6627666f..006f5bfae50d 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1886,13 +1886,40 @@ static struct tcp_seq_afinfo tcp6_seq_afinfo = {
 	},
 };
 
+#ifdef CONFIG_TCP_MD5SIG
+static struct tcp_seq_afinfo tcp6_md5_seq_afinfo = {
+	.name = "tcp6md5",
+	.family = AF_INET6,
+	.seq_fops = &tcp6_afinfo_seq_fops,
+	.seq_ops = {
+		.show = tcp_md5_seq_show,
+	}
+};
+#endif
+
 int __net_init tcp6_proc_init(struct net *net)
 {
-	return tcp_proc_register(net, &tcp6_seq_afinfo, S_IRUGO);
+	if (tcp_proc_register(net, &tcp6_seq_afinfo, S_IRUGO))
+		goto out_tcp6;
+#ifdef CONFIG_TCP_MD5SIG
+	if (tcp_proc_register(net, &tcp6_md5_seq_afinfo, S_IRUSR))
+		goto out_tcp6md5;
+#endif
+	return 0;
+
+#ifdef CONFIG_TCP_MD5SIG
+out_tcp6md5:
+	tcp_proc_unregister(net, &tcp6_seq_afinfo);
+#endif
+out_tcp6:
+	return -ENOMEM;
 }
 
 void tcp6_proc_exit(struct net *net)
 {
+#ifdef CONFIG_TCP_MD5SIG
+	tcp_proc_unregister(net, &tcp6_md5_seq_afinfo);
+#endif
 	tcp_proc_unregister(net, &tcp6_seq_afinfo);
 }
 #endif
-- 
2.13.1
