From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: [PATCH] iproute2 add hoplimit and reordering route options usage and parsing
Date: Mon, 05 Oct 2009 10:54:21 +0200
Message-ID: <1254732861.015524.19779.nullmailer@watson.codefidence.com>
Cc: ori@comsleep.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:37900 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758606AbZJEIyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 04:54:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuki Arbel <yuki@comsleep.com>

iproute2 git HEAD (spotted originally on 2.6.26, so it's probably not new) 
does  not parse the hoplimit route option when proccessing parameters, nor 
does it  print hoplimit and reordering options in the usage lines.  
This patch fixes both. 

Tested by setting hoplimit and be retreiving it via "show".

Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
[ported to HEAD and fixed a bug with hoplimit lock handling in original]
Signed-off-by: Ori Finkelman <ori@comsleep.com>
Signed-off-by: Yuki Arbel <yuki@comsleep.com>

---

Carved out from original patch by Yuki Arbel and Ori Finkelman from 
Comsleep Ltd. which I'm asssiting in mainlining.

diff --git a/ip/iproute.c b/ip/iproute.c
index bf0f31b..4821a1d 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -73,7 +73,7 @@ static void usage(void)
 	fprintf(stderr, "           [ rtt TIME ] [ rttvar TIME ]\n");
 	fprintf(stderr, "           [ window NUMBER] [ cwnd NUMBER ] [ initcwnd NUMBER ]\n");
 	fprintf(stderr, "           [ ssthresh NUMBER ] [ realms REALM ] [ src ADDRESS ]\n");
-	fprintf(stderr, "           [ rto_min TIME ]\n");
+	fprintf(stderr, "           [ rto_min TIME ] [ hoplimit NUMBER ] [ reordering NUMBER] \n");
 	fprintf(stderr, "TYPE := [ unicast | local | broadcast | multicast | throw |\n");
 	fprintf(stderr, "          unreachable | prohibit | blackhole | nat ]\n");
 	fprintf(stderr, "TABLE_ID := [ local | main | default | all | NUMBER ]\n");
@@ -768,6 +768,16 @@ int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 			if (get_unsigned(&mtu, *argv, 0))
 				invarg("\"mtu\" value is invalid\n", *argv);
 			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_MTU, mtu);
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
 #ifdef RTAX_ADVMSS
 		} else if (strcmp(*argv, "advmss") == 0) {
 			unsigned mss;
