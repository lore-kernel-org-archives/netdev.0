From: David Miller <davem@davemloft.net>
Subject: tcp_slow_start_after_idle
Date: Tue, 13 Jun 2006 22:35:38 -0700 (PDT)
Message-ID: <20060613.223538.24611602.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zach.brown@oracle.com, jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:912
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964889AbWFNFfb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 01:35:31 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Bringing back up this old topic:

	http://marc.theaimsgroup.com/?l=linux-netdev&m=114564962420171&w=2

I've decided to add this tunable to the net-2.6.18 tree, patch below.

The more I think about it, allowing it to be turned off is
reasonable, but it will be left on by default.

diff-tree 1cd14da556199b2827a92f1eaa9d3e8411c2b68d (from 2fa95182e211572e998c7d1f906aa74fb119b025)
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Tue Jun 13 22:33:04 2006 -0700

    [TCP]: Add tcp_slow_start_after_idle sysctl.
    
    A lot of people have asked for a way to disable tcp_cwnd_restart(),
    and it seems reasonable to add a sysctl to do that.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index f12007b..d46338a 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -362,6 +362,13 @@ tcp_workaround_signed_windows - BOOLEAN
 	not receive a window scaling option from them.
 	Default: 0
 
+tcp_slow_start_after_idle - BOOLEAN
+	If set, provide RFC2861 behavior and time out the congestion
+	window after an idle period.  An idle period is defined at
+	the current RTO.  If unset, the congestion window will not
+	be timed out after an idle period.
+	Default: 1
+
 IP Variables:
 
 ip_local_port_range - 2 INTEGERS
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 98338ed..cee944d 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -405,6 +405,7 @@ enum
 	NET_TCP_BASE_MSS=114,
 	NET_IPV4_TCP_WORKAROUND_SIGNED_WINDOWS=115,
 	NET_TCP_DMA_COPYBREAK=116,
+	NET_TCP_SLOW_START_AFTER_IDLE=117,
 };
 
 enum {
diff --git a/include/net/tcp.h b/include/net/tcp.h
index de88c54..bfc71f9 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -227,6 +227,7 @@ extern int sysctl_tcp_abc;
 extern int sysctl_tcp_mtu_probing;
 extern int sysctl_tcp_base_mss;
 extern int sysctl_tcp_workaround_signed_windows;
+extern int sysctl_tcp_slow_start_after_idle;
 
 extern atomic_t tcp_memory_allocated;
 extern atomic_t tcp_sockets_allocated;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index e7fb665..ce4cd5f 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -690,6 +690,14 @@ ctl_table ipv4_table[] = {
 		.proc_handler	= &proc_dointvec
 	},
 #endif
+	{
+		.ctl_name	= NET_TCP_SLOW_START_AFTER_IDLE,
+		.procname	= "tcp_slow_start_after_idle",
+		.data		= &sysctl_tcp_slow_start_after_idle,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
+	},
 	{ .ctl_name = 0 }
 };
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 743016b..be6d929 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -59,6 +59,9 @@ int sysctl_tcp_tso_win_divisor = 3;
 int sysctl_tcp_mtu_probing = 0;
 int sysctl_tcp_base_mss = 512;
 
+/* By default, RFC2861 behavior.  */
+int sysctl_tcp_slow_start_after_idle = 1;
+
 static void update_send_head(struct sock *sk, struct tcp_sock *tp,
 			     struct sk_buff *skb)
 {
@@ -138,7 +141,8 @@ static void tcp_event_data_sent(struct t
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	const u32 now = tcp_time_stamp;
 
-	if (!tp->packets_out && (s32)(now - tp->lsndtime) > icsk->icsk_rto)
+	if (sysctl_tcp_slow_start_after_idle &&
+	    (!tp->packets_out && (s32)(now - tp->lsndtime) > icsk->icsk_rto))
 		tcp_cwnd_restart(sk, __sk_dst_get(sk));
 
 	tp->lsndtime = now;

