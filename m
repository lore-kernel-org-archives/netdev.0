From: Alexander Kolesnik <Alexander.Kolesnik@awanti.com>
Subject: [PATCH] iputils: ping
Date: Thu, 29 Jan 2009 20:41:02 +0300
Message-ID: <389891790.20090129204102@awanti.com>
Reply-To: Alexander Kolesnik <Alexander.Kolesnik@awanti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.awanti.com ([91.190.112.18]:57176 "EHLO mx0.awanti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752653AbZA2SFV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2009 13:05:21 -0500
Received: from alexkol.abisoft.spb.ru (abi165.abisoft.spb.ru [91.190.120.165])
	by mx0.awanti.com (Postfix) with ESMTP id C38E84C07D
	for <netdev@vger.kernel.org>; Thu, 29 Jan 2009 20:41:02 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

We used to use mrtg-ping-probe perl script (http://pwo.de/projects/mrtg/)
for  packetloss statistics generation in MRTG. Last time the number of
monitoring  hosts  became  high,  so  mrtg-ping-probe  overhead became
inadmissible.

Here  is  a  patch  to  iputils-ss020927  that  adds -m option to ping
utility, which allows ping to behave like mrtg-ping-probe: print average
RTT and packet loss only.

Hope, this will be useful for someone.

PS Sorry, if I chose wrong place to publish this patch.

--
Best regards,
Alexander

[---cut here---]
--- iputils/ping.c.org  2002-09-20 19:08:11.000000000 +0400
+++ iputils/ping.c      2009-01-29 14:10:40.000000000 +0300
@@ -486,10 +486,12 @@
                exit(2);
        }

-       printf("PING %s (%s) ", hostname, inet_ntoa(whereto.sin_addr));
-       if (device || (options&F_STRICTSOURCE))
+       if ( !(options & F_MRTGPROBE) ) {
+           printf("PING %s (%s) ", hostname, inet_ntoa(whereto.sin_addr));
+           if (device || (options&F_STRICTSOURCE))
                printf("from %s %s: ", inet_ntoa(source.sin_addr), device ?: "");
-       printf("%d(%d) bytes of data.\n", datalen, datalen+8+optlen+20);
+           printf("%d(%d) bytes of data.\n", datalen, datalen+8+optlen+20);
+       }

        setup(icmp_sock);

@@ -1197,7 +1199,7 @@
 void usage(void)
 {
        fprintf(stderr,
-"Usage: ping [-LRUbdfnqrvVaA] [-c count] [-i interval] [-w deadline]\n"
+"Usage: ping [-LRUbdfnqrvVaAm] [-c count] [-i interval] [-w deadline]\n"
 "            [-p pattern] [-s packetsize] [-t ttl] [-I interface or address]\n"
 "            [-M mtu discovery hint] [-S sndbuf]\n"
 "            [ -T timestamp option ] [ -Q tos ] [hop1 ...] destination\n");
--- iputils/ping_common.c.org   2002-09-20 20:02:32.000000000 +0400
+++ iputils/ping_common.c       2009-01-29 14:15:24.000000000 +0300
@@ -216,6 +216,9 @@
                }
                lingertime *= 1000;
                break;
+       case 'm':
+               options |= F_MRTGPROBE;
+               break;
        case 'V':
                printf("ping utility, iputils-ss%s\n", SNAPSHOT);
                exit(0);
@@ -782,8 +785,16 @@

        tvsub(&tv, &start_time);

+       if (options & F_MRTGPROBE) {
+           fflush(stdout);
+           printf("%d\n%d\n", (unsigned long)(tsum/1000),
+               (int) ((((long long)(ntransmitted - nreceived)) * 100) / ntransmitted) );
+           exit(!nreceived || (deadline && nreceived < npackets));
+       }
+
        putchar('\n');
        fflush(stdout);
+
        printf("--- %s ping statistics ---\n", hostname);
        printf("%ld packets transmitted, ", ntransmitted);
        printf("%ld received", nreceived);
--- iputils/ping_common.h.org   2002-09-20 19:08:11.000000000 +0400
+++ iputils/ping_common.h       2009-01-29 14:06:40.000000000 +0300
@@ -59,6 +59,7 @@
 #define        F_STRICTSOURCE  0x8000
 #define F_NOLOOP       0x10000
 #define F_TTL          0x20000
+#define F_MRTGPROBE    0x40000

 /*
  * MAX_DUP_CHK is the number of bits in received table, i.e. the maximum
@@ -117,9 +118,9 @@
 case 'f': case 'i': case 'w': case 'l': \
 case 'S': case 'n': case 'p': case 'q': \
 case 'r': case 's': case 'v': case 'L': \
-case 't': case 'A': case 'W': case 'B':
+case 't': case 'A': case 'W': case 'B': case 'm':

-#define COMMON_OPTSTR "h?VQ:I:M:aUc:dfi:w:l:S:np:qrs:vLt:AW:B"
+#define COMMON_OPTSTR "h?VQ:I:M:aUc:dfi:w:l:S:np:qrs:vLt:AW:B:m"


 /*
--- iputils/doc/ping.sgml.org   2002-09-20 16:55:50.000000000 +0400
+++ iputils/doc/ping.sgml       2009-01-29 13:14:38.000000000 +0300
@@ -14,7 +14,7 @@
 <refsynopsisdiv>
 <cmdsynopsis>
 <command>ping</command>
-<arg choice="opt"><option>-LRUbdfnqrvVaAB</option></arg>
+<arg choice="opt"><option>-LRUbdfnqrvVaABm</option></arg>
 <arg choice="opt">-c <replaceable/count/</arg>
 <arg choice="opt">-i <replaceable/interval/</arg>
 <arg choice="opt">-l <replaceable/preload/</arg>
@@ -144,6 +144,14 @@
   </para></listitem>
  </varlistentry>
  <varlistentry>
+  <term><option/-m/</term>
+  <listitem><para>
+Behave like mrtg-ping-probe (<ulink url="http://pwo.de/projects/mrtg/">http://pwo.de/projects/mrtg/</ulink>):
+print average RTT and packet loss only. Combine with <option>-q</option> to strip
+header and footer.
+  </para></listitem>
+ </varlistentry>
+ <varlistentry>
   <term><option/-n/</term>
   <listitem><para>
 Numeric output only.
[---cut here---]


