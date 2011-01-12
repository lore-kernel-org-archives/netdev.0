From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH v1 1/2] TCPCT API sysctl update to draft -03
Date: Wed, 12 Jan 2011 12:52:51 -0500
Message-ID: <4D2DEA73.4000708@gmail.com>
References: <4D2DE824.10205@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020801090202090500050900"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:43301 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696Ab1ALRwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 12:52:55 -0500
In-Reply-To: <4D2DE824.10205@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020801090202090500050900
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use most recently specified symbols of RFC-to-be-6013.

Allows different global s_data limits for SYN and SYN_ACK.

CC: "Eric W. Biederman" <ebiederm@xmission.com>
CC: Stephen Hemminger <shemminger@vyatta.com>
CC: Andi Kleen <andi@firstfloor.org>
Signed-off-by: William.Allen.Simpson@gmail.com
---
  Documentation/networking/ip-sysctl.txt |   10 ++++++++++
  include/net/tcp.h                      |    2 ++
  net/ipv4/sysctl_net_ipv4.c             |   25 ++++++++++++++++++++++++-
  net/ipv4/tcp_output.c                  |   19 +++++++++++++++++--
  4 files changed, 53 insertions(+), 3 deletions(-)

--------------020801090202090500050900
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+API-03u1+2.6.37.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="TCPCT+API-03u1+2.6.37.patch"

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index d99940d..4e14b3a 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -184,6 +184,16 @@ tcp_cookie_size - INTEGER
 	as the minimum.  Odd values are interpreted as the next even value.
 	Default: 0 (off).
 
+tcp_syn_data_limit - INTEGER
+	Limit for TCP Cookie Transactions (TCPCT) data transmitted with
+	the <SYN>. Default: 496. Maximum: 496.
+
+tcp_syn_ack_data_limit - INTEGER
+	Limit for TCP Cookie Transactions (TCPCT) data transmitted with
+	the <SYN,ACK(SYN)>. As a matter of security policy, keep the
+	setting small to avoid amplification denial of service attacks.
+	Default: 80. Maximum: 1220.
+
 tcp_dsack - BOOLEAN
 	Allows TCP to send "duplicate" SACKs.
 
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
index dc7c096..16a9e40 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -63,6 +63,15 @@ int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
 int sysctl_tcp_cookie_size __read_mostly = 0; /* TCP_COOKIE_MAX */
 EXPORT_SYMBOL_GPL(sysctl_tcp_cookie_size);
 
+int sysctl_tcp_syn_data_limit __read_mostly = TCP_MSS_DEFAULT - 40;
+EXPORT_SYMBOL_GPL(sysctl_tcp_syn_data_limit);
+
+/* As a matter of security policy, keep the setting small to avoid
+ * amplification denial of service attacks.
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


--------------020801090202090500050900--
