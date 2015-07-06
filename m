From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 1/3] tcp: introduce TCP experimental option for SMC
Date: Mon,  6 Jul 2015 17:11:49 +0200
Message-ID: <1436195511-32314-2-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1436195511-32314-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: utz.bacher@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, ursula.braun@de.ibm.com,
	ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:57733 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753474AbbGFPMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 11:12:15 -0400
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Mon, 6 Jul 2015 16:12:13 +0100
In-Reply-To: <1436195511-32314-1-git-send-email-ubraun@linux.vnet.ibm.com>
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

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 include/linux/tcp.h        |  5 ++++-
 include/net/request_sock.h |  3 ++-
 include/net/tcp.h          |  3 +++
 net/ipv4/tcp_input.c       | 12 ++++++++++++
 net/ipv4/tcp_minisocks.c   |  4 ++++
 net/ipv4/tcp_output.c      | 28 ++++++++++++++++++++++++++++
 6 files changed, 53 insertions(+), 2 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 48c3696..de0d67c 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -90,6 +90,7 @@ struct tcp_options_received {
 		sack_ok : 4,	/* SACK seen on SYN packet		*/
 		snd_wscale : 4,	/* Window scaling received from sender	*/
 		rcv_wscale : 4;	/* Window scaling to send to receiver	*/
+	u8	smc_capability:1; /* SMC capability			*/
 	u8	num_sacks;	/* Number of SACK blocks		*/
 	u16	user_mss;	/* mss requested by user in ioctl	*/
 	u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
@@ -99,6 +100,7 @@ static inline void tcp_clear_options(struct tcp_options_received *rx_opt)
 {
 	rx_opt->tstamp_ok = rx_opt->sack_ok = 0;
 	rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
+	rx_opt->smc_capability = 0;
 }
 
 /* This is the max number of SACKS that we'll generate and process. It's safe
@@ -207,7 +209,8 @@ struct tcp_sock {
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
index 950cfec..882e8d5 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -185,6 +185,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
  * experimental options. See draft-ietf-tcpm-experimental-options-00.txt
  */
 #define TCPOPT_FASTOPEN_MAGIC	0xF989
+#define TCPOPT_SMC_MAGIC	0xE2D4C3D9
 
 /*
  *     TCP option lengths
@@ -197,6 +198,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOLEN_MD5SIG         18
 #define TCPOLEN_FASTOPEN_BASE  2
 #define TCPOLEN_EXP_FASTOPEN_BASE  4
+#define TCPOLEN_EXP_SMC_BASE   6
 
 /* But this is what stacks really send out. */
 #define TCPOLEN_TSTAMP_ALIGNED		12
@@ -207,6 +209,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOLEN_SACK_PERBLOCK		8
 #define TCPOLEN_MD5SIG_ALIGNED		20
 #define TCPOLEN_MSS_ALIGNED		4
+#define TCPOLEN_EXP_SMC_BASE_ALIGNED    8
 
 /* Flags in tp->nonagle */
 #define TCP_NAGLE_OFF		1	/* Nagle's algo is disabled */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 684f095..0cde982 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3743,6 +3743,11 @@ void tcp_parse_options(const struct sk_buff *skb,
 					tcp_parse_fastopen_option(opsize -
 						TCPOLEN_EXP_FASTOPEN_BASE,
 						ptr + 2, th->syn, foc, true);
+				else if (th->syn && !(opsize & 1) &&
+					 opsize >= TCPOLEN_EXP_SMC_BASE &&
+					 get_unaligned_be32(ptr) ==
+					 TCPOPT_SMC_MAGIC)
+					opt_rx->smc_capability = 1;
 				break;
 
 			}
@@ -5554,6 +5559,9 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 		 * is initialized. */
 		tp->copied_seq = tp->rcv_nxt;
 
+		if (tp->syn_smc && !tp->rx_opt.smc_capability)
+			tp->syn_smc = 0;
+
 		smp_mb();
 
 		tcp_finish_connect(sk, skb);
@@ -6000,6 +6008,7 @@ static void tcp_openreq_init(struct request_sock *req,
 
 	req->rcv_wnd = 0;		/* So that tcp_send_synack() knows! */
 	req->cookie_ts = 0;
+	req->smc_capability = 0;
 	tcp_rsk(req)->rcv_isn = TCP_SKB_CB(skb)->seq;
 	tcp_rsk(req)->rcv_nxt = TCP_SKB_CB(skb)->seq + 1;
 	tcp_rsk(req)->snt_synack = tcp_time_stamp;
@@ -6140,6 +6149,9 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	/* Note: tcp_v6_init_req() might override ir_iif for link locals */
 	inet_rsk(req)->ir_iif = sk->sk_bound_dev_if;
 
+	if (tmp_opt.smc_capability)
+		req->smc_capability = 1;
+
 	af_ops->init_req(req, sk, skb);
 
 	if (security_inet_conn_request(sk, skb, req))
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 4bc00cb..3a19d97 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -445,6 +445,10 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		struct tcp_request_sock *treq = tcp_rsk(req);
 		struct inet_connection_sock *newicsk = inet_csk(newsk);
 		struct tcp_sock *newtp = tcp_sk(newsk);
+		struct tcp_sock *oldtp = tcp_sk(sk);
+
+		if (oldtp->syn_smc && !req->smc_capability)
+			newtp->syn_smc = 0;
 
 		/* Now setup tcp_sock */
 		newtp->pred_flags = 0;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index b1c218d..acb6d8d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -426,6 +426,7 @@ static inline bool tcp_urg_mode(const struct tcp_sock *tp)
 #define OPTION_MD5		(1 << 2)
 #define OPTION_WSCALE		(1 << 3)
 #define OPTION_FAST_OPEN_COOKIE	(1 << 8)
+#define OPTION_SMC		(1 << 9)
 
 struct tcp_out_options {
 	u16 options;		/* bit field of OPTION_* */
@@ -544,6 +545,14 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 		}
 		ptr += (len + 3) >> 2;
 	}
+
+	if (unlikely(OPTION_SMC & options)) {
+		*ptr++ = htonl((TCPOPT_NOP  << 24) |
+			       (TCPOPT_NOP  << 16) |
+			       (TCPOPT_EXP <<  8) |
+			       (TCPOLEN_EXP_SMC_BASE));
+		*ptr++ = htonl(TCPOPT_SMC_MAGIC);
+	}
 }
 
 /* Compute TCP options for SYN packets. This is not the final
@@ -611,6 +620,15 @@ static unsigned int tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 		}
 	}
 
+	if (tp->syn_smc) {
+		u32 need = TCPOLEN_EXP_SMC_BASE_ALIGNED;
+
+		if (remaining >= need) {
+			opts->options |= OPTION_SMC;
+			remaining -= need;
+		}
+	}
+
 	return MAX_TCP_OPTION_SPACE - remaining;
 }
 
@@ -623,6 +641,7 @@ static unsigned int tcp_synack_options(struct sock *sk,
 				   struct tcp_fastopen_cookie *foc)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
+	struct tcp_sock *tp = tcp_sk(sk);
 	unsigned int remaining = MAX_TCP_OPTION_SPACE;
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -672,6 +691,15 @@ static unsigned int tcp_synack_options(struct sock *sk,
 		}
 	}
 
+	if (tp->syn_smc && req->smc_capability) {
+		u32 need = TCPOLEN_EXP_SMC_BASE_ALIGNED;
+
+		if (remaining >= need) {
+			opts->options |= OPTION_SMC;
+			remaining -= need;
+		}
+	}
+
 	return MAX_TCP_OPTION_SPACE - remaining;
 }
 
-- 
2.3.8
