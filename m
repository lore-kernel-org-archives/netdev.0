From: Ole Bjorn Hessen <obh@telenor.net>
Subject: [PATCH iputils ping]: report outstanding packets before sending next packet
Date: Thu, 5 Jan 2012 10:04:29 +0100 (MET)
Message-ID: <201201051118.MAA12446@shell02.nsc.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nsmail02.e.nsc.no ([148.123.0.198]:50308 "EHLO
	nsmail02.e.nsc.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754954Ab2AELSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 06:18:45 -0500
Received: from shell02.nsc.no (shell02.nsc.no [10.123.1.22])
	by nsmail02.e.nsc.no (Postfix) with ESMTP id 0CBE417400
	for <netdev@vger.kernel.org>; Thu,  5 Jan 2012 12:18:42 +0100 (MET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Hello,

please accept following patch to ping to let ping report outstanding
packets before sending next packet. This is a sorely missed feature
from the old sun ping. Very useful together with the -D option:

     ping -DO 10.122.145.180 > file
     # wait next day
     ^C
     grep "no answer yet" file

     [1325752664.026900] 64 bytes from 10.122.145.180: icmp_req=20 ttl=64 time=0.695 ms
     [1325752665.026926] 64 bytes from 10.122.145.180: icmp_req=21 ttl=64 time=0.695 ms
     [1325752666.026917] 64 bytes from 10.122.145.180: icmp_req=22 ttl=64 time=0.682 ms
     [1325752667.026922] 64 bytes from 10.122.145.180: icmp_req=23 ttl=64 time=0.695 ms
     [1325752669.026217] no answer yet for icmp_seq=24
     [1325752670.026207] no answer yet for icmp_seq=25
     ...
     [1325752697.026206] no answer yet for icmp_seq=52
     [1325752698.026205] no answer yet for icmp_seq=53
     [1325752698.026962] 64 bytes from 10.122.145.180: icmp_req=54 ttl=64 time=0.717 ms
     [1325752699.026930] 64 bytes from 10.122.145.180: icmp_req=55 ttl=64 time=0.690 ms
     [1325752700.026928] 64 bytes from 10.122.145.180: icmp_req=56 ttl=64 time=0.695 ms

Kind regards,

Ole Bjorn Hessen,
Telenor


diff -r -u ../iputils-s20101006/doc/ping.sgml ./doc/ping.sgml
--- ../iputils-s20101006/doc/ping.sgml	2010-10-06 13:59:20.000000000 +0200
+++ ./doc/ping.sgml	2012-01-05 09:54:34.641712000 +0100
@@ -14,7 +14,7 @@
 <refsynopsisdiv>
 <cmdsynopsis>
 <command>ping</command>
-<arg choice="opt"><option>-LRUbdfnqrvVaAB</option></arg>
+<arg choice="opt"><option>-LRUbdfnqrvVaABDO</option></arg>
 <arg choice="opt">-c <replaceable/count/</arg>
 <arg choice="opt">-m <replaceable/mark/</arg>
 <arg choice="opt">-i <replaceable/interval/</arg>
@@ -246,6 +246,14 @@
   </para></listitem>
  </varlistentry>
  <varlistentry>
+  <term><option/-O/</term>
+  <listitem><para>
+Report outstanding ICMP ECHO reply before sending next packet.
+This is useful together with the timestamp <option>-D</option> to
+log output to a diagnostic file and search for missing answers.
+  </para></listitem>
+ </varlistentry>
+ <varlistentry>
   <term><option>-p <replaceable/pattern/</option></term>
   <listitem><para>
 You may specify up to 16 ``pad'' bytes to fill out the packet you send.
diff -r -u ../iputils-s20101006/ping6.c ./ping6.c
--- ../iputils-s20101006/ping6.c	2010-10-06 13:59:20.000000000 +0200
+++ ./ping6.c	2012-01-05 09:23:29.754460000 +0100
@@ -1554,7 +1554,7 @@
 void usage(void)
 {
 	fprintf(stderr,
-"Usage: ping6 [-LUdfnqrvVaAD] [-c count] [-i interval] [-w deadline]\n"
+"Usage: ping6 [-LUdfnqrvVaADO] [-c count] [-i interval] [-w deadline]\n"
 "             [-p pattern] [-s packetsize] [-t ttl] [-I interface]\n"
 "             [-M pmtudisc-hint] [-S sndbuf] [-F flowlabel] [-Q tclass]\n"
 "             [[-N nodeinfo-option] ...]\n"
diff -r -u ../iputils-s20101006/ping.c ./ping.c
--- ../iputils-s20101006/ping.c	2010-10-06 13:59:20.000000000 +0200
+++ ./ping.c	2012-01-05 09:23:31.079133000 +0100
@@ -1232,7 +1232,7 @@
 void usage(void)
 {
 	fprintf(stderr,
-"Usage: ping [-LRUbdfnqrvVaAD] [-c count] [-i interval] [-w deadline]\n"
+"Usage: ping [-LRUbdfnqrvVaADO] [-c count] [-i interval] [-w deadline]\n"
 "            [-p pattern] [-s packetsize] [-t ttl] [-I interface]\n"
 "            [-M pmtudisc-hint] [-m mark] [-S sndbuf]\n"
 "            [-T tstamp-options] [-Q tos] [hop1 ...] destination\n");
diff -r -u ../iputils-s20101006/ping_common.c ./ping_common.c
--- ../iputils-s20101006/ping_common.c	2010-10-06 13:59:20.000000000 +0200
+++ ./ping_common.c	2012-01-05 09:28:24.801117000 +0100
@@ -172,6 +172,9 @@
 			exit(2);
 		}
 		break;
+	case 'O':
+		options |= F_OUTSTANDING;
+		break;
 	case 'S':
 		sndbuf = atoi(optarg);
 		if (sndbuf <= 0) {
@@ -349,6 +352,14 @@
 		tokens = ntokens - interval;
 	}
 
+	if (options & F_OUTSTANDING) {
+		if (ntransmitted > 0 && !TST(ntransmitted % mx_dup_ck)) {
+			print_timestamp();
+			printf("no answer yet for icmp_seq=%lu\n", (ntransmitted % mx_dup_ck));
+			fflush(stdout);
+		}
+	}
+
 resend:
 	i = send_probe();
 
diff -r -u ../iputils-s20101006/ping_common.h ./ping_common.h
--- ../iputils-s20101006/ping_common.h	2010-10-06 13:59:20.000000000 +0200
+++ ./ping_common.h	2012-01-05 09:22:27.545729000 +0100
@@ -62,6 +62,7 @@
 #define F_TTL		0x20000
 #define F_MARK		0x40000
 #define F_PTIMEOFDAY	0x80000
+#define F_OUTSTANDING	0x100000
 
 /*
  * MAX_DUP_CHK is the number of bits in received table, i.e. the maximum
@@ -121,9 +122,9 @@
 case 'S': case 'n': case 'p': case 'q': \
 case 'r': case 's': case 'v': case 'L': \
 case 't': case 'A': case 'W': case 'B': case 'm': \
-case 'D':
+case 'D': case 'O':
 
-#define COMMON_OPTSTR "h?VQ:I:M:aUc:dfi:w:l:S:np:qrs:vLt:AW:Bm:D"
+#define COMMON_OPTSTR "h?VQ:I:M:aUc:dfi:w:l:S:np:qrs:vLt:AW:Bm:DO"
 
 
 /*
----------
