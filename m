From: Baruch Even <baruch@ev-en.org>
Subject: [RFC PATCH 5/5] Switch in/out of beta=minrtt/maxrtt by bandwidth
Date: Fri, 11 Mar 2005 18:12:47 +0200 (IST)
Message-ID: <20050311161242.30424.92575.64606@galon.ev-en.org>
References: <20050311160734.30424.67955.65942@galon.ev-en.org>
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com,
        Baruch Even <baruch@ev-en.org>, Douglas Leith <doug.leith@nuim.ie>,
        Stephen Hemminger <shemminger@osdl.org>
To: "David S.Miller" <davem@davemloft.net>
In-Reply-To: <20050311160734.30424.67955.65942@galon.ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Reset beta when bandwidth usage changes drastically, we have completely new
network conditions.

Signed-Off-By: Douglas Leith <doug.leith@nuim.ie>
Signed-Off-By: Baruch Even <baruch@ev-en.org>

Index: 2.6.12-rc/include/net/tcp.h
===================================================================
--- 2.6.12-rc.orig/include/net/tcp.h
+++ 2.6.12-rc/include/net/tcp.h
@@ -613,6 +613,7 @@ extern int sysctl_tcp_bic_beta;
 extern int sysctl_tcp_moderate_rcvbuf;
 extern int sysctl_tcp_tso_win_divisor;
 extern int sysctl_tcp_htcp;
+extern int sysctl_tcp_htcp_bandwidth_switch;
 extern int sysctl_tcp_htcp_modeswitch;
 extern int sysctl_tcp_htcp_alpha_func;
 extern int sysctl_tcp_htcp_alpha_adjust;
@@ -978,12 +979,17 @@ static inline void htcp_beta_check(struc
 
 static inline void htcp_beta_update(struct tcp_sock *tp)
 {
+	__u32 snd_maxB;
+	__u32 snd_oldmaxB;
+
 	if (!tcp_is_htcp(tp))
 		return;
 	
+	snd_maxB = tp->htcp.snd_maxB;
+	snd_oldmaxB = tp->htcp.snd_oldmaxB;
 	tp->htcp.snd_oldmaxB = tp->htcp.snd_maxB;
 
-	if (sysctl_tcp_htcp_modeswitch) {
+	if ((!sysctl_tcp_htcp_bandwidth_switch || between(5*snd_maxB, 4*snd_oldmaxB, 6*snd_oldmaxB)) && sysctl_tcp_htcp_modeswitch) {
 		if (tp->htcp.snd_modecount && tp->htcp.snd_minRTT>HZ/100 && tp->htcp.snd_maxRTT>0)
 			tp->htcp.snd_beta = (tp->htcp.snd_minRTT<<7)/tp->htcp.snd_maxRTT;
 		else
Index: 2.6.12-rc/net/ipv4/tcp_input.c
===================================================================
--- 2.6.12-rc.orig/net/ipv4/tcp_input.c
+++ 2.6.12-rc/net/ipv4/tcp_input.c
@@ -104,6 +104,7 @@ int sysctl_tcp_bic_fast_convergence = 1;
 int sysctl_tcp_bic_low_window = 14;
 int sysctl_tcp_bic_beta = 819;		/* = 819/1024 (BICTCP_BETA_SCALE) */
 int sysctl_tcp_htcp = 1;
+int sysctl_tcp_htcp_bandwidth_switch = 1;
 int sysctl_tcp_htcp_modeswitch = 1;
 int sysctl_tcp_htcp_alpha_func = 1;
 int sysctl_tcp_htcp_alpha_adjust = 1;
Index: 2.6.12-rc/net/ipv4/sysctl_net_ipv4.c
===================================================================
--- 2.6.12-rc.orig/net/ipv4/sysctl_net_ipv4.c
+++ 2.6.12-rc/net/ipv4/sysctl_net_ipv4.c
@@ -699,6 +699,14 @@ ctl_table ipv4_table[] = {
 		.proc_handler	= &proc_dointvec,
 	},
 	{
+		.ctl_name	= NET_TCP_HTCP_BANDWIDTH_SWITCH,
+		.procname	= "tcp_htcp_bandwidth_switch",
+		.data		= &sysctl_tcp_htcp_bandwidth_switch,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
 		.ctl_name	= NET_TCP_HTCP_MODESWITCH,
 		.procname	= "tcp_htcp_modeswitch",
 		.data		= &sysctl_tcp_htcp_modeswitch,
Index: 2.6.12-rc/include/linux/sysctl.h
===================================================================
--- 2.6.12-rc.orig/include/linux/sysctl.h
+++ 2.6.12-rc/include/linux/sysctl.h
@@ -351,6 +351,7 @@ enum
 	NET_TCP_HTCP_ALPHA_FUNC=111,
 	NET_TCP_HTCP_ALPHA_ADJUST=112,
 	NET_TCP_HTCP_RTT_SCALING=113,
+	NET_TCP_HTCP_BANDWIDTH_SWITCH=114,
 };
 
 enum {
