From: Baruch Even <baruch@ev-en.org>
Subject: [RFC PATCH 3/5] Adjust alpha to 2*(1-beta)
Date: Fri, 11 Mar 2005 18:10:39 +0200 (IST)
Message-ID: <20050311161039.30424.15240.63353@galon.ev-en.org>
References: <20050311160734.30424.67955.65942@galon.ev-en.org>
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com,
        Baruch Even <baruch@ev-en.org>, Douglas Leith <doug.leith@nuim.ie>,
        Stephen Hemminger <shemminger@osdl.org>
To: "David S.Miller" <davem@davemloft.net>
In-Reply-To: <20050311160734.30424.67955.65942@galon.ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Update alpha to be related to beta so that fairness between flows will
be preserved. See article for details.

Signed-Off-By: Douglas Leith <doug.leith@nuim.ie>
Signed-Off-By: Baruch Even <baruch@ev-en.org>

Index: 2.6.12-rc/net/ipv4/tcp_input.c
===================================================================
--- 2.6.12-rc.orig/net/ipv4/tcp_input.c
+++ 2.6.12-rc/net/ipv4/tcp_input.c
@@ -106,6 +106,7 @@ int sysctl_tcp_bic_beta = 819;		/* = 819
 int sysctl_tcp_htcp = 1;
 int sysctl_tcp_htcp_modeswitch = 1;
 int sysctl_tcp_htcp_alpha_func = 1;
+int sysctl_tcp_htcp_alpha_adjust = 1;
 
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
 #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
@@ -2131,7 +2132,15 @@ static inline void reno_cong_avoid(struc
 				}
 			}
 
-			tp->htcp.snd_alpha = alpha;
+			if (sysctl_tcp_htcp_alpha_adjust) {
+				alpha = alpha*2*((1<<7)-tp->htcp.snd_beta);
+				if (!alpha)
+					alpha = 1<<7;
+			}
+			else
+				alpha <<= 7;
+
+			tp->htcp.snd_alpha = alpha>>7;
 
 			tp->snd_cwnd_cnt++;
 			if ((tp->snd_cwnd_cnt*alpha)>>7 > tp->snd_cwnd) {
Index: 2.6.12-rc/include/net/tcp.h
===================================================================
--- 2.6.12-rc.orig/include/net/tcp.h
+++ 2.6.12-rc/include/net/tcp.h
@@ -615,6 +615,7 @@ extern int sysctl_tcp_tso_win_divisor;
 extern int sysctl_tcp_htcp;
 extern int sysctl_tcp_htcp_modeswitch;
 extern int sysctl_tcp_htcp_alpha_func;
+extern int sysctl_tcp_htcp_alpha_adjust;
 
 extern atomic_t tcp_memory_allocated;
 extern atomic_t tcp_sockets_allocated;
Index: 2.6.12-rc/net/ipv4/sysctl_net_ipv4.c
===================================================================
--- 2.6.12-rc.orig/net/ipv4/sysctl_net_ipv4.c
+++ 2.6.12-rc/net/ipv4/sysctl_net_ipv4.c
@@ -714,6 +714,14 @@ ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= NET_TCP_HTCP_ALPHA_ADJUST,
+		.procname	= "tcp_htcp_alpha_adjust",
+		.data		= &sysctl_tcp_htcp_alpha_adjust,
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
@@ -349,6 +349,7 @@ enum
 	NET_TCP_HTCP=109,
 	NET_TCP_HTCP_MODESWITCH=110,
 	NET_TCP_HTCP_ALPHA_FUNC=111,
+	NET_TCP_HTCP_ALPHA_ADJUST=112,
 };
 
 enum {
