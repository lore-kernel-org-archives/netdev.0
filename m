From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH] tcp: Remove TCPCT
Date: Sun, 17 Mar 2013 19:23:34 +0100
Message-ID: <1363544614-14411-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:40630 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932536Ab3CQSXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Mar 2013 14:23:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCPCT uses option-number 253, reserved for experimental use and should
not be used in production environments.
Further, TCPCT does not fully implement RFC 6013.

As a nice side-effect, removing TCPCT increases TCP's performance for
very short flows:

Doing an apache-benchmark with -c 100 -n 100000, sending HTTP-requests
for files of 1KB size.

before this patch:
	average (among 7 runs) of 20845.5 Requests/Second
after:
	average (among 7 runs) of 21403.6 Requests/Second

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 Documentation/networking/ip-sysctl.txt |   8 -
 drivers/infiniband/hw/cxgb4/cm.c       |   2 +-
 include/linux/tcp.h                    |  10 --
 include/net/request_sock.h             |   8 +-
 include/net/tcp.h                      |  89 +----------
 include/uapi/linux/tcp.h               |  26 ----
 net/dccp/ipv4.c                        |   5 +-
 net/dccp/ipv6.c                        |   5 +-
 net/ipv4/inet_connection_sock.c        |   2 +-
 net/ipv4/syncookies.c                  |   3 +-
 net/ipv4/sysctl_net_ipv4.c             |   7 -
 net/ipv4/tcp.c                         | 267 ---------------------------------
 net/ipv4/tcp_input.c                   |  69 +--------
 net/ipv4/tcp_ipv4.c                    |  60 +-------
 net/ipv4/tcp_minisocks.c               |  40 +----
 net/ipv4/tcp_output.c                  | 219 +--------------------------
 net/ipv6/syncookies.c                  |   3 +-
 net/ipv6/tcp_ipv6.c                    |  56 +------
 18 files changed, 38 insertions(+), 841 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 18a24c4..17953e2 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -175,14 +175,6 @@ tcp_congestion_control - STRING
 	is inherited.
 	[see setsockopt(listenfd, SOL_TCP, TCP_CONGESTION, "name" ...) ]
 
-tcp_cookie_size - INTEGER
-	Default size of TCP Cookie Transactions (TCPCT) option, that may be
-	overridden on a per socket basis by the TCPCT socket option.
-	Values greater than the maximum (16) are interpreted as the maximum.
-	Values greater than zero and less than the minimum (8) are interpreted
-	as the minimum.  Odd values are interpreted as the next even value.
-	Default: 0 (off).
-
 tcp_dsack - BOOLEAN
 	Allows TCP to send "duplicate" SACKs.
 
diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 8dcc84f..54fd31f 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -2915,7 +2915,7 @@ static void build_cpl_pass_accept_req(struct sk_buff *skb, int stid , u8 tos)
 	 */
 	memset(&tmp_opt, 0, sizeof(tmp_opt));
 	tcp_clear_options(&tmp_opt);
