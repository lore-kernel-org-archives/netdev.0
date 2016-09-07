From: "Francis Y. Yan" <francisyyan@gmail.com>
Subject: [PATCH net-next 2/2] tcp: put a TLV list of TCP stats in error queue
Date: Tue,  6 Sep 2016 18:32:41 -0700
Message-ID: <1473211961-107223-2-git-send-email-francisyyan@gmail.com>
References: <1473211961-107223-1-git-send-email-francisyyan@gmail.com>
Cc: netdev@vger.kernel.org, edumazet@google.com, soheil@google.com,
        ncardwell@google.com, "Francis Y. Yan" <francisyyan@gmail.com>,
        Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34989 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756096AbcIGBcx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 21:32:53 -0400
Received: by mail-pa0-f67.google.com with SMTP id pp5so67601pac.2
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 18:32:52 -0700 (PDT)
In-Reply-To: <1473211961-107223-1-git-send-email-francisyyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To export useful TCP statistics along with timestamps, such as
rwnd-limited time and min RTT, we enqueue a TLV list in error queue
immediately when a timestamp is generated.

Specifically, if user space requests SOF_TIMESTAMPING_TX_* timestamps
and sets SOF_TIMESTAMPING_OPT_STATS, the kernel will create a list of
TLVs (struct nlattr) containing all the statistics and store the list
in payload of the skb that is going to be enqueued into error queue.
Notice that SOF_TIMESTAMPING_OPT_STATS can only be set together with
SOF_TIMESTAMPING_OPT_TSONLY.

In addition, if the application in user space also enables receiving
timestamp (e.g. by SOF_TIMESTAMPING_SOFTWARE), calling recvfrom() on
error queue will return one more control message with a cmsg_type of
SCM_OPT_STATS containing the list of TLVs in its cmsg_data.

Signed-off-by: Francis Y. Yan <francisyyan@gmail.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 arch/alpha/include/uapi/asm/socket.h   |  2 ++
 arch/avr32/include/uapi/asm/socket.h   |  2 ++
 arch/frv/include/uapi/asm/socket.h     |  2 ++
 arch/ia64/include/uapi/asm/socket.h    |  2 ++
 arch/m32r/include/uapi/asm/socket.h    |  2 ++
 arch/mips/include/uapi/asm/socket.h    |  2 ++
 arch/mn10300/include/uapi/asm/socket.h |  2 ++
 arch/parisc/include/uapi/asm/socket.h  |  2 ++
 arch/powerpc/include/uapi/asm/socket.h |  2 ++
 arch/s390/include/uapi/asm/socket.h    |  2 ++
 arch/sparc/include/uapi/asm/socket.h   |  2 ++
 arch/xtensa/include/uapi/asm/socket.h  |  2 ++
 include/linux/tcp.h                    |  3 +++
 include/uapi/asm-generic/socket.h      |  2 ++
 include/uapi/linux/net_tstamp.h        |  3 ++-
 include/uapi/linux/tcp.h               |  7 +++++++
 net/core/skbuff.c                      | 10 ++++++++--
 net/core/sock.c                        |  7 +++++++
 net/ipv4/tcp.c                         | 23 +++++++++++++++++++++++
 net/socket.c                           |  7 ++++++-
 20 files changed, 82 insertions(+), 4 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 9e46d6e..c9f30508b 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -97,4 +97,6 @@
 
 #define SO_CNX_ADVICE		53
 
+#define SCM_OPT_STATS		54
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 1fd147f..e937d3f 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -90,4 +90,6 @@
 
 #define SO_CNX_ADVICE		53
 
+#define SCM_OPT_STATS		54
+
 #endif /* _UAPI__ASM_AVR32_SOCKET_H */
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index afbc98f0..f17c124 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -90,5 +90,7 @@
 
 #define SO_CNX_ADVICE		53
 
+#define SCM_OPT_STATS		54
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index 0018fad..bdd72e2 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -99,4 +99,6 @@
 
 #define SO_CNX_ADVICE		53
 
+#define SCM_OPT_STATS		54
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 5fe42fc..217e311 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -90,4 +90,6 @@
 
 #define SO_CNX_ADVICE		53
 
+#define SCM_OPT_STATS		54
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index 2027240a..76ea723 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -108,4 +108,6 @@
 
 #define SO_CNX_ADVICE		53
 
+#define SCM_OPT_STATS		54
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index 5129f23..a4c0295 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -90,4 +90,6 @@
 
 #define SO_CNX_ADVICE		53
 
+#define SCM_OPT_STATS		54
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index 9c935d7..05ef7c0 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -89,4 +89,6 @@
 
 #define SO_CNX_ADVICE		0x402E
 
+#define SCM_OPT_STATS		0x402F
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index 1672e33..fe2dea1 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -97,4 +97,6 @@
 
 #define SO_CNX_ADVICE		53
 
+#define SCM_OPT_STATS		54
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index 41b51c2..1bd8c67 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -96,4 +96,6 @@
 
 #define SO_CNX_ADVICE		53
 
+#define SCM_OPT_STATS		54
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index 31aede3..e1b2237 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -86,6 +86,8 @@
 
 #define SO_CNX_ADVICE		0x0037
 
+#define SCM_OPT_STATS		0x0038
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 81435d9..8aba6bd 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -101,4 +101,6 @@
 
 #define SO_CNX_ADVICE		53
 
+#define SCM_OPT_STATS		54
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index f5b588e..187af3a 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -427,4 +427,7 @@ static inline void tcp_saved_syn_free(struct tcp_sock *tp)
 
 u32 tcp_rwnd_limited_delta(const struct tcp_sock *tp);
 
