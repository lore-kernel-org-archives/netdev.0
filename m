From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2 6/6] ip route: Add support for vrf keyword
Date: Mon, 27 Jun 2016 11:51:01 -0700
Message-ID: <1467053461-16147-7-git-send-email-dsa@cumulusnetworks.com>
References: <1467053461-16147-1-git-send-email-dsa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34102 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644AbcF0SvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 14:51:15 -0400
Received: by mail-pa0-f44.google.com with SMTP id bz2so61468586pad.1
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 11:51:14 -0700 (PDT)
In-Reply-To: <1467053461-16147-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add vrf keyword to 'ip route' commands. Allows:
1. Users can list routes by VRF name:
       $ ip route show vrf NAME

   VRF tables have all routes including local and broadcast routes.
   The VRF keyword filters LOCAL and BROADCAST routes; to see all
   routes the table option can be used. Or to see local routes only
   for a VRF:
       $ ip route show vrf NAME type local

2. Add or delete a route for a VRF:
       $ ip route {add|delete} vrf NAME <route spec>

3. Do a route lookup for a VRF:
       $ ip route get vrf NAME ADDRESS

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/iproute.c | 32 ++++++++++++++++++++++++++++++--
 1 file changed, 30 insertions(+), 2 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index aae693d17be8..bd661c16cb46 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -67,10 +67,10 @@ static void usage(void)
 	fprintf(stderr, "       ip route showdump\n");
 	fprintf(stderr, "       ip route get ADDRESS [ from ADDRESS iif STRING ]\n");
 	fprintf(stderr, "                            [ oif STRING ] [ tos TOS ]\n");
-	fprintf(stderr, "                            [ mark NUMBER ]\n");
+	fprintf(stderr, "                            [ mark NUMBER ] [ vrf NAME ]\n");
 	fprintf(stderr, "       ip route { add | del | change | append | replace } ROUTE\n");
 	fprintf(stderr, "SELECTOR := [ root PREFIX ] [ match PREFIX ] [ exact PREFIX ]\n");
-	fprintf(stderr, "            [ table TABLE_ID ] [ proto RTPROTO ]\n");
+	fprintf(stderr, "            [ table TABLE_ID ] [ vrf NAME ] [ proto RTPROTO ]\n");
 	fprintf(stderr, "            [ type TYPE ] [ scope SCOPE ]\n");
 	fprintf(stderr, "ROUTE := NODE_SPEC [ INFO_SPEC ]\n");
 	fprintf(stderr, "NODE_SPEC := [ TYPE ] PREFIX [ tos TOS ]\n");
@@ -1141,6 +1141,20 @@ static int iproute_modify(int cmd, unsigned int flags, int argc, char **argv)
 				addattr32(&req.n, sizeof(req), RTA_TABLE, tid);
 			}
 			table_ok = 1;
+		} else if (matches(*argv, "vrf") == 0) {
+			__u32 tid;
+
+			NEXT_ARG();
+			tid = ipvrf_get_table(*argv);
+			if (tid == 0)
+				invarg("Invalid VRF\n", *argv);
+			if (tid < 256)
+				req.r.rtm_table = tid;
+			else {
+				req.r.rtm_table = RT_TABLE_UNSPEC;
+				addattr32(&req.n, sizeof(req), RTA_TABLE, tid);
+			}
+			table_ok = 1;
 		} else if (strcmp(*argv, "dev") == 0 ||
 			   strcmp(*argv, "oif") == 0) {
 			NEXT_ARG();
@@ -1395,6 +1409,15 @@ static int iproute_list_flush_or_save(int argc, char **argv, int action)
 				}
 			} else
 				filter.tb = tid;
+		} else if (matches(*argv, "vrf") == 0) {
+			__u32 tid;
+
+			NEXT_ARG();
+			tid = ipvrf_get_table(*argv);
+			if (tid == 0)
+				invarg("Invalid VRF\n", *argv);
+			filter.tb = tid;
+			filter.typemask = ~(1 << RTN_LOCAL | 1<<RTN_BROADCAST);
 		} else if (matches(*argv, "cached") == 0 ||
 			   matches(*argv, "cloned") == 0) {
 			filter.cloned = 1;
@@ -1681,6 +1704,11 @@ static int iproute_get(int argc, char **argv)
 			req.r.rtm_flags |= RTM_F_NOTIFY;
 		} else if (matches(*argv, "connected") == 0) {
 			connected = 1;
+		} else if (matches(*argv, "vrf") == 0) {
+			NEXT_ARG();
+			if (!name_is_vrf(*argv))
+				invarg("Invalid VRF\n", *argv);
+			odev = *argv;
 		} else {
 			inet_prefix addr;
 
-- 
2.1.4
