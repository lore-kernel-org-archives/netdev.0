From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH V3 net-next 2/5] tcp: TCP experimental option for SMC - TCP hooks
Date: Wed, 22 Jul 2015 10:59:49 +0200
Message-ID: <1437555592-16506-3-git-send-email-ubraun@linux.vnet.ibm.com>
References: <20150715.212837.233151628267116088.davem@davemloft.net>
 <1437555592-16506-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: utz.bacher@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, ursula.braun@de.ibm.com,
	ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:53951 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933301AbbGVJAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 05:00:05 -0400
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Wed, 22 Jul 2015 10:00:02 +0100
In-Reply-To: <1437555592-16506-1-git-send-email-ubraun@linux.vnet.ibm.com>
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
 include/linux/tcp.h      |   8 +++
 include/net/tcp.h        | 128 +++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp.c           |   3 ++
 net/ipv4/tcp_input.c     |   7 +++
 net/ipv4/tcp_minisocks.c |   3 ++
 net/ipv4/tcp_output.c    |  23 +++------
 6 files changed, 155 insertions(+), 17 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 488a875..4afaa202 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -96,10 +96,18 @@ struct tcp_options_received {
 	u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
 };
 
+#if IS_ENABLED(CONFIG_AFSMC)
+extern struct static_key tcp_have_smc;
+#endif
+
 static inline void tcp_clear_options(struct tcp_options_received *rx_opt)
 {
 	rx_opt->tstamp_ok = rx_opt->sack_ok = 0;
 	rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
+#if IS_ENABLED(CONFIG_AFSMC)
+	if (static_key_false(&tcp_have_smc))
+		rx_opt->smc_ok = 0;
+#endif
 }
 
 /* This is the max number of SACKS that we'll generate and process. It's safe
diff --git a/include/net/tcp.h b/include/net/tcp.h
index e4584ed..4e28233 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1766,8 +1766,136 @@ static inline void skb_set_tcp_pure_ack(struct sk_buff *skb)
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
 #if IS_ENABLED(CONFIG_AFSMC)
 extern struct static_key tcp_have_smc;
 #endif
 
+static inline void smc_parse_options(const struct tcphdr *th,
+				     struct tcp_options_received *opt_rx,
+				     const unsigned char *ptr,
+				     int opsize)
+{
+#if IS_ENABLED(CONFIG_AFSMC)
+	if (!static_key_false(&tcp_have_smc))
+		return;
+	if (th->syn && !(opsize & 1) &&
+	    opsize >= TCPOLEN_EXP_SMC_BASE &&
+	    get_unaligned_be32(ptr) == TCPOPT_SMC_MAGIC)
+		opt_rx->smc_ok = 1;
+#endif
+}
+
+static inline void smc_options_write(__be32 *ptr, u16 *options)
+{
+#if IS_ENABLED(CONFIG_AFSMC)
+	if (!static_key_false(&tcp_have_smc))
+		return;
+	if (unlikely(OPTION_SMC & *options)) {
+		*ptr++ = htonl((TCPOPT_NOP  << 24) |
+			       (TCPOPT_NOP  << 16) |
+			       (TCPOPT_EXP <<  8) |
+			       (TCPOLEN_EXP_SMC_BASE));
+		*ptr++ = htonl(TCPOPT_SMC_MAGIC);
+	}
+#endif
+}
+
+static inline void smc_set_option(struct tcp_sock *tp,
+				  struct tcp_out_options *opts,
+				  unsigned int *remaining)
+{
+#if IS_ENABLED(CONFIG_AFSMC)
+	if (!static_key_false(&tcp_have_smc))
+		return;
+	if (tp->syn_smc) {
+		u32 need = TCPOLEN_EXP_SMC_BASE_ALIGNED;
+
+		if (*remaining >= need) {
+			opts->options |= OPTION_SMC;
+			*remaining -= need;
+		}
+	}
+#endif
+
+}
+static inline void smc_set_option_cond(struct tcp_sock *tp,
+				       struct request_sock *req,
+				       struct tcp_out_options *opts,
+				       unsigned int *remaining)
+{
+#if IS_ENABLED(CONFIG_AFSMC)
+	struct inet_request_sock *ireq;
+
+	if (!static_key_false(&tcp_have_smc))
+		return;
+
+	ireq = inet_rsk(req);
+	if (tp->syn_smc && ireq->smc_ok) {
+		u32 need = TCPOLEN_EXP_SMC_BASE_ALIGNED;
+
+		if (*remaining >= need) {
+			opts->options |= OPTION_SMC;
+			*remaining -= need;
+		}
+	}
+#endif
+}
+
+static inline void smc_set_capability(struct inet_request_sock *ireq,
+				      const struct tcp_options_received *rx_opt)
+{
+#if IS_ENABLED(CONFIG_AFSMC)
+	if (!static_key_false(&tcp_have_smc))
+		return;
+
+	if (rx_opt->smc_ok)
+		ireq->smc_ok = 1;
+	else
+		ireq->smc_ok = 0;
+#endif
+}
+
+static inline void smc_check_reset_syn(struct tcp_sock *tp)
+{
+#if IS_ENABLED(CONFIG_AFSMC)
+	if (static_key_false(&tcp_have_smc))
+		if (tp->syn_smc && !tp->rx_opt.smc_ok)
+			tp->syn_smc = 0;
+#endif
+}
+
+static inline void smc_check_reset_syn_req(struct tcp_sock *oldtp,
+					   struct request_sock *req,
+					   struct tcp_sock *newtp)
+{
+#if IS_ENABLED(CONFIG_AFSMC)
+	struct inet_request_sock *ireq;
+
+	if (!static_key_false(&tcp_have_smc))
+		return;
+
+	ireq = inet_rsk(req);
+	if (oldtp->syn_smc && !ireq->smc_ok)
+		newtp->syn_smc = 0;
+#endif
+}
+
 #endif	/* _TCP_H */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 7f40567..4d27db6 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -301,6 +301,9 @@ EXPORT_SYMBOL(sysctl_tcp_wmem);
 atomic_long_t tcp_memory_allocated;	/* Current allocated memory. */
 EXPORT_SYMBOL(tcp_memory_allocated);
 
+struct static_key tcp_have_smc __read_mostly = STATIC_KEY_INIT_FALSE;
+EXPORT_SYMBOL(tcp_have_smc);
+
 /*
  * Current number of TCP sockets.
  */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1578fc2..4d35ceb 100644
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
@@ -6017,6 +6022,8 @@ static void tcp_openreq_init(struct request_sock *req,
 	ireq->ir_rmt_port = tcp_hdr(skb)->source;
 	ireq->ir_num = ntohs(tcp_hdr(skb)->dest);
 	ireq->ir_mark = inet_request_mark(sk, skb);
+	smc_set_capability(ireq, rx_opt);
+
 }
 
 struct request_sock *inet_reqsk_alloc(const struct request_sock_ops *ops,
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
