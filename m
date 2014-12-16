From: rapier <rapier@psc.edu>
Subject: [PATCH net-next 1/3] Implementation of RFC 4898 Extended TCP Statistics
 (Web10G)
Date: Tue, 16 Dec 2014 12:50:07 -0500
Message-ID: <549070CF.1010506@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.70.106]:39692 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751062AbaLPRuI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2014 12:50:08 -0500
Received: from CMU-785477.WV.CC.CMU.EDU (CMU-785477.WV.CC.CMU.EDU [128.237.173.182])
	(authenticated bits=0)
	by mailer2.psc.edu (8.13.8/8.13.8) with ESMTP id sBGHo7NL012576
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 12:50:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides the kernel instrument set. While this patch
compiles and runs it does not have control and management capabilities.
These are provided in the next patch submission.

---
  include/linux/tcp.h      |   8 +
  include/net/tcp.h        |   1 +
  include/net/tcp_estats.h | 376 ++++++++++++++++++++++++++++++++++++++=
+++++++++
  include/uapi/linux/tcp.h |   6 +-
  net/ipv4/tcp.c           |  21 ++-
  net/ipv4/tcp_cong.c      |   3 +
  net/ipv4/tcp_htcp.c      |   1 +
  net/ipv4/tcp_input.c     | 116 +++++++++++++--
  net/ipv4/tcp_ipv4.c      |  10 ++
  net/ipv4/tcp_output.c    |  61 +++++++-
  net/ipv4/tcp_timer.c     |   3 +
  net/ipv6/tcp_ipv6.c      |   7 +
  12 files changed, 592 insertions(+), 21 deletions(-)
  create mode 100644 include/net/tcp_estats.h

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 67309ec..8758360 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -126,6 +126,10 @@ static inline struct tcp_request_sock *tcp_rsk(con=
st struct request_sock *req)
  	return (struct tcp_request_sock *)req;
  }
 =20
