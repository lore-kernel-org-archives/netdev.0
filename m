From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [net-next-2.6 PATCH 2/4 resent] TCPCT part 1b: sysctl_tcp_cookie_size
 and TCP_COOKIE_TRANSACTIONS
Date: Thu, 15 Oct 2009 11:01:15 -0400
Message-ID: <4AD7393B.3050406@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010901030502050303080802"
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:31595 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756303AbZJOPDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 11:03:08 -0400
Received: by fg-out-1718.google.com with SMTP id d23so1985999fga.1
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 08:01:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010901030502050303080802
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Define sysctl (tcp_cookie_size) to turn on and off the cookie option
default globally, instead of a compiled configuration option.

Define per socket option (TCP_COOKIE_TRANSACTIONS) for setting constant
data values, retrieving variable cookie values, and other facilities.

This is a straightforward re-implementation of an earlier (year-old)
patch that no longer applies cleanly, with permission of the original
author (Adam Langley).  The patch was previously reviewed:

    http://thread.gmane.org/gmane.linux.network/102586

These functions will also be used in subsequent patches that implement
additional features.
---
   include/linux/tcp.h        |   31 ++++++++++++++++++++++++++++++-
   include/net/tcp.h          |    1 +
   net/ipv4/sysctl_net_ipv4.c |    8 ++++++++
   net/ipv4/tcp_output.c      |    8 ++++++++
   4 files changed, 47 insertions(+), 1 deletions(-)



--------------010901030502050303080802
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+1-2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+1-2.patch"

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 61723a7..63ab660 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -96,6 +96,7 @@ enum {
 #define TCP_QUICKACK		12	/* Block/reenable quick acks */
 #define TCP_CONGESTION		13	/* Congestion control algorithm */
 #define TCP_MD5SIG		14	/* TCP MD5 Signature (RFC2385) */
+#define TCP_COOKIE_TRANSACTIONS	15	/* TCP Cookie Transactions */
 
 #define TCPI_OPT_TIMESTAMPS	1
 #define TCPI_OPT_SACK		2
@@ -170,6 +171,34 @@ struct tcp_md5sig {
 	__u8	tcpm_key[TCP_MD5SIG_MAXKEYLEN];		/* key (binary) */
 };
 
+/* for TCP_COOKIE_TRANSACTIONS (TCPCT) socket option */
+#define TCP_COOKIE_MAX		16		/* 128-bits */
+#define TCP_COOKIE_MIN		 8		/*  64-bits */
+#define TCP_COOKIE_PAIR_SIZE	(2*TCP_COOKIE_MAX)
+
+#define TCP_S_DATA_MAX		64U		/* after TCP+IP options */
+#define TCP_S_DATA_MSS_DEFAULT	536U		/* default MSS (RFC1122) */
+
+/* Flags for both getsockopt and setsockopt */
+#define TCP_COOKIE_IN_ALWAYS	(1 << 0)	/* Discard SYN without cookie */
+#define TCP_COOKIE_OUT_NEVER	(1 << 1)	/* Prohibit outgoing cookies,
+						 * supercedes everything else. */
+#define TCP_EXTEND_TIMESTAMP	(1 << 4)	/* Initiate 64-bit timestamps */
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
+	__u8	tcpct_value[TCP_S_DATA_MSS_DEFAULT];
+};
+
 #ifdef __KERNEL__
 
 #include <linux/skbuff.h>
@@ -431,6 +460,6 @@ static inline struct tcp_timewait_sock *tcp_twsk(const struct sock *sk)
 	return (struct tcp_timewait_sock *)sk;
 }
 
-#endif
+#endif	/* __KERNEL__ */
 
 #endif	/* _LINUX_TCP_H */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 28bcaf7..63d17fd 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -237,6 +237,7 @@ extern int sysctl_tcp_base_mss;
 extern int sysctl_tcp_workaround_signed_windows;
 extern int sysctl_tcp_slow_start_after_idle;
 extern int sysctl_tcp_max_ssthresh;
+extern int sysctl_tcp_cookie_size;
 
 extern atomic_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
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
index 765d80f..c235196 100644
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
1.6.0.4



--------------010901030502050303080802--
