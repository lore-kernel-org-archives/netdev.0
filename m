From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] Report vegas connection info
Date: Fri, 23 Apr 2004 15:20:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040423152017.556fbbb3@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Simple extension of tcp_diag to send out vegas information.
Have simple addition to 'ss' command to print:

$ ss -i
State      Recv-Q Send-Q      Local Address:Port          Peer Address:Port
ESTAB      0      0             172.20.1.73:32775          172.20.1.60:iperf  
	rto:201 rtt:1.875/0.75 cwnd:8 ssthresh:3 vegas bw:9.2672e+10

diff -Nru a/include/linux/tcp_diag.h b/include/linux/tcp_diag.h
--- a/include/linux/tcp_diag.h	Fri Apr 23 14:56:53 2004
+++ b/include/linux/tcp_diag.h	Fri Apr 23 14:56:53 2004
@@ -98,9 +98,10 @@
 	TCPDIAG_NONE,
 	TCPDIAG_MEMINFO,
 	TCPDIAG_INFO,
+	TCPDIAG_VEGASINFO,
 };
 
-#define TCPDIAG_MAX TCPDIAG_INFO
+#define TCPDIAG_MAX TCPDIAG_VEGASINFO
 
 
 /* TCPDIAG_MEM */
@@ -112,5 +113,15 @@
 	__u32	tcpdiag_fmem;
 	__u32	tcpdiag_tmem;
 };
+
+/* TCPDIAG_VEGASINFO */
+
+struct tcpvegas_info {
+	__u32	tcpv_enabled;
+	__u32	tcpv_rttcnt;
+	__u32	tcpv_rtt;
+	__u32	tcpv_minrtt;
+};
+
 
 #endif /* _TCP_DIAG_H_ */
diff -Nru a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
--- a/net/ipv4/tcp_diag.c	Fri Apr 23 14:56:53 2004
+++ b/net/ipv4/tcp_diag.c	Fri Apr 23 14:56:53 2004
@@ -50,6 +50,7 @@
 	struct nlmsghdr  *nlh;
 	struct tcp_info  *info = NULL;
 	struct tcpdiag_meminfo  *minfo = NULL;
+	struct tcpvegas_info *vinfo = NULL;
 	unsigned char	 *b = skb->tail;
 
 	nlh = NLMSG_PUT(skb, pid, seq, TCPDIAG_GETSOCK, sizeof(*r));
@@ -59,6 +60,9 @@
 			minfo = TCPDIAG_PUT(skb, TCPDIAG_MEMINFO, sizeof(*minfo));
 		if (ext & (1<<(TCPDIAG_INFO-1)))
 			info = TCPDIAG_PUT(skb, TCPDIAG_INFO, sizeof(*info));
+		
+		if (tcp_is_vegas(tp) && (ext & (1<<(TCPDIAG_VEGASINFO-1))))
+			vinfo = TCPDIAG_PUT(skb, TCPDIAG_VEGASINFO, sizeof(*vinfo));
 	}
 	r->tcpdiag_family = sk->sk_family;
 	r->tcpdiag_state = sk->sk_state;
@@ -194,6 +198,13 @@
 		info->tcpi_snd_cwnd = tp->snd_cwnd;
 		info->tcpi_advmss = tp->advmss;
 		info->tcpi_reordering = tp->reordering;
+	}
+
+	if (vinfo) {
+		vinfo->tcpv_enabled = tp->vegas.doing_vegas_now;
+		vinfo->tcpv_rttcnt = tp->vegas.cntRTT;
+		vinfo->tcpv_rtt = tp->vegas.baseRTT;
+		vinfo->tcpv_minrtt = tp->vegas.minRTT;
 	}
 
 	nlh->nlmsg_len = skb->tail - b;