+#ifdef CONFIG_TCP_ESTATS
+struct tcp_estats;
+#endif
+
  struct tcp_sock {
  	/* inet_connection_sock has to be the first member of tcp_sock */
  	struct inet_connection_sock	inet_conn;
@@ -309,6 +313,10 @@ struct tcp_sock {
  	struct tcp_md5sig_info	__rcu *md5sig_info;
  #endif
 =20
+#ifdef CONFIG_TCP_ESTATS
+	struct tcp_estats	*tcp_stats;
+#endif
+
  /* TCP fastopen related information */
  	struct tcp_fastopen_request *fastopen_req;
  	/* fastopen_rsk points to request_sock that resulted in this big
diff --git a/include/net/tcp.h b/include/net/tcp.h
index f50f29faf..9f7e31e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -43,6 +43,7 @@
  #include <net/tcp_states.h>
  #include <net/inet_ecn.h>
  #include <net/dst.h>
+#include <net/tcp_estats.h>
 =20
  #include <linux/seq_file.h>
  #include <linux/memcontrol.h>
diff --git a/include/net/tcp_estats.h b/include/net/tcp_estats.h
new file mode 100644
index 0000000..ff6000e
--- /dev/null
+++ b/include/net/tcp_estats.h
@@ -0,0 +1,376 @@
+/*
+ * include/net/tcp_estats.h
+ *
+ * Implementation of TCP Extended Statistics MIB (RFC 4898)
+ *
+ * Authors:
+ *   John Estabrook <jsestabrook@gmail.com>
+ *   Andrew K. Adams <akadams@psc.edu>
+ *   Kevin Hogan <kwabena@google.com>
+ *   Dominin Hamon <dma@stripysock.com>
+ *   John Heffner <johnwheffner@gmail.com>
+ *
+ * The Web10Gig project.  See http://www.web10gig.org
+ *
+ * Copyright =A9 2011, Pittsburgh Supercomputing Center (PSC).
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#ifndef _TCP_ESTATS_H
+#define _TCP_ESTATS_H
+
+#include <net/sock.h>
+#include <linux/idr.h>
+#include <linux/in.h>
+#include <linux/jump_label.h>
+#include <linux/spinlock.h>
+#include <linux/tcp.h>
+#include <linux/workqueue.h>
+
+/* defines number of seconds that stats persist after connection ends =
*/
+#define TCP_ESTATS_PERSIST_DELAY_SECS 5
+
+enum tcp_estats_sndlim_states {
+	TCP_ESTATS_SNDLIM_NONE =3D -1,
+	TCP_ESTATS_SNDLIM_SENDER,
+	TCP_ESTATS_SNDLIM_CWND,
+	TCP_ESTATS_SNDLIM_RWIN,
+	TCP_ESTATS_SNDLIM_STARTUP,
+	TCP_ESTATS_SNDLIM_TSODEFER,
+	TCP_ESTATS_SNDLIM_PACE,
+	TCP_ESTATS_SNDLIM_NSTATES	/* Keep at end */
+};
+
+enum tcp_estats_addrtype {
+	TCP_ESTATS_ADDRTYPE_IPV4 =3D 1,
+	TCP_ESTATS_ADDRTYPE_IPV6 =3D 2
+};
+
+enum tcp_estats_softerror_reason {
+	TCP_ESTATS_SOFTERROR_BELOW_DATA_WINDOW =3D 1,
+	TCP_ESTATS_SOFTERROR_ABOVE_DATA_WINDOW =3D 2,
+	TCP_ESTATS_SOFTERROR_BELOW_ACK_WINDOW =3D 3,
+	TCP_ESTATS_SOFTERROR_ABOVE_ACK_WINDOW =3D 4,
+	TCP_ESTATS_SOFTERROR_BELOW_TS_WINDOW =3D 5,
+	TCP_ESTATS_SOFTERROR_ABOVE_TS_WINDOW =3D 6,
+	TCP_ESTATS_SOFTERROR_DATA_CHECKSUM =3D 7,
+	TCP_ESTATS_SOFTERROR_OTHER =3D 8,
+};
+
+#define TCP_ESTATS_INACTIVE	2
+#define TCP_ESTATS_ACTIVE	1
+
+#define TCP_ESTATS_TABLEMASK_INACTIVE	0x00
+#define TCP_ESTATS_TABLEMASK_ACTIVE	0x01
+#define TCP_ESTATS_TABLEMASK_PERF	0x02
+#define TCP_ESTATS_TABLEMASK_PATH	0x04
+#define TCP_ESTATS_TABLEMASK_STACK	0x08
+#define TCP_ESTATS_TABLEMASK_APP	0x10
+#define TCP_ESTATS_TABLEMASK_EXTRAS	0x40
+
+#ifdef CONFIG_TCP_ESTATS
+
+extern struct static_key tcp_estats_enabled;
+
+#define TCP_ESTATS_CHECK(tp, table, expr)				\
+	do {								\
+		if (static_key_false(&tcp_estats_enabled)) {		\
+			if (likely((tp)->tcp_stats) &&			\
+			    likely((tp)->tcp_stats->tables.table)) {	\
+				(expr);					\
+			}						\
+		}							\
+	} while (0)
+
+#define TCP_ESTATS_VAR_INC(tp, table, var)				\
+	TCP_ESTATS_CHECK(tp, table, ++((tp)->tcp_stats->tables.table->var))
+#define TCP_ESTATS_VAR_DEC(tp, table, var)				\
+	TCP_ESTATS_CHECK(tp, table, --((tp)->tcp_stats->tables.table->var))
+#define TCP_ESTATS_VAR_ADD(tp, table, var, val)				\
+	TCP_ESTATS_CHECK(tp, table,					\
+			 ((tp)->tcp_stats->tables.table->var) +=3D (val))
+#define TCP_ESTATS_VAR_SET(tp, table, var, val)				\
+	TCP_ESTATS_CHECK(tp, table,					\
+			 ((tp)->tcp_stats->tables.table->var) =3D (val))
+#define TCP_ESTATS_UPDATE(tp, func)					\
+	do {								\
+		if (static_key_false(&tcp_estats_enabled)) {		\
+			if (likely((tp)->tcp_stats)) {			\
+				(func);					\
+			}						\
+		}							\
+	} while (0)
+
+/*
+ * Variables that can be read and written directly.
+ *
+ * Contains all variables from RFC 4898. Commented fields are
+ * either not implemented (only StartTimeStamp
+ * remains unimplemented in this release) or have
+ * handlers and do not need struct storage.
+ */
+struct tcp_estats_connection_table {
+	u32			AddressType;
+	union { struct in_addr addr; struct in6_addr addr6; }	LocalAddress;
+	union { struct in_addr addr; struct in6_addr addr6; }	RemAddress;
+	u16			LocalPort;
+	u16			RemPort;
+};
+
+struct tcp_estats_perf_table {
+	u32		SegsOut;
+	u32		DataSegsOut;
+	u64		DataOctetsOut;
+	u32		SegsRetrans;
+	u32		OctetsRetrans;
+	u32		SegsIn;
+	u32		DataSegsIn;
+	u64		DataOctetsIn;
+	/*		ElapsedSecs */
+	/*		ElapsedMicroSecs */
+	/*		StartTimeStamp */
+	/*		CurMSS */
+	/*		PipeSize */
+	u32		MaxPipeSize;
+	/*		SmoothedRTT */
+	/*		CurRTO */
+	u32		CongSignals;
+	/*		CurCwnd */
+	/*		CurSsthresh */
+	u32		Timeouts;
+	/*		CurRwinSent */
+	u32		MaxRwinSent;
+	u32		ZeroRwinSent;
+	/*		CurRwinRcvd */
+	u32		MaxRwinRcvd;
+	u32		ZeroRwinRcvd;
+	/*		SndLimTransRwin */
+	/*		SndLimTransCwnd */
+	/*		SndLimTransSnd */
+	/*		SndLimTimeRwin */
+	/*		SndLimTimeCwnd */
+	/*		SndLimTimeSnd */
+	u32		snd_lim_trans[TCP_ESTATS_SNDLIM_NSTATES];
+	u32		snd_lim_time[TCP_ESTATS_SNDLIM_NSTATES];
+};
+
+struct tcp_estats_path_table {
+	/*		RetranThresh */
+	u32		NonRecovDAEpisodes;
+	u32		SumOctetsReordered;
+	u32		NonRecovDA;
+	u32		SampleRTT;
+	/*		RTTVar */
+	u32		MaxRTT;
+	u32		MinRTT;
+	u64		SumRTT;
+	u32		CountRTT;
+	u32		MaxRTO;
+	u32		MinRTO;
+	u8		IpTtl;
+	u8		IpTosIn;
+	/*		IpTosOut */
+	u32		PreCongSumCwnd;
+	u32		PreCongSumRTT;
+	u32		PostCongSumRTT;
+	u32		PostCongCountRTT;
+	u32		ECNsignals;
+	u32		DupAckEpisodes;
+	/*		RcvRTT */
+	u32		DupAcksOut;
+	u32		CERcvd;
+	u32		ECESent;
+};
+
+struct tcp_estats_stack_table {
+	u32		ActiveOpen;
+	/*		MSSSent */
+	/*		MSSRcvd */
+	/*		WinScaleSent */
+	/*		WinScaleRcvd */
+	/*		TimeStamps */
+	/*		ECN */
+	/*		WillSendSACK */
+	/*		WillUseSACK */
+	/*		State */
+	/*		Nagle */
+	u32		MaxSsCwnd;
+	u32		MaxCaCwnd;
+	u32		MaxSsthresh;
+	u32		MinSsthresh;
+	/*		InRecovery */
+	u32		DupAcksIn;
+	u32		SpuriousFrDetected;
+	u32		SpuriousRtoDetected;
+	u32		SoftErrors;
+	u32		SoftErrorReason;
+	u32		SlowStart;
+	u32		CongAvoid;
+	u32		OtherReductions;
+	u32		CongOverCount;
+	u32		FastRetran;
+	u32		SubsequentTimeouts;
+	/*		CurTimeoutCount */
+	u32		AbruptTimeouts;
+	u32		SACKsRcvd;
+	u32		SACKBlocksRcvd;
+	u32		SendStall;
+	u32		DSACKDups;
+	u32		MaxMSS;
+	u32		MinMSS;
+	u32		SndInitial;
+	u32		RecInitial;
+	/*		CurRetxQueue */
+	/*		MaxRetxQueue */
+	/*		CurReasmQueue */
+	u32		MaxReasmQueue;
+	u32		EarlyRetrans;
+	u32		EarlyRetransDelay;
+};
+
+struct tcp_estats_app_table {
+	/*		SndUna */
+	/*		SndNxt */
+	u32		SndMax;
+	u64		ThruOctetsAcked;
+	/*		RcvNxt */
+	u64		ThruOctetsReceived;
+	/*		CurAppWQueue */
+	u32		MaxAppWQueue;
+	/*		CurAppRQueue */
+	u32		MaxAppRQueue;
+};
+
+/*
+    currently, no backing store is needed for tuning elements in
+     web10g - they are all read or written to directly in other
+     data structures (such as the socket)
+*/
+
+struct tcp_estats_extras_table {
+	/*		OtherReductionsCV */
+	u32		OtherReductionsCM;
+	u32		Priority;
+};
+
+struct tcp_estats_tables {
+	struct tcp_estats_connection_table	*connection_table;
+	struct tcp_estats_perf_table		*perf_table;
+	struct tcp_estats_path_table		*path_table;
+	struct tcp_estats_stack_table		*stack_table;
+	struct tcp_estats_app_table		*app_table;
+	struct tcp_estats_extras_table		*extras_table;
+};
+
+struct tcp_estats {
+	int				tcpe_cid; /* idr map id */
+
+	struct sock			*sk;
+	kuid_t				uid;
+	kgid_t				gid;
+	int				ids;
+
+	atomic_t			users;
+
+	enum tcp_estats_sndlim_states	limstate;
+	ktime_t				limstate_ts;
+#ifdef CONFIG_TCP_ESTATS_STRICT_ELAPSEDTIME
+	ktime_t				start_ts;
+	ktime_t				current_ts;
+#else
+	unsigned long			start_ts;
+	unsigned long			current_ts;
+#endif
+	struct timeval			start_tv;
+
+        int				queued;
+        struct work_struct		create_notify;
+        struct work_struct		establish_notify;
+        struct delayed_work		destroy_notify;
+
+	struct tcp_estats_tables	tables;
+
+	struct rcu_head			rcu;
+};
+
+extern struct idr tcp_estats_idr;
+
+extern int tcp_estats_wq_enabled;
+extern struct workqueue_struct *tcp_estats_wq;
+extern void (*create_notify_func)(struct work_struct *work);
+extern void (*establish_notify_func)(struct work_struct *work);
+extern void (*destroy_notify_func)(struct work_struct *work);
+
+extern unsigned long persist_delay;
+extern spinlock_t tcp_estats_idr_lock;
+
+/* For the TCP code */
+extern int  tcp_estats_create(struct sock *sk, enum tcp_estats_addrtyp=
e t,
+			      int active);
+extern void tcp_estats_destroy(struct sock *sk);
+extern void tcp_estats_establish(struct sock *sk);
+extern void tcp_estats_free(struct rcu_head *rcu);
+
+extern void tcp_estats_update_snd_nxt(struct tcp_sock *tp);
+extern void tcp_estats_update_acked(struct tcp_sock *tp, u32 ack);
+extern void tcp_estats_update_rtt(struct sock *sk, unsigned long rtt_s=
ample);
+extern void tcp_estats_update_timeout(struct sock *sk);
+extern void tcp_estats_update_mss(struct tcp_sock *tp);
+extern void tcp_estats_update_rwin_rcvd(struct tcp_sock *tp);
+extern void tcp_estats_update_sndlim(struct tcp_sock *tp,
+				     enum tcp_estats_sndlim_states why);
+extern void tcp_estats_update_rcvd(struct tcp_sock *tp, u32 seq);
+extern void tcp_estats_update_rwin_sent(struct tcp_sock *tp);
+extern void tcp_estats_update_congestion(struct tcp_sock *tp);
+extern void tcp_estats_update_post_congestion(struct tcp_sock *tp);
+extern void tcp_estats_update_segsend(struct sock *sk, int pcount,
+                                      u32 seq, u32 end_seq, int flags)=
;
+extern void tcp_estats_update_segrecv(struct tcp_sock *tp, struct sk_b=
uff *skb);
+extern void tcp_estats_update_finish_segrecv(struct tcp_sock *tp);
+extern void tcp_estats_update_writeq(struct sock *sk);
+extern void tcp_estats_update_recvq(struct sock *sk);
+
+extern void tcp_estats_init(void);
+
+static inline void tcp_estats_use(struct tcp_estats *stats)
+{
+	atomic_inc(&stats->users);
+}
+
+static inline int tcp_estats_use_if_valid(struct tcp_estats *stats)
+{
+	return atomic_inc_not_zero(&stats->users);
+}
+
+static inline void tcp_estats_unuse(struct tcp_estats *stats)
+{
+	if (atomic_dec_and_test(&stats->users)) {
+		sock_put(stats->sk);
+		stats->sk =3D NULL;
+		call_rcu(&stats->rcu, tcp_estats_free);
+	}
+}
+
+#else /* !CONFIG_TCP_ESTATS */
+
+#define tcp_estats_enabled	(0)
+
+#define TCP_ESTATS_VAR_INC(tp, table, var)	do {} while (0)
+#define TCP_ESTATS_VAR_DEC(tp, table, var)	do {} while (0)
+#define TCP_ESTATS_VAR_ADD(tp, table, var, val)	do {} while (0)
+#define TCP_ESTATS_VAR_SET(tp, table, var, val)	do {} while (0)
+#define TCP_ESTATS_UPDATE(tp, func)		do {} while (0)
+
+static inline void tcp_estats_init(void) { }
+static inline void tcp_estats_establish(struct sock *sk) { }
+static inline void tcp_estats_create(struct sock *sk,
+				     enum tcp_estats_addrtype t,
+				     int active) { }
+static inline void tcp_estats_destroy(struct sock *sk) { }
+
+#endif /* CONFIG_TCP_ESTATS */
+
+#endif /* _TCP_ESTATS_H */
diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index 3b97183..5dae043 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -186,9 +186,13 @@ struct tcp_info {
  	__u32	tcpi_rcv_space;
 =20
  	__u32	tcpi_total_retrans;
-
  	__u64	tcpi_pacing_rate;
  	__u64	tcpi_max_pacing_rate;
+
+#ifdef CONFIG_TCP_ESTATS
+	/* RFC 4898 extended stats Info */
+	__u32	tcpi_estats_cid;
+#endif
  };
 =20
  /* for TCP_MD5SIG socket option */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3075723..698dbb7 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -418,6 +418,10 @@ void tcp_init_sock(struct sock *sk)
  	sk->sk_sndbuf =3D sysctl_tcp_wmem[1];
  	sk->sk_rcvbuf =3D sysctl_tcp_rmem[1];
 =20
+#ifdef CONFIG_TCP_ESTATS
+	tp->tcp_stats =3D NULL;
+#endif
+
  	local_bh_disable();
  	sock_update_memcg(sk);
  	sk_sockets_allocated_inc(sk);
@@ -972,6 +976,9 @@ wait_for_memory:
  		tcp_push(sk, flags & ~MSG_MORE, mss_now,
  			 TCP_NAGLE_PUSH, size_goal);
 =20
+		if (copied)
+                        TCP_ESTATS_UPDATE(tp, tcp_estats_update_writeq=
(sk));
+
  		if ((err =3D sk_stream_wait_memory(sk, &timeo)) !=3D 0)
  			goto do_error;
 =20
@@ -1264,9 +1271,11 @@ new_segment:
  wait_for_sndbuf:
  			set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
  wait_for_memory:
-			if (copied)
+			if (copied) {
  				tcp_push(sk, flags & ~MSG_MORE, mss_now,
  					 TCP_NAGLE_PUSH, size_goal);
+				TCP_ESTATS_UPDATE(tp, tcp_estats_update_writeq(sk));
+			}
 =20
  			if ((err =3D sk_stream_wait_memory(sk, &timeo)) !=3D 0)
  				goto do_error;
@@ -1658,6 +1667,8 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *=
sk, struct msghdr *msg,
  			     *seq, TCP_SKB_CB(skb)->seq, tp->rcv_nxt, flags);
  		}
 =20