-	tcp_parse_options(skb, &tmp_opt, NULL, 0, NULL);
+	tcp_parse_options(skb, &tmp_opt, 0, NULL);
 
 	req = (struct cpl_pass_accept_req *)__skb_push(skb, sizeof(*req));
 	memset(req, 0, sizeof(*req));
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 763c108..ed6a745 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -90,9 +90,6 @@ struct tcp_options_received {
 		sack_ok : 4,	/* SACK seen on SYN packet		*/
 		snd_wscale : 4,	/* Window scaling received from sender	*/
 		rcv_wscale : 4;	/* Window scaling to send to receiver	*/
-	u8	cookie_plus:6,	/* bytes in authenticator/cookie option	*/
-		cookie_out_never:1,
-		cookie_in_always:1;
 	u8	num_sacks;	/* Number of SACK blocks		*/
 	u16	user_mss;	/* mss requested by user in ioctl	*/
 	u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
@@ -102,7 +99,6 @@ static inline void tcp_clear_options(struct tcp_options_received *rx_opt)
 {
 	rx_opt->tstamp_ok = rx_opt->sack_ok = 0;
 	rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
-	rx_opt->cookie_plus = 0;
 }
 
 /* This is the max number of SACKS that we'll generate and process. It's safe
@@ -320,12 +316,6 @@ struct tcp_sock {
 	struct tcp_md5sig_info	__rcu *md5sig_info;
 #endif
 
-	/* When the cookie options are generated and exchanged, then this
-	 * object holds a reference to them (cookie_values->kref).  Also
-	 * contains related tcp_cookie_transactions fields.
-	 */
-	struct tcp_cookie_values  *cookie_values;
-
 /* TCP fastopen related information */
 	struct tcp_fastopen_request *fastopen_req;
 	/* fastopen_rsk points to request_sock that resulted in this big
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index a51dbd1..9069e65 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -27,19 +27,13 @@ struct sk_buff;
 struct dst_entry;
 struct proto;
 
-/* empty to "strongly type" an otherwise void parameter.
- */
-struct request_values {
-};
-
 struct request_sock_ops {
 	int		family;
 	int		obj_size;
 	struct kmem_cache	*slab;
 	char		*slab_name;
 	int		(*rtx_syn_ack)(struct sock *sk,
-				       struct request_sock *req,
-				       struct request_values *rvp);
+				       struct request_sock *req);
 	void		(*send_ack)(struct sock *sk, struct sk_buff *skb,
 				    struct request_sock *req);
 	void		(*send_reset)(struct sock *sk,
diff --git a/include/net/tcp.h b/include/net/tcp.h
index ab9f947..7f2f171 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -179,7 +179,6 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOPT_SACK             5       /* SACK Block */
 #define TCPOPT_TIMESTAMP	8	/* Better RTT estimations/PAWS */
 #define TCPOPT_MD5SIG		19	/* MD5 Signature (RFC2385) */
-#define TCPOPT_COOKIE		253	/* Cookie extension (experimental) */
 #define TCPOPT_EXP		254	/* Experimental */
 /* Magic number to be after the option value for sharing TCP
  * experimental options. See draft-ietf-tcpm-experimental-options-00.txt
@@ -454,7 +453,7 @@ extern void tcp_syn_ack_timeout(struct sock *sk, struct request_sock *req);
 extern int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		       size_t len, int nonblock, int flags, int *addr_len);
 extern void tcp_parse_options(const struct sk_buff *skb,
-			      struct tcp_options_received *opt_rx, const u8 **hvpp,
+			      struct tcp_options_received *opt_rx,
 			      int estab, struct tcp_fastopen_cookie *foc);
 extern const u8 *tcp_parse_md5sig_option(const struct tcphdr *th);
 
@@ -476,7 +475,6 @@ extern int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr,
 extern int tcp_connect(struct sock *sk);
 extern struct sk_buff * tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 					struct request_sock *req,
-					struct request_values *rvp,
 					struct tcp_fastopen_cookie *foc);
 extern int tcp_disconnect(struct sock *sk, int flags);
 
@@ -1589,91 +1587,6 @@ struct tcp_request_sock_ops {
 #endif
 };
 
-/* Using SHA1 for now, define some constants.
- */
-#define COOKIE_DIGEST_WORDS (SHA_DIGEST_WORDS)
-#define COOKIE_MESSAGE_WORDS (SHA_MESSAGE_BYTES / 4)
-#define COOKIE_WORKSPACE_WORDS (COOKIE_DIGEST_WORDS + COOKIE_MESSAGE_WORDS)
-
-extern int tcp_cookie_generator(u32 *bakery);
-
-/**
- *	struct tcp_cookie_values - each socket needs extra space for the
- *	cookies, together with (optional) space for any SYN data.
- *
- *	A tcp_sock contains a pointer to the current value, and this is
- *	cloned to the tcp_timewait_sock.
- *
- * @cookie_pair:	variable data from the option exchange.
- *
- * @cookie_desired:	user specified tcpct_cookie_desired.  Zero
- *			indicates default (sysctl_tcp_cookie_size).
- *			After cookie sent, remembers size of cookie.
- *			Range 0, TCP_COOKIE_MIN to TCP_COOKIE_MAX.
- *
- * @s_data_desired:	user specified tcpct_s_data_desired.  When the
- *			constant payload is specified (@s_data_constant),
- *			holds its length instead.
- *			Range 0 to TCP_MSS_DESIRED.
- *
- * @s_data_payload:	constant data that is to be included in the
- *			payload of SYN or SYNACK segments when the
- *			cookie option is present.
- */
-struct tcp_cookie_values {
-	struct kref	kref;
-	u8		cookie_pair[TCP_COOKIE_PAIR_SIZE];
-	u8		cookie_pair_size;
-	u8		cookie_desired;
-	u16		s_data_desired:11,
-			s_data_constant:1,
-			s_data_in:1,
-			s_data_out:1,
-			s_data_unused:2;
-	u8		s_data_payload[0];
-};
-
-static inline void tcp_cookie_values_release(struct kref *kref)
-{
-	kfree(container_of(kref, struct tcp_cookie_values, kref));
-}
-
-/* The length of constant payload data.  Note that s_data_desired is
- * overloaded, depending on s_data_constant: either the length of constant
- * data (returned here) or the limit on variable data.
- */
-static inline int tcp_s_data_size(const struct tcp_sock *tp)
-{
-	return (tp->cookie_values != NULL && tp->cookie_values->s_data_constant)
-		? tp->cookie_values->s_data_desired
-		: 0;
-}
-
-/**
- *	struct tcp_extend_values - tcp_ipv?.c to tcp_output.c workspace.
- *
- *	As tcp_request_sock has already been extended in other places, the
- *	only remaining method is to pass stack values along as function
- *	parameters.  These parameters are not needed after sending SYNACK.
- *
- * @cookie_bakery:	cryptographic secret and message workspace.
- *
- * @cookie_plus:	bytes in authenticator/cookie option, copied from
- *			struct tcp_options_received (above).
- */
-struct tcp_extend_values {
-	struct request_values		rv;
-	u32				cookie_bakery[COOKIE_WORKSPACE_WORDS];
-	u8				cookie_plus:6,
-					cookie_out_never:1,
-					cookie_in_always:1;
-};
-
-static inline struct tcp_extend_values *tcp_xv(struct request_values *rvp)
-{
-	return (struct tcp_extend_values *)rvp;
-}
-
 extern void tcp_v4_init(void);
 extern void tcp_init(void);
 
diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index 6b1ead0..8d776eb 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -102,7 +102,6 @@ enum {
 #define TCP_QUICKACK		12	/* Block/reenable quick acks */
 #define TCP_CONGESTION		13	/* Congestion control algorithm */
 #define TCP_MD5SIG		14	/* TCP MD5 Signature (RFC2385) */
-#define TCP_COOKIE_TRANSACTIONS	15	/* TCP Cookie Transactions */
 #define TCP_THIN_LINEAR_TIMEOUTS 16      /* Use linear timeouts for thin streams*/
 #define TCP_THIN_DUPACK         17      /* Fast retrans. after 1 dupack */
 #define TCP_USER_TIMEOUT	18	/* How long for loss retry before timeout */
@@ -199,29 +198,4 @@ struct tcp_md5sig {
 	__u8	tcpm_key[TCP_MD5SIG_MAXKEYLEN];		/* key (binary) */
 };
 
-/* for TCP_COOKIE_TRANSACTIONS (TCPCT) socket option */
-#define TCP_COOKIE_MIN		 8		/*  64-bits */
-#define TCP_COOKIE_MAX		16		/* 128-bits */
-#define TCP_COOKIE_PAIR_SIZE	(2*TCP_COOKIE_MAX)
-
-/* Flags for both getsockopt and setsockopt */
-#define TCP_COOKIE_IN_ALWAYS	(1 << 0)	/* Discard SYN without cookie */
-#define TCP_COOKIE_OUT_NEVER	(1 << 1)	/* Prohibit outgoing cookies,
-						 * supercedes everything. */
-
-/* Flags for getsockopt */
-#define TCP_S_DATA_IN		(1 << 2)	/* Was data received? */
-#define TCP_S_DATA_OUT		(1 << 3)	/* Was data sent? */
-
-/* TCP_COOKIE_TRANSACTIONS data */
-struct tcp_cookie_transactions {
-	__u16	tcpct_flags;			/* see above */
-	__u8	__tcpct_pad1;			/* zero */
-	__u8	tcpct_cookie_desired;		/* bytes */
-	__u16	tcpct_s_data_desired;		/* bytes of variable data */
-	__u16	tcpct_used;			/* bytes in value */
-	__u8	tcpct_value[TCP_MSS_DEFAULT];
-};
-
-
 #endif /* _UAPI_LINUX_TCP_H */
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 4f9f5eb..ebc54fe 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -500,8 +500,7 @@ static struct dst_entry* dccp_v4_route_skb(struct net *net, struct sock *sk,
 	return &rt->dst;
 }
 
-static int dccp_v4_send_response(struct sock *sk, struct request_sock *req,
-				 struct request_values *rv_unused)
+static int dccp_v4_send_response(struct sock *sk, struct request_sock *req)
 {
 	int err = -1;
 	struct sk_buff *skb;
@@ -658,7 +657,7 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	dreq->dreq_gss     = dreq->dreq_iss;
 	dreq->dreq_service = service;
 
-	if (dccp_v4_send_response(sk, req, NULL))
+	if (dccp_v4_send_response(sk, req))
 		goto drop_and_free;
 
 	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 6e05981..9c61f9c 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -213,8 +213,7 @@ out:
 }
 
 
-static int dccp_v6_send_response(struct sock *sk, struct request_sock *req,
-				 struct request_values *rv_unused)
+static int dccp_v6_send_response(struct sock *sk, struct request_sock *req)
 {
 	struct inet6_request_sock *ireq6 = inet6_rsk(req);
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -428,7 +427,7 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	dreq->dreq_gss     = dreq->dreq_iss;
 	dreq->dreq_service = service;
 
-	if (dccp_v6_send_response(sk, req, NULL))
+	if (dccp_v6_send_response(sk, req))
 		goto drop_and_free;
 
 	inet6_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 786d97a..6acb541 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -559,7 +559,7 @@ static inline void syn_ack_recalc(struct request_sock *req, const int thresh,
 
 int inet_rtx_syn_ack(struct sock *parent, struct request_sock *req)
 {
-	int err = req->rsk_ops->rtx_syn_ack(parent, req, NULL);
+	int err = req->rsk_ops->rtx_syn_ack(parent, req);
 
 	if (!err)
 		req->num_retrans++;
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index ef54377..7f4a5cb 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -267,7 +267,6 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 			     struct ip_options *opt)
 {
 	struct tcp_options_received tcp_opt;
-	const u8 *hash_location;
 	struct inet_request_sock *ireq;
 	struct tcp_request_sock *treq;
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -294,7 +293,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 
 	/* check for timestamp cookie support */
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
-	tcp_parse_options(skb, &tcp_opt, &hash_location, 0, NULL);
+	tcp_parse_options(skb, &tcp_opt, 0, NULL);
 
 	if (!cookie_check_timestamp(&tcp_opt, sock_net(sk), &ecn_ok))
 		goto out;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index cca4550..cb45062 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -733,13 +733,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.procname	= "tcp_cookie_size",
-		.data		= &sysctl_tcp_cookie_size,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
 		.procname       = "tcp_thin_linear_timeouts",
 		.data           = &sysctl_tcp_thin_linear_timeouts,
 		.maxlen         = sizeof(int),
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 8d14573..17a6810 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -409,15 +409,6 @@ void tcp_init_sock(struct sock *sk)
 
 	icsk->icsk_sync_mss = tcp_sync_mss;
 
-	/* TCP Cookie Transactions */
-	if (sysctl_tcp_cookie_size > 0) {
-		/* Default, cookies without s_data_payload. */
-		tp->cookie_values =
-			kzalloc(sizeof(*tp->cookie_values),
-				sk->sk_allocation);
-		if (tp->cookie_values != NULL)
-			kref_init(&tp->cookie_values->kref);
-	}
 	/* Presumed zeroed, in order of appearance:
 	 *	cookie_in_always, cookie_out_never,
 	 *	s_data_constant, s_data_in, s_data_out
@@ -2397,92 +2388,6 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		release_sock(sk);
 		return err;
 	}
-	case TCP_COOKIE_TRANSACTIONS: {
-		struct tcp_cookie_transactions ctd;
-		struct tcp_cookie_values *cvp = NULL;
-
-		if (sizeof(ctd) > optlen)
-			return -EINVAL;
-		if (copy_from_user(&ctd, optval, sizeof(ctd)))
-			return -EFAULT;
-
-		if (ctd.tcpct_used > sizeof(ctd.tcpct_value) ||
-		    ctd.tcpct_s_data_desired > TCP_MSS_DESIRED)
-			return -EINVAL;
-
-		if (ctd.tcpct_cookie_desired == 0) {
-			/* default to global value */
-		} else if ((0x1 & ctd.tcpct_cookie_desired) ||
-			   ctd.tcpct_cookie_desired > TCP_COOKIE_MAX ||
-			   ctd.tcpct_cookie_desired < TCP_COOKIE_MIN) {
-			return -EINVAL;
-		}
-
-		if (TCP_COOKIE_OUT_NEVER & ctd.tcpct_flags) {
-			/* Supercedes all other values */
-			lock_sock(sk);
-			if (tp->cookie_values != NULL) {
-				kref_put(&tp->cookie_values->kref,
-					 tcp_cookie_values_release);
-				tp->cookie_values = NULL;
-			}
-			tp->rx_opt.cookie_in_always = 0; /* false */
-			tp->rx_opt.cookie_out_never = 1; /* true */
-			release_sock(sk);
-			return err;
-		}
-
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
-		}
-		lock_sock(sk);
-		tp->rx_opt.cookie_in_always =
-			(TCP_COOKIE_IN_ALWAYS & ctd.tcpct_flags);
-		tp->rx_opt.cookie_out_never = 0; /* false */
-
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
-		}
-
-		if (cvp != NULL) {
-			cvp->cookie_desired = ctd.tcpct_cookie_desired;
-
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
-
-			tp->cookie_values = cvp;
-		}
-		release_sock(sk);
-		return err;
-	}
 	default:
 		/* fallthru */
 		break;
@@ -2902,41 +2807,6 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 			return -EFAULT;
 		return 0;
 
-	case TCP_COOKIE_TRANSACTIONS: {
-		struct tcp_cookie_transactions ctd;
-		struct tcp_cookie_values *cvp = tp->cookie_values;
-
-		if (get_user(len, optlen))
-			return -EFAULT;
-		if (len < sizeof(ctd))
-			return -EINVAL;
-
-		memset(&ctd, 0, sizeof(ctd));
-		ctd.tcpct_flags = (tp->rx_opt.cookie_in_always ?
-				   TCP_COOKIE_IN_ALWAYS : 0)
-				| (tp->rx_opt.cookie_out_never ?
-				   TCP_COOKIE_OUT_NEVER : 0);
-
-		if (cvp != NULL) {
-			ctd.tcpct_flags |= (cvp->s_data_in ?
-					    TCP_S_DATA_IN : 0)
-					 | (cvp->s_data_out ?
-					    TCP_S_DATA_OUT : 0);
-
-			ctd.tcpct_cookie_desired = cvp->cookie_desired;
-			ctd.tcpct_s_data_desired = cvp->s_data_desired;
-
-			memcpy(&ctd.tcpct_value[0], &cvp->cookie_pair[0],
-			       cvp->cookie_pair_size);
-			ctd.tcpct_used = cvp->cookie_pair_size;
-		}
-
-		if (put_user(sizeof(ctd), optlen))
-			return -EFAULT;
-		if (copy_to_user(optval, &ctd, sizeof(ctd)))
-			return -EFAULT;
-		return 0;
-	}
 	case TCP_THIN_LINEAR_TIMEOUTS:
 		val = tp->thin_lto;
 		break;
@@ -3409,134 +3279,6 @@ EXPORT_SYMBOL(tcp_md5_hash_key);
 
 #endif
 
-/* Each Responder maintains up to two secret values concurrently for
- * efficient secret rollover.  Each secret value has 4 states:
- *
- * Generating.  (tcp_secret_generating != tcp_secret_primary)
- *    Generates new Responder-Cookies, but not yet used for primary
- *    verification.  This is a short-term state, typically lasting only
- *    one round trip time (RTT).
- *
- * Primary.  (tcp_secret_generating == tcp_secret_primary)
- *    Used both for generation and primary verification.
- *
- * Retiring.  (tcp_secret_retiring != tcp_secret_secondary)
- *    Used for verification, until the first failure that can be
- *    verified by the newer Generating secret.  At that time, this
- *    cookie's state is changed to Secondary, and the Generating
- *    cookie's state is changed to Primary.  This is a short-term state,
- *    typically lasting only one round trip time (RTT).
- *
- * Secondary.  (tcp_secret_retiring == tcp_secret_secondary)
- *    Used for secondary verification, after primary verification
- *    failures.  This state lasts no more than twice the Maximum Segment
- *    Lifetime (2MSL).  Then, the secret is discarded.
- */
-struct tcp_cookie_secret {
-	/* The secret is divided into two parts.  The digest part is the
-	 * equivalent of previously hashing a secret and saving the state,
-	 * and serves as an initialization vector (IV).  The message part
-	 * serves as the trailing secret.
-	 */
-	u32				secrets[COOKIE_WORKSPACE_WORDS];
-	unsigned long			expires;
-};
-
-#define TCP_SECRET_1MSL (HZ * TCP_PAWS_MSL)
-#define TCP_SECRET_2MSL (HZ * TCP_PAWS_MSL * 2)
-#define TCP_SECRET_LIFE (HZ * 600)
-
-static struct tcp_cookie_secret tcp_secret_one;
-static struct tcp_cookie_secret tcp_secret_two;
-
-/* Essentially a circular list, without dynamic allocation. */
-static struct tcp_cookie_secret *tcp_secret_generating;
-static struct tcp_cookie_secret *tcp_secret_primary;
-static struct tcp_cookie_secret *tcp_secret_retiring;
-static struct tcp_cookie_secret *tcp_secret_secondary;
-
-static DEFINE_SPINLOCK(tcp_secret_locker);
-
-/* Select a pseudo-random word in the cookie workspace.
- */
-static inline u32 tcp_cookie_work(const u32 *ws, const int n)
-{
-	return ws[COOKIE_DIGEST_WORDS + ((COOKIE_MESSAGE_WORDS-1) & ws[n])];
-}
-
-/* Fill bakery[COOKIE_WORKSPACE_WORDS] with generator, updating as needed.
- * Called in softirq context.
- * Returns: 0 for success.
- */
-int tcp_cookie_generator(u32 *bakery)
-{
-	unsigned long jiffy = jiffies;
-
-	if (unlikely(time_after_eq(jiffy, tcp_secret_generating->expires))) {
-		spin_lock_bh(&tcp_secret_locker);
-		if (!time_after_eq(jiffy, tcp_secret_generating->expires)) {
-			/* refreshed by another */
-			memcpy(bakery,
-			       &tcp_secret_generating->secrets[0],
-			       COOKIE_WORKSPACE_WORDS);
-		} else {
-			/* still needs refreshing */
-			get_random_bytes(bakery, COOKIE_WORKSPACE_WORDS);
-
-			/* The first time, paranoia assumes that the
-			 * randomization function isn't as strong.  But,
-			 * this secret initialization is delayed until
-			 * the last possible moment (packet arrival).
-			 * Although that time is observable, it is
-			 * unpredictably variable.  Mash in the most
-			 * volatile clock bits available, and expire the
-			 * secret extra quickly.
-			 */
-			if (unlikely(tcp_secret_primary->expires ==
-				     tcp_secret_secondary->expires)) {
-				struct timespec tv;
-
-				getnstimeofday(&tv);
-				bakery[COOKIE_DIGEST_WORDS+0] ^=
-					(u32)tv.tv_nsec;
-
-				tcp_secret_secondary->expires = jiffy
-					+ TCP_SECRET_1MSL
-					+ (0x0f & tcp_cookie_work(bakery, 0));
-			} else {
-				tcp_secret_secondary->expires = jiffy
-					+ TCP_SECRET_LIFE
-					+ (0xff & tcp_cookie_work(bakery, 1));
-				tcp_secret_primary->expires = jiffy
-					+ TCP_SECRET_2MSL
-					+ (0x1f & tcp_cookie_work(bakery, 2));
-			}
-			memcpy(&tcp_secret_secondary->secrets[0],
-			       bakery, COOKIE_WORKSPACE_WORDS);
-
-			rcu_assign_pointer(tcp_secret_generating,
-					   tcp_secret_secondary);
-			rcu_assign_pointer(tcp_secret_retiring,
-					   tcp_secret_primary);
-			/*
-			 * Neither call_rcu() nor synchronize_rcu() needed.
-			 * Retiring data is not freed.  It is replaced after
-			 * further (locked) pointer updates, and a quiet time
-			 * (minimum 1MSL, maximum LIFE - 2MSL).
-			 */
-		}
-		spin_unlock_bh(&tcp_secret_locker);
-	} else {
-		rcu_read_lock_bh();
-		memcpy(bakery,
-		       &rcu_dereference(tcp_secret_generating)->secrets[0],
-		       COOKIE_WORKSPACE_WORDS);
-		rcu_read_unlock_bh();
-	}
-	return 0;
-}
-EXPORT_SYMBOL(tcp_cookie_generator);
-
 void tcp_done(struct sock *sk)
 {
 	struct request_sock *req = tcp_sk(sk)->fastopen_rsk;
@@ -3591,7 +3333,6 @@ void __init tcp_init(void)
 	unsigned long limit;
 	int max_rshare, max_wshare, cnt;
 	unsigned int i;
-	unsigned long jiffy = jiffies;
 
 	BUILD_BUG_ON(sizeof(struct tcp_skb_cb) > sizeof(skb->cb));
 
@@ -3667,13 +3408,5 @@ void __init tcp_init(void)
 
 	tcp_register_congestion_control(&tcp_reno);
 
-	memset(&tcp_secret_one.secrets[0], 0, sizeof(tcp_secret_one.secrets));
-	memset(&tcp_secret_two.secrets[0], 0, sizeof(tcp_secret_two.secrets));
-	tcp_secret_one.expires = jiffy; /* past due */
-	tcp_secret_two.expires = jiffy; /* past due */
-	tcp_secret_generating = &tcp_secret_one;
-	tcp_secret_primary = &tcp_secret_one;
-	tcp_secret_retiring = &tcp_secret_two;
-	tcp_secret_secondary = &tcp_secret_two;
 	tcp_tasklet_init();
 }
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 836d74d..19f0149 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3760,8 +3760,8 @@ old_ack:
  * But, this can also be called on packets in the established flow when
  * the fast version below fails.
  */
-void tcp_parse_options(const struct sk_buff *skb, struct tcp_options_received *opt_rx,
-		       const u8 **hvpp, int estab,
+void tcp_parse_options(const struct sk_buff *skb,
+		       struct tcp_options_received *opt_rx, int estab,
 		       struct tcp_fastopen_cookie *foc)
 {
 	const unsigned char *ptr;
@@ -3845,31 +3845,6 @@ void tcp_parse_options(const struct sk_buff *skb, struct tcp_options_received *o
 				 */
 				break;
 #endif
-			case TCPOPT_COOKIE:
-				/* This option is variable length.
-				 */
-				switch (opsize) {
-				case TCPOLEN_COOKIE_BASE:
-					/* not yet implemented */
-					break;
-				case TCPOLEN_COOKIE_PAIR:
-					/* not yet implemented */
-					break;
-				case TCPOLEN_COOKIE_MIN+0:
-				case TCPOLEN_COOKIE_MIN+2:
-				case TCPOLEN_COOKIE_MIN+4:
-				case TCPOLEN_COOKIE_MIN+6:
-				case TCPOLEN_COOKIE_MAX:
-					/* 16-bit multiple */
-					opt_rx->cookie_plus = opsize;
-					*hvpp = ptr;
-					break;
-				default:
-					/* ignore option */
-					break;
-				}
-				break;
-
 			case TCPOPT_EXP:
 				/* Fast Open option shares code 254 using a
 				 * 16 bits magic number. It's valid only in
@@ -3915,8 +3890,7 @@ static bool tcp_parse_aligned_timestamp(struct tcp_sock *tp, const struct tcphdr
  * If it is wrong it falls back on tcp_parse_options().
  */
 static bool tcp_fast_parse_options(const struct sk_buff *skb,
-				   const struct tcphdr *th,
-				   struct tcp_sock *tp, const u8 **hvpp)
+				   const struct tcphdr *th, struct tcp_sock *tp)
 {
 	/* In the spirit of fast parsing, compare doff directly to constant
 	 * values.  Because equality is used, short doff can be ignored here.
@@ -3930,7 +3904,7 @@ static bool tcp_fast_parse_options(const struct sk_buff *skb,
 			return true;
 	}
 
-	tcp_parse_options(skb, &tp->rx_opt, hvpp, 1, NULL);
+	tcp_parse_options(skb, &tp->rx_opt, 1, NULL);
 	if (tp->rx_opt.saw_tstamp)
 		tp->rx_opt.rcv_tsecr -= tp->tsoffset;
 
@@ -5311,12 +5285,10 @@ out:
 static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
 				  const struct tcphdr *th, int syn_inerr)
 {
-	const u8 *hash_location;
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	/* RFC1323: H1. Apply PAWS check first. */
-	if (tcp_fast_parse_options(skb, th, tp, &hash_location) &&
-	    tp->rx_opt.saw_tstamp &&
+	if (tcp_fast_parse_options(skb, th, tp) && tp->rx_opt.saw_tstamp &&
 	    tcp_paws_discard(sk, skb)) {
 		if (!th->rst) {
 			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSESTABREJECTED);
@@ -5670,12 +5642,11 @@ static bool tcp_rcv_fastopen_synack(struct sock *sk, struct sk_buff *synack,
 
 	if (mss == tp->rx_opt.user_mss) {
 		struct tcp_options_received opt;
-		const u8 *hash_location;
 
 		/* Get original SYNACK MSS value if user MSS sets mss_clamp */
 		tcp_clear_options(&opt);
 		opt.user_mss = opt.mss_clamp = 0;
-		tcp_parse_options(synack, &opt, &hash_location, 0, NULL);
+		tcp_parse_options(synack, &opt, 0, NULL);
 		mss = opt.mss_clamp;
 	}
 
@@ -5706,14 +5677,12 @@ static bool tcp_rcv_fastopen_synack(struct sock *sk, struct sk_buff *synack,
 static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 					 const struct tcphdr *th, unsigned int len)
 {
-	const u8 *hash_location;
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct tcp_cookie_values *cvp = tp->cookie_values;
 	struct tcp_fastopen_cookie foc = { .len = -1 };
 	int saved_clamp = tp->rx_opt.mss_clamp;
 
-	tcp_parse_options(skb, &tp->rx_opt, &hash_location, 0, &foc);
+	tcp_parse_options(skb, &tp->rx_opt, 0, &foc);
 	if (tp->rx_opt.saw_tstamp)
 		tp->rx_opt.rcv_tsecr -= tp->tsoffset;
 
@@ -5810,30 +5779,6 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 		 * is initialized. */
 		tp->copied_seq = tp->rcv_nxt;
 
-		if (cvp != NULL &&
-		    cvp->cookie_pair_size > 0 &&
-		    tp->rx_opt.cookie_plus > 0) {
-			int cookie_size = tp->rx_opt.cookie_plus
-					- TCPOLEN_COOKIE_BASE;
-			int cookie_pair_size = cookie_size
-					     + cvp->cookie_desired;
-
-			/* A cookie extension option was sent and returned.
-			 * Note that each incoming SYNACK replaces the
-			 * Responder cookie.  The initial exchange is most
-			 * fragile, as protection against spoofing relies
-			 * entirely upon the sequence and timestamp (above).
-			 * This replacement strategy allows the correct pair to
-			 * pass through, while any others will be filtered via
-			 * Responder verification later.
-			 */
-			if (sizeof(cvp->cookie_pair) >= cookie_pair_size) {
-				memcpy(&cvp->cookie_pair[cvp->cookie_desired],
-				       hash_location, cookie_size);
-				cvp->cookie_pair_size = cookie_pair_size;
-			}
-		}
-
 		smp_mb();
 
 		tcp_finish_connect(sk, skb);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index b7ab868..b27c758 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -838,7 +838,6 @@ static void tcp_v4_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
  */
 static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 			      struct request_sock *req,
-			      struct request_values *rvp,
 			      u16 queue_mapping,
 			      bool nocache)
 {
@@ -851,7 +850,7 @@ static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 	if (!dst && (dst = inet_csk_route_req(sk, &fl4, req)) == NULL)
 		return -1;
 
-	skb = tcp_make_synack(sk, dst, req, rvp, NULL);
+	skb = tcp_make_synack(sk, dst, req, NULL);
 
 	if (skb) {
 		__tcp_v4_send_check(skb, ireq->loc_addr, ireq->rmt_addr);
@@ -868,10 +867,9 @@ static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 	return err;
 }
 
-static int tcp_v4_rtx_synack(struct sock *sk, struct request_sock *req,
-			     struct request_values *rvp)
+static int tcp_v4_rtx_synack(struct sock *sk, struct request_sock *req)
 {
-	int res = tcp_v4_send_synack(sk, NULL, req, rvp, 0, false);
+	int res = tcp_v4_send_synack(sk, NULL, req, 0, false);
 
 	if (!res)
 		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
@@ -1371,8 +1369,7 @@ static bool tcp_fastopen_check(struct sock *sk, struct sk_buff *skb,
 static int tcp_v4_conn_req_fastopen(struct sock *sk,
 				    struct sk_buff *skb,
 				    struct sk_buff *skb_synack,
-				    struct request_sock *req,
-				    struct request_values *rvp)
+				    struct request_sock *req)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct request_sock_queue *queue = &inet_csk(sk)->icsk_accept_queue;
@@ -1467,9 +1464,7 @@ static int tcp_v4_conn_req_fastopen(struct sock *sk,
 
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 {
-	struct tcp_extend_values tmp_ext;
 	struct tcp_options_received tmp_opt;
-	const u8 *hash_location;
 	struct request_sock *req;
 	struct inet_request_sock *ireq;
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -1519,42 +1514,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = TCP_MSS_DEFAULT;
 	tmp_opt.user_mss  = tp->rx_opt.user_mss;
-	tcp_parse_options(skb, &tmp_opt, &hash_location, 0,
-	    want_cookie ? NULL : &foc);
-
-	if (tmp_opt.cookie_plus > 0 &&
-	    tmp_opt.saw_tstamp &&
-	    !tp->rx_opt.cookie_out_never &&
-	    (sysctl_tcp_cookie_size > 0 ||
-	     (tp->cookie_values != NULL &&
-	      tp->cookie_values->cookie_desired > 0))) {
-		u8 *c;
-		u32 *mess = &tmp_ext.cookie_bakery[COOKIE_DIGEST_WORDS];
-		int l = tmp_opt.cookie_plus - TCPOLEN_COOKIE_BASE;
-
-		if (tcp_cookie_generator(&tmp_ext.cookie_bakery[0]) != 0)
-			goto drop_and_release;
-
-		/* Secret recipe starts with IP addresses */
-		*mess++ ^= (__force u32)daddr;
-		*mess++ ^= (__force u32)saddr;
-
-		/* plus variable length Initiator Cookie */
-		c = (u8 *)mess;
-		while (l-- > 0)
-			*c++ ^= *hash_location++;
-
-		want_cookie = false;	/* not our kind of cookie */
-		tmp_ext.cookie_out_never = 0; /* false */
-		tmp_ext.cookie_plus = tmp_opt.cookie_plus;
-	} else if (!tp->rx_opt.cookie_in_always) {
-		/* redundant indications, but ensure initialization. */
-		tmp_ext.cookie_out_never = 1; /* true */
-		tmp_ext.cookie_plus = 0;
-	} else {
-		goto drop_and_release;
-	}
-	tmp_ext.cookie_in_always = tp->rx_opt.cookie_in_always;
+	tcp_parse_options(skb, &tmp_opt, 0, want_cookie ? NULL : &foc);
 
 	if (want_cookie && !tmp_opt.saw_tstamp)
 		tcp_clear_options(&tmp_opt);
@@ -1636,7 +1596,6 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	 * of tcp_v4_send_synack()->tcp_select_initial_window().
 	 */
 	skb_synack = tcp_make_synack(sk, dst, req,
-	    (struct request_values *)&tmp_ext,
 	    fastopen_cookie_present(&valid_foc) ? &valid_foc : NULL);
 
 	if (skb_synack) {
@@ -1660,8 +1619,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		if (fastopen_cookie_present(&foc) && foc.len != 0)
 			NET_INC_STATS_BH(sock_net(sk),
 			    LINUX_MIB_TCPFASTOPENPASSIVEFAIL);
-	} else if (tcp_v4_conn_req_fastopen(sk, skb, skb_synack, req,
-	    (struct request_values *)&tmp_ext))
+	} else if (tcp_v4_conn_req_fastopen(sk, skb, skb_synack, req))
 		goto drop_and_free;
 
 	return 0;
@@ -2241,12 +2199,6 @@ void tcp_v4_destroy_sock(struct sock *sk)
 	if (inet_csk(sk)->icsk_bind_hash)
 		inet_put_port(sk);
 
-	/* TCP Cookie Transactions */
-	if (tp->cookie_values != NULL) {
-		kref_put(&tp->cookie_values->kref,
-			 tcp_cookie_values_release);
-		tp->cookie_values = NULL;
-	}
 	BUG_ON(tp->fastopen_rsk != NULL);
 
 	/* If socket is aborted during connect operation */
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 4bdb09f..8f0234f 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -93,13 +93,12 @@ tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
 			   const struct tcphdr *th)
 {
 	struct tcp_options_received tmp_opt;
-	const u8 *hash_location;
 	struct tcp_timewait_sock *tcptw = tcp_twsk((struct sock *)tw);
 	bool paws_reject = false;
 
 	tmp_opt.saw_tstamp = 0;
 	if (th->doff > (sizeof(*th) >> 2) && tcptw->tw_ts_recent_stamp) {
-		tcp_parse_options(skb, &tmp_opt, &hash_location, 0, NULL);
+		tcp_parse_options(skb, &tmp_opt, 0, NULL);
 
 		if (tmp_opt.saw_tstamp) {
 			tmp_opt.rcv_tsecr	-= tcptw->tw_ts_offset;
@@ -388,32 +387,6 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		struct tcp_request_sock *treq = tcp_rsk(req);
 		struct inet_connection_sock *newicsk = inet_csk(newsk);
 		struct tcp_sock *newtp = tcp_sk(newsk);
-		struct tcp_sock *oldtp = tcp_sk(sk);
-		struct tcp_cookie_values *oldcvp = oldtp->cookie_values;
-
-		/* TCP Cookie Transactions require space for the cookie pair,
-		 * as it differs for each connection.  There is no need to
-		 * copy any s_data_payload stored at the original socket.
-		 * Failure will prevent resuming the connection.
-		 *
-		 * Presumed copied, in order of appearance:
-		 *	cookie_in_always, cookie_out_never
-		 */
-		if (oldcvp != NULL) {
-			struct tcp_cookie_values *newcvp =
-				kzalloc(sizeof(*newtp->cookie_values),
-					GFP_ATOMIC);
-
-			if (newcvp != NULL) {
-				kref_init(&newcvp->kref);
-				newcvp->cookie_desired =
-						oldcvp->cookie_desired;
-				newtp->cookie_values = newcvp;
-			} else {
-				/* Not Yet Implemented */
-				newtp->cookie_values = NULL;
-			}
-		}
 
 		/* Now setup tcp_sock */
 		newtp->pred_flags = 0;
@@ -422,8 +395,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		newtp->rcv_nxt = treq->rcv_isn + 1;
 
 		newtp->snd_sml = newtp->snd_una =
-		newtp->snd_nxt = newtp->snd_up =
-			treq->snt_isn + 1 + tcp_s_data_size(oldtp);
+		newtp->snd_nxt = newtp->snd_up = treq->snt_isn + 1;
 
 		tcp_prequeue_init(newtp);
 		INIT_LIST_HEAD(&newtp->tsq_node);
@@ -460,8 +432,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		tcp_set_ca_state(newsk, TCP_CA_Open);
 		tcp_init_xmit_timers(newsk);
 		skb_queue_head_init(&newtp->out_of_order_queue);
-		newtp->write_seq = newtp->pushed_seq =
-			treq->snt_isn + 1 + tcp_s_data_size(oldtp);
+		newtp->write_seq = newtp->pushed_seq = treq->snt_isn + 1;
 
 		newtp->rx_opt.saw_tstamp = 0;
 
@@ -538,7 +509,6 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 			   bool fastopen)
 {
 	struct tcp_options_received tmp_opt;
-	const u8 *hash_location;
 	struct sock *child;
 	const struct tcphdr *th = tcp_hdr(skb);
 	__be32 flg = tcp_flag_word(th) & (TCP_FLAG_RST|TCP_FLAG_SYN|TCP_FLAG_ACK);
@@ -548,7 +518,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 
 	tmp_opt.saw_tstamp = 0;
 	if (th->doff > (sizeof(struct tcphdr)>>2)) {
-		tcp_parse_options(skb, &tmp_opt, &hash_location, 0, NULL);
+		tcp_parse_options(skb, &tmp_opt, 0, NULL);
 
 		if (tmp_opt.saw_tstamp) {
 			tmp_opt.ts_recent = req->ts_recent;
@@ -648,7 +618,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	 */
 	if ((flg & TCP_FLAG_ACK) && !fastopen &&
 	    (TCP_SKB_CB(skb)->ack_seq !=
-	     tcp_rsk(req)->snt_isn + 1 + tcp_s_data_size(tcp_sk(sk))))
+	     tcp_rsk(req)->snt_isn + 1))
 		return sk;
 
 	/* Also, it would be not so bad idea to check rcv_tsecr, which
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8e7742f..ac5871e 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -65,9 +65,6 @@ int sysctl_tcp_base_mss __read_mostly = TCP_BASE_MSS;
 /* By default, RFC2861 behavior.  */
 int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
 
-int sysctl_tcp_cookie_size __read_mostly = 0; /* TCP_COOKIE_MAX */
-EXPORT_SYMBOL_GPL(sysctl_tcp_cookie_size);
-
 static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 			   int push_one, gfp_t gfp);
 
@@ -386,7 +383,6 @@ static inline bool tcp_urg_mode(const struct tcp_sock *tp)
 #define OPTION_TS		(1 << 1)
 #define OPTION_MD5		(1 << 2)
 #define OPTION_WSCALE		(1 << 3)
-#define OPTION_COOKIE_EXTENSION	(1 << 4)
 #define OPTION_FAST_OPEN_COOKIE	(1 << 8)
 
 struct tcp_out_options {
@@ -400,36 +396,6 @@ struct tcp_out_options {
 	struct tcp_fastopen_cookie *fastopen_cookie;	/* Fast open cookie */
 };
 
-/* The sysctl int routines are generic, so check consistency here.
- */
-static u8 tcp_cookie_size_check(u8 desired)
-{
-	int cookie_size;
-
-	if (desired > 0)
-		/* previously specified */
-		return desired;
-
-	cookie_size = ACCESS_ONCE(sysctl_tcp_cookie_size);
-	if (cookie_size <= 0)
-		/* no default specified */
-		return 0;
-
-	if (cookie_size <= TCP_COOKIE_MIN)
-		/* value too small, specify minimum */
-		return TCP_COOKIE_MIN;
-
-	if (cookie_size >= TCP_COOKIE_MAX)
-		/* value too large, specify maximum */
-		return TCP_COOKIE_MAX;
-
-	if (cookie_size & 1)
-		/* 8-bit multiple, illegal, fix it */
-		cookie_size++;
-
-	return (u8)cookie_size;
-}
-
 /* Write previously computed TCP options to the packet.
  *
  * Beware: Something in the Internet is very sensitive to the ordering of
@@ -448,27 +414,9 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 {
 	u16 options = opts->options;	/* mungable copy */
 
-	/* Having both authentication and cookies for security is redundant,
-	 * and there's certainly not enough room.  Instead, the cookie-less
-	 * extension variant is proposed.
-	 *
-	 * Consider the pessimal case with authentication.  The options
-	 * could look like:
-	 *   COOKIE|MD5(20) + MSS(4) + SACK|TS(12) + WSCALE(4) == 40
-	 */
 	if (unlikely(OPTION_MD5 & options)) {
-		if (unlikely(OPTION_COOKIE_EXTENSION & options)) {
-			*ptr++ = htonl((TCPOPT_COOKIE << 24) |
-				       (TCPOLEN_COOKIE_BASE << 16) |
-				       (TCPOPT_MD5SIG << 8) |
-				       TCPOLEN_MD5SIG);
-		} else {
-			*ptr++ = htonl((TCPOPT_NOP << 24) |
-				       (TCPOPT_NOP << 16) |
-				       (TCPOPT_MD5SIG << 8) |
-				       TCPOLEN_MD5SIG);
-		}
-		options &= ~OPTION_COOKIE_EXTENSION;
+		*ptr++ = htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |
+			       (TCPOPT_MD5SIG << 8) | TCPOLEN_MD5SIG);
 		/* overload cookie hash location */
 		opts->hash_location = (__u8 *)ptr;
 		ptr += 4;
@@ -497,44 +445,6 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 		*ptr++ = htonl(opts->tsecr);
 	}
 
-	/* Specification requires after timestamp, so do it now.
-	 *
-	 * Consider the pessimal case without authentication.  The options
-	 * could look like:
-	 *   MSS(4) + SACK|TS(12) + COOKIE(20) + WSCALE(4) == 40
-	 */
-	if (unlikely(OPTION_COOKIE_EXTENSION & options)) {
-		__u8 *cookie_copy = opts->hash_location;
-		u8 cookie_size = opts->hash_size;
-
-		/* 8-bit multiple handled in tcp_cookie_size_check() above,
-		 * and elsewhere.
-		 */
-		if (0x2 & cookie_size) {
-			__u8 *p = (__u8 *)ptr;
-
-			/* 16-bit multiple */
-			*p++ = TCPOPT_COOKIE;
-			*p++ = TCPOLEN_COOKIE_BASE + cookie_size;
-			*p++ = *cookie_copy++;
-			*p++ = *cookie_copy++;
-			ptr++;
-			cookie_size -= 2;
-		} else {
-			/* 32-bit multiple */
-			*ptr++ = htonl(((TCPOPT_NOP << 24) |
-					(TCPOPT_NOP << 16) |
-					(TCPOPT_COOKIE << 8) |
-					TCPOLEN_COOKIE_BASE) +
-				       cookie_size);
-		}
-
-		if (cookie_size > 0) {
-			memcpy(ptr, cookie_copy, cookie_size);
-			ptr += (cookie_size / 4);
-		}
-	}
-
 	if (unlikely(OPTION_SACK_ADVERTISE & options)) {
 		*ptr++ = htonl((TCPOPT_NOP << 24) |
 			       (TCPOPT_NOP << 16) |
@@ -593,11 +503,7 @@ static unsigned int tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 				struct tcp_md5sig_key **md5)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct tcp_cookie_values *cvp = tp->cookie_values;
 	unsigned int remaining = MAX_TCP_OPTION_SPACE;
-	u8 cookie_size = (!tp->rx_opt.cookie_out_never && cvp != NULL) ?
-			 tcp_cookie_size_check(cvp->cookie_desired) :
-			 0;
 	struct tcp_fastopen_request *fastopen = tp->fastopen_req;
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -649,52 +555,7 @@ static unsigned int tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 			tp->syn_fastopen = 1;
 		}
 	}
-	/* Note that timestamps are required by the specification.
-	 *
-	 * Odd numbers of bytes are prohibited by the specification, ensuring
-	 * that the cookie is 16-bit aligned, and the resulting cookie pair is
-	 * 32-bit aligned.
-	 */
-	if (*md5 == NULL &&
-	    (OPTION_TS & opts->options) &&
-	    cookie_size > 0) {
-		int need = TCPOLEN_COOKIE_BASE + cookie_size;
-
-		if (0x2 & need) {
-			/* 32-bit multiple */
-			need += 2; /* NOPs */
-
-			if (need > remaining) {
-				/* try shrinking cookie to fit */
-				cookie_size -= 2;
-				need -= 4;
-			}
-		}
-		while (need > remaining && TCP_COOKIE_MIN <= cookie_size) {
-			cookie_size -= 4;
-			need -= 4;
-		}
-		if (TCP_COOKIE_MIN <= cookie_size) {
-			opts->options |= OPTION_COOKIE_EXTENSION;
-			opts->hash_location = (__u8 *)&cvp->cookie_pair[0];
-			opts->hash_size = cookie_size;
-
-			/* Remember for future incarnations. */
-			cvp->cookie_desired = cookie_size;
-
-			if (cvp->cookie_desired != cvp->cookie_pair_size) {
-				/* Currently use random bytes as a nonce,
-				 * assuming these are completely unpredictable
-				 * by hostile users of the same system.
-				 */
-				get_random_bytes(&cvp->cookie_pair[0],
-						 cookie_size);
-				cvp->cookie_pair_size = cookie_size;
-			}
 
-			remaining -= need;
-		}
-	}
 	return MAX_TCP_OPTION_SPACE - remaining;
 }
 
@@ -704,14 +565,10 @@ static unsigned int tcp_synack_options(struct sock *sk,
 				   unsigned int mss, struct sk_buff *skb,
 				   struct tcp_out_options *opts,
 				   struct tcp_md5sig_key **md5,
-				   struct tcp_extend_values *xvp,
 				   struct tcp_fastopen_cookie *foc)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
 	unsigned int remaining = MAX_TCP_OPTION_SPACE;
-	u8 cookie_plus = (xvp != NULL && !xvp->cookie_out_never) ?
-			 xvp->cookie_plus :
-			 0;
 
 #ifdef CONFIG_TCP_MD5SIG
 	*md5 = tcp_rsk(req)->af_specific->md5_lookup(sk, req);
@@ -759,28 +616,7 @@ static unsigned int tcp_synack_options(struct sock *sk,
 			remaining -= need;
 		}
 	}
-	/* Similar rationale to tcp_syn_options() applies here, too.
-	 * If the <SYN> options fit, the same options should fit now!
-	 */
-	if (*md5 == NULL &&
-	    ireq->tstamp_ok &&
-	    cookie_plus > TCPOLEN_COOKIE_BASE) {
-		int need = cookie_plus; /* has TCPOLEN_COOKIE_BASE */
-
-		if (0x2 & need) {
-			/* 32-bit multiple */
-			need += 2; /* NOPs */
-		}
-		if (need <= remaining) {
-			opts->options |= OPTION_COOKIE_EXTENSION;
-			opts->hash_size = cookie_plus - TCPOLEN_COOKIE_BASE;
-			remaining -= need;
-		} else {
-			/* There's no error return, so flag it. */
-			xvp->cookie_out_never = 1; /* true */
-			opts->hash_size = 0;
-		}
-	}
+
 	return MAX_TCP_OPTION_SPACE - remaining;
 }
 
@@ -2802,32 +2638,24 @@ int tcp_send_synack(struct sock *sk)
  * sk: listener socket
  * dst: dst entry attached to the SYNACK
  * req: request_sock pointer
- * rvp: request_values pointer
  *
  * Allocate one skb and build a SYNACK packet.
  * @dst is consumed : Caller should not use it again.
  */
 struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 				struct request_sock *req,
-				struct request_values *rvp,
 				struct tcp_fastopen_cookie *foc)
 {
 	struct tcp_out_options opts;
-	struct tcp_extend_values *xvp = tcp_xv(rvp);
 	struct inet_request_sock *ireq = inet_rsk(req);
 	struct tcp_sock *tp = tcp_sk(sk);
-	const struct tcp_cookie_values *cvp = tp->cookie_values;
 	struct tcphdr *th;
 	struct sk_buff *skb;
 	struct tcp_md5sig_key *md5;
 	int tcp_header_size;
 	int mss;
-	int s_data_desired = 0;
 
-	if (cvp != NULL && cvp->s_data_constant && cvp->s_data_desired)
-		s_data_desired = cvp->s_data_desired;
-	skb = alloc_skb(MAX_TCP_HEADER + 15 + s_data_desired,
-			sk_gfp_atomic(sk, GFP_ATOMIC));
+	skb = alloc_skb(MAX_TCP_HEADER + 15, sk_gfp_atomic(sk, GFP_ATOMIC));
 	if (unlikely(!skb)) {
 		dst_release(dst);
 		return NULL;
@@ -2869,9 +2697,8 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	else
 #endif
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
-	tcp_header_size = tcp_synack_options(sk, req, mss,
-					     skb, &opts, &md5, xvp, foc)
-			+ sizeof(*th);
+	tcp_header_size = tcp_synack_options(sk, req, mss, skb, &opts, &md5,
+					     foc) + sizeof(*th);
 
 	skb_push(skb, tcp_header_size);
 	skb_reset_transport_header(skb);
@@ -2889,40 +2716,6 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	tcp_init_nondata_skb(skb, tcp_rsk(req)->snt_isn,
 			     TCPHDR_SYN | TCPHDR_ACK);
 
-	if (OPTION_COOKIE_EXTENSION & opts.options) {
-		if (s_data_desired) {
-			u8 *buf = skb_put(skb, s_data_desired);
-
-			/* copy data directly from the listening socket. */
-			memcpy(buf, cvp->s_data_payload, s_data_desired);
-			TCP_SKB_CB(skb)->end_seq += s_data_desired;
-		}
-
-		if (opts.hash_size > 0) {
-			__u32 workspace[SHA_WORKSPACE_WORDS];
-			u32 *mess = &xvp->cookie_bakery[COOKIE_DIGEST_WORDS];
-			u32 *tail = &mess[COOKIE_MESSAGE_WORDS-1];
-
-			/* Secret recipe depends on the Timestamp, (future)
-			 * Sequence and Acknowledgment Numbers, Initiator
-			 * Cookie, and others handled by IP variant caller.
-			 */
-			*tail-- ^= opts.tsval;
-			*tail-- ^= tcp_rsk(req)->rcv_isn + 1;
-			*tail-- ^= TCP_SKB_CB(skb)->seq + 1;
-
-			/* recommended */
-			*tail-- ^= (((__force u32)th->dest << 16) | (__force u32)th->source);
-			*tail-- ^= (u32)(unsigned long)cvp; /* per sockopt */
-
-			sha_transform((__u32 *)&xvp->cookie_bakery[0],
-				      (char *)mess,
-				      &workspace[0]);
-			opts.hash_location =
-				(__u8 *)&xvp->cookie_bakery[0];
-		}
-	}
-
 	th->seq = htonl(TCP_SKB_CB(skb)->seq);
 	/* XXX data is queued and acked as is. No buffer/window check */
 	th->ack_seq = htonl(tcp_rsk(req)->rcv_nxt);
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 8a0848b..d5dda20 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -149,7 +149,6 @@ static inline int cookie_check(const struct sk_buff *skb, __u32 cookie)
 struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_options_received tcp_opt;
-	const u8 *hash_location;
 	struct inet_request_sock *ireq;
 	struct inet6_request_sock *ireq6;
 	struct tcp_request_sock *treq;
@@ -177,7 +176,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 
 	/* check for timestamp cookie support */
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
-	tcp_parse_options(skb, &tcp_opt, &hash_location, 0, NULL);
+	tcp_parse_options(skb, &tcp_opt, 0, NULL);
 
 	if (!cookie_check_timestamp(&tcp_opt, sock_net(sk), &ecn_ok))
 		goto out;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 9b64600..0a97add 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -454,7 +454,6 @@ out:
 static int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
 			      struct flowi6 *fl6,
 			      struct request_sock *req,
-			      struct request_values *rvp,
 			      u16 queue_mapping)
 {
 	struct inet6_request_sock *treq = inet6_rsk(req);
@@ -466,7 +465,7 @@ static int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
 	if (!dst && (dst = inet6_csk_route_req(sk, fl6, req)) == NULL)
 		goto done;
 
-	skb = tcp_make_synack(sk, dst, req, rvp, NULL);
+	skb = tcp_make_synack(sk, dst, req, NULL);
 
 	if (skb) {
 		__tcp_v6_send_check(skb, &treq->loc_addr, &treq->rmt_addr);
@@ -481,13 +480,12 @@ done:
 	return err;
 }
 
-static int tcp_v6_rtx_synack(struct sock *sk, struct request_sock *req,
-			     struct request_values *rvp)
+static int tcp_v6_rtx_synack(struct sock *sk, struct request_sock *req)
 {
 	struct flowi6 fl6;
 	int res;
 
-	res = tcp_v6_send_synack(sk, NULL, &fl6, req, rvp, 0);
+	res = tcp_v6_send_synack(sk, NULL, &fl6, req, 0);
 	if (!res)
 		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
 	return res;
@@ -940,9 +938,7 @@ static struct sock *tcp_v6_hnd_req(struct sock *sk,struct sk_buff *skb)
  */
 static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 {
-	struct tcp_extend_values tmp_ext;
 	struct tcp_options_received tmp_opt;
-	const u8 *hash_location;
 	struct request_sock *req;
 	struct inet6_request_sock *treq;
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -980,50 +976,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = IPV6_MIN_MTU - sizeof(struct tcphdr) - sizeof(struct ipv6hdr);
 	tmp_opt.user_mss = tp->rx_opt.user_mss;
-	tcp_parse_options(skb, &tmp_opt, &hash_location, 0, NULL);
-
-	if (tmp_opt.cookie_plus > 0 &&
-	    tmp_opt.saw_tstamp &&
-	    !tp->rx_opt.cookie_out_never &&
-	    (sysctl_tcp_cookie_size > 0 ||
-	     (tp->cookie_values != NULL &&
-	      tp->cookie_values->cookie_desired > 0))) {
-		u8 *c;
-		u32 *d;
-		u32 *mess = &tmp_ext.cookie_bakery[COOKIE_DIGEST_WORDS];
-		int l = tmp_opt.cookie_plus - TCPOLEN_COOKIE_BASE;
-
-		if (tcp_cookie_generator(&tmp_ext.cookie_bakery[0]) != 0)
-			goto drop_and_free;
-
-		/* Secret recipe starts with IP addresses */
-		d = (__force u32 *)&ipv6_hdr(skb)->daddr.s6_addr32[0];
-		*mess++ ^= *d++;
-		*mess++ ^= *d++;
-		*mess++ ^= *d++;
-		*mess++ ^= *d++;
-		d = (__force u32 *)&ipv6_hdr(skb)->saddr.s6_addr32[0];
-		*mess++ ^= *d++;
-		*mess++ ^= *d++;
-		*mess++ ^= *d++;
-		*mess++ ^= *d++;
-
-		/* plus variable length Initiator Cookie */
-		c = (u8 *)mess;
-		while (l-- > 0)
-			*c++ ^= *hash_location++;
-
-		want_cookie = false;	/* not our kind of cookie */
-		tmp_ext.cookie_out_never = 0; /* false */
-		tmp_ext.cookie_plus = tmp_opt.cookie_plus;
-	} else if (!tp->rx_opt.cookie_in_always) {
-		/* redundant indications, but ensure initialization. */
-		tmp_ext.cookie_out_never = 1; /* true */
-		tmp_ext.cookie_plus = 0;
-	} else {
-		goto drop_and_free;
-	}
-	tmp_ext.cookie_in_always = tp->rx_opt.cookie_in_always;
+	tcp_parse_options(skb, &tmp_opt, 0, NULL);
 
 	if (want_cookie && !tmp_opt.saw_tstamp)
 		tcp_clear_options(&tmp_opt);
@@ -1101,7 +1054,6 @@ have_isn:
 		goto drop_and_release;
 
 	if (tcp_v6_send_synack(sk, dst, &fl6, req,
-			       (struct request_values *)&tmp_ext,
 			       skb_get_queue_mapping(skb)) ||
 	    want_cookie)
 		goto drop_and_free;
-- 
1.8.1.227.g44fe835
