From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] BIC TCP beta calculation error
Date: Mon, 21 Feb 2005 14:56:07 -0800
Message-ID: <20050221145607.67f05ced@dxpl.pdx.osdl.net>
References: <200502211535.j1LFZwun012564@uni02mr.unity.ncsu.edu>
	<20050221095559.18128947.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20050221095559.18128947.davem@redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave, did you get this already?
------------
Yee-Ting Li and David Keith identified (in great detail) a problem
with the BIC TCP in 2.6. The issue was a BETA/2 when BETA*2 was expected.
Here is a better fix based on BIC TCP 1.1 code.

Test description and results
	http://developer.osdl.org/shemminger/bic-beta-patch.pdf

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


diff -Nru a/include/linux/sysctl.h b/include/linux/sysctl.h
--- a/include/linux/sysctl.h	2005-02-21 12:55:57 -08:00
+++ b/include/linux/sysctl.h	2005-02-21 12:55:57 -08:00
@@ -344,6 +344,7 @@
 	NET_TCP_DEFAULT_WIN_SCALE=105,
 	NET_TCP_MODERATE_RCVBUF=106,
 	NET_TCP_TSO_WIN_DIVISOR=107,
+	NET_TCP_BIC_BETA=108,
 };
 
 enum {
diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	2005-02-21 12:55:57 -08:00
+++ b/include/net/tcp.h	2005-02-21 12:55:57 -08:00
@@ -505,9 +505,8 @@
 # define TCP_TW_RECYCLE_TICK (12+2-TCP_TW_RECYCLE_SLOTS_LOG)
 #endif
 
-#define BICTCP_1_OVER_BETA	8	/*
-					 * Fast recovery
-					 * multiplicative decrease factor
+#define BICTCP_BETA_SCALE    1024	/* Scale factor beta calculation
+					 * max_cwnd = snd_cwnd * beta
 					 */
 #define BICTCP_MAX_INCREMENT 32		/*
 					 * Limit on the amount of
@@ -606,6 +605,7 @@
 extern int sysctl_tcp_bic;
 extern int sysctl_tcp_bic_fast_convergence;
 extern int sysctl_tcp_bic_low_window;
+extern int sysctl_tcp_bic_beta;
 extern int sysctl_tcp_moderate_rcvbuf;
 extern int sysctl_tcp_tso_win_divisor;
 
@@ -1244,15 +1244,16 @@
 	if (tcp_is_bic(tp)) {
 		if (sysctl_tcp_bic_fast_convergence &&
 		    tp->snd_cwnd < tp->bictcp.last_max_cwnd)
-			tp->bictcp.last_max_cwnd
-				= (tp->snd_cwnd * (2*BICTCP_1_OVER_BETA-1))
-				/ (BICTCP_1_OVER_BETA/2);
+			tp->bictcp.last_max_cwnd = (tp->snd_cwnd * 
+						    (BICTCP_BETA_SCALE
+						     + sysctl_tcp_bic_beta))
+				/ (2 * BICTCP_BETA_SCALE);
 		else
 			tp->bictcp.last_max_cwnd = tp->snd_cwnd;
 
 		if (tp->snd_cwnd > sysctl_tcp_bic_low_window)
-			return max(tp->snd_cwnd - (tp->snd_cwnd/BICTCP_1_OVER_BETA),
-				   2U);
+			return max((tp->snd_cwnd * sysctl_tcp_bic_beta)
+				   / BICTCP_BETA_SCALE, 2U);
 	}
 
 	return max(tp->snd_cwnd >> 1U, 2U);
diff -Nru a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
--- a/net/ipv4/sysctl_net_ipv4.c	2005-02-21 12:55:57 -08:00
+++ b/net/ipv4/sysctl_net_ipv4.c	2005-02-21 12:55:57 -08:00
@@ -682,6 +682,14 @@
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= NET_TCP_BIC_BETA,
+		.procname	= "tcp_bic_beta",
+		.data		= &sysctl_tcp_bic_beta,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 	{ .ctl_name = 0 }
 };
 
diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	2005-02-21 12:55:57 -08:00
+++ b/net/ipv4/tcp_input.c	2005-02-21 12:55:57 -08:00
@@ -102,6 +102,7 @@
 int sysctl_tcp_bic = 1;
 int sysctl_tcp_bic_fast_convergence = 1;
 int sysctl_tcp_bic_low_window = 14;
+int sysctl_tcp_bic_beta = 819;		/* = 819/1024 (BICTCP_BETA_SCALE) */
 
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
 #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
