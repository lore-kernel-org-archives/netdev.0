From: Andi Kleen <ak@suse.de>
Subject: [PATCH RFC] [7/9] Convert TCP exports into namespaces
Date: Thu, 22 Nov 2007 03:43:12 +0100 (CET)
Message-ID: <20071122024312.DB1FD14D68@wotan.suse.de>
References: <20071122343.446909000@suse.de>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:58883 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751807AbXKVCnO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 21:43:14 -0500
In-Reply-To: <20071122343.446909000@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I defined two namespaces: tcp for TCP internals which are only used by 
tcp_ipv6.ko And tcpcong for exports used by the TCP congestion modules

No need to export any TCP internals to anybody else. So express this in a namespace.

I admit I'm not 100% sure tcpcong makes sense -- there might be a legitimate
need to have external out of tree congestion modules. They seem nearly like
drivers, but only nearly. If that was deemed the case it would be possible to 
remove tcpcong again to allow everybody to access this.

This implicitely turns all exports into GPL only, but that won't matter
because all modules allowed to import TCP functions are GPLed.

---
 net/ipv4/tcp.c           |   71 +++++++++++++++++++++++++++--------------------
 net/ipv4/tcp_cong.c      |   14 ++++-----
 net/ipv4/tcp_input.c     |   12 +++----
 net/ipv4/tcp_ipv4.c      |   38 ++++++++++++-------------
 net/ipv4/tcp_minisocks.c |   12 +++----
 net/ipv4/tcp_output.c    |   12 +++----
 net/ipv4/tcp_timer.c     |    2 -
 7 files changed, 87 insertions(+), 74 deletions(-)

Index: linux/net/ipv4/tcp.c
===================================================================
--- linux.orig/net/ipv4/tcp.c
+++ linux/net/ipv4/tcp.c
@@ -275,21 +275,21 @@ DEFINE_SNMP_STAT(struct tcp_mib, tcp_sta
 
 atomic_t tcp_orphan_count = ATOMIC_INIT(0);
 
-EXPORT_SYMBOL_GPL(tcp_orphan_count);
+EXPORT_SYMBOL_NS(tcp, tcp_orphan_count);
 
 int sysctl_tcp_mem[3] __read_mostly;
 int sysctl_tcp_wmem[3] __read_mostly;
 int sysctl_tcp_rmem[3] __read_mostly;
 
-EXPORT_SYMBOL(sysctl_tcp_mem);
-EXPORT_SYMBOL(sysctl_tcp_rmem);
-EXPORT_SYMBOL(sysctl_tcp_wmem);
+EXPORT_SYMBOL_NS(tcp, sysctl_tcp_mem);
+EXPORT_SYMBOL_NS(tcp, sysctl_tcp_rmem);
+EXPORT_SYMBOL_NS(tcp, sysctl_tcp_wmem);
 
 atomic_t tcp_memory_allocated;	/* Current allocated memory. */
 atomic_t tcp_sockets_allocated;	/* Current number of TCP sockets. */
 
-EXPORT_SYMBOL(tcp_memory_allocated);
-EXPORT_SYMBOL(tcp_sockets_allocated);
+EXPORT_SYMBOL_NS(tcp, tcp_memory_allocated);
+EXPORT_SYMBOL_NS(tcp, tcp_sockets_allocated);
 
 /*
  * Pressure flag: try to collapse.
@@ -299,7 +299,7 @@ EXPORT_SYMBOL(tcp_sockets_allocated);
  */
 int tcp_memory_pressure __read_mostly;
 
-EXPORT_SYMBOL(tcp_memory_pressure);
+EXPORT_SYMBOL_NS(tcp, tcp_memory_pressure);
 
 void tcp_enter_memory_pressure(void)
 {
@@ -309,7 +309,7 @@ void tcp_enter_memory_pressure(void)
 	}
 }
 
