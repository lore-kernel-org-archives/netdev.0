From: Baruch Even <baruch@ev-en.org>
Subject: [RFC PATCH 2/5] Adjust alpha according to a function defined in HTCP
Date: Fri, 11 Mar 2005 18:09:38 +0200 (IST)
Message-ID: <20050311160938.30424.87084.26112@galon.ev-en.org>
References: <20050311160734.30424.67955.65942@galon.ev-en.org>
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com,
        Baruch Even <baruch@ev-en.org>, Douglas Leith <doug.leith@nuim.ie>,
        Stephen Hemminger <shemminger@osdl.org>
To: "David S.Miller" <davem@davemloft.net>
In-Reply-To: <20050311160734.30424.67955.65942@galon.ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Modify alpha as a function of the time since last backoff.

Signed-Off-By: Douglas Leith <doug.leith@nuim.ie>
Signed-Off-By: Baruch Even <baruch@ev-en.org>

Index: 2.6.12-rc/net/ipv4/tcp_input.c
===================================================================
--- 2.6.12-rc.orig/net/ipv4/tcp_input.c
+++ 2.6.12-rc/net/ipv4/tcp_input.c
@@ -105,6 +105,7 @@ int sysctl_tcp_bic_low_window = 14;
 int sysctl_tcp_bic_beta = 819;		/* = 819/1024 (BICTCP_BETA_SCALE) */
 int sysctl_tcp_htcp = 1;
 int sysctl_tcp_htcp_modeswitch = 1;
+int sysctl_tcp_htcp_alpha_func = 1;
 
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
 #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
@@ -2120,6 +2121,16 @@ static inline void reno_cong_avoid(struc
 			measure_minRTT(tp);
 
 			/* calculate increase rate - alpha is number of packets added to cwnd per RTT */
+			if (sysctl_tcp_htcp_alpha_func) {
+				/* time since last backoff */
+				__u32 diff = tp->htcp.snd_ccount * tp->htcp.snd_minRTT;
+
+				if (diff > HZ) {
+					diff -= HZ;
+					alpha += ( 10*diff+((diff>>1)*(diff>>1)/HZ) )/HZ;
+				}
+			}
+
 			tp->htcp.snd_alpha = alpha;
 
 			tp->snd_cwnd_cnt++;
Index: 2.6.12-rc/include/net/tcp.h
===================================================================
--- 2.6.12-rc.orig/include/net/tcp.h
+++ 2.6.12-rc/include/net/tcp.h
@@ -614,6 +614,7 @@ extern int sysctl_tcp_moderate_rcvbuf;
 extern int sysctl_tcp_tso_win_divisor;
 extern int sysctl_tcp_htcp;
 extern int sysctl_tcp_htcp_modeswitch;
+extern int sysctl_tcp_htcp_alpha_func;
 
 extern atomic_t tcp_memory_allocated;
 extern atomic_t tcp_sockets_allocated;
Index: 2.6.12-rc/net/ipv4/sysctl_net_ipv4.c
===================================================================
--- 2.6.12-rc.orig/net/ipv4/sysctl_net_ipv4.c
+++ 2.6.12-rc/net/ipv4/sysctl_net_ipv4.c
@@ -706,6 +706,14 @@ ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= NET_TCP_HTCP_ALPHA_FUNC,
+		.procname	= "tcp_htcp_alpha_func",
+		.data		= &sysctl_tcp_htcp_alpha_func,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 	{ .ctl_name = 0 }
 };
 
Index: 2.6.12-rc/include/linux/sysctl.h
===================================================================
--- 2.6.12-rc.orig/include/linux/sysctl.h
+++ 2.6.12-rc/include/linux/sysctl.h
@@ -348,6 +348,7 @@ enum
 	NET_TCP_BIC_BETA=108,
 	NET_TCP_HTCP=109,
 	NET_TCP_HTCP_MODESWITCH=110,
+	NET_TCP_HTCP_ALPHA_FUNC=111,
 };
 
 enum {
