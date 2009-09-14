From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH iproute2] ip: print "temporary" for IPv6 temp addresses
Date: Mon, 14 Sep 2009 17:01:43 -0400
Message-ID: <4AAEAF37.7020305@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:29488 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755817AbZINVBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 17:01:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 addresses that have IFA_F_SECONDARY set are actually temporary addresses,
hence the IFA_F_TEMPORARY equivalent.  Change the output in this case and
allow filtering on the word "temporary".

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 32c9008..8492fa8 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -74,7 +74,7 @@ static void usage(void)
 	fprintf(stderr, "SCOPE-ID := [ host | link | global | NUMBER ]\n");
 	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] FLAG\n");
 	fprintf(stderr, "FLAG  := [ permanent | dynamic | secondary | primary |\n");
-	fprintf(stderr, "           tentative | deprecated | dadfailed |\n");
+	fprintf(stderr, "           tentative | deprecated | dadfailed | temporary |\n");
 	fprintf(stderr, "           CONFFLAG-LIST ]\n");
 	fprintf(stderr, "CONFFLAG-LIST := [ CONFFLAG-LIST ] CONFFLAG\n");
 	fprintf(stderr, "CONFFLAG  := [ home | nodad ]\n");
@@ -486,7 +486,10 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	fprintf(fp, "scope %s ", rtnl_rtscope_n2a(ifa->ifa_scope, b1, sizeof(b1)));
 	if (ifa->ifa_flags&IFA_F_SECONDARY) {
 		ifa->ifa_flags &= ~IFA_F_SECONDARY;
-		fprintf(fp, "secondary ");
+		if (ifa->ifa_family == AF_INET6)
+			fprintf(fp, "temporary ");
+		else
+			fprintf(fp, "secondary ");
 	}
 	if (ifa->ifa_flags&IFA_F_TENTATIVE) {
 		ifa->ifa_flags &= ~IFA_F_TENTATIVE;
@@ -642,7 +645,8 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
 		} else if (strcmp(*argv, "permanent") == 0) {
 			filter.flags |= IFA_F_PERMANENT;
 			filter.flagmask |= IFA_F_PERMANENT;
-		} else if (strcmp(*argv, "secondary") == 0) {
+		} else if (strcmp(*argv, "secondary") == 0 ||
+			   strcmp(*argv, "temporary") == 0) {
 			filter.flags |= IFA_F_SECONDARY;
 			filter.flagmask |= IFA_F_SECONDARY;
 		} else if (strcmp(*argv, "primary") == 0) {
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 1145b28..24a3812 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -97,7 +97,7 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 .ti -8
 .IR FLAG " := "
 .RB "[ " permanent " | " dynamic " | " secondary " | " primary " | "\
-tentative " | " deprecated " | " dadfailed " ]"
+tentative " | " deprecated " | " dadfailed " | " temporary " ]"
 
 .ti -8
 .BR "ip addrlabel" " { " add " | " del " } " prefix
@@ -1043,6 +1043,10 @@ address detection.
 address detection.
 
 .TP
+.B temporary
+(IPv6 only) only list temporary addresses.
+
+.TP
 .BR primary " and " secondary
 only list primary (or secondary) addresses.
 