-EXPORT_SYMBOL(tcp_enter_memory_pressure);
+EXPORT_SYMBOL_NS(tcp, tcp_enter_memory_pressure);
 
 /*
  *	Wait for a TCP event.
@@ -1995,7 +1995,7 @@ int compat_tcp_setsockopt(struct sock *s
 	return do_tcp_setsockopt(sk, level, optname, optval, optlen);
 }
 
-EXPORT_SYMBOL(compat_tcp_setsockopt);
+EXPORT_SYMBOL_NS(tcp, compat_tcp_setsockopt);
 #endif
 
 /* Return information about state of tcp endpoint in API format. */
@@ -2061,7 +2061,7 @@ void tcp_get_info(struct sock *sk, struc
 	info->tcpi_total_retrans = tp->total_retrans;
 }
 
-EXPORT_SYMBOL_GPL(tcp_get_info);
+EXPORT_SYMBOL_NS(tcp, tcp_get_info);
 
 static int do_tcp_getsockopt(struct sock *sk, int level,
 		int optname, char __user *optval, int __user *optlen)
@@ -2174,7 +2174,7 @@ int compat_tcp_getsockopt(struct sock *s
 	return do_tcp_getsockopt(sk, level, optname, optval, optlen);
 }
 
-EXPORT_SYMBOL(compat_tcp_getsockopt);
+EXPORT_SYMBOL_NS(tcp, compat_tcp_getsockopt);
 #endif
 
 struct sk_buff *tcp_tso_segment(struct sk_buff *skb, int features)
@@ -2262,7 +2262,7 @@ struct sk_buff *tcp_tso_segment(struct s
 out:
 	return segs;
 }
-EXPORT_SYMBOL(tcp_tso_segment);
+EXPORT_SYMBOL_NS(tcp, tcp_tso_segment);
 
 #ifdef CONFIG_TCP_MD5SIG
 static unsigned long tcp_md5sig_users;
@@ -2298,7 +2298,7 @@ void tcp_free_md5sig_pool(void)
 		__tcp_free_md5sig_pool(pool);
 }
 
-EXPORT_SYMBOL(tcp_free_md5sig_pool);
+EXPORT_SYMBOL_NS(tcp, tcp_free_md5sig_pool);
 
 static struct tcp_md5sig_pool **__tcp_alloc_md5sig_pool(void)
 {
@@ -2371,7 +2371,7 @@ retry:
 	return pool;
 }
 
-EXPORT_SYMBOL(tcp_alloc_md5sig_pool);
+EXPORT_SYMBOL_NS(tcp, tcp_alloc_md5sig_pool);
 
 struct tcp_md5sig_pool *__tcp_get_md5sig_pool(int cpu)
 {
@@ -2384,14 +2384,14 @@ struct tcp_md5sig_pool *__tcp_get_md5sig
 	return (p ? *per_cpu_ptr(p, cpu) : NULL);
 }
 
-EXPORT_SYMBOL(__tcp_get_md5sig_pool);
+EXPORT_SYMBOL_NS(tcp, __tcp_get_md5sig_pool);
 
 void __tcp_put_md5sig_pool(void)
 {
 	tcp_free_md5sig_pool();
 }
 
-EXPORT_SYMBOL(__tcp_put_md5sig_pool);
+EXPORT_SYMBOL_NS(tcp, __tcp_put_md5sig_pool);
 #endif
 
 void tcp_done(struct sock *sk)
@@ -2409,7 +2409,7 @@ void tcp_done(struct sock *sk)
 	else
 		inet_csk_destroy_sock(sk);
 }
-EXPORT_SYMBOL_GPL(tcp_done);
+EXPORT_SYMBOL_NS(tcp, tcp_done);
 
 extern void __skb_cb_too_small_for_tcp(int, int);
 extern struct tcp_congestion_ops tcp_reno;
@@ -2524,15 +2524,28 @@ void __init tcp_init(void)
 	tcp_register_congestion_control(&tcp_reno);
 }
 
