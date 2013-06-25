From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [patch 1/1] tcp: introduce TCP experimental option for SMC-R
Date: Tue, 25 Jun 2013 15:59:05 +0200
Message-ID: <20130625140033.744208982@linux.vnet.ibm.com>
References: <20130625135904.840700403@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ubraun@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:37682 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308Ab3FYOAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 10:00:45 -0400
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Tue, 25 Jun 2013 14:56:13 +0100
Content-Disposition: inline; filename=smc-tcp-handshake-v4.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>

RDMA is considered to become an important technology for IBM System z
(which is "s390" in Linux kernel terminology).
We intend to introduce a new socket protocol family providing Shared
Memory Communications over RDMA called SMC-R. The respective IETF draft
can be found at [1]. Its objective is to come up with a low latency, but
also low CPU cost communication vehicle exploiting RDMA technology
transparently while keeping the TCP/IP administration model and allowing
fallback to TCP sockets if necessary. The SMC-R protocol makes use of
the existing TCP 3-way hand shake, the TCP connection and IP topology to
preserve the traditional network administrative model including network
security. The SMC-R protocol also enables redundancy and load balancing
across multiple RDMA-capable devices.

An essential part of this approach is the so-called "rendezvous"
protocol through TCP sockets. It is used to dynamically discover RDMA
capabilities of connection partners and exchange credentials necessary
to exploit that capability if present and to have a fallback to TCP
sockets otherwise. It makes use of the concept of TCP experimental
options as described in [2]. The assigned ExID is 0xE2D4C3D9 [3].
This is the only part of our approach touching common TCP code in the
Linux kernel.

According to the SMC-R protocol connections are set up using regular
TCP sockets. During the TCP 3-way handshake, a new experimental TCP
option announces SMC-R capability. If both partners indicate SMC-R
capability then at the completion of the 3-way TCP handshake the SMC-R
layers in each peer take control of the TCP connection.

An implementation of a new TCP experimental option requires changes to
the existing TCP kernel code. This RFC describes our intended changes to
support TCP experimental option SMC-R. I would like to receive feedback
  - if the proposed implementation of using the RFC'ed TCP experimental
    option is considered done at the right level by the Linux kernel
    community.
  - and if not so, how the RFC can be implemented otherwise more
    appropriately.
  - if certain aspects prevent inclusion into the Linux kernel.

Setting TCP experimental option SMC-R will be triggered from kernel
exploiters like our new SMC-R socket address family by setting a new
flag "syn_smc" on struct tcp_sock of the connecting and the listening
socket. If the client peer is SMC-R capable, flag syn_smc is kept on the
connecting socket after the 3-way TPC handshake, otherwise it is reset.
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
[1] http://datatracker.ietf.org/doc/draft-fox-tcpm-shared-memory-rdma/
[2] http://datatracker.ietf.org/doc/draft-ietf-tcpm-experimental-options/
[3] http://www.iana.org/assignments/tcp-parameters

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>

