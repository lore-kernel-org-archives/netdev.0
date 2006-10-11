From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [RFC] [TCP]: TCP MD5 Signature Option (RFC2385) Support.
Date: Wed, 11 Oct 2006 11:39:00 +0900 (JST)
Message-ID: <20061011.113900.08679683.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:61455 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S932406AbWJKCgd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 22:36:33 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

These changesets (on top of linux-2.6.19-rc1) implement TCP MD5 Signature
Option, which is described in RFC2385.

This implementation is based on joint work between David Miller and myself,
which was based on patch by Rick Payne.

TODOs or Things to consider
	- Locking
	- GSO (Herbert?)
	- Memory accounting?
	- New value for TCP_MD5SIG value to resolve conflicts with the
	  customizable TCP backoff patch

Tree is also available in 2.6.19-rc1-tcpmd5-20061011 branch at
	git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6.18-git-tcp.git

HEADLINES
---------

    [TCP]: Use TCPOLEN_TSTAMP_ALIGNED macro instead of magic number.
    [NET]: Use hton{l,s}() for non-initializers.
    [NET]: Use typesafe inet_twsk() inline function instead of cast.
    [NET]: Introduce protocol-specific destructor for time-wait sockets.
    [TCP]: MD5 Signature Option (RFC2385) support.

DIFFSTAT
--------

 CREDITS                          |    3 
 include/linux/tcp.h              |   35 ++
 include/net/inet_timewait_sock.h |    1 
 include/net/request_sock.h       |    3 
 include/net/tcp.h                |  139 ++++++++
 include/net/timewait_sock.h      |   10 +
 net/dccp/ipv4.c                  |   12 -
 net/dccp/ipv6.c                  |   14 -
 net/dccp/minisocks.c             |    2 
 net/ipv4/Kconfig                 |   15 +
 net/ipv4/ip_gre.c                |    4 
 net/ipv4/tcp.c                   |  137 ++++++++
 net/ipv4/tcp_input.c             |    8 
 net/ipv4/tcp_ipv4.c              |  689 ++++++++++++++++++++++++++++++++++++--
 net/ipv4/tcp_minisocks.c         |   64 +++-
 net/ipv4/tcp_output.c            |  142 +++++++-
 net/ipv6/tcp_ipv6.c              |  581 +++++++++++++++++++++++++++++++-
 17 files changed, 1759 insertions(+), 100 deletions(-)

CHANGESETS
----------

commit 2af9286ebd40b0787e22ee2f4082cc5915ed390d
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Fri Sep 29 12:49:02 2006 +0900

    [TCP]: Use TCPOLEN_TSTAMP_ALIGNED macro instead of magic number.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index c83938b..f745095 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -578,7 +578,7 @@ static void tcp_v4_send_ack(struct sk_bu
 	struct tcphdr *th = skb->h.th;
 	struct {
 		struct tcphdr th;
-		u32 tsopt[3];
+		u32 tsopt[TCPOLEN_TSTAMP_ALIGNED >> 2];
 	} rep;
 	struct ip_reply_arg arg;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3b65754..34e004b 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -653,7 +653,7 @@ static void tcp_v6_send_ack(struct sk_bu
 	int tot_len = sizeof(struct tcphdr);
 
 	if (ts)
-		tot_len += 3*4;
+		tot_len += TCPOLEN_TSTAMP_ALIGNED;
 
 	buff = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) + tot_len,
 			 GFP_ATOMIC);

---
commit 9454bd98a3b8e47545aee7f704046ec2a05bdf9b
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sun Oct 1 11:02:16 2006 +0900

    [NET]: Use hton{l,s}() for non-initializers.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index f5fba05..d5b5dec 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -611,8 +611,8 @@ static int ipgre_rcv(struct sk_buff *skb
 		 * - When dealing with WCCPv2, Skip extra 4 bytes in GRE header
 		 */
 		if (flags == 0 &&
-		    skb->protocol == __constant_htons(ETH_P_WCCP)) {
-			skb->protocol = __constant_htons(ETH_P_IP);
+		    skb->protocol == htons(ETH_P_WCCP)) {
+			skb->protocol = htons(ETH_P_IP);
 			if ((*(h + offset) & 0xF0) != 0x40) 
 				offset += 4;
 		}
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 9a253fa..f22536e 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -273,10 +273,10 @@ static void tcp_build_and_update_options
 					 __u32 tstamp)
 {
 	if (tp->rx_opt.tstamp_ok) {
-		*ptr++ = __constant_htonl((TCPOPT_NOP << 24) |
-					  (TCPOPT_NOP << 16) |
-					  (TCPOPT_TIMESTAMP << 8) |
-					  TCPOLEN_TIMESTAMP);
+		*ptr++ = htonl((TCPOPT_NOP << 24) |
+			       (TCPOPT_NOP << 16) |
+			       (TCPOPT_TIMESTAMP << 8) |
+			       TCPOLEN_TIMESTAMP);
 		*ptr++ = htonl(tstamp);
 		*ptr++ = htonl(tp->rx_opt.ts_recent);
 	}
@@ -325,18 +325,27 @@ static void tcp_syn_build_options(__be32
 	*ptr++ = htonl((TCPOPT_MSS << 24) | (TCPOLEN_MSS << 16) | mss);
 	if (ts) {
 		if(sack)
-			*ptr++ = __constant_htonl((TCPOPT_SACK_PERM << 24) | (TCPOLEN_SACK_PERM << 16) |
-						  (TCPOPT_TIMESTAMP << 8) | TCPOLEN_TIMESTAMP);
+			*ptr++ = htonl((TCPOPT_SACK_PERM << 24) |
+				       (TCPOLEN_SACK_PERM << 16) |
+				       (TCPOPT_TIMESTAMP << 8) |
+				       TCPOLEN_TIMESTAMP);
 		else
-			*ptr++ = __constant_htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |
-						  (TCPOPT_TIMESTAMP << 8) | TCPOLEN_TIMESTAMP);
+			*ptr++ = htonl((TCPOPT_NOP << 24) |
+				       (TCPOPT_NOP << 16) |
+				       (TCPOPT_TIMESTAMP << 8) |
+				       TCPOLEN_TIMESTAMP);
 		*ptr++ = htonl(tstamp);		/* TSVAL */
 		*ptr++ = htonl(ts_recent);	/* TSECR */
 	} else if(sack)
-		*ptr++ = __constant_htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |
-					  (TCPOPT_SACK_PERM << 8) | TCPOLEN_SACK_PERM);
+		*ptr++ = htonl((TCPOPT_NOP << 24) |
+			       (TCPOPT_NOP << 16) |
+			       (TCPOPT_SACK_PERM << 8) |
+			       TCPOLEN_SACK_PERM);
 	if (offer_wscale)
-		*ptr++ = htonl((TCPOPT_NOP << 24) | (TCPOPT_WINDOW << 16) | (TCPOLEN_WINDOW << 8) | (wscale));
+		*ptr++ = htonl((TCPOPT_NOP << 24) |
+			       (TCPOPT_WINDOW << 16) |
+			       (TCPOLEN_WINDOW << 8) |
+			       (wscale));
 }
 
 /* This routine actually transmits TCP packets queued in by

---
commit 5afcffa8aa27442edc1c6c4d36936170daaeb843
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sat Oct 7 23:55:17 2006 +0900

    [NET]: Use typesafe inet_twsk() inline function instead of cast.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index bf692c1..7e746c4 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -311,7 +311,7 @@ static void dccp_v4_err(struct sk_buff *
 	}
 
 	if (sk->sk_state == DCCP_TIME_WAIT) {
-		inet_twsk_put((struct inet_timewait_sock *)sk);
+		inet_twsk_put(inet_twsk(sk));
 		return;
 	}
 
@@ -614,7 +614,7 @@ static struct sock *dccp_v4_hnd_req(stru
 			bh_lock_sock(nsk);
 			return nsk;
 		}
-		inet_twsk_put((struct inet_timewait_sock *)nsk);
+		inet_twsk_put(inet_twsk(nsk));
 		return NULL;
 	}
 
@@ -980,7 +980,7 @@ discard_and_relse:
 	goto discard_it;
 
 do_time_wait:
-	inet_twsk_put((struct inet_timewait_sock *)sk);
+	inet_twsk_put(inet_twsk(sk));
 	goto no_dccp_socket;
 }
 
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 7a47399..7171a78 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -285,7 +285,7 @@ static void dccp_v6_err(struct sk_buff *
 	}
 
 	if (sk->sk_state == DCCP_TIME_WAIT) {
-		inet_twsk_put((struct inet_timewait_sock *)sk);
+		inet_twsk_put(inet_twsk(sk));
 		return;
 	}
 
@@ -663,7 +663,7 @@ static struct sock *dccp_v6_hnd_req(stru
 			bh_lock_sock(nsk);
 			return nsk;
 		}
-		inet_twsk_put((struct inet_timewait_sock *)nsk);
+		inet_twsk_put(inet_twsk(nsk));
 		return NULL;
 	}
 
@@ -1109,7 +1109,7 @@ discard_and_relse:
 	goto discard_it;
 
 do_time_wait:
-	inet_twsk_put((struct inet_timewait_sock *)sk);
+	inet_twsk_put(inet_twsk(sk));
 	goto no_dccp_socket;
 }
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f745095..6bbd985 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -355,7 +355,7 @@ void tcp_v4_err(struct sk_buff *skb, u32
 		return;
 	}
 	if (sk->sk_state == TCP_TIME_WAIT) {
-		inet_twsk_put((struct inet_timewait_sock *)sk);
+		inet_twsk_put(inet_twsk(sk));
 		return;
 	}
 
@@ -960,7 +960,7 @@ static struct sock *tcp_v4_hnd_req(struc
 			bh_lock_sock(nsk);
 			return nsk;
 		}
-		inet_twsk_put((struct inet_timewait_sock *)nsk);
+		inet_twsk_put(inet_twsk(nsk));
 		return NULL;
 	}
 
@@ -1154,26 +1154,24 @@ discard_and_relse:
 
 do_time_wait:
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
-		inet_twsk_put((struct inet_timewait_sock *) sk);
+		inet_twsk_put(inet_twsk(sk));
 		goto discard_it;
 	}
 
 	if (skb->len < (th->doff << 2) || tcp_checksum_complete(skb)) {
 		TCP_INC_STATS_BH(TCP_MIB_INERRS);
-		inet_twsk_put((struct inet_timewait_sock *) sk);
+		inet_twsk_put(inet_twsk(sk));
 		goto discard_it;
 	}
-	switch (tcp_timewait_state_process((struct inet_timewait_sock *)sk,
-					   skb, th)) {
+	switch (tcp_timewait_state_process(inet_twsk(sk), skb, th)) {
 	case TCP_TW_SYN: {
 		struct sock *sk2 = inet_lookup_listener(&tcp_hashinfo,
 							skb->nh.iph->daddr,
 							th->dest,
 							inet_iif(skb));
 		if (sk2) {
-			inet_twsk_deschedule((struct inet_timewait_sock *)sk,
-					     &tcp_death_row);
-			inet_twsk_put((struct inet_timewait_sock *)sk);
+			inet_twsk_deschedule(inet_twsk(sk), &tcp_death_row);
+			inet_twsk_put(inet_twsk(sk));
 			sk = sk2;
 			goto process;
 		}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 34e004b..4c2a7c0 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -329,7 +329,7 @@ static void tcp_v6_err(struct sk_buff *s
 	}
 
 	if (sk->sk_state == TCP_TIME_WAIT) {
-		inet_twsk_put((struct inet_timewait_sock *)sk);
+		inet_twsk_put(inet_twsk(sk));
 		return;
 	}
 
@@ -749,7 +749,7 @@ static struct sock *tcp_v6_hnd_req(struc
 			bh_lock_sock(nsk);
 			return nsk;
 		}
-		inet_twsk_put((struct inet_timewait_sock *)nsk);
+		inet_twsk_put(inet_twsk(nsk));
 		return NULL;
 	}
 
@@ -1283,18 +1283,17 @@ discard_and_relse:
 
 do_time_wait:
 	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) {
-		inet_twsk_put((struct inet_timewait_sock *)sk);
+		inet_twsk_put(inet_twsk(sk));
 		goto discard_it;
 	}
 
 	if (skb->len < (th->doff<<2) || tcp_checksum_complete(skb)) {
 		TCP_INC_STATS_BH(TCP_MIB_INERRS);
-		inet_twsk_put((struct inet_timewait_sock *)sk);
+		inet_twsk_put(inet_twsk(sk));
 		goto discard_it;
 	}
 
-	switch (tcp_timewait_state_process((struct inet_timewait_sock *)sk,
-					   skb, th)) {
+	switch (tcp_timewait_state_process(inet_twsk(sk), skb, th)) {
 	case TCP_TW_SYN:
 	{
 		struct sock *sk2;

---
commit a63850c54f8792a5562f611639209f038d75b716
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sun Oct 8 21:41:30 2006 +0900

    [NET]: Introduce protocol-specific destructor for time-wait sockets.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 6d14c22..5f48748 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -196,6 +196,7 @@ static inline void inet_twsk_put(struct 
 {
 	if (atomic_dec_and_test(&tw->tw_refcnt)) {
 		struct module *owner = tw->tw_prot->owner;
+		twsk_destructor((struct sock *)tw);
 #ifdef SOCK_REFCNT_DEBUG
 		printk(KERN_DEBUG "%s timewait_sock %p released\n",
 		       tw->tw_prot->name, tw);
diff --git a/include/net/timewait_sock.h b/include/net/timewait_sock.h
index 2544281..be293d7 100644
--- a/include/net/timewait_sock.h
+++ b/include/net/timewait_sock.h
@@ -19,6 +19,7 @@ struct timewait_sock_ops {
 	unsigned int	twsk_obj_size;
 	int		(*twsk_unique)(struct sock *sk,
 				       struct sock *sktw, void *twp);
+	void		(*twsk_destructor)(struct sock *sk);
 };
 
 static inline int twsk_unique(struct sock *sk, struct sock *sktw, void *twp)
@@ -28,4 +29,10 @@ static inline int twsk_unique(struct soc
 	return 0;
 }
 
+static inline void twsk_destructor(struct sock *sk)
+{
+	if (sk->sk_prot->twsk_prot->twsk_destructor != NULL)
+		sk->sk_prot->twsk_prot->twsk_destructor(sk);
+}
+
 #endif /* _TIMEWAIT_SOCK_H */

