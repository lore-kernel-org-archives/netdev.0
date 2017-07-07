From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH iproute2] ip: change flag names to an array
Date: Fri,  7 Jul 2017 08:39:41 -0700
Message-ID: <20170707153941.5427-1-stephen@networkplumber.org>
Cc: lorenzo@google.com, Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36475 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751023AbdGGPju (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 11:39:50 -0400
Received: by mail-pf0-f177.google.com with SMTP id q86so18881472pfl.3
        for <netdev@vger.kernel.org>; Fri, 07 Jul 2017 08:39:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the most of the address flags, use a table of bit values rather
than open coding every value.  This allows for easier inevitable
expansion of flags.

This also fixes the missing stable-privacy flag.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 ip/ipaddress.c | 152 ++++++++++++++++++++++++---------------------------------
 1 file changed, 65 insertions(+), 87 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index f06f5829fb61..b4efb9fedcd2 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1013,14 +1013,67 @@ static unsigned int get_ifa_flags(struct ifaddrmsg *ifa,
 				ifa->ifa_flags;
 }
 
+
+static const char *ifa_flag_names[] = {
+	"secondary",
+	"nodad",
+	"optimistic",
+	"dadfailed",
+	"home",
+	"deprecated",
+	"tentative",
+	"permanent",
+	"mngtmpaddr",
+	"noprefixroute",
+	"autojoin",
+	"stable-privacy",
+};
+
+static void print_ifa_flags(FILE *fp, const struct ifaddrmsg *ifa, unsigned int flags)
+{
+	unsigned int i;
+
+	for (i = 0; i < ARRAY_SIZE(ifa_flag_names); i++) {
+		unsigned int mask = 1u << i;
+
+		if (mask == IFA_F_PERMANENT) {
+			if (!(flags & mask))
+				fprintf(fp, "dynamic ");
+		} else if (flags & mask) {
+			if (mask == IFA_F_SECONDARY) {
+				if (ifa->ifa_family == AF_INET6)
+					fprintf(fp, "temporary ");
+				else
+					fprintf(fp, "secondary ");
+			} else
+				fprintf(fp, "%s ", ifa_flag_names[i]);
+		}
+
+		flags &= ~mask;
+	}
+
+	if (flags)
+		fprintf(fp, "flags %02x ", flags);
+
+}
+
+static unsigned int get_ifa_flag_mask(const char *name)
+{
+	unsigned int i;
+
+	for (i = 0; i < ARRAY_SIZE(ifa_flag_names); i++) {
+		if (!strcmp(name, ifa_flag_names[i]))
+			return 1u << i;
+	}
+	return 0;
+}
+
 int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		   void *arg)
 {
 	FILE *fp = arg;
 	struct ifaddrmsg *ifa = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
-	int deprecated = 0;
-	/* Use local copy of ifa_flags to not interfere with filtering code */
 	unsigned int ifa_flags;
 	struct rtattr *rta_tb[IFA_MAX+1];
 
@@ -1040,6 +1093,7 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	parse_rtattr(rta_tb, IFA_MAX, IFA_RTA(ifa),
 		     n->nlmsg_len - NLMSG_LENGTH(sizeof(*ifa)));
 
+
 	ifa_flags = get_ifa_flags(ifa, rta_tb[IFA_FLAGS]);
 
 	if (!rta_tb[IFA_LOCAL])
@@ -1145,52 +1199,9 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 					      rta_tb[IFA_ANYCAST]));
 	}
 	fprintf(fp, "scope %s ", rtnl_rtscope_n2a(ifa->ifa_scope, b1, sizeof(b1)));
