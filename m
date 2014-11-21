From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH 1/3] [RFC] tcp: introduce TCP experimental option for SMC
Date: Fri, 21 Nov 2014 21:08:02 +0100
Message-ID: <1416600484-55631-2-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1416600484-55631-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: linux-s390@vger.kernel.org, davem@davemloft.net,
	utz.bacher@de.ibm.com, ogerlitz@mellanox.com, monis@mellanox.com,
	fowlerja@us.ibm.com, heiko.carstens@de.ibm.com,
	frank.blaschka@de.ibm.com, ursula.braun@de.ibm.com,
	ubraun@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:34275 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500AbaKUUIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 15:08:16 -0500
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 21 Nov 2014 20:08:14 -0000
In-Reply-To: <1416600484-55631-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

The SMC-R protocol defines dynamic discovery of peers. This is done by
implementing experimental TCP options as defined in RFC6994. The TCP code needs
to be extended to support RFC6994.

I would like to receive feedback:
  - if the proposed implementation of using the RFC6994 (TCP Experimental [1])
    option is considered implemented at the right level by the Linux kernel
    community.
  - and if not so, how the RFC can be implemented otherwise more
    appropriately.
  - if certain aspects prevent inclusion into the Linux kernel.

Setting TCP experimental option SMC-R will be triggered from kernel
exploiters like our new SMC-R socket family by setting a new
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

