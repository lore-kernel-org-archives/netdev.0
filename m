From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: [PATCH] iproute2 add hoplimit parsing and update usage and documentation
Date: Tue, 06 Oct 2009 15:40:34 +0200
Message-ID: <1254836434.544524.27946.nullmailer@watson.codefidence.com>
References: <4ACB39F2.6080002@codefidence.com>
Cc: Ori Finkelman <ori@comsleep.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:46841 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757264AbZJFNlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 09:41:08 -0400
Cc: Andreas Henriksson <andreas@fatal.se>
In-Reply-To: <4ACB39F2.6080002@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gilad Ben-Yossef <gilad@codefidence.com>

- Parse and handle the hoplimit ip route option and add it to the usage 
  line and documentation.

- Add the missing reordering ip route option to the usage line.

- Add documentation for initcwnd ip route option.

Tested by setting hoplimit and retreiving it via "show". 

Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
[ported to HEAD, fixed a bug with hoplimit lock handling, added documentation]
Signed-off-by: Ori Finkelman <ori@comsleep.com>
Signed-off-by: Yony Amit <yony@comsleep.com>

---

Debian is carrying a patch with identical functionality for some 
time now it seems.

Parts of this patch carved out from original patch by Yony Amit 
and Ori Finkelman from Comsleep Ltd. with minor bug
fixing and HEAD port by me.

Additional documentation bits inspired by Debian patch with unknown
author provided by Andreas Henriksson <andreas@fatal.se>

diff --git a/doc/ip-cref.tex b/doc/ip-cref.tex
index bb4eb78..f81adc5 100644
--- a/doc/ip-cref.tex
+++ b/doc/ip-cref.tex
@@ -1324,7 +1324,17 @@ peers are allowed to send to us.
     If it is not given, Linux uses the value selected with \verb|sysctl|
     variable \verb|net/ipv4/tcp_reordering|.
 
+\item \verb|hoplimit NUMBER|
 
+--- [2.5.74+ only] Maximum number of hops on the path to this destination. 
+    The default is the value selected with the \verb|sysctl| variable
+    \verb|net/ipv4/ip_default_ttl|.
+
+\item \verb|initcwnd NUMBER|
+--- [2.5.70+ only] Initial congestion window size for connections to 
+    this destination. Actual window size is this value multiplied by the
+    MSS (``Maximal Segment Size'') for same connection. The default is
+    zero, meaning to use the values specified in~\cite{RFC2414}.
 
 \item \verb|nexthop NEXTHOP|
 
@@ -2653,6 +2663,9 @@ http://www.cisco.com/univercd/cc/td/doc/product/software/ios120.
 \bibitem{RFC-DHCP} R.~Droms.
 ``Dynamic Host Configuration Protocol.'', RFC-2131
 
+\bibitem{RFC2414}  M.~Allman, S.~Floyd, C.~Partridge.
+``Increasing TCP's Initial Window'', RFC-2414.
+
 \end{thebibliography}
 
 
diff --git a/ip/iproute.c b/ip/iproute.c
index bf0f31b..aeea93d 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -13,6 +13,8 @@
  *
  * Rani Assaf <rani@magic.metawire.com> 980929:	resolve addresses
  * Kunihiro Ishiguro <kunihiro@zebra.org> 001102: rtnh_ifindex was not initialized
+ * Gilad Ben-Yossef <gilad@codefidence.com> 091006: Add hoplimit option parsing 
+ * and correct usage
  */
 
 #include <stdio.h>
@@ -70,10 +72,10 @@ static void usage(void)
 	fprintf(stderr, "INFO_SPEC := NH OPTIONS FLAGS [ nexthop NH ]...\n");
 	fprintf(stderr, "NH := [ via ADDRESS ] [ dev STRING ] [ weight NUMBER ] NHFLAGS\n");
 	fprintf(stderr, "OPTIONS := FLAGS [ mtu NUMBER ] [ advmss NUMBER ]\n");
-	fprintf(stderr, "           [ rtt TIME ] [ rttvar TIME ]\n");
+	fprintf(stderr, "           [ rtt TIME ] [ rttvar TIME ] [reordering NUMBER ]\n");
 	fprintf(stderr, "           [ window NUMBER] [ cwnd NUMBER ] [ initcwnd NUMBER ]\n");
 	fprintf(stderr, "           [ ssthresh NUMBER ] [ realms REALM ] [ src ADDRESS ]\n");
-	fprintf(stderr, "           [ rto_min TIME ]\n");
+	fprintf(stderr, "           [ rto_min TIME ] [ hoplimit NUMBER ] \n");
 	fprintf(stderr, "TYPE := [ unicast | local | broadcast | multicast | throw |\n");
 	fprintf(stderr, "          unreachable | prohibit | blackhole | nat ]\n");
 	fprintf(stderr, "TABLE_ID := [ local | main | default | all | NUMBER ]\n");
@@ -768,6 +770,18 @@ int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 			if (get_unsigned(&mtu, *argv, 0))
 				invarg("\"mtu\" value is invalid\n", *argv);
 			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_MTU, mtu);
+#ifdef RTAX_HOPLIMIT
+		} else if (strcmp(*argv, "hoplimit") == 0) {
+			unsigned hoplimit;
+			NEXT_ARG();
+			if (strcmp(*argv, "lock") == 0) {
+				mxlock |= (1<<RTAX_HOPLIMIT);
+				NEXT_ARG();
+			}
+			if (get_unsigned(&hoplimit, *argv, 0))
+				invarg("\"hoplimit\" value is invalid\n", *argv);
+			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_HOPLIMIT, hoplimit);
+#endif
 #ifdef RTAX_ADVMSS
 		} else if (strcmp(*argv, "advmss") == 0) {
 			unsigned mss;