+		TCP_ESTATS_UPDATE(tp, tcp_estats_update_recvq(sk));
+
  		/* Well, if we have backlog, try to process it now yet. */
 =20
  		if (copied >=3D target && !sk->sk_backlog.tail)
@@ -2684,6 +2695,11 @@ void tcp_get_info(const struct sock *sk, struct =
tcp_info *info)
  					sk->sk_pacing_rate : ~0ULL;
  	info->tcpi_max_pacing_rate =3D sk->sk_max_pacing_rate !=3D ~0U ?
  					sk->sk_max_pacing_rate : ~0ULL;
+
+#ifdef CONFIG_TCP_ESTATS
+	info->tcpi_estats_cid =3D (tp->tcp_stats && tp->tcp_stats->tcpe_cid >=
 0)
+					? tp->tcp_stats->tcpe_cid : 0;
+#endif
  }
  EXPORT_SYMBOL_GPL(tcp_get_info);
 =20
@@ -3101,6 +3117,9 @@ void __init tcp_init(void)
  		tcp_hashinfo.ehash_mask + 1, tcp_hashinfo.bhash_size);
 =20
  	tcp_metrics_init();
+
  	BUG_ON(tcp_register_congestion_control(&tcp_reno) !=3D 0);
+	tcp_estats_init();
+
  	tcp_tasklet_init();
  }
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 27ead0d..e93929d 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -295,6 +295,8 @@ void tcp_slow_start(struct tcp_sock *tp, u32 acked)
  {
  	u32 cwnd =3D tp->snd_cwnd + acked;
 =20
+	TCP_ESTATS_VAR_INC(tp, stack_table, SlowStart);
+
  	if (cwnd > tp->snd_ssthresh)
  		cwnd =3D tp->snd_ssthresh + 1;
  	tp->snd_cwnd =3D min(cwnd, tp->snd_cwnd_clamp);
@@ -304,6 +306,7 @@ EXPORT_SYMBOL_GPL(tcp_slow_start);
  /* In theory this is tp->snd_cwnd +=3D 1 / tp->snd_cwnd (or alternati=
ve w) */
  void tcp_cong_avoid_ai(struct tcp_sock *tp, u32 w)
  {
+	TCP_ESTATS_VAR_INC(tp, stack_table, CongAvoid);
  	if (tp->snd_cwnd_cnt >=3D w) {
  		if (tp->snd_cwnd < tp->snd_cwnd_clamp)
  			tp->snd_cwnd++;
diff --git a/net/ipv4/tcp_htcp.c b/net/ipv4/tcp_htcp.c
index 58469ff..5facb4c 100644
--- a/net/ipv4/tcp_htcp.c
+++ b/net/ipv4/tcp_htcp.c
@@ -251,6 +251,7 @@ static void htcp_cong_avoid(struct sock *sk, u32 ac=
k, u32 acked)
  			tp->snd_cwnd_cnt +=3D ca->pkts_acked;
 =20
  		ca->pkts_acked =3D 1;
+		TCP_ESTATS_VAR_INC(tp, stack_table, CongAvoid);
  	}
  }
 =20
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 075ab4d..8f0601b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -77,8 +77,10 @@
  #include <linux/errqueue.h>
 =20
  int sysctl_tcp_timestamps __read_mostly =3D 1;
+EXPORT_SYMBOL(sysctl_tcp_timestamps);
  int sysctl_tcp_window_scaling __read_mostly =3D 1;
  int sysctl_tcp_sack __read_mostly =3D 1;
+EXPORT_SYMBOL(sysctl_tcp_sack);
  int sysctl_tcp_fack __read_mostly =3D 1;
  int sysctl_tcp_reordering __read_mostly =3D TCP_FASTRETRANS_THRESH;
  int sysctl_tcp_max_reordering __read_mostly =3D 300;
@@ -231,13 +233,15 @@ static void __tcp_ecn_check_ce(struct tcp_sock *t=
p, const struct sk_buff *skb)
  			tcp_enter_quickack_mode((struct sock *)tp);
  		break;
  	case INET_ECN_CE:
+		TCP_ESTATS_VAR_INC(tp, path_table, CERcvd);
  		if (tcp_ca_needs_ecn((struct sock *)tp))
  			tcp_ca_event((struct sock *)tp, CA_EVENT_ECN_IS_CE);
-
  		if (!(tp->ecn_flags & TCP_ECN_DEMAND_CWR)) {
  			/* Better not delay acks, sender can have a very low cwnd */
  			tcp_enter_quickack_mode((struct sock *)tp);
  			tp->ecn_flags |=3D TCP_ECN_DEMAND_CWR;
+		} else {
+			TCP_ESTATS_VAR_INC(tp, path_table, ECESent);
  		}
  		tp->ecn_flags |=3D TCP_ECN_SEEN;
  		break;
@@ -1104,6 +1108,7 @@ static bool tcp_check_dsack(struct sock *sk, cons=
t struct sk_buff *ack_skb,
  		dup_sack =3D true;
  		tcp_dsack_seen(tp);
  		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPDSACKRECV);
+		TCP_ESTATS_VAR_INC(tp, stack_table, DSACKDups);
  	} else if (num_sacks > 1) {
  		u32 end_seq_1 =3D get_unaligned_be32(&sp[1].end_seq);
  		u32 start_seq_1 =3D get_unaligned_be32(&sp[1].start_seq);
@@ -1114,6 +1119,7 @@ static bool tcp_check_dsack(struct sock *sk, cons=
t struct sk_buff *ack_skb,
  			tcp_dsack_seen(tp);
  			NET_INC_STATS_BH(sock_net(sk),
  					LINUX_MIB_TCPDSACKOFORECV);
+			TCP_ESTATS_VAR_INC(tp, stack_table, DSACKDups);
  		}
  	}
 =20