-EXPORT_SYMBOL(tcp_close);
-EXPORT_SYMBOL(tcp_disconnect);
-EXPORT_SYMBOL(tcp_getsockopt);
-EXPORT_SYMBOL(tcp_ioctl);
-EXPORT_SYMBOL(tcp_poll);
-EXPORT_SYMBOL(tcp_read_sock);
-EXPORT_SYMBOL(tcp_recvmsg);
-EXPORT_SYMBOL(tcp_sendmsg);
-EXPORT_SYMBOL(tcp_sendpage);
-EXPORT_SYMBOL(tcp_setsockopt);
-EXPORT_SYMBOL(tcp_shutdown);
-EXPORT_SYMBOL(tcp_statistics);
+EXPORT_SYMBOL_NS(tcp, tcp_close);
+EXPORT_SYMBOL_NS(tcp, tcp_disconnect);
+EXPORT_SYMBOL_NS(tcp, tcp_getsockopt);
+EXPORT_SYMBOL_NS(tcp, tcp_ioctl);
+EXPORT_SYMBOL_NS(tcp, tcp_poll);
+EXPORT_SYMBOL_NS(tcp, tcp_read_sock);
+EXPORT_SYMBOL_NS(tcp, tcp_recvmsg);
+EXPORT_SYMBOL_NS(tcp, tcp_sendmsg);
+EXPORT_SYMBOL_NS(tcp, tcp_sendpage);
+EXPORT_SYMBOL_NS(tcp, tcp_setsockopt);
+EXPORT_SYMBOL_NS(tcp, tcp_shutdown);
+EXPORT_SYMBOL_NS(tcp, tcp_statistics);
+
+MODULE_NAMESPACE_ALLOW(tcp, ipv6);
+MODULE_NAMESPACE_ALLOW(tcpcong, ipv6);
+
+MODULE_NAMESPACE_ALLOW(tcpcong, tcp_bic);
+MODULE_NAMESPACE_ALLOW(tcpcong, tcp_cubic);
+MODULE_NAMESPACE_ALLOW(tcpcong, tcp_westwood);
+MODULE_NAMESPACE_ALLOW(tcpcong, tcp_hyspeed);
+MODULE_NAMESPACE_ALLOW(tcpcong, tcp_hybla);
+MODULE_NAMESPACE_ALLOW(tcpcong, tcp_htcp);
+MODULE_NAMESPACE_ALLOW(tcpcong, tcp_vegas);
+MODULE_NAMESPACE_ALLOW(tcpcong, tcp_scalable);
+MODULE_NAMESPACE_ALLOW(tcpcong, tcp_lp);
Index: linux/net/ipv4/tcp_ipv4.c
===================================================================
--- linux.orig/net/ipv4/tcp_ipv4.c
+++ linux/net/ipv4/tcp_ipv4.c
@@ -163,7 +163,7 @@ int tcp_twsk_unique(struct sock *sk, str
 	return 0;
 }
 
-EXPORT_SYMBOL_GPL(tcp_twsk_unique);
+EXPORT_SYMBOL_NS(tcp, tcp_twsk_unique);
 
 /* This will initiate an outgoing connection. */
 int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
@@ -845,7 +845,7 @@ struct tcp_md5sig_key *tcp_v4_md5_lookup
 	return tcp_v4_md5_do_lookup(sk, inet_sk(addr_sk)->daddr);
 }
 
-EXPORT_SYMBOL(tcp_v4_md5_lookup);
+EXPORT_SYMBOL_NS(tcp, tcp_v4_md5_lookup);
 
 static struct tcp_md5sig_key *tcp_v4_reqsk_md5_lookup(struct sock *sk,
 						      struct request_sock *req)
@@ -913,7 +913,7 @@ int tcp_v4_md5_do_add(struct sock *sk, _
 	return 0;
 }
 
