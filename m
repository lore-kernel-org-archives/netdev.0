From: =?iso-8859-1?q?Ole_Bj=F8rn_Hessen?= <obh@telenor.net>
Subject: patch for iputils ping & ping6: print gettimeofday timestamp, print no reply
Date: 26 Jun 2009 23:46:34 +0200
Message-ID: <v5prcqvfb9.fsf@shell1.nsc.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from greylin.nsc.no ([193.213.112.58]:62914 "EHLO greylin.nsc.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751257AbZFZWRm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 18:17:42 -0400
Received: from shell1.nsc.no (shell1.nsc.no [148.122.207.137])
	by greylin.nsc.no (Postfix) with ESMTP id 3E9FB11DC9
	for <netdev@vger.kernel.org>; Fri, 26 Jun 2009 23:46:35 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

sometimes I need to ping an IP address for a long time to get to know
how stable a connection is. It'd be nice if output from ping could be
configured to be more grep'ble and time stamped.

This small patch adds some functionality to print timestamp before
printfs (option -D) and also to print out "no reply yet" (option -N) if
no packet was received before next packet is sent.

I sent the patch original to Noah Meyerhans at debian, but he suggested
to send the patch to YOSHIFUJI Hideaki) via the netdev@vger.kernel.org
mailinglist instead.

Kind regards,

Ole Bj=F8rn Hessen
Telenor



diff -r -u ../iputils_20071127.orig/doc/ping.sgml ./doc/ping.sgml
--- ../iputils_20071127.orig/doc/ping.sgml	2007-04-11 04:49:11.00000000=
0 +0200
+++ ./doc/ping.sgml	2009-06-26 23:26:18.412415000 +0200
@@ -160,6 +160,19 @@
   </para></listitem>
  </varlistentry>
  <varlistentry>
+  <term><option/-D/</term>
+  <listitem><para>
+Print timestamp (unix time + microseconds as in gettimeofday) before
+each line.
+  </para></listitem>
+ </varlistentry>
+ <varlistentry>
+  <term><option/-N/</term>
+  <listitem><para>
+Print no reply yet if no packet was received before sending next packe=
t.
+  </para></listitem>
+ </varlistentry>
+ <varlistentry>
   <term><option>-Q <replaceable/tos/</option></term>
   <listitem><para>
 Set Quality of Service -related bits in ICMP datagrams. =20
diff -r -u ../iputils_20071127.orig/ping6.c ./ping6.c
--- ../iputils_20071127.orig/ping6.c	2007-12-10 04:56:22.000000000 +010=
0
+++ ./ping6.c	2009-06-26 23:30:44.303253000 +0200
@@ -672,6 +672,11 @@
 		if (options & F_FLOOD) {
 			write(STDOUT_FILENO, "\bE", 2);
 		} else {
+			if (options & F_PTIMEOFDAY) {
+				struct timeval recv_time;
+				gettimeofday(&recv_time, NULL);
+				printf("%lu.%06lu ", (unsigned long)recv_time.tv_sec, (unsigned lo=
ng)recv_time.tv_usec);
+			}
 			printf("From %s icmp_seq=3D%u ", pr_addr(&sin6->sin6_addr), ntohs(i=
cmph.icmp6_seq));
 			pr_icmph(e->ee_type, e->ee_code, e->ee_info);
 			putchar('\n');
@@ -821,11 +826,21 @@
 				write(STDOUT_FILENO, "\bE", 2);
 				return 0;
 			}
