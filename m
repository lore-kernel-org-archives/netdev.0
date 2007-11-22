From: Andi Kleen <ak@suse.de>
Subject: [PATCH RFC] [9/9] Add a inet namespace
Date: Thu, 22 Nov 2007 03:43:14 +0100 (CET)
Message-ID: <20071122024315.09E8114D68@wotan.suse.de>
References: <20071122343.446909000@suse.de>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:37778 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751741AbXKVCnQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 21:43:16 -0500
In-Reply-To: <20071122343.446909000@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Shared by IP, IPv6, DCCP, UDPLITE, SCTP. 

The symbols used by tunnel modules weren't put into any name space
because there are quite a lot of them.

---
 net/core/fib_rules.c            |    9 ++++--
 net/ipv4/af_inet.c              |   52 ++++++++++++++++++++++++----------------
 net/ipv4/arp.c                  |    1 
 net/ipv4/icmp.c                 |   10 +++----
 net/ipv4/inet_connection_sock.c |   40 +++++++++++++++---------------
 net/ipv4/inet_diag.c            |    4 +--
 net/ipv4/inet_hashtables.c      |    8 +++---
 net/ipv4/inet_timewait_sock.c   |   12 ++++-----
 net/ipv4/ip_input.c             |    2 -
 net/ipv4/ip_output.c            |    7 +++--
 net/ipv4/ip_sockglue.c          |   10 +++----
 11 files changed, 86 insertions(+), 69 deletions(-)

Index: linux/net/ipv4/af_inet.c
===================================================================
--- linux.orig/net/ipv4/af_inet.c
+++ linux/net/ipv4/af_inet.c
@@ -218,7 +218,7 @@ out:
 }
 
 u32 inet_ehash_secret __read_mostly;
-EXPORT_SYMBOL(inet_ehash_secret);
+EXPORT_SYMBOL_NS(inet, inet_ehash_secret);
 
 /*
  * inet_ehash_secret must be set exactly once
@@ -235,7 +235,7 @@ void build_ehash_secret(void)
 		inet_ehash_secret = rnd;
 	spin_unlock_bh(&inetsw_lock);
 }
-EXPORT_SYMBOL(build_ehash_secret);
+EXPORT_SYMBOL_NS(inet, build_ehash_secret);
 
 /*
  *	Create an inet socket.
@@ -1127,7 +1127,7 @@ int inet_sk_rebuild_header(struct sock *
 	return err;
 }
 
-EXPORT_SYMBOL(inet_sk_rebuild_header);
+EXPORT_SYMBOL_NS(inet,inet_sk_rebuild_header);
 
 static int inet_gso_send_check(struct sk_buff *skb)
 {
@@ -1235,6 +1235,8 @@ unsigned long snmp_fold_field(void *mib[
 	}
 	return res;
 }
+/* AK: Not in inet namespace because they're a generic facility. Probably
+   should be in another file though. */
 EXPORT_SYMBOL_GPL(snmp_fold_field);
 
 int snmp_mib_init(void *ptr[2], size_t mibsize, size_t mibalign)
@@ -1499,20 +1501,30 @@ static int __init ipv4_proc_init(void)
 
 MODULE_ALIAS_NETPROTO(PF_INET);
 
