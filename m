From: "Adam Langley" <agl@imperialviolet.org>
Subject: [RFC] tcp: Add (limited) SYNACK payload support
Date: Tue, 12 Aug 2008 13:56:47 -0700
Message-ID: <396556a20805301217k293e5718h6bbf02bfe069070@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:19211 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164AbYHLU4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 16:56:00 -0400
Received: by ug-out-1314.google.com with SMTP id h2so18793ugf.16
        for <netdev@vger.kernel.org>; Tue, 12 Aug 2008 13:55:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements the draft spec:
http://www.ietf.org/internet-drafts/draft-agl-tcpm-sadata-01.txt

At the moment, this is just an [RFC] patch because an option number hasn't been
assigned by the IETF yet.

It allows listening sockets to be configured with a small (<= 64 bytes),
payload that is included in SYN/ACK packets elicited by SYN packets that
include a special option. See the draft linked to above for motivations.

Additionally, the listening socket can request that the kernel replace 8 bytes
of the payload with random data (that can later be read from the resulting
accepted socket).

The additional header material for the user interface is:

#define TCP_SADATA_MAX_PAYLOAD	64

/* Flags shared by both */
#define TCP_SADATA_REQUEST	(1 << 0)	/* Request sadata or */
/* Flags for setsockopt */
#define TCP_SADATA_INC_NONCE	(1 << 1)	/* Include nonce in payloads */
/* Flags for getsockopt */
#define TCP_SADATA_SENT		(1 << 2)	/* Was payload sent? */
#define TCP_SADATA_RCVD		(1 << 3)	/* Was payload received? */
#define TCP_SADATA_NONCE	(1 << 4)	/* Was an nonce sent? */

struct tcp_sadata {
	__u16	tcpsa_flags;		/* TCP_SADATA_*, above */
	__u8	tcpsa_payload_len;	/* Length of payload, in bytes */
	__u8	tcpsa_nonce_offset;	/* If INC_NONCE, it's offset in bytes */
	__u32	tcpsa_reserved;
	__u8	tcpsa_payload[TCP_SADATA_MAX_PAYLOAD];
};

A client socket (before connecting) is configured by a setsockopt with flags
equal to TCP_SADATA_REQUEST.

After connecting, a getsockopt will reveal:
  TCP_SADATA_RCVD - SYN/ACK payload received, use recv/read etc to get it
  TCP_SADATA_REQUEST is false - the kernel decided not to actually send the
    request. The kernel is free to do so, although this patch doesn't currently
    make use of it.

A listening socket is configured with a setsockopt with non-zero payload len
and, optionally, TCP_SADATA_INC_NONCE and tcpsa_nonce_offset if the kernel
should include random data.

On a resulting, accepted socket, a getsockopt reveals:
  TCP_SADATA_SENT - a SYN/ACK payload was sent
  TCP_SADATA_NONCE - the 8 random bytes generated are in tcpsa_payload