@@ -1653,6 +1659,9 @@ tcp_sacktag_write_queue(struct sock *sk, const st=
ruct sk_buff *ack_skb,
  	state.reord =3D tp->packets_out;
  	state.rtt_us =3D -1L;
 =20
+	TCP_ESTATS_VAR_INC(tp, stack_table, SACKsRcvd);
+	TCP_ESTATS_VAR_ADD(tp, stack_table, SACKBlocksRcvd, num_sacks);
+
  	if (!tp->sacked_out) {
  		if (WARN_ON(tp->fackets_out))
  			tp->fackets_out =3D 0;
@@ -1928,6 +1937,8 @@ void tcp_enter_loss(struct sock *sk)
  	bool new_recovery =3D false;
  	bool is_reneg;			/* is receiver reneging on SACKs? */
 =20
+	TCP_ESTATS_UPDATE(tp, tcp_estats_update_congestion(tp));
+
  	/* Reduce ssthresh if it has not yet been made inside this window. *=
/
  	if (icsk->icsk_ca_state <=3D TCP_CA_Disorder ||
  	    !after(tp->high_seq, tp->snd_una) ||
@@ -2200,8 +2211,12 @@ static bool tcp_time_to_recover(struct sock *sk,=
 int flag)
  	 */
  	if (tp->do_early_retrans && !tp->retrans_out && tp->sacked_out &&
  	    (tp->packets_out >=3D (tp->sacked_out + 1) && tp->packets_out < =
4) &&
-	    !tcp_may_send_now(sk))
-		return !tcp_pause_early_retransmit(sk, flag);
+	    !tcp_may_send_now(sk)) {
+		int early_retrans =3D !tcp_pause_early_retransmit(sk, flag);
+		if (early_retrans)
+			TCP_ESTATS_VAR_INC(tp, stack_table, EarlyRetrans);
+		return early_retrans;
+	}
 =20
  	return false;
  }
@@ -2299,9 +2314,15 @@ static void tcp_update_scoreboard(struct sock *s=
k, int fast_rexmit)
   */
  static inline void tcp_moderate_cwnd(struct tcp_sock *tp)
  {
-	tp->snd_cwnd =3D min(tp->snd_cwnd,
-			   tcp_packets_in_flight(tp) + tcp_max_burst(tp));
-	tp->snd_cwnd_stamp =3D tcp_time_stamp;
+	u32 pkts =3D tcp_packets_in_flight(tp) + tcp_max_burst(tp);
+
+	if (pkts < tp->snd_cwnd) {
+		tp->snd_cwnd =3D pkts;
+		tp->snd_cwnd_stamp =3D tcp_time_stamp;
+
+		TCP_ESTATS_VAR_INC(tp, stack_table, OtherReductions);
+		TCP_ESTATS_VAR_INC(tp, extras_table, OtherReductionsCM);
+	}
  }
 =20
  /* Nothing was retransmitted or returned timestamp is less
@@ -2402,6 +2423,7 @@ static void tcp_undo_cwnd_reduction(struct sock *=
sk, bool unmark_loss)
  		if (tp->prior_ssthresh > tp->snd_ssthresh) {
  			tp->snd_ssthresh =3D tp->prior_ssthresh;
  			tcp_ecn_withdraw_cwr(tp);
+			TCP_ESTATS_VAR_INC(tp, stack_table, CongOverCount);
  		}
  	} else {
  		tp->snd_cwnd =3D max(tp->snd_cwnd, tp->snd_ssthresh);
@@ -2428,10 +2450,15 @@ static bool tcp_try_undo_recovery(struct sock *=
sk)
  		 */
  		DBGUNDO(sk, inet_csk(sk)->icsk_ca_state =3D=3D TCP_CA_Loss ? "loss"=
 : "retrans");
  		tcp_undo_cwnd_reduction(sk, false);