-EXPORT_SYMBOL(inet_accept);
-EXPORT_SYMBOL(inet_bind);
-EXPORT_SYMBOL(inet_dgram_connect);
-EXPORT_SYMBOL(inet_dgram_ops);
-EXPORT_SYMBOL(inet_getname);
-EXPORT_SYMBOL(inet_ioctl);
-EXPORT_SYMBOL(inet_listen);
-EXPORT_SYMBOL(inet_register_protosw);
-EXPORT_SYMBOL(inet_release);
-EXPORT_SYMBOL(inet_sendmsg);
-EXPORT_SYMBOL(inet_shutdown);
-EXPORT_SYMBOL(inet_sock_destruct);
-EXPORT_SYMBOL(inet_stream_connect);
-EXPORT_SYMBOL(inet_stream_ops);
-EXPORT_SYMBOL(inet_unregister_protosw);
-EXPORT_SYMBOL(net_statistics);
-EXPORT_SYMBOL(sysctl_ip_nonlocal_bind);
+MODULE_NAMESPACE_ALLOW(inet, ipv6);
+MODULE_NAMESPACE_ALLOW(inet, udplite);
+MODULE_NAMESPACE_ALLOW(inet, dccp_ipv6);
+MODULE_NAMESPACE_ALLOW(inet, dccp_ipv4);
+MODULE_NAMESPACE_ALLOW(inet, dccp);
+MODULE_NAMESPACE_ALLOW(inet, sctp);
+
+/* RED-PEN: would be better to fix wanrouter */
+MODULE_NAMESPACE_ALLOW(inet, wanrouter);
+
+EXPORT_SYMBOL_NS(inet,inet_accept);
+EXPORT_SYMBOL_NS(inet,inet_bind);
+EXPORT_SYMBOL_NS(inet,inet_dgram_connect);
+EXPORT_SYMBOL_NS(inet,inet_dgram_ops);
+EXPORT_SYMBOL_NS(inet,inet_getname);
+EXPORT_SYMBOL_NS(inet,inet_ioctl);
+EXPORT_SYMBOL_NS(inet,inet_listen);
+EXPORT_SYMBOL_NS(inet,inet_register_protosw);
+EXPORT_SYMBOL_NS(inet,inet_release);
+EXPORT_SYMBOL_NS(inet,inet_sendmsg);
+EXPORT_SYMBOL_NS(inet,inet_shutdown);
+EXPORT_SYMBOL_NS(inet,inet_sock_destruct);
+EXPORT_SYMBOL_NS(inet,inet_stream_connect);
+EXPORT_SYMBOL_NS(inet,inet_stream_ops);
+EXPORT_SYMBOL_NS(inet,inet_unregister_protosw);
+EXPORT_SYMBOL_NS(inet,net_statistics);
+EXPORT_SYMBOL_NS(inet,sysctl_ip_nonlocal_bind);
Index: linux/net/ipv4/arp.c
===================================================================
--- linux.orig/net/ipv4/arp.c
+++ linux/net/ipv4/arp.c
@@ -1406,6 +1406,7 @@ static int __init arp_proc_init(void)
 
 #endif /* CONFIG_PROC_FS */
 
+/* No namespace because those are used by various drivers */
 EXPORT_SYMBOL(arp_broken_ops);
 EXPORT_SYMBOL(arp_find);
 EXPORT_SYMBOL(arp_create);
Index: linux/net/ipv4/icmp.c
===================================================================
--- linux.orig/net/ipv4/icmp.c
+++ linux/net/ipv4/icmp.c
@@ -1101,7 +1101,7 @@ void __init icmp_init(struct net_proto_f
 	}
 }
 
-EXPORT_SYMBOL(icmp_err_convert);
-EXPORT_SYMBOL(icmp_send);
-EXPORT_SYMBOL(icmp_statistics);
-EXPORT_SYMBOL(xrlim_allow);
+EXPORT_SYMBOL_NS(inet, icmp_err_convert);
+EXPORT_SYMBOL_NS(inet, icmp_send);
+EXPORT_SYMBOL_NS(inet, icmp_statistics);
+EXPORT_SYMBOL_NS(inet, xrlim_allow);
Index: linux/net/ipv4/inet_connection_sock.c
===================================================================
--- linux.orig/net/ipv4/inet_connection_sock.c
+++ linux/net/ipv4/inet_connection_sock.c
@@ -26,7 +26,7 @@
 
 #ifdef INET_CSK_DEBUG
 const char inet_csk_timer_bug_msg[] = "inet_csk BUG: unknown timer value\n";
