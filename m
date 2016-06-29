From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v3 iproute2 3/6] ip neigh: Add support for keyword
Date: Wed, 29 Jun 2016 11:06:17 -0700
Message-ID: <1467223580-14548-4-git-send-email-dsa@cumulusnetworks.com>
References: <1467223580-14548-1-git-send-email-dsa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34258 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443AbcF2SGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 14:06:41 -0400
Received: by mail-pf0-f170.google.com with SMTP id h14so20404850pfe.1
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 11:06:28 -0700 (PDT)
In-Reply-To: <1467223580-14548-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add vrf keyword to 'ip neigh' commands. Allows listing neighbor
entries for all links associated with a given VRF.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/ipneigh.c            | 14 +++++++++++++-
 man/man8/ip-neighbour.8 |  8 +++++++-
 2 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index 4ddb747e2086..3e444712645f 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -48,7 +48,8 @@ static void usage(void)
 {
 	fprintf(stderr, "Usage: ip neigh { add | del | change | replace }\n"
 			"                { ADDR [ lladdr LLADDR ] [ nud STATE ] | proxy ADDR } [ dev DEV ]\n");
-	fprintf(stderr, "       ip neigh { show | flush } [ proxy ] [ to PREFIX ] [ dev DEV ] [ nud STATE ]\n\n");
+	fprintf(stderr, "       ip neigh { show | flush } [ proxy ] [ to PREFIX ] [ dev DEV ] [ nud STATE ]\n");
+	fprintf(stderr, "                                 [ vrf NAME ]\n\n");
 	fprintf(stderr, "STATE := { permanent | noarp | stale | reachable | none |\n"
 			"           incomplete | delay | probe | failed }\n");
 	exit(-1);
@@ -385,6 +386,17 @@ static int do_show_or_flush(int argc, char **argv, int flush)
 				invarg("Device does not exist\n", *argv);
 			addattr32(&req.n, sizeof(req), NDA_MASTER, ifindex);
 			filter.master = ifindex;
+		} else if (strcmp(*argv, "vrf") == 0) {
+			int ifindex;
+
+			NEXT_ARG();
+			ifindex = ll_name_to_index(*argv);
+			if (!ifindex)
+				invarg("Not a valid VRF name\n", *argv);
+			if (!name_is_vrf(*argv))
+				invarg("Not a valid VRF name\n", *argv);
+			addattr32(&req.n, sizeof(req), NDA_MASTER, ifindex);
+			filter.master = ifindex;
 		} else if (strcmp(*argv, "unused") == 0) {
 			filter.unused_only = 1;
 		} else if (strcmp(*argv, "nud") == 0) {
diff --git a/man/man8/ip-neighbour.8 b/man/man8/ip-neighbour.8
index b292e1814495..bbfe8e72a09c 100644
--- a/man/man8/ip-neighbour.8
+++ b/man/man8/ip-neighbour.8
@@ -31,7 +31,9 @@ ip-neighbour \- neighbour/arp tables management.
 .B  dev
 .IR DEV " ] [ "
 .B  nud
-.IR STATE " ]"
+.IR STATE " ] [ "
+.B  vrf
+.IR NAME " ] "
 
 .ti -8
 .IR STATE " := {"
@@ -164,6 +166,10 @@ the prefix selecting the neighbours to list.
 only list the neighbours attached to this device.
 
 .TP
+.BI vrf " NAME"
+only list the neighbours for given VRF.
+
+.TP
 .BI proxy
 list neighbour proxies.
 
-- 
2.1.4
