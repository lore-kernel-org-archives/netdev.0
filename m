From: rapier <rapier@psc.edu>
Subject: [PATCH net-next 2/3] Implementation of RFC 4898 Extended TCP Statistics
 (Web10G)
Date: Tue, 16 Dec 2014 12:50:11 -0500
Message-ID: <549070D3.5050808@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.70.106]:39697 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751252AbaLPRuM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2014 12:50:12 -0500
Received: from CMU-785477.WV.CC.CMU.EDU (CMU-785477.WV.CC.CMU.EDU [128.237.173.182])
	(authenticated bits=0)
	by mailer2.psc.edu (8.13.8/8.13.8) with ESMTP id sBGHoBjY012587
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 12:50:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches provide control and management routines for the
kernel instrument set (KIS). This set of patches can be applied
against net-next independently of the KIS. While the kernel can be
patched, compiled, and run with this patch set it provides no real
functionality without the KIS implementation.

The reason is that the development team is primarily focused on ensurin=
g
that the KIS is taken up by the community. Alternative control and
management methods can be developed and implemented as long as the KIS
is in the kernel.

In order for this patch set to compile on its own we have included two
files/patches that were previously introduced in the KIS implementation=
=2E
These are include/net/tcp_estats.h and include/linux/tcp.h. If patching
against a source tree that includes the KIS implementation
net/ipv4/[tcp_estats.c, sysctl_net_ipv4.c, Kconfig, Makefile] are requi=
red.

---
  include/linux/tcp.h        |   8 +
  include/net/tcp_estats.h   | 376 +++++++++++++++++++++++
  net/ipv4/Kconfig           |  25 ++
  net/ipv4/Makefile          |   1 +
  net/ipv4/sysctl_net_ipv4.c |  14 +
  net/ipv4/tcp_estats.c      | 736 ++++++++++++++++++++++++++++++++++++=
+++++++++
  6 files changed, 1160 insertions(+)
  create mode 100644 include/net/tcp_estats.h
  create mode 100644 net/ipv4/tcp_estats.c

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
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index bd29016..c04ba8f 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -680,3 +680,28 @@ config TCP_MD5SIG
  	  on the Internet.
 =20
  	  If unsure, say N.
+
+config TCP_ESTATS
+	bool "TCP: Extended TCP statistics (RFC4898) MIB"
+	---help---
+	  RFC 4898 specifies a number of extended statistics for TCP. This
+	  data can be accessed using netlink. See http://www.web10g.org for
+	  more details.
+
+if TCP_ESTATS
+
+config TCP_ESTATS_STRICT_ELAPSEDTIME=09
+	bool "TCP: ESTATS strict ElapsedSecs/Msecs counters"
+	depends on TCP_ESTATS
+	default n
+	---help---
+	  Elapsed time since beginning of connection.
+	  RFC4898 defines ElapsedSecs/Msecs as being updated via ktime_get
+	  at each protocol event (sending or receiving of a segment);
+	  as this can be a performance hit, leaving this config option off
+	  will update elapsed based on on the jiffies counter instead.
+	  Set to Y for strict conformance with the MIB.
+
+	  If unsure, say N.
+
+endif
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 518c04e..7e2c69a 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -36,6 +36,7 @@ obj-$(CONFIG_INET_TUNNEL) +=3D tunnel4.o
  obj-$(CONFIG_INET_XFRM_MODE_TRANSPORT) +=3D xfrm4_mode_transport.o
  obj-$(CONFIG_INET_XFRM_MODE_TUNNEL) +=3D xfrm4_mode_tunnel.o
  obj-$(CONFIG_IP_PNP) +=3D ipconfig.o
+obj-$(CONFIG_TCP_ESTATS) +=3D tcp_estats.o
  obj-$(CONFIG_NETFILTER)	+=3D netfilter.o netfilter/
  obj-$(CONFIG_INET_DIAG) +=3D inet_diag.o
  obj-$(CONFIG_INET_TCP_DIAG) +=3D tcp_diag.o
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index e0ee384..edc5a66 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -42,6 +42,11 @@ static int tcp_syn_retries_max =3D MAX_TCP_SYNCNT;
  static int ip_ping_group_range_min[] =3D { 0, 0 };
  static int ip_ping_group_range_max[] =3D { GID_T_MAX, GID_T_MAX };
 =20