-EXPORT_SYMBOL(inet_csk_timer_bug_msg);
+EXPORT_SYMBOL_NS(inet, inet_csk_timer_bug_msg);
 #endif
 
 /*
@@ -73,7 +73,7 @@ int inet_csk_bind_conflict(const struct 
 	return node != NULL;
 }
 
-EXPORT_SYMBOL_GPL(inet_csk_bind_conflict);
+EXPORT_SYMBOL_NS(inet, inet_csk_bind_conflict);
 
 /* Obtain a reference to a local port for the given sock,
  * if snum is zero it means select any available local port.
@@ -170,7 +170,7 @@ fail:
 	return ret;
 }
 
-EXPORT_SYMBOL_GPL(inet_csk_get_port);
+EXPORT_SYMBOL_NS(inet, inet_csk_get_port);
 
 /*
  * Wait for an incoming connection, avoid race conditions. This must be called
@@ -263,7 +263,7 @@ out_err:
 	goto out;
 }
 
-EXPORT_SYMBOL(inet_csk_accept);
+EXPORT_SYMBOL_NS(inet, inet_csk_accept);
 
 /*
  * Using different timers for retransmit, delayed acks and probes
@@ -292,7 +292,7 @@ void inet_csk_init_xmit_timers(struct so
 	icsk->icsk_pending = icsk->icsk_ack.pending = 0;
 }
 
-EXPORT_SYMBOL(inet_csk_init_xmit_timers);
+EXPORT_SYMBOL_NS(inet, inet_csk_init_xmit_timers);
 
 void inet_csk_clear_xmit_timers(struct sock *sk)
 {
@@ -305,21 +305,21 @@ void inet_csk_clear_xmit_timers(struct s
 	sk_stop_timer(sk, &sk->sk_timer);
 }
 
-EXPORT_SYMBOL(inet_csk_clear_xmit_timers);
+EXPORT_SYMBOL_NS(inet, inet_csk_clear_xmit_timers);
 
 void inet_csk_delete_keepalive_timer(struct sock *sk)
 {
 	sk_stop_timer(sk, &sk->sk_timer);
 }
 
-EXPORT_SYMBOL(inet_csk_delete_keepalive_timer);
+EXPORT_SYMBOL_NS(inet, inet_csk_delete_keepalive_timer);
 
 void inet_csk_reset_keepalive_timer(struct sock *sk, unsigned long len)
 {
 	sk_reset_timer(sk, &sk->sk_timer, jiffies + len);
 }
 
-EXPORT_SYMBOL(inet_csk_reset_keepalive_timer);
+EXPORT_SYMBOL_NS(inet, inet_csk_reset_keepalive_timer);
 
 struct dst_entry* inet_csk_route_req(struct sock *sk,
 				     const struct request_sock *req)
@@ -352,7 +352,7 @@ struct dst_entry* inet_csk_route_req(str
 	return &rt->u.dst;
 }
 
-EXPORT_SYMBOL_GPL(inet_csk_route_req);
+EXPORT_SYMBOL_NS(inet, inet_csk_route_req);
 
 static inline u32 inet_synq_hash(const __be32 raddr, const __be16 rport,
 				 const u32 rnd, const u32 synq_hsize)
@@ -394,7 +394,7 @@ struct request_sock *inet_csk_search_req
 	return req;
 }
 
-EXPORT_SYMBOL_GPL(inet_csk_search_req);
+EXPORT_SYMBOL_NS(inet, inet_csk_search_req);
 
 void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
 				   unsigned long timeout)
@@ -411,7 +411,7 @@ void inet_csk_reqsk_queue_hash_add(struc
 /* Only thing we need from tcp.h */
 extern int sysctl_tcp_synack_retries;
 
