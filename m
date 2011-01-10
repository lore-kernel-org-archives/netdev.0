From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH v1] TCPCT sysctl API update to draft -02
Date: Mon, 10 Jan 2011 12:48:12 -0500
Message-ID: <4D2B465C.2030305@gmail.com>
References: <4D28D8EF.5010008@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020605020101030709030604"
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Andi Kleen <andi@firstfloor.org>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:55456 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751393Ab1AJRsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 12:48:16 -0500
Received: by iwn9 with SMTP id 9so19385414iwn.19
        for <netdev@vger.kernel.org>; Mon, 10 Jan 2011 09:48:16 -0800 (PST)
In-Reply-To: <4D28D8EF.5010008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020605020101030709030604
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Circa 15 months ago, my first submitted patch was a sysctl, and there was a
conflict that appeared in a later merge of trees.  Experts, am I in the right
ballpark this time around?

Later, I'll submit the manpage patch to linux-man@vger.kernel.org too.

===

Use most recently specified symbols of RFC-to-be-6013.

Allows different global s_data limits for SYN and SYN_ACK.

Signed-off-by: William.Allen.Simpson@gmail.com
---
  include/net/tcp.h          |    2 ++
  net/ipv4/sysctl_net_ipv4.c |   25 ++++++++++++++++++++++++-
  net/ipv4/tcp_output.c      |   19 +++++++++++++++++--
  3 files changed, 43 insertions(+), 3 deletions(-)


--------------020605020101030709030604
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+API-02u1+2.6.37.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="TCPCT+API-02u1+2.6.37.patch"

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 38509f0..3ac2bca 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -241,6 +241,8 @@ extern int sysctl_tcp_workaround_signed_windows;
 extern int sysctl_tcp_slow_start_after_idle;
 extern int sysctl_tcp_max_ssthresh;
 extern int sysctl_tcp_cookie_size;
+extern int sysctl_tcp_syn_data_limit;
+extern int sysctl_tcp_syn_ack_data_limit;
 extern int sysctl_tcp_thin_linear_timeouts;
 extern int sysctl_tcp_thin_dupack;
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 1a45665..629f90b 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -30,6 +30,9 @@ static int tcp_adv_win_scale_min = -31;
 static int tcp_adv_win_scale_max = 31;
 static int ip_ttl_min = 1;
 static int ip_ttl_max = 255;
+static int tcp_cookie_max = TCP_COOKIE_MAX;
+static int tcp_syn_data_max = TCP_MSS_DEFAULT - 40;
+static int tcp_syn_ack_data_max = TCP_MSS_DESIRED;
 
 /* Update system visible IP port range */
 static void set_local_port_range(int range[2])
@@ -588,7 +591,27 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_cookie_size,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &tcp_cookie_max,
+	},
+	{
+		.procname	= "tcp_syn_data_limit",
+		.data		= &sysctl_tcp_syn_data_limit,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &tcp_syn_data_max,
+	},
+	{
+		.procname	= "tcp_syn_ack_data_limit",
+		.data		= &sysctl_tcp_syn_ack_data_limit,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &tcp_syn_ack_data_max,
 	},
 	{
 		.procname       = "tcp_thin_linear_timeouts",
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index dc7c096..3bd3da5 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -63,6 +63,15 @@ int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
 int sysctl_tcp_cookie_size __read_mostly = 0; /* TCP_COOKIE_MAX */
 EXPORT_SYMBOL_GPL(sysctl_tcp_cookie_size);
 
+int sysctl_tcp_syn_data_limit __read_mostly = TCP_MSS_DEFAULT - 40;
+EXPORT_SYMBOL_GPL(sysctl_tcp_syn_data_limit);
+
+/* As a matter of security policy, keep the initial setting small for most
+ * client systems to avoid their use in amplification DoS attacks.
+ */
+int sysctl_tcp_syn_ack_data_limit __read_mostly = 80; /* TCP_MSS_DESIRED */
+EXPORT_SYMBOL_GPL(sysctl_tcp_syn_ack_data_limit);
+
 
 /* Account for new data that has been sent to the network. */
 static void tcp_event_new_data_sent(struct sock *sk, struct sk_buff *skb)
@@ -2418,10 +2427,16 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	struct tcp_md5sig_key *md5;
 	int tcp_header_size;
 	int mss;
-	int s_data_desired = 0;
+	int s_data_desired;
 
-	if (cvp != NULL && cvp->s_data_constant && cvp->s_data_desired)
+	if (cvp != NULL &&
+	    cvp->s_data_constant &&
+	    cvp->s_data_desired > 0 &&
+	    cvp->s_data_desired <= sysctl_tcp_syn_ack_data_limit)
 		s_data_desired = cvp->s_data_desired;
+	else
+		s_data_desired = 0;
+
 	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15 + s_data_desired, 1, GFP_ATOMIC);
 	if (skb == NULL)
 		return NULL;
-- 
1.7.1


--------------020605020101030709030604--