---

 include/linux/tcp.h      |   53 ++++++++++++++++++++++++++++++++-
 include/net/tcp.h        |   48 ++++++++++++++++++++++++++++++
 net/ipv4/Kconfig         |    9 ++++++
 net/ipv4/tcp.c           |   73 +++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv4/tcp_input.c     |   29 +++++++++++++++++-
 net/ipv4/tcp_ipv4.c      |   36 +++++++++++++++++++++++
 net/ipv4/tcp_minisocks.c |   18 +++++++++--
 net/ipv4/tcp_output.c    |   53 +++++++++++++++++++++++++++++++++
 net/ipv6/tcp_ipv6.c      |   30 +++++++++++++++++++
 9 files changed, 340 insertions(+), 9 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 2e25573..af95ac0 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -96,6 +96,7 @@ enum {
 #define TCP_QUICKACK		12	/* Block/reenable quick acks */
 #define TCP_CONGESTION		13	/* Congestion control algorithm */
 #define TCP_MD5SIG		14	/* TCP MD5 Signature (RFC2385) */
+#define TCP_SADATA		15	/* TCP SYNACK payloads */
 
 #define TCPI_OPT_TIMESTAMPS	1
 #define TCPI_OPT_SACK		2
@@ -170,6 +171,25 @@ struct tcp_md5sig {
 	__u8	tcpm_key[TCP_MD5SIG_MAXKEYLEN];		/* key (binary) */
 };
 
+#define TCP_SADATA_MAX_PAYLOAD	64
+
+/* Flags shared by both */
+#define TCP_SADATA_REQUEST	(1 << 0)	/* Request sadata or */
+/* Flags for setsockopt */
+#define TCP_SADATA_INC_NONCE	(1 << 1)	/* Include nonce in payloads */
+/* Flags for getsockopt */
+#define TCP_SADATA_SENT		(1 << 2)	/* Was payload sent? */
+#define TCP_SADATA_RCVD		(1 << 3)	/* Was payload received? */
+#define TCP_SADATA_NONCE	(1 << 4)	/* Was an nonce sent? */
+
+struct tcp_sadata {
+	__u16	tcpsa_flags;		/* TCP_SADATA_*, above */
+	__u8	tcpsa_payload_len;	/* Length of payload, in bytes */
+	__u8	tcpsa_nonce_offset;	/* If INC_NONCE, it's offset in bytes */
+	__u32	tcpsa_reserved;
+	__u8	tcpsa_payload[TCP_SADATA_MAX_PAYLOAD];
+};
+
 #ifdef __KERNEL__
 
 #include <linux/skbuff.h>
@@ -222,6 +242,9 @@ struct tcp_options_received {
 	u8	num_sacks;	/* Number of SACK blocks		*/
 	u16	user_mss;  	/* mss requested by user in ioctl */
 	u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
+#ifdef CONFIG_TCP_SYNACK_PAYLOAD
+	u8	sadata_ok;	/* OK to include data in the SYNACK?	*/
+#endif
 };
 
 /* This is the max number of SACKS that we'll generate and process. It's safe
@@ -230,14 +253,28 @@ struct tcp_options_received {
  * only four options will fit in a standard TCP header */
 #define TCP_NUM_SACKS 4
 
+struct tcp_sadata_payload;
+
 struct tcp_request_sock {
 	struct inet_request_sock 	req;
 #ifdef CONFIG_TCP_MD5SIG
 	/* Only used by TCP MD5 Signature so far. */
 	struct tcp_request_sock_ops	*af_specific;
 #endif
-	u32			 	rcv_isn;
-	u32			 	snt_isn;
+	u32				rcv_isn;
+	u32				snt_isn;
+#ifdef CONFIG_TCP_SYNACK_PAYLOAD
+	/* If sadata_ok is true then sadata_nonce contains valid random bytes.
+	 * This is the second half of the 8 byte nonce. The first is the
+	 * snt_isn in native byte order to save space.
+	 *
+	 * If sadata_ok is true then sadata_payload is non-NULL and this
+	 * object holds a reference to it (sadata_payload->kref)
+	 */
+	struct tcp_sadata_payload	*sadata_payload;
+	u8				sadata_nonce[4]; /* generated nonce */
+	u8				sadata_ok:1;   /* send sadata?    */
+#endif
 };
 
 static inline struct tcp_request_sock *tcp_rsk(const struct request_sock *req)
@@ -411,6 +448,18 @@ struct tcp_sock {
 #endif
 
 	int			linger2;
+
+#ifdef CONFIG_TCP_SYNACK_PAYLOAD
+	union {
+		/* (maybe NULL) the current payload			      */
+		struct tcp_sadata_payload *p;
+		u8 nonce[8];	/* the generated nonce			      */
+	} sadata;
+	u8	sadata_is_nonce : 1,	/* sadata union contains nonce        */
+		sadata_sent : 1,	/* was the SYNACK data sent?          */
+		sadata_rcvd : 1,	/* did we see SYNACK payload data?    */
+		sadata_req : 1;		/* does userland want SYNACK payload? */
+#endif
 };
 
 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 8983386..163f781 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -30,6 +30,7 @@
 #include <linux/dmaengine.h>
 #include <linux/crypto.h>
 #include <linux/cryptohash.h>
+#include <linux/kref.h>
 
 #include <net/inet_connection_sock.h>
 #include <net/inet_timewait_sock.h>
@@ -166,6 +167,7 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOPT_SACK             5       /* SACK Block */
 #define TCPOPT_TIMESTAMP	8	/* Better RTT estimations/PAWS */
 #define TCPOPT_MD5SIG		19	/* MD5 Signature (RFC2385) */
+#define TCPOPT_SYNACK_PAYLOAD	255	/* Experimental option for now */
 
 /*
  *     TCP option lengths
@@ -176,6 +178,7 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOLEN_SACK_PERM      2
 #define TCPOLEN_TIMESTAMP      10
 #define TCPOLEN_MD5SIG         18
+#define TCPOLEN_SYNACK_PAYLOAD 2
 
 /* But this is what stacks really send out. */
 #define TCPOLEN_TSTAMP_ALIGNED		12
@@ -186,6 +189,7 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOLEN_SACK_PERBLOCK		8
 #define TCPOLEN_MD5SIG_ALIGNED		20
 #define TCPOLEN_MSS_ALIGNED		4
+#define TCPOLEN_SYNACK_PAYLOAD_ALIGNED	4
 
 /* Flags in tp->nonagle */
 #define TCP_NAGLE_OFF		1	/* Nagle's algo is disabled */
@@ -331,7 +335,10 @@ extern void tcp_enter_quickack_mode(struct sock *sk);
 
 static inline void tcp_clear_options(struct tcp_options_received *rx_opt)
 {
- 	rx_opt->tstamp_ok = rx_opt->sack_ok = rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
+	rx_opt->tstamp_ok = rx_opt->sack_ok = rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
+#ifdef CONFIG_TCP_SYNACK_PAYLOAD
+	rx_opt->sadata_ok = 0;
+#endif
 }
 
 #define	TCP_ECN_OK		1
@@ -1402,4 +1409,43 @@ struct tcp_request_sock_ops {
 extern void tcp_v4_init(void);
 extern void tcp_init(void);
 
+#ifdef CONFIG_TCP_SYNACK_PAYLOAD
+/**
+ * struct tcp_sadata_payload - a SYN/ACK data payload
+ * @sadp_len: the length of the trailing data payload
+ * @sadp_nonce_off: the offset of the nonce in the payload, if any
+ * @sadp_inc_nonce: include nonce iff true
+ * @sadp_data: trailing payload data
+ *
+ * This structure contains a constant payload that is to be included in the
+ * payload of SYNACK packets when the SYN requests it.
+ *
+ * This structure is immutable (save for the reference counter) once created. A
+ * tcp_sock contains a pointer to the current one and this is cloned off to the
+ * request socks as they are generated.
+ */
+struct tcp_sadata_payload {
+	struct kref	kref;
+	u8		len;
+	u8		nonce_off : 6,
+			inc_nonce : 1;
+	u8		data[0];
+};
+
+static inline void tcp_sadata_payload_release(struct kref *kref)
+{
+	kfree(container_of(kref, struct tcp_sadata_payload, kref));
+}
+
+static inline int tcp_rsk_sadata_len(const struct tcp_request_sock *trsk)
+{
+	return trsk->sadata_ok ? trsk->sadata_payload->len : 0;
+}
+#else
+static inline int tcp_rsk_sadata_len(const struct tcp_request_sock *trsk)
+{
+	return 0;
+}
+#endif
+
 #endif	/* _TCP_H */
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 591ea23..90e612b 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -630,5 +630,14 @@ config TCP_MD5SIG
 
 	  If unsure, say N.
 
+config TCP_SYNACK_PAYLOAD
+	bool "TCP: Enable payloads in SYNACK frames"
+	depends on EXPERIMENTAL
+	---help---
+	  This option enables an experimental, backwards compatible, extension
+	  to TCP where data can be included in the SYNACK frame of a handshake.
+
+	  If unsure, say N.
+
 source "net/ipv4/ipvs/Kconfig"
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1ab341e..f5e2eab 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1990,7 +1990,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 	int val;
 	int err = 0;
 
-	/* This is a string value all the others are int's */
+	/* These are string values, all the others are int's */
 	if (optname == TCP_CONGESTION) {
 		char name[TCP_CA_NAME_MAX];
 
@@ -2008,6 +2008,55 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		release_sock(sk);
 		return err;
 	}
+#ifdef CONFIG_TCP_SYNACK_PAYLOAD
+	else if (optname == TCP_SADATA) {
+		struct tcp_sadata tcpsa;
+		struct tcp_sadata_payload *sadp;
+
+		if (optlen < sizeof(tcpsa))
+			return -EINVAL;
+		if (copy_from_user(&tcpsa, optval, sizeof(tcpsa)))
+			return -EFAULT;
+		if (tcpsa.tcpsa_payload_len > TCP_SADATA_MAX_PAYLOAD)
+			return -EINVAL;
+		if (tcpsa.tcpsa_flags & TCP_SADATA_INC_NONCE &&
+		    tcpsa.tcpsa_nonce_offset > TCP_SADATA_MAX_PAYLOAD - 8)
+			return -EINVAL;
+
+		lock_sock(sk);
+		tp->sadata_req = TCP_SADATA_REQUEST & tcpsa.tcpsa_flags ? 1 : 0;
+
+		if (tcpsa.tcpsa_payload_len == 0) {
+			if (!tp->sadata_is_nonce && tp->sadata.p) {
+				kref_put(&tp->sadata.p->kref,
+					 tcp_sadata_payload_release);
+				tp->sadata.p = NULL;
+			}
+		} else if ((sadp = kmalloc(sizeof(struct tcp_sadata_payload) +
+					   tcpsa.tcpsa_payload_len,
+					   GFP_ATOMIC))) {
+			if (unlikely(tp->sadata_is_nonce)) {
+				tp->sadata_is_nonce = 0;
+			} else if (unlikely(tp->sadata.p)) {
+				kref_put(&tp->sadata.p->kref,
+					 tcp_sadata_payload_release);
+			}
+			kref_init(&sadp->kref);
+			memcpy(sadp->data, tcpsa.tcpsa_payload,
+			       tcpsa.tcpsa_payload_len);
+			sadp->len = tcpsa.tcpsa_payload_len;
+			sadp->nonce_off = tcpsa.tcpsa_nonce_offset;
+			sadp->inc_nonce =
+				TCP_SADATA_INC_NONCE & tcpsa.tcpsa_flags ? 1:0;
+			tp->sadata.p = sadp;
+		} else {
+			err = -ENOMEM;
+		}
+
+		release_sock(sk);
+		return err;
+	}
+#endif
 
 	if (optlen < sizeof(int))
 		return -EINVAL;
@@ -2269,6 +2318,28 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 	if (get_user(len, optlen))
 		return -EFAULT;
 
+#ifdef CONFIG_TCP_SYNACK_PAYLOAD
+	/* This is a string argument, all the rest are ints */
+	if (optname == TCP_SADATA) {
+		struct tcp_sadata tcpsa;
+
+		if (len < sizeof(tcpsa))
+			return -EINVAL;
+		tcpsa.tcpsa_flags = (tp->sadata_sent ? TCP_SADATA_SENT : 0) |
+				    (tp->sadata_rcvd ? TCP_SADATA_RCVD : 0) |
+				    (tp->sadata_req ? TCP_SADATA_REQUEST : 0);
+		if (tp->sadata_is_nonce) {
+			tcpsa.tcpsa_flags |= TCP_SADATA_NONCE;
+			memcpy(tcpsa.tcpsa_payload, tp->sadata.nonce, 8);
+		}
+		if (copy_to_user(optval, &tcpsa, sizeof(tcpsa)))
+			return -EFAULT;
+		if (put_user(sizeof(tcpsa), optlen))
+			return -EFAULT;
+		return 0;
+	}
+#endif
+
 	len = min_t(unsigned int, len, sizeof(int));
 
 	if (len < 0)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 67ccce2..d76ad9b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3418,7 +3418,11 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 					tcp_sack_reset(opt_rx);
 				}
 				break;
-
+#ifdef CONFIG_TCP_SYNACK_PAYLOAD
+			case TCPOPT_SYNACK_PAYLOAD:
+				opt_rx->sadata_ok = 1;
+				break;
+#endif
 			case TCPOPT_SACK:
 				if ((opsize >= (TCPOLEN_SACK_BASE + TCPOLEN_SACK_PERBLOCK)) &&
 				   !((opsize - TCPOLEN_SACK_BASE) % TCPOLEN_SACK_PERBLOCK) &&
@@ -4975,6 +4979,7 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	int saved_clamp = tp->rx_opt.mss_clamp;
+	char queued = 0;
 
 	tcp_parse_options(skb, &tp->rx_opt, 0);
 
@@ -5073,6 +5078,22 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 		 * Change state from SYN-SENT only after copied_seq
 		 * is initialized. */
 		tp->copied_seq = tp->rcv_nxt;
+
+#ifdef CONFIG_TCP_SYNACK_PAYLOAD
+		if (skb->len > (th->doff << 2) && tp->sadata_req &&
+		    tp->rx_opt.sadata_ok) {
+			__skb_pull(skb, th->doff << 2);
+			__skb_queue_tail(&sk->sk_receive_queue, skb);
+			skb_set_owner_r(skb, sk);
+			sk->sk_data_ready(sk, 0);
+			tp->sadata_rcvd = 1;
+			queued = 1;
+			tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
+			tp->rcv_wup = TCP_SKB_CB(skb)->end_seq;
+			tp->copied_seq = TCP_SKB_CB(skb)->seq + 1;
+		}
+#endif
+
 		smp_mb();
 		tcp_set_state(sk, TCP_ESTABLISHED);
 
@@ -5124,11 +5145,15 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 						  TCP_DELACK_MAX, TCP_RTO_MAX);
 
 discard:
-			__kfree_skb(skb);
+			if (!queued)
+				__kfree_skb(skb);
 			return 0;
 		} else {
 			tcp_send_ack(sk);
 		}