-EXPORT_SYMBOL(tcp_v4_md5_do_add);
+EXPORT_SYMBOL_NS(tcp, tcp_v4_md5_do_add);
 
 static int tcp_v4_md5_add_func(struct sock *sk, struct sock *addr_sk,
 			       u8 *newkey, u8 newkeylen)
@@ -951,7 +951,7 @@ int tcp_v4_md5_do_del(struct sock *sk, _
 	return -ENOENT;
 }
 
-EXPORT_SYMBOL(tcp_v4_md5_do_del);
+EXPORT_SYMBOL_NS(tcp, tcp_v4_md5_do_del);
 
 static void tcp_v4_clear_md5_list(struct sock *sk)
 {
@@ -1127,7 +1127,7 @@ int tcp_v4_calc_md5_hash(char *md5_hash,
 				       th, protocol, tcplen);
 }
 
-EXPORT_SYMBOL(tcp_v4_calc_md5_hash);
+EXPORT_SYMBOL_NS(tcp, tcp_v4_calc_md5_hash);
 
 static int tcp_v4_inbound_md5_hash(struct sock *sk, struct sk_buff *skb)
 {
@@ -1936,7 +1936,7 @@ int tcp_v4_destroy_sock(struct sock *sk)
 	return 0;
 }
 
-EXPORT_SYMBOL(tcp_v4_destroy_sock);
+EXPORT_SYMBOL_NS(tcp, tcp_v4_destroy_sock);
 
 #ifdef CONFIG_PROC_FS
 /* Proc filesystem TCP sock list dumping. */
@@ -2455,20 +2455,20 @@ void __init tcp_v4_init(struct net_proto
 		panic("Failed to create the TCP control socket.\n");
 }
 
-EXPORT_SYMBOL(ipv4_specific);
-EXPORT_SYMBOL(tcp_hashinfo);
-EXPORT_SYMBOL(tcp_prot);
-EXPORT_SYMBOL(tcp_unhash);
-EXPORT_SYMBOL(tcp_v4_conn_request);
-EXPORT_SYMBOL(tcp_v4_connect);
-EXPORT_SYMBOL(tcp_v4_do_rcv);
-EXPORT_SYMBOL(tcp_v4_remember_stamp);
-EXPORT_SYMBOL(tcp_v4_send_check);
-EXPORT_SYMBOL(tcp_v4_syn_recv_sock);
+EXPORT_SYMBOL_NS(tcp, ipv4_specific);
+EXPORT_SYMBOL_NS(tcp, tcp_hashinfo);
+EXPORT_SYMBOL_NS(tcp, tcp_prot);
+EXPORT_SYMBOL_NS(tcp, tcp_unhash);
+EXPORT_SYMBOL_NS(tcp, tcp_v4_conn_request);
+EXPORT_SYMBOL_NS(tcp, tcp_v4_connect);
+EXPORT_SYMBOL_NS(tcp, tcp_v4_do_rcv);
+EXPORT_SYMBOL_NS(tcp, tcp_v4_remember_stamp);
+EXPORT_SYMBOL_NS(tcp, tcp_v4_send_check);
+EXPORT_SYMBOL_NS(tcp, tcp_v4_syn_recv_sock);
 
 #ifdef CONFIG_PROC_FS
-EXPORT_SYMBOL(tcp_proc_register);
-EXPORT_SYMBOL(tcp_proc_unregister);
+EXPORT_SYMBOL_NS(tcp, tcp_proc_register);
+EXPORT_SYMBOL_NS(tcp, tcp_proc_unregister);
 #endif
-EXPORT_SYMBOL(sysctl_tcp_low_latency);
+EXPORT_SYMBOL_NS(tcp, sysctl_tcp_low_latency);
 