+#define OPT_STATS_DEFAULT_SIZE 256
+void tcp_put_opt_stats(struct sock *sk, struct sk_buff *skb);
+
 #endif	/* _LINUX_TCP_H */
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 67d632f..5a4735f 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -92,4 +92,6 @@
 
 #define SO_CNX_ADVICE		53
 
+#define SCM_OPT_STATS		54
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
index 264e515..464dcca 100644
--- a/include/uapi/linux/net_tstamp.h
+++ b/include/uapi/linux/net_tstamp.h
@@ -25,8 +25,9 @@ enum {
 	SOF_TIMESTAMPING_TX_ACK = (1<<9),
 	SOF_TIMESTAMPING_OPT_CMSG = (1<<10),
 	SOF_TIMESTAMPING_OPT_TSONLY = (1<<11),
+	SOF_TIMESTAMPING_OPT_STATS = (1<<12),
 
-	SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_OPT_TSONLY,
+	SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_OPT_STATS,
 	SOF_TIMESTAMPING_MASK = (SOF_TIMESTAMPING_LAST - 1) |
 				 SOF_TIMESTAMPING_LAST
 };
diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index f1e2de4..9bee101 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -214,6 +214,13 @@ struct tcp_info {
 	__u64	tcpi_rwnd_limited;	/* total time (us) limited by rwnd */
 };
 
+/* netlink attributes type for SCM_OPT_STATS */
+enum {
+	TCP_NLA_UNSPEC,
+	TCP_NLA_RWND_LIMITED,	/* total time (us) limited by rwnd */
+	TCP_NLA_MIN_RTT,	/* min RTT in us */
+};
+
 /* for TCP_MD5SIG socket option */
 #define TCP_MD5SIG_MAXKEYLEN	80
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3864b4b6..f924b76 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3805,7 +3805,7 @@ void __skb_tstamp_tx(struct sk_buff *orig_skb,
 		     struct sock *sk, int tstype)
 {
 	struct sk_buff *skb;
-	bool tsonly;
+	bool tsonly, opt_stats;
 
 	if (!sk)
 		return;
@@ -3814,7 +3814,10 @@ void __skb_tstamp_tx(struct sk_buff *orig_skb,
 	if (!skb_may_tx_timestamp(sk, tsonly))
 		return;
 
-	if (tsonly)
+	opt_stats = sk->sk_tsflags & SOF_TIMESTAMPING_OPT_STATS;
+	if (opt_stats)
+		skb = alloc_skb(OPT_STATS_DEFAULT_SIZE, GFP_ATOMIC);
+	else if (tsonly)
 		skb = alloc_skb(0, GFP_ATOMIC);
 	else
 		skb = skb_clone(orig_skb, GFP_ATOMIC);
@@ -3824,6 +3827,9 @@ void __skb_tstamp_tx(struct sk_buff *orig_skb,
 	if (tsonly) {
 		skb_shinfo(skb)->tx_flags = skb_shinfo(orig_skb)->tx_flags;
 		skb_shinfo(skb)->tskey = skb_shinfo(orig_skb)->tskey;
+
+		if (opt_stats)
+			tcp_put_opt_stats(sk, skb);
 	}
 
 	if (hwtstamps)
diff --git a/net/core/sock.c b/net/core/sock.c
index 51a7304..d5650fa 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -853,6 +853,13 @@ set_rcvbuf:
 				sk->sk_tskey = 0;
 			}
 		}
+
+		if (val & SOF_TIMESTAMPING_OPT_STATS &&
+		    !(val & SOF_TIMESTAMPING_OPT_TSONLY)) {
+			ret = -EINVAL;
+			break;
+		}
+
 		sk->sk_tsflags = val;
 		if (val & SOF_TIMESTAMPING_RX_SOFTWARE)
 			sock_enable_timestamp(sk,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index ed77f2c..d3ded20 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2787,6 +2787,29 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 }
 EXPORT_SYMBOL_GPL(tcp_get_info);
 
+void tcp_put_opt_stats(struct sock *sk, struct sk_buff *skb)
+{
+	const struct tcp_sock *tp = tcp_sk(sk);
+	unsigned int start;
+	u64 rwnd_limited;
+
+	do {
+		start = read_seqcount_begin(&tp->seqcnt);
+		rwnd_limited = tp->rwnd_limited + tcp_rwnd_limited_delta(tp);
+	} while (read_seqcount_retry(&tp->seqcnt, start));
+
+	if (nla_put(skb, TCP_NLA_RWND_LIMITED, sizeof(u64), &rwnd_limited))
+		goto nla_put_failure;
+
+	if (nla_put_u32(skb, TCP_NLA_MIN_RTT, tcp_min_rtt(tp)))
+		goto nla_put_failure;
+
+	return;
+
+nla_put_failure:
+	WARN_ONCE(1, "Not enough space for TCP stats\n");
+}
+
 static int do_tcp_getsockopt(struct sock *sk, int level,
 		int optname, char __user *optval, int __user *optlen)
 {
diff --git a/net/socket.c b/net/socket.c
index a1bd161..f1950d51 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -667,9 +667,14 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 	    (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
 	    ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2))
 		empty = 0;
-	if (!empty)
+	if (!empty) {
 		put_cmsg(msg, SOL_SOCKET,
 			 SCM_TIMESTAMPING, sizeof(tss), &tss);
+
+		if (sk->sk_tsflags & SOF_TIMESTAMPING_OPT_STATS)
+			put_cmsg(msg, SOL_SOCKET, SCM_OPT_STATS,
+				 skb->len, skb->data);
+	}
 }
 EXPORT_SYMBOL_GPL(__sock_recv_timestamp);
 
-- 
2.8.0.rc3.226.g39d4020
