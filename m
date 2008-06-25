From: "Adam Langley" <agl@imperialviolet.org>
Subject: [RFC] Long options
Date: Tue, 24 Jun 2008 17:58:27 -0700
Message-ID: <396556a20805301217k293e5718h6bbf02bfe0683150@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.227]:42138 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752955AbYFYA6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 20:58:55 -0400
Received: by wr-out-0506.google.com with SMTP id 69so2378401wri.5
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2008 17:58:54 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Building on [1] and [2], this patch adds support for long options, mostly as
documented in [3]. I'm going to be taking over [3] and seeing if I can push it
through the IETF.

Speed tests. Transfering a 48M lump of 0 bytes over a TCP connection between
two KVM instances on the same 2.33GHz Core2. Results are the average of at
least three runs. Loss was introduced with netem one the sending KVM host.

Kernel		Env		Time(s)		Rate(MB/s)
----------------------------------------------------
net-2.6		MD5		3.26		15.4
net-2.6		MD5, 5% loss	(didn't complete within 5 mins)
net-2.6+[1]	MD5		3.56		14.1
net-2.6+[1]	MD5, 5% loss	23.30		2.1

Although [1] seems to be slower, we'll see in a sec that's actually because
the TS option is more valuable than SACK in this situation. Also, it manages in
the face of 5% loss which net-2.6 can't do at all.

net-2.6+[1]	MD5, TS		3.13		16.1

Normally, [1] disables TS for SACKs when using MD5. In this case, TS seems
more valuable. Just to make sure the [1] isn't slowing anything down, we test
with MD5 disabled:

net-2.6				2.73		18.4
net-2.6+[1]			2.75		18.3

(Which is well within the variance)

net-2.6+LO	MD5, 5% loss	22.46		2.2
net-2.6+LO	MD5+LO, 5% loss	26.85		1.9

Even though LO allows for more SACK blocks, it doesn't seem to help any. If
anything, in fact, it actually seems to make things slower. Maybe I've screwed
something up in this patch, or maybe the couple of SACK blocks that you can
still manage even without LO are sufficient for the vast majority of the time.
Sniffs suggest that only a very few packets are taking advantage of LO to
include more SACK blocks.

LO is largly for experimentation with options that don't fit in the options
space anyway, I was just wondering if it helped normal cases too. Another
possibly would be to use the SLO option to enable TS in the case of MD5+LO. The
timings above suggest that could help a lot, although I've not coded that up
yet.


[1] http://marc.info/?l=linux-netdev&m=121426260509452&w=2
[2] http://marc.info/?l=linux-netdev&m=121434882711824&w=2
[3] http://tools.ietf.org/html/draft-eddy-tcp-loo-03

---

 include/linux/tcp.h                |    8 +++
 include/net/inet_connection_sock.h |    1
 include/net/inet_sock.h            |    3 +
 include/net/tcp.h                  |   22 ++++++++
 net/dccp/dccp.h                    |    3 +
 net/dccp/ipv4.c                    |    3 +
 net/dccp/output.c                  |    2 -
 net/ipv4/Kconfig                   |   10 ++++
 net/ipv4/sysctl_net_ipv4.c         |   10 ++++
 net/ipv4/tcp_input.c               |   38 +++++++++++++-
 net/ipv4/tcp_ipv4.c                |   65 ++++++++++++++---------
 net/ipv4/tcp_minisocks.c           |    3 +
 net/ipv4/tcp_output.c              |  100 ++++++++++++++++++++++++++++++++----
 13 files changed, 222 insertions(+), 46 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 20f9e27..71ee86e 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -222,13 +222,19 @@ struct tcp_options_received {
 	u8	num_sacks;	/* Number of SACK blocks		*/
 	u16	user_mss;  	/* mss requested by user in ioctl */
 	u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
+#ifdef CONFIG_TCP_LONG_OPTIONS
+	u8 long_options : 1; /* Was a LO option seen?      */
+	u16 lo_header_length;   /* This contains the header length, in 4
+				   byte words for the current packet.
+				   This is valid in all cases */
+#endif
 };
 
 /* This is the max number of SACKS that we'll generate and process. It's safe
  * to increse this, although since:
  *   size = TCPOLEN_SACK_BASE_ALIGNED (4) + n * TCPOLEN_SACK_PERBLOCK (8)
  * only four options will fit in a standard TCP header */
-#define TCP_NUM_SACKS 4
+#define TCP_NUM_SACKS 8
 
 struct tcp_request_sock {
 	struct inet_request_sock 	req;
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 2ff545a..d6a287c 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -38,6 +38,7 @@ struct tcp_congestion_ops;
 struct inet_connection_sock_af_ops {
 	int	    (*queue_xmit)(struct sk_buff *skb, int ipfragok);
 	void	    (*send_check)(struct sock *sk, int len,
+				  int header_len,
 				  struct sk_buff *skb);
 	int	    (*rebuild_header)(struct sock *sk);
 	int	    (*conn_request)(struct sock *sk, struct sk_buff *skb);
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index a42cd63..a9d28ad 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -72,7 +72,8 @@ struct inet_request_sock {
 				sack_ok	   : 1,
 				wscale_ok  : 1,
 				ecn_ok	   : 1,
-				acked	   : 1;
+				acked	   : 1,
+				long_options : 1;
 	struct ip_options	*opt;
 };
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 9164d2f..1c3e21d 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -167,6 +167,10 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOPT_SACK             5       /* SACK Block */
 #define TCPOPT_TIMESTAMP	8	/* Better RTT estimations/PAWS */
 #define TCPOPT_MD5SIG		19	/* MD5 Signature (RFC2385) */
+/* These two are temporarily taking the experimental option numbers */
+#define TCPOPT_LONG_OPTS	253	/* Large options */
+#define TCPOPT_SYN_LONG_OPTS	254	/* Delayed SYN options */
+
 
 /*
  *     TCP option lengths
@@ -177,6 +181,8 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOLEN_SACK_PERM      2
 #define TCPOLEN_TIMESTAMP      10
 #define TCPOLEN_MD5SIG         18
+#define TCPOLEN_LONG_OPTS      4
+#define TCPOLEN_SYN_LONG_OPTS  4
 
 /* But this is what stacks really send out. */
 #define TCPOLEN_TSTAMP_ALIGNED		12
@@ -187,6 +193,8 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOLEN_SACK_PERBLOCK		8
 #define TCPOLEN_MD5SIG_ALIGNED		20
 #define TCPOLEN_MSS_ALIGNED		4
+#define TCPOLEN_LONG_OPTS_ALIGNED	4
+#define TCPOLEN_SYN_LONG_OPTS_ALIGNED	4
 
 /* Flags in tp->nonagle */
 #define TCP_NAGLE_OFF		1	/* Nagle's algo is disabled */
@@ -237,6 +245,9 @@ extern int sysctl_tcp_base_mss;
 extern int sysctl_tcp_workaround_signed_windows;
 extern int sysctl_tcp_slow_start_after_idle;
 extern int sysctl_tcp_max_ssthresh;
+#ifdef CONFIG_TCP_LONG_OPTIONS
+extern int sysctl_tcp_long_options;
+#endif
 
 extern atomic_t tcp_memory_allocated;
 extern atomic_t tcp_sockets_allocated;
@@ -335,7 +346,10 @@ extern void tcp_enter_quickack_mode(struct sock *sk);
 
 static inline void tcp_clear_options(struct tcp_options_received *rx_opt)
 {
- 	rx_opt->tstamp_ok = rx_opt->sack_ok = rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
+	rx_opt->tstamp_ok = rx_opt->sack_ok = rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
+#ifdef CONFIG_TCP_LONG_OPTIONS
+	rx_opt->long_options = 0;
+#endif
 }
 
 #define	TCP_ECN_OK		1
@@ -406,6 +420,7 @@ extern void			tcp_parse_options(struct sk_buff *skb,
  */
 
 extern void		       	tcp_v4_send_check(struct sock *sk, int len,
+						  int header_len,
 						  struct sk_buff *skb);
 
 extern int			tcp_v4_conn_request(struct sock *sk,
@@ -977,6 +992,9 @@ static inline void tcp_openreq_init(struct request_sock *req,
 	ireq->acked = 0;
 	ireq->ecn_ok = 0;
 	ireq->rmt_port = tcp_hdr(skb)->source;
+#ifdef CONFIG_TCP_LONG_OPTIONS
+	ireq->long_options = rx_opt->long_options;
+#endif
 }
 
 extern void tcp_enter_memory_pressure(void);
@@ -1123,6 +1141,7 @@ extern int			tcp_v4_calc_md5_hash(char *md5_hash,
 						     struct dst_entry *dst,
 						     struct request_sock *req,
 						     struct tcphdr *th,
+						     int header_len,
 						     int protocol,
 						     unsigned int tcplen);
 extern struct tcp_md5sig_key	*tcp_v4_md5_lookup(struct sock *sk,
@@ -1373,6 +1392,7 @@ struct tcp_sock_af_ops {
 						  struct dst_entry *dst,
 						  struct request_sock *req,
 						  struct tcphdr *th,
+						  int header_len,
 						  int protocol,
 						  unsigned int len);
 	int			(*md5_add) (struct sock *sk,
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index f44d492..5b16ee9 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -209,7 +209,8 @@ static inline void dccp_csum_outgoing(struct sk_buff *skb)
 	skb->csum = skb_checksum(skb, 0, (cov > skb->len)? skb->len : cov, 0);
 }
 
-extern void dccp_v4_send_check(struct sock *sk, int len, struct sk_buff *skb);
+extern void dccp_v4_send_check(struct sock *sk, int len, int hlen,
+			       struct sk_buff *skb);
 
 extern int  dccp_retransmit_skb(struct sock *sk, struct sk_buff *skb);
 
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index c22a378..6b85eee 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -344,7 +344,8 @@ static inline __sum16 dccp_v4_csum_finish(struct sk_buff *skb,
 	return csum_tcpudp_magic(src, dst, skb->len, IPPROTO_DCCP, skb->csum);
 }
 
-void dccp_v4_send_check(struct sock *sk, int unused, struct sk_buff *skb)
+void dccp_v4_send_check(struct sock *sk, int unused, int hlen,
+			struct sk_buff *skb)
 {
 	const struct inet_sock *inet = inet_sk(sk);
 	struct dccp_hdr *dh = dccp_hdr(skb);
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 1f8a9b6..718db34 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -119,7 +119,7 @@ static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 			break;
 		}
 
-		icsk->icsk_af_ops->send_check(sk, 0, skb);
+		icsk->icsk_af_ops->send_check(sk, 0, 0, skb);
 
 		if (set_ack)
 			dccp_event_ack_sent(sk);
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 4670683..016ea1d 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -632,5 +632,15 @@ config TCP_MD5SIG
 
 	  If unsure, say N.
 
+config TCP_LONG_OPTIONS
+	  bool "TCP: Long options support (EXPERIMENTAL)"
+	  depends on EXPERIMENTAL
+	  ---help---
+	    This enables support for oversized TCP options, as detailed in
+	    draft-eddy-tcp-loo-03. Long options might be required for future TCP
+	    extensions and currently allow for additional SACK blocks (which is
+	    known to be helpful). Also, for MD5 signed packets, very few SACK
+	    blocks can be included without this.
+
 source "net/ipv4/ipvs/Kconfig"
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index c437f80..1ecfbff 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -753,6 +753,16 @@ static struct ctl_table ipv4_table[] = {
 		.strategy	= &sysctl_intvec,
 		.extra1		= &zero
 	},
+#ifdef CONFIG_TCP_LONG_OPTIONS
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "tcp_long_options",
+		.data		= &sysctl_tcp_long_options,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+#endif
 	{ .ctl_name = 0 }
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 6aff2fd..a607d99 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3329,6 +3329,10 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 	struct tcphdr *th = tcp_hdr(skb);
 	int length = (th->doff * 4) - sizeof(struct tcphdr);
 
+#ifdef CONFIG_TCP_LONG_OPTIONS
+	opt_rx->lo_header_length = th->doff;
+#endif
+
 	ptr = (unsigned char *)(th + 1);
 	opt_rx->saw_tstamp = 0;
 
@@ -3407,6 +3411,26 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 				 */
 				break;
 #endif
+#ifdef CONFIG_TCP_LONG_OPTIONS
+			case TCPOPT_LONG_OPTS:
+				if (opsize == TCPOLEN_LONG_OPTS) {
+					u16 a = get_unaligned_be16(ptr);
+					if (a >= th->doff &&
+					    a << 2 <= skb->len) {
+						int delta = (a - th->doff) << 2;
+						length += delta;
+						TCP_SKB_CB(skb)->end_seq =
+							TCP_SKB_CB(skb)->seq +
+							th->syn +
+							th->fin +
+							skb->len -
+							a * 4;
+						opt_rx->long_options = 1;
+						opt_rx->lo_header_length = a;
+					}
+				}
+				break;
+#endif
 			}
 
 			ptr += opsize-2;
@@ -3421,6 +3445,9 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 static int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *th,
 				  struct tcp_sock *tp)
 {
+#ifdef CONFIG_TCP_LONG_OPTIONS
+	tp->rx_opt.lo_header_length = th->doff;
+#endif
 	if (th->doff == sizeof(struct tcphdr) >> 2) {
 		tp->rx_opt.saw_tstamp = 0;
 		return 0;
@@ -3892,7 +3919,11 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 	if (TCP_SKB_CB(skb)->seq == TCP_SKB_CB(skb)->end_seq)
 		goto drop;
 
+#ifdef CONFIG_TCP_LONG_OPTIONS
+	__skb_pull(skb, tp->rx_opt.lo_header_length * 4);
+#else
 	__skb_pull(skb, th->doff * 4);
+#endif
 
 	TCP_ECN_accept_cwr(tp, skb);
 
@@ -4512,7 +4543,12 @@ static void tcp_urg(struct sock *sk, struct sk_buff *skb, struct tcphdr *th)
 
 	/* Do we wait for any urgent data? - normally not... */
 	if (tp->urg_data == TCP_URG_NOTYET) {
-		u32 ptr = tp->urg_seq - ntohl(th->seq) + (th->doff * 4) -
+#ifdef CONFIG_TCP_LONG_OPTIONS
+		const u32 data_off = tp->rx_opt.lo_header_length * 4;
+#else
+		const u32 data_off = th->doff * 4;
+#endif
+		u32 ptr = tp->urg_seq - ntohl(th->seq) + data_off -
 			  th->syn;
 
 		/* Is the urgent pointer pointing into this packet? */
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index cd601a8..8c8bf88 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -81,6 +81,7 @@
 
 #include <linux/crypto.h>
 #include <linux/scatterlist.h>
+#include <asm/unaligned.h>
 
 int sysctl_tcp_tw_reuse __read_mostly;
 int sysctl_tcp_low_latency __read_mostly;
@@ -88,15 +89,16 @@ int sysctl_tcp_low_latency __read_mostly;
 /* Check TCP sequence numbers in ICMP packets. */
 #define ICMP_MIN_LENGTH 8
 
-void tcp_v4_send_check(struct sock *sk, int len, struct sk_buff *skb);
+void tcp_v4_send_check(struct sock *sk, int len, int hlen,
+		       struct sk_buff *skb);
 
 #ifdef CONFIG_TCP_MD5SIG
 static struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk,
 						   __be32 addr);
 static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				   __be32 saddr, __be32 daddr,
-				   struct tcphdr *th, int protocol,
-				   unsigned int tcplen);
+				   struct tcphdr *th, int header_len,
+				   int protocol, unsigned int tcplen);
 #endif
 
 struct inet_hashinfo __cacheline_aligned tcp_hashinfo = {
@@ -481,7 +483,8 @@ out:
 }
 
 /* This routine computes an IPv4 TCP checksum. */
-void tcp_v4_send_check(struct sock *sk, int len, struct sk_buff *skb)
+void tcp_v4_send_check(struct sock *sk, int len, int header_len,
+		       struct sk_buff *skb)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct tcphdr *th = tcp_hdr(skb);
@@ -494,7 +497,7 @@ void tcp_v4_send_check(struct sock *sk, int len, struct sk_buff *skb)
 	} else {
 		th->check = tcp_v4_check(len, inet->saddr, inet->daddr,
 					 csum_partial((char *)th,
-						      th->doff << 2,
+						      header_len,
 						      skb->csum));
 	}
 }
@@ -586,8 +589,8 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 					key,
 					ip_hdr(skb)->daddr,
 					ip_hdr(skb)->saddr,
-					&rep.th, IPPROTO_TCP,
-					arg.iov[0].iov_len);
+					&rep.th, rep.th.doff << 2,
+					IPPROTO_TCP, arg.iov[0].iov_len);
 	}
 #endif
 	arg.csum = csum_tcpudp_nofold(ip_hdr(skb)->daddr,
@@ -680,8 +683,8 @@ static void tcp_v4_send_ack(struct tcp_timewait_sock *twsk,
 					key,
 					ip_hdr(skb)->daddr,
 					ip_hdr(skb)->saddr,
-					&rep.th, IPPROTO_TCP,
-					arg.iov[0].iov_len);
+					&rep.th, rep.th.doff << 2,
+					IPPROTO_TCP, arg.iov[0].iov_len);
 	}
 #endif
 	arg.csum = csum_tcpudp_nofold(ip_hdr(skb)->daddr,
@@ -1006,8 +1009,8 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
 
 static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				   __be32 saddr, __be32 daddr,
-				   struct tcphdr *th, int protocol,
-				   unsigned int tcplen)
+				   struct tcphdr *th, int header_len,
+				   int protocol, unsigned int tcplen)
 {
 	struct scatterlist sg[4];
 	__u16 data_len;
@@ -1056,9 +1059,9 @@ static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	nbytes += sizeof(struct tcphdr);
 
 	/* 3. the TCP segment data (if any) */
-	data_len = tcplen - (th->doff << 2);
+	data_len = tcplen - header_len;
 	if (data_len > 0) {
-		unsigned char *data = (unsigned char *)th + (th->doff << 2);
+		unsigned char *data = (unsigned char *)th + header_len;
 		sg_set_buf(&sg[block++], data, data_len);
 		nbytes += data_len;
 	}
@@ -1099,7 +1102,9 @@ int tcp_v4_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 			 struct sock *sk,
 			 struct dst_entry *dst,
 			 struct request_sock *req,
-			 struct tcphdr *th, int protocol,
+			 struct tcphdr *th,
+			 int header_len,
+			 int protocol,
 			 unsigned int tcplen)
 {
 	__be32 saddr, daddr;
@@ -1115,7 +1120,8 @@ int tcp_v4_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	}
 	return tcp_v4_do_calc_md5_hash(md5_hash, key,
 				       saddr, daddr,
-				       th, protocol, tcplen);
+				       th, header_len,
+				       protocol, tcplen);
 }
 
 EXPORT_SYMBOL(tcp_v4_calc_md5_hash);