-		if (inet_csk(sk)->icsk_ca_state =3D=3D TCP_CA_Loss)
+		if (inet_csk(sk)->icsk_ca_state =3D=3D TCP_CA_Loss) {
  			mib_idx =3D LINUX_MIB_TCPLOSSUNDO;
-		else
+			TCP_ESTATS_VAR_INC(tp, stack_table,
+					   SpuriousRtoDetected);
+		} else {
  			mib_idx =3D LINUX_MIB_TCPFULLUNDO;
+			TCP_ESTATS_VAR_INC(tp, stack_table,
+					   SpuriousFrDetected);
+		}
 =20
  		NET_INC_STATS_BH(sock_net(sk), mib_idx);
  	}
@@ -2472,9 +2499,12 @@ static bool tcp_try_undo_loss(struct sock *sk, b=
ool frto_undo)
 =20
  		DBGUNDO(sk, "partial loss");
  		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPLOSSUNDO);
-		if (frto_undo)
+		if (frto_undo) {
  			NET_INC_STATS_BH(sock_net(sk),
  					 LINUX_MIB_TCPSPURIOUSRTOS);
+			TCP_ESTATS_VAR_INC(tp, stack_table,
+					   SpuriousRtoDetected);
+		}
  		inet_csk(sk)->icsk_retransmits =3D 0;
  		if (frto_undo || tcp_is_sack(tp))
  			tcp_set_ca_state(sk, TCP_CA_Open);
@@ -2555,6 +2585,7 @@ void tcp_enter_cwr(struct sock *sk)
  		tcp_init_cwnd_reduction(sk);
  		tcp_set_ca_state(sk, TCP_CA_CWR);
  	}
+	TCP_ESTATS_UPDATE(tp, tcp_estats_update_congestion(tp));
  }
 =20
  static void tcp_try_keep_open(struct sock *sk)
@@ -2580,8 +2611,10 @@ static void tcp_try_to_open(struct sock *sk, int=
 flag, const int prior_unsacked)
  	if (!tcp_any_retrans_done(sk))
  		tp->retrans_stamp =3D 0;
 =20