+
+		if (queued)
+			return 0;
 		return -1;
 	}
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 44c1e93..677121c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -744,6 +744,13 @@ static int tcp_v4_send_synack(struct sock *sk, struct request_sock *req)
  */
 static void tcp_v4_reqsk_destructor(struct request_sock *req)
 {
+#ifdef CONFIG_TCP_SYNACK_PAYLOAD
+	if (tcp_rsk(req)->sadata_ok) {
+		kref_put(&tcp_rsk(req)->sadata_payload->kref,
+			 tcp_sadata_payload_release);
+	}
+#endif
+
 	kfree(inet_rsk(req)->opt);
 }
 
@@ -1302,6 +1309,15 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	}
 	tcp_rsk(req)->snt_isn = isn;
 
+#ifdef CONFIG_TCP_SYNACK_PAYLOAD
+	tcp_rsk(req)->sadata_ok = tmp_opt.sadata_ok;
+	if (tmp_opt.sadata_ok) {
+		tcp_rsk(req)->sadata_payload = tcp_sk(sk)->sadata.p;
+		kref_get(&tcp_sk(sk)->sadata.p->kref);
+		get_random_bytes(&tcp_rsk(req)->sadata_nonce, 4);
+	}
+#endif
+
 	if (__tcp_v4_send_synack(sk, req, dst) || want_cookie)
 		goto drop_and_free;
 
