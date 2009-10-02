From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH] TCPCT-1: adding a sysctl
Date: Fri, 02 Oct 2009 10:58:13 -0400
Message-ID: <4AC61505.8030701@gmail.com>
References: <4AC57AC5.3080703@gmail.com> <20091001225705.788d38ba@nehalam>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080503000504090508010102"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:48233 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608AbZJBO6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 10:58:16 -0400
Received: by fxm27 with SMTP id 27so1107571fxm.17
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2009 07:58:19 -0700 (PDT)
In-Reply-To: <20091001225705.788d38ba@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080503000504090508010102
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit

Stephen Hemminger wrote:
> BUT numbered sysctl values are deprecated and should no longer be added.
> The current way is to use CTL_UNNUMBERED instead, if you use CTL_UNNUMBERED
> then the table does not need to be changed.
> 
Thank you, that was immensely helpful.  I was using an old (related) example.

While I've long had credit in BSD-derived systems, this is the first I've
tried to implement for Linux kernel -- although I did give permission 15 or so
years ago for a fair amount of my stuff to be ported here under GPL....

This is a straightforward re-implementation of an earlier patch, that no
longer applies cleanly, that was reviewed:

   http://thread.gmane.org/gmane.linux.network/102586

With the original author's permission:

Adam Langley wrote:
# I'm afraid that my draft is now mostly dead!
#
# Please feel free to use any of the code that you found if it helps you
# and all the best with it,
#

The principle difference is using a TCP option to carry the cookie nonce,
instead of an offset to a random nonce in the data.  This allows several
related concepts to use the same extension option.  This cookie option has
been suggested for many years.

   http://www.merit.net/mail.archives/nanog/1996-09/msg00235.html

Also, as mentioned earlier, I added a sysctl to turn on and off the cookie
feature globally.  The cookies are useful even without SYN data.

Since I'm new around here, this first patch is just the ioctl and sysctl.

Any suggestions for improvement?  Or general approval?


