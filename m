From: Nivedita Singhvi <niv@us.ibm.com>
Subject: [Patch 2.4.20+] missing SNMP stats
Date: Tue, 8 Apr 2003 19:29:07 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0304081649570.11172-100000@w-nivedita.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Randy Dunlap <rddunlap@osdl.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Miller <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is the 2.4 version of the patch to support those SNMP TCP
counters currently not supported:

RtoAlgorithm
RtoMin
RtoMax
MaxConn
EstabResets

thanks,
Nivedita



diff -urN linux-2.4.20/include/net/snmp.h linux-2.4.20mibp/include/net/snmp.h
--- linux-2.4.20/include/net/snmp.h	Thu Nov 22 11:47:11 2001
+++ linux-2.4.20mibp/include/net/snmp.h	Tue Apr  8 18:40:09 2003
@@ -268,5 +268,8 @@
 #define SNMP_INC_STATS(mib, field) ((mib)[2*smp_processor_id()+!in_softirq()].field++)
 #define SNMP_INC_STATS_BH(mib, field) ((mib)[2*smp_processor_id()].field++)
 #define SNMP_INC_STATS_USER(mib, field) ((mib)[2*smp_processor_id()+1].field++)
- 	
+#define SNMP_ADD_STATS_BH(mib, field, addend)	\
+	((mib)[2*smp_processor_id()].field += addend)
+#define SNMP_ADD_STATS_USER(mib, field, addend)	\
+	((mib)[2*smp_processor_id()+1].field += addend)
 #endif
diff -urN linux-2.4.20/include/net/tcp.h linux-2.4.20mibp/include/net/tcp.h
--- linux-2.4.20/include/net/tcp.h	Thu Nov 28 15:53:15 2002
+++ linux-2.4.20mibp/include/net/tcp.h	Tue Apr  8 18:40:20 2003
@@ -30,6 +30,7 @@
 #include <linux/cache.h>
 #include <net/checksum.h>
 #include <net/sock.h>
+#include <net/snmp.h>
 
 /* This is for all connections with a full identity, no wildcards.
  * New scheme, half the table is for TIME_WAIT, the other half is
@@ -621,6 +622,8 @@
 #define TCP_INC_STATS(field)		SNMP_INC_STATS(tcp_statistics, field)
 #define TCP_INC_STATS_BH(field)		SNMP_INC_STATS_BH(tcp_statistics, field)
 #define TCP_INC_STATS_USER(field) 	SNMP_INC_STATS_USER(tcp_statistics, field)
+#define TCP_ADD_STATS_BH(field, val)	SNMP_ADD_STATS_BH(tcp_statistics, field, val)
+#define TCP_ADD_STATS_USER(field, val)	SNMP_ADD_STATS_USER(tcp_statistics, field, val)
 
 extern void			tcp_put_port(struct sock *sk);
 extern void			__tcp_put_port(struct sock *sk);
@@ -1372,6 +1375,9 @@
 		break;
 
 	case TCP_CLOSE:
+		if (oldstate == TCP_CLOSE_WAIT || oldstate == TCP_ESTABLISHED)
+			TCP_INC_STATS(TcpEstabResets);
+
 		sk->prot->unhash(sk);
 		if (sk->prev && !(sk->userlocks&SOCK_BINDPORT_LOCK))
 			tcp_put_port(sk);
@@ -1830,4 +1836,13 @@
 
 #define TCP_CHECK_TIMER(sk) do { } while (0)
 
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
diff -urN linux-2.4.20/net/ipv4/proc.c linux-2.4.20mibp/net/ipv4/proc.c
--- linux-2.4.20/net/ipv4/proc.c	Thu Nov 28 15:53:15 2002
+++ linux-2.4.20mibp/net/ipv4/proc.c	Tue Apr  8 18:41:06 2003
@@ -134,9 +134,17 @@
 	len += sprintf (buffer + len,
 		"\nTcp: RtoAlgorithm RtoMin RtoMax MaxConn ActiveOpens PassiveOpens AttemptFails EstabResets CurrEstab InSegs OutSegs RetransSegs InErrs OutRsts\n"
 		  "Tcp:");
-	for (i=0; i<offsetof(struct tcp_mib, __pad)/sizeof(unsigned long); i++)
-		len += sprintf(buffer+len, " %lu", fold_field((unsigned long*)tcp_statistics, sizeof(struct tcp_mib), i));
-
+	for (i=0; i<offsetof(struct tcp_mib, __pad)/sizeof(unsigned long); i++) {
+		if (i == (offsetof(struct tcp_mib, TcpMaxConn) / sizeof(unsigned long)))
+			/* MaxConn field is negative, RFC 2012 */
+			len += sprintf(buffer+len, " %d", 
+				       fold_field((unsigned long*)tcp_statistics,
+					          sizeof(struct tcp_mib), i));
+		else
+			len += sprintf(buffer+len, " %lu",
+				       fold_field((unsigned long*)tcp_statistics,
+					          sizeof(struct tcp_mib), i));
+	}
 	len += sprintf (buffer + len,
 		"\nUdp: InDatagrams NoPorts InErrors OutDatagrams\n"
 		  "Udp:");
diff -urN linux-2.4.20/net/ipv4/tcp.c linux-2.4.20mibp/net/ipv4/tcp.c
--- linux-2.4.20/net/ipv4/tcp.c	Thu Nov 28 15:53:15 2002
+++ linux-2.4.20mibp/net/ipv4/tcp.c	Tue Apr  8 18:40:51 2003
@@ -2641,5 +2641,6 @@
 	printk(KERN_INFO "TCP: Hash tables configured (established %d bind %d)\n",
 	       tcp_ehash_size<<1, tcp_bhash_size);
 
+	(void) tcp_mib_init();
 	tcpdiag_init();
 }