---
commit 5d36c0d1375c49412aba0653dc1d53cf8ebbbb44
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Oct 11 11:07:24 2006 +0900

    [TCP]: MD5 Signature Option (RFC2385) support.
    
    Based on implementation by Rick Payne.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/CREDITS b/CREDITS
index 5329ead..751b8eb 100644
--- a/CREDITS
+++ b/CREDITS
@@ -2598,6 +2598,9 @@ S: Ucitelska 1576
 S: Prague 8
 S: 182 00 Czech Republic
 
+N: Rick Payne
+D: RFC2385 Support for TCP
+
 N: Barak A. Pearlmutter
 E: bap@cs.unm.edu
 W: http://www.cs.unm.edu/~bap/
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 0e058a2..314d57c 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -19,6 +19,7 @@ #define _LINUX_TCP_H
 
 #include <linux/types.h>
 #include <asm/byteorder.h>
+#include <linux/socket.h>
 
 struct tcphdr {
 	__be16	source;
@@ -94,6 +95,7 @@ #define TCP_WINDOW_CLAMP	10	/* Bound adv
 #define TCP_INFO		11	/* Information about this connection. */
 #define TCP_QUICKACK		12	/* Block/reenable quick acks */
 #define TCP_CONGESTION		13	/* Congestion control algorithm */
+#define TCP_MD5SIG		14	/* TCP MD5 Signature (RFC2385) */
 
 #define TCPI_OPT_TIMESTAMPS	1
 #define TCPI_OPT_SACK		2
@@ -157,6 +159,17 @@ struct tcp_info
 	__u32	tcpi_total_retrans;
 };
 
+/* for TCP_MD5SIG socket option */
+#define TCP_MD5SIG_MAXKEYLEN	80
+
+struct tcp_md5sig {
+	struct __kernel_sockaddr_storage tcpm_addr;	/* address associated */
+	__u16	__tcpm_pad1;				/* zero */
+	__u16	tcpm_keylen;				/* key length */
+	__u32	__tcpm_pad2;				/* zero */
+	__u8	tcpm_key[TCP_MD5SIG_MAXKEYLEN];		/* key (binary) */
+};
+
 #ifdef __KERNEL__
 
 #include <linux/skbuff.h>
@@ -197,9 +210,13 @@ struct tcp_options_received {
 };
 
 struct tcp_request_sock {
-	struct inet_request_sock req;
-	__u32			 rcv_isn;
-	__u32			 snt_isn;
+	struct inet_request_sock 	req;
+#ifdef CONFIG_TCP_MD5SIG
+	/* Only used by TCP MD5 Signature so far. */
+	struct tcp_request_sock_ops	*af_specific;
+#endif
+	__u32			 	rcv_isn;
+	__u32			 	snt_isn;
 };
 
 static inline struct tcp_request_sock *tcp_rsk(const struct request_sock *req)
@@ -361,6 +378,14 @@ #endif
 		__u32		  probe_seq_start;
 		__u32		  probe_seq_end;
 	} mtu_probe;
+
+#ifdef CONFIG_TCP_MD5SIG
+/* TCP AF-Specific parts; only used by MD5 Signature support so far */
+	struct tcp_sock_af_ops	*af_specific;
+
+/* TCP MD5 Signagure Option information */
+	struct tcp_md5sig_info	*md5sig_info;
+#endif
 };
 
 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
@@ -375,6 +400,10 @@ struct tcp_timewait_sock {
 	__u32			  tw_rcv_wnd;
 	__u32			  tw_ts_recent;
 	long			  tw_ts_recent_stamp;
+#ifdef CONFIG_TCP_MD5SIG
+	__u16			  tw_md5_keylen;
+	__u8			  tw_md5_key[TCP_MD5SIG_MAXKEYLEN];
+#endif
 };
 
 static inline struct tcp_timewait_sock *tcp_twsk(const struct sock *sk)
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 8e165ca..6a814b7 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -35,7 +35,8 @@ struct request_sock_ops {
 				       struct dst_entry *dst);
 	void		(*send_ack)(struct sk_buff *skb,
 				    struct request_sock *req);
-	void		(*send_reset)(struct sk_buff *skb);
+	void		(*send_reset)(struct sock *sk,
+				      struct sk_buff *skb);
 	void		(*destructor)(struct request_sock *req);
 };
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7a093d0..84dfdcd 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -28,6 +28,7 @@ #include <linux/cache.h>
 #include <linux/percpu.h>
 #include <linux/skbuff.h>
 #include <linux/dmaengine.h>
+#include <linux/crypto.h>
 
 #include <net/inet_connection_sock.h>
 #include <net/inet_timewait_sock.h>
@@ -162,6 +163,7 @@ #define TCPOPT_WINDOW		3	/* Window scali
 #define TCPOPT_SACK_PERM        4       /* SACK Permitted */
 #define TCPOPT_SACK             5       /* SACK Block */
 #define TCPOPT_TIMESTAMP	8	/* Better RTT estimations/PAWS */
+#define TCPOPT_MD5SIG		19	/* MD5 Signature (RFC2385) */
 
 /*
  *     TCP option lengths
@@ -171,6 +173,7 @@ #define TCPOLEN_MSS            4
 #define TCPOLEN_WINDOW         3
 #define TCPOLEN_SACK_PERM      2
 #define TCPOLEN_TIMESTAMP      10
+#define TCPOLEN_MD5SIG         18
 
 /* But this is what stacks really send out. */
 #define TCPOLEN_TSTAMP_ALIGNED		12
@@ -179,6 +182,7 @@ #define TCPOLEN_SACKPERM_ALIGNED	4
 #define TCPOLEN_SACK_BASE		2
 #define TCPOLEN_SACK_BASE_ALIGNED	4
 #define TCPOLEN_SACK_PERBLOCK		8
+#define TCPOLEN_MD5SIG_ALIGNED		20
 
 /* Flags in tp->nonagle */
 #define TCP_NAGLE_OFF		1	/* Nagle's algo is disabled */