Index: linux/net/ipv4/tcp_minisocks.c
===================================================================
--- linux.orig/net/ipv4/tcp_minisocks.c
+++ linux/net/ipv4/tcp_minisocks.c
@@ -53,7 +53,7 @@ struct inet_timewait_death_row tcp_death
 					    (unsigned long)&tcp_death_row),
 };
 
-EXPORT_SYMBOL_GPL(tcp_death_row);
+EXPORT_SYMBOL_NS(tcp, tcp_death_row);
 
 static __inline__ int tcp_in_window(u32 seq, u32 end_seq, u32 s_win, u32 e_win)
 {
@@ -366,7 +366,7 @@ void tcp_twsk_destructor(struct sock *sk
 #endif
 }
 
-EXPORT_SYMBOL_GPL(tcp_twsk_destructor);
+EXPORT_SYMBOL_NS(tcp, tcp_twsk_destructor);
 
 static inline void TCP_ECN_openreq_child(struct tcp_sock *tp,
 					 struct request_sock *req)
@@ -734,7 +734,7 @@ int tcp_child_process(struct sock *paren
 	return ret;
 }
 
-EXPORT_SYMBOL(tcp_check_req);
-EXPORT_SYMBOL(tcp_child_process);
-EXPORT_SYMBOL(tcp_create_openreq_child);
-EXPORT_SYMBOL(tcp_timewait_state_process);
+EXPORT_SYMBOL_NS(tcp, tcp_check_req);
+EXPORT_SYMBOL_NS(tcp, tcp_child_process);
+EXPORT_SYMBOL_NS(tcp, tcp_create_openreq_child);
+EXPORT_SYMBOL_NS(tcp, tcp_timewait_state_process);
Index: linux/net/ipv4/tcp_output.c
===================================================================
--- linux.orig/net/ipv4/tcp_output.c
+++ linux/net/ipv4/tcp_output.c
@@ -2599,9 +2599,9 @@ void tcp_send_probe0(struct sock *sk)
 	}
 }
 
-EXPORT_SYMBOL(tcp_connect);
-EXPORT_SYMBOL(tcp_make_synack);
-EXPORT_SYMBOL(tcp_simple_retransmit);
-EXPORT_SYMBOL(tcp_sync_mss);
-EXPORT_SYMBOL(sysctl_tcp_tso_win_divisor);
-EXPORT_SYMBOL(tcp_mtup_init);
+EXPORT_SYMBOL_NS(tcp, tcp_connect);
+EXPORT_SYMBOL_NS(tcp, tcp_make_synack);
+EXPORT_SYMBOL_NS(tcp, tcp_simple_retransmit);
+EXPORT_SYMBOL_NS(tcp, tcp_sync_mss);
+EXPORT_SYMBOL_NS(tcpcong, sysctl_tcp_tso_win_divisor);
+EXPORT_SYMBOL_NS(tcp, tcp_mtup_init);
Index: linux/net/ipv4/tcp_timer.c
===================================================================
--- linux.orig/net/ipv4/tcp_timer.c
+++ linux/net/ipv4/tcp_timer.c
@@ -42,7 +42,7 @@ void tcp_init_xmit_timers(struct sock *s
 				  &tcp_keepalive_timer);
 }
 
-EXPORT_SYMBOL(tcp_init_xmit_timers);
+EXPORT_SYMBOL_NS(tcp, tcp_init_xmit_timers);
 
 static void tcp_write_err(struct sock *sk)
 {
Index: linux/net/ipv4/tcp_cong.c
===================================================================
--- linux.orig/net/ipv4/tcp_cong.c
+++ linux/net/ipv4/tcp_cong.c
@@ -57,7 +57,7 @@ int tcp_register_congestion_control(stru
 
 	return ret;
 }
-EXPORT_SYMBOL_GPL(tcp_register_congestion_control);
+EXPORT_SYMBOL_NS(tcpcong, tcp_register_congestion_control);
 
 /*
  * Remove congestion control algorithm, called from
@@ -71,7 +71,7 @@ void tcp_unregister_congestion_control(s
 	list_del_rcu(&ca->list);
 	spin_unlock(&tcp_cong_list_lock);
 }
-EXPORT_SYMBOL_GPL(tcp_unregister_congestion_control);
+EXPORT_SYMBOL_NS(tcpcong, tcp_unregister_congestion_control);
 
 /* Assign choice of congestion control. */
 void tcp_init_congestion_control(struct sock *sk)
@@ -315,7 +315,7 @@ void tcp_slow_start(struct tcp_sock *tp)
 			tp->snd_cwnd++;
 	}
 }
