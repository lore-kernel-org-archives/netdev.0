From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] add sysctl to turn off caching metrics
Date: Wed, 21 Apr 2004 11:10:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040421111046.34bf3e73@dell_ss3.pdx.osdl.net>
References: <20040420155738.4146b5bb.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040420155738.4146b5bb.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When running benchmarks and other experiments, it is often useful
not to save the route metrics (cwnd, rtt) from each connection.
Here is a simple way to do it with sysctl.  Not a new idea, it is part
of the web100 stuff as well.

Patch against 2.6.6-rc2

diff -Nru a/include/linux/sysctl.h b/include/linux/sysctl.h
--- a/include/linux/sysctl.h	Wed Apr 21 10:39:28 2004
+++ b/include/linux/sysctl.h	Wed Apr 21 10:39:28 2004
@@ -326,6 +326,7 @@
 	NET_IPV4_IPFRAG_SECRET_INTERVAL=94,
 	NET_TCP_WESTWOOD=95,
 	NET_IPV4_IGMP_MAX_MSF=96,
+	NET_TCP_NO_METRICS_SAVE=97,
 };
 
 enum {
diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	Wed Apr 21 10:39:28 2004
+++ b/include/net/tcp.h	Wed Apr 21 10:39:28 2004
@@ -583,6 +583,7 @@
 extern int sysctl_tcp_frto;
 extern int sysctl_tcp_low_latency;
 extern int sysctl_tcp_westwood;
+extern int sysctl_tcp_nometrics_save;
 
 extern atomic_t tcp_memory_allocated;
 extern atomic_t tcp_sockets_allocated;
diff -Nru a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
--- a/net/ipv4/sysctl_net_ipv4.c	Wed Apr 21 10:39:28 2004
+++ b/net/ipv4/sysctl_net_ipv4.c	Wed Apr 21 10:39:28 2004
@@ -594,6 +594,14 @@
 		.strategy	= &sysctl_jiffies
 	},
 	{
+		.ctl_name	= NET_TCP_NO_METRICS_SAVE,
+		.procname	= "tcp_no_metrics_save",
+		.data		= &sysctl_tcp_nometrics_save,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
 		.ctl_name	= NET_TCP_WESTWOOD, 
 		.procname	= "tcp_westwood",
 		.data		= &sysctl_tcp_westwood,
@@ -601,6 +609,7 @@
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+
 	{ .ctl_name = 0 }
 };
 
diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	Wed Apr 21 10:39:28 2004
+++ b/net/ipv4/tcp_input.c	Wed Apr 21 10:39:28 2004
@@ -87,6 +87,7 @@
 int sysctl_tcp_max_orphans = NR_FILE;
 int sysctl_tcp_frto;
 int sysctl_tcp_westwood;
+int sysctl_tcp_nometrics_save;
 
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
 #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
@@ -517,6 +518,9 @@
 {
 	struct tcp_opt *tp = tcp_sk(sk);
 	struct dst_entry *dst = __sk_dst_get(sk);
+
+	if (sysctl_tcp_nometrics_save)
+		return;
 
 	dst_confirm(dst);
 