@@ -1354,6 +1370,13 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	newinet->saddr	      = ireq->loc_addr;
 	newinet->opt	      = ireq->opt;
 	ireq->opt	      = NULL;
+#ifdef CONFIG_TCP_SYNACK_PAYLOAD
+	if (tcp_rsk(req)->sadata_ok) {
+		kref_put(&tcp_rsk(req)->sadata_payload->kref,
+			 tcp_sadata_payload_release);
+		tcp_rsk(req)->sadata_ok = 0;
+	}
+#endif
 	newinet->mc_index     = inet_iif(skb);
 	newinet->mc_ttl	      = ip_hdr(skb)->ttl;
 	inet_csk(newsk)->icsk_ext_hdr_len = 0;
@@ -1792,6 +1815,12 @@ static int tcp_v4_init_sock(struct sock *sk)
 	tp->af_specific = &tcp_sock_ipv4_specific;
 #endif
 
+#ifdef CONFIG_TCP_SYNACK_PAYLOAD
+	tp->sadata.p = NULL;
+	tp->sadata_sent = tp->sadata_rcvd = tp->sadata_req = 0;
+	tp->sadata_is_nonce = 0;
+#endif
+
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
@@ -1843,6 +1872,13 @@ void tcp_v4_destroy_sock(struct sock *sk)
 		sk->sk_sndmsg_page = NULL;
 	}
 
