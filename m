From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] route: ignore RTAX_HOPLIMIT of value -1
Date: Wed,  2 Dec 2015 13:50:22 +0100
Message-ID: <1449060622-22898-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:59135 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755238AbbLBMuf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 07:50:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Older kernels use -1 internally as indicator to use the sysctl default,
but they still export the setting. Newer kernels use 0 to indicate that
(which is why the conversion from -1 to 0 was done here), but they also
stopped exporting the value. Since the meaning of -1 is clear, treat it
equally like default on newer kernels (which is to not print anything).

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iproute.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index aed1038e515b6..c42ea0b9ecb8e 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -577,24 +577,23 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			if (mxrta[i] == NULL)
 				continue;
 
-			if (i < sizeof(mx_names)/sizeof(char*) && mx_names[i])
-				fprintf(fp, " %s", mx_names[i]);
-			else
-				fprintf(fp, " metric %d", i);
-
 			if (mxlock & (1<<i))
 				fprintf(fp, " lock");
 			if (i != RTAX_CC_ALGO)
 				val = rta_getattr_u32(mxrta[i]);
 
+			if (i == RTAX_HOPLIMIT && (int)val == -1)
+				continue;
+
+			if (i < sizeof(mx_names)/sizeof(char*) && mx_names[i])
+				fprintf(fp, " %s", mx_names[i]);
+			else
+				fprintf(fp, " metric %d", i);
+
 			switch (i) {
 			case RTAX_FEATURES:
 				print_rtax_features(fp, val);
 				break;
-			case RTAX_HOPLIMIT:
-				if ((int)val == -1)
-					val = 0;
-				/* fall through */
 			default:
 				fprintf(fp, " %u", val);
 				break;
-- 
2.5.0