@@ -300,6 +304,8 @@ extern void			tcp_cleanup_rbuf(struct so
 extern int			tcp_twsk_unique(struct sock *sk,
 						struct sock *sktw, void *twp);
 
+extern void			tcp_twsk_destructor(struct sock *sk);
+
 static inline void tcp_dec_quickack_mode(struct sock *sk,
 					 const unsigned int pkts)
 {
@@ -1058,6 +1064,110 @@ static inline void clear_all_retrans_hin
 	tp->fastpath_skb_hint = NULL;
 }
 
+/* MD5 Signature */
+struct crypto_hash;
+
+/* - key database */
+struct tcp_md5sig_key {
+	u8			*key;
+	u8			keylen;
+};
+
+struct tcp4_md5sig_key {
+	u8			*key;
+	u16			keylen;
+	__be32			addr;
+};
+
+struct tcp6_md5sig_key {
+	u8			*key;
+	u16			keylen;
+#if 0
+	u32			scope_id;	/* XXX */
+#endif
+	struct in6_addr		addr;
+};
+
+/* - sock block */
+struct tcp_md5sig_info {
+	struct tcp4_md5sig_key	*keys4;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	struct tcp6_md5sig_key	*keys6;
+	u32			entries6;
+	u32			alloced6;
+#endif
+	u32			entries4;
+	u32			alloced4;
+};
+
+/* - pseudo header */
+struct tcp4_pseudohdr {
+	__be32		saddr;
+	__be32		daddr;
+	__u8		pad;
+	__u8		protocol;
+	__be16		len;
+};
+
+struct tcp6_pseudohdr {
+	struct in6_addr	saddr;
+	struct in6_addr daddr;
+	__be32		len;
+	__be32		protocol;	/* including padding */
+};
+
+union tcp_md5sum_block {
+	struct tcp4_pseudohdr ip4;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	struct tcp6_pseudohdr ip6;
+#endif
+};
+
+/* - pool: digest algorithm, hash description and scratch buffer */
+struct tcp_md5sig_pool {
+	struct hash_desc	md5_desc;
+	union tcp_md5sum_block	md5_blk;
+};
+
+#define TCP_MD5SIG_MAXKEYS	(~(u32)0)	/* really?! */
+
+/* - functions */
+extern int			tcp_v4_calc_md5_hash(char *md5_hash,
+						     struct tcp_md5sig_key *key,
+						     struct sock *sk,
+						     struct dst_entry *dst,
+						     struct request_sock *req,
+						     struct tcphdr *th,
+						     int protocol, int tcplen);
+extern struct tcp_md5sig_key	*tcp_v4_md5_lookup(struct sock *sk,
+						   struct sock *addr_sk);
+
+extern int			tcp_v4_md5_do_add(struct sock *sk,
+						  __be32 addr,
+						  u8 *newkey,
+						  u8 newkeylen);
+
+extern int			tcp_v4_md5_do_del(struct sock *sk,
+						  u32 addr);
+
+extern struct tcp_md5sig_pool	**tcp_alloc_md5sig_pool(void);
+extern void			tcp_free_md5sig_pool(void);
+
+extern struct tcp_md5sig_pool	*__tcp_get_md5sig_pool(int cpu);
+extern void			__tcp_put_md5sig_pool(void);
+
+static inline
+struct tcp_md5sig_pool		*tcp_get_md5sig_pool(void)
+{
+	return __tcp_get_md5sig_pool(get_cpu());
+}
+
+static inline void		tcp_put_md5sig_pool(void)
+{
+	__tcp_put_md5sig_pool();
+	put_cpu();
+}
+
 /* /proc */
 enum tcp_seq_states {
 	TCP_SEQ_STATE_LISTENING,
@@ -1097,6 +1207,35 @@ extern int  tcp4_proc_init(void);
 extern void tcp4_proc_exit(void);
 #endif
 
+/* TCP af-specific functions */
+struct tcp_sock_af_ops {
+#ifdef CONFIG_TCP_MD5SIG
+	struct tcp_md5sig_key	*(*md5_lookup) (struct sock *sk,
+						struct sock *addr_sk);
+	int			(*calc_md5_hash) (char *location,
+						  struct tcp_md5sig_key *md5,
+						  struct sock *sk,
+						  struct dst_entry *dst,
+						  struct request_sock *req,
+						  struct tcphdr *th,
+						  int protocol, int len);
+	int			(*md5_add) (struct sock *sk,
+					    struct sock *addr_sk,
+					    u8 *newkey,
+					    u8 len);
+	int			(*md5_parse) (struct sock *sk,
+					      char __user *optval,
+					      int optlen);
+#endif
+};
+
+struct tcp_request_sock_ops {
+#ifdef CONFIG_TCP_MD5SIG
+	struct tcp_md5sig_key	*(*md5_lookup) (struct sock *sk,
+						struct request_sock *req);
+#endif
+};
+
 extern void tcp_v4_init(struct net_proto_family *ops);
 extern void tcp_init(void);
 
diff --git a/include/net/timewait_sock.h b/include/net/timewait_sock.h
index be293d7..d7a306e 100644
--- a/include/net/timewait_sock.h
+++ b/include/net/timewait_sock.h
@@ -31,6 +31,9 @@ static inline int twsk_unique(struct soc
 
 static inline void twsk_destructor(struct sock *sk)
 {
+	BUG_ON(sk == NULL);
+	BUG_ON(sk->sk_prot == NULL);
+	BUG_ON(sk->sk_prot->twsk_prot == NULL);
 	if (sk->sk_prot->twsk_prot->twsk_destructor != NULL)
 		sk->sk_prot->twsk_prot->twsk_destructor(sk);
 }
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 7e746c4..7e525bd 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -687,7 +687,7 @@ static struct dst_entry* dccp_v4_route_s
 	return &rt->u.dst;
 }
 
-static void dccp_v4_ctl_send_reset(struct sk_buff *rxskb)
+static void dccp_v4_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 {
 	int err;
 	struct dccp_hdr *rxdh = dccp_hdr(rxskb), *dh;
@@ -809,7 +809,7 @@ int dccp_v4_do_rcv(struct sock *sk, stru
 	return 0;
 
 reset:
-	dccp_v4_ctl_send_reset(skb);
+	dccp_v4_ctl_send_reset(sk, skb);
 discard:
 	kfree_skb(skb);
 	return 0;
@@ -967,7 +967,7 @@ no_dccp_socket:
 	if (dh->dccph_type != DCCP_PKT_RESET) {
 		DCCP_SKB_CB(skb)->dccpd_reset_code =
 					DCCP_RESET_CODE_NO_CONNECTION;
-		dccp_v4_ctl_send_reset(skb);
+		dccp_v4_ctl_send_reset(sk, skb);
 	}
 
 discard_it:
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 7171a78..c35159d 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -36,7 +36,7 @@ #include "feat.h"
 /* Socket used for sending RSTs and ACKs */
 static struct socket *dccp_v6_ctl_socket;
 
-static void dccp_v6_ctl_send_reset(struct sk_buff *skb);
+static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *skb);
 static void dccp_v6_reqsk_send_ack(struct sk_buff *skb,
 				   struct request_sock *req);
 static void dccp_v6_send_check(struct sock *sk, int len, struct sk_buff *skb);
@@ -514,7 +514,7 @@ static void dccp_v6_send_check(struct so
 							  skb->csum));
 }
 
-static void dccp_v6_ctl_send_reset(struct sk_buff *rxskb)
+static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 {
 	struct dccp_hdr *rxdh = dccp_hdr(rxskb), *dh;
 	const u32 dccp_hdr_reset_len = sizeof(struct dccp_hdr) +
@@ -1024,7 +1024,7 @@ static int dccp_v6_do_rcv(struct sock *s
 	return 0;
 
 reset:
-	dccp_v6_ctl_send_reset(skb);
+	dccp_v6_ctl_send_reset(sk, skb);
 discard:
 	if (opt_skb != NULL)
 		__kfree_skb(opt_skb);
@@ -1093,7 +1093,7 @@ no_dccp_socket:
 	if (dh->dccph_type != DCCP_PKT_RESET) {
 		DCCP_SKB_CB(skb)->dccpd_reset_code =
 					DCCP_RESET_CODE_NO_CONNECTION;
-		dccp_v6_ctl_send_reset(skb);
+		dccp_v6_ctl_send_reset(sk, skb);
 	}
 discard_it:
 
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 9045438..be2cdec 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -243,7 +243,7 @@ listen_overflow:
 	DCCP_SKB_CB(skb)->dccpd_reset_code = DCCP_RESET_CODE_TOO_BUSY;
 drop:
 	if (dccp_hdr(skb)->dccph_type != DCCP_PKT_RESET)
-		req->rsk_ops->send_reset(skb);
+		req->rsk_ops->send_reset(sk, skb);
 
 	inet_csk_reqsk_queue_drop(sk, req, prev);
 	goto out;
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 5572071..aff9328 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -625,5 +625,20 @@ config DEFAULT_TCP_CONG
 	default "reno" if DEFAULT_RENO
 	default "cubic"
 
+config TCP_MD5SIG
+	bool "TCP: MD5 Signature Option support (RFC2385)"
+	select CRYPTO
+	select CRYPTO_MD5
+	---help---
+	  RFC2385 specifices a method of giving MD5 protection to TCP sessions.
+	  Its main (only?) use is to protect BGP sessions between core routers
+	  on the Internet.
+
+	  If unsure, say N.
+
+config TCP_MD5SIG_DEBUG
+	bool "TCP: MD5 Signature Option debugging"
+	depends on TCP_MD5SIG
+
 source "net/ipv4/ipvs/Kconfig"
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 66e9a72..5dc7345 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -258,6 +258,7 @@ #include <linux/random.h>
 #include <linux/bootmem.h>
 #include <linux/cache.h>
 #include <linux/err.h>
+#include <linux/crypto.h>
 
 #include <net/icmp.h>
 #include <net/tcp.h>
@@ -1942,6 +1943,13 @@ static int do_tcp_setsockopt(struct sock
 		}
 		break;
 
+#ifdef CONFIG_TCP_MD5SIG
+	case TCP_MD5SIG:
+		/* Read the IP->Key mappings from userspace */
+		err = tp->af_specific->md5_parse(sk, optval, optlen);
+		break;
+#endif
+
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -2231,6 +2239,135 @@ out:
 }
 EXPORT_SYMBOL(tcp_tso_segment);
 
+#ifdef CONFIG_TCP_MD5SIG
+static unsigned long tcp_md5sig_users;
+static struct tcp_md5sig_pool **tcp_md5sig_pool;
+static DEFINE_SPINLOCK(tcp_md5sig_pool_lock);
+
+static void __tcp_free_md5sig_pool(struct tcp_md5sig_pool **pool)
+{
+	int cpu;
+	for_each_possible_cpu(cpu) {
+		struct tcp_md5sig_pool *p = *per_cpu_ptr(pool, cpu);
+		if (p) {
+			if (p->md5_desc.tfm)
+				crypto_free_hash(p->md5_desc.tfm);
+			kfree(p);
+			p = NULL;
+		}
+	}
+	free_percpu(pool);
+}
+
+void tcp_free_md5sig_pool(void)
+{
+	struct tcp_md5sig_pool **pool = NULL;
+
+	spin_lock(&tcp_md5sig_pool_lock);
+	if (--tcp_md5sig_users == 0) {
+		pool = tcp_md5sig_pool;
+		tcp_md5sig_pool = NULL;
+	}
+	spin_unlock(&tcp_md5sig_pool_lock);
+	if (pool)
+		__tcp_free_md5sig_pool(pool);
+}
+
+EXPORT_SYMBOL(tcp_free_md5sig_pool);
+
+struct tcp_md5sig_pool **__tcp_alloc_md5sig_pool(void)
+{
+	int cpu;
+	struct tcp_md5sig_pool **pool;
+	
+	pool = alloc_percpu(struct tcp_md5sig_pool *);
+	if (!pool)
+		return NULL;
+	
+	for_each_possible_cpu(cpu) {
+		struct tcp_md5sig_pool *p;
+		struct crypto_hash *hash;
+		
+		p = kzalloc(sizeof(*p), GFP_KERNEL);
+		if (!p)
+			goto out_free;
+		*per_cpu_ptr(pool, cpu) = p;
+
+		hash = crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
+		if (!hash || IS_ERR(hash))
+			goto out_free;
+		
+		p->md5_desc.tfm = hash;
+	}
+	return pool;
+out_free:
+	__tcp_free_md5sig_pool(pool);
+	return NULL;
+}
+
+struct tcp_md5sig_pool **tcp_alloc_md5sig_pool(void)
+{
+	struct tcp_md5sig_pool **pool;
+	int alloc = 0;
+
+retry:
+	spin_lock(&tcp_md5sig_pool_lock);
+	pool = tcp_md5sig_pool;
+	if (tcp_md5sig_users++ == 0) {
+		alloc = 1;
+		spin_unlock(&tcp_md5sig_pool_lock);
+	} else if (!pool) {
+		tcp_md5sig_users--;
+		spin_unlock(&tcp_md5sig_pool_lock);
+		cpu_relax();
+		goto retry;
+	} else
+		spin_unlock(&tcp_md5sig_pool_lock);
+
+	if (alloc) {
+		/* we cannot hold spinlock here because this may sleep. */
+		struct tcp_md5sig_pool **p = __tcp_alloc_md5sig_pool();
+		spin_lock(&tcp_md5sig_pool_lock);
+		if (!p) {
+			tcp_md5sig_users--;
+			spin_unlock(&tcp_md5sig_pool_lock);
+			return NULL;
+		}
+		pool = tcp_md5sig_pool;
+		if (pool) {
+			/* oops, it has already been assigned. */
+			spin_unlock(&tcp_md5sig_pool_lock);
+			__tcp_free_md5sig_pool(p);
+		} else {
+			tcp_md5sig_pool = pool = p;
+			spin_unlock(&tcp_md5sig_pool_lock);
+		}
+	}
+	return pool;
+}
+
+EXPORT_SYMBOL(tcp_alloc_md5sig_pool);
+
+struct tcp_md5sig_pool *__tcp_get_md5sig_pool(int cpu)
+{
+	struct tcp_md5sig_pool **p;
+	spin_lock(&tcp_md5sig_pool_lock);
+	p = tcp_md5sig_pool;
+	if (p)
+		tcp_md5sig_users++;
+	spin_unlock(&tcp_md5sig_pool_lock);
+	return (p ? *per_cpu_ptr(p, cpu) : NULL);
+}
+
+EXPORT_SYMBOL(__tcp_get_md5sig_pool);
+
+void __tcp_put_md5sig_pool(void) {
+	__tcp_free_md5sig_pool(tcp_md5sig_pool);
+}
+
+EXPORT_SYMBOL(__tcp_put_md5sig_pool);
+#endif
+
 extern void __skb_cb_too_small_for_tcp(int, int);
 extern struct tcp_congestion_ops tcp_reno;
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index cf06acc..443caff 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2677,6 +2677,14 @@ void tcp_parse_options(struct sk_buff *s
 					   opt_rx->sack_ok) {
 						TCP_SKB_CB(skb)->sacked = (ptr - 2) - (unsigned char *)th;
 					}
+#ifdef CONFIG_TCP_MD5SIG
+				case TCPOPT_MD5SIG:
+					/*
+					 * The MD5 Hash has already been
+					 * checked (see tcp_v{4,6}_do_rcv()).
+					 */
+					break;
+#endif
 	  			};
 	  			ptr+=opsize-2;
 	  			length-=opsize;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 6bbd985..0994ac9 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -78,6 +78,9 @@ #include <linux/stddef.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 
+#include <linux/crypto.h>
+#include <linux/scatterlist.h>
+
 int sysctl_tcp_tw_reuse __read_mostly;
 int sysctl_tcp_low_latency __read_mostly;
 
@@ -89,6 +92,13 @@ static struct socket *tcp_socket;
 
 void tcp_v4_send_check(struct sock *sk, int len, struct sk_buff *skb);
 
+#ifdef CONFIG_TCP_MD5SIG
+static struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk, __be32 addr);
+static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
+				   __be32 saddr, __be32 daddr, struct tcphdr *th,
+				   int protocol, int tcplen);
+#endif
+
 struct inet_hashinfo __cacheline_aligned tcp_hashinfo = {
 	.lhash_lock	= __RW_LOCK_UNLOCKED(tcp_hashinfo.lhash_lock),
 	.lhash_users	= ATOMIC_INIT(0),
@@ -526,11 +536,19 @@ int tcp_v4_gso_send_check(struct sk_buff
  *	Exception: precedence violation. We do not implement it in any case.
  */
 
-static void tcp_v4_send_reset(struct sk_buff *skb)
+static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcphdr *th = skb->h.th;
-	struct tcphdr rth;
+	struct {
+		struct tcphdr th;
+#ifdef CONFIG_TCP_MD5SIG
+		u32 opt[(TCPOLEN_MD5SIG_ALIGNED >> 2)];
+#endif
+	} rep;
 	struct ip_reply_arg arg;
+#ifdef CONFIG_TCP_MD5SIG
+	struct tcp_md5sig_key *key;
+#endif
 
 	/* Never send a reset in response to a reset. */
 	if (th->rst)
@@ -540,29 +558,50 @@ static void tcp_v4_send_reset(struct sk_
 		return;
 
 	/* Swap the send and the receive. */
-	memset(&rth, 0, sizeof(struct tcphdr));
-	rth.dest   = th->source;
-	rth.source = th->dest;
-	rth.doff   = sizeof(struct tcphdr) / 4;
-	rth.rst    = 1;
+	memset(&rep, 0, sizeof(rep));
+	rep.th.dest   = th->source;
+	rep.th.source = th->dest;
+	rep.th.doff   = sizeof(struct tcphdr) / 4;
+	rep.th.rst    = 1;
 
 	if (th->ack) {
-		rth.seq = th->ack_seq;
+		rep.th.seq = th->ack_seq;
 	} else {
-		rth.ack = 1;
-		rth.ack_seq = htonl(ntohl(th->seq) + th->syn + th->fin +
-				    skb->len - (th->doff << 2));
+		rep.th.ack = 1;
+		rep.th.ack_seq = htonl(ntohl(th->seq) + th->syn + th->fin +
+				       skb->len - (th->doff << 2));
 	}
 
 	memset(&arg, 0, sizeof arg);
-	arg.iov[0].iov_base = (unsigned char *)&rth;
-	arg.iov[0].iov_len  = sizeof rth;
+	arg.iov[0].iov_base = (unsigned char *)&rep;
+	arg.iov[0].iov_len  = sizeof(rep.th);
+
+#ifdef CONFIG_TCP_MD5SIG
+	key = sk ? tcp_v4_md5_do_lookup(sk, skb->nh.iph->daddr) : NULL;
+	if (key) {
+		rep.opt[0] = htonl((TCPOPT_NOP << 24) |
+				   (TCPOPT_NOP << 16) |
+				   (TCPOPT_MD5SIG << 8) |
+				   TCPOLEN_MD5SIG);
+		/* Update length and the length the header thinks exists */
+		arg.iov[0].iov_len += TCPOLEN_MD5SIG_ALIGNED;
+		rep.th.doff = arg.iov[0].iov_len / 4;
+
+		tcp_v4_do_calc_md5_hash((__u8 *)&rep.opt[1],
+					key,
+					skb->nh.iph->daddr,
+					skb->nh.iph->saddr,
+					&rep.th, IPPROTO_TCP,
+					arg.iov[0].iov_len);
+	}
+#endif
+
 	arg.csum = csum_tcpudp_nofold(skb->nh.iph->daddr,
 				      skb->nh.iph->saddr, /*XXX*/
 				      sizeof(struct tcphdr), IPPROTO_TCP, 0);
 	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
 
-	ip_send_reply(tcp_socket->sk, skb, &arg, sizeof rth);
+	ip_send_reply(tcp_socket->sk, skb, &arg, arg.iov[0].iov_len);
 
 	TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
 	TCP_INC_STATS_BH(TCP_MIB_OUTRSTS);
@@ -572,15 +611,24 @@ static void tcp_v4_send_reset(struct sk_
    outside socket context is ugly, certainly. What can I do?
  */
 
-static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
+static void tcp_v4_send_ack(struct tcp_timewait_sock *twsk,
+			    struct sk_buff *skb, u32 seq, u32 ack,
 			    u32 win, u32 ts)
 {
 	struct tcphdr *th = skb->h.th;
 	struct {
 		struct tcphdr th;
-		u32 tsopt[TCPOLEN_TSTAMP_ALIGNED >> 2];
+		u32 opt[(TCPOLEN_TSTAMP_ALIGNED >> 2)
+#ifdef CONFIG_TCP_MD5SIG
+			+ (TCPOLEN_MD5SIG_ALIGNED >> 2)
+#endif
+			];
 	} rep;
 	struct ip_reply_arg arg;
+#ifdef CONFIG_TCP_MD5SIG
+	struct tcp_md5sig_key *key;
+	struct tcp_md5sig_key tw_key;
+#endif
 
 	memset(&rep.th, 0, sizeof(struct tcphdr));
 	memset(&arg, 0, sizeof arg);
@@ -588,12 +636,12 @@ static void tcp_v4_send_ack(struct sk_bu
 	arg.iov[0].iov_base = (unsigned char *)&rep;
 	arg.iov[0].iov_len  = sizeof(rep.th);
 	if (ts) {
-		rep.tsopt[0] = htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |
-				     (TCPOPT_TIMESTAMP << 8) |
-				     TCPOLEN_TIMESTAMP);
-		rep.tsopt[1] = htonl(tcp_time_stamp);
-		rep.tsopt[2] = htonl(ts);
-		arg.iov[0].iov_len = sizeof(rep);
+		rep.opt[0] = htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |
+				   (TCPOPT_TIMESTAMP << 8) |
+				   TCPOLEN_TIMESTAMP);
+		rep.opt[1] = htonl(tcp_time_stamp);
+		rep.opt[2] = htonl(ts);
+		arg.iov[0].iov_len = TCPOLEN_TSTAMP_ALIGNED;
 	}
 
 	/* Swap the send and the receive. */
@@ -605,6 +653,44 @@ static void tcp_v4_send_ack(struct sk_bu
 	rep.th.ack     = 1;
 	rep.th.window  = htons(win);
 
+#ifdef CONFIG_TCP_MD5SIG
+	/*
+	 * The SKB holds an imcoming packet, but may not have a valid ->sk
+	 * pointer. This is especially the case when we're dealing with a
+	 * TIME_WAIT ack, because the sk structure is long gone, and only
+	 * the tcp_timewait_sock remains. So the md5 key is stashed in that
+	 * structure, and we use it in preference.  I believe that (twsk ||
+	 * skb->sk) holds true, but we program defensively.
+	 */
+	if (!twsk && skb->sk) {
+		key = tcp_v4_md5_do_lookup(skb->sk, skb->nh.iph->daddr);
+	} else if (twsk && twsk->tw_md5_keylen) {
+		tw_key.key = twsk->tw_md5_key;
+		tw_key.keylen = twsk->tw_md5_keylen;
+		key = &tw_key;
+	} else {
+		key = NULL;
+	}
+
+	if (key) {
+		int offset = (ts) ? 3 : 0;
+
+		rep.opt[offset++] = htonl((TCPOPT_NOP << 24) |
+					  (TCPOPT_NOP << 16) |
+					  (TCPOPT_MD5SIG << 8) |
+					  TCPOLEN_MD5SIG);
+		arg.iov[0].iov_len += TCPOLEN_MD5SIG_ALIGNED;
+		rep.th.doff = arg.iov[0].iov_len/4;
+
+		tcp_v4_do_calc_md5_hash((__u8 *)&rep.opt[offset],
+					key,
+					skb->nh.iph->daddr,
+					skb->nh.iph->saddr,
+					&rep.th, IPPROTO_TCP,
+					arg.iov[0].iov_len);
+	}
+#endif
+
 	arg.csum = csum_tcpudp_nofold(skb->nh.iph->daddr,
 				      skb->nh.iph->saddr, /*XXX*/
 				      arg.iov[0].iov_len, IPPROTO_TCP, 0);
@@ -618,9 +704,9 @@ static void tcp_v4_send_ack(struct sk_bu
 static void tcp_v4_timewait_ack(struct sock *sk, struct sk_buff *skb)
 {
 	struct inet_timewait_sock *tw = inet_twsk(sk);
-	const struct tcp_timewait_sock *tcptw = tcp_twsk(sk);
+	struct tcp_timewait_sock *tcptw = tcp_twsk(sk);
 
-	tcp_v4_send_ack(skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
+	tcp_v4_send_ack(tcptw, skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
 			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale, tcptw->tw_ts_recent);
 
 	inet_twsk_put(tw);
@@ -628,7 +714,8 @@ static void tcp_v4_timewait_ack(struct s
 
 static void tcp_v4_reqsk_send_ack(struct sk_buff *skb, struct request_sock *req)
 {
-	tcp_v4_send_ack(skb, tcp_rsk(req)->snt_isn + 1, tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd,
+	tcp_v4_send_ack(NULL, skb, tcp_rsk(req)->snt_isn + 1,
+			tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd,
 			req->ts_recent);
 }
 
@@ -715,6 +802,461 @@ static struct ip_options *tcp_v4_save_op
 	return dopt;
 }
 
+#ifdef CONFIG_TCP_MD5SIG
+/*
+ * RFC2385 MD5 checksumming requires a mapping of
+ * IP address->MD5 Key.
+ * We need to maintain these in the sk structure.
+ */
+
+/* Find the Key structure for an address.  */
+static struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk, __be32 addr)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	int i;
+
+	if (!tp->md5sig_info || !tp->md5sig_info->entries4)
+		return NULL;
+	for (i = 0; i < tp->md5sig_info->entries4; i++) {
+		if (tp->md5sig_info->keys4[i].addr == addr)
+			return (struct tcp_md5sig_key *)&tp->md5sig_info->keys4[i];
+	}
+	return NULL;
+}
+
+struct tcp_md5sig_key *tcp_v4_md5_lookup(struct sock *sk,
+					 struct sock *addr_sk)
+{
+	return tcp_v4_md5_do_lookup(sk, inet_sk(addr_sk)->daddr);
+}
+
+EXPORT_SYMBOL(tcp_v4_md5_lookup);
+
+struct tcp_md5sig_key *tcp_v4_reqsk_md5_lookup(struct sock *sk,
+					       struct request_sock *req)
+{
+	return tcp_v4_md5_do_lookup(sk, inet_rsk(req)->rmt_addr);
+}
+
+/* This can be called on a newly created socket, from other files */
+int tcp_v4_md5_do_add(struct sock *sk, __be32 addr,
+		      u8 *newkey, u8 newkeylen)
+{
+	/* Add Key to the list */
+	struct tcp4_md5sig_key *key;
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct tcp4_md5sig_key *keys;
+
+	key = (struct tcp4_md5sig_key *) tcp_v4_md5_do_lookup(sk, addr);
+	if (key) {
+		/* Pre-existing entry - just update that one. */
+		kfree (key->key);
+		key->key = newkey;
+		key->keylen = newkeylen;
+	} else {
+		if (!tp->md5sig_info) {
+			tp->md5sig_info = kzalloc(sizeof(*tp->md5sig_info), GFP_ATOMIC);
+			if (!tp->md5sig_info) {
+				kfree(newkey);
+				return -ENOMEM;
+			}
+		}
+		if (tcp_alloc_md5sig_pool() == NULL) {
+			kfree(newkey);
+			return -ENOMEM;
+		}
+		if (tp->md5sig_info->alloced4 == tp->md5sig_info->entries4) {
+			keys = kmalloc((sizeof(struct tcp4_md5sig_key) *
+				       (tp->md5sig_info->entries4 + 1)), GFP_ATOMIC);
+			if (!keys) {
+				kfree(newkey);
+				tcp_free_md5sig_pool();
+				return -ENOMEM;
+			}
+
+			if (tp->md5sig_info->entries4)
+				memcpy(keys, tp->md5sig_info->keys4,
+				       (sizeof (struct tcp4_md5sig_key) *
+					tp->md5sig_info->entries4));
+
+			/* Free old key list, and reference new one */
+			if (tp->md5sig_info->keys4)
+				kfree(tp->md5sig_info->keys4);
+			tp->md5sig_info->keys4 = keys;
+			tp->md5sig_info->alloced4++;
+		}
+		tp->md5sig_info->entries4++;
+		tp->md5sig_info->keys4[tp->md5sig_info->entries4 - 1].addr = addr;
+		tp->md5sig_info->keys4[tp->md5sig_info->entries4 - 1].key = newkey;
+		tp->md5sig_info->keys4[tp->md5sig_info->entries4 - 1].keylen = newkeylen;
+	}
+	return 0;
+}
+
+EXPORT_SYMBOL(tcp_v4_md5_do_add);
+
+static int tcp_v4_md5_add_func(struct sock *sk, struct sock *addr_sk,
+			       u8 *newkey, u8 newkeylen)
+{
+	return tcp_v4_md5_do_add(sk, inet_sk(addr_sk)->daddr,
+				 newkey, newkeylen);
+}
+
+int tcp_v4_md5_do_del(struct sock *sk, __be32 addr)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	int i;
+
+	for (i = 0; i < tp->md5sig_info->entries4; i++) {
+		if (tp->md5sig_info->keys4[i].addr == addr) {
+			/* Free the key */
+			kfree(tp->md5sig_info->keys4[i].key);
+			tp->md5sig_info->entries4--;
+
+			if (tp->md5sig_info->entries4 == 0) {
+				kfree(tp->md5sig_info->keys4);
+				tp->md5sig_info->keys4 = NULL;
+			} else {
+				/* Need to do some manipulation */
+				if (tp->md5sig_info->entries4 != i)
+					memcpy(&tp->md5sig_info->keys4[i],
+					       &tp->md5sig_info->keys4[i+1],
+					       (tp->md5sig_info->entries4 - i)
+					        * sizeof (struct tcp4_md5sig_key));
+			}
+			tcp_free_md5sig_pool();
+			return 0;
+		}
+	}
+	return -ENOENT;
+}
+
+EXPORT_SYMBOL(tcp_v4_md5_do_del);
+
+static void tcp_v4_clear_md5_list (struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	/* Free each key, then the set of key keys,
+	 * the crypto element, and then decrement our
+	 * hold on the last resort crypto.
+	 */
+	if (tp->md5sig_info->entries4) {
+		int i;
+		for (i = 0; i < tp->md5sig_info->entries4; i++)
+			kfree(tp->md5sig_info->keys4[i].key);
+		tp->md5sig_info->entries4 = 0;
+		tcp_free_md5sig_pool();
+	}
+	if (tp->md5sig_info->keys4) {
+		kfree(tp->md5sig_info->keys4);
+		tp->md5sig_info->keys4 = NULL;
+		tp->md5sig_info->alloced4  = 0;
+	}
+}
+
+static int tcp_v4_parse_md5_keys (struct sock *sk, char __user *optval,
+				  int optlen)
+{
+	struct tcp_md5sig cmd;
+	struct sockaddr_in *sin = (struct sockaddr_in *)&cmd.tcpm_addr;
+	u8 *newkey;
+
+	if (optlen < sizeof(cmd))
+		return -EINVAL;
+
+	if (copy_from_user (&cmd, optval, sizeof(cmd)))
+		return -EFAULT;
+
+	if (sin->sin_family != AF_INET)
+		return -EINVAL;
+
+	if (!cmd.tcpm_key || !cmd.tcpm_keylen) {
+		if (!tcp_sk(sk)->md5sig_info)
+			return -ENOENT;
+		return tcp_v4_md5_do_del(sk, sin->sin_addr.s_addr);
+	}
+
+	if (cmd.tcpm_keylen > TCP_MD5SIG_MAXKEYLEN)
+		return -EINVAL;
+
+	if (!tcp_sk(sk)->md5sig_info) {
+		struct tcp_sock *tp = tcp_sk(sk);
+		struct tcp_md5sig_info *p;
+
+		p = kzalloc(sizeof(struct tcp_md5sig_info), GFP_KERNEL);
+		if (!p)
+			return -EINVAL;
+
+		tp->md5sig_info = p;
+
+	}
+
+	newkey = kmalloc(cmd.tcpm_keylen, GFP_KERNEL);
+	if (!newkey)
+		return -ENOMEM;
+	memcpy(newkey, cmd.tcpm_key, cmd.tcpm_keylen);
+	return tcp_v4_md5_do_add(sk, sin->sin_addr.s_addr,
+				 newkey, cmd.tcpm_keylen);
+}
+
+static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
+				   __be32 saddr, __be32 daddr,
+				   struct tcphdr *th, int protocol,
+				   int tcplen)
+{
+	struct scatterlist sg[4];
+	__u16 data_len;
+	int block = 0;
+#ifdef CONFIG_TCP_MD5SIG_DEBUG
+	int i;
+#endif
+	__u16 old_checksum;
+	struct tcp_md5sig_pool *hp;
+	struct tcp4_pseudohdr *bp;
+	struct hash_desc *desc;
+	int err;
+	unsigned int nbytes = 0;
+
+	/*
+	 * Okay, so RFC2385 is turned on for this connection,
+	 * so we need to generate the MD5 hash for the packet now.
+	 */
+
+	hp = tcp_get_md5sig_pool();
+	if (!hp)
+		goto clear_hash_noput;
+
+	bp = &hp->md5_blk.ip4;
+	desc = &hp->md5_desc;
+
+	/*
+	 * 1. the TCP pseudo-header (in the order: source IP address,
+	 * destination IP address, zero-padded protocol number, and
+	 * segment length)
+	 */
+	bp->saddr = saddr;
+	bp->daddr = daddr;
+	bp->pad = 0;
+	bp->protocol = protocol;
+	bp->len = htons(tcplen);
+	sg_set_buf(&sg[block++], bp, sizeof(*bp));
+	nbytes += sizeof(*bp);
+
+#ifdef CONFIG_TCP_MD5SIG_DEBUG
+	printk("Calcuating hash for: ");
+	for (i = 0; i < sizeof (*bp); i++)
+		printk ("%02x ", (unsigned int)((unsigned char *)bp)[i]);
+	printk(" ");
+#endif
+
+	/* 2. the TCP header, excluding options, and assuming a
+	 * checksum of zero/
+	 */
+	old_checksum = th->check;
+	th->check = 0;
+	sg_set_buf(&sg[block++], th, sizeof(struct tcphdr));
+	nbytes += sizeof(struct tcphdr);
+#ifdef CONFIG_TCP_MD5SIG_DEBUG
+	for (i = 0; i < sizeof (struct tcphdr); i++)
+		printk (" %02x", (unsigned int)((unsigned char *)th)[i]);
+#endif
+	/* 3. the TCP segment data (if any) */
+	data_len = tcplen - (th->doff << 2);
+	if (data_len > 0) {
+		unsigned char *data = (unsigned char *)th + (th->doff << 2);
+		sg_set_buf(&sg[block++], data, data_len);
+		nbytes += data_len;
+	}
+
+	/* 4. an independently-specified key or password, known to both
+	 * TCPs and presumably connection-specific
+	 */
+	sg_set_buf(&sg[block++], key->key, key->keylen);
+	nbytes += key->keylen;
+
+#ifdef CONFIG_TCP_MD5SIG_DEBUG
+	printk ("  and password: ");
+	for (i = 0; i < key->keylen; i++)
+		printk ("%02x ", (unsigned int)key->key[i]);
+#endif
+
+	/* Now store the Hash into the packet */
+	err = crypto_hash_init(desc);
+	if (err)
+		goto clear_hash;
+	err = crypto_hash_update(desc, sg, nbytes);
+	if (err)
+		goto clear_hash;
+	err = crypto_hash_final(desc, md5_hash);
+	if (err)
+		goto clear_hash;
+
+	/* Reset header, and free up the crypto */
+	tcp_put_md5sig_pool();
+	th->check = old_checksum;
+
+out:
+#ifdef CONFIG_TCP_MD5SIG_DEBUG
+	printk(" result:");
+	for (i = 0; i < 16; i++)
+		printk (" %02x", (unsigned int)(((u8*)md5_hash)[i]));
+	printk("\n");
+#endif
+	return 0;
+clear_hash:
+	tcp_put_md5sig_pool();
+clear_hash_noput:
+	memset(md5_hash, 0, 16);
+	goto out;
+}
+
+int tcp_v4_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
+			 struct sock *sk,
+			 struct dst_entry *dst,
+			 struct request_sock *req,
+			 struct tcphdr *th, int protocol,
+			 int tcplen)
+{
+	__be32 saddr, daddr;
+
+	if (sk) {
+		saddr = inet_sk(sk)->saddr;
+		daddr = inet_sk(sk)->daddr;
+	} else {
+		struct rtable *rt = (struct rtable *)dst;
+		BUG_ON(!rt);
+		saddr = rt->rt_src;
+		daddr = rt->rt_dst;
+	}
+	return tcp_v4_do_calc_md5_hash(md5_hash, key,
+				       saddr, daddr,
+				       th, protocol, tcplen);
+}
+
+EXPORT_SYMBOL(tcp_v4_calc_md5_hash);
+
+static int tcp_v4_inbound_md5_hash (struct sock *sk, struct sk_buff *skb)
+{
+	/*
+	 * This gets called for each TCP segment that arrives
+	 * so we want to be efficient.
+	 * We have 3 drop cases:
+	 * o No MD5 hash and one expected.
+	 * o MD5 hash and we're not expecting one.
+	 * o MD5 hash and its wrong.
+	 */
+	__u8 *hash_location = NULL;
+	struct tcp_md5sig_key *hash_expected;
+	struct iphdr *iph = skb->nh.iph;
+	struct tcphdr *th = skb->h.th;
+	int length = (th->doff << 2) - sizeof (struct tcphdr);
+	int genhash;
+	unsigned char *ptr;
+	unsigned char newhash[16];
+
+	hash_expected = tcp_v4_md5_do_lookup(sk, iph->saddr);
+
+	/*
+	 * If the TCP option length is less than the TCP_MD5SIG
+	 * option length, then we can shortcut
+	 */
+	if (length < TCPOLEN_MD5SIG) {
+		if (hash_expected)
+			return 1;
+		else
+			return 0;
+	}
+
+	/* Okay, we can't shortcut - we have to grub through the options */
+	ptr = (unsigned char *)(th + 1);
+	while (length > 0) {
+		int opcode = *ptr++;
+		int opsize;
+
+		switch (opcode) {
+		case TCPOPT_EOL:
+			goto done_opts;
+		case TCPOPT_NOP:
+			length--;
+			continue;
+		default:
+			opsize = *ptr++;
+			if (opsize < 2)
+				goto done_opts;
+			if (opsize > length)
+				goto done_opts;
+
+			if (opcode == TCPOPT_MD5SIG) {
+				hash_location = ptr;
+				goto done_opts;
+			}
+		}
+		ptr += opsize-2;
+		length -= opsize;
+	}
+done_opts:
+	/* We've parsed the options - do we have a hash? */
+	if (!hash_expected && !hash_location)
+		return 0;
+
+	if (hash_expected && !hash_location) {
+		if (net_ratelimit()) {
+			printk(KERN_INFO "MD5 Hash NOT expected but found "
+			       "(" NIPQUAD_FMT ", %d)->(" NIPQUAD_FMT ", %d)\n",
+			       NIPQUAD (iph->saddr), ntohs(th->source),
+			       NIPQUAD (iph->daddr), ntohs(th->dest));
+		}
+		return 1;
+	}
+
+	if (!hash_expected && hash_location) {
+		if (net_ratelimit()) {
+			printk(KERN_INFO "MD5 Hash NOT expected but found "
+			       "(" NIPQUAD_FMT ", %d)->(" NIPQUAD_FMT ", %d)\n",
+			       NIPQUAD (iph->saddr), ntohs(th->source),
+			       NIPQUAD (iph->daddr), ntohs(th->dest));
+		}
+		return 1;
+	}
+
+	/* Okay, so this is hash_expected and hash_location -
+	 * so we need to calculate the checksum.
+	 */
+	genhash = tcp_v4_do_calc_md5_hash(newhash,
+					  hash_expected,
+					  iph->saddr, iph->daddr,
+					  th, sk->sk_protocol,
+					  skb->len);
+
+	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
+		if (net_ratelimit()) {
+			printk(KERN_INFO "MD5 Hash failed for "
+			       "(" NIPQUAD_FMT ", %d)->(" NIPQUAD_FMT ", %d)%s\n",
+			       NIPQUAD (iph->saddr), ntohs(th->source),
+			       NIPQUAD (iph->daddr), ntohs(th->dest),
+			       genhash ? " tcp_v4_calc_md5_hash failed" : "");
+#ifdef CONFIG_TCP_MD5SIG_DEBUG
+			do {
+				int i;
+				printk("Received: ");
+				for (i = 0; i < 16; i++)
+					printk("%02x ", 0xff & (int)hash_location[i]);
+				printk("\n");
+				printk("Calculated: ");
+				for (i = 0; i < 16; i++)
+					printk("%02x ", 0xff & (int)newhash[i]);
+				printk("\n");
+			} while(0);
+#endif
+		}
+		return 1;
+	}
+	return 0;
+}
+
+#endif
+
 struct request_sock_ops tcp_request_sock_ops = {
 	.family		=	PF_INET,
 	.obj_size	=	sizeof(struct tcp_request_sock),
@@ -724,9 +1266,16 @@ struct request_sock_ops tcp_request_sock
 	.send_reset	=	tcp_v4_send_reset,
 };
 
+struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
+#ifdef CONFIG_TCP_MD5SIG
+	.md5_lookup	=	tcp_v4_reqsk_md5_lookup,
+#endif
+};
+
 static struct timewait_sock_ops tcp_timewait_sock_ops = {
 	.twsk_obj_size	= sizeof(struct tcp_timewait_sock),
 	.twsk_unique	= tcp_twsk_unique,
+	.twsk_destructor= tcp_twsk_destructor,
 };
 
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
@@ -774,6 +1323,10 @@ #endif
 	if (!req)
 		goto drop;
 
+#ifdef CONFIG_TCP_MD5SIG
+	tcp_rsk(req)->af_specific = &tcp_request_sock_ipv4_ops;
+#endif
+
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = 536;
 	tmp_opt.user_mss  = tcp_sk(sk)->rx_opt.user_mss;
@@ -892,6 +1445,9 @@ struct sock *tcp_v4_syn_recv_sock(struct
 	struct inet_sock *newinet;
 	struct tcp_sock *newtp;
 	struct sock *newsk;
+#ifdef CONFIG_TCP_MD5SIG
+	struct tcp_md5sig_key *key;
+#endif
 
 	if (sk_acceptq_is_full(sk))
 		goto exit_overflow;
@@ -926,6 +1482,24 @@ struct sock *tcp_v4_syn_recv_sock(struct
 	newtp->advmss = dst_metric(dst, RTAX_ADVMSS);
 	tcp_initialize_rcv_mss(newsk);
 
+#ifdef CONFIG_TCP_MD5SIG
+	/* Copy over the MD5 key from the original socket */
+	if ((key = tcp_v4_md5_do_lookup(sk, newinet->daddr)) != NULL) {
+		/*
+		 * We're using one, so create a matching key
+		 * on the newsk structure. If we fail to get
+		 * memory, then we end up not copying the key
+		 * across. Shucks.
+		 */
+		char *newkey = kmalloc(key->keylen, GFP_ATOMIC);
+		if (newkey) {
+			memcpy(newkey, key->key, key->keylen);
+			tcp_v4_md5_do_add(newsk, inet_sk(sk)->daddr,
+					  newkey, key->keylen);
+		}
+	}
+#endif
+
 	__inet_hash(&tcp_hashinfo, newsk, 0);
 	__inet_inherit_port(&tcp_hashinfo, sk, newsk);
 
@@ -1001,10 +1575,24 @@ static int tcp_v4_checksum_init(struct s
  */
 int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 {
+	struct sock *rsk;
+#ifdef CONFIG_TCP_MD5SIG
+	/*
+	 * We really want to reject the packet as early as possible
+	 * if:
+	 *  o We're expecting an MD5'd packet and this is no MD5 tcp option
+	 *  o There is an MD5 option and we're not expecting one
+	 */
+	if (tcp_v4_inbound_md5_hash (sk, skb))
+		goto discard;
+#endif
+
 	if (sk->sk_state == TCP_ESTABLISHED) { /* Fast path */
 		TCP_CHECK_TIMER(sk);
-		if (tcp_rcv_established(sk, skb, skb->h.th, skb->len))
+		if (tcp_rcv_established(sk, skb, skb->h.th, skb->len)) {
+			rsk = sk;
 			goto reset;
+		}
 		TCP_CHECK_TIMER(sk);
 		return 0;
 	}
@@ -1018,20 +1606,24 @@ int tcp_v4_do_rcv(struct sock *sk, struc
 			goto discard;
 
 		if (nsk != sk) {
-			if (tcp_child_process(sk, nsk, skb))
+			if (tcp_child_process(sk, nsk, skb)) {
+				rsk = nsk;
 				goto reset;
+			}
 			return 0;
 		}
 	}
 
 	TCP_CHECK_TIMER(sk);
-	if (tcp_rcv_state_process(sk, skb, skb->h.th, skb->len))
+	if (tcp_rcv_state_process(sk, skb, skb->h.th, skb->len)) {
+		rsk = sk;
 		goto reset;
+	}
 	TCP_CHECK_TIMER(sk);
 	return 0;
 
 reset:
-	tcp_v4_send_reset(skb);
+	tcp_v4_send_reset(rsk, skb);
 discard:
 	kfree_skb(skb);
 	/* Be careful here. If this function gets more complicated and
@@ -1140,7 +1732,7 @@ no_tcp_socket:
 bad_packet:
 		TCP_INC_STATS_BH(TCP_MIB_INERRS);
 	} else {
-		tcp_v4_send_reset(skb);
+		tcp_v4_send_reset(NULL, skb);
 	}
 
 discard_it:
@@ -1263,6 +1855,15 @@ #ifdef CONFIG_COMPAT
 #endif
 };
 
+struct tcp_sock_af_ops tcp_sock_ipv4_specific = {
+#ifdef CONFIG_TCP_MD5SIG
+	.md5_lookup		= tcp_v4_md5_lookup,
+	.calc_md5_hash		= tcp_v4_calc_md5_hash,
+	.md5_add		= tcp_v4_md5_add_func,
+	.md5_parse		= tcp_v4_parse_md5_keys,
+#endif
+};
+
 /* NOTE: A lot of things set to zero explicitly by call to
  *       sk_alloc() so need not be done here.
  */
@@ -1302,6 +1903,9 @@ static int tcp_v4_init_sock(struct sock 
 
 	icsk->icsk_af_ops = &ipv4_specific;
 	icsk->icsk_sync_mss = tcp_sync_mss;
+#ifdef CONFIG_TCP_MD5SIG
+	tp->af_specific = &tcp_sock_ipv4_specific;
+#endif
 
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
@@ -1325,6 +1929,15 @@ int tcp_v4_destroy_sock(struct sock *sk)
 	/* Cleans up our, hopefully empty, out_of_order_queue. */
   	__skb_queue_purge(&tp->out_of_order_queue);
 
+#ifdef CONFIG_TCP_MD5SIG
+	/* Clean up the MD5 key list, if any */
+	if (tp->md5sig_info) {
+		tcp_v4_clear_md5_list(sk);
+		kfree(tp->md5sig_info);
+		tp->md5sig_info = NULL;
+	}
+#endif
+
 #ifdef CONFIG_NET_DMA
 	/* Cleans up our sk_async_wait_queue */
   	__skb_queue_purge(&sk->sk_async_wait_queue);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 0163d98..ac55d88 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -306,6 +306,28 @@ #if defined(CONFIG_IPV6) || defined(CONF
 			tw->tw_ipv6only = np->ipv6only;
 		}
 #endif
+
+#ifdef CONFIG_TCP_MD5SIG
+		/*
+		 * The timewait bucket does not have the key DB from the
+		 * sock structure. We just make a quick copy of the
+		 * md5 key being used (if indeed we are using one)
+		 * so the timewait ack generating code has the key.
+		 */
+		do {
+			struct tcp_md5sig_key *key;
+			memset(tcptw->tw_md5_key, 0, sizeof(tcptw->tw_md5_key));
+			tcptw->tw_md5_keylen = 0;
+			key = tp->af_specific->md5_lookup(sk, sk);
+			if (key != NULL) {
+				memcpy(&tcptw->tw_md5_key, key->key, key->keylen);
+				tcptw->tw_md5_keylen = key->keylen;
+				if (tcp_alloc_md5sig_pool() == NULL)
+					BUG();
+			}
+		} while(0);
+#endif
+
 		/* Linkage updates. */
 		__inet_twsk_hashdance(tw, sk, &tcp_hashinfo);
 
@@ -337,6 +359,17 @@ #endif
 	tcp_done(sk);
 }
 
+void tcp_twsk_destructor(struct sock *sk)
+{
+	struct tcp_timewait_sock *twsk = tcp_twsk(sk);
+#ifdef CONFIG_TCP_MD5SIG
+	if (twsk->tw_md5_keylen)
+		tcp_put_md5sig_pool();
+#endif
+}
+
+EXPORT_SYMBOL_GPL(tcp_twsk_destructor);
+
 /* This is not only more efficient than what we used to do, it eliminates
  * a lot of code duplication between IPv4/IPv6 SYN recv processing. -DaveM
  *
@@ -435,6 +468,11 @@ struct sock *tcp_create_openreq_child(st
 			newtp->rx_opt.ts_recent_stamp = 0;
 			newtp->tcp_header_len = sizeof(struct tcphdr);
 		}
+#ifdef CONFIG_TCP_MD5SIG
+		newtp->md5sig_info = NULL;	/*XXX*/
+		if (newtp->af_specific->md5_lookup(sk, newsk))
+			newtp->tcp_header_len += TCPOLEN_MD5SIG_ALIGNED;
+#endif
 		if (skb->len >= TCP_MIN_RCVMSS+newtp->tcp_header_len)
 			newicsk->icsk_ack.last_seg_size = skb->len - newtp->tcp_header_len;
 		newtp->rx_opt.mss_clamp = req->mss;
@@ -617,6 +655,30 @@ struct sock *tcp_check_req(struct sock *
 								 req, NULL);
 		if (child == NULL)
 			goto listen_overflow;
+#ifdef CONFIG_TCP_MD5SIG
+		else {
+			/* Copy over the MD5 key from the original socket */
+			struct tcp_md5sig_key *key;
+			struct tcp_sock *tp = tcp_sk(sk);
+			key = tp->af_specific->md5_lookup(sk, child);
+			if (key != NULL) {
+				/*
+				 * We're using one, so create a matching key on the
+				 * newsk structure. If we fail to get memory then we
+				 * end up not copying the key across. Shucks.
+				 */
+				char *newkey = kmalloc(key->keylen, GFP_ATOMIC);
+				if (newkey) {
+					if (!tcp_alloc_md5sig_pool())
+						BUG();
+					memcpy(newkey, key->key, key->keylen);
+					tp->af_specific->md5_add(child, child,
+								 newkey,
+								 key->keylen);
+				}
+			}
+		}
+#endif
 
 		inet_csk_reqsk_queue_unlink(sk, req, prev);
 		inet_csk_reqsk_queue_removed(sk, req);
@@ -633,7 +695,7 @@ struct sock *tcp_check_req(struct sock *
 	embryonic_reset:
 		NET_INC_STATS_BH(LINUX_MIB_EMBRYONICRSTS);
 		if (!(flg & TCP_FLAG_RST))
-			req->rsk_ops->send_reset(skb);
+			req->rsk_ops->send_reset(sk, skb);
 
 		inet_csk_reqsk_queue_drop(sk, req, prev);
 		return NULL;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f22536e..ce1348d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -270,7 +270,7 @@ static u16 tcp_select_window(struct sock
 }
 
 static void tcp_build_and_update_options(__be32 *ptr, struct tcp_sock *tp,
-					 __u32 tstamp)
+					 __u32 tstamp, __u8 **md5_hash)
 {
 	if (tp->rx_opt.tstamp_ok) {
 		*ptr++ = htonl((TCPOPT_NOP << 24) |
@@ -298,16 +298,29 @@ static void tcp_build_and_update_options
 			tp->rx_opt.eff_sacks--;
 		}
 	}
+#ifdef CONFIG_TCP_MD5SIG
+	if (md5_hash) {
+		*ptr++ = htonl((TCPOPT_NOP << 24) |
+			       (TCPOPT_NOP << 16) |
+			       (TCPOPT_MD5SIG << 8) |
+			       TCPOLEN_MD5SIG);
+		*md5_hash = (__u8 *)ptr;
+	}
+#endif
 }
 
 /* Construct a tcp options header for a SYN or SYN_ACK packet.
  * If this is every changed make sure to change the definition of
  * MAX_SYN_SIZE to match the new maximum number of options that you
  * can generate.
+ *
+ * Note - that with the RFC2385 TCP option, we make room for the
+ * 16 byte MD5 hash. This will be filled in later, so the pointer for the
+ * location to be filled is passed back up.
  */
 static void tcp_syn_build_options(__be32 *ptr, int mss, int ts, int sack,
 				  int offer_wscale, int wscale, __u32 tstamp,
-				  __u32 ts_recent)
+				  __u32 ts_recent, __u8 **md5_hash)
 {
 	/* We always get an MSS option.
 	 * The option bytes which will be seen in normal data
@@ -346,6 +359,20 @@ static void tcp_syn_build_options(__be32
 			       (TCPOPT_WINDOW << 16) |
 			       (TCPOLEN_WINDOW << 8) |
 			       (wscale));
+#ifdef CONFIG_TCP_MD5SIG
+	/*
+	 * If MD5 is enabled, then we set the option, and include the size
+	 * (always 18). The actual MD5 hash is added just before the
+	 * packet is sent.
+	 */
+	if (md5_hash) {
+		*ptr++ = htonl((TCPOPT_NOP << 24) |
+			       (TCPOPT_NOP << 16) |
+			       (TCPOPT_MD5SIG << 8) |
+			       TCPOLEN_MD5SIG);
+		*md5_hash = (__u8 *) ptr;
+	}
+#endif
 }
 
 /* This routine actually transmits TCP packets queued in by
@@ -366,6 +393,10 @@ static int tcp_transmit_skb(struct sock 
 	struct tcp_sock *tp;
 	struct tcp_skb_cb *tcb;
 	int tcp_header_size;
+#ifdef CONFIG_TCP_MD5SIG
+	struct tcp_md5sig_key *md5;
+	__u8 *md5_hash_location;
+#endif
 	struct tcphdr *th;
 	int sysctl_flags;
 	int err;
@@ -424,6 +455,16 @@ #define SYSCTL_FLAG_SACK	0x4
 	if (tcp_packets_in_flight(tp) == 0)
 		tcp_ca_event(sk, CA_EVENT_TX_START);
 
+#ifdef CONFIG_TCP_MD5SIG
+	/*
+	 * Are we doing MD5 on this segment? If so - make
+	 * room for it.
+	 */
+	md5 = tp->af_specific->md5_lookup(sk, sk);
+	if (md5)
+		tcp_header_size += TCPOLEN_MD5SIG_ALIGNED;
+#endif
+
 	th = (struct tcphdr *) skb_push(skb, tcp_header_size);
 	skb->h.th = th;
 	skb_set_owner_w(skb, sk);
@@ -461,13 +502,34 @@ #define SYSCTL_FLAG_SACK	0x4
 				      (sysctl_flags & SYSCTL_FLAG_WSCALE),
 				      tp->rx_opt.rcv_wscale,
 				      tcb->when,
-				      tp->rx_opt.ts_recent);
+				      tp->rx_opt.ts_recent,
+
+#ifdef CONFIG_TCP_MD5SIG
+				      md5 ? &md5_hash_location :
+#endif
+				      NULL);
 	} else {
 		tcp_build_and_update_options((__be32 *)(th + 1),
-					     tp, tcb->when);
+					     tp, tcb->when,
+#ifdef CONFIG_TCP_MD5SIG
+					     md5 ? &md5_hash_location :
+#endif
+					     NULL);
 		TCP_ECN_send(sk, tp, skb, tcp_header_size);
 	}
 