+#ifdef CONFIG_TCP_SYNACK_PAYLOAD
+	if (!tp->sadata_is_nonce && tp->sadata.p) {
+		kref_put(&tp->sadata.p->kref, tcp_sadata_payload_release);
+		tp->sadata.p = NULL;
+	}
+#endif
+
 	atomic_dec(&tcp_sockets_allocated);
 }
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index f976fc5..1e42355 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -394,7 +394,8 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		newtp = tcp_sk(newsk);
 		newtp->pred_flags = 0;
 		newtp->rcv_wup = newtp->copied_seq = newtp->rcv_nxt = treq->rcv_isn + 1;
-		newtp->snd_sml = newtp->snd_una = newtp->snd_nxt = treq->snt_isn + 1;
+		newtp->snd_sml = newtp->snd_una = newtp->snd_nxt =
+			treq->snt_isn + 1 + tcp_rsk_sadata_len(treq);
 
 		tcp_prequeue_init(newtp);
 
@@ -427,7 +428,17 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		tcp_set_ca_state(newsk, TCP_CA_Open);
 		tcp_init_xmit_timers(newsk);
 		skb_queue_head_init(&newtp->out_of_order_queue);
-		newtp->write_seq = treq->snt_isn + 1;
+		newtp->write_seq = treq->snt_isn + 1 + tcp_rsk_sadata_len(treq);
+#ifdef CONFIG_TCP_SYNACK_PAYLOAD
+		newtp->sadata_sent = treq->sadata_ok;
+		if (treq->sadata_ok && treq->sadata_payload->inc_nonce) {
+			memcpy(newtp->sadata.nonce, &treq->snt_isn, 4);
+			memcpy(&newtp->sadata.nonce[4], &treq->sadata_nonce, 4);
+			newtp->sadata_is_nonce = 1;
+		} else {
+			newtp->sadata.p = NULL;
+		}
+#endif
 		newtp->pushed_seq = newtp->write_seq;
 
 		newtp->rx_opt.saw_tstamp = 0;
