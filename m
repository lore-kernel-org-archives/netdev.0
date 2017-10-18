From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH V2 net-next 2/3] tcp: TCP experimental option for SMC
Date: Wed, 18 Oct 2017 16:29:59 +0200
Message-ID: <20171018143000.23884-3-ubraun@linux.vnet.ibm.com>
References: <20171018143000.23884-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:54768 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751844AbdJROaL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 10:30:11 -0400
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9IETVH8113752
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 10:30:11 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2dp6s5046n-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 10:30:10 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Wed, 18 Oct 2017 15:30:09 +0100
In-Reply-To: <20171018143000.23884-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SMC protocol [1] relies on the use of a new TCP experimental
option [2, 3]. With this option, SMC capabilities are exchanged
between peers during the TCP three way handshake. This patch adds
support for this experimental option to TCP.

References:
[1] SMC-R Informational RFC: http://www.rfc-editor.org/info/rfc7609
[2] Shared Use of TCP Experimental Options RFC 6994:
    https://tools.ietf.org/rfc/rfc6994.txt
[3] IANA ExID SMCR:
http://www.iana.org/assignments/tcp-parameters/tcp-parameters.xhtml#tcp-exids

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 include/linux/tcp.h      |  9 +++++--
 include/net/inet_sock.h  |  3 ++-
 include/net/tcp.h        |  8 ++++++
 net/ipv4/tcp.c           |  6 +++++
 net/ipv4/tcp_input.c     | 34 ++++++++++++++++++++++++++
 net/ipv4/tcp_minisocks.c | 19 +++++++++++++++
 net/ipv4/tcp_output.c    | 63 +++++++++++++++++++++++++++++++++++++++++++++---
 7 files changed, 136 insertions(+), 6 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 1d2c44e09e31..3fb28954a1b7 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -98,7 +98,8 @@ struct tcp_options_received {
 		tstamp_ok : 1,	/* TIMESTAMP seen on SYN packet		*/
 		dsack : 1,	/* D-SACK is scheduled			*/
 		wscale_ok : 1,	/* Wscale seen on SYN packet		*/
-		sack_ok : 4,	/* SACK seen on SYN packet		*/
+		sack_ok : 3,	/* SACK seen on SYN packet		*/
+		smc_ok : 1,	/* SMC seen on SYN packet		*/
 		snd_wscale : 4,	/* Window scaling received from sender	*/
 		rcv_wscale : 4;	/* Window scaling to send to receiver	*/
 	u8	num_sacks;	/* Number of SACK blocks		*/
@@ -110,6 +111,9 @@ static inline void tcp_clear_options(struct tcp_options_received *rx_opt)
 {
 	rx_opt->tstamp_ok = rx_opt->sack_ok = 0;
 	rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
+#if IS_ENABLED(CONFIG_SMC)
+	rx_opt->smc_ok = 0;
+#endif
 }
 
 /* This is the max number of SACKS that we'll generate and process. It's safe
@@ -228,7 +232,8 @@ struct tcp_sock {
 		syn_fastopen_ch:1, /* Active TFO re-enabling probe */
 		syn_data_acked:1,/* data in SYN is acked by SYN-ACK */
 		save_syn:1,	/* Save headers of SYN packet */
-		is_cwnd_limited:1;/* forward progress limited by snd_cwnd? */
+		is_cwnd_limited:1,/* forward progress limited by snd_cwnd? */
+		syn_smc:1;	/* SYN includes SMC */
 	u32	tlp_high_seq;	/* snd_nxt at the time of TLP retransmit. */
 
 /* RTT measurement */
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index aa95053dfc78..600a7626eba0 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -92,7 +92,8 @@ struct inet_request_sock {
 				wscale_ok  : 1,
 				ecn_ok	   : 1,
 				acked	   : 1,
-				no_srccheck: 1;
+				no_srccheck: 1,
+				smc_ok	   : 1;
 	kmemcheck_bitfield_end(flags);
 	u32                     ir_mark;
 	union {
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 3b3b9b968e2d..a2e87ac8cdc0 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -45,6 +45,7 @@
 
 #include <linux/seq_file.h>
 #include <linux/memcontrol.h>
+#include <linux/unaligned/access_ok.h>
 
 #include <linux/bpf.h>
 #include <linux/filter.h>
@@ -191,6 +192,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
  * experimental options. See draft-ietf-tcpm-experimental-options-00.txt
  */
 #define TCPOPT_FASTOPEN_MAGIC	0xF989
+#define TCPOPT_SMC_MAGIC	0xE2D4C3D9
 
 /*
  *     TCP option lengths
@@ -203,6 +205,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOLEN_MD5SIG         18
 #define TCPOLEN_FASTOPEN_BASE  2
 #define TCPOLEN_EXP_FASTOPEN_BASE  4
+#define TCPOLEN_EXP_SMC_BASE   6
 
 /* But this is what stacks really send out. */
 #define TCPOLEN_TSTAMP_ALIGNED		12
@@ -213,6 +216,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOLEN_SACK_PERBLOCK		8
 #define TCPOLEN_MD5SIG_ALIGNED		20
 #define TCPOLEN_MSS_ALIGNED		4
+#define TCPOLEN_EXP_SMC_BASE_ALIGNED	8
 
 /* Flags in tp->nonagle */
 #define TCP_NAGLE_OFF		1	/* Nagle's algo is disabled */
@@ -2101,4 +2105,8 @@ static inline bool tcp_bpf_ca_needs_ecn(struct sock *sk)
 {
 	return (tcp_call_bpf(sk, BPF_SOCK_OPS_NEEDS_ECN) == 1);
 }
+
+#if IS_ENABLED(CONFIG_SMC)
+extern struct static_key_false tcp_have_smc;
+#endif
 #endif	/* _TCP_H */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3b34850d361f..e782e7d4088f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -270,6 +270,7 @@
 #include <linux/time.h>
 #include <linux/slab.h>
 #include <linux/errqueue.h>
+#include <linux/static_key.h>
 
 #include <net/icmp.h>
 #include <net/inet_common.h>
@@ -300,6 +301,11 @@ EXPORT_SYMBOL(sysctl_tcp_wmem);
 atomic_long_t tcp_memory_allocated;	/* Current allocated memory. */
 EXPORT_SYMBOL(tcp_memory_allocated);
 
+#if IS_ENABLED(CONFIG_SMC)
+DEFINE_STATIC_KEY_FALSE(tcp_have_smc);
+EXPORT_SYMBOL(tcp_have_smc);
+#endif
+
 /*
  * Current number of TCP sockets.
  */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d0682ce2a5d6..d507ab4ecc34 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -75,6 +75,7 @@
 #include <linux/ipsec.h>
 #include <asm/unaligned.h>
 #include <linux/errqueue.h>
+#include <linux/static_key.h>
 
 int sysctl_tcp_fack __read_mostly;
 int sysctl_tcp_max_reordering __read_mostly = 300;
@@ -3735,6 +3736,21 @@ static void tcp_parse_fastopen_option(int len, const unsigned char *cookie,
 	foc->exp = exp_opt;
 }
 
+static void smc_parse_options(const struct tcphdr *th,
+			      struct tcp_options_received *opt_rx,
+			      const unsigned char *ptr,
+			      int opsize)
+{
+#if IS_ENABLED(CONFIG_SMC)
+	if (static_branch_unlikely(&tcp_have_smc)) {
+		if (th->syn && !(opsize & 1) &&
+		    opsize >= TCPOLEN_EXP_SMC_BASE &&
+		    get_unaligned_be32(ptr) == TCPOPT_SMC_MAGIC)
+			opt_rx->smc_ok = 1;
+	}
+#endif
+}
+
 /* Look for tcp options. Normally only called on SYN and SYNACK packets.
  * But, this can also be called on packets in the established flow when
  * the fast version below fails.
@@ -3842,6 +3858,9 @@ void tcp_parse_options(const struct net *net,
 					tcp_parse_fastopen_option(opsize -
 						TCPOLEN_EXP_FASTOPEN_BASE,
 						ptr + 2, th->syn, foc, true);
+				else
+					smc_parse_options(th, opt_rx, ptr,
+							  opsize);
 				break;
 
 			}
@@ -5594,6 +5613,16 @@ static bool tcp_rcv_fastopen_synack(struct sock *sk, struct sk_buff *synack,
 	return false;
 }
 
+static void smc_check_reset_syn(struct tcp_sock *tp)
+{
+#if IS_ENABLED(CONFIG_SMC)
+	if (static_branch_unlikely(&tcp_have_smc)) {
+		if (tp->syn_smc && !tp->rx_opt.smc_ok)
+			tp->syn_smc = 0;
+	}
+#endif
+}
+
 static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 					 const struct tcphdr *th)
 {
@@ -5700,6 +5729,8 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 		 * is initialized. */
 		tp->copied_seq = tp->rcv_nxt;
 
+		smc_check_reset_syn(tp);
+
 		smp_mb();
 
 		tcp_finish_connect(sk, skb);
@@ -6152,6 +6183,9 @@ static void tcp_openreq_init(struct request_sock *req,
 	ireq->ir_rmt_port = tcp_hdr(skb)->source;
 	ireq->ir_num = ntohs(tcp_hdr(skb)->dest);
 	ireq->ir_mark = inet_request_mark(sk, skb);
+#if IS_ENABLED(CONFIG_SMC)
+	ireq->smc_ok = rx_opt->smc_ok;
+#endif
 }
 
 struct request_sock *inet_reqsk_alloc(const struct request_sock_ops *ops,
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 2341b9f857b6..edca83d4c9ec 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -23,6 +23,7 @@
 #include <linux/slab.h>
 #include <linux/sysctl.h>
 #include <linux/workqueue.h>
+#include <linux/static_key.h>
 #include <net/tcp.h>
 #include <net/inet_common.h>
 #include <net/xfrm.h>
@@ -417,6 +418,21 @@ void tcp_ca_openreq_child(struct sock *sk, const struct dst_entry *dst)
 }
 EXPORT_SYMBOL_GPL(tcp_ca_openreq_child);
 
+static void smc_check_reset_syn_req(struct tcp_sock *oldtp,
+				    struct request_sock *req,
+				    struct tcp_sock *newtp)
+{
+#if IS_ENABLED(CONFIG_SMC)
+	struct inet_request_sock *ireq;
+
+	if (static_branch_unlikely(&tcp_have_smc)) {
+		ireq = inet_rsk(req);
+		if (oldtp->syn_smc && !ireq->smc_ok)
+			newtp->syn_smc = 0;
+	}
+#endif
+}
+
 /* This is not only more efficient than what we used to do, it eliminates
  * a lot of code duplication between IPv4/IPv6 SYN recv processing. -DaveM
  *
@@ -434,6 +450,9 @@ struct sock *tcp_create_openreq_child(const struct sock *sk,
 		struct tcp_request_sock *treq = tcp_rsk(req);
 		struct inet_connection_sock *newicsk = inet_csk(newsk);
 		struct tcp_sock *newtp = tcp_sk(newsk);
+		struct tcp_sock *oldtp = tcp_sk(sk);
+
+		smc_check_reset_syn_req(oldtp, req, newtp);
 
 		/* Now setup tcp_sock */
 		newtp->pred_flags = 0;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 6c74f2a39778..29b3b4ae60fa 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -41,6 +41,7 @@
 #include <linux/compiler.h>
 #include <linux/gfp.h>
 #include <linux/module.h>
+#include <linux/static_key.h>
 
 #include <trace/events/tcp.h>
 
@@ -422,6 +423,22 @@ static inline bool tcp_urg_mode(const struct tcp_sock *tp)
 #define OPTION_MD5		(1 << 2)
 #define OPTION_WSCALE		(1 << 3)
 #define OPTION_FAST_OPEN_COOKIE	(1 << 8)
+#define OPTION_SMC		(1 << 9)
+
+static void smc_options_write(__be32 *ptr, u16 *options)
+{
+#if IS_ENABLED(CONFIG_SMC)
+	if (static_branch_unlikely(&tcp_have_smc)) {
+		if (unlikely(OPTION_SMC & *options)) {
+			*ptr++ = htonl((TCPOPT_NOP  << 24) |
+				       (TCPOPT_NOP  << 16) |
+				       (TCPOPT_EXP <<  8) |
+				       (TCPOLEN_EXP_SMC_BASE));
+			*ptr++ = htonl(TCPOPT_SMC_MAGIC);
+		}
+	}
+#endif
+}
 
 struct tcp_out_options {
 	u16 options;		/* bit field of OPTION_* */
@@ -540,6 +557,41 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 		}
 		ptr += (len + 3) >> 2;
 	}
+
+	smc_options_write(ptr, &options);
+}
+
+static void smc_set_option(const struct tcp_sock *tp,
+			   struct tcp_out_options *opts,
+			   unsigned int *remaining)
+{
+#if IS_ENABLED(CONFIG_SMC)
+	if (static_branch_unlikely(&tcp_have_smc)) {
+		if (tp->syn_smc) {
+			if (*remaining >= TCPOLEN_EXP_SMC_BASE_ALIGNED) {
+				opts->options |= OPTION_SMC;
+				*remaining -= TCPOLEN_EXP_SMC_BASE_ALIGNED;
+			}
+		}
+	}
+#endif
+}
+
+static void smc_set_option_cond(const struct tcp_sock *tp,
+				const struct inet_request_sock *ireq,
+				struct tcp_out_options *opts,
+				unsigned int *remaining)
+{
+#if IS_ENABLED(CONFIG_SMC)
+	if (static_branch_unlikely(&tcp_have_smc)) {
+		if (tp->syn_smc && ireq->smc_ok) {
+			if (*remaining >= TCPOLEN_EXP_SMC_BASE_ALIGNED) {
+				opts->options |= OPTION_SMC;
+				*remaining -= TCPOLEN_EXP_SMC_BASE_ALIGNED;
+			}
+		}
+	}
+#endif
 }
 
 /* Compute TCP options for SYN packets. This is not the final
@@ -607,11 +659,14 @@ static unsigned int tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 		}
 	}
 
+	smc_set_option(tp, opts, &remaining);
+
 	return MAX_TCP_OPTION_SPACE - remaining;
 }
 
 /* Set up TCP options for SYN-ACKs. */
-static unsigned int tcp_synack_options(struct request_sock *req,
+static unsigned int tcp_synack_options(const struct sock *sk,
+				       struct request_sock *req,
 				       unsigned int mss, struct sk_buff *skb,
 				       struct tcp_out_options *opts,
 				       const struct tcp_md5sig_key *md5,
@@ -667,6 +722,8 @@ static unsigned int tcp_synack_options(struct request_sock *req,
 		}
 	}
 
+	smc_set_option_cond(tcp_sk(sk), ireq, opts, &remaining);
+
 	return MAX_TCP_OPTION_SPACE - remaining;
 }
 
@@ -3193,8 +3250,8 @@ struct sk_buff *tcp_make_synack(const struct sock *sk, struct dst_entry *dst,
 	md5 = tcp_rsk(req)->af_specific->req_md5_lookup(sk, req_to_sk(req));
 #endif
 	skb_set_hash(skb, tcp_rsk(req)->txhash, PKT_HASH_TYPE_L4);
-	tcp_header_size = tcp_synack_options(req, mss, skb, &opts, md5, foc) +
-			  sizeof(*th);
+	tcp_header_size = tcp_synack_options(sk, req, mss, skb, &opts, md5,
+					     foc) + sizeof(*th);
 
 	skb_push(skb, tcp_header_size);
 	skb_reset_transport_header(skb);
-- 
2.13.5
