From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: add real socket cookies
Date: Tue, 10 Mar 2015 15:45:33 -0700
Message-ID: <1426027533.11398.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Eric Salo <salo@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:45089 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691AbbCJWpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 18:45:35 -0400
Received: by igjz20 with SMTP id z20so8193049igj.4
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 15:45:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

A long standing problem in netlink socket dumps is the use
of kernel socket addresses as cookies.

1) It is a security concern.

2) Sockets can be reused quite quickly, so there is
   no guarantee a cookie is used once and identify
   a flow.

3) request sock, establish sock, and timewait socks
   for a given flow have different cookies.


Part of our effort to bring better TCP statistics requires
to switch to a different allocator.

In this patch, I chose to use a per network namespace 64bit generator,
and to use it only in the case a socket needs to be dumped to netlink.

Note that I tried to carry cookies from request sock, to establish sock,
then timewait sockets.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Eric Salo <salo@google.com>
---
 include/linux/sock_diag.h        |    4 +--
 include/net/inet_sock.h          |    2 +
 include/net/inet_timewait_sock.h |    1 
 include/net/net_namespace.h      |    2 +
 include/net/sock.h               |    3 ++
 net/core/sock.c                  |    1 
 net/core/sock_diag.c             |   37 +++++++++++++++++++++--------
 net/dccp/ipv4.c                  |    2 +
 net/ipv4/inet_connection_sock.c  |    3 +-
 net/ipv4/inet_diag.c             |   14 +++++++---
 net/ipv4/inet_timewait_sock.c    |    1 
 net/ipv4/syncookies.c            |    1 
 net/ipv4/tcp_input.c             |    2 +
 13 files changed, 55 insertions(+), 18 deletions(-)

diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index b5ad7d35a636..083ac388098e 100644
--- a/include/linux/sock_diag.h
+++ b/include/linux/sock_diag.h
@@ -19,8 +19,8 @@ void sock_diag_unregister(const struct sock_diag_handler *h);
 void sock_diag_register_inet_compat(int (*fn)(struct sk_buff *skb, struct nlmsghdr *nlh));
 void sock_diag_unregister_inet_compat(int (*fn)(struct sk_buff *skb, struct nlmsghdr *nlh));
 
