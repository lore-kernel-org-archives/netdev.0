From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/3) tcp diag info for 2.4
Date: Fri, 1 Oct 2004 15:56:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041001155620.2f11f9f0@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This adds vegas style bandwidth info to 2.4.
Also: makes 2.6 and 2.4 version of tcp_diag.h identical.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/include/linux/tcp_diag.h b/include/linux/tcp_diag.h
--- a/include/linux/tcp_diag.h	2004-10-01 15:52:21 -07:00
+++ b/include/linux/tcp_diag.h	2004-10-01 15:52:21 -07:00
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
--- a/net/ipv4/tcp_diag.c	2004-10-01 15:52:21 -07:00
+++ b/net/ipv4/tcp_diag.c	2004-10-01 15:52:21 -07:00
@@ -49,6 +49,7 @@
 	struct nlmsghdr  *nlh;
 	struct tcp_info  *info = NULL;
 	struct tcpdiag_meminfo  *minfo = NULL;
+	struct tcpvegas_info *vinfo = NULL;
 	unsigned char	 *b = skb->tail;
 
 	nlh = NLMSG_PUT(skb, pid, seq, TCPDIAG_GETSOCK, sizeof(*r));
@@ -58,6 +59,10 @@
 			minfo = TCPDIAG_PUT(skb, TCPDIAG_MEMINFO, sizeof(*minfo));
 		if (ext & (1<<(TCPDIAG_INFO-1)))
 			info = TCPDIAG_PUT(skb, TCPDIAG_INFO, sizeof(*info));
+
+		if ((tcp_is_westwood(tp) || tcp_is_vegas(tp))
+		    && (ext & (1<<(TCPDIAG_VEGASINFO-1))))
+			vinfo = TCPDIAG_PUT(skb, TCPDIAG_VEGASINFO, sizeof(*vinfo));
 	}
 	r->tcpdiag_family = sk->family;
 	r->tcpdiag_state = sk->state;
@@ -184,6 +189,20 @@
 		info->tcpi_snd_cwnd = tp->snd_cwnd;
 		info->tcpi_advmss = tp->advmss;
 		info->tcpi_reordering = tp->reordering;
+	}
+
+	if (vinfo) {
+		if (tcp_is_vegas(tp)) {
+			vinfo->tcpv_enabled = tp->vegas.doing_vegas_now;
+			vinfo->tcpv_rttcnt = tp->vegas.cntRTT;
+			vinfo->tcpv_rtt = (1000000*tp->vegas.baseRTT)/HZ;
+			vinfo->tcpv_minrtt = (1000000*tp->vegas.minRTT)/HZ;
+		} else {
+			vinfo->tcpv_enabled = 0;
+			vinfo->tcpv_rttcnt = 0;
+			vinfo->tcpv_rtt = (1000000*tp->westwood.rtt)/HZ;
+			vinfo->tcpv_minrtt = (1000000*tp->westwood.rtt_min)/HZ;
+		}
 	}
 
 	nlh->nlmsg_len = skb->tail - b;
