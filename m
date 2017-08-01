From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH iproute2 v2] ip: change flag names to an array
Date: Tue,  1 Aug 2017 08:38:42 -0700
Message-ID: <20170801153842.5991-1-stephen@networkplumber.org>
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:38323 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751670AbdHAPis (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 11:38:48 -0400
Received: by mail-pg0-f48.google.com with SMTP id l64so9342111pge.5
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 08:38:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the most of the address flags, use a table of values rather
than open coding every value.  This allows for easier inevitable
expansion of flags.

This also fixes the missing stable-privacy flag.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
v2 - use name/value table rather than assuming order
     handle negative masks "-deprecated"

 ip/ipaddress.c | 184 ++++++++++++++++++++++++++++-----------------------------
 1 file changed, 89 insertions(+), 95 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index cf8ef8186f52..4d37c5e04507 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1012,14 +1012,95 @@ static unsigned int get_ifa_flags(struct ifaddrmsg *ifa,
 				ifa->ifa_flags;
 }
 
+/* Mapping from argument to address flag mask */
+struct {
+	const char *name;
+	unsigned long value;
+} ifa_flag_names[] = {
+	{ "secondary",		IFA_F_SECONDARY },
+	{ "temporary",		IFA_F_SECONDARY },
+	{ "nodad",		IFA_F_NODAD },
+	{ "optimistic",		IFA_F_OPTIMISTIC },
+	{ "dadfailed",		IFA_F_DADFAILED },
+	{ "home",		IFA_F_HOMEADDRESS },
+	{ "deprecated",		IFA_F_DEPRECATED },
+	{ "tentative",		IFA_F_TENTATIVE },
+	{ "permanent",		IFA_F_PERMANENT },
+	{ "mngtmpaddr",		IFA_F_MANAGETEMPADDR },
+	{ "noprefixroute",	IFA_F_NOPREFIXROUTE },
+	{ "autojoin",		IFA_F_MCAUTOJOIN },
+	{ "stable-privacy",	IFA_F_STABLE_PRIVACY },
+};
+
+static void print_ifa_flags(FILE *fp, const struct ifaddrmsg *ifa,
+			    unsigned int flags)
+{
+	unsigned int i;
+
+	for (i = 0; i < ARRAY_SIZE(ifa_flag_names); i++) {
+		unsigned long mask = ifa_flag_names[i].value;
+
+		if (mask == IFA_F_PERMANENT) {
+			if (!(flags & mask))
+				fprintf(fp, "dynamic ");
+		} else if (flags & mask) {
+			if (mask == IFA_F_SECONDARY &&
+			    ifa->ifa_family == AF_INET6)
+				fprintf(fp, "temporary ");
+			else
+				fprintf(fp, "%s ", ifa_flag_names[i].name);
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
+static int get_filter(const char *arg)
+{
+	unsigned int i;
+
+	/* Special cases */
+	if (strcmp(arg, "dynamic") == 0) {
+		filter.flags &= ~IFA_F_PERMANENT;
+		filter.flagmask |= IFA_F_PERMANENT;
+	} else if (strcmp(arg, "primary") == 0) {
+		filter.flags &= ~IFA_F_SECONDARY;
+		filter.flagmask |= IFA_F_SECONDARY;
+	} else if (*arg == '-') {
+		for (i = 0; i < ARRAY_SIZE(ifa_flag_names); i++) {
+			if (strcmp(arg + 1, ifa_flag_names[i].name))
+				continue;
+
+			filter.flags &= ifa_flag_names[i].value;
+			filter.flagmask |= ifa_flag_names[i].value;
+			return 0;
+		}
+
+		return -1;
+	} else {
+		for (i = 0; i < ARRAY_SIZE(ifa_flag_names); i++) {
+			if (strcmp(arg, ifa_flag_names[i].name))
+				continue;
+			filter.flags |= ifa_flag_names[i].value;
+			filter.flagmask |= ifa_flag_names[i].value;
+			return 0;
+		}
+		return -1;
+	}
+
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
 
@@ -1144,52 +1225,9 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
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
@@ -1205,7 +1243,7 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		if (ci->ifa_prefered == INFINITY_LIFE_TIME)
 			fprintf(fp, "forever");
 		else {
-			if (deprecated)
+			if (ifa_flags & IFA_F_DEPRECATED)
 				fprintf(fp, "%dsec", ci->ifa_prefered);
 			else
 				fprintf(fp, "%usec", ci->ifa_prefered);
@@ -1608,52 +1646,8 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 			filter.scope = scope;
 		} else if (strcmp(*argv, "up") == 0) {
 			filter.up = 1;
-		} else if (strcmp(*argv, "dynamic") == 0) {
-			filter.flags &= ~IFA_F_PERMANENT;
-			filter.flagmask |= IFA_F_PERMANENT;
-		} else if (strcmp(*argv, "permanent") == 0) {
-			filter.flags |= IFA_F_PERMANENT;
-			filter.flagmask |= IFA_F_PERMANENT;
-		} else if (strcmp(*argv, "secondary") == 0 ||
-			   strcmp(*argv, "temporary") == 0) {
-			filter.flags |= IFA_F_SECONDARY;
-			filter.flagmask |= IFA_F_SECONDARY;
-		} else if (strcmp(*argv, "primary") == 0) {
-			filter.flags &= ~IFA_F_SECONDARY;
-			filter.flagmask |= IFA_F_SECONDARY;
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
+		} else if (get_filter(*argv) == 0) {
+
 		} else if (strcmp(*argv, "label") == 0) {
 			NEXT_ARG();
 			filter.label = *argv;
-- 
2.11.0