+#ifdef CONFIG_TCP_MD5SIG
+	/* Calculate the MD5 hash, as we have all we need now */
+	if (md5) {
+		tp->af_specific->calc_md5_hash(md5_hash_location,
+					       md5,
+					       sk, NULL, NULL,
+					       skb->h.th,
+					       sk->sk_protocol,
+					       skb->len);
+	}
+#endif
+
 	icsk->icsk_af_ops->send_check(sk, skb->len, skb);
 
 	if (likely(tcb->flags & TCPCB_FLAG_ACK))
@@ -847,6 +909,11 @@ unsigned int tcp_current_mss(struct sock
 		mss_now -= (TCPOLEN_SACK_BASE_ALIGNED +
 			    (tp->rx_opt.eff_sacks * TCPOLEN_SACK_PERBLOCK));
 
+#ifdef CONFIG_TCP_MD5SIG
+	if (tp->af_specific->md5_lookup(sk, sk))
+		mss_now -= TCPOLEN_MD5SIG_ALIGNED;
+#endif
+
 	xmit_size_goal = mss_now;
 
 	if (doing_tso) {
@@ -2030,6 +2097,10 @@ struct sk_buff * tcp_make_synack(struct 
 	struct tcphdr *th;
 	int tcp_header_size;
 	struct sk_buff *skb;
+#ifdef CONFIG_TCP_MD5SIG
+	struct tcp_md5sig_key *md5;
+	__u8 *md5_hash_location;
+#endif
 
 	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15, 1, GFP_ATOMIC);
 	if (skb == NULL)
@@ -2045,6 +2116,13 @@ struct sk_buff * tcp_make_synack(struct 
 			   (ireq->wscale_ok ? TCPOLEN_WSCALE_ALIGNED : 0) +
 			   /* SACK_PERM is in the place of NOP NOP of TS */
 			   ((ireq->sack_ok && !ireq->tstamp_ok) ? TCPOLEN_SACKPERM_ALIGNED : 0));
+
+#ifdef CONFIG_TCP_MD5SIG
+	/* Are we doing MD5 on this segment? If so - make room for it */
+	md5 = tcp_rsk(req)->af_specific->md5_lookup(sk, req);
+	if (md5)
+		tcp_header_size += TCPOLEN_MD5SIG_ALIGNED;
+#endif
 	skb->h.th = th = (struct tcphdr *) skb_push(skb, tcp_header_size);
 
 	memset(th, 0, sizeof(struct tcphdr));
@@ -2082,11 +2160,29 @@ struct sk_buff * tcp_make_synack(struct 
 	tcp_syn_build_options((__be32 *)(th + 1), dst_metric(dst, RTAX_ADVMSS), ireq->tstamp_ok,
 			      ireq->sack_ok, ireq->wscale_ok, ireq->rcv_wscale,
 			      TCP_SKB_CB(skb)->when,
-			      req->ts_recent);
+			      req->ts_recent,
+			      (
+#ifdef CONFIG_TCP_MD5SIG
+			       md5 ? &md5_hash_location :
+#endif
+			       NULL)
+			      );
 
 	skb->csum = 0;
 	th->doff = (tcp_header_size >> 2);
 	TCP_INC_STATS(TCP_MIB_OUTSEGS);
+
+#ifdef CONFIG_TCP_MD5SIG
+	/* Okay, we have all we need - do the md5 hash if needed */
+	if (md5) {
+		tp->af_specific->calc_md5_hash(md5_hash_location,
+					       md5,
+					       NULL, dst, req,
+					       skb->h.th, sk->sk_protocol,
+					       skb->len);
+	}
+#endif
+
 	return skb;
 }
 
@@ -2105,6 +2201,11 @@ static void tcp_connect_init(struct sock
 	tp->tcp_header_len = sizeof(struct tcphdr) +
 		(sysctl_tcp_timestamps ? TCPOLEN_TSTAMP_ALIGNED : 0);
 
+#ifdef CONFIG_TCP_MD5SIG
+	if (tp->af_specific->md5_lookup(sk, sk) != NULL)
+		tp->tcp_header_len += TCPOLEN_MD5SIG_ALIGNED;
+#endif
+
 	/* If user gave his TCP_MAXSEG, record it to clamp */
 	if (tp->rx_opt.user_mss)
 		tp->rx_opt.mss_clamp = tp->rx_opt.user_mss;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 4c2a7c0..24b71bc 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -66,10 +66,13 @@ #include <asm/uaccess.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 
+#include <linux/crypto.h>
+#include <linux/scatterlist.h>
+
 /* Socket used for sending RSTs and ACKs */
 static struct socket *tcp6_socket;
 
-static void	tcp_v6_send_reset(struct sk_buff *skb);
+static void	tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb);
 static void	tcp_v6_reqsk_send_ack(struct sk_buff *skb, struct request_sock *req);
 static void	tcp_v6_send_check(struct sock *sk, int len, 
 				  struct sk_buff *skb);
@@ -78,6 +81,8 @@ static int	tcp_v6_do_rcv(struct sock *sk
 
 static struct inet_connection_sock_af_ops ipv6_mapped;
 static struct inet_connection_sock_af_ops ipv6_specific;
+static struct tcp_sock_af_ops tcp_sock_ipv6_specific;
+static struct tcp_sock_af_ops tcp_sock_ipv6_mapped_specific;
 
 static int tcp_v6_get_port(struct sock *sk, unsigned short snum)
 {
@@ -215,6 +220,9 @@ static int tcp_v6_connect(struct sock *s
 
 		icsk->icsk_af_ops = &ipv6_mapped;
 		sk->sk_backlog_rcv = tcp_v4_do_rcv;
+#ifdef CONFIG_TCP_MD5SIG
+		tp->af_specific = &tcp_sock_ipv6_mapped_specific;
+#endif
 
 		err = tcp_v4_connect(sk, (struct sockaddr *)&sin, sizeof(sin));
 
@@ -222,6 +230,9 @@ static int tcp_v6_connect(struct sock *s
 			icsk->icsk_ext_hdr_len = exthdrlen;
 			icsk->icsk_af_ops = &ipv6_specific;
 			sk->sk_backlog_rcv = tcp_v6_do_rcv;
+#ifdef CONFIG_TCP_MD5SIG
+			tp->af_specific = &tcp_sock_ipv6_specific;
+#endif
 			goto failure;
 		} else {
 			ipv6_addr_set(&np->saddr, 0, 0, htonl(0x0000FFFF),
@@ -526,6 +537,396 @@ static void tcp_v6_reqsk_destructor(stru
 		kfree_skb(inet6_rsk(req)->pktopts);
 }
 
+#ifdef CONFIG_TCP_MD5SIG
+static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(struct sock *sk,
+						   struct in6_addr *addr)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	int i;
+
+	BUG_ON(tp == NULL);
+
+	if (!tp->md5sig_info || !tp->md5sig_info->entries6)
+		return NULL;
+
+	for (i = 0; i < tp->md5sig_info->entries6; i++) {
+		if (ipv6_addr_cmp(&tp->md5sig_info->keys6[i].addr, addr) == 0)
+			return (struct tcp_md5sig_key *)&tp->md5sig_info->keys6[i];
+	}
+	return NULL;
+}
+
+static struct tcp_md5sig_key *tcp_v6_md5_lookup(struct sock *sk,
+						struct sock *addr_sk)
+{
+	return tcp_v6_md5_do_lookup(sk, &inet6_sk(addr_sk)->daddr);
+}
+
+static struct tcp_md5sig_key *tcp_v6_reqsk_md5_lookup(struct sock *sk,
+						      struct request_sock *req)
+{
+	return tcp_v6_md5_do_lookup(sk, &inet6_rsk(req)->rmt_addr);
+}
+
+static int tcp_v6_md5_do_add(struct sock *sk, struct in6_addr *peer,
+			     char *newkey, u8 newkeylen)
+{
+	/* Add key to the list */
+	struct tcp6_md5sig_key *key;
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct tcp6_md5sig_key *keys;
+
+	key = (struct tcp6_md5sig_key*) tcp_v6_md5_do_lookup(sk, peer);
+	if (key) {
+		/* modify existing entry - just update that one */
+		kfree(key->key);
+		key->key = newkey;
+		key->keylen = newkeylen;
+	} else {
+		/* reallocate new list if current one is full. */
+		if (!tp->md5sig_info) {
+			tp->md5sig_info = kzalloc(sizeof(*tp->md5sig_info), GFP_ATOMIC);
+			if (!tp->md5sig_info) {
+				kfree(newkey);
+				return -ENOMEM;
+			}
+		}
+		tcp_alloc_md5sig_pool();
+		if (tp->md5sig_info->alloced6 == tp->md5sig_info->entries6) {
+			keys = kmalloc((sizeof (tp->md5sig_info->keys6[0]) *
+				       (tp->md5sig_info->entries6 + 1)), GFP_ATOMIC);
+
+			if (!keys) {
+				tcp_free_md5sig_pool();
+				kfree(newkey);
+				return -ENOMEM;
+			}
+
+			if (tp->md5sig_info->entries6)
+				memmove(keys, tp->md5sig_info->keys6,
+					(sizeof (tp->md5sig_info->keys6[0]) *
+					 tp->md5sig_info->entries6));
+
+			kfree(tp->md5sig_info->keys6);
+			tp->md5sig_info->keys6 = keys;
+			tp->md5sig_info->alloced6++;
+		}
+
+		ipv6_addr_copy(&tp->md5sig_info->keys6[tp->md5sig_info->entries6].addr,
+			       peer);
+		tp->md5sig_info->keys6[tp->md5sig_info->entries6].key = newkey;
+		tp->md5sig_info->keys6[tp->md5sig_info->entries6].keylen = newkeylen;
+
+		tp->md5sig_info->entries6++;
+	}
+	return 0;
+}
+
+static int tcp_v6_md5_add_func(struct sock *sk, struct sock *addr_sk,
+			       u8 *newkey, __u8 newkeylen)
+{
+	return tcp_v6_md5_do_add(sk, &inet6_sk(addr_sk)->daddr,
+				 newkey, newkeylen);
+}
+
+static int tcp_v6_md5_do_del(struct sock *sk, struct in6_addr *peer)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	int i;
+
+	for (i = 0; i < tp->md5sig_info->entries6; i++) {
+		if (ipv6_addr_cmp(&tp->md5sig_info->keys6[i].addr, peer) == 0) {
+			/* Free the key */
+			kfree(tp->md5sig_info->keys6[i].key);
+			tp->md5sig_info->entries6--;
+
+			if (tp->md5sig_info->entries6 == 0) {
+				kfree(tp->md5sig_info->keys6);
+				tp->md5sig_info->keys6 = NULL;
+
+				tcp_free_md5sig_pool();
+
+				return 0;
+			} else {
+				/* shrink the database */
+				if (tp->md5sig_info->entries6 != i)
+					memmove(&tp->md5sig_info->keys6[i],
+						&tp->md5sig_info->keys6[i+1],
+						(tp->md5sig_info->entries6 - i)
+						* sizeof (tp->md5sig_info->keys6[0]));
+			}
+		}
+	}
+	return -ENOENT;
+}
+
+static void tcp_v6_clear_md5_list (struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	int i;
+
+	if (tp->md5sig_info->entries6) {
+		for (i = 0; i < tp->md5sig_info->entries6; i++)
+			kfree(tp->md5sig_info->keys6[i].key);
+		tp->md5sig_info->entries6 = 0;
+		tcp_free_md5sig_pool();
+	}
+
+	kfree(tp->md5sig_info->keys6);
+	tp->md5sig_info->keys6 = NULL;
+	tp->md5sig_info->alloced6 = 0;
+
+	if (tp->md5sig_info->entries4) {
+		for (i = 0; i < tp->md5sig_info->entries4; i++)
+			kfree(tp->md5sig_info->keys4[i].key);
+		tp->md5sig_info->entries4 = 0;
+		tcp_free_md5sig_pool();
+	}
+
+	kfree(tp->md5sig_info->keys4);
+	tp->md5sig_info->keys4 = NULL;
+	tp->md5sig_info->alloced4 = 0;
+}
+
+static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
+				  int optlen)
+{
+	struct tcp_md5sig cmd;
+	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)&cmd.tcpm_addr;
+	u8 *newkey;
+
+	if (optlen < sizeof(cmd))
+		return -EINVAL;
+
+	if (copy_from_user(&cmd, optval, sizeof(cmd)))
+		return -EFAULT;
+
+	if (sin6->sin6_family != AF_INET6)
+		return -EINVAL;
+
+	if (!cmd.tcpm_keylen) {
+		if (!tcp_sk(sk)->md5sig_info)
+			return -ENOENT;
+		if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_MAPPED)
+			return tcp_v4_md5_do_del(sk, sin6->sin6_addr.s6_addr32[3]);
+		return tcp_v6_md5_do_del(sk, &sin6->sin6_addr);
+	}
+
+	if (cmd.tcpm_keylen > TCP_MD5SIG_MAXKEYLEN)
+		return -EINVAL;
+
+	if (!tcp_sk(sk)->md5sig_info) {
+		struct tcp_sock *tp = tcp_sk(sk);
+		struct tcp_md5sig_info *p;
+
+		p = kzalloc(sizeof(struct tcp_md5sig_info), GFP_KERNEL);
+		if (!p)
+			return -ENOMEM;
+
+		tp->md5sig_info = p;
+	}
+
+	newkey = kmalloc(cmd.tcpm_keylen, GFP_KERNEL);
+	if (!newkey)
+		return -ENOMEM;
+	memcpy(newkey, cmd.tcpm_key, cmd.tcpm_keylen);
+	if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_MAPPED) {
+		return tcp_v4_md5_do_add(sk, sin6->sin6_addr.s6_addr32[3],
+					 newkey, cmd.tcpm_keylen);
+	}
+	return tcp_v6_md5_do_add(sk, &sin6->sin6_addr, newkey, cmd.tcpm_keylen);
+}
+
+static int tcp_v6_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
+				   struct in6_addr *saddr,
+				   struct in6_addr *daddr,
+				   struct tcphdr *th, int protocol,
+				   int tcplen)
+{
+	struct scatterlist sg[4];
+	__u16 data_len;
+	int block = 0;
+	__u16 cksum;
+	struct tcp_md5sig_pool *hp;
+	struct tcp6_pseudohdr *bp;
+	struct hash_desc *desc;
+	int err;
+	unsigned int nbytes = 0;
+
+	hp = tcp_get_md5sig_pool();
+	if (!hp) {
+		printk(KERN_WARNING "%s(): hash pool not found...\n", __FUNCTION__);
+		goto clear_hash_noput;
+	}
+	bp = &hp->md5_blk.ip6;
+	desc = &hp->md5_desc;
+
+	/* 1. TCP pseudo-header (RFC2460) */
+	ipv6_addr_copy(&bp->saddr, saddr);
+	ipv6_addr_copy(&bp->daddr, daddr);
+	bp->len = htonl(tcplen);
+	bp->protocol = htonl(protocol);
+
+	sg_set_buf(&sg[block++], bp, sizeof(*bp));
+	nbytes += sizeof(*bp);
+
+	/* 2. TCP header, excluding options */
+	cksum = th->check;
+	th->check = 0;
+	sg_set_buf(&sg[block++], th, sizeof(*th));
+	nbytes += sizeof(*th);
+
+	/* 3. TCP segment data (if any) */
+	data_len = tcplen - (th->doff << 2);
+	if (data_len > 0) {
+		u8 *data = (u8 *)th + (th->doff << 2);
+		sg_set_buf(&sg[block++], data, data_len);
+		nbytes += data_len;
+	}
+
+	/* 4. shared key */
+	sg_set_buf(&sg[block++], key->key, key->keylen);
+	nbytes += key->keylen;
+
+	/* Now store the hash into the packet */
+	err = crypto_hash_init(desc);
+	if (err) {
+		printk(KERN_WARNING "%s(): hash_init failed\n", __FUNCTION__);
+		goto clear_hash;
+	}
+	err = crypto_hash_update(desc, sg, nbytes);
+	if (err) {
+		printk(KERN_WARNING "%s(): hash_update failed\n", __FUNCTION__);
+		goto clear_hash;
+	}
+	err = crypto_hash_final(desc, md5_hash);
+	if (err) {
+		printk(KERN_WARNING "%s(): hash_final failed\n", __FUNCTION__);
+		goto clear_hash;
+	}
+
+	/* Reset header, and free up the crypto */
+	tcp_put_md5sig_pool();
+	th->check = cksum;
+out:
+	return 0;
+clear_hash:
+	tcp_put_md5sig_pool();
+clear_hash_noput:
+	memset(md5_hash, 0, 16);
+	goto out;
+}
+
+static int tcp_v6_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
+				struct sock *sk,
+				struct dst_entry *dst,
+				struct request_sock *req,
+				struct tcphdr *th, int protocol,
+				int tcplen)
+{
+	struct in6_addr *saddr, *daddr;
+
+	if (sk) {
+		saddr = &inet6_sk(sk)->saddr;
+		daddr = &inet6_sk(sk)->daddr;
+	} else {
+		saddr = &inet6_rsk(req)->loc_addr;
+		daddr = &inet6_rsk(req)->rmt_addr;
+	}
+	return tcp_v6_do_calc_md5_hash(md5_hash, key,
+				       saddr, daddr,
+				       th, protocol, tcplen);
+}
+
+static int tcp_v6_inbound_md5_hash (struct sock *sk, struct sk_buff *skb)
+{
+	__u8 *hash_location = NULL;
+	struct tcp_md5sig_key *hash_expected;
+	struct ipv6hdr *ip6h = skb->nh.ipv6h;
+	struct tcphdr *th = skb->h.th;
+	int length = (th->doff << 2) - sizeof (*th);
+	int genhash;
+	u8 *ptr;
+	u8 newhash[16];
+
+	hash_expected = tcp_v6_md5_do_lookup(sk, &ip6h->saddr);
+
+	/* If the TCP option is too short, we can short cut */
+	if (length < TCPOLEN_MD5SIG)
+		return hash_expected ? 1 : 0;
+
+	/* parse options */
+	ptr = (u8*)(th + 1);
+	while (length > 0) {
+		int opcode = *ptr++;
+		int opsize;
+
+		switch(opcode) {
+		case TCPOPT_EOL:
+			goto done_opts;
+		case TCPOPT_NOP:
+			length--;
+			continue;
+		default:
+			opsize = *ptr++;
+			if (opsize < 2 || opsize > length)
+				goto done_opts;
+			if (opcode == TCPOPT_MD5SIG) {
+				hash_location = ptr;
+				goto done_opts;
+			}
+		}
+		ptr += opsize - 2;
+		length -= opsize;
+	}
+
+done_opts:
+	/* do we have a hash as expected? */
+	if (!hash_expected) {
+		if (!hash_location)
+			return 0;
+		if (net_ratelimit()) {
+			printk(KERN_INFO "MD5 Hash NOT expected but found "
+			       "(" NIP6_FMT ", %u)->"
+			       "(" NIP6_FMT ", %u)\n",
+			       NIP6(ip6h->saddr), ntohs(th->source),
+			       NIP6(ip6h->daddr), ntohs(th->dest));
+		}
+		return 1;
+	}
+
+	if (!hash_location) {
+		if (net_ratelimit()) {
+			printk(KERN_INFO "MD5 Hash expected but NOT found "
+			       "(" NIP6_FMT ", %u)->"
+			       "(" NIP6_FMT ", %u)\n",
+			       NIP6(ip6h->saddr), ntohs(th->source),
+			       NIP6(ip6h->daddr), ntohs(th->dest));
+		}
+		return 1;
+	}
+
+	/* check the signature */
+	genhash = tcp_v6_do_calc_md5_hash(newhash,
+					  hash_expected,
+					  &ip6h->saddr, &ip6h->daddr,
+					  th, sk->sk_protocol,
+					  skb->len);
+	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
+		if (net_ratelimit()) {
+			printk(KERN_INFO "MD5 Hash %s for "
+			       "(" NIP6_FMT ", %u)->"
+			       "(" NIP6_FMT ", %u)\n",
+			       genhash ? "failed" : "mismatch",
+			       NIP6(ip6h->saddr), ntohs(th->source),
+			       NIP6(ip6h->daddr), ntohs(th->dest));
+		}
+		return 1;
+	}
+	return 0;
+}
+#endif
+
 static struct request_sock_ops tcp6_request_sock_ops = {
 	.family		=	AF_INET6,
 	.obj_size	=	sizeof(struct tcp6_request_sock),
@@ -535,9 +936,16 @@ static struct request_sock_ops tcp6_requ
 	.send_reset	=	tcp_v6_send_reset
 };
 
+struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
+#ifdef CONFIG_TCP_MD5SIG
+	.md5_lookup	=	tcp_v6_reqsk_md5_lookup,
+#endif
+};
+
 static struct timewait_sock_ops tcp6_timewait_sock_ops = {
 	.twsk_obj_size	= sizeof(struct tcp6_timewait_sock),
 	.twsk_unique	= tcp_twsk_unique,
+	.twsk_destructor= tcp_twsk_destructor,
 };
 
 static void tcp_v6_send_check(struct sock *sk, int len, struct sk_buff *skb)
@@ -574,11 +982,15 @@ static int tcp_v6_gso_send_check(struct 
 	return 0;
 }
 
-static void tcp_v6_send_reset(struct sk_buff *skb)
+static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcphdr *th = skb->h.th, *t1; 
 	struct sk_buff *buff;
 	struct flowi fl;
+	int tot_len = sizeof(*th);
+#ifdef CONFIG_TCP_MD5SIG
+	struct tcp_md5sig_key *key;
+#endif
 
 	if (th->rst)
 		return;
@@ -586,25 +998,35 @@ static void tcp_v6_send_reset(struct sk_
 	if (!ipv6_unicast_destination(skb))
 		return; 
 
+#ifdef CONFIG_TCP_MD5SIG
+	if (sk)
+		key = tcp_v6_md5_do_lookup(sk, &skb->nh.ipv6h->daddr);
+	else
+		key = NULL;
+
+	if (key)
+		tot_len += TCPOLEN_MD5SIG_ALIGNED;
+#endif
+
 	/*
 	 * We need to grab some memory, and put together an RST,
 	 * and then put it into the queue to be sent.
 	 */
 
-	buff = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) + sizeof(struct tcphdr),
+	buff = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) + tot_len,
 			 GFP_ATOMIC);
 	if (buff == NULL) 
 	  	return;
 
