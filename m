From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [net-next-2.6 PATCH v5 3/5 RFC] TCPCT part1c: sysctl_tcp_cookie_size,
 socket option TCP_COOKIE_TRANSACTIONS, functions
Date: Mon, 09 Nov 2009 11:33:28 -0500
Message-ID: <4AF84458.9070000@gmail.com>
References: <4AF83E2D.1050401@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060208050900010301080505"
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:34113 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756285AbZKIQd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 11:33:29 -0500
Received: by bwz27 with SMTP id 27so3640439bwz.21
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2009 08:33:34 -0800 (PST)
In-Reply-To: <4AF83E2D.1050401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060208050900010301080505
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Define sysctl (tcp_cookie_size) to turn on and off the cookie option
default globally, instead of a compiled configuration option.

Define per socket option (TCP_COOKIE_TRANSACTIONS) for setting constant
data values, retrieving variable cookie values, and other facilities.

Redefine two TCP header functions to accept TCP header pointer.
When subtracting, return signed int to allow error checking.

Move inline tcp_clear_options() unchanged from net/tcp.h to linux/tcp.h,
near its corresponding struct tcp_options_received (prior to changes).

This is a straightforward re-implementation of an earlier (year-old)
patch that no longer applies cleanly, with permission of the original
author (Adam Langley).  The patch was previously reviewed:

    http://thread.gmane.org/gmane.linux.network/102586

These functions will also be used in subsequent patches that implement
additional features.

Requires:
   TCPCT part 1b: TCP_MSS_DEFAULT, TCP_MSS_DESIRED

Signed-off-by: William.Allen.Simpson@gmail.com
---
  Documentation/networking/ip-sysctl.txt |    8 ++++++
  include/linux/tcp.h                    |   44 +++++++++++++++++++++++++++++++-
  include/net/tcp.h                      |    6 +---
  net/ipv4/sysctl_net_ipv4.c             |    8 ++++++
  net/ipv4/tcp_output.c                  |    8 ++++++
  5 files changed, 68 insertions(+), 6 deletions(-)

--------------060208050900010301080505
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+1c5.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+1c5.patch"

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index a0e134d..d47c000 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -164,6 +164,14 @@ tcp_congestion_control - STRING
 	additional choices may be available based on kernel configuration.
 	Default is set as part of kernel configuration.
 
+tcp_cookie_size - INTEGER
+	Default size of TCP Cookie Transactions (TCPCT) option, that may be
+	overridden on a per socket basis by the TCPCT socket option.
+	Values greater than the maximum (16) are interpreted as the maximum.
+	Values greater than zero and less than the minimum (8) are interpreted
+	as the minimum.
+	Default: 0 (off).
+
 tcp_dsack - BOOLEAN
 	Allows TCP to send "duplicate" SACKs.
 
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 32d7d77..57921c1 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -102,7 +102,9 @@ enum {
 #define TCP_QUICKACK		12	/* Block/reenable quick acks */
 #define TCP_CONGESTION		13	/* Congestion control algorithm */
 #define TCP_MD5SIG		14	/* TCP MD5 Signature (RFC2385) */
+#define TCP_COOKIE_TRANSACTIONS	15	/* TCP Cookie Transactions */
 
+/* for TCP_INFO socket option */
 #define TCPI_OPT_TIMESTAMPS	1
 #define TCPI_OPT_SACK		2
 #define TCPI_OPT_WSCALE		4
@@ -174,6 +176,30 @@ struct tcp_md5sig {
 	__u8	tcpm_key[TCP_MD5SIG_MAXKEYLEN];		/* key (binary) */
 };
 
+/* for TCP_COOKIE_TRANSACTIONS (TCPCT) socket option */
+#define TCP_COOKIE_MAX		16		/* 128-bits */
+#define TCP_COOKIE_MIN		 8		/*  64-bits */
+#define TCP_COOKIE_PAIR_SIZE	(2*TCP_COOKIE_MAX)
+
+/* Flags for both getsockopt and setsockopt */
+#define TCP_COOKIE_IN_ALWAYS	(1 << 0)	/* Discard SYN without cookie */
+#define TCP_COOKIE_OUT_NEVER	(1 << 1)	/* Prohibit outgoing cookies,
+						 * supercedes everything. */
+
+/* Flags for getsockopt */
+#define TCP_S_DATA_IN		(1 << 2)	/* Was data received? */
+#define TCP_S_DATA_OUT		(1 << 3)	/* Was data sent? */
+
+/* TCP_COOKIE_TRANSACTIONS data */
+struct tcp_cookie_transactions {
+	__u16	tcpct_flags;			/* see above */
+	__u8	__tcpct_pad1;			/* zero */
+	__u8	tcpct_cookie_desired;		/* bytes */
+	__u16	tcpct_s_data_desired;		/* bytes of variable data */
+	__u16	tcpct_used;			/* bytes in value */
+	__u8	tcpct_value[TCP_MSS_DEFAULT];
+};
+
 #ifdef __KERNEL__
 
 #include <linux/skbuff.h>
@@ -197,6 +223,17 @@ static inline unsigned int tcp_optlen(const struct sk_buff *skb)
 	return (tcp_hdr(skb)->doff - 5) * 4;
 }
 
