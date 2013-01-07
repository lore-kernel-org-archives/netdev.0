From: elelueck@linux.vnet.ibm.com
Subject: [RFC PATCH V2] tcp: introduce raw access to experimental options
Date: Mon,  7 Jan 2013 17:13:30 +0100
Message-ID: <1357575210-52926-2-git-send-email-elelueck@linux.vnet.ibm.com>
References: <1357575210-52926-1-git-send-email-elelueck@linux.vnet.ibm.com>
Cc: Einar Lueck <elelueck@linux.vnet.ibm.com>, davem@davemloft.net,
	ubacher@de.ibm.com, raspl@de.ibm.com, frankbla@de.ibm.com,
	samudrala@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:42694 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753824Ab3AGQOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 11:14:08 -0500
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <elelueck@linux.vnet.ibm.com>;
	Mon, 7 Jan 2013 16:13:13 -0000
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r07GDtCU46071858
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2013 16:13:55 GMT
Received: from d06av05.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r07GE3QP027317
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2013 09:14:03 -0700
In-Reply-To: <1357575210-52926-1-git-send-email-elelueck@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Einar Lueck <elelueck@linux.vnet.ibm.com>

This patch adds means for raw acces to TCP expirimental options
253 and 254. The intention of this is to enable user space
applications to implement communication behaviour that depends
on experimental options. For that, new (set|get)sockopts are
introduced:

TCP_EXPOPTS (get & set): TCP experimental options to be added to
			 packets
TCP_RECV_EXPOPTS (get):  experimental options received with last
			 packet
TCP_RECV_SYN_EXPOPTS (get): experimental options received with
			 SYN packet

Access to these options is allowed only with CAP_NET_RAW privilige.

TCP experimental options 253 and 254 configured via TCP_EXPOPTS on
any TCP socket are appended to every packet that is sent as long
as there is enough room left. If there is not enough room left they
are silently dropped.

Listening sockets reply to SYN packets with SYN ACK packets containing
TCP experimental options 253 and 254 as configured via TCP_EXPOPTS, too.
If a TCP connection gets established the configured experimental options
are the defaults for the new socket, too. Thus, a getsockopt on the
resulting accept socket for TCP_EXPOPTS returns the same stuff configured
on the listening socket.

As mentioned above, even after the 3whs is complete, experimental options
are sent with every packet. To enable user space applications to distinguish
between what has been advertized via SYN and what has been received with the
last packet the aforementioned TCP_RECV_SYN_EXPOPTS and TCP_RECV_EXPOPTS are
introduced.

Today, experimental option 253 (COOKIE) and 254 (FASTOPEN) are already
exploited. For co-existence the following approach has been taken:

General remarks:
* Interface to COOKIE and FASTOPEN stays the same
Sender side:
1. COOKIE and FASTPATH code adds own options first (if applicable)
2. Finally, if enough room is left, TCP_EXPOPTS experimental options are
   appended
Receiver side:
1. ALL 253 and 254 experimental options are made available via
   TCP_RECV(_SYN)_EXPOPTS
2. COOKIE and FASTOPEN code check if there is any option relevant for them

References:
http://tools.ietf.org/html/draft-ietf-tcpm-experimental-options-02