-	if (flag & FLAG_ECE)
+	if (flag & FLAG_ECE) {
  		tcp_enter_cwr(sk);
+		TCP_ESTATS_VAR_INC(tp, path_table, ECNsignals);
+	}
 =20
  	if (inet_csk(sk)->icsk_ca_state !=3D TCP_CA_CWR) {
  		tcp_try_keep_open(sk);
@@ -2826,6 +2859,10 @@ static void tcp_fastretrans_alert(struct sock *s=
k, const int acked,
  			}
  			break;
 =20
+		case TCP_CA_Disorder:
+			TCP_ESTATS_VAR_INC(tp, path_table, NonRecovDAEpisodes);
+			break;
+
  		case TCP_CA_Recovery:
  			if (tcp_is_reno(tp))
  				tcp_reset_reno_sack(tp);
@@ -2870,6 +2907,10 @@ static void tcp_fastretrans_alert(struct sock *s=
k, const int acked,
  		if (icsk->icsk_ca_state <=3D TCP_CA_Disorder)
  			tcp_try_undo_dsack(sk);
 =20
+
+		if (icsk->icsk_ca_state =3D=3D TCP_CA_Disorder)
+			TCP_ESTATS_VAR_INC(tp, path_table, NonRecovDA);
+
  		if (!tcp_time_to_recover(sk, flag)) {
  			tcp_try_to_open(sk, flag, prior_unsacked);
  			return;
@@ -2889,6 +2930,8 @@ static void tcp_fastretrans_alert(struct sock *sk=
, const int acked,
  		/* Otherwise enter Recovery state */
  		tcp_enter_recovery(sk, (flag & FLAG_ECE));
  		fast_rexmit =3D 1;
+		TCP_ESTATS_UPDATE(tp, tcp_estats_update_congestion(tp));
+		TCP_ESTATS_VAR_INC(tp, stack_table, FastRetran);
  	}
 =20
  	if (do_lost)
@@ -2928,6 +2971,7 @@ static inline bool tcp_ack_update_rtt(struct sock=
 *sk, const int flag,
 =20
  	tcp_rtt_estimator(sk, seq_rtt_us);
  	tcp_set_rto(sk);
+	TCP_ESTATS_UPDATE(tcp_sk(sk), tcp_estats_update_rtt(sk, seq_rtt_us));
 =20
  	/* RFC6298: only reset backoff on valid RTT measurement. */
  	inet_csk(sk)->icsk_backoff =3D 0;
@@ -3007,6 +3051,7 @@ void tcp_resume_early_retransmit(struct sock *sk)
  	if (!tp->do_early_retrans)
  		return;
 =20
+	TCP_ESTATS_VAR_INC(tp, stack_table, EarlyRetransDelay);
  	tcp_enter_recovery(sk, false);
  	tcp_update_scoreboard(sk, 1);
  	tcp_xmit_retransmit_queue(sk);
@@ -3310,9 +3355,11 @@ static int tcp_ack_update_window(struct sock *sk=
, const struct sk_buff *skb, u32
  				tp->max_window =3D nwin;
  				tcp_sync_mss(sk, inet_csk(sk)->icsk_pmtu_cookie);
  			}
+			TCP_ESTATS_UPDATE(tp, tcp_estats_update_rwin_rcvd(tp));
  		}
  	}
 =20
+	TCP_ESTATS_UPDATE(tp, tcp_estats_update_acked(tp, ack));
  	tp->snd_una =3D ack;
 =20
  	return flag;
@@ -3410,6 +3457,7 @@ static int tcp_ack(struct sock *sk, const struct =
sk_buff *skb, int flag)
  	int prior_packets =3D tp->packets_out;
  	const int prior_unsacked =3D tp->packets_out - tp->sacked_out;
  	int acked =3D 0; /* Number of packets newly acked */
+	int prior_state =3D icsk->icsk_ca_state;
  	long sack_rtt_us =3D -1L;
 =20
  	/* We very likely will need to access write queue head. */
@@ -3419,6 +3467,9 @@ static int tcp_ack(struct sock *sk, const struct =
sk_buff *skb, int flag)
  	 * then we can probably ignore it.
  	 */
  	if (before(ack, prior_snd_una)) {
+		TCP_ESTATS_VAR_INC(tp, stack_table, SoftErrors);
+		TCP_ESTATS_VAR_SET(tp, stack_table, SoftErrorReason,
+				   TCP_ESTATS_SOFTERROR_BELOW_ACK_WINDOW);
  		/* RFC 5961 5.2 [Blind Data Injection Attack].[Mitigation] */
  		if (before(ack, prior_snd_una - tp->max_window)) {
  			tcp_send_challenge_ack(sk);
@@ -3430,8 +3481,12 @@ static int tcp_ack(struct sock *sk, const struct=
 sk_buff *skb, int flag)
  	/* If the ack includes data we haven't sent yet, discard
  	 * this segment (RFC793 Section 3.9).
  	 */
-	if (after(ack, tp->snd_nxt))
+	if (after(ack, tp->snd_nxt)) {
+		TCP_ESTATS_VAR_INC(tp, stack_table, SoftErrors);
+		TCP_ESTATS_VAR_SET(tp, stack_table, SoftErrorReason,
+				   TCP_ESTATS_SOFTERROR_ABOVE_ACK_WINDOW);
  		goto invalid_ack;
+	}
 =20
  	if (icsk->icsk_pending =3D=3D ICSK_TIME_EARLY_RETRANS ||
  	    icsk->icsk_pending =3D=3D ICSK_TIME_LOSS_PROBE)
@@ -3439,6 +3494,9 @@ static int tcp_ack(struct sock *sk, const struct =
sk_buff *skb, int flag)
 =20
  	if (after(ack, prior_snd_una)) {
  		flag |=3D FLAG_SND_UNA_ADVANCED;
+		if (icsk->icsk_ca_state =3D=3D TCP_CA_Disorder)
+			TCP_ESTATS_VAR_ADD(tp, path_table, SumOctetsReordered,
+					   ack - prior_snd_una);
  		icsk->icsk_retransmits =3D 0;
  	}
 =20
@@ -3456,6 +3514,7 @@ static int tcp_ack(struct sock *sk, const struct =
sk_buff *skb, int flag)
  		 * Note, we use the fact that SND.UNA>=3DSND.WL2.
  		 */
  		tcp_update_wl(tp, ack_seq);
+		TCP_ESTATS_UPDATE(tp, tcp_estats_update_acked(tp, ack));
  		tp->snd_una =3D ack;
  		flag |=3D FLAG_WIN_UPDATE;
 =20
@@ -3510,6 +3569,10 @@ static int tcp_ack(struct sock *sk, const struct=
 sk_buff *skb, int flag)
  		is_dupack =3D !(flag & (FLAG_SND_UNA_ADVANCED | FLAG_NOT_DUP));
  		tcp_fastretrans_alert(sk, acked, prior_unsacked,
  				      is_dupack, flag);
+		if (icsk->icsk_ca_state =3D=3D TCP_CA_Open &&
+		    prior_state >=3D TCP_CA_CWR)
+			TCP_ESTATS_UPDATE(tp,
+				tcp_estats_update_post_congestion(tp));
  	}
  	if (tp->tlp_high_seq)
  		tcp_process_tlp_ack(sk, ack, flag);
@@ -4177,7 +4240,9 @@ static void tcp_ofo_queue(struct sock *sk)
 =20
  		tail =3D skb_peek_tail(&sk->sk_receive_queue);
  		eaten =3D tail && tcp_try_coalesce(sk, tail, skb, &fragstolen);
+		TCP_ESTATS_UPDATE(tp, tcp_estats_update_rcvd(tp, tp->rcv_nxt));
  		tp->rcv_nxt =3D TCP_SKB_CB(skb)->end_seq;
+
  		if (!eaten)
  			__skb_queue_tail(&sk->sk_receive_queue, skb);
  		if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
@@ -4232,6 +4297,9 @@ static void tcp_data_queue_ofo(struct sock *sk, s=
truct sk_buff *skb)
  	SOCK_DEBUG(sk, "out of order segment: rcv_next %X seq %X - %X\n",
  		   tp->rcv_nxt, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq);
 =20
+        TCP_ESTATS_UPDATE(tp, tcp_estats_update_recvq(sk));
+        TCP_ESTATS_VAR_INC(tp, path_table, DupAcksOut);
+
  	skb1 =3D skb_peek_tail(&tp->out_of_order_queue);
  	if (!skb1) {
  		/* Initial out of order segment, build 1 SACK. */
@@ -4242,6 +4310,7 @@ static void tcp_data_queue_ofo(struct sock *sk, s=
truct sk_buff *skb)
  						TCP_SKB_CB(skb)->end_seq;
  		}
  		__skb_queue_head(&tp->out_of_order_queue, skb);
+                TCP_ESTATS_VAR_INC(tp, path_table, DupAckEpisodes);
  		goto end;
  	}
 =20
@@ -4438,6 +4507,9 @@ queue_and_out:
 =20
  			eaten =3D tcp_queue_rcv(sk, skb, 0, &fragstolen);
  		}
+		TCP_ESTATS_UPDATE(
+			tp,
+			tcp_estats_update_rcvd(tp, TCP_SKB_CB(skb)->end_seq));
  		tp->rcv_nxt =3D TCP_SKB_CB(skb)->end_seq;
  		if (skb->len)
  			tcp_event_data_recv(sk, skb);
@@ -4459,6 +4531,8 @@ queue_and_out:
 =20
  		tcp_fast_path_check(sk);
 =20
+		TCP_ESTATS_UPDATE(tp, tcp_estats_update_recvq(sk));
+
  		if (eaten > 0)
  			kfree_skb_partial(skb, fragstolen);
  		if (!sock_flag(sk, SOCK_DEAD))
@@ -4990,6 +5064,9 @@ static bool tcp_validate_incoming(struct sock *sk=
, struct sk_buff *skb,
  	    tcp_paws_discard(sk, skb)) {
  		if (!th->rst) {
  			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSESTABREJECTED);
+			TCP_ESTATS_VAR_INC(tp, stack_table, SoftErrors);
+			TCP_ESTATS_VAR_SET(tp, stack_table, SoftErrorReason,
+					   TCP_ESTATS_SOFTERROR_BELOW_TS_WINDOW);
  			tcp_send_dupack(sk, skb);
  			goto discard;
  		}
@@ -5004,6 +5081,11 @@ static bool tcp_validate_incoming(struct sock *s=
k, struct sk_buff *skb,
  		 * an acknowledgment should be sent in reply (unless the RST
  		 * bit is set, if so drop the segment and return)".
  		 */
+		TCP_ESTATS_VAR_INC(tp, stack_table, SoftErrors);
+		TCP_ESTATS_VAR_SET(tp, stack_table, SoftErrorReason,
+			before(TCP_SKB_CB(skb)->end_seq, tp->rcv_wup) ?
+				TCP_ESTATS_SOFTERROR_BELOW_DATA_WINDOW :
+				TCP_ESTATS_SOFTERROR_ABOVE_DATA_WINDOW);
  		if (!th->rst) {
  			if (th->syn)
  				goto syn_challenge;
@@ -5152,6 +5234,10 @@ void tcp_rcv_established(struct sock *sk, struct=
 sk_buff *skb,
  				return;
  			} else { /* Header too small */
  				TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
+				TCP_ESTATS_VAR_INC(tp, stack_table, SoftErrors);
+				TCP_ESTATS_VAR_SET(tp, stack_table,
+						   SoftErrorReason,
+						   TCP_ESTATS_SOFTERROR_OTHER);
  				goto discard;
  			}
  		} else {
@@ -5178,6 +5264,7 @@ void tcp_rcv_established(struct sock *sk, struct =
sk_buff *skb,
  					tcp_rcv_rtt_measure_ts(sk, skb);
 =20
  					__skb_pull(skb, tcp_header_len);
+					TCP_ESTATS_UPDATE(tp, tcp_estats_update_rcvd(tp, TCP_SKB_CB(skb)-=
>end_seq));
  					tp->rcv_nxt =3D TCP_SKB_CB(skb)->end_seq;
  					NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPHPHITSTOUSER);
  					eaten =3D 1;
@@ -5204,10 +5291,12 @@ void tcp_rcv_established(struct sock *sk, struc=
t sk_buff *skb,
  				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPHPHITS);
 =20
  				/* Bulk data transfer: receiver */
+				TCP_ESTATS_UPDATE(tp, tcp_estats_update_rcvd(tp, TCP_SKB_CB(skb)->=
end_seq));
  				eaten =3D tcp_queue_rcv(sk, skb, tcp_header_len,
  						      &fragstolen);
  			}
 =20
+			TCP_ESTATS_UPDATE(tp, tcp_estats_update_recvq(sk));
  			tcp_event_data_recv(sk, skb);
 =20
  			if (TCP_SKB_CB(skb)->ack_seq !=3D tp->snd_una) {
@@ -5260,6 +5349,9 @@ step5:
  csum_error:
  	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_CSUMERRORS);
  	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
+	TCP_ESTATS_VAR_INC(tp, stack_table, SoftErrors);
+	TCP_ESTATS_VAR_SET(tp, stack_table, SoftErrorReason,
+			   TCP_ESTATS_SOFTERROR_DATA_CHECKSUM);
 =20
  discard:
  	__kfree_skb(skb);
@@ -5459,6 +5551,7 @@ static int tcp_rcv_synsent_state_process(struct s=
ock *sk, struct sk_buff *skb,
  		smp_mb();
 =20
  		tcp_finish_connect(sk, skb);
+		tcp_estats_establish(sk);
 =20
  		if ((tp->syn_fastopen || tp->syn_data) &&
  		    tcp_rcv_fastopen_synack(sk, skb, &foc))
@@ -5685,6 +5778,7 @@ int tcp_rcv_state_process(struct sock *sk, struct=
 sk_buff *skb,
  		smp_mb();
  		tcp_set_state(sk, TCP_ESTABLISHED);
  		sk->sk_state_change(sk);
+		tcp_estats_establish(sk);
 =20
  		/* Note, that this wakeup is only for marginal crossed SYN case.
  		 * Passively open sockets are not waked up, because
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a3f72d7..9c85a54 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1310,6 +1310,8 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk=
, struct sk_buff *skb,
  	if (!newsk)
  		goto exit_nonewsk;
 =20
+	tcp_estats_create(newsk, TCP_ESTATS_ADDRTYPE_IPV4, TCP_ESTATS_INACTIV=
E);
+
  	newsk->sk_gso_type =3D SKB_GSO_TCPV4;
  	inet_sk_rx_dst_set(newsk, skb);
 =20
@@ -1670,6 +1672,8 @@ process:
  	skb->dev =3D NULL;
 =20
  	bh_lock_sock_nested(sk);
+	TCP_ESTATS_UPDATE(
+		tcp_sk(sk), tcp_estats_update_segrecv(tcp_sk(sk), skb));
  	ret =3D 0;
  	if (!sock_owned_by_user(sk)) {
  		if (!tcp_prequeue(sk, skb))
@@ -1680,6 +1684,8 @@ process:
  		NET_INC_STATS_BH(net, LINUX_MIB_TCPBACKLOGDROP);
  		goto discard_and_relse;
  	}
+	TCP_ESTATS_UPDATE(
+		tcp_sk(sk), tcp_estats_update_finish_segrecv(tcp_sk(sk)));
  	bh_unlock_sock(sk);
 =20
  	sock_put(sk);
@@ -1809,6 +1815,8 @@ static int tcp_v4_init_sock(struct sock *sk)
  	tcp_sk(sk)->af_specific =3D &tcp_sock_ipv4_specific;
  #endif
 =20
+	tcp_estats_create(sk, TCP_ESTATS_ADDRTYPE_IPV4, TCP_ESTATS_ACTIVE);
+
  	return 0;
  }
 =20
@@ -1842,6 +1850,8 @@ void tcp_v4_destroy_sock(struct sock *sk)
  	if (inet_csk(sk)->icsk_bind_hash)
  		inet_put_port(sk);
 =20
+	tcp_estats_destroy(sk);
+
  	BUG_ON(tp->fastopen_rsk !=3D NULL);
 =20
  	/* If socket is aborted during connect operation */
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7f18262..145b4f2 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -80,6 +80,7 @@ static void tcp_event_new_data_sent(struct sock *sk, =
const struct sk_buff *skb)
 =20
  	tcp_advance_send_head(sk, skb);
  	tp->snd_nxt =3D TCP_SKB_CB(skb)->end_seq;
+	TCP_ESTATS_UPDATE(tp, tcp_estats_update_snd_nxt(tp));
 =20
  	tp->packets_out +=3D tcp_skb_pcount(skb);
  	if (!prior_packets || icsk->icsk_pending =3D=3D ICSK_TIME_EARLY_RETR=
ANS ||
@@ -292,6 +293,7 @@ static u16 tcp_select_window(struct sock *sk)
  	}
  	tp->rcv_wnd =3D new_win;
  	tp->rcv_wup =3D tp->rcv_nxt;
+	TCP_ESTATS_UPDATE(tp, tcp_estats_update_rwin_sent(tp));
 =20
  	/* Make sure we do not exceed the maximum possible
  	 * scaled window.
@@ -905,6 +907,12 @@ static int tcp_transmit_skb(struct sock *sk, struc=
t sk_buff *skb, int clone_it,
  	struct tcp_md5sig_key *md5;
  	struct tcphdr *th;
  	int err;
+#ifdef CONFIG_TCP_ESTATS
+	__u32 seq;
+	__u32 end_seq;
+	int tcp_flags;
+	int pcount;
+#endif
 =20
  	BUG_ON(!skb || !tcp_skb_pcount(skb));
 =20
@@ -1008,6 +1016,15 @@ static int tcp_transmit_skb(struct sock *sk, str=
uct sk_buff *skb, int clone_it,
  		TCP_ADD_STATS(sock_net(sk), TCP_MIB_OUTSEGS,
  			      tcp_skb_pcount(skb));
 =20
+#ifdef CONFIG_TCP_ESTATS
+	/* If the skb isn't cloned, we can't reference it after
+	 * calling queue_xmit, so copy everything we need here. */
+	pcount =3D tcp_skb_pcount(skb);
+	seq =3D TCP_SKB_CB(skb)->seq;
+	end_seq =3D TCP_SKB_CB(skb)->end_seq;
+	tcp_flags =3D TCP_SKB_CB(skb)->tcp_flags;
+#endif
+
  	/* OK, its time to fill skb_shinfo(skb)->gso_segs */
  	skb_shinfo(skb)->gso_segs =3D tcp_skb_pcount(skb);
 =20
@@ -1020,10 +1037,17 @@ static int tcp_transmit_skb(struct sock *sk, st=
ruct sk_buff *skb, int clone_it,
 =20
  	err =3D icsk->icsk_af_ops->queue_xmit(sk, skb, &inet->cork.fl);
 =20
+	if (likely(!err)) {
+		TCP_ESTATS_UPDATE(tp, tcp_estats_update_segsend(sk, pcount,
+								seq, end_seq,
+								tcp_flags));
+	}
+
  	if (likely(err <=3D 0))
  		return err;
 =20
  	tcp_enter_cwr(sk);
+	TCP_ESTATS_VAR_INC(tp, stack_table, SendStall);
 =20
  	return net_xmit_eval(err);
  }
@@ -1398,6 +1422,7 @@ unsigned int tcp_sync_mss(struct sock *sk, u32 pm=
tu)
  	if (icsk->icsk_mtup.enabled)
  		mss_now =3D min(mss_now, tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_=
low));
  	tp->mss_cache =3D mss_now;
+	TCP_ESTATS_UPDATE(tp, tcp_estats_update_mss(tp));
 =20
  	return mss_now;
  }
@@ -1670,11 +1695,13 @@ static unsigned int tcp_snd_test(const struct s=
ock *sk, struct sk_buff *skb,
  	tcp_init_tso_segs(sk, skb, cur_mss);
 =20
  	if (!tcp_nagle_test(tp, skb, cur_mss, nonagle))
-		return 0;
+		return -TCP_ESTATS_SNDLIM_SENDER;
 =20
  	cwnd_quota =3D tcp_cwnd_test(tp, skb);
-	if (cwnd_quota && !tcp_snd_wnd_test(tp, skb, cur_mss))
-		cwnd_quota =3D 0;
+	if (!cwnd_quota)
+		return -TCP_ESTATS_SNDLIM_CWND;
+	if (!tcp_snd_wnd_test(tp, skb, cur_mss))
+		return -TCP_ESTATS_SNDLIM_RWIN;
 =20
  	return cwnd_quota;
  }
@@ -1688,7 +1715,7 @@ bool tcp_may_send_now(struct sock *sk)
  	return skb &&
  		tcp_snd_test(sk, skb, tcp_current_mss(sk),
  			     (tcp_skb_is_last(sk, skb) ?
-			      tp->nonagle : TCP_NAGLE_PUSH));
+			      tp->nonagle : TCP_NAGLE_PUSH)) > 0;
  }
 =20
  /* Trim TSO SKB to LEN bytes, put the remaining data into a new packe=
t
@@ -1978,6 +2005,7 @@ static bool tcp_write_xmit(struct sock *sk, unsig=
ned int mss_now, int nonagle,
  	unsigned int tso_segs, sent_pkts;
  	int cwnd_quota;
  	int result;
+	int why =3D TCP_ESTATS_SNDLIM_SENDER;
  	bool is_cwnd_limited =3D false;
  	u32 max_segs;
 =20
@@ -2008,6 +2036,7 @@ static bool tcp_write_xmit(struct sock *sk, unsig=
ned int mss_now, int nonagle,
 =20
  		cwnd_quota =3D tcp_cwnd_test(tp, skb);
  		if (!cwnd_quota) {
+			why =3D TCP_ESTATS_SNDLIM_CWND;
  			is_cwnd_limited =3D true;
  			if (push_one =3D=3D 2)
  				/* Force out a loss probe pkt. */
