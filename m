From: Nivedita Singhvi <niv@us.ibm.com>
Subject: [PATCH] SNMP MIB for TCP variables 2.4.18+
Date: Wed, 15 May 2002 09:55:01 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0205150952040.1146-100000@w-nivedita2.des.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <owner-netdev@oss.sgi.com>
To: <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

This is a patch to support some SNMP TCP MIB variables currently
not provided by Linux (reqd by RFC 2012).

Patch applies to 2.4.18+ cleanly.
Can provide diffs against 2.5+ separately as well if needed.

I'm following up on work done by Mark Price a while ago
which included some larger changes. Will be working those 
separately.


thanks,
Nivedita


diff -urN linux-2.4.18/include/net/tcp.h linux-2.4.18statp/include/net/tcp.h
--- linux-2.4.18/include/net/tcp.h	Thu Nov 22 11:47:22 2001
+++ linux-2.4.18statp/include/net/tcp.h	Mon Apr 22 20:21:02 2002
@@ -331,6 +331,7 @@
 #define TCP_DELACK_MIN	4U
 #define TCP_ATO_MIN	4U
 #endif
+#define TCP_RTO_OTHER	1
 #define TCP_RTO_MAX	((unsigned)(120*HZ))
 #define TCP_RTO_MIN	((unsigned)(HZ/5))
 #define TCP_TIMEOUT_INIT ((unsigned)(3*HZ))	/* RFC 1122 initial RTO value	*/
diff -urN linux-2.4.18/net/ipv4/proc.c linux-2.4.18statp/net/ipv4/proc.c
--- linux-2.4.18/net/ipv4/proc.c	Wed May 16 10:21:45 2001
+++ linux-2.4.18statp/net/ipv4/proc.c	Mon Apr 22 22:45:52 2002
@@ -134,9 +134,17 @@
 	len += sprintf (buffer + len,
 		"\nTcp: RtoAlgorithm RtoMin RtoMax MaxConn ActiveOpens PassiveOpens AttemptFails EstabResets CurrEstab InSegs OutSegs RetransSegs InErrs OutRsts\n"
 		  "Tcp:");
-	for (i=0; i<offsetof(struct tcp_mib, __pad)/sizeof(unsigned long); i++)
-		len += sprintf(buffer+len, " %lu", fold_field((unsigned long*)tcp_statistics, sizeof(struct tcp_mib), i));
-
+	for (i=0; i<offsetof(struct tcp_mib, __pad)/sizeof(unsigned long); i++) { 
+		/* MaxConn field is negative, RFC 2012 */
+		if (i == 3) 
+			len += sprintf(buffer+len, " %ld", 
+		 	   (long) fold_field((unsigned long*)tcp_statistics, 
+			   sizeof(struct tcp_mib), i));
+		else 
+			len += sprintf(buffer+len, " %lu", 
+			   fold_field((unsigned long*)tcp_statistics, 
+			   sizeof(struct tcp_mib), i));
+	}
 	len += sprintf (buffer + len,
 		"\nUdp: InDatagrams NoPorts InErrors OutDatagrams\n"
 		  "Udp:");
diff -urN linux-2.4.18/net/ipv4/tcp.c linux-2.4.18statp/net/ipv4/tcp.c
--- linux-2.4.18/net/ipv4/tcp.c	Fri Dec 21 09:42:05 2001
+++ linux-2.4.18statp/net/ipv4/tcp.c	Mon Apr 22 20:20:22 2002
@@ -2555,5 +2555,11 @@
 	printk("TCP: Hash tables configured (established %d bind %d)\n",
 	       tcp_ehash_size<<1, tcp_bhash_size);
 
+	/* RFC2012 */
+	tcp_statistics[0].TcpRtoAlgorithm = TCP_RTO_OTHER;
+	tcp_statistics[0].TcpRtoMin = TCP_RTO_MIN*1000/HZ;
+	tcp_statistics[0].TcpRtoMax = TCP_RTO_MAX*1000/HZ;
+	tcp_statistics[0].TcpMaxConn = -1; 
+
 	tcpdiag_init();
 }
