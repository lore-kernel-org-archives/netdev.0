From: Nivedita Singhvi <niv@us.ibm.com>
Subject: [Patch 2.5.65+] missing SNMP stats
Date: Mon, 7 Apr 2003 13:53:16 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0304071159060.14335-100000@w-nivedita.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Randy Dunlap <rddunlap@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Miller <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch provides support for those SNMP TCP 
counters currently not supported:
 
RtoAlgorithm 
RtoMin 
RtoMax 
MaxConn
EstabResets 

Randy (Dunlap) worked up his own patch and this is
a merge of his and mine which I had done a while
back with Mark Price which I had cleaned up but
not resubmitted yet. (Thanks, Randy)

thanks,
Nivedita 

diff -urN linux-2.5.65/include/net/tcp.h linux-2.5.65mibp/include/net/tcp.h
--- linux-2.5.65/include/net/tcp.h	Mon Mar 17 13:43:41 2003
+++ linux-2.5.65mibp/include/net/tcp.h	Fri Apr  4 12:04:59 2003
@@ -31,6 +31,7 @@
 #include <linux/percpu.h>
 #include <net/checksum.h>
 #include <net/sock.h>
+#include <net/snmp.h>
 #if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
 #include <linux/ipv6.h>
 #endif
@@ -639,6 +640,8 @@
 #define TCP_INC_STATS_BH(field)		SNMP_INC_STATS_BH(tcp_statistics, field)
 #define TCP_INC_STATS_USER(field) 	SNMP_INC_STATS_USER(tcp_statistics, field)
 #define TCP_DEC_STATS(field)		SNMP_DEC_STATS(tcp_statistics, field)
+#define TCP_ADD_STATS_BH(field, val)	SNMP_ADD_STATS_BH(tcp_statistics, field, val)
+#define TCP_ADD_STATS_USER(field, val)	SNMP_ADD_STATS_USER(tcp_statistics, field, val)
 
 extern __inline__ void		tcp_put_port(struct sock *sk);
 extern void			tcp_inherit_port(struct sock *sk, struct sock *child);
@@ -1397,6 +1400,9 @@
 		break;
 
 	case TCP_CLOSE:
+		if (oldstate == TCP_CLOSE_WAIT || oldstate == TCP_ESTABLISHED)
+			TCP_INC_STATS(TcpEstabResets);
+
 		sk->prot->unhash(sk);
 		if (sk->prev && !(sk->userlocks&SOCK_BINDPORT_LOCK))
 			tcp_put_port(sk);
@@ -1877,4 +1883,13 @@
 		       tp->snd_una + tp->snd_wnd));
 }
 
+static inline void tcp_mib_init(void)
+{
+	/* See RFC 2012 */
+	TCP_ADD_STATS_USER(TcpRtoAlgorithm, 1);
+	TCP_ADD_STATS_USER(TcpRtoMin, TCP_RTO_MIN*1000/HZ);
+	TCP_ADD_STATS_USER(TcpRtoMax, TCP_RTO_MAX*1000/HZ);
+	TCP_ADD_STATS_USER(TcpMaxConn, -1);
+}
+
 #endif	/* _TCP_H */
diff -urN linux-2.5.65/net/ipv4/af_inet.c linux-2.5.65mibp/net/ipv4/af_inet.c
--- linux-2.5.65/net/ipv4/af_inet.c	Mon Mar 17 13:43:42 2003
+++ linux-2.5.65mibp/net/ipv4/af_inet.c	Fri Apr  4 11:34:38 2003
@@ -1110,6 +1110,8 @@
 		}
 	}
 
+	(void) tcp_mib_init();
+
 	return 0;
 }
 
diff -urN linux-2.5.65/net/ipv4/proc.c linux-2.5.65mibp/net/ipv4/proc.c
--- linux-2.5.65/net/ipv4/proc.c	Fri Apr  4 12:27:06 2003
+++ linux-2.5.65mibp/net/ipv4/proc.c	Mon Apr  7 10:26:34 2003
@@ -143,9 +143,15 @@
 			"InSegs OutSegs RetransSegs InErrs OutRsts\nTcp:");
 
 	for (i = 0;
-	     i < offsetof(struct tcp_mib, __pad) / sizeof(unsigned long); i++)
-		seq_printf(seq, " %lu",
-			   fold_field((void **) tcp_statistics, i));
+	     i < offsetof(struct tcp_mib, __pad) / sizeof(unsigned long); i++) {
+		if (i == (offsetof(struct tcp_mib, TcpMaxConn) / sizeof(unsigned long)))
+			/* MaxConn field is negative, RFC 2012 */
+			seq_printf(seq, " %ld", 
+				   fold_field((void **) tcp_statistics, i));
+		else
+			seq_printf(seq, " %lu", 
+				   fold_field((void **) tcp_statistics, i));
+	}
 
 	seq_printf(seq, "\nUdp: InDatagrams NoPorts InErrors OutDatagrams\n"
 			"Udp:");
