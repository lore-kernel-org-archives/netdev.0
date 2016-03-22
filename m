From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/7] ipaddress: colorize peer, broadcast and anycast addresses as well
Date: Tue, 22 Mar 2016 19:35:14 +0100
Message-ID: <1458671719-14361-3-git-send-email-phil@nwl.cc>
References: <1458671719-14361-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:52024 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751364AbcCVSgK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 14:36:10 -0400
In-Reply-To: <1458671719-14361-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipaddress.c | 31 +++++++++++++++++--------------
 1 file changed, 17 insertions(+), 14 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 7aab8e781eae8..90d7b1096c3aa 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -862,7 +862,8 @@ int print_linkinfo(const struct sockaddr_nl *who,
 				fprintf(fp, " peer ");
 			else
 				fprintf(fp, " brd ");
-			fprintf(fp, "%s", ll_addr_n2a(RTA_DATA(tb[IFLA_BROADCAST]),
+			color_fprintf(fp, COLOR_MAC, "%s",
+					ll_addr_n2a(RTA_DATA(tb[IFLA_BROADCAST]),
 						      RTA_PAYLOAD(tb[IFLA_BROADCAST]),
 						      ifi->ifi_type,
 						      b1, sizeof(b1)));
@@ -1062,32 +1063,34 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		                          RTA_PAYLOAD(rta_tb[IFA_LOCAL]),
 		                          RTA_DATA(rta_tb[IFA_LOCAL]),
 		                          abuf, sizeof(abuf)));
-		if (rta_tb[IFA_ADDRESS] == NULL ||
-		    memcmp(RTA_DATA(rta_tb[IFA_ADDRESS]), RTA_DATA(rta_tb[IFA_LOCAL]),
-			   ifa->ifa_family == AF_INET ? 4 : 16) == 0) {
-			fprintf(fp, "/%d ", ifa->ifa_prefixlen);
-		} else {
-			fprintf(fp, " peer %s/%d ",
-				format_host(ifa->ifa_family,
-					    RTA_PAYLOAD(rta_tb[IFA_ADDRESS]),
-					    RTA_DATA(rta_tb[IFA_ADDRESS]),
-					    abuf, sizeof(abuf)),
-				ifa->ifa_prefixlen);
+		if (rta_tb[IFA_ADDRESS] &&
+		    memcmp(RTA_DATA(rta_tb[IFA_ADDRESS]),
+		           RTA_DATA(rta_tb[IFA_LOCAL]),
+		           ifa->ifa_family == AF_INET ? 4 : 16)) {
+			fprintf(fp, " peer ");
+			color_fprintf(fp, ifa_family_color(ifa->ifa_family),
+			              "%s", format_host(ifa->ifa_family,
+			              RTA_PAYLOAD(rta_tb[IFA_ADDRESS]),
+			              RTA_DATA(rta_tb[IFA_ADDRESS]),
+			              abuf, sizeof(abuf)));
 		}
+		fprintf(fp, "/%d ", ifa->ifa_prefixlen);
 	}
 
 	if (brief)
 		goto brief_exit;
 
 	if (rta_tb[IFA_BROADCAST]) {
-		fprintf(fp, "brd %s ",
+		fprintf(fp, "brd ");
+		color_fprintf(fp, ifa_family_color(ifa->ifa_family), "%s ",
 			format_host(ifa->ifa_family,
 				    RTA_PAYLOAD(rta_tb[IFA_BROADCAST]),
 				    RTA_DATA(rta_tb[IFA_BROADCAST]),
 				    abuf, sizeof(abuf)));
 	}
 	if (rta_tb[IFA_ANYCAST]) {
-		fprintf(fp, "any %s ",
+		fprintf(fp, "any ");
+		color_fprintf(fp, ifa_family_color(ifa->ifa_family), "%s ",
 			format_host(ifa->ifa_family,
 				    RTA_PAYLOAD(rta_tb[IFA_ANYCAST]),
 				    RTA_DATA(rta_tb[IFA_ANYCAST]),
-- 
2.7.2