@@ -595,7 +606,8 @@ struct sock *tcp_check_req(struct sock *sk,struct sk_buff *skb,
 	 * Invalid ACK: reset will be sent by listening socket
 	 */
 	if ((flg & TCP_FLAG_ACK) &&
-	    (TCP_SKB_CB(skb)->ack_seq != tcp_rsk(req)->snt_isn + 1))
+	    (TCP_SKB_CB(skb)->ack_seq != tcp_rsk(req)->snt_isn +
+					 1 + tcp_rsk_sadata_len(tcp_rsk(req))))
 		return sk;
 
 	/* Also, it would be not so bad idea to check rcv_tsecr, which
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a00532d..1fb7f0a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -348,6 +348,7 @@ static void tcp_init_nondata_skb(struct sk_buff *skb, u32 seq, u8 flags)
 #define OPTION_SACK_ADVERTISE	(1 << 0)
 #define OPTION_TS		(1 << 1)
 #define OPTION_MD5		(1 << 2)
+#define OPTION_SYNACK_PAYLOAD	(1 << 3)
 
 struct tcp_out_options {
 	u8 options;		/* bit field of OPTION_* */
@@ -430,6 +431,15 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 			tp->rx_opt.eff_sacks--;
 		}
 	}
+
+#ifdef CONFIG_TCP_SYNACK_PAYLOAD
+	if (unlikely(OPTION_SYNACK_PAYLOAD & opts->options)) {
+		*ptr++ = htonl((TCPOPT_NOP << 24) |
+			       (TCPOPT_NOP << 16) |
+			       (TCPOPT_SYNACK_PAYLOAD << 8) |
+			       TCPOLEN_SYNACK_PAYLOAD);
+	}
+#endif
 }
 
 static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
@@ -476,6 +486,14 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 			size += TCPOLEN_SACKPERM_ALIGNED;
 	}
 
+#ifdef CONFIG_TCP_SYNACK_PAYLOAD
+	if (unlikely(tp->sadata_req &&
+	    size + TCPOLEN_SYNACK_PAYLOAD_ALIGNED <= MAX_TCP_OPTION_SPACE)) {
+		opts->options |= OPTION_SYNACK_PAYLOAD;
+		size += TCPOLEN_SYNACK_PAYLOAD_ALIGNED;
+	}
+#endif
+
 	return size;
 }
 
