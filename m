From: Krister Johansen <kjlx@templeofstupid.com>
Subject: [PATCH iproute/master 2/3] iptunnel: add support for mpls/ip to sit tunnels
Date: Fri,  9 Jun 2017 18:31:31 -0700
Message-ID: <1497058292-10099-3-git-send-email-kjlx@templeofstupid.com>
References: <1497058292-10099-1-git-send-email-kjlx@templeofstupid.com>
Cc: netdev@vger.kernel.org, simon.horman@netronome.com,
        dsahern@gmail.com, Krister Johansen <kjlx@templeofstupid.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub5.mail.dreamhost.com ([208.113.200.129]:56411 "EHLO
        homiemail-a48.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751707AbdFJBcS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 21:32:18 -0400
Received: from homiemail-a48.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a48.g.dreamhost.com (Postfix) with ESMTP id EF2F870D2B0F
        for <netdev@vger.kernel.org>; Fri,  9 Jun 2017 18:32:17 -0700 (PDT)
Received: from kmjvbox (c-174-62-91-145.hsd1.ca.comcast.net [174.62.91.145])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a48.g.dreamhost.com (Postfix) with ESMTPSA id D6BB670D2B04
        for <netdev@vger.kernel.org>; Fri,  9 Jun 2017 18:32:17 -0700 (PDT)
In-Reply-To: <1497058292-10099-1-git-send-email-kjlx@templeofstupid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Original-Author: Simon Horman <simon.horman@netronome.com>
Signed-off-by: Krister Johansen <kjlx@templeofstupid.com>
---
 include/utils.h       | 3 +++
 ip/link_iptnl.c       | 9 ++++++---
 ip/tunnel.c           | 3 +++
 man/man8/ip-link.8.in | 9 +++++----
 4 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index bfbc9e6..60ffde4 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -87,6 +87,9 @@ struct ipx_addr {
 #ifndef AF_MPLS
 # define AF_MPLS 28
 #endif
+#ifndef IPPROTO_MPLS
+#define IPPROTO_MPLS	137
+#endif
 
 __u32 get_addr32(const char *name);
 int get_addr_1(inet_prefix *dst, const char *arg, int family);
diff --git a/ip/link_iptnl.c b/ip/link_iptnl.c
index 2f74d9b..cf3a9ef 100644
--- a/ip/link_iptnl.c
+++ b/ip/link_iptnl.c
@@ -16,6 +16,7 @@
 #include <sys/socket.h>
 #include <arpa/inet.h>
 
+#include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/if_tunnel.h>
 #include "rt_names.h"
@@ -47,9 +48,8 @@ static void print_usage(FILE *f, int sit)
 		type
 	);
 	if (sit) {
-		fprintf(f,
-			"                [ mode { ip6ip | ipip | any } ]\n"
-			"                [ isatap ]\n");
+		fprintf(f, "          [ mode { ip6ip | ipip | mplsip | any } ]\n");
+		fprintf(f, "          [ isatap ]\n");
 	}
 	fprintf(f, "                [ external ]\n");
 	fprintf(f, "                [ fwmark MARK ]\n");
@@ -243,6 +243,9 @@ get_failed:
 				 strcmp(*argv, "ipip") == 0 ||
 				 strcmp(*argv, "ip4ip4") == 0)
 				proto = IPPROTO_IPIP;
+			else if (strcmp(*argv, "mpls/ipv4") == 0 ||
+				   strcmp(*argv, "mplsip") == 0)
+				proto = IPPROTO_MPLS;
 			else if (strcmp(*argv, "any/ipv4") == 0 ||
 				 strcmp(*argv, "any") == 0)
 				proto = 0;
diff --git a/ip/tunnel.c b/ip/tunnel.c
index 7956d71..d359eb9 100644
--- a/ip/tunnel.c
+++ b/ip/tunnel.c
@@ -54,6 +54,9 @@ const char *tnl_strproto(__u8 proto)
 	case IPPROTO_ESP:
 		strcpy(buf, "esp");
 		break;
+	case IPPROTO_MPLS:
+		strcpy(buf, "mpls");
+		break;
 	case 0:
 		strcpy(buf, "any");
 		break;
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 3cc2f5d..994b539 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -662,7 +662,7 @@ the following additional arguments are supported:
 ] [
 .I " [no]encap-remcsum "
 ] [
-.I " mode " { ip6ip | ipip | any } "
+.I " mode " { ip6ip | ipip | mplsip | any } "
 ]
 
 .in +8
@@ -700,10 +700,11 @@ encapsulation.
 applicable for Generic UDP Encapsulation.
 
 .sp
-.BI mode " { ip6ip | ipip | any } "
+.BI mode " { ip6ip | ipip | mplsip | any } "
 - specifies mode in which device should run. "ip6ip" indicates
-IPv6-Over-IPv4, "ipip" indicates "IPv4-Over-IPv4", "any" indicates either
-IPv6 or IPv4 Over IPv4. Only supported for SIT where the default is "ip6ip".
+IPv6-Over-IPv4, "ipip" indicates "IPv4-Over-IPv4", "mplsip" indicates
+MPLS-Over-IPv4, "any" indicates IPv6, IPv4 or MPLS Over IPv4. Only
+supported for SIT where the default is "ip6ip".
 
 .in -8
 
-- 
2.7.4
