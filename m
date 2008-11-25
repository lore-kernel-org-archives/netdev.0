From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: Use a percpu_counter for sockets_allocated
Date: Tue, 25 Nov 2008 23:48:19 +0100
Message-ID: <492C80B3.4040209@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010008080307040707010500"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:60093 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752240AbYKYWsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 17:48:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010008080307040707010500
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David

I am working on the SMP scalability problem of socket
allocation / deallocation.

I'll submit seven patches on lkml for fs subsystem, but before that,
I would like to submit two network patches for net-next-2.6.

After all contended cache lines access on fs subsystem are avoided,
we hit two contention points on network side : socket_allocated and
orphan_count atomic's (for SOCK_STREAM sockets)

Thank you

[PATCH] net: Use a percpu_counter for sockets_allocated

Instead of using one atomic_t per protocol, use a percpu_counter
for "sockets_allocated", to reduce cache line contention on
heavy duty network servers. 

Note : We revert commit (248969ae31e1b3276fc4399d67ce29a5d81e6fd9
net: af_unix can make unix_nr_socks visbile in /proc),
since it is not anymore used after sock_prot_inuse_add() addition

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/net/sctp/sctp.h |    1 +
 include/net/sock.h      |    2 +-
 include/net/tcp.h       |    2 +-
 net/core/sock.c         |   10 +++++++---
 net/ipv4/proc.c         |    3 ++-
 net/ipv4/tcp.c          |    8 ++++++--
 net/ipv4/tcp_ipv4.c     |    4 ++--
 net/ipv6/tcp_ipv6.c     |    2 +-
 net/sctp/protocol.c     |    6 +++++-
 net/sctp/socket.c       |    6 +++---
 net/unix/af_unix.c      |    1 -
 11 files changed, 29 insertions(+), 16 deletions(-)

--------------010008080307040707010500
Content-Type: text/plain;
 name="sockets_allocated.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sockets_allocated.patch"

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 2379750..bbb7742 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -138,6 +138,7 @@ void sctp_write_space(struct sock *sk);
 unsigned int sctp_poll(struct file *file, struct socket *sock,
 		poll_table *wait);
 void sctp_sock_rfree(struct sk_buff *skb);
+extern struct percpu_counter sctp_sockets_allocated;
 
 /*
  * sctp/primitive.c
diff --git a/include/net/sock.h b/include/net/sock.h
index 00cd486..a2a3890 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -649,7 +649,7 @@ struct proto {
 	/* Memory pressure */
 	void			(*enter_memory_pressure)(struct sock *sk);
 	atomic_t		*memory_allocated;	/* Current allocated memory. */
-	atomic_t		*sockets_allocated;	/* Current number of sockets. */
+	struct percpu_counter	*sockets_allocated;	/* Current number of sockets. */
 	/*
 	 * Pressure flag: try to collapse.
 	 * Technical note: it is used by multiple contexts non atomically.
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 2653924..723fc1b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -238,7 +238,7 @@ extern int sysctl_tcp_slow_start_after_idle;
 extern int sysctl_tcp_max_ssthresh;
 
 extern atomic_t tcp_memory_allocated;
-extern atomic_t tcp_sockets_allocated;
+extern struct percpu_counter tcp_sockets_allocated;
 extern int tcp_memory_pressure;
 
 /*
diff --git a/net/core/sock.c b/net/core/sock.c
index a4e840e..7a081b6 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1071,7 +1071,7 @@ struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
 		newsk->sk_sleep	 = NULL;
 
 		if (newsk->sk_prot->sockets_allocated)
-			atomic_inc(newsk->sk_prot->sockets_allocated);
+			percpu_counter_inc(newsk->sk_prot->sockets_allocated);
 	}
 out:
 	return newsk;
@@ -1463,8 +1463,12 @@ int __sk_mem_schedule(struct sock *sk, int size, int kind)
 	}
 
 	if (prot->memory_pressure) {
-		if (!*prot->memory_pressure ||
-		    prot->sysctl_mem[2] > atomic_read(prot->sockets_allocated) *
+		int alloc;
+
+		if (!*prot->memory_pressure)
+			return 1;
+		alloc = percpu_counter_read_positive(prot->sockets_allocated);
+		if (prot->sysctl_mem[2] > alloc *
 		    sk_mem_pages(sk->sk_wmem_queued +
 				 atomic_read(&sk->sk_rmem_alloc) +
 				 sk->sk_forward_alloc))
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 731789b..4944b47 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -55,7 +55,8 @@ static int sockstat_seq_show(struct seq_file *seq, void *v)
 	seq_printf(seq, "TCP: inuse %d orphan %d tw %d alloc %d mem %d\n",
 		   sock_prot_inuse_get(net, &tcp_prot),
 		   atomic_read(&tcp_orphan_count),
-		   tcp_death_row.tw_count, atomic_read(&tcp_sockets_allocated),
+		   tcp_death_row.tw_count,
+		   (int)percpu_counter_sum_positive(&tcp_sockets_allocated),
 		   atomic_read(&tcp_memory_allocated));
 	seq_printf(seq, "UDP: inuse %d mem %d\n",
 		   sock_prot_inuse_get(net, &udp_prot),
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 044224a..e6fade9 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -290,9 +290,12 @@ EXPORT_SYMBOL(sysctl_tcp_rmem);
 EXPORT_SYMBOL(sysctl_tcp_wmem);
 
 atomic_t tcp_memory_allocated;	/* Current allocated memory. */
