From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH iproute2] ip: add support for IFA_F_DADFAILED
Date: Mon, 14 Sep 2009 17:00:23 -0400
Message-ID: <4AAEAEE7.4090507@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:11796 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073AbZINVAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 17:00:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[I'm not sure if I needed to update if_addr.h, or if that will happen
 automatically when you update the headers to 2.6.32]


Add support for IFA_F_DADFAILED and update ip.8 man page.

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

diff --git a/include/linux/if_addr.h b/include/linux/if_addr.h
index 08ea980..41b0193 100644
--- a/include/linux/if_addr.h
+++ b/include/linux/if_addr.h
@@ -41,6 +41,7 @@ enum
 
 #define	IFA_F_NODAD		0x02
 #define IFA_F_OPTIMISTIC	0x04
+#define IFA_F_DADFAILED		0x08
 #define	IFA_F_HOMEADDRESS	0x10
 #define IFA_F_DEPRECATED	0x20
 #define IFA_F_TENTATIVE		0x40
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 267ecb3..32c9008 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -64,7 +64,7 @@ static void usage(void)
 		iplink_usage();
 	}
 	fprintf(stderr, "Usage: ip addr {add|change|replace} IFADDR dev STRING [ LIFETIME ]\n");
-	fprintf(stderr, "                                                      [ CONFFLAG-LIST]\n");
+	fprintf(stderr, "                                                      [ CONFFLAG-LIST ]\n");
 	fprintf(stderr, "       ip addr del IFADDR dev STRING\n");
 	fprintf(stderr, "       ip addr {show|flush} [ dev STRING ] [ scope SCOPE-ID ]\n");
 	fprintf(stderr, "                            [ to PREFIX ] [ FLAG-LIST ] [ label PATTERN ]\n");
@@ -74,7 +74,8 @@ static void usage(void)
 	fprintf(stderr, "SCOPE-ID := [ host | link | global | NUMBER ]\n");
 	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] FLAG\n");
 	fprintf(stderr, "FLAG  := [ permanent | dynamic | secondary | primary |\n");
-	fprintf(stderr, "           tentative | deprecated | CONFFLAG-LIST ]\n");
+	fprintf(stderr, "           tentative | deprecated | dadfailed |\n");
+	fprintf(stderr, "           CONFFLAG-LIST ]\n");
 	fprintf(stderr, "CONFFLAG-LIST := [ CONFFLAG-LIST ] CONFFLAG\n");
 	fprintf(stderr, "CONFFLAG  := [ home | nodad ]\n");
 	fprintf(stderr, "LIFETIME := [ valid_lft LFT ] [ preferred_lft LFT ]\n");
@@ -508,6 +509,10 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		fprintf(fp, "dynamic ");
 	} else
 		ifa->ifa_flags &= ~IFA_F_PERMANENT;
+	if (ifa->ifa_flags&IFA_F_DADFAILED) {
+		ifa->ifa_flags &= ~IFA_F_DADFAILED;
+		fprintf(fp, "dadfailed ");
+	}
 	if (ifa->ifa_flags)
 		fprintf(fp, "flags %02x ", ifa->ifa_flags);
 	if (rta_tb[IFA_LABEL])
@@ -655,6 +660,9 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
 		} else if (strcmp(*argv, "nodad") == 0) {
 			filter.flags |= IFA_F_NODAD;
 			filter.flagmask |= IFA_F_NODAD;
+		} else if (strcmp(*argv, "dadfailed") == 0) {
+			filter.flags |= IFA_F_DADFAILED;
+			filter.flagmask |= IFA_F_DADFAILED;
 		} else if (strcmp(*argv, "label") == 0) {
 			NEXT_ARG();
 			filter.label = *argv;
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index a8fccc4..1145b28 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -97,7 +97,7 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 .ti -8
 .IR FLAG " := "
 .RB "[ " permanent " | " dynamic " | " secondary " | " primary " | "\
-tentative " | " deprecated " ]"
+tentative " | " deprecated " | " dadfailed " ]"
 
 .ti -8
 .BR "ip addrlabel" " { " add " | " del " } " prefix
@@ -1030,7 +1030,7 @@ addresses.
 
 .TP
 .B tentative
-(IPv6 only) only list addresses which did not pass duplicate
+(IPv6 only) only list addresses which have not yet passed duplicate
 address detection.
 
 .TP
@@ -1038,6 +1038,11 @@ address detection.
 (IPv6 only) only list deprecated addresses.
 
 .TP
+.B dadfailed
+(IPv6 only) only list addresses which have failed duplicate
+address detection.
+
+.TP
 .BR primary " and " secondary
 only list primary (or secondary) addresses.
 
