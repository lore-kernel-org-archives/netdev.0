From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [PATCH] pktgen unaligned access on IA-64
Date: Tue, 10 Feb 2004 19:02:57 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16425.7377.210243.50268@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello!
Grant Grundler spotted and cured this. 

Cheers.
					--ro



--- net/core/pktgen.c.040207	Sat Feb  7 12:54:40 2004
+++ net/core/pktgen.c	Mon Feb  9 00:03:52 2004
@@ -50,6 +50,8 @@
  * Fix refcount off by one if first packet fails, potential null deref, 
  * memleak 030710- KJP
  *
+ * Fixed unaligned access on IA-64 Grant Grundler <grundler@parisc-linux.org>
+ *
  * See Documentation/networking/pktgen.txt for how to use this.
  */
 
@@ -88,7 +90,7 @@
 #define cycles()	((u32)get_cycles())
 
 
-#define VERSION "pktgen version 1.31"
+#define VERSION "pktgen version 1.32"
 static char version[] __initdata = 
   "pktgen.c: v1.3: Packet Generator for packet performance testing.\n";
 
@@ -193,7 +195,8 @@
 struct pktgen_hdr {
 	__u32 pgh_magic;
 	__u32 seq_num;
-	struct timeval timestamp;
+	__u32 tv_sec;
+	__u32 tv_usec;
 };
 
 static int cpu_speed;
@@ -563,11 +566,14 @@
 
 	/* Stamp the time, and sequence number, convert them to network byte order */
 	if (pgh) {
+		struct timeval timestamp;
+
 		pgh->pgh_magic = htonl(PKTGEN_MAGIC);
-		do_gettimeofday(&(pgh->timestamp));
-		pgh->timestamp.tv_usec = htonl(pgh->timestamp.tv_usec);
-		pgh->timestamp.tv_sec = htonl(pgh->timestamp.tv_sec);
-		pgh->seq_num = htonl(info->seq_num);
+		pgh->seq_num   = htonl(info->seq_num);
+		
+		do_gettimeofday(&timestamp);
+		pgh->tv_sec    = htonl(timestamp.tv_sec);
+		pgh->tv_usec   = htonl(timestamp.tv_usec);
 	}
 	
 	return skb;