+/* Extended statistics (RFC4898). */
+#ifdef CONFIG_TCP_ESTATS
+int sysctl_tcp_estats __read_mostly;
+#endif  /* CONFIG_TCP_ESTATS */
+
  /* Update system visible IP port range */
  static void set_local_port_range(struct net *net, int range[2])
  {
@@ -767,6 +772,15 @@ static struct ctl_table ipv4_table[] =3D {
  		.proc_handler	=3D proc_dointvec_minmax,
  		.extra1		=3D &one
  	},
+#ifdef CONFIG_TCP_ESTATS
+	{
+		.procname	=3D "tcp_estats",
+		.data		=3D &sysctl_tcp_estats,
+		.maxlen		=3D sizeof(int),
+		.mode		=3D 0644,
+		.proc_handler	=3D proc_dointvec
+	},
+#endif /* CONFIG TCP ESTATS */
  	{ }
  };
 =20
diff --git a/net/ipv4/tcp_estats.c b/net/ipv4/tcp_estats.c
new file mode 100644
index 0000000..e817540
--- /dev/null
+++ b/net/ipv4/tcp_estats.c
@@ -0,0 +1,736 @@
+/*
+ * net/ipv4/tcp_estats.c
+ *
+ * Implementation of TCP ESTATS MIB (RFC 4898)
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
+ *
+ */
+
+#include <linux/export.h>
+#ifndef CONFIG_TCP_ESTATS_STRICT_ELAPSEDTIME
+#include <linux/jiffies.h>
+#endif
+#include <linux/types.h>
+#include <linux/socket.h>
+#include <linux/string.h>
+#include <net/tcp_estats.h>
+#include <net/tcp.h>
+#include <asm/atomic.h>
+#include <asm/byteorder.h>
+
+#define ESTATS_INF32	0xffffffff
+
+#define ESTATS_MAX_CID	5000000
+
+extern int sysctl_tcp_estats;
+
+struct idr tcp_estats_idr;
+EXPORT_SYMBOL(tcp_estats_idr);
+static int next_id =3D 1;
+DEFINE_SPINLOCK(tcp_estats_idr_lock);
+EXPORT_SYMBOL(tcp_estats_idr_lock);
+
+int tcp_estats_wq_enabled __read_mostly =3D 0;
+EXPORT_SYMBOL(tcp_estats_wq_enabled);
+struct workqueue_struct *tcp_estats_wq =3D NULL;
+EXPORT_SYMBOL(tcp_estats_wq);
+void (*create_notify_func)(struct work_struct *work);
+EXPORT_SYMBOL(create_notify_func);
+void (*establish_notify_func)(struct work_struct *work);
+EXPORT_SYMBOL(establish_notify_func);
+void (*destroy_notify_func)(struct work_struct *work);
+EXPORT_SYMBOL(destroy_notify_func);
+unsigned long persist_delay =3D 0;
+EXPORT_SYMBOL(persist_delay);
+
+struct static_key tcp_estats_enabled __read_mostly =3D STATIC_KEY_INIT=
_FALSE;
+EXPORT_SYMBOL(tcp_estats_enabled);
+
+/* if HAVE_JUMP_LABEL is defined, then static_key_slow_inc/dec uses a
+ *   mutex in its implementation, and hence can't be called if in_inte=
rrupt().
+ * if HAVE_JUMP_LABEL is NOT defined, then no mutex is used, hence no =
need
+ *   for deferring enable/disable */
+#ifdef HAVE_JUMP_LABEL
+static atomic_t tcp_estats_enabled_deferred;
+
+static void tcp_estats_handle_deferred_enable_disable(void)
+{
+	int count =3D atomic_xchg(&tcp_estats_enabled_deferred, 0);
+
+	while (count > 0) {
+		static_key_slow_inc(&tcp_estats_enabled);
+		--count;
+	}
+
+	while (count < 0) {
+		static_key_slow_dec(&tcp_estats_enabled);
+		++count;
+	}
+}
+#endif
+
+static inline void tcp_estats_enable(void)
+{
+#ifdef HAVE_JUMP_LABEL
+	if (in_interrupt()) {
+		atomic_inc(&tcp_estats_enabled_deferred);
+		return;
+	}
+	tcp_estats_handle_deferred_enable_disable();
+#endif
+	static_key_slow_inc(&tcp_estats_enabled);
+}
+
+static inline void tcp_estats_disable(void)
+{
+#ifdef HAVE_JUMP_LABEL
+	if (in_interrupt()) {
+		atomic_dec(&tcp_estats_enabled_deferred);
+		return;
+	}
+	tcp_estats_handle_deferred_enable_disable();
+#endif
+	static_key_slow_dec(&tcp_estats_enabled);
+}
+
+/* Calculates the required amount of memory for any enabled tables. */
+int tcp_estats_get_allocation_size(int sysctl)
+{
+	int size =3D sizeof(struct tcp_estats) +
+		sizeof(struct tcp_estats_connection_table);
+
+	if (sysctl & TCP_ESTATS_TABLEMASK_PERF)
+		size +=3D sizeof(struct tcp_estats_perf_table);
+	if (sysctl & TCP_ESTATS_TABLEMASK_PATH)
+		size +=3D sizeof(struct tcp_estats_path_table);
+	if (sysctl & TCP_ESTATS_TABLEMASK_STACK)
+		size +=3D sizeof(struct tcp_estats_stack_table);
+	if (sysctl & TCP_ESTATS_TABLEMASK_APP)
+		size +=3D sizeof(struct tcp_estats_app_table);
+	if (sysctl & TCP_ESTATS_TABLEMASK_EXTRAS)
+		size +=3D sizeof(struct tcp_estats_extras_table);
+	return size;
+}
+
+/* Called whenever a TCP/IPv4 sock is created.
+ * net/ipv4/tcp_ipv4.c: tcp_v4_syn_recv_sock,
+ *			tcp_v4_init_sock
+ * Allocates a stats structure and initializes values.
+ */
+int tcp_estats_create(struct sock *sk, enum tcp_estats_addrtype addrty=
pe,
+		      int active)
+{
+	struct tcp_estats *stats;
+	struct tcp_estats_tables *tables;
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	void *estats_mem;
+	int sysctl;
+	int ret;
+
+	/* Read the sysctl once before calculating memory needs and initializ=
ing
+	 * tables to avoid raciness. */
+	sysctl =3D ACCESS_ONCE(sysctl_tcp_estats);
+	if (likely(sysctl =3D=3D TCP_ESTATS_TABLEMASK_INACTIVE)) {
+		return 0;
+	}
+
+	estats_mem =3D kzalloc(tcp_estats_get_allocation_size(sysctl), gfp_an=
y());
+	if (!estats_mem)
+		return -ENOMEM;
+
+	stats =3D estats_mem;
+	estats_mem +=3D sizeof(struct tcp_estats);
+
+	tables =3D &stats->tables;
+
+	tables->connection_table =3D estats_mem;
+	estats_mem +=3D sizeof(struct tcp_estats_connection_table);
+
+	if (sysctl & TCP_ESTATS_TABLEMASK_PERF) {
+		tables->perf_table =3D estats_mem;
+		estats_mem +=3D sizeof(struct tcp_estats_perf_table);
+	}
+	if (sysctl & TCP_ESTATS_TABLEMASK_PATH) {
+		tables->path_table =3D estats_mem;
+		estats_mem +=3D sizeof(struct tcp_estats_path_table);
+	}
+	if (sysctl & TCP_ESTATS_TABLEMASK_STACK) {
+		tables->stack_table =3D estats_mem;
+		estats_mem +=3D sizeof(struct tcp_estats_stack_table);
+	}
+	if (sysctl & TCP_ESTATS_TABLEMASK_APP) {
+		tables->app_table =3D estats_mem;
+		estats_mem +=3D sizeof(struct tcp_estats_app_table);
+	}
+	if (sysctl & TCP_ESTATS_TABLEMASK_EXTRAS) {
+		tables->extras_table =3D estats_mem;
+		estats_mem +=3D sizeof(struct tcp_estats_extras_table);
+	}
+
+	stats->tcpe_cid =3D -1;
+	stats->queued =3D 0;
+
+	tables->connection_table->AddressType =3D addrtype;
+
+	sock_hold(sk);
+	stats->sk =3D sk;
+	atomic_set(&stats->users, 0);
+
+	stats->limstate =3D TCP_ESTATS_SNDLIM_STARTUP;
+	stats->limstate_ts =3D ktime_get();
+#ifdef CONFIG_TCP_ESTATS_STRICT_ELAPSEDTIME
+	stats->start_ts =3D stats->current_ts =3D stats->limstate_ts;
+#else
+	stats->start_ts =3D stats->current_ts =3D jiffies;
+#endif
+	do_gettimeofday(&stats->start_tv);
+
+	/* order is important -
+	 * must have stats hooked into tp and tcp_estats_enabled()
+	 * in order to have the TCP_ESTATS_VAR_<> macros work */
+	tp->tcp_stats =3D stats;
+	tcp_estats_enable();
+
+	TCP_ESTATS_VAR_SET(tp, stack_table, ActiveOpen, active);
+
+	TCP_ESTATS_VAR_SET(tp, app_table, SndMax, tp->snd_nxt);
+	TCP_ESTATS_VAR_SET(tp, stack_table, SndInitial, tp->snd_nxt);
+
+	TCP_ESTATS_VAR_SET(tp, path_table, MinRTT, ESTATS_INF32);
+	TCP_ESTATS_VAR_SET(tp, path_table, MinRTO, ESTATS_INF32);
+	TCP_ESTATS_VAR_SET(tp, stack_table, MinMSS, ESTATS_INF32);
+	TCP_ESTATS_VAR_SET(tp, stack_table, MinSsthresh, ESTATS_INF32);
+
+	tcp_estats_use(stats);
+
+	if (tcp_estats_wq_enabled) {
+		tcp_estats_use(stats);
+		stats->queued =3D 1;
+		stats->tcpe_cid =3D 0;
+		INIT_WORK(&stats->create_notify, create_notify_func);
+		ret =3D queue_work(tcp_estats_wq, &stats->create_notify);
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(tcp_estats_create);
+
+void tcp_estats_destroy(struct sock *sk)
+{
+	struct tcp_estats *stats =3D tcp_sk(sk)->tcp_stats;
+
+	if (stats =3D=3D NULL)
+		return;
+
+	/* Attribute final sndlim time. */
+	tcp_estats_update_sndlim(tcp_sk(stats->sk), stats->limstate);
+
+	if (tcp_estats_wq_enabled && stats->queued) {
+		INIT_DELAYED_WORK(&stats->destroy_notify,
+			destroy_notify_func);
+		queue_delayed_work(tcp_estats_wq, &stats->destroy_notify,
+			persist_delay);
+	}
+	tcp_estats_unuse(stats);
+}
+
+/* Do not call directly.  Called from tcp_estats_unuse() through call_=
rcu. */
+void tcp_estats_free(struct rcu_head *rcu)
+{
+	struct tcp_estats *stats =3D container_of(rcu, struct tcp_estats, rcu=
);
+	tcp_estats_disable();
+	kfree(stats);
+}
+EXPORT_SYMBOL(tcp_estats_free);
+
+/* Called when a connection enters the ESTABLISHED state, and has all =
its
+ * state initialized.
+ * net/ipv4/tcp_input.c: tcp_rcv_state_process,
+ *			 tcp_rcv_synsent_state_process
+ * Here we link the statistics structure in so it is visible in the /p=
roc
+ * fs, and do some final init.
+ */
+void tcp_estats_establish(struct sock *sk)
+{
+	struct inet_sock *inet =3D inet_sk(sk);
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	struct tcp_estats *stats =3D tp->tcp_stats;
+	struct tcp_estats_connection_table *conn_table;
+
+	if (stats =3D=3D NULL)
+		return;
+
+	conn_table =3D stats->tables.connection_table;
+
+	/* Let's set these here, since they can't change once the
+	 * connection is established.
+	 */
+	conn_table->LocalPort =3D inet->inet_num;
+	conn_table->RemPort =3D ntohs(inet->inet_dport);
+
+	if (conn_table->AddressType =3D=3D TCP_ESTATS_ADDRTYPE_IPV4) {
+		memcpy(&conn_table->LocalAddress.addr, &inet->inet_rcv_saddr,
+			sizeof(struct in_addr));
+		memcpy(&conn_table->RemAddress.addr, &inet->inet_daddr,
+			sizeof(struct in_addr));
+	}
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	else if (conn_table->AddressType =3D=3D TCP_ESTATS_ADDRTYPE_IPV6) {
+		memcpy(&conn_table->LocalAddress.addr6, &(sk)->sk_v6_rcv_saddr,
+		       sizeof(struct in6_addr));
+		/* ipv6 daddr now uses a different struct than saddr */
+		memcpy(&conn_table->RemAddress.addr6, &(sk)->sk_v6_daddr,
+		       sizeof(struct in6_addr));
+	}
+#endif
+	else {
+		pr_err("TCP ESTATS: AddressType not valid.\n");
+	}
+
+	tcp_estats_update_finish_segrecv(tp);
+	tcp_estats_update_rwin_rcvd(tp);
+	tcp_estats_update_rwin_sent(tp);
+
+	TCP_ESTATS_VAR_SET(tp, stack_table, RecInitial, tp->rcv_nxt);
+
+	tcp_estats_update_sndlim(tp, TCP_ESTATS_SNDLIM_SENDER);
+
+	if (tcp_estats_wq_enabled && stats->queued) {
+		INIT_WORK(&stats->establish_notify, establish_notify_func);
+		queue_work(tcp_estats_wq, &stats->establish_notify);
+	}
+}
+
+/*
+ * Statistics update functions
+ */
+
+void tcp_estats_update_snd_nxt(struct tcp_sock *tp)
+{
+	struct tcp_estats *stats =3D tp->tcp_stats;
+
+	if (stats->tables.app_table) {
+		if (after(tp->snd_nxt, stats->tables.app_table->SndMax))
+			stats->tables.app_table->SndMax =3D tp->snd_nxt;
+	}
+}
+
+void tcp_estats_update_acked(struct tcp_sock *tp, u32 ack)
+{
+	struct tcp_estats *stats =3D tp->tcp_stats;
+
+	if (stats->tables.app_table)
+		stats->tables.app_table->ThruOctetsAcked +=3D ack - tp->snd_una;
+}
+
+void tcp_estats_update_rtt(struct sock *sk, unsigned long rtt_sample)
+{
+	struct tcp_estats *stats =3D tcp_sk(sk)->tcp_stats;
+	struct tcp_estats_path_table *path_table =3D stats->tables.path_table=
;
+	unsigned long rtt_sample_msec =3D rtt_sample/1000;
+	u32 rto;
+
+	if (path_table =3D=3D NULL)
+		return;
+
+	path_table->SampleRTT =3D rtt_sample_msec;
+
+	if (rtt_sample_msec > path_table->MaxRTT)
+		path_table->MaxRTT =3D rtt_sample_msec;
+	if (rtt_sample_msec < path_table->MinRTT)
+		path_table->MinRTT =3D rtt_sample_msec;
+
+	path_table->CountRTT++;
+	path_table->SumRTT +=3D rtt_sample_msec;
+
+	rto =3D jiffies_to_msecs(inet_csk(sk)->icsk_rto);
+	if (rto > path_table->MaxRTO)
+		path_table->MaxRTO =3D rto;
+	if (rto < path_table->MinRTO)
+		path_table->MinRTO =3D rto;
+}
+
+void tcp_estats_update_timeout(struct sock *sk)
+{
+	if (inet_csk(sk)->icsk_backoff)
+		TCP_ESTATS_VAR_INC(tcp_sk(sk), stack_table, SubsequentTimeouts);
+	else
+		TCP_ESTATS_VAR_INC(tcp_sk(sk), perf_table, Timeouts);
+
+	if (inet_csk(sk)->icsk_ca_state =3D=3D TCP_CA_Open)
+		TCP_ESTATS_VAR_INC(tcp_sk(sk), stack_table, AbruptTimeouts);
+}
+
+void tcp_estats_update_mss(struct tcp_sock *tp)
+{
+	struct tcp_estats *stats =3D tp->tcp_stats;
+	struct tcp_estats_stack_table *stack_table =3D stats->tables.stack_ta=
ble;
+	int mss =3D tp->mss_cache;
+
+	if (stack_table =3D=3D NULL)
+		return;
+
+	if (mss > stack_table->MaxMSS)
+		stack_table->MaxMSS =3D mss;
+	if (mss < stack_table->MinMSS)
+		stack_table->MinMSS =3D mss;
+}
+
+void tcp_estats_update_finish_segrecv(struct tcp_sock *tp)
+{
+	struct tcp_estats *stats =3D tp->tcp_stats;
+	struct tcp_estats_tables *tables =3D &stats->tables;
+	struct tcp_estats_perf_table *perf_table =3D tables->perf_table;
+	struct tcp_estats_stack_table *stack_table =3D tables->stack_table;
+	u32 mss =3D tp->mss_cache;
+	u32 cwnd;
+	u32 ssthresh;
+	u32 pipe_size;
+
+#ifdef CONFIG_TCP_ESTATS_STRICT_ELAPSEDTIME
+	stats->current_ts =3D ktime_get();
+#else
+	stats->current_ts =3D jiffies;
+#endif
+
+	if (stack_table !=3D NULL) {
+		cwnd =3D tp->snd_cwnd * mss;
+		if (tp->snd_cwnd <=3D tp->snd_ssthresh) {
+			if (cwnd > stack_table->MaxSsCwnd)
+				stack_table->MaxSsCwnd =3D cwnd;
+		} else if (cwnd > stack_table->MaxCaCwnd) {
+			stack_table->MaxCaCwnd =3D cwnd;
+		}
+	}
+
+	if (perf_table !=3D NULL) {
+		pipe_size =3D tcp_packets_in_flight(tp) * mss;
+		if (pipe_size > perf_table->MaxPipeSize)
+			perf_table->MaxPipeSize =3D pipe_size;
+	}
+
+	/* Discard initiail ssthresh set at infinity. */
+	if (tp->snd_ssthresh >=3D TCP_INFINITE_SSTHRESH) {
+		return;
+	}
+
+	if (stack_table !=3D NULL) {
+		ssthresh =3D tp->snd_ssthresh * tp->mss_cache;
+		if (ssthresh > stack_table->MaxSsthresh)
+			stack_table->MaxSsthresh =3D ssthresh;
+		if (ssthresh < stack_table->MinSsthresh)
+			stack_table->MinSsthresh =3D ssthresh;
+	}
+}
+EXPORT_SYMBOL(tcp_estats_update_finish_segrecv);
+
+void tcp_estats_update_rwin_rcvd(struct tcp_sock *tp)
+{
+	struct tcp_estats *stats =3D tp->tcp_stats;
+	struct tcp_estats_perf_table *perf_table =3D stats->tables.perf_table=
;
+	u32 win =3D tp->snd_wnd;
+
+	if (perf_table =3D=3D NULL)
+		return;
+
+	if (win > perf_table->MaxRwinRcvd)
+		perf_table->MaxRwinRcvd =3D win;
+	if (win =3D=3D 0)
+		perf_table->ZeroRwinRcvd++;
+}
+
+void tcp_estats_update_rwin_sent(struct tcp_sock *tp)
+{
+	struct tcp_estats *stats =3D tp->tcp_stats;
+	struct tcp_estats_perf_table *perf_table =3D stats->tables.perf_table=
;
+	u32 win =3D tp->rcv_wnd;
+
+	if (perf_table =3D=3D NULL)
+		return;
+
+	if (win > perf_table->MaxRwinSent)
+		perf_table->MaxRwinSent =3D win;
+	if (win =3D=3D 0)
+		perf_table->ZeroRwinSent++;
+}
+
+void tcp_estats_update_sndlim(struct tcp_sock *tp,
+			      enum tcp_estats_sndlim_states state)
+{
+	struct tcp_estats *stats =3D tp->tcp_stats;
+	struct tcp_estats_perf_table *perf_table =3D stats->tables.perf_table=
;
+	ktime_t now;
+
+	if (state <=3D TCP_ESTATS_SNDLIM_NONE ||
+	    state >=3D TCP_ESTATS_SNDLIM_NSTATES) {
+		pr_err("tcp_estats_update_sndlim: BUG: state out of range %d\n",
+		       state);
+		return;
+	}
+
+	if (perf_table =3D=3D NULL)
+		return;
+
+	now =3D ktime_get();
+	perf_table->snd_lim_time[stats->limstate]
+	    +=3D ktime_to_us(ktime_sub(now, stats->limstate_ts));
+	stats->limstate_ts =3D now;
+	if (stats->limstate !=3D state) {
+		stats->limstate =3D state;
+		perf_table->snd_lim_trans[state]++;
+	}
+}
+
+void tcp_estats_update_congestion(struct tcp_sock *tp)
+{
+	struct tcp_estats *stats =3D tp->tcp_stats;
+	struct tcp_estats_path_table *path_table =3D stats->tables.path_table=
;
+
+	TCP_ESTATS_VAR_INC(tp, perf_table, CongSignals);
+
+	if (path_table !=3D NULL) {
+		path_table->PreCongSumCwnd +=3D tp->snd_cwnd * tp->mss_cache;
+		path_table->PreCongSumRTT +=3D path_table->SampleRTT;
+	}
+}
+
+void tcp_estats_update_post_congestion(struct tcp_sock *tp)
+{
+	struct tcp_estats *stats =3D tp->tcp_stats;
+	struct tcp_estats_path_table *path_table =3D stats->tables.path_table=
;
+
+	if (path_table !=3D NULL) {
+		path_table->PostCongCountRTT++;
+		path_table->PostCongSumRTT +=3D path_table->SampleRTT;
+	}
+}
+
+void tcp_estats_update_segsend(struct sock *sk, int pcount,
+			       u32 seq, u32 end_seq, int flags)
+{
+	struct tcp_estats *stats =3D tcp_sk(sk)->tcp_stats;
+	struct tcp_estats_perf_table *perf_table =3D stats->tables.perf_table=
;
+	struct tcp_estats_app_table *app_table =3D stats->tables.app_table;
+
+	int data_len =3D end_seq - seq;
+
+#ifdef CONFIG_TCP_ESTATS_STRICT_ELAPSEDTIME
+	stats->current_ts =3D ktime_get();
+#else
+	stats->current_ts =3D jiffies;
+#endif
+
+	if (perf_table =3D=3D NULL)
+		return;
+
+	/* We know we're sending a segment. */
+	perf_table->SegsOut +=3D pcount;
+
+	/* A pure ACK contains no data; everything else is data. */
+	if (data_len > 0) {
+		perf_table->DataSegsOut +=3D pcount;
+		perf_table->DataOctetsOut +=3D data_len;
+	}
+
+	/* Check for retransmission. */
+	if (flags & TCPHDR_SYN) {
+		if (inet_csk(sk)->icsk_retransmits)
+			perf_table->SegsRetrans++;
+	} else if (app_table !=3D NULL &&
+		   before(seq, app_table->SndMax)) {
+		perf_table->SegsRetrans +=3D pcount;
+		perf_table->OctetsRetrans +=3D data_len;
+	}
+}
+
+void tcp_estats_update_segrecv(struct tcp_sock *tp, struct sk_buff *sk=
b)
+{
+	struct tcp_estats_tables *tables =3D &tp->tcp_stats->tables;
+	struct tcp_estats_path_table *path_table =3D tables->path_table;
+	struct tcp_estats_perf_table *perf_table =3D tables->perf_table;
+	struct tcp_estats_stack_table *stack_table =3D tables->stack_table;
+	struct tcphdr *th =3D tcp_hdr(skb);
+	struct iphdr *iph =3D ip_hdr(skb);
+
+	if (perf_table !=3D NULL)
+		perf_table->SegsIn++;
+
+	if (skb->len =3D=3D th->doff * 4) {
+		if (stack_table !=3D NULL &&
+		    TCP_SKB_CB(skb)->ack_seq =3D=3D tp->snd_una)
+			stack_table->DupAcksIn++;
+	} else {
+		if (perf_table !=3D NULL) {
+			perf_table->DataSegsIn++;
+			perf_table->DataOctetsIn +=3D skb->len - th->doff * 4;
+		}
+	}
+
+	if (path_table !=3D NULL) {
+		path_table->IpTtl =3D iph->ttl;
+		path_table->IpTosIn =3D iph->tos;
+	}
+}
+EXPORT_SYMBOL(tcp_estats_update_segrecv);
+
+void tcp_estats_update_rcvd(struct tcp_sock *tp, u32 seq)
+{
+        /* After much debate, it was decided that "seq - rcv_nxt" is
+           indeed what we want, as opposed to what Krishnan suggested
+           to better match the RFC: "seq - tp->rcv_wup" */
+	TCP_ESTATS_VAR_ADD(tp, app_table, ThruOctetsReceived,
+			   seq - tp->rcv_nxt);
+}
+
+void tcp_estats_update_writeq(struct sock *sk)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	struct tcp_estats_app_table *app_table =3D
+			tp->tcp_stats->tables.app_table;
+	int len;
+
+	if (app_table =3D=3D NULL)
+		return;
+
+	len =3D tp->write_seq - app_table->SndMax;
+
+	if (len > app_table->MaxAppWQueue)
+		app_table->MaxAppWQueue =3D len;
+}
+
+static inline u32 ofo_qlen(struct tcp_sock *tp)
+{
+	if (!skb_peek(&tp->out_of_order_queue))
+		return 0;
+	else
+		return TCP_SKB_CB(tp->out_of_order_queue.prev)->end_seq -
+		    TCP_SKB_CB(tp->out_of_order_queue.next)->seq;
+}
+
+void tcp_estats_update_recvq(struct sock *sk)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	struct tcp_estats_tables *tables =3D &tp->tcp_stats->tables;
+	struct tcp_estats_app_table *app_table =3D tables->app_table;
+	struct tcp_estats_stack_table *stack_table =3D tables->stack_table;
+
+	if (app_table !=3D NULL) {
+		u32 len =3D tp->rcv_nxt - tp->copied_seq;
+		if (app_table->MaxAppRQueue < len)
+			app_table->MaxAppRQueue =3D len;
+	}
+
+	if (stack_table !=3D NULL) {
+		u32 len =3D ofo_qlen(tp);
+		if (stack_table->MaxReasmQueue < len)
+			stack_table->MaxReasmQueue =3D len;
+	}
+}
+
+/*
+ * Manage connection ID table
+ */
+
+static int get_new_cid(struct tcp_estats *stats)
+{
+         int id_cid;
+
+again:
+         spin_lock_bh(&tcp_estats_idr_lock);
+         id_cid =3D idr_alloc(&tcp_estats_idr, stats, next_id, 0, GFP_=
KERNEL);
+         if (unlikely(id_cid =3D=3D -ENOSPC)) {
+                 spin_unlock_bh(&tcp_estats_idr_lock);
+                 goto again;
+         }
+         if (unlikely(id_cid =3D=3D -ENOMEM)) {
+                 spin_unlock_bh(&tcp_estats_idr_lock);
+                 return -ENOMEM;
+         }
+         next_id =3D (id_cid + 1) % ESTATS_MAX_CID;
+         stats->tcpe_cid =3D id_cid;
+         spin_unlock_bh(&tcp_estats_idr_lock);
+         return 0;
+}
+
+static void create_func(struct work_struct *work)
+{
+	/* stub for netlink notification of new connections */
+	;
+}
+
+static void establish_func(struct work_struct *work)
+{
+	struct tcp_estats *stats =3D container_of(work, struct tcp_estats,
+						establish_notify);
+	int err =3D 0;
+
+	if ((stats->tcpe_cid) > 0) {
+		pr_err("TCP estats container established multiple times.\n");
+		return;
+	}
+
+	if ((stats->tcpe_cid) =3D=3D 0) {
+		err =3D get_new_cid(stats);
+		if (err)
+			pr_devel("get_new_cid error %d\n", err);
+	}
+}
+
+static void destroy_func(struct work_struct *work)
+{
+	struct tcp_estats *stats =3D container_of(work, struct tcp_estats,
+						destroy_notify.work);
+
+	int id_cid =3D stats->tcpe_cid;
+
+	if (id_cid =3D=3D 0)
+		pr_devel("TCP estats destroyed before being established.\n");
+
+	if (id_cid >=3D 0) {
+		if (id_cid) {
+			spin_lock_bh(&tcp_estats_idr_lock);
+			idr_remove(&tcp_estats_idr, id_cid);
+			spin_unlock_bh(&tcp_estats_idr_lock);
+		}
+		stats->tcpe_cid =3D -1;
+
+		tcp_estats_unuse(stats);
+	}
+}
+
+void __init tcp_estats_init()
+{
+	idr_init(&tcp_estats_idr);
+
+	create_notify_func =3D &create_func;
+	establish_notify_func =3D &establish_func;
+	destroy_notify_func =3D &destroy_func;
+
+	persist_delay =3D TCP_ESTATS_PERSIST_DELAY_SECS * HZ;
+
+	tcp_estats_wq =3D alloc_workqueue("tcp_estats", WQ_MEM_RECLAIM, 256);
+	if (tcp_estats_wq =3D=3D NULL) {
+		pr_err("tcp_estats_init(): alloc_workqueue failed\n");
+		goto cleanup_fail;
+	}
+
+	tcp_estats_wq_enabled =3D 1;
+	return;
+
+cleanup_fail:
+	pr_err("TCP ESTATS: initialization failed.\n");
+}
--=20
1.9.3