-EXPORT_SYMBOL_GPL(inet_csk_reqsk_queue_hash_add);
+EXPORT_SYMBOL_NS(inet, inet_csk_reqsk_queue_hash_add);
 
 void inet_csk_reqsk_queue_prune(struct sock *parent,
 				const unsigned long interval,
@@ -500,7 +500,7 @@ void inet_csk_reqsk_queue_prune(struct s
 		inet_csk_reset_keepalive_timer(parent, interval);
 }
 
-EXPORT_SYMBOL_GPL(inet_csk_reqsk_queue_prune);
+EXPORT_SYMBOL_NS(inet, inet_csk_reqsk_queue_prune);
 
 struct sock *inet_csk_clone(struct sock *sk, const struct request_sock *req,
 			    const gfp_t priority)
@@ -528,7 +528,7 @@ struct sock *inet_csk_clone(struct sock 
 	return newsk;
 }
 
-EXPORT_SYMBOL_GPL(inet_csk_clone);
+EXPORT_SYMBOL_NS(inet, inet_csk_clone);
 
 /*
  * At this point, there should be no process reference to this
@@ -559,7 +559,7 @@ void inet_csk_destroy_sock(struct sock *
 	sock_put(sk);
 }
 
-EXPORT_SYMBOL(inet_csk_destroy_sock);
+EXPORT_SYMBOL_NS(inet, inet_csk_destroy_sock);
 
 int inet_csk_listen_start(struct sock *sk, const int nr_table_entries)
 {
@@ -594,7 +594,7 @@ int inet_csk_listen_start(struct sock *s
 	return -EADDRINUSE;
 }
 
-EXPORT_SYMBOL_GPL(inet_csk_listen_start);
+EXPORT_SYMBOL_NS(inet, inet_csk_listen_start);
 
 /*
  *	This routine closes sockets which have been at least partially
@@ -649,7 +649,7 @@ void inet_csk_listen_stop(struct sock *s
 	BUG_TRAP(!sk->sk_ack_backlog);
 }
 
-EXPORT_SYMBOL_GPL(inet_csk_listen_stop);
+EXPORT_SYMBOL_NS(inet, inet_csk_listen_stop);
 
 void inet_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr)
 {
@@ -661,7 +661,7 @@ void inet_csk_addr2sockaddr(struct sock 
 	sin->sin_port		= inet->dport;
 }
 
-EXPORT_SYMBOL_GPL(inet_csk_addr2sockaddr);
+EXPORT_SYMBOL_NS(inet, inet_csk_addr2sockaddr);
 
 int inet_csk_ctl_sock_create(struct socket **sock, unsigned short family,
 			     unsigned short type, unsigned char protocol)
@@ -680,7 +680,7 @@ int inet_csk_ctl_sock_create(struct sock
 	return rc;
 }
 
-EXPORT_SYMBOL_GPL(inet_csk_ctl_sock_create);
+EXPORT_SYMBOL_NS(inet, inet_csk_ctl_sock_create);
 
 #ifdef CONFIG_COMPAT
 int inet_csk_compat_getsockopt(struct sock *sk, int level, int optname,
@@ -695,7 +695,7 @@ int inet_csk_compat_getsockopt(struct so
 					     optval, optlen);
 }
 
-EXPORT_SYMBOL_GPL(inet_csk_compat_getsockopt);
+EXPORT_SYMBOL_NS(inet, inet_csk_compat_getsockopt);
 
 int inet_csk_compat_setsockopt(struct sock *sk, int level, int optname,
 			       char __user *optval, int optlen)
@@ -709,5 +709,5 @@ int inet_csk_compat_setsockopt(struct so
 					     optval, optlen);
 }
 
-EXPORT_SYMBOL_GPL(inet_csk_compat_setsockopt);
+EXPORT_SYMBOL_NS(inet, inet_csk_compat_setsockopt);
 #endif
Index: linux/net/ipv4/ip_output.c
===================================================================
--- linux.orig/net/ipv4/ip_output.c
+++ linux/net/ipv4/ip_output.c
@@ -669,7 +669,7 @@ fail:
 	return err;
 }
 
-EXPORT_SYMBOL(ip_fragment);
+EXPORT_SYMBOL_NS(inet,ip_fragment);
 
 int
 ip_generic_getfrag(void *from, char *to, int offset, int len, int odd, struct sk_buff *skb)
@@ -1409,6 +1409,7 @@ void __init ip_init(void)
 #endif
 }
 
-EXPORT_SYMBOL(ip_generic_getfrag);
-EXPORT_SYMBOL(ip_queue_xmit);
+EXPORT_SYMBOL_NS(inet,ip_generic_getfrag);
+EXPORT_SYMBOL_NS(inet,ip_queue_xmit);
+/* ip_send_check is widely used by netfilter modules */
 EXPORT_SYMBOL(ip_send_check);
Index: linux/net/ipv4/inet_diag.c
===================================================================
--- linux.orig/net/ipv4/inet_diag.c
+++ linux/net/ipv4/inet_diag.c
@@ -873,7 +873,7 @@ int inet_diag_register(const struct inet
 out:
 	return err;
 }
-EXPORT_SYMBOL_GPL(inet_diag_register);
+EXPORT_SYMBOL_NS(inet, inet_diag_register);
 
 void inet_diag_unregister(const struct inet_diag_handler *h)
 {
@@ -888,7 +888,7 @@ void inet_diag_unregister(const struct i
 
 	synchronize_rcu();
 }
-EXPORT_SYMBOL_GPL(inet_diag_unregister);
+EXPORT_SYMBOL_NS(inet, inet_diag_unregister);
 
 static int __init inet_diag_init(void)
 {
Index: linux/net/ipv4/inet_hashtables.c
===================================================================
--- linux.orig/net/ipv4/inet_hashtables.c
+++ linux/net/ipv4/inet_hashtables.c
@@ -86,7 +86,7 @@ void inet_put_port(struct inet_hashinfo 
 	local_bh_enable();
 }
 
-EXPORT_SYMBOL(inet_put_port);
+EXPORT_SYMBOL_NS(inet, inet_put_port);
 
 /*
  * This lock without WQ_FLAG_EXCLUSIVE is good on UP and it can be very bad on SMP.
@@ -116,7 +116,7 @@ void inet_listen_wlock(struct inet_hashi
 	}
 }
 
-EXPORT_SYMBOL(inet_listen_wlock);
+EXPORT_SYMBOL_NS(inet, inet_listen_wlock);
 
 /*
  * Don't inline this cruft. Here are some nice properties to exploit here. The
@@ -188,7 +188,7 @@ sherry_cache:
 	read_unlock(&hashinfo->lhash_lock);
 	return sk;
 }
-EXPORT_SYMBOL_GPL(__inet_lookup_listener);
+EXPORT_SYMBOL_NS(inet, __inet_lookup_listener);
 
 /* called with local bh disabled */
 static int __inet_check_established(struct inet_timewait_death_row *death_row,
@@ -364,4 +364,4 @@ out:
 	}
 }
 
-EXPORT_SYMBOL_GPL(inet_hash_connect);
+EXPORT_SYMBOL_NS(inet, inet_hash_connect);
Index: linux/net/ipv4/ip_input.c
===================================================================
--- linux.orig/net/ipv4/ip_input.c
+++ linux/net/ipv4/ip_input.c
@@ -453,4 +453,4 @@ out:
 	return NET_RX_DROP;
 }
 
-EXPORT_SYMBOL(ip_statistics);
+EXPORT_SYMBOL_NS(inet, ip_statistics);
Index: linux/net/core/fib_rules.c
===================================================================
--- linux.orig/net/core/fib_rules.c
+++ linux/net/core/fib_rules.c
@@ -100,7 +100,7 @@ errout:
 	return err;
 }
 