@@ -504,6 +522,25 @@ static unsigned tcp_synack_options(struct sock *sk,
 	   to be unnecessary. */
 	doing_ts = ireq->tstamp_ok && !(*md5 && ireq->sack_ok);
 
+#ifdef CONFIG_TCP_SYNACK_PAYLOAD
+	if (unlikely(tcp_rsk(req)->sadata_ok)) {
+		opts->options |= OPTION_SYNACK_PAYLOAD;
+		size += TCPOLEN_SYNACK_PAYLOAD_ALIGNED;
+
+		/* Consider the pessimal case: all options included. In this
+		 * case the options look like:
+		 *   MD5(20) + MSS(4) + WSCALE(4) + TS(12) + SADATAOK(4) > 40
+		 * Thus, when including both SADATAOK and MD5 we disable TS.
+		 * The reason is that we must be consistant across
+		 * retransmissions in our inclusion of SADATAOK. But a user
+		 * could configure an MD5 option between two retransmissions.
+		 * So, to be safe, we must disable TS rather than SADATAOK
+		 */
+		if (*md5)
+			doing_ts = 0;
+	}
+#endif
+
 	opts->mss = mss;
 	size += TCPOLEN_MSS_ALIGNED;
 
@@ -2285,6 +2322,22 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	 */
 	tcp_init_nondata_skb(skb, tcp_rsk(req)->snt_isn,
 			     TCPCB_FLAG_SYN | TCPCB_FLAG_ACK);
+#ifdef CONFIG_TCP_SYNACK_PAYLOAD
+	if (tcp_rsk(req)->sadata_ok) {
+		const struct tcp_sadata_payload *sadp =
+			tcp_rsk(req)->sadata_payload;
+		u8 *buf = skb_put(skb, sadp->len);
+		memcpy(buf, sadp->data, sadp->len);
+		if (sadp->inc_nonce &&
+		    sadp->len >= 8 + sadp->nonce_off) {
+			memcpy(buf + sadp->nonce_off,
+			       &tcp_rsk(req)->snt_isn, 4);
+			memcpy(buf + sadp->nonce_off + 4,
+			       tcp_rsk(req)->sadata_nonce, 4);
+		}
+		TCP_SKB_CB(skb)->end_seq += sadp->len;
+	}
+#endif
 	th->seq = htonl(TCP_SKB_CB(skb)->seq);
 	th->ack_seq = htonl(tcp_rsk(req)->rcv_isn + 1);
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5b90b36..e8387ea 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -532,6 +532,13 @@ static void tcp_v6_reqsk_destructor(struct request_sock *req)
 {
 	if (inet6_rsk(req)->pktopts)
 		kfree_skb(inet6_rsk(req)->pktopts);
+
+#ifdef CONFIG_TCP_SYNACK_PAYLOAD
+	if (tcp_rsk(req)->sadata_ok) {
+		kref_put(&tcp_rsk(req)->sadata_payload->kref,
+			 tcp_sadata_payload_release);
+	}
+#endif
 }
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -1265,6 +1272,15 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 
 	tcp_rsk(req)->snt_isn = isn;
 
+#ifdef CONFIG_TCP_SYNACK_PAYLOAD
+	tcp_rsk(req)->sadata_ok = tmp_opt.sadata_ok;
+	if (tmp_opt.sadata_ok) {
+		tcp_rsk(req)->sadata_payload = tcp_sk(sk)->sadata.p;
+		kref_get(&tcp_sk(sk)->sadata.p->kref);
+		get_random_bytes(&tcp_rsk(req)->sadata_nonce, 4);
+	}
+#endif
+
 	security_inet_conn_request(sk, skb, req);
 
 	if (tcp_v6_send_synack(sk, req))
@@ -1451,6 +1467,14 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		inet_csk(newsk)->icsk_ext_hdr_len = (newnp->opt->opt_nflen +
 						     newnp->opt->opt_flen);
 
+#ifdef CONFIG_TCP_SYNACK_PAYLOAD
+	if (tcp_rsk(req)->sadata_ok) {
+		kref_put(&tcp_rsk(req)->sadata_payload->kref,
+			 tcp_sadata_payload_release);
+		tcp_rsk(req)->sadata_ok = 0;
+	}
+#endif
+
 	tcp_mtup_init(newsk);
 	tcp_sync_mss(newsk, dst_mtu(dst));
 	newtp->advmss = dst_metric(dst, RTAX_ADVMSS);
@@ -1894,6 +1918,12 @@ static int tcp_v6_init_sock(struct sock *sk)
 	tp->af_specific = &tcp_sock_ipv6_specific;
 #endif
 
+#ifdef CONFIG_TCP_SYNACK_PAYLOAD
+	tp->sadata.p = NULL;
+	tp->sadata_sent = tp->sadata_rcvd = tp->sadata_req = 0;
+	tp->sadata_is_nonce = 0;
+#endif
+
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