-	skb_reserve(buff, MAX_HEADER + sizeof(struct ipv6hdr) + sizeof(struct tcphdr));
+	skb_reserve(buff, MAX_HEADER + sizeof(struct ipv6hdr) + tot_len);
 
-	t1 = (struct tcphdr *) skb_push(buff,sizeof(struct tcphdr));
+	t1 = (struct tcphdr *) skb_push(buff, tot_len);
 
 	/* Swap the send and the receive. */
 	memset(t1, 0, sizeof(*t1));
 	t1->dest = th->source;
 	t1->source = th->dest;
-	t1->doff = sizeof(*t1)/4;
+	t1->doff = tot_len / 4;
 	t1->rst = 1;
   
 	if(th->ack) {
@@ -615,6 +1037,22 @@ static void tcp_v6_send_reset(struct sk_
 				    + skb->len - (th->doff<<2));
 	}
 
+#ifdef CONFIG_TCP_MD5SIG
+	if (key) {
+		u32 *opt = (u32*)(t1 + 1);
+		opt[0] = htonl((TCPOPT_NOP << 24) |
+			       (TCPOPT_NOP << 16) |
+			       (TCPOPT_MD5SIG << 8) |
+			       TCPOLEN_MD5SIG);
+		tcp_v6_do_calc_md5_hash((__u8*)&opt[1],
+					key,
+					&skb->nh.ipv6h->daddr,
+					&skb->nh.ipv6h->saddr,
+					t1, IPPROTO_TCP,
+					tot_len);
+	}
+#endif
+
 	buff->csum = csum_partial((char *)t1, sizeof(*t1), 0);
 
 	memset(&fl, 0, sizeof(fl));