-EXPORT_SYMBOL_GPL(tcp_slow_start);
+EXPORT_SYMBOL_NS(tcpcong, tcp_slow_start);
 
 /*
  * TCP Reno congestion control
@@ -355,7 +355,7 @@ void tcp_reno_cong_avoid(struct sock *sk
 			tp->snd_cwnd_cnt++;
 	}
 }
-EXPORT_SYMBOL_GPL(tcp_reno_cong_avoid);
+EXPORT_SYMBOL_NS(tcpcong, tcp_reno_cong_avoid);
 
 /* Slow start threshold is half the congestion window (min 2) */
 u32 tcp_reno_ssthresh(struct sock *sk)
@@ -363,7 +363,7 @@ u32 tcp_reno_ssthresh(struct sock *sk)
 	const struct tcp_sock *tp = tcp_sk(sk);
 	return max(tp->snd_cwnd >> 1U, 2U);
 }
-EXPORT_SYMBOL_GPL(tcp_reno_ssthresh);
+EXPORT_SYMBOL_NS(tcpcong, tcp_reno_ssthresh);
 
 /* Lower bound on congestion window with halving. */
 u32 tcp_reno_min_cwnd(const struct sock *sk)
@@ -371,7 +371,7 @@ u32 tcp_reno_min_cwnd(const struct sock 
 	const struct tcp_sock *tp = tcp_sk(sk);
 	return tp->snd_ssthresh/2;
 }
-EXPORT_SYMBOL_GPL(tcp_reno_min_cwnd);
+EXPORT_SYMBOL_NS(tcpcong, tcp_reno_min_cwnd);
 
 struct tcp_congestion_ops tcp_reno = {
 	.flags		= TCP_CONG_NON_RESTRICTED,
@@ -393,4 +393,4 @@ struct tcp_congestion_ops tcp_init_conge
 	.cong_avoid	= tcp_reno_cong_avoid,
 	.min_cwnd	= tcp_reno_min_cwnd,
 };
-EXPORT_SYMBOL_GPL(tcp_init_congestion_ops);
+EXPORT_SYMBOL_NS(tcpcong, tcp_init_congestion_ops);
Index: linux/net/ipv4/tcp_input.c
===================================================================
--- linux.orig/net/ipv4/tcp_input.c
+++ linux/net/ipv4/tcp_input.c
@@ -5163,9 +5163,9 @@ discard:
 	return 0;
 }
 
-EXPORT_SYMBOL(sysctl_tcp_ecn);
-EXPORT_SYMBOL(sysctl_tcp_reordering);
-EXPORT_SYMBOL(tcp_parse_options);
-EXPORT_SYMBOL(tcp_rcv_established);
-EXPORT_SYMBOL(tcp_rcv_state_process);
-EXPORT_SYMBOL(tcp_initialize_rcv_mss);
+EXPORT_SYMBOL_NS(tcp, sysctl_tcp_ecn);
+EXPORT_SYMBOL_NS(tcp, sysctl_tcp_reordering);
+EXPORT_SYMBOL_NS(tcp, tcp_parse_options);
+EXPORT_SYMBOL_NS(tcp, tcp_rcv_established);
+EXPORT_SYMBOL_NS(tcp, tcp_rcv_state_process);
+EXPORT_SYMBOL_NS(tcp, tcp_initialize_rcv_mss);