--------------080503000504090508010102
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="tcpct-1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tcpct-1.patch"

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 61723a7..a8d8a88 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -96,6 +96,7 @@ enum {
 #define TCP_QUICKACK		12	/* Block/reenable quick acks */
 #define TCP_CONGESTION		13	/* Congestion control algorithm */
 #define TCP_MD5SIG		14	/* TCP MD5 Signature (RFC2385) */
+#define TCP_COOKIE_DATA		15	/* TCP Cookie Transactions extension */
 
 #define TCPI_OPT_TIMESTAMPS	1
 #define TCPI_OPT_SACK		2
@@ -170,6 +171,33 @@ struct tcp_md5sig {
 	__u8	tcpm_key[TCP_MD5SIG_MAXKEYLEN];		/* key (binary) */
 };
 
+/* for TCP_COOKIE_DATA socket option */
+#define TCP_COOKIE_MAX		16		/* 128-bits */
+#define TCP_COOKIE_MIN		 8		/*  64-bits */
+#define TCP_COOKIE_PAIR_SIZE	(2*TCP_COOKIE_MAX)
+
+#define TCP_S_DATA_MAX		64U		/* after TCP+IP options */
+#define TCP_S_DATA_MSS_DEFAULT	536U		/* default MSS (RFC1122) */
+
+/* Flags for both getsockopt and setsockopt */
+#define TCP_COOKIE_IN_ALWAYS	(1 << 0)	/* Discard SYN without cookie */
+#define TCP_COOKIE_OUT_NEVER	(1 << 1)	/* Prohibit outgoing cookies.
+						   Supercedes the others. */
+
+/* Flags for getsockopt */
+#define TCP_S_DATA_IN		(1 << 2)	/* Was data received? */
+#define TCP_S_DATA_OUT		(1 << 3)	/* Was data sent? */
+
+/* TCP Cookie Transactions data */
+struct tcp_cookie_data {
+	__u16	tcpcd_flags;			/* see above */
+	__u8	__tcpcd_pad1;			/* zero */
+	__u8	tcpcd_cookie_desired;		/* bytes */
+	__u16	tcpcd_s_data_desired;		/* bytes of variable data */
+	__u16	tcpcd_used;			/* bytes in value */
+	__u8	tcpcd_value[TCP_S_DATA_MSS_DEFAULT];
+};
+
 #ifdef __KERNEL__
 
 #include <linux/skbuff.h>
@@ -217,9 +245,13 @@ struct tcp_options_received {
 		sack_ok : 4,	/* SACK seen on SYN packet		*/
 		snd_wscale : 4,	/* Window scaling received from sender	*/
 		rcv_wscale : 4;	/* Window scaling to send to receiver	*/
-/*	SACKs data	*/
+#ifdef CONFIG_TCP_OPT_COOKIE_EXTENSION
+	u16	extend_ok:1;	/* Cookie{less,pair} seen		*/
+	u8	*cookie_copy;
+	u8	cookie_size;	/* bytes in copy */
+#endif
 	u8	num_sacks;	/* Number of SACK blocks		*/
-	u16	user_mss;  	/* mss requested by user in ioctl */
+	u16	user_mss;	/* mss requested by user in ioctl	*/
 	u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
 };
 
@@ -229,14 +261,27 @@ struct tcp_options_received {
  * only four options will fit in a standard TCP header */
 #define TCP_NUM_SACKS 4
 
+#ifdef CONFIG_TCP_OPT_COOKIE_EXTENSION
+struct tcp_cookie_pair;
+struct tcp_s_data_payload;
+#endif
+
 struct tcp_request_sock {
 	struct inet_request_sock 	req;
 #ifdef CONFIG_TCP_MD5SIG
 	/* Only used by TCP MD5 Signature so far. */
 	const struct tcp_request_sock_ops *af_specific;
 #endif
-	u32			 	rcv_isn;
-	u32			 	snt_isn;
+	u32				rcv_isn;
+	u32				snt_isn;
+#ifdef CONFIG_TCP_OPT_COOKIE_EXTENSION
+	u8				*cookie_copy;
+	u8				cookie_size;	/* bytes in copy */
+	u8				s_data_in:1,
+					s_data_out:1,
+					cookie_in_always:1,
+					cookie_out_never:1;
+#endif
 };
 
 static inline struct tcp_request_sock *tcp_rsk(const struct request_sock *req)
@@ -406,6 +451,33 @@ struct tcp_sock {
 /* TCP MD5 Signature Option information */
 	struct tcp_md5sig_info	*md5sig_info;
 #endif
+#ifdef CONFIG_TCP_OPT_COOKIE_EXTENSION
+	/* If s_data_desired > 0 and s_data_payload is non-NULL, then this
+	 * object holds a reference to it (s_data_payload->kref)
+	 */
+	struct tcp_s_data_payload	*s_data_payload;
+
+	/* When the cookie options are generated and exchanged, then this
+	 * object holds a reference to them (cookie_pair->kref)
+	 */
+	struct tcp_cookie_pair	  	*cookie_pair;
+
+	/* If s_data_payload is non-NULL, then this holds a copy of
+	 * s_data_payload->tsdpl_size.  Otherwise, this holds the user
+	 * specified tcpcd_s_data_desired (variable data).
+	 */
+	u16				s_data_desired;	/* bytes */
+
+	/* Initially, this holds the user specified tcpcd_cookie_desired.
+	 * Zero indicates default (sysctl_tcp_cookie_size).  After the
+	 * option has been exchanged, this holds the actual size.
+	 */
+	u8				cookie_desired;	/* bytes */
+	u8				s_data_in:1,
+					s_data_out:1,
+					cookie_in_always:1,
+					cookie_out_never:1;
+#endif
 };
 
 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
@@ -424,6 +496,12 @@ struct tcp_timewait_sock {
 	u16			  tw_md5_keylen;
 	u8			  tw_md5_key[TCP_MD5SIG_MAXKEYLEN];
 #endif
+#ifdef CONFIG_TCP_OPT_COOKIE_EXTENSION
+	/* Few sockets in timewait have cookies; in that case, then this
+	 * object holds a reference to it (tw_cookie_pair->kref)
+	 */
+	struct tcp_cookie_pair	  *tw_cookie_pair;
+#endif
 };
 
 static inline struct tcp_timewait_sock *tcp_twsk(const struct sock *sk)
@@ -431,6 +509,6 @@ static inline struct tcp_timewait_sock *tcp_twsk(const struct sock *sk)
 	return (struct tcp_timewait_sock *)sk;
 }
 
-#endif
+#endif	/* __KERNEL__ */
 
 #endif	/* _LINUX_TCP_H */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 03a49c7..6755ed8 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -30,6 +30,7 @@
 #include <linux/dmaengine.h>
 #include <linux/crypto.h>
 #include <linux/cryptohash.h>
+#include <linux/kref.h>
 
 #include <net/inet_connection_sock.h>
 #include <net/inet_timewait_sock.h>
@@ -167,6 +168,7 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOPT_SACK             5       /* SACK Block */
 #define TCPOPT_TIMESTAMP	8	/* Better RTT estimations/PAWS */
 #define TCPOPT_MD5SIG		19	/* MD5 Signature (RFC2385) */
+#define TCPOPT_COOKIE		253	/* Cookie extension (experimental) */
 
 /*
  *     TCP option lengths
@@ -177,6 +179,10 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOLEN_SACK_PERM      2
 #define TCPOLEN_TIMESTAMP      10
 #define TCPOLEN_MD5SIG         18
+#define TCPOLEN_COOKIE_BASE    2	/* Cookie-less header extension */
+#define TCPOLEN_COOKIE_PAIR    3	/* Cookie pair header extension */
+#define TCPOLEN_COOKIE_MAX     (TCPOLEN_COOKIE_BASE+TCP_COOKIE_MAX)
+#define TCPOLEN_COOKIE_MIN     (TCPOLEN_COOKIE_BASE+TCP_COOKIE_MIN)
 
 /* But this is what stacks really send out. */
 #define TCPOLEN_TSTAMP_ALIGNED		12
@@ -237,6 +243,7 @@ extern int sysctl_tcp_base_mss;
 extern int sysctl_tcp_workaround_signed_windows;
 extern int sysctl_tcp_slow_start_after_idle;
 extern int sysctl_tcp_max_ssthresh;
+extern int sysctl_tcp_cookie_size;
 
 extern atomic_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
@@ -345,7 +352,12 @@ extern void tcp_enter_quickack_mode(struct sock *sk);
 
 static inline void tcp_clear_options(struct tcp_options_received *rx_opt)
 {
- 	rx_opt->tstamp_ok = rx_opt->sack_ok = rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
+#ifdef CONFIG_TCP_OPT_COOKIE_EXTENSION
+	rx_opt->cookie_copy = NULL;
+	rx_opt->cookie_size = rx_opt->extend_ok =
+#endif
+	rx_opt->tstamp_ok = rx_opt->sack_ok =
+	rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
 }
 
 #define	TCP_ECN_OK		1
@@ -1480,6 +1492,46 @@ struct tcp_request_sock_ops {
 #endif
 };
 
+#ifdef CONFIG_TCP_OPT_COOKIE_EXTENSION
+/**
+ * This structure contains variable data that is to be included in the
+ * cookie option and compared with later incoming segments.
+ *
+ * A tcp_sock contains a pointer to the current value, and this is cloned to
+ * the tcp_timewait_sock.
+ */
+struct tcp_cookie_pair {
+	struct kref	kref;
+	/* 32-bit aligned for faster comparisons? */
+	u8		tcpcp_data[TCP_COOKIE_PAIR_SIZE];
+	u8		tcpcp_size;	/* of the cookie pair */
+};
+
+static inline void tcp_cookie_pair_release(struct kref *kref)
+{
+	kfree(container_of(kref, struct tcp_cookie_pair, kref));
+}
+
+/**
+ * This structure contains constant data that is to be included in the
+ * payload of SYN or SYNACK segments when the cookie option is present.
+ *
+ * This structure is immutable (save for the reference counter) once created.
+ * A tcp_sock contains a pointer to the current value, and this is cloned to
+ * the request socks as they are generated.
+ */
+struct tcp_s_data_payload {
+	struct kref	kref;
+	u16		tsdpl_size;	/* of the trailing payload */
+	u8		tsdpl_data[0];	/* trailing payload */
+};
+
+static inline void tcp_s_data_payload_release(struct kref *kref)
+{
+	kfree(container_of(kref, struct tcp_s_data_payload, kref));
+}
+#endif
+
 extern void tcp_v4_init(void);
 extern void tcp_init(void);
 
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 70491d9..1cf3be5 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -627,3 +627,36 @@ config TCP_MD5SIG
 
 	  If unsure, say N.
 
+config TCP_OPT_COOKIE_EXTENSION
+	bool "TCP: Cookie option extension (EXPERIMENTAL)"
+	default n
+	depends on EXPERIMENTAL
+	select CRYPTO
+	select CRYPTO_MD5
+	---help---
+	  TCP/IP networking is open to an attack known as "SYN flooding".
+	  This denial-of-service attack prevents legitimate remote users
+	  from being able to connect to the computer during an ongoing
+	  attack and requires very little work from the attacker, who can
+	  operate from anywhere on the Internet.
+
+	  TCP Cookie Transactions (TCPCT) deter spoofing of client
+	  connections and prevent server resource exhaustion, by
+	  eliminating the need to maintain server state during <SYN>
+	  establishment and after <FIN> and <RST> termination of
+	  connections.  The TCPCT cookie exchange itself may optionally
+	  carry <SYN> data, limited in size to inhibit Denial of Service
+	  (DoS) attacks. Implements TCP header extension, allowing
+	  64-bit timestamps and more Selective Acknowledgments.
+
+	  Unlike the passive "SYN cookies" option, other TCP options will
+	  continue to work.  If configured, SYN cookies continue to function
+	  for those parties that do not use this Cookie extension option.
+
+	  If you say Y here, note that TCPCT isn't yet enabled by default.
+
+	  The sysctl "tcp_cookie_size" should be in the range 8 to 16,
+	  although any non-zero value will be adjusted automatically.
+
+	  If unsure, say N.
+
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 2dcf04d..25b60eb 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -712,6 +712,16 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+#ifdef CONFIG_TCP_OPT_COOKIE_EXTENSION
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "tcp_cookie_size",
+		.data		= &sysctl_tcp_cookie_size,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+#endif
 	{
 		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "udp_mem",
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5200aab..93af24c 100644
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

--------------080503000504090508010102--
