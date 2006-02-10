From: Russell Stuart <russell-lartc@stuart.id.au>
Subject: [PATCH] TC: bug fixes to the "sample" clause
Date: Fri, 10 Feb 2006 12:33:26 +1000
Message-ID: <1139538806.15476.33.camel@ras>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: netdev@vger.kernel.org, lartc@mailman.ds9a.nl,
	shemminger@osdl.org
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

PATCH 1
=======

On my machine tc does not parse filter "sample" for the u32
filter.  Eg:

tc filter add dev eth2 parent 1:0 protocol ip prio 1 u32 ht 801: \ 
    classid 1:3 \
    sample ip protocol 1 0xff match ip protocol 1 0xff
  Illegal "sample"

The reason is a missing memset.  This patch fixes it.

diff -Nur iproute-20051007.keep/tc/f_u32.c iproute-20051007/tc/f_u32.c
--- iproute-20051007.keep/tc/f_u32.c	2005-01-19 08:11:58.000000000 +1000
+++ iproute-20051007/tc/f_u32.c	2006-01-12 17:12:43.000000000 +1000
@@ -878,6 +878,7 @@
 				struct tc_u32_sel sel;
 				struct tc_u32_key keys[4];
 			} sel2;
+			memset(&sel2, 0, sizeof(sel2));
 			NEXT_ARG();
 			if (parse_selector(&argc, &argv, &sel2.sel, n)) {
 				fprintf(stderr, "Illegal \"sample\"\n");


PATCH 2
=======

In tc, the u32 sample clause uses the 2.4 hashing algorithm.
The hashing algorithm used by the kernel changed in 2.6,
consequently "sample" hasn't work since then.

This patch makes the sample clause work for both 2.4 and 2.6:

diff -Nur iproute-20051007.keep/tc/f_u32.c iproute-20051007/tc/f_u32.c
--- iproute-20051007.keep/tc/f_u32.c	2006-01-12 17:34:37.000000000 +1000
+++ iproute-20051007/tc/f_u32.c	2006-02-07 17:10:29.000000000 +1000
@@ -17,6 +17,7 @@
 #include <syslog.h>
 #include <fcntl.h>
 #include <sys/socket.h>
+#include <sys/utsname.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <string.h>
@@ -874,6 +875,7 @@
 				htid = (handle&0xFFFFF000);
 		} else if (strcmp(*argv, "sample") == 0) {
 			__u32 hash;
+			struct utsname utsname;
 			struct {
 				struct tc_u32_sel sel;
 				struct tc_u32_key keys[4];
@@ -889,8 +891,19 @@
 				return -1;
 			}
 			hash = sel2.sel.keys[0].val&sel2.sel.keys[0].mask;
-			hash ^= hash>>16;
-			hash ^= hash>>8;
+			uname(&utsname);
+			if (strncmp(utsname.release, "2.4.", 4) == 0) {
+				hash ^= hash>>16;
+				hash ^= hash>>8;
+			}
+			else {
+				__u32 mask = sel2.sel.keys[0].mask;
+				while (mask && !(mask & 1)) {
+				  	mask >>= 1;
+					hash >>= 1;
+				}
+				hash &= 0xFF;
+			}
 			htid = ((hash<<12)&0xFF000)|(htid&0xFFF00000);
 			sample_ok = 1;
 			continue;


PATCH 3
=======

"tc" does not allow you to specify the divisor for the
"sample" clause, it always assumes a divisor of 256.  
If the divisor isn't 256, (ie it is something less),
the kernel will usually whinge because the bucket given
to it by "tc" is typically too big.

This patch adds a "divisor" option to tc's "sample"
clause:

diff -Nur iproute-20051007.keep/tc/f_u32.c iproute-20051007/tc/f_u32.c
--- iproute-20051007.keep/tc/f_u32.c	2006-02-10 11:40:16.000000000 +1000
+++ iproute-20051007/tc/f_u32.c	2006-02-10 11:47:14.000000000 +1000
@@ -35,7 +35,7 @@
 	fprintf(stderr, "or         u32 divisor DIVISOR\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: SELECTOR := SAMPLE SAMPLE ...\n");
-	fprintf(stderr, "       SAMPLE := { ip | ip6 | udp | tcp | icmp | u{32|16|8} | mark } SAMPLE_ARGS\n");
+	fprintf(stderr, "       SAMPLE := { ip | ip6 | udp | tcp | icmp | u{32|16|8} | mark } SAMPLE_ARGS [divisor DIVISOR]\n");
 	fprintf(stderr, "       FILTERID := X:Y:Z\n");
 }
 
@@ -835,7 +835,7 @@
 			unsigned divisor;
 			NEXT_ARG();
 			if (get_unsigned(&divisor, *argv, 0) || divisor == 0 ||
-			    divisor > 0x100) {
+			    divisor > 0x100 || (divisor - 1 & divisor)) {
 				fprintf(stderr, "Illegal \"divisor\"\n");
 				return -1;
 			}
@@ -875,6 +875,7 @@
 				htid = (handle&0xFFFFF000);
 		} else if (strcmp(*argv, "sample") == 0) {
 			__u32 hash;
+			unsigned divisor = 0x100;
 			struct utsname utsname;
 			struct {
 				struct tc_u32_sel sel;
@@ -890,6 +891,15 @@
 				fprintf(stderr, "\"sample\" must contain exactly ONE key.\n");
 				return -1;
 			}
+			if (*argv != 0 && strcmp(*argv, "divisor") == 0) {
+				NEXT_ARG();
+				if (get_unsigned(&divisor, *argv, 0) || divisor == 0 ||
+				    divisor > 0x100 || (divisor - 1 & divisor)) {
+					fprintf(stderr, "Illegal sample \"divisor\"\n");
+					return -1;
+				}
+				NEXT_ARG();
+			}
 			hash = sel2.sel.keys[0].val&sel2.sel.keys[0].mask;
 			uname(&utsname);
 			if (strncmp(utsname.release, "2.4.", 4) == 0) {
@@ -904,7 +913,7 @@
 				}
 				hash &= 0xFF;
 			}
-			htid = ((hash<<12)&0xFF000)|(htid&0xFFF00000);
+			htid = ((hash%divisor)<<12)|(htid&0xFFF00000);
 			sample_ok = 1;
 			continue;
 		} else if (strcmp(*argv, "indev") == 0) {