@@ -1135,22 +1141,14 @@ static int tcp_v4_inbound_md5_hash(struct sock *sk, struct sk_buff *skb)
 	const struct iphdr *iph = ip_hdr(skb);
 	struct tcphdr *th = tcp_hdr(skb);
 	int length = (th->doff << 2) - sizeof(struct tcphdr);
+	unsigned header_len = th->doff << 2;
 	int genhash;
 	unsigned char *ptr;
 	unsigned char newhash[16];
 
 	hash_expected = tcp_v4_md5_do_lookup(sk, iph->saddr);
 
-	/*
-	 * If the TCP option length is less than the TCP_MD5SIG
-	 * option length, then we can shortcut
-	 */
-	if (length < TCPOLEN_MD5SIG) {
-		if (hash_expected)
-			return 1;
-		else
-			return 0;
-	}
+	if (!hash_expected) return 0;
 
 	/* Okay, we can't shortcut - we have to grub through the options */
 	ptr = (unsigned char *)(th + 1);
@@ -1175,6 +1173,19 @@ static int tcp_v4_inbound_md5_hash(struct sock *sk, struct sk_buff *skb)
 				hash_location = ptr;
 				goto done_opts;
 			}
+#ifdef CONFIG_TCP_LONG_OPTIONS
+			else if (opcode == TCPOPT_LONG_OPTS) {
+				if (opsize == TCPOLEN_LONG_OPTS) {
+					const u16 a = get_unaligned_be16(ptr);
+					if (a >= th->doff &&
+					    a << 2 <= skb->len) {
+						int delta = (a - th->doff) << 2;
+						length += delta;
+						header_len += delta;
+					}
+				}
+			}
+#endif
 		}
 		ptr += opsize-2;
 		length -= opsize;