@@ -645,15 +1083,37 @@ static void tcp_v6_send_reset(struct sk_
 	kfree_skb(buff);
 }
 
-static void tcp_v6_send_ack(struct sk_buff *skb, u32 seq, u32 ack, u32 win, u32 ts)
+static void tcp_v6_send_ack(struct tcp_timewait_sock *tw,
+			    struct sk_buff *skb, u32 seq, u32 ack, u32 win, u32 ts)
 {
 	struct tcphdr *th = skb->h.th, *t1;
 	struct sk_buff *buff;
 	struct flowi fl;
 	int tot_len = sizeof(struct tcphdr);
+	u32 *topt;
+#ifdef CONFIG_TCP_MD5SIG
+	struct tcp_md5sig_key *key;
+	struct tcp_md5sig_key tw_key;
+#endif
+
+#ifdef CONFIG_TCP_MD5SIG
+	if (!tw && skb->sk) {
+		key = tcp_v6_md5_do_lookup(skb->sk, &skb->nh.ipv6h->daddr);
+	} else if (tw && tw->tw_md5_keylen) {
+		tw_key.key = tw->tw_md5_key;
+		tw_key.keylen = tw->tw_md5_keylen;
+		key = &tw_key;
+	} else {
+		key = NULL;
+	}
+#endif
 
 	if (ts)
 		tot_len += TCPOLEN_TSTAMP_ALIGNED;
+#ifdef CONFIG_TCP_MD5SIG
+	if (key)
+		tot_len += TCPOLEN_MD5SIG_ALIGNED;
+#endif
 
 	buff = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) + tot_len,
 			 GFP_ATOMIC);