@@ -2016,19 +2045,24 @@ static bool tcp_write_xmit(struct sock *sk, uns=
igned int mss_now, int nonagle,
  				break;
  		}
 =20
-		if (unlikely(!tcp_snd_wnd_test(tp, skb, mss_now)))
+		if (unlikely(!tcp_snd_wnd_test(tp, skb, mss_now))) {
+			why =3D TCP_ESTATS_SNDLIM_RWIN;
  			break;
-
+		}
+	=09
  		if (tso_segs =3D=3D 1) {
  			if (unlikely(!tcp_nagle_test(tp, skb, mss_now,
  						     (tcp_skb_is_last(sk, skb) ?
  						      nonagle : TCP_NAGLE_PUSH))))
+				/* set above: why =3D TCP_ESTATS_SNDLIM_SENDER; */
  				break;
  		} else {
  			if (!push_one &&
  			    tcp_tso_should_defer(sk, skb, &is_cwnd_limited,
-						 max_segs))
+						 max_segs)) {
+				why =3D TCP_ESTATS_SNDLIM_TSODEFER;
  				break;
+			}
  		}
 =20
  		limit =3D mss_now;
@@ -2041,6 +2075,7 @@ static bool tcp_write_xmit(struct sock *sk, unsig=
ned int mss_now, int nonagle,
 =20
  		if (skb->len > limit &&
  		    unlikely(tso_fragment(sk, skb, limit, mss_now, gfp)))
+			/* set above: why =3D TCP_ESTATS_SNDLIM_SENDER; */
  			break;
 =20
  		/* TCP Small Queues :
@@ -2064,10 +2099,12 @@ static bool tcp_write_xmit(struct sock *sk, uns=
igned int mss_now, int nonagle,
  			 */
  			smp_mb__after_atomic();
  			if (atomic_read(&sk->sk_wmem_alloc) > limit)
+				/* set above: why =3D TCP_ESTATS_SNDLIM_SENDER; */
  				break;
  		}
 =20
  		if (unlikely(tcp_transmit_skb(sk, skb, 1, gfp)))