Signed-off-by: Einar Lueck <elelueck@linux.vnet.ibm.com>
---
 include/linux/tcp.h      |  23 +++++++++
 include/net/tcp.h        |   3 ++
 include/uapi/linux/tcp.h |   3 ++
 net/ipv4/tcp.c           | 122 +++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_input.c     | 119 ++++++++++++++++++++++++++++++---------------
 net/ipv4/tcp_ipv4.c      |  14 ++++++
 net/ipv4/tcp_minisocks.c |  17 +++++++
 net/ipv4/tcp_output.c    |  47 +++++++++++-------
 8 files changed, 293 insertions(+), 55 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 60b7aac..574c26f 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -67,6 +67,8 @@ struct tcp_sack_block {
 #define TCP_FACK_ENABLED  (1 << 1)   /*1 = FACK is enabled locally*/
 #define TCP_DSACK_SEEN    (1 << 2)   /*1 = DSACK was received from peer*/
 
+#define TCP_EXPOP_MAXLEN 40
+
 struct tcp_options_received {
 /*	PAWS/RTTM data	*/
 	long	ts_recent_stamp;/* Time we stored ts_recent (for aging) */
@@ -86,6 +88,9 @@ struct tcp_options_received {
 	u8	num_sacks;	/* Number of SACK blocks		*/
 	u16	user_mss;	/* mss requested by user in ioctl	*/
 	u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
+	u8	exp_opts_len;	/* length of buffer containing all exp
+				 * options in format: kind length data */
+	u8	exp_opts[TCP_EXPOP_MAXLEN];	/* experimental options */
 };
 
 static inline void tcp_clear_options(struct tcp_options_received *rx_opt)
@@ -93,6 +98,7 @@ static inline void tcp_clear_options(struct tcp_options_received *rx_opt)
 	rx_opt->tstamp_ok = rx_opt->sack_ok = 0;
 	rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
 	rx_opt->cookie_plus = 0;
+	rx_opt->exp_opts_len = 0;
 }
 
 /* This is the max number of SACKS that we'll generate and process. It's safe
@@ -118,6 +124,11 @@ struct tcp_request_sock {
 						  * FastOpen it's the seq#
 						  * after data-in-SYN.
 						  */
+	u8				syn_expopts[TCP_EXPOP_MAXLEN];
+						/* experimental options
+						 * received with SYNACK */
+	u8				syn_expopts_len;
+
 };
 
 static inline struct tcp_request_sock *tcp_rsk(const struct request_sock *req)