@@ -673,15 +1133,29 @@ static void tcp_v6_send_ack(struct sk_bu
 	t1->ack_seq = htonl(ack);
 	t1->ack = 1;
 	t1->window = htons(win);
+
+	topt = (u32*)(t1 + 1);
 	
 	if (ts) {
-		u32 *ptr = (u32*)(t1 + 1);
-		*ptr++ = htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |
-			       (TCPOPT_TIMESTAMP << 8) | TCPOLEN_TIMESTAMP);
-		*ptr++ = htonl(tcp_time_stamp);
-		*ptr = htonl(ts);
+		*topt++ = htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |
+				(TCPOPT_TIMESTAMP << 8) | TCPOLEN_TIMESTAMP);
+		*topt++ = htonl(tcp_time_stamp);
+		*topt = htonl(ts);
 	}
 
+#ifdef CONFIG_TCP_MD5SIG
+	if (key) {
+		*topt++ = htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |
+				(TCPOPT_MD5SIG << 8) | TCPOLEN_MD5SIG);
+		tcp_v6_do_calc_md5_hash((__u8 *)topt,
+					key,
+					&skb->nh.ipv6h->daddr,
+					&skb->nh.ipv6h->saddr,
+					t1, IPPROTO_TCP,
+					tot_len);
+	}
+#endif
+
 	buff->csum = csum_partial((char *)t1, tot_len, 0);
 
 	memset(&fl, 0, sizeof(fl));
@@ -712,9 +1186,9 @@ static void tcp_v6_send_ack(struct sk_bu
 static void tcp_v6_timewait_ack(struct sock *sk, struct sk_buff *skb)
 {
 	struct inet_timewait_sock *tw = inet_twsk(sk);
-	const struct tcp_timewait_sock *tcptw = tcp_twsk(sk);
+	struct tcp_timewait_sock *tcptw = tcp_twsk(sk);
 
-	tcp_v6_send_ack(skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
+	tcp_v6_send_ack(tcptw, skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
 			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale,
 			tcptw->tw_ts_recent);
 
@@ -723,7 +1197,7 @@ static void tcp_v6_timewait_ack(struct s
 
 static void tcp_v6_reqsk_send_ack(struct sk_buff *skb, struct request_sock *req)
 {
-	tcp_v6_send_ack(skb, tcp_rsk(req)->snt_isn + 1, tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd, req->ts_recent);
+	tcp_v6_send_ack(NULL, skb, tcp_rsk(req)->snt_isn + 1, tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd, req->ts_recent);
 }
 
 
@@ -794,6 +1268,10 @@ static int tcp_v6_conn_request(struct so
 	if (req == NULL)
 		goto drop;
 
+#ifdef CONFIG_TCP_MD5SIG
+	tcp_rsk(req)->af_specific = &tcp_request_sock_ipv6_ops;
+#endif
+
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = IPV6_MIN_MTU - sizeof(struct tcphdr) - sizeof(struct ipv6hdr);
 	tmp_opt.user_mss = tp->rx_opt.user_mss;
@@ -852,6 +1330,9 @@ static struct sock * tcp_v6_syn_recv_soc
 	struct tcp_sock *newtp;
 	struct sock *newsk;
 	struct ipv6_txoptions *opt;
+#ifdef CONFIG_TCP_MD5SIG
+	struct tcp_md5sig_key *key;
+#endif
 
 	if (skb->protocol == htons(ETH_P_IP)) {
 		/*
@@ -882,6 +1363,10 @@ static struct sock * tcp_v6_syn_recv_soc
 
 		inet_csk(newsk)->icsk_af_ops = &ipv6_mapped;
 		newsk->sk_backlog_rcv = tcp_v4_do_rcv;
+#ifdef CONFIG_TCP_MD5SIG
+		newtp->af_specific = &tcp_sock_ipv6_mapped_specific;
+#endif
+
 		newnp->pktoptions  = NULL;
 		newnp->opt	   = NULL;
 		newnp->mcast_oif   = inet6_iif(skb);
@@ -1016,6 +1501,23 @@ static struct sock * tcp_v6_syn_recv_soc
 
 	newinet->daddr = newinet->saddr = newinet->rcv_saddr = LOOPBACK4_IPV6;
 
+#ifdef CONFIG_TCP_MD5SIG
+	/* Copy over the MD5 key from the original socket */
+	if ((key = tcp_v6_md5_do_lookup(sk, &newnp->daddr)) != NULL) {
+		/* We're using one, so create a matching key
+		 * on the newsk structure. If we fail to get
+		 * memory, then we end up not copying the key
+		 * across. Shucks.
+		 */
+		char *newkey = kmalloc(key->keylen, GFP_ATOMIC);
+		if (newkey) {
+			memcpy(newkey, key->key, key->keylen);
+			tcp_v6_md5_do_add(newsk, &inet6_sk(sk)->daddr,
+					  newkey, key->keylen);
+		}
+	}
+#endif
+
 	__inet6_hash(&tcp_hashinfo, newsk);
 	inet_inherit_port(&tcp_hashinfo, sk, newsk);
 
@@ -1075,6 +1577,11 @@ static int tcp_v6_do_rcv(struct sock *sk
 	if (skb->protocol == htons(ETH_P_IP))
 		return tcp_v4_do_rcv(sk, skb);
 
+#ifdef CONFIG_TCP_MD5SIG
+	if (tcp_v6_inbound_md5_hash (sk, skb))
+		goto discard;
+#endif
+
 	if (sk_filter(sk, skb))
 		goto discard;
 
@@ -1140,7 +1647,7 @@ static int tcp_v6_do_rcv(struct sock *sk
 	return 0;
 
 reset:
-	tcp_v6_send_reset(skb);
+	tcp_v6_send_reset(sk, skb);
 discard:
 	if (opt_skb)
 		__kfree_skb(opt_skb);
@@ -1265,7 +1772,7 @@ no_tcp_socket:
 bad_packet:
 		TCP_INC_STATS_BH(TCP_MIB_INERRS);
 	} else {
-		tcp_v6_send_reset(skb);
+		tcp_v6_send_reset(NULL, skb);
 	}
 
 discard_it:
@@ -1344,6 +1851,15 @@ #ifdef CONFIG_COMPAT
 #endif
 };
 
+static struct tcp_sock_af_ops tcp_sock_ipv6_specific = {
+#ifdef CONFIG_TCP_MD5SIG
+	.md5_lookup	=	tcp_v6_md5_lookup,
+	.calc_md5_hash	=	tcp_v6_calc_md5_hash,
+	.md5_add	=	tcp_v6_md5_add_func,
+	.md5_parse	=	tcp_v6_parse_md5_keys,
+#endif
+};
+
 /*
  *	TCP over IPv4 via INET6 API
  */
@@ -1366,6 +1882,15 @@ #ifdef CONFIG_COMPAT
 #endif
 };
 
+static struct tcp_sock_af_ops tcp_sock_ipv6_mapped_specific = {
+#ifdef CONFIG_TCP_MD5SIG
+	.md5_lookup	=	tcp_v4_md5_lookup,
+	.calc_md5_hash	=	tcp_v4_calc_md5_hash,
+	.md5_add	=	tcp_v6_md5_add_func,
+	.md5_parse	=	tcp_v6_parse_md5_keys,
+#endif
+};
+
 /* NOTE: A lot of things set to zero explicitly by call to
  *       sk_alloc() so need not be done here.
  */
@@ -1405,6 +1930,10 @@ static int tcp_v6_init_sock(struct sock 
 	sk->sk_write_space = sk_stream_write_space;
 	sock_set_flag(sk, SOCK_USE_WRITE_QUEUE);
 
+#ifdef CONFIG_TCP_MD5SIG
+	tp->af_specific = &tcp_sock_ipv6_specific;
+#endif
+
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
@@ -1415,6 +1944,11 @@ static int tcp_v6_init_sock(struct sock 
 
 static int tcp_v6_destroy_sock(struct sock *sk)
 {
+#ifdef CONFIG_TCP_MD5SIG
+	/* Clean up the MD5 key list */
+	if (tcp_sk(sk)->md5sig_info)
+		tcp_v6_clear_md5_list(sk);
+#endif
 	tcp_v4_destroy_sock(sk);
 	return inet6_destroy_sock(sk);
 }

---
