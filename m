From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH V2 net-next 1/3] tcp: introduce TCP experimental option for SMC
Date: Tue, 14 Jul 2015 14:42:33 +0200
Message-ID: <1436877755-23431-2-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1436877755-23431-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: utz.bacher@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, ursula.braun@de.ibm.com,
	ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:38226 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520AbbGNMmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 08:42:45 -0400
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Tue, 14 Jul 2015 13:42:43 +0100
In-Reply-To: <1436877755-23431-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

The SMC-R protocol defines dynamic discovery of peers. This is done by
implementing experimental TCP options as defined in RFC6994. The TCP code
needs to be extended to support RFC6994.

Setting the TCP experimental option for SMC-R [2] will be triggered from
kernel exploiters like the new SMC-R socket family by setting a new
flag "syn_smc" on struct tcp_sock of the connecting and the listening
socket. If the client peer is SMC-R capable, flag syn_smc is kept on the
connecting socket after the 3-way TCP handshake, otherwise it is reset.
If the server peer is SMC-R capable, the new connected TCP socket has
the new flag set, otherwise not.

Code snippet client:
  tcp_sk(sock->sk)->syn_smc = 1;
  rc = kernel_connect(sock, addr, alen, flags);
  if (tcp_sk(sock->sk)->syn_smc) {
          /* switch to smc for this connection */

Code snippet server:
  tcp_sk(sock->sk)->syn_smc = 1;
  rc = kernel_listen(sock, backlog);
  rc = kernel_accept(sock, &newsock, 0);
  if (tcp_sk(newsock->sk)->syn_smc) {
          /* switch to smc for this connection */

References:
[1] Shared Use of TCP Experimental Options RFC 6994:
    https://tools.ietf.org/rfc/rfc6994.txt    
[2] IANA ExID SMCR: 
    http://www.iana.org/assignments/tcp-parameters/tcp-parameters.xhtml#tcp-exids

This patch has already been posted in June 2013, but Dave Miller has
postponed applying till the user of the new flags, ie. the entire SMC-R
protocol stack is implemented.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 include/linux/tcp.h        |  16 ++++-
 include/net/request_sock.h |   3 +-
 include/net/tcp.h          | 145 +++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_input.c       |   8 +++
 net/ipv4/tcp_minisocks.c   |   3 +
 net/ipv4/tcp_output.c      |  23 ++-----
 6 files changed, 179 insertions(+), 19 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 48c3696..1b9a698 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -90,15 +90,28 @@ struct tcp_options_received {
 		sack_ok : 4,	/* SACK seen on SYN packet		*/
 		snd_wscale : 4,	/* Window scaling received from sender	*/
 		rcv_wscale : 4;	/* Window scaling to send to receiver	*/
+	u8	smc_capability:1; /* SMC capability			*/
 	u8	num_sacks;	/* Number of SACK blocks		*/
 	u16	user_mss;	/* mss requested by user in ioctl	*/
 	u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
 };
 
+#if IS_ENABLED(CONFIG_AFSMC)
+static inline void smc_clear_rx_opt(struct tcp_options_received *rx_opt)
+{
+	rx_opt->smc_capability = 0;
+}
+#else
+static inline void smc_clear_rx_opt(struct tcp_options_received *rx_opt)
+{
+}
+#endif
+
 static inline void tcp_clear_options(struct tcp_options_received *rx_opt)
 {
 	rx_opt->tstamp_ok = rx_opt->sack_ok = 0;
 	rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
+	smc_clear_rx_opt(rx_opt);
 }
 
 /* This is the max number of SACKS that we'll generate and process. It's safe
@@ -207,7 +220,8 @@ struct tcp_sock {
 		syn_fastopen_exp:1,/* SYN includes Fast Open exp. option */
 		syn_data_acked:1,/* data in SYN is acked by SYN-ACK */
 		save_syn:1,	/* Save headers of SYN packet */
-		is_cwnd_limited:1;/* forward progress limited by snd_cwnd? */
+		is_cwnd_limited:1,/* forward progress limited by snd_cwnd? */
+		syn_smc:1;	/* SYN includes SMC			*/
 	u32	tlp_high_seq;	/* snd_nxt at the time of TLP retransmit. */
 
 /* RTT measurement */
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 87935ca..dee47d2 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -55,7 +55,8 @@ struct request_sock {
 	struct sock			*rsk_listener;
 	u16				mss;
 	u8				num_retrans; /* number of retransmits */
-	u8				cookie_ts:1; /* syncookie: encode tcpopts in timestamp */
+	u8				cookie_ts:1, /* syncookie: encode tcpopts in timestamp */
+					smc_capability:1;
 	u8				num_timeout:7; /* number of timeouts */
 	/* The following two fields can be easily recomputed I think -AK */
 	u32				window_clamp; /* window clamp at creation time */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 364426a..b51a6c1 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -46,6 +46,7 @@
 
 #include <linux/seq_file.h>
 #include <linux/memcontrol.h>
+#include <asm/unaligned.h>
 
 extern struct inet_hashinfo tcp_hashinfo;
 
@@ -185,6 +186,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
  * experimental options. See draft-ietf-tcpm-experimental-options-00.txt
  */
 #define TCPOPT_FASTOPEN_MAGIC	0xF989
+#define TCPOPT_SMC_MAGIC	0xE2D4C3D9
 
 /*
  *     TCP option lengths
@@ -197,6 +199,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOLEN_MD5SIG         18
 #define TCPOLEN_FASTOPEN_BASE  2
 #define TCPOLEN_EXP_FASTOPEN_BASE  4
+#define TCPOLEN_EXP_SMC_BASE   6
 
 /* But this is what stacks really send out. */
 #define TCPOLEN_TSTAMP_ALIGNED		12
@@ -207,6 +210,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOLEN_SACK_PERBLOCK		8
 #define TCPOLEN_MD5SIG_ALIGNED		20
 #define TCPOLEN_MSS_ALIGNED		4
+#define TCPOLEN_EXP_SMC_BASE_ALIGNED    8
 
 /* Flags in tp->nonagle */
 #define TCP_NAGLE_OFF		1	/* Nagle's algo is disabled */
@@ -1762,4 +1766,145 @@ static inline void skb_set_tcp_pure_ack(struct sk_buff *skb)
 	skb->truesize = 2;
 }
 
+struct tcp_out_options {
+	u16 options;		/* bit field of OPTION_* */
+	u16 mss;		/* 0 to disable */
+	u8 ws;			/* window scale, 0 to disable */
+	u8 num_sack_blocks;	/* number of SACK blocks to include */
+	u8 hash_size;		/* bytes in hash_location */
+	__u8 *hash_location;	/* temporary pointer, overloaded */
+	__u32 tsval, tsecr;	/* need to include OPTION_TS */
+	struct tcp_fastopen_cookie *fastopen_cookie;	/* Fast open cookie */
+};
+
+#define OPTION_SACK_ADVERTISE	(1 << 0)
+#define OPTION_TS		(1 << 1)
+#define OPTION_MD5		(1 << 2)
+#define OPTION_WSCALE		(1 << 3)
+#define OPTION_FAST_OPEN_COOKIE	(1 << 8)
+#define OPTION_SMC		(1 << 9)
+
+#if IS_ENABLED(CONFIG_AFSMC)
+static inline void smc_parse_options(const struct tcphdr *th,
+				     struct tcp_options_received *opt_rx,
+				     const unsigned char *ptr,
+				     int opsize)
+{
+	if (th->syn && !(opsize & 1) &&
+	    opsize >= TCPOLEN_EXP_SMC_BASE &&
+	    get_unaligned_be32(ptr) == TCPOPT_SMC_MAGIC)
+		opt_rx->smc_capability = 1;
+}
+
+static inline void smc_options_write(__be32 *ptr, u16 *options)
+{
+	if (unlikely(OPTION_SMC & *options)) {
+		*ptr++ = htonl((TCPOPT_NOP  << 24) |
+			       (TCPOPT_NOP  << 16) |
+			       (TCPOPT_EXP <<  8) |
+			       (TCPOLEN_EXP_SMC_BASE));
+		*ptr++ = htonl(TCPOPT_SMC_MAGIC);
+	}
+}
+
+static inline void smc_set_option(struct tcp_sock *tp,
+				  struct tcp_out_options *opts,
+				  unsigned int *remaining)
+{
+	if (tp->syn_smc) {
+		u32 need = TCPOLEN_EXP_SMC_BASE_ALIGNED;
+
+		if (*remaining >= need) {
+			opts->options |= OPTION_SMC;
+			*remaining -= need;
+		}
+	}
+}
+static inline void smc_set_option_cond(struct tcp_sock *tp,
+				       struct request_sock *req,
+				       struct tcp_out_options *opts,
+				       unsigned int *remaining)
+{
+	if (tp->syn_smc && req->smc_capability) {
+		u32 need = TCPOLEN_EXP_SMC_BASE_ALIGNED;
+
+		if (*remaining >= need) {
+			opts->options |= OPTION_SMC;
+			*remaining -= need;
+		}
+	}
+}
+
+static inline void smc_set_capability(struct request_sock *req,
+				      struct tcp_options_received *rx_opt)
+{
+	if (rx_opt->smc_capability)
+		req->smc_capability = 1;
+}
+
+static inline void smc_reset_capability(struct request_sock *req)
+{
+	req->smc_capability = 0;
+}
+
+static inline void smc_check_reset_syn(struct tcp_sock *tp)
+{
+	if (tp->syn_smc && !tp->rx_opt.smc_capability)
+		tp->syn_smc = 0;
+}
+
+static inline void smc_check_reset_syn_req(struct tcp_sock *oldtp,
+					   struct request_sock *req,
+					   struct tcp_sock *newtp)
+{
+	if (oldtp->syn_smc && !req->smc_capability)
+		newtp->syn_smc = 0;
+}
+
+#else
+static inline void smc_parse_options(const struct tcphdr *th,
+				     struct tcp_options_received *opt_rx,
+				     const unsigned char *ptr,
+				     int opsize)
+{
+}
+
+static inline void smc_options_write(__be32 *ptr, u16 *options)
+{
+}
+
+static inline void smc_set_option(struct tcp_sock *tp,
+				  struct tcp_out_options *opts,
+				  unsigned int *remaining)
+{
+}
+
+static inline void smc_set_option_cond(struct tcp_sock *tp,
+				       struct request_sock *req,
+				       struct tcp_out_options *opts,
+				       unsigned int *remaining)
+{
+}
+
+static inline void smc_set_capability(struct request_sock *req,
+				      struct tcp_options_received *rx_opt)
+{
+}
+
+static inline void smc_reset_capability(struct request_sock *req)
+{
+}
+
+static inline void smc_check_reset_syn(struct tcp_sock *tp)
+{
+}
+
+static inline void smc_check_reset_syn_req(struct tcp_sock *oldtp,
+					   struct request_sock *req,
+					   struct tcp_sock *tp)
+{
+}
+
+#endif /* IS_ENABLED(CONFIG_AFSMC) */
+
 #endif	/* _TCP_H */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1578fc2..9b49240 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3748,6 +3748,9 @@ void tcp_parse_options(const struct sk_buff *skb,
 					tcp_parse_fastopen_option(opsize -
 						TCPOLEN_EXP_FASTOPEN_BASE,
 						ptr + 2, th->syn, foc, true);
+				else
+					smc_parse_options(th, opt_rx, ptr,
+							  opsize);
 				break;
 
 			}
@@ -5556,6 +5559,8 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 		 * is initialized. */
 		tp->copied_seq = tp->rcv_nxt;
 
+		smc_check_reset_syn(tp);
+
 		smp_mb();
 
 		tcp_finish_connect(sk, skb);
@@ -6002,6 +6007,7 @@ static void tcp_openreq_init(struct request_sock *req,
 
 	req->rcv_wnd = 0;		/* So that tcp_send_synack() knows! */
 	req->cookie_ts = 0;
+	smc_reset_capability(req);
 	tcp_rsk(req)->rcv_isn = TCP_SKB_CB(skb)->seq;
 	tcp_rsk(req)->rcv_nxt = TCP_SKB_CB(skb)->seq + 1;
 	tcp_rsk(req)->snt_synack = tcp_time_stamp;
@@ -6142,6 +6148,8 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	/* Note: tcp_v6_init_req() might override ir_iif for link locals */
 	inet_rsk(req)->ir_iif = sk->sk_bound_dev_if;
 
+	smc_set_capability(req, &tmp_opt);
+
 	af_ops->init_req(req, sk, skb);
 
 	if (security_inet_conn_request(sk, skb, req))
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 6d8795b..62e6c2c 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -443,6 +443,9 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		struct tcp_request_sock *treq = tcp_rsk(req);
 		struct inet_connection_sock *newicsk = inet_csk(newsk);
 		struct tcp_sock *newtp = tcp_sk(newsk);
+		struct tcp_sock *oldtp = tcp_sk(sk);
+
+		smc_check_reset_syn_req(oldtp, req, newtp);
 
 		/* Now setup tcp_sock */
 		newtp->pred_flags = 0;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7105784..17ddabd 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -419,23 +419,6 @@ static inline bool tcp_urg_mode(const struct tcp_sock *tp)
 	return tp->snd_una != tp->snd_up;
 }
 
-#define OPTION_SACK_ADVERTISE	(1 << 0)
-#define OPTION_TS		(1 << 1)
-#define OPTION_MD5		(1 << 2)
-#define OPTION_WSCALE		(1 << 3)
-#define OPTION_FAST_OPEN_COOKIE	(1 << 8)
-
-struct tcp_out_options {
-	u16 options;		/* bit field of OPTION_* */
-	u16 mss;		/* 0 to disable */
-	u8 ws;			/* window scale, 0 to disable */
-	u8 num_sack_blocks;	/* number of SACK blocks to include */
-	u8 hash_size;		/* bytes in hash_location */
-	__u8 *hash_location;	/* temporary pointer, overloaded */
-	__u32 tsval, tsecr;	/* need to include OPTION_TS */
-	struct tcp_fastopen_cookie *fastopen_cookie;	/* Fast open cookie */
-};
-
 /* Write previously computed TCP options to the packet.
  *
  * Beware: Something in the Internet is very sensitive to the ordering of
@@ -542,6 +525,8 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 		}
 		ptr += (len + 3) >> 2;
 	}
+
+	smc_options_write(ptr, &options);
 }
 
 /* Compute TCP options for SYN packets. This is not the final
@@ -609,6 +594,8 @@ static unsigned int tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 		}
 	}
 
+	smc_set_option(tp, opts, &remaining);
+
 	return MAX_TCP_OPTION_SPACE - remaining;
 }
 
@@ -670,6 +657,8 @@ static unsigned int tcp_synack_options(struct sock *sk,
 		}
 	}
 
+	smc_set_option_cond(tcp_sk(sk), req, opts, &remaining);
+
 	return MAX_TCP_OPTION_SPACE - remaining;
 }
 
-- 
2.3.8