@@ -1206,8 +1217,8 @@ done_opts:
 	genhash = tcp_v4_do_calc_md5_hash(newhash,
 					  hash_expected,
 					  iph->saddr, iph->daddr,
-					  th, sk->sk_protocol,
-					  skb->len);
+					  th, header_len,
+					  sk->sk_protocol, skb->len);
 
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
 		if (net_ratelimit()) {
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 019c8c1..8948674 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -445,6 +445,9 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 						       keepalive_time_when(newtp));
 
 		newtp->rx_opt.tstamp_ok = ireq->tstamp_ok;
+#ifdef CONFIG_TCP_LONG_OPTIONS
+		newtp->rx_opt.long_options = ireq->long_options;
+#endif
 		if ((newtp->rx_opt.sack_ok = ireq->sack_ok) != 0) {
 			if (sysctl_tcp_fack)
 				tcp_enable_fack(newtp);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7ada03d..fe79126 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -58,6 +58,10 @@ int sysctl_tcp_tso_win_divisor __read_mostly = 3;
 int sysctl_tcp_mtu_probing __read_mostly = 0;
 int sysctl_tcp_base_mss __read_mostly = 512;
 
+#ifdef CONFIG_TCP_LONG_OPTIONS
+int sysctl_tcp_long_options __read_mostly = 1;
+#endif
+
 /* By default, RFC2861 behavior.  */
 int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
 
@@ -352,6 +356,12 @@ static void tcp_init_nondata_skb(struct sk_buff *skb, u32 seq, u8 flags)
 #define OPTION_MD5		(1 << 2)
 
 struct tcp_out_options {
+#ifdef CONFIG_TCP_LONG_OPTIONS
+	unsigned long_size;		/* LO options. 0 to disable */
+	struct tcp_out_options *slo;	/* If non-NULL, include these options */
+					/* in an SLO header */
+	unsigned slo_size;		/* The number of bytes of SLO option */
+#endif
 	unsigned options;		/* bit field of OPTION_* */
 	unsigned mss;			/* 0 to disable */
 	unsigned ws;			/* window scale, 0 to disable */
@@ -362,6 +372,22 @@ struct tcp_out_options {
 static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 			      const struct tcp_out_options *opts,
 			      __u8 **md5_hash) {
+#ifdef CONFIG_TCP_LONG_OPTIONS
+	if (unlikely(opts->long_size)) {
+		*ptr++ = htonl((TCPOPT_LONG_OPTS << 24) |
+			       (TCPOLEN_LONG_OPTS << 16) |
+			       opts->long_size);
+	}
+
+	if (unlikely(opts->slo)) {
+		*ptr++ = htonl((TCPOPT_SYN_LONG_OPTS << 24) |
+			       (TCPOLEN_SYN_LONG_OPTS << 16) |
+			       opts->slo_size);
+		tcp_options_write(ptr, tp, opts->slo, NULL);
+		ptr += opts->slo_size >> 2;
+	}
+#endif
+
 	if (unlikely(OPTION_MD5 & opts->options)) {
 		*ptr++ = htonl((TCPOPT_NOP << 24) |
 			       (TCPOPT_NOP << 16) |
@@ -477,6 +503,16 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 			size += TCPOLEN_SACKPERM_ALIGNED;
 	}
 
+#ifdef CONFIG_TCP_LONG_OPTIONS
+	/* It's possible, if all the the above options are enabled, that we
+	 * don't have enough space for the LO option */
+	if (likely(sysctl_tcp_long_options &&
+		   MAX_TCP_OPTION_SPACE - size >= TCPOLEN_LONG_OPTS_ALIGNED)) {
+		size += TCPOLEN_LONG_OPTS_ALIGNED;
+		opts->long_size = (sizeof(struct tcphdr) + size) >> 2;
+	}
+#endif
+
 	return size;
 }
 
@@ -524,6 +560,13 @@ static unsigned tcp_synack_options(struct sock *sk,
 			size += TCPOLEN_SACKPERM_ALIGNED;
 	}
 
+#ifdef CONFIG_TCP_LONG_OPTIONS
+	if (unlikely(ireq->long_options)) {
+		size += TCPOLEN_LONG_OPTS_ALIGNED;
+		opts->long_size = (sizeof(struct tcphdr) + size) >> 2;
+	}
+#endif
+
 	return size;
 }
 
@@ -552,18 +595,49 @@ static unsigned tcp_established_options(struct sock *sk, struct sk_buff *skb,
 	}
 
 	if (unlikely(tp->rx_opt.eff_sacks)) {
-		const unsigned remaining = MAX_TCP_OPTION_SPACE - size;
-		opts->num_sack_blocks =
-			min_t(unsigned, tp->rx_opt.eff_sacks,
-			      (remaining - TCPOLEN_SACK_BASE_ALIGNED) /
-			      TCPOLEN_SACK_PERBLOCK);
-		size += TCPOLEN_SACK_BASE_ALIGNED +
-			opts->num_sack_blocks * TCPOLEN_SACK_PERBLOCK;
+#ifdef CONFIG_TCP_LONG_OPTIONS
+		if (unlikely(tp->rx_opt.long_options)) {
+			opts->num_sack_blocks = tp->rx_opt.eff_sacks;
+			size += TCPOLEN_SACK_BASE_ALIGNED +
+				opts->num_sack_blocks * TCPOLEN_SACK_PERBLOCK;
+			if (unlikely(size > MAX_TCP_OPTION_SPACE)) {
+				size += TCPOLEN_LONG_OPTS_ALIGNED;
+				opts->long_size =
+					(sizeof(struct tcphdr) + size) >> 2;
+			}
+		} else {
+#endif
+			const unsigned remaining = MAX_TCP_OPTION_SPACE - size;
+			opts->num_sack_blocks =
+				min_t(unsigned, tp->rx_opt.eff_sacks,
+				      (remaining - TCPOLEN_SACK_BASE_ALIGNED) /
+				      TCPOLEN_SACK_PERBLOCK);
+			size += TCPOLEN_SACK_BASE_ALIGNED +
+				opts->num_sack_blocks * TCPOLEN_SACK_PERBLOCK;
+#ifdef CONFIG_TCP_LONG_OPTIONS
+		}
+#endif
 	}
 
 	return size;
 }
 
+/**
+ * tcp_doff_value: return the correct TCP DO value
+ * @header_size: the size of the full header, possibly exceeding 60 bytes
+ *
+ * When long options are enabled, and we have a header > 60 bytes in length
+ * (which is the max that can be represented using the TCP DO field) we set the
+ * DO field to 6 (== 24 bytes) which is enough to cover the struct tcphdr and
+ * the first four bytes of the options, which is the LO option
+ */
+static unsigned tcp_doff_value(unsigned header_size)
+{
+	if (header_size <= 60)
+		return header_size >> 2;
+	return 6;
+}
+
 /* This routine actually transmits TCP packets queued in by
  * tcp_do_sendmsg().  This is used by both the initial
  * transmission and possible later retransmissions.
@@ -630,7 +704,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	th->dest		= inet->dport;
 	th->seq			= htonl(tcb->seq);
 	th->ack_seq		= htonl(tp->rcv_nxt);
-	*(((__be16 *)th) + 6)	= htons(((tcp_header_size >> 2) << 12) |
+	*(((__be16 *)th) + 6)	= htons((tcp_doff_value(tcp_header_size) << 12)|
 					tcb->flags);
 
 	if (unlikely(tcb->flags & TCPCB_FLAG_SYN)) {
@@ -661,12 +735,13 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 					       md5,
 					       sk, NULL, NULL,
 					       tcp_hdr(skb),
+					       tcp_header_size,
 					       sk->sk_protocol,
 					       skb->len);
 	}
 #endif
 
-	icsk->icsk_af_ops->send_check(sk, skb->len, skb);
+	icsk->icsk_af_ops->send_check(sk, skb->len, tcp_header_size, skb);
 
 	if (likely(tcb->flags & TCPCB_FLAG_ACK))
 		tcp_event_ack_sent(sk, tcp_skb_pcount(skb));
@@ -2293,7 +2368,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	else
 #endif
 	tcp_options_write((__be32 *)(th + 1), tp, &opts, &md5_hash_location);
-	th->doff = (tcp_header_size >> 2);
+	th->doff = tcp_doff_value(tcp_header_size);
 	TCP_INC_STATS(TCP_MIB_OUTSEGS);
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -2302,8 +2377,9 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 		tp->af_specific->calc_md5_hash(md5_hash_location,
 					       md5,
 					       NULL, dst, req,
-					       tcp_hdr(skb), sk->sk_protocol,
-					       skb->len);
+					       tcp_hdr(skb),
+					       tcp_header_size,
+					       sk->sk_protocol, skb->len);
 	}
 #endif
 