---
 include/linux/tcp.h        |    4 +++-
 include/net/request_sock.h |    3 ++-
 include/net/tcp.h          |    3 +++
 net/ipv4/tcp_input.c       |   38 +++++++++++++++++++++++++-------------
 net/ipv4/tcp_ipv4.c        |    3 +++
 net/ipv4/tcp_minisocks.c   |    4 ++++
 net/ipv4/tcp_output.c      |   26 ++++++++++++++++++++++++++
 7 files changed, 66 insertions(+), 15 deletions(-)

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
@@ -198,7 +199,8 @@ struct tcp_sock {
 	u8	do_early_retrans:1,/* Enable RFC5827 early-retransmit  */
 		syn_data:1,	/* SYN includes data */
 		syn_fastopen:1,	/* SYN includes Fast Open option */
-		syn_data_acked:1;/* data in SYN is acked by SYN-ACK */
+		syn_data_acked:1,/* data in SYN is acked by SYN-ACK */
+		syn_smc:1;	/* SYN includes SMC			*/
 	u32	tlp_high_seq;	/* snd_nxt at the time of TLP retransmit. */
 
 /* RTT measurement */
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -51,7 +51,8 @@ struct request_sock {
 	struct request_sock		*dl_next;
 	u16				mss;
 	u8				num_retrans; /* number of retransmits */
-	u8				cookie_ts:1; /* syncookie: encode tcpopts in timestamp */
+	u8				cookie_ts:1, /* syncookie: encode tcpopts in timestamp */
+					smc_capability:1;
 	u8				num_timeout:7; /* number of timeouts */
 	/* The following two fields can be easily recomputed I think -AK */
 	u32				window_clamp; /* window clamp at creation time */
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -181,6 +181,7 @@ extern void tcp_time_wait(struct sock *s
  * experimental options. See draft-ietf-tcpm-experimental-options-00.txt
  */
 #define TCPOPT_FASTOPEN_MAGIC	0xF989
+#define TCPOPT_SMC_MAGIC	0xE2D4C3D9
 
 /*
  *     TCP option lengths
@@ -196,6 +197,7 @@ extern void tcp_time_wait(struct sock *s
 #define TCPOLEN_COOKIE_PAIR    3	/* Cookie pair header extension */
 #define TCPOLEN_COOKIE_MIN     (TCPOLEN_COOKIE_BASE+TCP_COOKIE_MIN)
 #define TCPOLEN_COOKIE_MAX     (TCPOLEN_COOKIE_BASE+TCP_COOKIE_MAX)
+#define TCPOLEN_EXP_SMC_BASE   6
 
 /* But this is what stacks really send out. */
 #define TCPOLEN_TSTAMP_ALIGNED		12
@@ -206,6 +208,7 @@ extern void tcp_time_wait(struct sock *s
 #define TCPOLEN_SACK_PERBLOCK		8
 #define TCPOLEN_MD5SIG_ALIGNED		20
 #define TCPOLEN_MSS_ALIGNED		4
+#define TCPOLEN_EXP_SMC_BASE_ALIGNED	8
 
 /* Flags in tp->nonagle */
 #define TCP_NAGLE_OFF		1	/* Nagle's algo is disabled */
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3501,20 +3501,29 @@ void tcp_parse_options(const struct sk_b
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
+				} else if (opsize < TCPOLEN_EXP_SMC_BASE)
 					break;
-				foc->len = opsize - TCPOLEN_EXP_FASTOPEN_BASE;
-				if (foc->len >= TCP_FASTOPEN_COOKIE_MIN &&
-				    foc->len <= TCP_FASTOPEN_COOKIE_MAX)
-					memcpy(foc->val, ptr + 2, foc->len);
-				else if (foc->len != 0)
-					foc->len = -1;
+				else if (get_unaligned_be32(ptr) == TCPOPT_SMC_MAGIC) {
+					opt_rx->smc_capability = 1;
+					break;
+				}
 				break;
 
 			}
@@ -5412,6 +5421,9 @@ static int tcp_rcv_synsent_state_process
 		 * is initialized. */
 		tp->copied_seq = tp->rcv_nxt;
 
+		if (tp->syn_smc && !tp->rx_opt.smc_capability)
+			tp->syn_smc = 0;
+
 		smp_mb();
 
 		tcp_finish_connect(sk, skb);
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1491,6 +1491,9 @@ int tcp_v4_conn_request(struct sock *sk,
 	tmp_opt.user_mss  = tp->rx_opt.user_mss;
 	tcp_parse_options(skb, &tmp_opt, 0, want_cookie ? NULL : &foc);
 
+	if (tmp_opt.smc_capability)
+		req->smc_capability = 1;
+
 	if (want_cookie && !tmp_opt.saw_tstamp)
 		tcp_clear_options(&tmp_opt);
 
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -385,6 +385,10 @@ struct sock *tcp_create_openreq_child(st
 		struct tcp_request_sock *treq = tcp_rsk(req);
 		struct inet_connection_sock *newicsk = inet_csk(newsk);
 		struct tcp_sock *newtp = tcp_sk(newsk);
+		struct tcp_sock *oldtp = tcp_sk(sk);
+
+		if (oldtp->syn_smc && !req->smc_capability)
+			newtp->syn_smc = 0;
 
 		/* Now setup tcp_sock */
 		newtp->pred_flags = 0;
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -386,6 +386,7 @@ static inline bool tcp_urg_mode(const st
 #define OPTION_MD5		(1 << 2)
 #define OPTION_WSCALE		(1 << 3)
 #define OPTION_FAST_OPEN_COOKIE	(1 << 8)
+#define OPTION_SMC		(1 << 9)
 
 struct tcp_out_options {
 	u16 options;		/* bit field of OPTION_* */
@@ -495,6 +496,14 @@ static void tcp_options_write(__be32 *pt
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
@@ -558,6 +567,14 @@ static unsigned int tcp_syn_options(stru
 		}
 	}
 
+	if (tp->syn_smc) {
+		int need = TCPOLEN_EXP_SMC_BASE_ALIGNED;
+		if (remaining >= need) {
+			opts->options |= OPTION_SMC;
+			remaining -= need;
+		}
+	}
+
 	return MAX_TCP_OPTION_SPACE - remaining;
 }
 
@@ -570,6 +587,7 @@ static unsigned int tcp_synack_options(s
 				   struct tcp_fastopen_cookie *foc)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
+	struct tcp_sock *tp = tcp_sk(sk);
 	unsigned int remaining = MAX_TCP_OPTION_SPACE;
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -618,6 +636,14 @@ static unsigned int tcp_synack_options(s
 			remaining -= need;
 		}
 	}
+
+	if (tp->syn_smc && req->smc_capability) {
+		int need = TCPOLEN_EXP_SMC_BASE_ALIGNED;
+		if (remaining >= need) {
+			opts->options |= OPTION_SMC;
+			remaining -= need;
+		}
+	}
 
 	return MAX_TCP_OPTION_SPACE - remaining;
 }
