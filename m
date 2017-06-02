From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2] iproute: extend route get to return matching fib route
Date: Thu,  1 Jun 2017 21:53:28 -0700
Message-ID: <1496379208-30573-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, dsahern@gmail.com,
        nikolay@cumulusnetworks.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33121 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750710AbdFBExd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 00:53:33 -0400
Received: by mail-pf0-f174.google.com with SMTP id e193so46190280pfh.0
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 21:53:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Uses newly introduced RTM_GETROUTE flag RTM_F_FIB_MATCH
to return a matching fib route. Introduces 'fibmatch'
keyword to ip route get.

ipv4:
----
$ip route show
default via 192.168.0.2 dev eth0
10.0.14.0/24
        nexthop via 172.16.0.3  dev dummy0 weight 1
        nexthop via 172.16.1.3  dev dummy1 weight 1

$ip route get 10.0.14.2
10.0.14.2 via 172.16.1.3 dev dummy1  src 172.16.1.1
    cache

$ip route get fibmatch 10.0.14.2
10.0.14.0/24
        nexthop via 172.16.0.3  dev dummy0 weight 1
        nexthop via 172.16.1.3  dev dummy1 weight 1

ipv6:
----
$ip -6 route show
2001:db9:100::/120  metric 1024
        nexthop via 2001:db8:2::2  dev dummy0 weight 1
        nexthop via 2001:db8:12::2  dev dummy1 weight 1

$ip -6 route get 2001:db9:100::1
2001:db9:100::1 from :: via 2001:db8:12::2 dev dummy1  \
                src 2001:db8:12::1  metric 1024  pref medium

$ip -6 route get fibmatch 2001:db9:100::1
2001:db9:100::/120  metric 1024
        nexthop via 2001:db8:12::2  dev dummy1 weight 1
        nexthop via 2001:db8:2::2  dev dummy0 weight 1

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/linux/rtnetlink.h |  1 +
 ip/iproute.c              |  9 ++++++++-
 man/man8/ip-route.8.in    | 12 ++++++++++++
 3 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index a96db83..3035741 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -278,6 +278,7 @@ enum rt_scope_t {
 #define RTM_F_EQUALIZE		0x400	/* Multipath equalizer: NI	*/
 #define RTM_F_PREFIX		0x800	/* Prefix addresses		*/
 #define RTM_F_LOOKUP_TABLE	0x1000	/* set rtm_table to FIB lookup result */
+#define RTM_F_FIB_MATCH		0x2000	/* get fib match support */
 
 /* Reserved table identifiers */
 
diff --git a/ip/iproute.c b/ip/iproute.c
index b4ca291..1b9c903 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -65,7 +65,8 @@ static void usage(void)
 	fprintf(stderr, "       ip route save SELECTOR\n");
 	fprintf(stderr, "       ip route restore\n");
 	fprintf(stderr, "       ip route showdump\n");
-	fprintf(stderr, "       ip route get ADDRESS [ from ADDRESS iif STRING ]\n");
+	fprintf(stderr, "       ip route get [ ROUTE_GET_FLAGS ] ADDRESS\n");
+	fprintf(stderr, "                            [ from ADDRESS iif STRING ]\n");
 	fprintf(stderr, "                            [ oif STRING ] [ tos TOS ]\n");
 	fprintf(stderr, "                            [ mark NUMBER ] [ vrf NAME ]\n");
 	fprintf(stderr, "                            [ uid NUMBER ]\n");
@@ -103,6 +104,7 @@ static void usage(void)
 	fprintf(stderr, "ENCAPHDR := [ MPLSLABEL | SEG6HDR ]\n");
 	fprintf(stderr, "SEG6HDR := [ mode SEGMODE ] segs ADDR1,ADDRi,ADDRn [hmac HMACKEYID] [cleanup]\n");
 	fprintf(stderr, "SEGMODE := [ encap | inline ]\n");
+	fprintf(stderr, "ROUTE_GET_FLAGS := [ fibmatch ]\n");
 	exit(-1);
 }
 
@@ -1674,6 +1676,7 @@ static int iproute_get(int argc, char **argv)
 	char  *idev = NULL;
 	char  *odev = NULL;
 	int connected = 0;
+	int fib_match = 0;
 	int from_ok = 0;
 	unsigned int mark = 0;
 
@@ -1728,6 +1731,8 @@ static int iproute_get(int argc, char **argv)
 			if (get_unsigned(&uid, *argv, 0))
 				invarg("invalid UID\n", *argv);
 			addattr32(&req.n, sizeof(req), RTA_UID, uid);
+		} else if (matches(*argv, "fibmatch") == 0) {
+			fib_match = 1;
 		} else {
 			inet_prefix addr;
 
@@ -1776,6 +1781,8 @@ static int iproute_get(int argc, char **argv)
 		req.r.rtm_family = AF_INET;
 
 	req.r.rtm_flags |= RTM_F_LOOKUP_TABLE;
+	if (fib_match)
+		req.r.rtm_flags |= RTM_F_FIB_MATCH;
 
 	if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0)
 		return -2;
diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index c8eb38a..de8d360 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -28,6 +28,7 @@ ip-route \- routing table management
 
 .ti -8
 .B  ip route get
+.I ROUTE_GET_FLAGS
 .IR ADDRESS " [ "
 .BI from " ADDRESS " iif " STRING"
 .RB " ] [ " oif
@@ -219,6 +220,12 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
 .B hmac
 .IR KEYID " ]"
 
+.ti -8
+.IR ROUTE_GET_FLAGS " := "
+.BR " [ "
+.BR fibmatch
+.BR " ] "
+
 .SH DESCRIPTION
 .B ip route
 is used to manipulate entries in the kernel routing tables.
@@ -930,6 +937,11 @@ this command gets a single route to a destination and prints its
 contents exactly as the kernel sees it.
 
 .TP
+.BI fibmatch
+Return full fib lookup matched route. Default is to return the resolved
+dst entry
+
+.TP
 .BI to " ADDRESS " (default)
 the destination address.
 
-- 
2.1.4
