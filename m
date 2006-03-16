From: Russell Stuart <russell-lartc@stuart.id.au>
Subject: Re: [PATCH] TC: bug fixes to the "sample" clause
Date: Thu, 16 Mar 2006 11:43:39 +1000
Message-ID: <1142473419.17608.351.camel@ras.pc.brisbane.lube>
References: <1139538806.15476.33.camel@ras> <1142082696.5184.53.camel@jzny2>
	<1142225063.14909.77.camel@ras.pc.brisbane.lube>
	<1142269090.5242.29.camel@jzny2> <4415B217.30507@trash.net>
	<20060313100421.7df7f9ed@localhost.localdomain>
	<1142286237.17608.7.camel@ras.pc.brisbane.lube>
	<20060313135048.27b09fba@localhost.localdomain>
	<1142296295.17608.112.camel@ras.pc.brisbane.lube>
	<1142303082.5219.16.camel@jzny2>
	<1142306212.17608.178.camel@ras.pc.brisbane.lube>
	<1142307572.5219.73.camel@jzny2>
	<1142312708.17608.270.camel@ras.pc.brisbane.lube>
	<1142436098.5346.3.camel@jzny2>
	<1142470323.17608.341.camel@ras.pc.brisbane.lube>
	<20060315165757.44bf1548@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lartc@mailman.ds9a.nl, hadi@cyberus.ca, netdev@vger.kernel.org
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060315165757.44bf1548@localhost.localdomain>
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

<snip>Much discussion bashing this issue to death.</snip>

(sorry, jamal - this one is CC'ed to lartc.)

Here is are revised versions of the 2 as yet unapplied
patches.

PATCH 1
=======

[Has been applied.]


PATCH 2
=======

In tc, the u32 sample clause uses the 2.4 hashing algorithm.
The hashing algorithm used by the kernel changed in 2.6,
consequently "sample" hasn't work since then.

This patch makes the sample clause work 2.6 only.  This is
different from the prior version of the patch, in that it
made it work with 2.4 and 2.6:

diff -Nur iproute-20051007.keep/tc/f_u32.c iproute-20051007/tc/f_u32.c
--- iproute-20051007.keep/tc/f_u32.c	2006-03-14 12:28:17.000000000 +1000
+++ iproute-20051007/tc/f_u32.c	2006-03-16 11:08:25.000000000 +1000
@@ -888,8 +888,18 @@
 				return -1;
 			}
 			hash = sel2.sel.keys[0].val&sel2.sel.keys[0].mask;
+#if	0
+			/* 2.2 .. 2.4 hashing algorithm */
 			hash ^= hash>>16;
 			hash ^= hash>>8;
+#else
+			/* 2.5 onwards */
+			__u32 mask = sel2.sel.keys[0].mask;
+			while (mask && !(mask & 1)) {
+			  	mask >>= 1;
+				hash >>= 1;
+			}
+#endif
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
clause.  This is identical to the previous version of
the patch, other than it now applies correctly after
the revised PATCH 3.

diff -Nur iproute-20051007.keep/tc/f_u32.c iproute-20051007/tc/f_u32.c
--- iproute-20051007.keep/tc/f_u32.c	2006-03-16 11:27:17.000000000 +1000
+++ iproute-20051007/tc/f_u32.c	2006-03-16 11:29:56.000000000 +1000
@@ -34,7 +34,7 @@
 	fprintf(stderr, "or         u32 divisor DIVISOR\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: SELECTOR := SAMPLE SAMPLE ...\n");
-	fprintf(stderr, "       SAMPLE := { ip | ip6 | udp | tcp | icmp | u{32|16|8} | mark } SAMPLE_ARGS\n");
+	fprintf(stderr, "       SAMPLE := { ip | ip6 | udp | tcp | icmp | u{32|16|8} | mark } SAMPLE_ARGS [divisor DIVISOR]\n");
 	fprintf(stderr, "       FILTERID := X:Y:Z\n");
 }
 
@@ -834,7 +834,7 @@
 			unsigned divisor;
 			NEXT_ARG();
 			if (get_unsigned(&divisor, *argv, 0) || divisor == 0 ||
-			    divisor > 0x100) {
+			    divisor > 0x100 || (divisor - 1 & divisor)) {
 				fprintf(stderr, "Illegal \"divisor\"\n");
 				return -1;
 			}
@@ -874,6 +874,7 @@
 				htid = (handle&0xFFFFF000);
 		} else if (strcmp(*argv, "sample") == 0) {
 			__u32 hash;
+			unsigned divisor = 0x100;
 			struct {
 				struct tc_u32_sel sel;
 				struct tc_u32_key keys[4];
@@ -888,6 +889,15 @@
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
 #if	0
 			/* 2.2 .. 2.4 hashing algorithm */
@@ -901,7 +911,7 @@
 				hash >>= 1;
 			}
 #endif
-			htid = ((hash<<12)&0xFF000)|(htid&0xFFF00000);
+			htid = ((hash%divisor)<<12)|(htid&0xFFF00000);
 			sample_ok = 1;
 			continue;
 		} else if (strcmp(*argv, "indev") == 0) {
