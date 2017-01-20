From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: remove bh disabling around percpu_counter
 accesses
Date: Fri, 20 Jan 2017 05:06:08 -0800
Message-ID: <1484917568.16328.110.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36518 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751976AbdATNGL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 08:06:11 -0500
Received: by mail-pf0-f194.google.com with SMTP id 19so5471321pfo.3
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 05:06:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Shaohua Li made percpu_counter irq safe in commit 098faf5805c8
("percpu_counter: make APIs irq safe")

We can safely remove BH disable/enable sections around various
percpu_counter manipulations.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/dst_ops.h           |    9 +--------
 include/net/inet_frag.h         |    8 +-------
 net/ipv4/inet_connection_sock.c |    3 +--
 net/ipv4/proc.c                 |    2 --
 net/ipv4/tcp.c                  |    2 --
 net/ipv4/tcp_ipv4.c             |    2 --
 6 files changed, 3 insertions(+), 23 deletions(-)

diff --git a/include/net/dst_ops.h b/include/net/dst_ops.h
index a0d443ca16fcca26b4925d477265935f5bdaf5bc..8a2b66d8d78de33f18f1343f97fd7d29e935fbfa 100644
--- a/include/net/dst_ops.h
+++ b/include/net/dst_ops.h
@@ -46,19 +46,12 @@ static inline int dst_entries_get_fast(struct dst_ops *dst)
 
 static inline int dst_entries_get_slow(struct dst_ops *dst)
 {
-	int res;
-
-	local_bh_disable();
-	res = percpu_counter_sum_positive(&dst->pcpuc_entries);
-	local_bh_enable();
-	return res;
+	return percpu_counter_sum_positive(&dst->pcpuc_entries);
 }
 
 static inline void dst_entries_add(struct dst_ops *dst, int val)
 {
-	local_bh_disable();
 	percpu_counter_add(&dst->pcpuc_entries, val);
-	local_bh_enable();
 }
 
 static inline int dst_entries_init(struct dst_ops *dst)
diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 909972aa3acd7e4e3d865800f45056235efc7bef..5894730ec82a9fba3b9bca160de6e0db3a73024e 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -164,13 +164,7 @@ static inline void add_frag_mem_limit(struct netns_frags *nf, int i)
 
 static inline unsigned int sum_frag_mem_limit(struct netns_frags *nf)
 {
-	unsigned int res;
-
-	local_bh_disable();
-	res = percpu_counter_sum_positive(&nf->mem);
-	local_bh_enable();
-
-	return res;
+	return percpu_counter_sum_positive(&nf->mem);
 }
 
 /* RFC 3168 support :
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 096a085611ab8dc2b0666ed9859bf792f396dc43..c7f7c53353691070813eeb7ece86d1826f408fd5 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -836,9 +836,8 @@ void inet_csk_destroy_sock(struct sock *sk)
 
 	sk_refcnt_debug_release(sk);
 
-	local_bh_disable();
 	percpu_counter_dec(sk->sk_prot->orphan_count);
-	local_bh_enable();
+
 	sock_put(sk);
 }
 EXPORT_SYMBOL(inet_csk_destroy_sock);
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 0247ca0322327bc42273b675b769c1f176ba33f4..a9deeb90dd36e0a8f94596b4f563ad63925344cf 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -57,10 +57,8 @@ static int sockstat_seq_show(struct seq_file *seq, void *v)
 	unsigned int frag_mem;
 	int orphans, sockets;
 
-	local_bh_disable();
 	orphans = percpu_counter_sum_positive(&tcp_orphan_count);
 	sockets = proto_sockets_allocated_sum_positive(&tcp_prot);
-	local_bh_enable();
 
 	socket_seq_show(seq);
 	seq_printf(seq, "TCP: inuse %d orphan %d tw %d alloc %d mem %ld\n",
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index aba6ea76338e35e36124580dcab3c80e3c638659..c43eb1a831d7a0a36b447421908a149b1808590b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -420,9 +420,7 @@ void tcp_init_sock(struct sock *sk)
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
-	local_bh_disable();
 	sk_sockets_allocated_inc(sk);
-	local_bh_enable();
 }
 EXPORT_SYMBOL(tcp_init_sock);
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3644fc1176918d81c645e0e79c4ec3aec4216474..f7325b25b06e65581ecc496f95e819aa738c0987 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1887,9 +1887,7 @@ void tcp_v4_destroy_sock(struct sock *sk)
 	tcp_free_fastopen_req(tp);
 	tcp_saved_syn_free(tp);
 
-	local_bh_disable();
 	sk_sockets_allocated_dec(sk);
-	local_bh_enable();
 }
 EXPORT_SYMBOL(tcp_v4_destroy_sock);
 