+			if (options & F_PTIMEOFDAY) {
+				struct timeval recv_time;
+				gettimeofday(&recv_time, NULL);
+				printf("%lu.%06lu ", (unsigned long)recv_time.tv_sec, (unsigned lo=
ng)recv_time.tv_usec);
+			}
 			printf("From %s: icmp_seq=3D%u ", pr_addr(&from->sin6_addr), ntohs(=
icmph1->icmp6_seq));
 		} else {
 			/* We've got something other than an ECHOREPLY */
 			if (!(options & F_VERBOSE) || uid)
 				return 1;
+			if (options & F_PTIMEOFDAY) {
+				struct timeval recv_time;
+				gettimeofday(&recv_time, NULL);
+				printf("%lu.%06lu ", (unsigned long)recv_time.tv_sec, (unsigned lo=
ng)recv_time.tv_usec);
+			}
 			printf("From %s: ", pr_addr(&from->sin6_addr));
 		}
 		pr_icmph(icmph->icmp6_type, icmph->icmp6_code, ntohl(icmph->icmp6_mt=
u));
@@ -971,7 +986,7 @@
 void usage(void)
 {
 	fprintf(stderr,
-"Usage: ping6 [-LUdfnqrvVaA] [-c count] [-i interval] [-w deadline]\n"
+"Usage: ping6 [-LUdfnqrvVaADN] [-c count] [-i interval] [-w deadline]\=
n"
 "             [-p pattern] [-s packetsize] [-t ttl] [-I interface]\n"
 "             [-M mtu discovery hint] [-S sndbuf]\n"
 "             [-F flow label] [-Q traffic class] [hop1 ...] destinatio=
n\n");
diff -r -u ../iputils_20071127.orig/ping.c ./ping.c
--- ../iputils_20071127.orig/ping.c	2007-12-10 04:56:22.000000000 +0100
+++ ./ping.c	2009-06-26 23:30:31.202369000 +0200
@@ -595,6 +595,11 @@
 		if (options & F_FLOOD) {
 			write(STDOUT_FILENO, "\bE", 2);
 		} else {
+			if (options & F_PTIMEOFDAY) {
+				struct timeval recv_time;
+				gettimeofday(&recv_time, NULL);
+				printf("%lu.%06lu ", (unsigned long)recv_time.tv_sec, (unsigned lo=
ng)recv_time.tv_usec);
+			}
 			printf("From %s icmp_seq=3D%u ", pr_addr(sin->sin_addr.s_addr), nto=
hs(icmph.un.echo.sequence));
 			pr_icmph(e->ee_type, e->ee_code, e->ee_info, NULL);
 			fflush(stdout);
@@ -761,6 +766,11 @@
 						write(STDOUT_FILENO, "\bE", 2);
 					return !error_pkt;
 				}
+				if (options & F_PTIMEOFDAY) {
+					struct timeval recv_time;
+					gettimeofday(&recv_time, NULL);
+					printf("%lu.%06lu ", (unsigned long)recv_time.tv_sec, (unsigned l=
ong)recv_time.tv_usec);
+				}
 				printf("From %s: icmp_seq=3D%u ",
 				       pr_addr(from->sin_addr.s_addr),
 				       ntohs(icp1->un.echo.sequence));
@@ -782,6 +792,11 @@
 		}
 		if (!(options & F_VERBOSE) || uid)
 			return 0;
+		if (options & F_PTIMEOFDAY) {
+			struct timeval recv_time;
+			gettimeofday(&recv_time, NULL);
+			printf("%lu.%06lu ", (unsigned long)recv_time.tv_sec, (unsigned lon=
g)recv_time.tv_usec);
+		}
 		printf("From %s: ", pr_addr(from->sin_addr.s_addr));
 		if (csfailed) {
 			printf("(BAD CHECKSUM)\n");
@@ -1214,7 +1229,7 @@
 void usage(void)
 {
 	fprintf(stderr,
-"Usage: ping [-LRUbdfnqrvVaA] [-c count] [-i interval] [-w deadline]\n=
"
+"Usage: ping [-LRUbdfnqrvVaADN] [-c count] [-i interval] [-w deadline]=
\n"
 "            [-p pattern] [-s packetsize] [-t ttl] [-I interface or ad=
dress]\n"
 "            [-M mtu discovery hint] [-S sndbuf]\n"
 "            [ -T timestamp option ] [ -Q tos ] [hop1 ...] destination=
\n");
diff -r -u ../iputils_20071127.orig/ping_common.c ./ping_common.c
--- ../iputils_20071127.orig/ping_common.c	2009-06-26 19:53:06.36158700=
0 +0200
+++ ./ping_common.c	2009-06-26 23:23:18.839167000 +0200
@@ -114,6 +114,9 @@
 	case 'd':
 		options |=3D F_SO_DEBUG;
 		break;
+	case 'D':
+		options |=3D F_PTIMEOFDAY;
+		break;
 	case 'f':
 		options |=3D F_FLOOD;
 		setbuf(stdout, (char *)NULL);
@@ -171,6 +174,9 @@
 	case 'n':
 		options |=3D F_NUMERIC;
 		break;
+	case 'N':
+		options |=3D F_NOREPLY;
+		break;
 	case 'p':		/* fill buffer with user pattern */
 		options |=3D F_PINGFILLED;
 		fill(optarg);
@@ -316,6 +322,18 @@
 		tokens =3D ntokens - interval;
 	}
=20
+	if (options & F_NOREPLY) {
+		if (ntransmitted > 0 && !TST(ntransmitted % mx_dup_ck)) {
+			if (options & F_PTIMEOFDAY) {
+				struct timeval recv_time;
+				gettimeofday(&recv_time, NULL);=09
+				printf("%lu.%06lu ", (unsigned long)recv_time.tv_sec, (unsigned lo=
ng)recv_time.tv_usec);
+			}
+			printf("no answer yet for icmp_seq=3D%lu\n", (ntransmitted % mx_dup=
_ck));
+			fflush(stdout);
+		}
+	}
+
 resend:
 	i =3D send_probe();
=20
@@ -714,6 +732,11 @@
 	} else {
 		int i;
 		__u8 *cp, *dp;
+		if (options & F_PTIMEOFDAY) {
+			struct timeval recv_time;
+			gettimeofday(&recv_time, NULL);
+			printf("%lu.%06lu ", (unsigned long)recv_time.tv_sec, (unsigned lon=
g)recv_time.tv_usec);
+		}
 		printf("%d bytes from %s: icmp_seq=3D%u", cc, from, seq);
=20
 		if (hops >=3D 0)
diff -r -u ../iputils_20071127.orig/ping_common.h ./ping_common.h
--- ../iputils_20071127.orig/ping_common.h	2007-12-10 04:56:22.00000000=
0 +0100
+++ ./ping_common.h	2009-06-26 23:24:00.656302000 +0200
@@ -60,6 +60,8 @@
 #define	F_STRICTSOURCE	0x8000
 #define F_NOLOOP	0x10000
 #define F_TTL		0x20000
+#define F_PTIMEOFDAY	0x40000
+#define F_NOREPLY	0x80000
=20
 /*
  * MAX_DUP_CHK is the number of bits in received table, i.e. the maxim=
um
@@ -118,9 +120,10 @@
 case 'f': case 'i': case 'w': case 'l': \
 case 'S': case 'n': case 'p': case 'q': \
 case 'r': case 's': case 'v': case 'L': \
-case 't': case 'A': case 'W': case 'B':
+case 't': case 'A': case 'W': case 'B': \
+case 'D': case 'N':
=20
-#define COMMON_OPTSTR "h?VQ:I:M:aUc:dfi:w:l:S:np:qrs:vLt:AW:B"
+#define COMMON_OPTSTR "h?VQ:I:M:aUc:dfi:w:l:S:np:qrs:vLt:AW:BDN"
=20
=20
 /*
