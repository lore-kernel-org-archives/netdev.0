From: Baruch Even <baruch@ev-en.org>
Subject: [RFC PATCH 4/5] Adjust alpha according to RTT timing
Date: Fri, 11 Mar 2005 18:11:41 +0200 (IST)
Message-ID: <20050311161141.30424.47574.20943@galon.ev-en.org>
References: <20050311160734.30424.67955.65942@galon.ev-en.org>
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com,
        Baruch Even <baruch@ev-en.org>, Douglas Leith <doug.leith@nuim.ie>,
        Stephen Hemminger <shemminger@osdl.org>
To: "David S.Miller" <davem@davemloft.net>
In-Reply-To: <20050311160734.30424.67955.65942@galon.ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Do RTT scaling on alpha.

Signed-Off-By: Douglas Leith <doug.leith@nuim.ie>
Signed-Off-By: Baruch Even <baruch@ev-en.org>

Index: 2.6.12-rc/net/ipv4/tcp_input.c
===================================================================
--- 2.6.12-rc.orig/net/ipv4/tcp_input.c
+++ 2.6.12-rc/net/ipv4/tcp_input.c
@@ -107,6 +107,7 @@ int sysctl_tcp_htcp = 1;
 int sysctl_tcp_htcp_modeswitch = 1;
 int sysctl_tcp_htcp_alpha_func = 1;
 int sysctl_tcp_htcp_alpha_adjust = 1;
+int sysctl_tcp_htcp_rtt_scaling = 1;
 
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
 #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
@@ -2132,6 +2133,16 @@ static inline void reno_cong_avoid(struc
 				}
 			}
 
+			if (sysctl_tcp_htcp_rtt_scaling) {
+				__u32 RTT_Scaling;
+				/* refer current RTT to design point, clamping ratio to interval [0.5,10] */
+				RTT_Scaling = max((HZ<<3)/(10*tp->htcp.snd_minRTT), (__u32)1<<2);
+				RTT_Scaling = min(RTT_Scaling,(__u32)10<<3);
+				alpha = (alpha<<3)/RTT_Scaling;
+				if (!alpha)
+					alpha = 1;
+			}
+
 			if (sysctl_tcp_htcp_alpha_adjust) {
 				alpha = alpha*2*((1<<7)-tp->htcp.snd_beta);
 				if (!alpha)
Index: 2.6.12-rc/net/ipv4/sysctl_net_ipv4.c
===================================================================
--- 2.6.12-rc.orig/net/ipv4/sysctl_net_ipv4.c
+++ 2.6.12-rc/net/ipv4/sysctl_net_ipv4.c
@@ -722,6 +722,14 @@ ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= NET_TCP_HTCP_RTT_SCALING,
+		.procname	= "tcp_htcp_rtt_scaling",
+		.data		= &sysctl_tcp_htcp_rtt_scaling,
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
@@ -350,6 +350,7 @@ enum
 	NET_TCP_HTCP_MODESWITCH=110,
 	NET_TCP_HTCP_ALPHA_FUNC=111,
 	NET_TCP_HTCP_ALPHA_ADJUST=112,
+	NET_TCP_HTCP_RTT_SCALING=113,
 };
 
 enum {
Index: 2.6.12-rc/include/net/tcp.h
===================================================================
--- 2.6.12-rc.orig/include/net/tcp.h
+++ 2.6.12-rc/include/net/tcp.h
@@ -616,6 +616,7 @@ extern int sysctl_tcp_htcp;
 extern int sysctl_tcp_htcp_modeswitch;
 extern int sysctl_tcp_htcp_alpha_func;
 extern int sysctl_tcp_htcp_alpha_adjust;
+extern int sysctl_tcp_htcp_rtt_scaling;
 
 extern atomic_t tcp_memory_allocated;
 extern atomic_t tcp_sockets_allocated;