-int sock_diag_check_cookie(void *sk, const __u32 *cookie);
-void sock_diag_save_cookie(void *sk, __u32 *cookie);
+int sock_diag_check_cookie(struct sock *sk, const __u32 *cookie);
+void sock_diag_save_cookie(struct sock *sk, __u32 *cookie);
 
 int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attr);
 int sock_diag_put_filterinfo(bool may_report_filterinfo, struct sock *sk,
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index eb16c7beed1e..e565afdc14ad 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -77,6 +77,8 @@ struct inet_request_sock {
 #define ir_v6_rmt_addr		req.__req_common.skc_v6_daddr
 #define ir_v6_loc_addr		req.__req_common.skc_v6_rcv_saddr
 #define ir_iif			req.__req_common.skc_bound_dev_if
+#define ir_cookie		req.__req_common.skc_cookie
+#define ireq_net		req.__req_common.skc_net
 
 	kmemcheck_bitfield_begin(flags);
 	u16			snd_wscale : 4,
diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 6c566034e26d..b7ce1003c429 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -122,6 +122,7 @@ struct inet_timewait_sock {
 #define tw_v6_rcv_saddr    	__tw_common.skc_v6_rcv_saddr
 #define tw_dport		__tw_common.skc_dport
 #define tw_num			__tw_common.skc_num
+#define tw_cookie		__tw_common.skc_cookie
 
 	int			tw_timeout;
 	volatile unsigned char	tw_substate;
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 2cb9acb618e9..e086f4030dd2 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -56,6 +56,8 @@ struct net {
 #endif
 	spinlock_t		rules_mod_lock;
 
+	atomic64_t		cookie_gen;
+
 	struct list_head	list;		/* list of network namespaces */
 	struct list_head	cleanup_list;	/* namespaces on death row */
 	struct list_head	exit_list;	/* Use only net_mutex */
diff --git a/include/net/sock.h b/include/net/sock.h
index 250822cc1e02..d996c633bec2 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -199,6 +199,8 @@ struct sock_common {
 	struct in6_addr		skc_v6_rcv_saddr;
 #endif
 
+	atomic64_t		skc_cookie;
+
 	/*
 	 * fields between dontcopy_begin/dontcopy_end
 	 * are not copied in sock_copy()
@@ -329,6 +331,7 @@ struct sock {
 #define sk_net			__sk_common.skc_net
 #define sk_v6_daddr		__sk_common.skc_v6_daddr
 #define sk_v6_rcv_saddr	__sk_common.skc_v6_rcv_saddr
+#define sk_cookie		__sk_common.skc_cookie
 
 	socket_lock_t		sk_lock;
 	struct sk_buff_head	sk_receive_queue;
diff --git a/net/core/sock.c b/net/core/sock.c
index 726e1f99aa8d..a9a9c2ff9260 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1538,6 +1538,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		newsk->sk_err	   = 0;
 		newsk->sk_priority = 0;
 		newsk->sk_incoming_cpu = raw_smp_processor_id();
+		atomic64_set(&newsk->sk_cookie, 0);
 		/*
 		 * Before updating sk_refcnt, we must commit prior changes to memory
 		 * (Documentation/RCU/rculist_nulls.txt for details)
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index 96e70ee05a8d..74dddf84adcd 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -13,22 +13,39 @@ static const struct sock_diag_handler *sock_diag_handlers[AF_MAX];
 static int (*inet_rcv_compat)(struct sk_buff *skb, struct nlmsghdr *nlh);
 static DEFINE_MUTEX(sock_diag_table_mutex);
 
-int sock_diag_check_cookie(void *sk, const __u32 *cookie)
+static u64 sock_gen_cookie(struct sock *sk)
 {
-	if ((cookie[0] != INET_DIAG_NOCOOKIE ||
-	     cookie[1] != INET_DIAG_NOCOOKIE) &&
-	    ((u32)(unsigned long)sk != cookie[0] ||
-	     (u32)((((unsigned long)sk) >> 31) >> 1) != cookie[1]))
-		return -ESTALE;
-	else
+	while (1) {
+		u64 res = atomic64_read(&sk->sk_cookie);
+
+		if (res)
+			return res;
+		res = atomic64_inc_return(&sock_net(sk)->cookie_gen);
+		atomic64_cmpxchg(&sk->sk_cookie, 0, res);
+	}
+}
+
+int sock_diag_check_cookie(struct sock *sk, const __u32 *cookie)
+{
+	u64 res;
+
+	if (cookie[0] == INET_DIAG_NOCOOKIE && cookie[1] == INET_DIAG_NOCOOKIE)
 		return 0;
+
+	res = sock_gen_cookie(sk);
+	if ((u32)res != cookie[0] || (u32)(res >> 32) != cookie[1])
+		return -ESTALE;
+
+	return 0;
 }
 EXPORT_SYMBOL_GPL(sock_diag_check_cookie);
 
-void sock_diag_save_cookie(void *sk, __u32 *cookie)
+void sock_diag_save_cookie(struct sock *sk, __u32 *cookie)
 {
-	cookie[0] = (u32)(unsigned long)sk;
-	cookie[1] = (u32)(((unsigned long)sk >> 31) >> 1);
+	u64 res = sock_gen_cookie(sk);
+
+	cookie[0] = (u32)res;
+	cookie[1] = (u32)(res >> 32);
 }
 EXPORT_SYMBOL_GPL(sock_diag_save_cookie);
 
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index e45b968613a4..207281ae3536 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -641,6 +641,8 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	ireq = inet_rsk(req);
 	ireq->ir_loc_addr = ip_hdr(skb)->daddr;
 	ireq->ir_rmt_addr = ip_hdr(skb)->saddr;
+	ireq->ireq_net = sock_net(sk);
+	atomic64_set(&ireq->ir_cookie, 0);
 
 	/*
 	 * Step 3: Process LISTEN state
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 14d02ea905b6..a097ae38b639 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -678,7 +678,8 @@ struct sock *inet_csk_clone_lock(const struct sock *sk,
 		newsk->sk_write_space = sk_stream_write_space;
 
 		newsk->sk_mark = inet_rsk(req)->ir_mark;
-
+		atomic64_cmpxchg(&newsk->sk_cookie, 0,
+				 atomic64_read(&inet_rsk(req)->ir_cookie));
 		newicsk->icsk_retransmits = 0;
 		newicsk->icsk_backoff	  = 0;
 		newicsk->icsk_probes_out  = 0;
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index ac3bfb458afd..29317ff4a007 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -221,12 +221,13 @@ static int inet_csk_diag_fill(struct sock *sk,
 				 user_ns, portid, seq, nlmsg_flags, unlh);
 }
 
-static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
+static int inet_twsk_diag_fill(struct sock *sk,
 			       struct sk_buff *skb,
 			       const struct inet_diag_req_v2 *req,
 			       u32 portid, u32 seq, u16 nlmsg_flags,
 			       const struct nlmsghdr *unlh)
 {
+	struct inet_timewait_sock *tw = inet_twsk(sk);
 	struct inet_diag_msg *r;
 	struct nlmsghdr *nlh;
 	s32 tmo;
@@ -247,7 +248,7 @@ static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 	r->idiag_retrans      = 0;
 
 	r->id.idiag_if	      = tw->tw_bound_dev_if;
-	sock_diag_save_cookie(tw, r->id.idiag_cookie);
+	sock_diag_save_cookie(sk, r->id.idiag_cookie);
 
 	r->id.idiag_sport     = tw->tw_sport;
 	r->id.idiag_dport     = tw->tw_dport;
@@ -283,7 +284,7 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 			const struct nlmsghdr *unlh)
 {
 	if (sk->sk_state == TCP_TIME_WAIT)
-		return inet_twsk_diag_fill(inet_twsk(sk), skb, r, portid, seq,
+		return inet_twsk_diag_fill(sk, skb, r, portid, seq,
 					   nlmsg_flags, unlh);
 
 	return inet_csk_diag_fill(sk, skb, r, user_ns, portid, seq,
@@ -675,7 +676,7 @@ static int inet_twsk_diag_dump(struct sock *sk,
 	if (!inet_diag_bc_sk(bc, sk))
 		return 0;
 
-	return inet_twsk_diag_fill(inet_twsk(sk), skb, r,
+	return inet_twsk_diag_fill(sk, skb, r,
 				   NETLINK_CB(cb->skb).portid,
 				   cb->nlh->nlmsg_seq, NLM_F_MULTI, cb->nlh);
 }
@@ -734,7 +735,10 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 	r->idiag_retrans = req->num_retrans;
 
 	r->id.idiag_if = sk->sk_bound_dev_if;
-	sock_diag_save_cookie(req, r->id.idiag_cookie);
+
+	BUILD_BUG_ON(offsetof(struct inet_request_sock, ir_cookie) !=
+		     offsetof(struct sock, sk_cookie));
+	sock_diag_save_cookie((struct sock *)ireq, r->id.idiag_cookie);
 
 	tmo = req->expires - jiffies;
 	if (tmo < 0)
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 6d592f8555fb..2bd980526631 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -195,6 +195,7 @@ struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int stat
 		tw->tw_ipv6only	    = 0;
 		tw->tw_transparent  = inet->transparent;
 		tw->tw_prot	    = sk->sk_prot_creator;
+		atomic64_set(&tw->tw_cookie, atomic64_read(&sk->sk_cookie));
 		twsk_net_set(tw, hold_net(sock_net(sk)));
 		/*
 		 * Because we use RCU lookups, we should not set tw_refcnt
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 45fe60c5238e..ece31b426013 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -346,6 +346,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	req->ts_recent		= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsval : 0;
 	treq->snt_synack	= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsecr : 0;
 	treq->listener		= NULL;
+	ireq->ireq_net		= sock_net(sk);
 
 	/* We throwed the options of the initial SYN away, so we hope
 	 * the ACK carries the same options again (see RFC1122 4.2.3.8)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index fb4cf8b8e121..d7045f5f6ebf 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5965,6 +5965,8 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 
 	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
 	tcp_openreq_init(req, &tmp_opt, skb, sk);
+	inet_rsk(req)->ireq_net = sock_net(sk);
+	atomic64_set(&inet_rsk(req)->ir_cookie, 0);
 
 	af_ops->init_req(req, sk, skb);
 