+static inline unsigned int tcp_header_len_th(const struct tcphdr *th)
+{
+	return th->doff * 4;
+}
+
+/* When doff is bad, this could be negative. */
+static inline int tcp_option_len_th(const struct tcphdr *th)
+{
+	return (int)(th->doff * 4) - sizeof(*th);
+}
+
 /* This defines a selective acknowledgement block. */
 struct tcp_sack_block_wire {
 	__be32	start_seq;
@@ -227,6 +264,11 @@ struct tcp_options_received {
 	u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
 };
 
+static inline void tcp_clear_options(struct tcp_options_received *rx_opt)
+{
+	rx_opt->tstamp_ok = rx_opt->sack_ok = rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
+}
+
 /* This is the max number of SACKS that we'll generate and process. It's safe
  * to increse this, although since:
  *   size = TCPOLEN_SACK_BASE_ALIGNED (4) + n * TCPOLEN_SACK_PERBLOCK (8)
@@ -435,6 +477,6 @@ static inline struct tcp_timewait_sock *tcp_twsk(const struct sock *sk)
 	return (struct tcp_timewait_sock *)sk;
 }
 
-#endif
+#endif	/* __KERNEL__ */
 
 #endif	/* _LINUX_TCP_H */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index a413e9f..f15924b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -234,6 +234,7 @@ extern int sysctl_tcp_base_mss;
 extern int sysctl_tcp_workaround_signed_windows;
 extern int sysctl_tcp_slow_start_after_idle;
 extern int sysctl_tcp_max_ssthresh;
+extern int sysctl_tcp_cookie_size;
 
 extern atomic_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
@@ -340,11 +341,6 @@ static inline void tcp_dec_quickack_mode(struct sock *sk,
 
 extern void tcp_enter_quickack_mode(struct sock *sk);
 
-static inline void tcp_clear_options(struct tcp_options_received *rx_opt)
-{
- 	rx_opt->tstamp_ok = rx_opt->sack_ok = rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
-}
-
 #define	TCP_ECN_OK		1
 #define	TCP_ECN_QUEUE_CWR	2
 #define	TCP_ECN_DEMAND_CWR	4
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 2dcf04d..3422c54 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -714,6 +714,14 @@ static struct ctl_table ipv4_table[] = {
 	},
 	{
 		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "tcp_cookie_size",
+		.data		= &sysctl_tcp_cookie_size,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "udp_mem",
 		.data		= &sysctl_udp_mem,
 		.maxlen		= sizeof(sysctl_udp_mem),
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 784e6ee..492ccdd 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -59,6 +59,14 @@ int sysctl_tcp_base_mss __read_mostly = 512;
 /* By default, RFC2861 behavior.  */
 int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
 
+#ifdef CONFIG_SYSCTL
+/* By default, let the user enable it. */
+int sysctl_tcp_cookie_size __read_mostly = 0;
+#else
+int sysctl_tcp_cookie_size __read_mostly = TCP_COOKIE_MAX;
+#endif
+
+
 /* Account for new data that has been sent to the network. */
 static void tcp_event_new_data_sent(struct sock *sk, struct sk_buff *skb)
 {
-- 
1.6.3.3


--------------060208050900010301080505--