@@ -210,6 +221,18 @@ struct tcp_sock {
 	u32	snd_up;		/* Urgent pointer		*/
 
 	u8	keepalive_probes; /* num of allowed keep alive probes	*/
+
+/* for raw acces to experimental options */
+	struct {
+		u8 *conf;	/* lazy allocation of TCP_EXPOP_MAXLEN bytes
+				 * for raw access to experimental options */
+		u8 conf_len;	/* bytes actually used for experimental opts */
+		u8 *syn;	/* experimental options received with SYN,
+				 * allocated only if received */
+		u8 syn_len;	/* bytes of experimental options actually
+				 * received with SYN */
+	} exp_opts;
+
 /*
  *      Options received (usually on last packet, some only on SYN packets).
  */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 4af45e3..8e0740c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -180,6 +180,8 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOPT_TIMESTAMP	8	/* Better RTT estimations/PAWS */
 #define TCPOPT_MD5SIG		19	/* MD5 Signature (RFC2385) */
 #define TCPOPT_COOKIE		253	/* Cookie extension (experimental) */
+#define TCPOPT_EXP253		253	/* TCP experimental option 253 */
+#define TCPOPT_EXP254		254	/* TCP experimental option 254 */
 #define TCPOPT_EXP		254	/* Experimental */
 /* Magic number to be after the option value for sharing TCP
  * experimental options. See draft-ietf-tcpm-experimental-options-00.txt
@@ -190,6 +192,7 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
  *     TCP option lengths
  */
 
+#define TCPOLEN_MAX_ANYEXP     40
 #define TCPOLEN_MSS            4
 #define TCPOLEN_WINDOW         3
 #define TCPOLEN_SACK_PERM      2
diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index e962faa..a6554d1 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -111,6 +111,9 @@ enum {
 #define TCP_QUEUE_SEQ		21
 #define TCP_REPAIR_OPTIONS	22
 #define TCP_FASTOPEN		23	/* Enable FastOpen on listeners */
+#define TCP_EXPOPTS		24	/* TCP exp. options (configured) */
+#define TCP_RECV_EXPOPTS	25	/* TCP exp. options (received) */
+#define TCP_RECV_SYN_EXPOPTS	26	/* TCP exp. options (rec. with syn)) */
 
 struct tcp_repair_opt {
 	__u32	opt_code;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index e457c7a..437c22e 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -423,6 +423,12 @@ void tcp_init_sock(struct sock *sk)
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
+	/* memory for raw access to experimental options is allocated lazy */
+	tp->exp_opts.conf = NULL;
+	tp->exp_opts.conf_len = 0;
+	tp->exp_opts.syn = NULL;
+	tp->exp_opts.syn_len = 0;
+
 	local_bh_disable();
 	sock_update_memcg(sk);
 	sk_sockets_allocated_inc(sk);
@@ -2366,6 +2372,56 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 
 	/* These are data/string values, all the others are ints */
 	switch (optname) {
+	case TCP_EXPOPTS: {
+		u8 conf[TCP_EXPOP_MAXLEN];
+
+		if (!capable(CAP_NET_RAW))
+			return -EACCES;
+
+		if (optlen > TCP_EXPOP_MAXLEN || (optlen < 4 && optlen > 0) ||
+		    (optlen % 4 > 0))
+			return -EINVAL;
+		if (optlen > 0 && !optval)
+			return -EINVAL;
+
+		/* filter for raw access to supported options */
+		if (optlen) {
+			u8 i;
+
+			if (copy_from_user(conf, optval, optlen))
+				return -EFAULT;
+
+			i = 0;
+			while (i < optlen) {
+				if (conf[i] != TCPOPT_EXP253 &&
+				    conf[i] != TCPOPT_EXP254)
+					return -EINVAL;
+
+				if (i + 1 < optlen) {
+					i += conf[i+1];
+					if (i > optlen)
+						return -EINVAL;
+				} else {
+					return -EINVAL;
+				}
+			}
+		}
+
+		lock_sock(sk);
+		if (!optlen) {
+			tp->exp_opts.conf_len = 0;
+			release_sock(sk);
+			return 0;
+		}
+		if (!tp->exp_opts.conf) {
+			tp->exp_opts.conf = kzalloc(TCP_EXPOP_MAXLEN,
+						    sk->sk_allocation);
+		}
+		memcpy(tp->exp_opts.conf, conf, optlen);
+		tp->exp_opts.conf_len = optlen;
+		release_sock(sk);
+		return err;
+	}
 	case TCP_CONGESTION: {
 		char name[TCP_CA_NAME_MAX];
 
@@ -2947,6 +3003,72 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 	case TCP_USER_TIMEOUT:
 		val = jiffies_to_msecs(icsk->icsk_user_timeout);
 		break;
+	case TCP_EXPOPTS: {
+		u8 exp_opts_len;
+
+		if (!capable(CAP_NET_RAW))
+			return -EACCES;
+
+		if (get_user(len, optlen))
+			return -EFAULT;
+		if (len < 0)
+			return -EINVAL;
+
+		exp_opts_len = tp->exp_opts.conf_len;
+
+		if (exp_opts_len > len)
+			return -EINVAL;
+		if (put_user(exp_opts_len, optlen))
+			return -EFAULT;
+		if (exp_opts_len && copy_to_user(optval, tp->exp_opts.conf,
+						 exp_opts_len))
+			return -EFAULT;
+		return 0;
+	}
+	case TCP_RECV_EXPOPTS:
+		if (!capable(CAP_NET_RAW))
+			return -EACCES;
+
+		if (get_user(len, optlen))
+			return -EFAULT;
+		if (len < 0)
+			return -EINVAL;
+
+		if (len < tp->rx_opt.exp_opts_len)
+			return -EINVAL;
+
+		if (put_user(tp->rx_opt.exp_opts_len, optlen))
+			return -EFAULT;
+		if (copy_to_user(optval, tp->rx_opt.exp_opts,
+				 tp->rx_opt.exp_opts_len))
+			return -EFAULT;
+		return 0;
+	case TCP_RECV_SYN_EXPOPTS: {
+		u8 exp_opts_len;
+
+		if (!capable(CAP_NET_RAW))
+			return -EACCES;
+
+		if (get_user(len, optlen))
+			return -EFAULT;
+		if (len < 0)
+			return -EINVAL;
+
+		if (!tp->exp_opts.syn)
+			exp_opts_len = 0;
+		else
+			exp_opts_len = tp->exp_opts.syn_len;
+
+		if (exp_opts_len > len)
+			return -EINVAL;
+		if (put_user(exp_opts_len, optlen))
+			return -EFAULT;
+		if (exp_opts_len && copy_to_user(optval, tp->exp_opts.syn,
+						 exp_opts_len)) {
+			return -EFAULT;
+		}
+		return 0;
+	}
 	default:
 		return -ENOPROTOOPT;
 	}
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 181fc82..ab9c88b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3699,11 +3699,32 @@ old_ack:
 	return 0;
 }
 
+static inline void tcp_parse_fastopen_cookie(int opcode,
+		int opsize,
+		const unsigned char *ptr,
+		struct tcp_fastopen_cookie *foc,
+		const struct tcphdr *th) {
+	/* Fast Open option shares code 254 using a 16 bits magic number. It's
+	 * valid only in SYN or SYN-ACK with an even size.
+	 */
+	if (opsize < TCPOLEN_EXP_FASTOPEN_BASE ||
+	    get_unaligned_be16(ptr) != TCPOPT_FASTOPEN_MAGIC || foc == NULL ||
+	    !th->syn || (opsize & 1))
+		return;
+	foc->len = opsize - TCPOLEN_EXP_FASTOPEN_BASE;
+	if (foc->len >= TCP_FASTOPEN_COOKIE_MIN &&
+	    foc->len <= TCP_FASTOPEN_COOKIE_MAX)
+		memcpy(foc->val, ptr + 2, foc->len);
+	else if (foc->len != 0)
+		foc->len = -1;
+}
+
 /* Look for tcp options. Normally only called on SYN and SYNACK packets.
  * But, this can also be called on packets in the established flow when
  * the fast version below fails.
  */
-void tcp_parse_options(const struct sk_buff *skb, struct tcp_options_received *opt_rx,
+void tcp_parse_options(const struct sk_buff *skb,
+		       struct tcp_options_received *opt_rx,
 		       const u8 **hvpp, int estab,
 		       struct tcp_fastopen_cookie *foc)
 {
@@ -3713,6 +3734,7 @@ void tcp_parse_options(const struct sk_buff *skb, struct tcp_options_received *o
 
 	ptr = (const unsigned char *)(th + 1);
 	opt_rx->saw_tstamp = 0;
+	opt_rx->exp_opts_len = 0;
 
 	while (length > 0) {
 		int opcode = *ptr++;
@@ -3788,48 +3810,56 @@ void tcp_parse_options(const struct sk_buff *skb, struct tcp_options_received *o
 				 */
 				break;
 #endif
-			case TCPOPT_COOKIE:
-				/* This option is variable length.
+			case TCPOPT_EXP253:
+			case TCPOPT_EXP254:
+				/* First parse options into raw access area for
+				 * experimental options. Then handle
+				 * potential exploitations
 				 */
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
+				if (opsize <= TCPOLEN_MAX_ANYEXP &&
+				    opsize >= 2 &&
+				    (opt_rx->exp_opts_len + opsize <=
+				     TCPOLEN_MAX_ANYEXP)) {
+					opt_rx->exp_opts[
+						opt_rx->exp_opts_len] = opcode;
+					opt_rx->exp_opts[
+						opt_rx->exp_opts_len + 1] =
+						opsize;
+					memcpy(opt_rx->exp_opts +
+						opt_rx->exp_opts_len + 2, ptr,
+						opsize - 2);
+					opt_rx->exp_opts_len += opsize;
 				}
-				break;
 
-			case TCPOPT_EXP:
-				/* Fast Open option shares code 254 using a
-				 * 16 bits magic number. It's valid only in
-				 * SYN or SYN-ACK with an even size.
-				 */
-				if (opsize < TCPOLEN_EXP_FASTOPEN_BASE ||
-				    get_unaligned_be16(ptr) != TCPOPT_FASTOPEN_MAGIC ||
-				    foc == NULL || !th->syn || (opsize & 1))
-					break;
-				foc->len = opsize - TCPOLEN_EXP_FASTOPEN_BASE;
-				if (foc->len >= TCP_FASTOPEN_COOKIE_MIN &&
-				    foc->len <= TCP_FASTOPEN_COOKIE_MAX)
-					memcpy(foc->val, ptr + 2, foc->len);
-				else if (foc->len != 0)
-					foc->len = -1;
+				/* handle potential exploitations */
+				if (opcode == TCPOPT_COOKIE) {
+					/* This option is variable length. */
+					switch (opsize) {
+					case TCPOLEN_COOKIE_BASE:
+						/* not yet implemented */
+						break;
+					case TCPOLEN_COOKIE_PAIR:
+						/* not yet implemented */
+						break;
+					case TCPOLEN_COOKIE_MIN+0:
+					case TCPOLEN_COOKIE_MIN+2:
+					case TCPOLEN_COOKIE_MIN+4:
+					case TCPOLEN_COOKIE_MIN+6:
+					case TCPOLEN_COOKIE_MAX:
+						/* 16-bit multiple */
+						opt_rx->cookie_plus = opsize;
+						*hvpp = ptr;
+						break;
+					default:
+						/* ignore option */
+						break;
+					}
+				} else {
+					tcp_parse_fastopen_cookie(opcode,
+								  opsize, ptr,
+								  foc, th);
+				}
 				break;
-
 			}
 			ptr += opsize-2;
 			length -= opsize;
@@ -3861,6 +3891,9 @@ static bool tcp_fast_parse_options(const struct sk_buff *skb,
 				   const struct tcphdr *th,
 				   struct tcp_sock *tp, const u8 **hvpp)
 {
+	/* required if exp options are not used anymore by the counter part */
+	tp->rx_opt.exp_opts_len = 0;
+
 	/* In the spirit of fast parsing, compare doff directly to constant
 	 * values.  Because equality is used, short doff can be ignored here.
 	 */
@@ -5786,6 +5819,14 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 			}
 		}
 
+		if (unlikely(tp->rx_opt.exp_opts_len > 0)) {
+			tp->exp_opts.syn = kzalloc(tp->rx_opt.exp_opts_len,
+						   sk->sk_allocation);
+			tp->exp_opts.syn_len = tp->rx_opt.exp_opts_len;
+			memcpy(tp->exp_opts.syn, &tp->rx_opt.exp_opts,
+			       tp->rx_opt.exp_opts_len);
+		}
+
 		smp_mb();
 
 		tcp_finish_connect(sk, skb);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0c4a643..b7ab768 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1525,6 +1525,16 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_parse_options(skb, &tmp_opt, &hash_location, 0,
 	    want_cookie ? NULL : &foc);
 
+	/* for raw access to experimental options in SYN packet */
+	tcp_rsk(req)->syn_expopts_len = tmp_opt.exp_opts_len;
+	if (tcp_rsk(req)->syn_expopts_len) {
+		/* transport experimental options via request socket to big
+		 * socket
+		 */
+		memcpy(tcp_rsk(req)->syn_expopts, tmp_opt.exp_opts,
+		       tcp_rsk(req)->syn_expopts_len);
+	}
+
 	if (tmp_opt.cookie_plus > 0 &&
 	    tmp_opt.saw_tstamp &&
 	    !tp->rx_opt.cookie_out_never &&
@@ -2209,6 +2219,10 @@ void tcp_v4_destroy_sock(struct sock *sk)
 	}
 	BUG_ON(tp->fastopen_rsk != NULL);
 
+	/* buffers for raw access to experimental options */
+	kfree(tp->exp_opts.conf);
+	kfree(tp->exp_opts.syn);
+
 	/* If socket is aborted during connect operation */
 	tcp_free_fastopen_req(tp);
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index a7302d9..1ca8980 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -468,6 +468,23 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 
 		newtp->urg_data = 0;
 
+		if (tcp_rsk(req)->syn_expopts_len) {
+			newtp->exp_opts.syn_len =
+					tcp_rsk(req)->syn_expopts_len;
+			newtp->exp_opts.syn = kzalloc(newtp->exp_opts.syn_len,
+						      GFP_ATOMIC);
+			memcpy(newtp->exp_opts.syn, tcp_rsk(req)->syn_expopts,
+			       newtp->exp_opts.syn_len);
+		}
+
+		if (oldtp->exp_opts.conf_len > 0) {
+			newtp->exp_opts.conf_len = oldtp->exp_opts.conf_len;
+			newtp->exp_opts.conf = kzalloc(TCP_EXPOP_MAXLEN,
+						       GFP_ATOMIC);
+			memcpy(newtp->exp_opts.conf, oldtp->exp_opts.conf,
+			       oldtp->exp_opts.conf_len);
+		}
+
 		if (sock_flag(newsk, SOCK_KEEPOPEN))
 			inet_csk_reset_keepalive_timer(newsk,
 						       keepalive_time_when(newtp));
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 948ac27..a57470a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -385,6 +385,7 @@ static inline bool tcp_urg_mode(const struct tcp_sock *tp)
 #define OPTION_MD5		(1 << 2)
 #define OPTION_WSCALE		(1 << 3)
 #define OPTION_COOKIE_EXTENSION	(1 << 4)
+#define OPTION_EXP		(1 << 5)
 #define OPTION_FAST_OPEN_COOKIE	(1 << 8)
 
 struct tcp_out_options {
@@ -581,6 +582,12 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 		}
 		ptr += (foc->len + 3) >> 2;
 	}
+	if (unlikely(OPTION_EXP & options && tp->exp_opts.conf_len > 0)) {
+		__u8 *p = (__u8 *) ptr;
+		memcpy(ptr, tp->exp_opts.conf, tp->exp_opts.conf_len);
+		p += tp->exp_opts.conf_len;
+		ptr = (__be32 *) p;
+	}
 }
 
 /* Compute TCP options for SYN packets. This is not the final
@@ -693,6 +700,11 @@ static unsigned int tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 			remaining -= need;
 		}
 	}
+	if (unlikely(tp->exp_opts.conf_len > 0 &&
+		     tp->exp_opts.conf_len <= remaining)) {
+		opts->options |= OPTION_EXP;
+		remaining -= tp->exp_opts.conf_len;
+	}
 	return MAX_TCP_OPTION_SPACE - remaining;
 }
 
@@ -748,15 +760,6 @@ static unsigned int tcp_synack_options(struct sock *sk,
 		if (unlikely(!ireq->tstamp_ok))
 			remaining -= TCPOLEN_SACKPERM_ALIGNED;
 	}
-	if (foc != NULL) {
-		u32 need = TCPOLEN_EXP_FASTOPEN_BASE + foc->len;
-		need = (need + 3) & ~3U;  /* Align to 32 bits */
-		if (remaining >= need) {
-			opts->options |= OPTION_FAST_OPEN_COOKIE;
-			opts->fastopen_cookie = foc;
-			remaining -= need;
-		}
-	}
 	/* Similar rationale to tcp_syn_options() applies here, too.
 	 * If the <SYN> options fit, the same options should fit now!
 	 */
@@ -779,6 +782,12 @@ static unsigned int tcp_synack_options(struct sock *sk,
 			opts->hash_size = 0;
 		}
 	}
+
+	if (unlikely(tcp_sk(sk)->exp_opts.conf_len > 0 &&
+		     tcp_sk(sk)->exp_opts.conf_len <= remaining)) {
+		opts->options |= OPTION_EXP;
+		remaining -= tcp_sk(sk)->exp_opts.conf_len;
+	}
 	return MAX_TCP_OPTION_SPACE - remaining;
 }
 
@@ -791,38 +800,44 @@ static unsigned int tcp_established_options(struct sock *sk, struct sk_buff *skb
 {
 	struct tcp_skb_cb *tcb = skb ? TCP_SKB_CB(skb) : NULL;
 	struct tcp_sock *tp = tcp_sk(sk);
-	unsigned int size = 0;
+	unsigned remaining = MAX_TCP_OPTION_SPACE;
 	unsigned int eff_sacks;
 
 #ifdef CONFIG_TCP_MD5SIG
 	*md5 = tp->af_specific->md5_lookup(sk, sk);
 	if (unlikely(*md5)) {
 		opts->options |= OPTION_MD5;
-		size += TCPOLEN_MD5SIG_ALIGNED;
+		remaining -= TCPOLEN_MD5SIG_ALIGNED;
 	}
 #else
 	*md5 = NULL;
 #endif
 
-	if (likely(tp->rx_opt.tstamp_ok)) {
+	if (likely(tp->rx_opt.tstamp_ok &&
+		   remaining >= TCPOLEN_TSTAMP_ALIGNED)) {
 		opts->options |= OPTION_TS;
 		opts->tsval = tcb ? tcb->when : 0;
 		opts->tsecr = tp->rx_opt.ts_recent;
-		size += TCPOLEN_TSTAMP_ALIGNED;
+		remaining -= TCPOLEN_TSTAMP_ALIGNED;
 	}
 
 	eff_sacks = tp->rx_opt.num_sacks + tp->rx_opt.dsack;
 	if (unlikely(eff_sacks)) {
-		const unsigned int remaining = MAX_TCP_OPTION_SPACE - size;
 		opts->num_sack_blocks =
 			min_t(unsigned int, eff_sacks,
 			      (remaining - TCPOLEN_SACK_BASE_ALIGNED) /
 			      TCPOLEN_SACK_PERBLOCK);
-		size += TCPOLEN_SACK_BASE_ALIGNED +
+		remaining -= TCPOLEN_SACK_BASE_ALIGNED +
 			opts->num_sack_blocks * TCPOLEN_SACK_PERBLOCK;
 	}
 
-	return size;
+	if (unlikely(tp->exp_opts.conf_len > 0 &&
+		     tp->exp_opts.conf_len <= remaining)) {
+		opts->options |= OPTION_EXP;
+		remaining -= tp->exp_opts.conf_len;
+	}
+
+	return MAX_TCP_OPTION_SPACE - remaining;
 }
 
 
-- 
1.7.12.4