This patch has already been posted in June 2013, but Dave Miller has postponed
applying till the user of the new flags, ie. the entire SMC-R protocol stack is
implemented.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 include/linux/tcp.h        |  5 ++++-
 include/net/request_sock.h |  3 ++-
 include/net/tcp.h          |  4 ++++
 net/ipv4/tcp_input.c       | 41 ++++++++++++++++++++++++++++-------------
 net/ipv4/tcp_minisocks.c   |  4 ++++
 net/ipv4/tcp_output.c      | 26 ++++++++++++++++++++++++++
 6 files changed, 68 insertions(+), 15 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index f566b85..f3edcea 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -89,6 +89,7 @@ struct tcp_options_received {
 		sack_ok : 4,	/* SACK seen on SYN packet		*/
 		snd_wscale : 4,	/* Window scaling received from sender	*/
 		rcv_wscale : 4;	/* Window scaling to send to receiver	*/
+	u8	smc_capability:1; /* SMC capability			*/
 	u8	num_sacks;	/* Number of SACK blocks		*/
 	u16	user_mss;	/* mss requested by user in ioctl	*/
 	u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
@@ -98,6 +99,7 @@ static inline void tcp_clear_options(struct tcp_options_received *rx_opt)
 {
 	rx_opt->tstamp_ok = rx_opt->sack_ok = 0;
 	rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
+	rx_opt->smc_capability = 0;
 }
 
 /* This is the max number of SACKS that we'll generate and process. It's safe
@@ -187,7 +189,8 @@ struct tcp_sock {
 		syn_data:1,	/* SYN includes data */
 		syn_fastopen:1,	/* SYN includes Fast Open option */
 		syn_data_acked:1,/* data in SYN is acked by SYN-ACK */
-		is_cwnd_limited:1;/* forward progress limited by snd_cwnd? */
+		is_cwnd_limited:1,/* forward progress limited by snd_cwnd? */
+		syn_smc:1;	/* SYN include SMC			*/
 	u32	tlp_high_seq;	/* snd_nxt at the time of TLP retransmit. */
 
 /* RTT measurement */
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 7f830ff..11307a3 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -52,7 +52,8 @@ struct request_sock {
 	struct request_sock		*dl_next;
 	u16				mss;
 	u8				num_retrans; /* number of retransmits */
-	u8				cookie_ts:1; /* syncookie: encode tcpopts in timestamp */
+	u8				cookie_ts:1, /* syncookie: encode tcpopts in timestamp */
+					smc_capability:1;
 	u8				num_timeout:7; /* number of timeouts */
 	/* The following two fields can be easily recomputed I think -AK */
 	u32				window_clamp; /* window clamp at creation time */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index f50f29faf..a25c220 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -178,6 +178,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
  * experimental options. See draft-ietf-tcpm-experimental-options-00.txt
  */
 #define TCPOPT_FASTOPEN_MAGIC	0xF989
+#define TCPOPT_SMC_MAGIC	0xE2D4C3D9
 
 /*
  *     TCP option lengths
@@ -189,6 +190,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOLEN_TIMESTAMP      10
 #define TCPOLEN_MD5SIG         18
 #define TCPOLEN_EXP_FASTOPEN_BASE  4
+#define TCPOLEN_EXP_SMC_BASE   6
 
 /* But this is what stacks really send out. */
 #define TCPOLEN_TSTAMP_ALIGNED		12
@@ -199,6 +201,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOLEN_SACK_PERBLOCK		8
 #define TCPOLEN_MD5SIG_ALIGNED		20
 #define TCPOLEN_MSS_ALIGNED		4
+#define TCPOLEN_EXP_SMC_BASE_ALIGNED    8
 
 /* Flags in tp->nonagle */
 #define TCP_NAGLE_OFF		1	/* Nagle's algo is disabled */
@@ -1121,6 +1124,7 @@ static inline void tcp_openreq_init(struct request_sock *req,
 
 	req->rcv_wnd = 0;		/* So that tcp_send_synack() knows! */
 	req->cookie_ts = 0;
+	req->smc_capability = 0;
 	tcp_rsk(req)->rcv_isn = TCP_SKB_CB(skb)->seq;
 	tcp_rsk(req)->rcv_nxt = TCP_SKB_CB(skb)->seq + 1;
 	tcp_rsk(req)->snt_synack = tcp_time_stamp;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d91436b..eb435e5 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3650,20 +3650,29 @@ void tcp_parse_options(const struct sk_buff *skb,
 				break;
 #endif
 			case TCPOPT_EXP:
-				/* Fast Open option shares code 254 using a
-				 * 16 bits magic number. It's valid only in
-				 * SYN or SYN-ACK with an even size.
-				 */
-				if (opsize < TCPOLEN_EXP_FASTOPEN_BASE ||
-				    get_unaligned_be16(ptr) != TCPOPT_FASTOPEN_MAGIC ||
-				    foc == NULL || !th->syn || (opsize & 1))
+				if (!th->syn || (opsize & 1) ||
+				    (opsize < TCPOLEN_EXP_FASTOPEN_BASE))
+					break;
+				if (get_unaligned_be16(ptr) == TCPOPT_FASTOPEN_MAGIC) {
+					if (foc == NULL)
+						break;
+					/* Fast Open option shares code 254 using a
+					 * 16 bits magic number. It's valid only in
+					 * SYN or SYN-ACK with an even size.
+					 */
+					foc->len = opsize - TCPOLEN_EXP_FASTOPEN_BASE;
+					if (foc->len >= TCP_FASTOPEN_COOKIE_MIN &&
+					    foc->len <= TCP_FASTOPEN_COOKIE_MAX)
+						memcpy(foc->val, ptr + 2, foc->len);
+					else if (foc->len != 0)
+						foc->len = -1;
+					break;
+				} else if (opsize < TCPOLEN_EXP_SMC_BASE) {
 					break;
-				foc->len = opsize - TCPOLEN_EXP_FASTOPEN_BASE;
-				if (foc->len >= TCP_FASTOPEN_COOKIE_MIN &&
-				    foc->len <= TCP_FASTOPEN_COOKIE_MAX)
-					memcpy(foc->val, ptr + 2, foc->len);
-				else if (foc->len != 0)
-					foc->len = -1;
+				} else if (get_unaligned_be32(ptr) == TCPOPT_SMC_MAGIC) {
+					opt_rx->smc_capability = 1;
+					break;
+				}
 				break;
 
 			}
@@ -5457,6 +5466,9 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 		 * is initialized. */
 		tp->copied_seq = tp->rcv_nxt;
 
+		if (tp->syn_smc && !tp->rx_opt.smc_capability)
+			tp->syn_smc = 0;
+
 		smp_mb();
 
 		tcp_finish_connect(sk, skb);
@@ -5953,6 +5965,9 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
 	tcp_openreq_init(req, &tmp_opt, skb, sk);
 
+	if (tmp_opt.smc_capability)
+		req->smc_capability = 1;
+
 	af_ops->init_req(req, sk, skb);
 
 	if (security_inet_conn_request(sk, skb, req))
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 63d2680..1fd1f7e 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -414,6 +414,10 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
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
index f5bd4bd..ba242d0 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -424,6 +424,7 @@ static inline bool tcp_urg_mode(const struct tcp_sock *tp)
 #define OPTION_MD5		(1 << 2)
 #define OPTION_WSCALE		(1 << 3)
 #define OPTION_FAST_OPEN_COOKIE	(1 << 8)
+#define OPTION_SMC		(1 << 9)
 
 struct tcp_out_options {
 	u16 options;		/* bit field of OPTION_* */
@@ -533,6 +534,14 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 		}
 		ptr += (foc->len + 3) >> 2;
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
@@ -596,6 +605,14 @@ static unsigned int tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 		}
 	}
 
+	if (tp->syn_smc) {
+		u32 need = TCPOLEN_EXP_SMC_BASE_ALIGNED;
+		if (remaining >= need) {
+			opts->options |= OPTION_SMC;
+			remaining -= need;
+		}
+	}
+
 	return MAX_TCP_OPTION_SPACE - remaining;
 }
 
@@ -608,6 +625,7 @@ static unsigned int tcp_synack_options(struct sock *sk,
 				   struct tcp_fastopen_cookie *foc)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
+	struct tcp_sock *tp = tcp_sk(sk);
 	unsigned int remaining = MAX_TCP_OPTION_SPACE;
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -657,6 +675,14 @@ static unsigned int tcp_synack_options(struct sock *sk,
 		}
 	}
 
+	if (tp->syn_smc && req->smc_capability) {
+		u32 need = TCPOLEN_EXP_SMC_BASE_ALIGNED;
+		if (remaining >= need) {
+			opts->options |= OPTION_SMC;
+			remaining -= need;
+		}
+	}
+
 	return MAX_TCP_OPTION_SPACE - remaining;
 }
 
-- 
1.8.5.5