-	if (ifa_flags & IFA_F_SECONDARY) {
-		ifa_flags &= ~IFA_F_SECONDARY;
-		if (ifa->ifa_family == AF_INET6)
-			fprintf(fp, "temporary ");
-		else
-			fprintf(fp, "secondary ");
-	}
-	if (ifa_flags & IFA_F_TENTATIVE) {
-		ifa_flags &= ~IFA_F_TENTATIVE;
-		fprintf(fp, "tentative ");
-	}
-	if (ifa_flags & IFA_F_DEPRECATED) {
-		ifa_flags &= ~IFA_F_DEPRECATED;
-		deprecated = 1;
-		fprintf(fp, "deprecated ");
-	}
-	if (ifa_flags & IFA_F_HOMEADDRESS) {
-		ifa_flags &= ~IFA_F_HOMEADDRESS;
-		fprintf(fp, "home ");
-	}
-	if (ifa_flags & IFA_F_NODAD) {
-		ifa_flags &= ~IFA_F_NODAD;
-		fprintf(fp, "nodad ");
-	}
-	if (ifa_flags & IFA_F_MANAGETEMPADDR) {
-		ifa_flags &= ~IFA_F_MANAGETEMPADDR;
-		fprintf(fp, "mngtmpaddr ");
-	}
-	if (ifa_flags & IFA_F_NOPREFIXROUTE) {
-		ifa_flags &= ~IFA_F_NOPREFIXROUTE;
-		fprintf(fp, "noprefixroute ");
-	}
-	if (ifa_flags & IFA_F_MCAUTOJOIN) {
-		ifa_flags &= ~IFA_F_MCAUTOJOIN;
-		fprintf(fp, "autojoin ");
-	}
-	if (!(ifa_flags & IFA_F_PERMANENT))
-		fprintf(fp, "dynamic ");
-	else
-		ifa_flags &= ~IFA_F_PERMANENT;
-	if (ifa_flags & IFA_F_DADFAILED) {
-		ifa_flags &= ~IFA_F_DADFAILED;
-		fprintf(fp, "dadfailed ");
-	}
-	if (ifa_flags)
-		fprintf(fp, "flags %02x ", ifa_flags);
+
+	print_ifa_flags(fp, ifa, ifa_flags);
+
 	if (rta_tb[IFA_LABEL])
 		fprintf(fp, "%s", rta_getattr_str(rta_tb[IFA_LABEL]));
 	if (rta_tb[IFA_CACHEINFO]) {
@@ -1206,7 +1217,7 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		if (ci->ifa_prefered == INFINITY_LIFE_TIME)
 			fprintf(fp, "forever");
 		else {
-			if (deprecated)
+			if (ifa_flags & IFA_F_DEPRECATED)
 				fprintf(fp, "%dsec", ci->ifa_prefered);
 			else
 				fprintf(fp, "%usec", ci->ifa_prefered);
@@ -1570,6 +1581,7 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 	struct nlmsg_chain _ainfo = { NULL, NULL}, *ainfo = NULL;
 	struct nlmsg_list *l;
 	char *filter_dev = NULL;
+	unsigned int mask;
 	int no_link = 0;
 
 	ipaddr_reset_filter(oneline, 0);
@@ -1612,49 +1624,15 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 		} else if (strcmp(*argv, "dynamic") == 0) {
 			filter.flags &= ~IFA_F_PERMANENT;
 			filter.flagmask |= IFA_F_PERMANENT;
-		} else if (strcmp(*argv, "permanent") == 0) {
-			filter.flags |= IFA_F_PERMANENT;
-			filter.flagmask |= IFA_F_PERMANENT;
-		} else if (strcmp(*argv, "secondary") == 0 ||
-			   strcmp(*argv, "temporary") == 0) {
+		} else if (strcmp(*argv, "temporary") == 0) {
 			filter.flags |= IFA_F_SECONDARY;
 			filter.flagmask |= IFA_F_SECONDARY;
 		} else if (strcmp(*argv, "primary") == 0) {
 			filter.flags &= ~IFA_F_SECONDARY;
 			filter.flagmask |= IFA_F_SECONDARY;
-		} else if (strcmp(*argv, "tentative") == 0) {
-			filter.flags |= IFA_F_TENTATIVE;
-			filter.flagmask |= IFA_F_TENTATIVE;
-		} else if (strcmp(*argv, "-tentative") == 0) {
-			filter.flags &= ~IFA_F_TENTATIVE;
-			filter.flagmask |= IFA_F_TENTATIVE;
-		} else if (strcmp(*argv, "deprecated") == 0) {
-			filter.flags |= IFA_F_DEPRECATED;
-			filter.flagmask |= IFA_F_DEPRECATED;
-		} else if (strcmp(*argv, "-deprecated") == 0) {
-			filter.flags &= ~IFA_F_DEPRECATED;
-			filter.flagmask |= IFA_F_DEPRECATED;
-		} else if (strcmp(*argv, "home") == 0) {
-			filter.flags |= IFA_F_HOMEADDRESS;
-			filter.flagmask |= IFA_F_HOMEADDRESS;
-		} else if (strcmp(*argv, "nodad") == 0) {
-			filter.flags |= IFA_F_NODAD;
-			filter.flagmask |= IFA_F_NODAD;
-		} else if (strcmp(*argv, "mngtmpaddr") == 0) {
-			filter.flags |= IFA_F_MANAGETEMPADDR;
-			filter.flagmask |= IFA_F_MANAGETEMPADDR;
-		} else if (strcmp(*argv, "noprefixroute") == 0) {
-			filter.flags |= IFA_F_NOPREFIXROUTE;
-			filter.flagmask |= IFA_F_NOPREFIXROUTE;
-		} else if (strcmp(*argv, "autojoin") == 0) {
-			filter.flags |= IFA_F_MCAUTOJOIN;
-			filter.flagmask |= IFA_F_MCAUTOJOIN;
-		} else if (strcmp(*argv, "dadfailed") == 0) {
-			filter.flags |= IFA_F_DADFAILED;
-			filter.flagmask |= IFA_F_DADFAILED;
-		} else if (strcmp(*argv, "-dadfailed") == 0) {
-			filter.flags &= ~IFA_F_DADFAILED;
-			filter.flagmask |= IFA_F_DADFAILED;
+		} else if ((mask = get_ifa_flag_mask(*argv)) != 0) {
+			filter.flags |= mask;
+			filter.flagmask |= mask;
 		} else if (strcmp(*argv, "label") == 0) {
 			NEXT_ARG();
 			filter.label = *argv;
-- 
2.11.0
