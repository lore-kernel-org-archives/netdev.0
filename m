From: Dmitry Popov <dp@highloadlab.com>
Subject: [PATCH 1/5] tcp: cookie transactions scaling
Date: Wed, 27 Oct 2010 17:27:08 +0400
Message-ID: <AANLkTin+B9-U=SEkX7udR+r0Yovim_xHPYJ3CqPF0Da2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "David S. Miller" <davem@davemloft.net>,
	William.Allen.Simpson@gmail.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andreas Petlund <apetlund@simula.no>,
	Shan Wei <shanwei@cn.fujitsu.co
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:51418 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761167Ab0J0N1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 09:27:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Popov <dp@highloadlab.com>

TCPCT usage doesn't need socket lock now.

TCPCT changes via setsockopt use RCU and each tcp_cookie_values struct
has reference count. def_cookie_values (default cookie values) is used
to eliminate NULL pointer checks).

Signed-off-by: Dmitry Popov <dp@highloadlab.com>
---
 include/linux/tcp.h      |    6 ++
 include/net/tcp.h        |   18 ++++++-
 net/ipv4/tcp.c           |  124 +++++++++++++++++++++++++--------------------
 net/ipv4/tcp_input.c     |    4 +-
 net/ipv4/tcp_ipv4.c      |   28 +++++++---
 net/ipv4/tcp_minisocks.c |   20 ++++++--
 net/ipv4/tcp_output.c    |   31 +++++++++---
 net/ipv6/tcp_ipv6.c      |    9 ++--
 8 files changed, 156 insertions(+), 84 deletions(-)
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 806266a..3436176 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -463,6 +463,12 @@ struct tcp_sock {
 	/* When the cookie options are generated and exchanged, then this
 	 * object holds a reference to them (cookie_values->kref).  Also
 	 * contains related tcp_cookie_transactions fields.
+	 *
+	 * Note:
+	 * cookie_values are partially under RCU:
+	 * only s_data_constant, s_data_desired and s_data_payload should be
+	 * changed via RCU. Writers should use a socket lock.
+	 * So readers which hold this lock may omit rcu_reader_lock.
 	 */
 	struct tcp_cookie_values  *cookie_values;
 };
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 3f0dbec..08e6ce1 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1498,6 +1498,7 @@ extern int tcp_cookie_generator(u32 *bakery);
  *			cookie option is present.
  */
 struct tcp_cookie_values {
+	struct rcu_head	rcu_head;
 	struct kref	kref;
 	u8		cookie_pair[TCP_COOKIE_PAIR_SIZE];
 	u8		cookie_pair_size;
@@ -1510,18 +1511,33 @@ struct tcp_cookie_values {
 	u8		s_data_payload[0];
 };

+extern struct tcp_cookie_values def_cookie_values;
+
 static inline void tcp_cookie_values_release(struct kref *kref)
 {
 	kfree(container_of(kref, struct tcp_cookie_values, kref));
 }

+/* RCU-protected desired size of cookie
+ */
+static inline u8 rcu_tcp_cookie_desired(const struct tcp_sock *tp)
+{
+	u8 res;
+
+	rcu_read_lock();
+	res = rcu_dereference(tp->cookie_values)->cookie_desired;
+	rcu_read_unlock();
+
+	return res;
+}
+
 /* The length of constant payload data.  Note that s_data_desired is
  * overloaded, depending on s_data_constant: either the length of constant
  * data (returned here) or the limit on variable data.
  */
 static inline int tcp_s_data_size(const struct tcp_sock *tp)
 {
-	return (tp->cookie_values != NULL && tp->cookie_values->s_data_constant)
+	return tp->cookie_values->s_data_constant
 		? tp->cookie_values->s_data_desired
 		: 0;
 }
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index f115ea6..ebb9d80 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -309,6 +309,20 @@ struct tcp_splice_state {
 };

 /*
+ * Default cookie values struct
+ * Initialization is for clarity only
+ */
+struct tcp_cookie_values def_cookie_values __read_mostly = {
+	.cookie_pair_size = 0,
+	.cookie_desired = 0,
+	.s_data_desired = 0,
+	.s_data_constant = 0,
+	.s_data_in = 0,
+	.s_data_out = 0
+};
+EXPORT_SYMBOL(def_cookie_values);
+
+/*
  * Pressure flag: try to collapse.
  * Technical note: it is used by multiple contexts non atomically.
  * All the __sk_mem_schedule() is of this nature: accounting
@@ -2145,6 +2159,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 	case TCP_COOKIE_TRANSACTIONS: {
 		struct tcp_cookie_transactions ctd;
 		struct tcp_cookie_values *cvp = NULL;
+		struct kref *oldkref = NULL;

 		if (sizeof(ctd) > optlen)
 			return -EINVAL;
@@ -2166,66 +2181,63 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		if (TCP_COOKIE_OUT_NEVER & ctd.tcpct_flags) {
 			/* Supercedes all other values */
 			lock_sock(sk);
-			if (tp->cookie_values != NULL) {
-				kref_put(&tp->cookie_values->kref,
-					 tcp_cookie_values_release);
-				tp->cookie_values = NULL;
+
+			if (tp->cookie_values != &def_cookie_values) {
+				oldkref = &tp->cookie_values->kref;
+				rcu_assign_pointer(tp->cookie_values,
+						   &def_cookie_values);
 			}
+
 			tp->rx_opt.cookie_in_always = 0; /* false */
 			tp->rx_opt.cookie_out_never = 1; /* true */
 			release_sock(sk);
+
+			if (oldkref) {
+				synchronize_rcu();
+				kref_put(oldkref, tcp_cookie_values_release);
+			}
+
 			return err;
 		}

-		/* Allocate ancillary memory before locking.
-		 */
-		if (ctd.tcpct_used > 0 ||
-		    (tp->cookie_values == NULL &&
-		     (sysctl_tcp_cookie_size > 0 ||
-		      ctd.tcpct_cookie_desired > 0 ||
-		      ctd.tcpct_s_data_desired > 0))) {
-			cvp = kzalloc(sizeof(*cvp) + ctd.tcpct_used,
-				      GFP_KERNEL);
-			if (cvp == NULL)
-				return -ENOMEM;
-
-			kref_init(&cvp->kref);
+		/* Setup cvp before locking  */
+		cvp = kzalloc(sizeof(*cvp) + ctd.tcpct_used,
+				  GFP_KERNEL);
+		if (cvp == NULL)
+			return -ENOMEM;
+
+		kref_init(&cvp->kref);
+
+		cvp->cookie_desired = ctd.tcpct_cookie_desired;
+
+		if (ctd.tcpct_used > 0) {
+			memcpy(cvp->s_data_payload, ctd.tcpct_value,
+				   ctd.tcpct_used);
+			cvp->s_data_desired = ctd.tcpct_used;
+			cvp->s_data_constant = 1; /* true */
+		} else {
+			/* No constant payload data. */
+			cvp->s_data_desired = ctd.tcpct_s_data_desired;
+			cvp->s_data_constant = 0; /* false */
 		}
+
 		lock_sock(sk);
 		tp->rx_opt.cookie_in_always =
 			(TCP_COOKIE_IN_ALWAYS & ctd.tcpct_flags);
 		tp->rx_opt.cookie_out_never = 0; /* false */

-		if (tp->cookie_values != NULL) {
-			if (cvp != NULL) {
-				/* Changed values are recorded by a changed
-				 * pointer, ensuring the cookie will differ,
-				 * without separately hashing each value later.
-				 */
-				kref_put(&tp->cookie_values->kref,
-					 tcp_cookie_values_release);
-			} else {
-				cvp = tp->cookie_values;
-			}
+		if (tp->cookie_values != &def_cookie_values) {
+			/* We have to release old structure, later */
+			oldkref = &tp->cookie_values->kref;
 		}

-		if (cvp != NULL) {
-			cvp->cookie_desired = ctd.tcpct_cookie_desired;
+		rcu_assign_pointer(tp->cookie_values, cvp);
+		release_sock(sk);
+		synchronize_rcu();

-			if (ctd.tcpct_used > 0) {
-				memcpy(cvp->s_data_payload, ctd.tcpct_value,
-				       ctd.tcpct_used);
-				cvp->s_data_desired = ctd.tcpct_used;
-				cvp->s_data_constant = 1; /* true */
-			} else {
-				/* No constant payload data. */
-				cvp->s_data_desired = ctd.tcpct_s_data_desired;
-				cvp->s_data_constant = 0; /* false */
-			}
+		if (oldkref)
+			kref_put(oldkref, tcp_cookie_values_release);

-			tp->cookie_values = cvp;
-		}
-		release_sock(sk);
 		return err;
 	}
 	default:
@@ -2572,7 +2584,7 @@ static int do_tcp_getsockopt(struct sock *sk, int level,

 	case TCP_COOKIE_TRANSACTIONS: {
 		struct tcp_cookie_transactions ctd;
-		struct tcp_cookie_values *cvp = tp->cookie_values;
+		struct tcp_cookie_values *cvp;

 		if (get_user(len, optlen))
 			return -EFAULT;
@@ -2585,19 +2597,21 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 				| (tp->rx_opt.cookie_out_never ?
 				   TCP_COOKIE_OUT_NEVER : 0);

-		if (cvp != NULL) {
-			ctd.tcpct_flags |= (cvp->s_data_in ?
-					    TCP_S_DATA_IN : 0)
-					 | (cvp->s_data_out ?
-					    TCP_S_DATA_OUT : 0);
+		rcu_read_lock();

-			ctd.tcpct_cookie_desired = cvp->cookie_desired;
-			ctd.tcpct_s_data_desired = cvp->s_data_desired;
+		cvp = rcu_dereference(tp->cookie_values);
+		ctd.tcpct_flags |= (cvp->s_data_in ?
+					TCP_S_DATA_IN : 0)
+				 | (cvp->s_data_out ?
+					TCP_S_DATA_OUT : 0);

-			memcpy(&ctd.tcpct_value[0], &cvp->cookie_pair[0],
-			       cvp->cookie_pair_size);
-			ctd.tcpct_used = cvp->cookie_pair_size;
-		}
+		ctd.tcpct_cookie_desired = cvp->cookie_desired;
+		ctd.tcpct_s_data_desired = cvp->s_data_desired;
+
+		memcpy(&ctd.tcpct_value[0], &cvp->cookie_pair[0],
+			   cvp->cookie_pair_size);
+		ctd.tcpct_used = cvp->cookie_pair_size;
+		rcu_read_unlock();

 		if (put_user(sizeof(ctd), optlen))
 			return -EFAULT;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b55f60f..65fe78e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5450,6 +5450,7 @@ static int tcp_rcv_synsent_state_process(struct
sock *sk, struct sk_buff *skb,
 	u8 *hash_location;
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
+	/* We're under socket lock, no need for RCU */
 	struct tcp_cookie_values *cvp = tp->cookie_values;
 	int saved_clamp = tp->rx_opt.mss_clamp;

@@ -5551,8 +5552,7 @@ static int tcp_rcv_synsent_state_process(struct
sock *sk, struct sk_buff *skb,
 		 * is initialized. */
 		tp->copied_seq = tp->rcv_nxt;

-		if (cvp != NULL &&
-		    cvp->cookie_pair_size > 0 &&
+		if (cvp->cookie_pair_size > 0 &&
 		    tp->rx_opt.cookie_plus > 0) {
 			int cookie_size = tp->rx_opt.cookie_plus
 					- TCPOLEN_COOKIE_BASE;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 6068b17..3de881e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1380,8 +1380,7 @@ int tcp_v4_conn_request(struct sock *sk, struct
sk_buff *skb)
 	    tmp_opt.saw_tstamp &&
 	    !tp->rx_opt.cookie_out_never &&
 	    (sysctl_tcp_cookie_size > 0 ||
-	     (tp->cookie_values != NULL &&
-	      tp->cookie_values->cookie_desired > 0))) {
+		 rcu_tcp_cookie_desired(tp) > 0)) {
 		u8 *c;
 		u32 *mess = &tmp_ext.cookie_bakery[COOKIE_DIGEST_WORDS];
 		int l = tmp_opt.cookie_plus - TCPOLEN_COOKIE_BASE;
@@ -1403,14 +1402,15 @@ int tcp_v4_conn_request(struct sock *sk,
struct sk_buff *skb)
 #endif
 		tmp_ext.cookie_out_never = 0; /* false */
 		tmp_ext.cookie_plus = tmp_opt.cookie_plus;
+		tmp_ext.cookie_in_always = tp->rx_opt.cookie_in_always;
 	} else if (!tp->rx_opt.cookie_in_always) {
 		/* redundant indications, but ensure initialization. */
 		tmp_ext.cookie_out_never = 1; /* true */
 		tmp_ext.cookie_plus = 0;
+		tmp_ext.cookie_in_always = 0;
 	} else {
 		goto drop_and_release;
 	}
-	tmp_ext.cookie_in_always = tp->rx_opt.cookie_in_always;

 	if (want_cookie && !tmp_opt.saw_tstamp)
 		tcp_clear_options(&tmp_opt);
@@ -1990,9 +1990,11 @@ static int tcp_v4_init_sock(struct sock *sk)
 		tp->cookie_values =
 			kzalloc(sizeof(*tp->cookie_values),
 				sk->sk_allocation);
-		if (tp->cookie_values != NULL)
-			kref_init(&tp->cookie_values->kref);
 	}
+	if (tp->cookie_values != NULL)
+		kref_init(&tp->cookie_values->kref);
+	else
+		tp->cookie_values = &def_cookie_values;
 	/* Presumed zeroed, in order of appearance:
 	 *	cookie_in_always, cookie_out_never,
 	 *	s_data_constant, s_data_in, s_data_out
@@ -2007,6 +2009,13 @@ static int tcp_v4_init_sock(struct sock *sk)
 	return 0;
 }

+static void tcp_cookie_values_put(struct rcu_head *rcu_head)
+{
+	struct tcp_cookie_values *cvp =
+		container_of(rcu_head, struct tcp_cookie_values, rcu_head);
+	kref_put(&cvp->kref, tcp_cookie_values_release);
+}
+
 void tcp_v4_destroy_sock(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -2047,10 +2056,11 @@ void tcp_v4_destroy_sock(struct sock *sk)
 	}

 	/* TCP Cookie Transactions */
-	if (tp->cookie_values != NULL) {
-		kref_put(&tp->cookie_values->kref,
-			 tcp_cookie_values_release);
-		tp->cookie_values = NULL;
+	if (tp->cookie_values != &def_cookie_values) {
+		struct rcu_head *rcu_head = &tp->cookie_values->rcu_head;
+
+		rcu_assign_pointer(tp->cookie_values, &def_cookie_values);
+		call_rcu(rcu_head, tcp_cookie_values_put);
 	}

 	percpu_counter_dec(&tcp_sockets_allocated);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 599752c..d62c65a 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -375,7 +375,8 @@ struct sock *tcp_create_openreq_child(struct sock
*sk, struct request_sock *req,
 		struct inet_connection_sock *newicsk = inet_csk(newsk);
 		struct tcp_sock *newtp = tcp_sk(newsk);
 		struct tcp_sock *oldtp = tcp_sk(sk);
-		struct tcp_cookie_values *oldcvp = oldtp->cookie_values;
+		struct tcp_cookie_values *oldcvp;
+		int s_data_size;

 		/* TCP Cookie Transactions require space for the cookie pair,
 		 * as it differs for each connection.  There is no need to
@@ -385,7 +386,10 @@ struct sock *tcp_create_openreq_child(struct sock
*sk, struct request_sock *req,
 		 * Presumed copied, in order of appearance:
 		 *	cookie_in_always, cookie_out_never
 		 */
-		if (oldcvp != NULL) {
+
+		rcu_read_lock();
+		oldcvp = rcu_dereference(oldtp->cookie_values);
+		if (oldcvp != &def_cookie_values) {
 			struct tcp_cookie_values *newcvp =
 				kzalloc(sizeof(*newtp->cookie_values),
 					GFP_ATOMIC);
@@ -397,9 +401,15 @@ struct sock *tcp_create_openreq_child(struct sock
*sk, struct request_sock *req,
 				newtp->cookie_values = newcvp;
 			} else {
 				/* Not Yet Implemented */
-				newtp->cookie_values = NULL;
+				newtp->cookie_values = &def_cookie_values;
 			}
+		} else {
+			newtp->cookie_values = &def_cookie_values;
 		}
+		s_data_size = oldcvp->s_data_constant ?
+				oldcvp->s_data_desired :
+				0;
+		rcu_read_unlock();

 		/* Now setup tcp_sock */
 		newtp->pred_flags = 0;
@@ -409,7 +419,7 @@ struct sock *tcp_create_openreq_child(struct sock
*sk, struct request_sock *req,

 		newtp->snd_sml = newtp->snd_una =
 		newtp->snd_nxt = newtp->snd_up =
-			treq->snt_isn + 1 + tcp_s_data_size(oldtp);
+			treq->snt_isn + 1 + s_data_size;

 		tcp_prequeue_init(newtp);

@@ -443,7 +453,7 @@ struct sock *tcp_create_openreq_child(struct sock
*sk, struct request_sock *req,
 		tcp_init_xmit_timers(newsk);
 		skb_queue_head_init(&newtp->out_of_order_queue);
 		newtp->write_seq = newtp->pushed_seq =
-			treq->snt_isn + 1 + tcp_s_data_size(oldtp);
+			treq->snt_isn + 1 + s_data_size;

 		newtp->rx_opt.saw_tstamp = 0;

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8954453..eef2d66 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -562,11 +562,14 @@ static unsigned tcp_syn_options(struct sock *sk,
struct sk_buff *skb,
 				struct tcp_out_options *opts,
 				struct tcp_md5sig_key **md5) {
 	struct tcp_sock *tp = tcp_sk(sk);
+	/* As long as tcp_syn_options is called under socket lock,
+	 * we don't need RCU here */
 	struct tcp_cookie_values *cvp = tp->cookie_values;
 	unsigned remaining = MAX_TCP_OPTION_SPACE;
-	u8 cookie_size = (!tp->rx_opt.cookie_out_never && cvp != NULL) ?
-			 tcp_cookie_size_check(cvp->cookie_desired) :
-			 0;
+	u8 cookie_size =
+		(!tp->rx_opt.cookie_out_never && cvp != &def_cookie_values) ?
+			tcp_cookie_size_check(cvp->cookie_desired) :
+			0;

 #ifdef CONFIG_TCP_MD5SIG
 	*md5 = tp->af_specific->md5_get(sk, sk);
@@ -2407,19 +2410,28 @@ struct sk_buff *tcp_make_synack(struct sock
*sk, struct dst_entry *dst,
 	struct tcp_extend_values *xvp = tcp_xv(rvp);
 	struct inet_request_sock *ireq = inet_rsk(req);
 	struct tcp_sock *tp = tcp_sk(sk);
-	const struct tcp_cookie_values *cvp = tp->cookie_values;
+	struct tcp_cookie_values *cvp;
 	struct tcphdr *th;
 	struct sk_buff *skb;
 	struct tcp_md5sig_key *md5;
 	int tcp_header_size;
 	int mss;
-	int s_data_desired = 0;
+	int s_data_desired;
+
+	rcu_read_lock();
+	cvp = rcu_dereference(tp->cookie_values);
+	if (cvp != &def_cookie_values)
+		kref_get(&cvp->kref);
+	rcu_read_unlock();
+
+	s_data_desired = cvp->s_data_constant ? cvp->s_data_desired : 0;

-	if (cvp != NULL && cvp->s_data_constant && cvp->s_data_desired)
-		s_data_desired = cvp->s_data_desired;
 	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15 + s_data_desired, 1, GFP_ATOMIC);
-	if (skb == NULL)
+	if (skb == NULL) {
+		if (cvp != &def_cookie_values)
+			kref_put(&cvp->kref, tcp_cookie_values_release);
 		return NULL;
+	}

 	/* Reserve space for headers. */
 	skb_reserve(skb, MAX_TCP_HEADER);
@@ -2506,6 +2518,9 @@ struct sk_buff *tcp_make_synack(struct sock *sk,
struct dst_entry *dst,
 		}
 	}

+	if (cvp != &def_cookie_values)
+		kref_put(&cvp->kref, tcp_cookie_values_release);
+
 	th->seq = htonl(TCP_SKB_CB(skb)->seq);
 	th->ack_seq = htonl(tcp_rsk(req)->rcv_isn + 1);

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 80d2d20..a3fa1f9 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1306,8 +1306,7 @@ static int tcp_v6_conn_request(struct sock *sk,
struct sk_buff *skb)
 	    tmp_opt.saw_tstamp &&
 	    !tp->rx_opt.cookie_out_never &&
 	    (sysctl_tcp_cookie_size > 0 ||
-	     (tp->cookie_values != NULL &&
-	      tp->cookie_values->cookie_desired > 0))) {
+	     rcu_tcp_cookie_desired(tp) > 0)) {
 		u8 *c;
 		u32 *d;
 		u32 *mess = &tmp_ext.cookie_bakery[COOKIE_DIGEST_WORDS];
@@ -2012,9 +2011,11 @@ static int tcp_v6_init_sock(struct sock *sk)
 		tp->cookie_values =
 			kzalloc(sizeof(*tp->cookie_values),
 				sk->sk_allocation);
-		if (tp->cookie_values != NULL)
-			kref_init(&tp->cookie_values->kref);
 	}
+	if (tp->cookie_values != NULL)
+		kref_init(&tp->cookie_values->kref);
+	else
+		tp->cookie_values = &def_cookie_values;
 	/* Presumed zeroed, in order of appearance:
 	 *	cookie_in_always, cookie_out_never,
 	 *	s_data_constant, s_data_in, s_data_out