-EXPORT_SYMBOL_GPL(fib_rules_register);
+EXPORT_SYMBOL_NS(fib, fib_rules_register);
 
 static void cleanup_ops(struct fib_rules_ops *ops)
 {
@@ -135,7 +135,7 @@ out:
 	return err;
 }
 
-EXPORT_SYMBOL_GPL(fib_rules_unregister);
+EXPORT_SYMBOL_NS(fib, fib_rules_unregister);
 
 static int fib_rule_match(struct fib_rule *rule, struct fib_rules_ops *ops,
 			  struct flowi *fl, int flags)
@@ -195,7 +195,7 @@ out:
 	return err;
 }
 
-EXPORT_SYMBOL_GPL(fib_rules_lookup);
+EXPORT_SYMBOL_NS(fib, fib_rules_lookup);
 
 static int validate_rulemsg(struct fib_rule_hdr *frh, struct nlattr **tb,
 			    struct fib_rules_ops *ops)
@@ -658,3 +658,6 @@ static int __init fib_rules_init(void)
 }
 
 subsys_initcall(fib_rules_init);
+
+MODULE_NAMESPACE_ALLOW(fib, ipv6);
+MODULE_NAMESPACE_ALLOW(fib, decnet);
Index: linux/net/ipv4/inet_timewait_sock.c
===================================================================
--- linux.orig/net/ipv4/inet_timewait_sock.c
+++ linux/net/ipv4/inet_timewait_sock.c
@@ -85,7 +85,7 @@ void __inet_twsk_hashdance(struct inet_t
 	write_unlock(lock);
 }
 