+			/* set above: why =3D TCP_ESTATS_SNDLIM_SENDER; */
  			break;
 =20
  repair:
@@ -2080,9 +2117,12 @@ repair:
  		sent_pkts +=3D tcp_skb_pcount(skb);
 =20
  		if (push_one)
+			/* set above: why =3D TCP_ESTATS_SNDLIM_SENDER; */
  			break;
  	}
 =20
+	TCP_ESTATS_UPDATE(tp, tcp_estats_update_sndlim(tp, why));
+
  	if (likely(sent_pkts)) {
  		if (tcp_in_cwnd_reduction(sk))
  			tp->prr_out +=3D sent_pkts;
@@ -3148,11 +3188,16 @@ int tcp_connect(struct sock *sk)
  	 */
  	tp->snd_nxt =3D tp->write_seq;
  	tp->pushed_seq =3D tp->write_seq;
-	TCP_INC_STATS(sock_net(sk), TCP_MIB_ACTIVEOPENS);
 =20
  	/* Timer for repeating the SYN until an answer. */
  	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
  				  inet_csk(sk)->icsk_rto, TCP_RTO_MAX);
+
+	TCP_ESTATS_VAR_SET(tp, stack_table, SndInitial, tp->write_seq);
+	TCP_ESTATS_VAR_SET(tp, app_table, SndMax, tp->write_seq);
+	TCP_ESTATS_UPDATE(tp, tcp_estats_update_snd_nxt(tp));
+	TCP_INC_STATS(sock_net(sk), TCP_MIB_ACTIVEOPENS);
+
  	return 0;
  }
  EXPORT_SYMBOL(tcp_connect);
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 1829c7f..0f6f1f4 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -477,6 +477,9 @@ out_reset_timer:
  		icsk->icsk_rto =3D min(icsk->icsk_rto << 1, TCP_RTO_MAX);
  	}
  	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, TCP=
_RTO_MAX);
+
+        TCP_ESTATS_UPDATE(tp, tcp_estats_update_timeout(sk));
+
  	if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1, 0, 0))
  		__sk_dst_reset(sk);
 =20
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5ff8780..db1f88f 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1131,6 +1131,8 @@ static struct sock *tcp_v6_syn_recv_sock(struct s=
ock *sk, struct sk_buff *skb,
  	if (newsk =3D=3D NULL)
  		goto out_nonewsk;
 =20
+	tcp_estats_create(newsk, TCP_ESTATS_ADDRTYPE_IPV6, TCP_ESTATS_INACTIV=
E);
+
  	/*
  	 * No need to charge this sock to the relevant IPv6 refcnt debug soc=
ks
  	 * count here, tcp_create_openreq_child now does this for us, see th=
e
@@ -1463,6 +1465,8 @@ process:
  	skb->dev =3D NULL;
 =20
  	bh_lock_sock_nested(sk);
+	TCP_ESTATS_UPDATE(
+		tcp_sk(sk), tcp_estats_update_segrecv(tcp_sk(sk), skb));
  	ret =3D 0;
  	if (!sock_owned_by_user(sk)) {
  		if (!tcp_prequeue(sk, skb))
@@ -1473,6 +1477,8 @@ process:
  		NET_INC_STATS_BH(net, LINUX_MIB_TCPBACKLOGDROP);
  		goto discard_and_relse;
  	}
+	TCP_ESTATS_UPDATE(
+		tcp_sk(sk), tcp_estats_update_finish_segrecv(tcp_sk(sk)));
  	bh_unlock_sock(sk);
 =20
  	sock_put(sk);
@@ -1661,6 +1667,7 @@ static int tcp_v6_init_sock(struct sock *sk)
  #ifdef CONFIG_TCP_MD5SIG
  	tcp_sk(sk)->af_specific =3D &tcp_sock_ipv6_specific;
  #endif
+	tcp_estats_create(sk, TCP_ESTATS_ADDRTYPE_IPV6, TCP_ESTATS_ACTIVE);
 =20
  	return 0;
  }
--=20
1.9.3