-atomic_t tcp_sockets_allocated;	/* Current number of TCP sockets. */
-
 EXPORT_SYMBOL(tcp_memory_allocated);
+
+/*
+ * Current number of TCP sockets.
+ */
+struct percpu_counter tcp_sockets_allocated;
 EXPORT_SYMBOL(tcp_sockets_allocated);
 
 /*
@@ -2685,6 +2688,7 @@ void __init tcp_init(void)
 
 	BUILD_BUG_ON(sizeof(struct tcp_skb_cb) > sizeof(skb->cb));
 
+	percpu_counter_init(&tcp_sockets_allocated, 0);
 	tcp_hashinfo.bind_bucket_cachep =
 		kmem_cache_create("tcp_bind_bucket",
 				  sizeof(struct inet_bind_bucket), 0,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index cab2458..26b9030 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1797,7 +1797,7 @@ static int tcp_v4_init_sock(struct sock *sk)
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
-	atomic_inc(&tcp_sockets_allocated);
+	percpu_counter_inc(&tcp_sockets_allocated);
 
 	return 0;
 }
@@ -1845,7 +1845,7 @@ void tcp_v4_destroy_sock(struct sock *sk)
 		sk->sk_sndmsg_page = NULL;
 	}
 
-	atomic_dec(&tcp_sockets_allocated);
+	percpu_counter_dec(&tcp_sockets_allocated);
 }
 
 EXPORT_SYMBOL(tcp_v4_destroy_sock);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index a5d750a..d04bfad 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1829,7 +1829,7 @@ static int tcp_v6_init_sock(struct sock *sk)
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
-	atomic_inc(&tcp_sockets_allocated);
+	percpu_counter_inc(&tcp_sockets_allocated);
 
 	return 0;
 }
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index a8ca743..d5ea232 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -102,6 +102,8 @@ struct sock *sctp_get_ctl_sock(void)
 /* Set up the proc fs entry for the SCTP protocol. */
 static __init int sctp_proc_init(void)
 {
+	if (percpu_counter_init(&sctp_sockets_allocated, 0))
+		goto out_nomem;
 #ifdef CONFIG_PROC_FS
 	if (!proc_net_sctp) {
 		struct proc_dir_entry *ent;
@@ -110,7 +112,7 @@ static __init int sctp_proc_init(void)
 			ent->owner = THIS_MODULE;
 			proc_net_sctp = ent;
 		} else
-			goto out_nomem;
+			goto out_free_percpu;
 	}
 
 	if (sctp_snmp_proc_init())
@@ -135,6 +137,8 @@ out_snmp_proc_init:
 		proc_net_sctp = NULL;
 		remove_proc_entry("sctp", init_net.proc_net);
 	}
+out_free_percpu:
+	percpu_counter_destroy(&sctp_sockets_allocated);
 out_nomem:
 	return -ENOMEM;
 #else
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index ba81fe3..b88222b 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -114,7 +114,7 @@ extern int sysctl_sctp_wmem[3];
 
 static int sctp_memory_pressure;
 static atomic_t sctp_memory_allocated;
-static atomic_t sctp_sockets_allocated;
+struct percpu_counter sctp_sockets_allocated;
 
 static void sctp_enter_memory_pressure(struct sock *sk)
 {
@@ -3613,7 +3613,7 @@ SCTP_STATIC int sctp_init_sock(struct sock *sk)
 	sp->hmac = NULL;
 
 	SCTP_DBG_OBJCNT_INC(sock);
-	atomic_inc(&sctp_sockets_allocated);
+	percpu_counter_inc(&sctp_sockets_allocated);
 
 	local_bh_disable();
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
@@ -3632,7 +3632,7 @@ SCTP_STATIC void sctp_destroy_sock(struct sock *sk)
 	/* Release our hold on the endpoint. */
 	ep = sctp_sk(sk)->ep;
 	sctp_endpoint_free(ep);
-	atomic_dec(&sctp_sockets_allocated);
+ 	percpu_counter_dec(&sctp_sockets_allocated);
 	local_bh_disable();
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
 	local_bh_enable();
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 3a35a6e..5aaf23e 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -571,7 +571,6 @@ static const struct proto_ops unix_seqpacket_ops = {
 static struct proto unix_proto = {
 	.name			= "UNIX",
 	.owner			= THIS_MODULE,
-	.sockets_allocated	= &unix_nr_socks,
 	.obj_size		= sizeof(struct unix_sock),
 };
 

--------------010008080307040707010500--