-EXPORT_SYMBOL_GPL(__inet_twsk_hashdance);
+EXPORT_SYMBOL_NS(inet, __inet_twsk_hashdance);
 
 struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int state)
 {
@@ -117,7 +117,7 @@ struct inet_timewait_sock *inet_twsk_all
 	return tw;
 }
 
-EXPORT_SYMBOL_GPL(inet_twsk_alloc);
+EXPORT_SYMBOL_NS(inet, inet_twsk_alloc);
 
 /* Returns non-zero if quota exceeded.  */
 static int inet_twdr_do_twkill_work(struct inet_timewait_death_row *twdr,
@@ -192,7 +192,7 @@ out:
 	spin_unlock(&twdr->death_lock);
 }
 
-EXPORT_SYMBOL_GPL(inet_twdr_hangman);
+EXPORT_SYMBOL_NS(inet, inet_twdr_hangman);
 
 extern void twkill_slots_invalid(void);
 
@@ -225,7 +225,7 @@ void inet_twdr_twkill_work(struct work_s
 	}
 }
 
-EXPORT_SYMBOL_GPL(inet_twdr_twkill_work);
+EXPORT_SYMBOL_NS(inet, inet_twdr_twkill_work);
 
 /* These are always called from BH context.  See callers in
  * tcp_input.c to verify this.
@@ -326,7 +326,7 @@ void inet_twsk_schedule(struct inet_time
 	spin_unlock(&twdr->death_lock);
 }
 
-EXPORT_SYMBOL_GPL(inet_twsk_schedule);
+EXPORT_SYMBOL_NS(inet, inet_twsk_schedule);
 
 void inet_twdr_twcal_tick(unsigned long data)
 {
@@ -382,4 +382,4 @@ out:
 	spin_unlock(&twdr->death_lock);
 }
 
-EXPORT_SYMBOL_GPL(inet_twdr_twcal_tick);
+EXPORT_SYMBOL_NS(inet, inet_twdr_twcal_tick);
Index: linux/net/ipv4/ip_sockglue.c
===================================================================
--- linux.orig/net/ipv4/ip_sockglue.c
+++ linux/net/ipv4/ip_sockglue.c
@@ -943,7 +943,7 @@ int compat_ip_setsockopt(struct sock *sk
 	return err;
 }
 
-EXPORT_SYMBOL(compat_ip_setsockopt);
+EXPORT_SYMBOL_NS(inet, compat_ip_setsockopt);
 #endif
 
 /*
@@ -1206,10 +1206,10 @@ int compat_ip_getsockopt(struct sock *sk
 	return err;
 }
 
-EXPORT_SYMBOL(compat_ip_getsockopt);
+EXPORT_SYMBOL_NS(inet, compat_ip_getsockopt);
 #endif
 
-EXPORT_SYMBOL(ip_cmsg_recv);
+EXPORT_SYMBOL_NS(inet, ip_cmsg_recv);
 
-EXPORT_SYMBOL(ip_getsockopt);
-EXPORT_SYMBOL(ip_setsockopt);
+EXPORT_SYMBOL_NS(inet, ip_getsockopt);
+EXPORT_SYMBOL_NS(inet, ip_setsockopt);
