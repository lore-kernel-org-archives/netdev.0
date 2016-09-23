From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCHv2 iproute2 2/2] ip rule: add selector support
Date: Fri, 23 Sep 2016 11:25:55 +0800
Message-ID: <1474601155-28171-3-git-send-email-liuhangbin@gmail.com>
References: <1474601155-28171-1-git-send-email-liuhangbin@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Phil Sutter <phil@nwl.cc>, Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35213 "EHLO
        mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932633AbcIWD00 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 23:26:26 -0400
Received: by mail-pa0-f48.google.com with SMTP id oz2so35500335pac.2
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 20:26:25 -0700 (PDT)
In-Reply-To: <1474601155-28171-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 ip/iprule.c        | 180 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 man/man8/ip-rule.8 |   6 +-
 2 files changed, 180 insertions(+), 6 deletions(-)

diff --git a/ip/iprule.c b/ip/iprule.c
index e18505f..42fb6af 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -20,6 +20,7 @@
 #include <netinet/ip.h>
 #include <arpa/inet.h>
 #include <string.h>
+#include <linux/if.h>
 #include <linux/fib_rules.h>
 #include <errno.h>
 
@@ -41,7 +42,7 @@ static void usage(void)
 {
 	fprintf(stderr, "Usage: ip rule { add | del } SELECTOR ACTION\n");
 	fprintf(stderr, "       ip rule { flush | save | restore }\n");
-	fprintf(stderr, "       ip rule [ list ]\n");
+	fprintf(stderr, "       ip rule [ list [ SELECTOR ]]\n");
 	fprintf(stderr, "SELECTOR := [ not ] [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark FWMARK[/MASK] ]\n");
 	fprintf(stderr, "            [ iif STRING ] [ oif STRING ] [ pref NUMBER ] [ l3mdev ]\n");
 	fprintf(stderr, "ACTION := [ table TABLE_ID ]\n");
@@ -55,6 +56,105 @@ static void usage(void)
 	exit(-1);
 }
 
+static struct
+{
+	int not;
+	int l3mdev;
+	int iifmask, oifmask;
+	unsigned int tb;
+	unsigned int tos, tosmask;
+	unsigned int pref, prefmask;
+	unsigned int fwmark, fwmask;
+	char iif[IFNAMSIZ];
+	char oif[IFNAMSIZ];
+	inet_prefix src;
+	inet_prefix dst;
+} filter;
+
+static bool filter_nlmsg(struct nlmsghdr *n, struct rtattr **tb, int host_len)
+{
+	struct rtmsg *r = NLMSG_DATA(n);
+	inet_prefix src = { .family = r->rtm_family };
+	inet_prefix dst = { .family = r->rtm_family };
+	__u32 table;
+
+	if (preferred_family != AF_UNSPEC && r->rtm_family != preferred_family)
+		return false;
+
+	if (filter.prefmask &&
+	    filter.pref ^ (tb[FRA_PRIORITY] ? rta_getattr_u32(tb[FRA_PRIORITY]) : 0))
+		return false;
+	if (filter.not && !(r->rtm_flags & FIB_RULE_INVERT))
+		return false;
+
+	if (filter.src.family) {
+		if (tb[FRA_SRC]) {
+			memcpy(&src.data, RTA_DATA(tb[FRA_SRC]),
+			       (r->rtm_src_len + 7) / 8);
+		}
+		if (filter.src.family != r->rtm_family ||
+		    filter.src.bitlen > r->rtm_src_len ||
+		    inet_addr_match(&src, &filter.src, filter.src.bitlen))
+			return false;
+	}
+
+	if (filter.dst.family) {
+		if (tb[FRA_DST]) {
+			memcpy(&dst.data, RTA_DATA(tb[FRA_DST]),
+			       (r->rtm_dst_len + 7) / 8);
+		}
+		if (filter.dst.family != r->rtm_family ||
+		    filter.dst.bitlen > r->rtm_dst_len ||
+		    inet_addr_match(&dst, &filter.dst, filter.dst.bitlen))
+			return false;
+	}
+
+	if (filter.tosmask && filter.tos ^ r->rtm_tos)
+		return false;
+
+	if (filter.fwmark) {
+		__u32 mark = 0;
+		if (tb[FRA_FWMARK])
+			mark = rta_getattr_u32(tb[FRA_FWMARK]);
+		if (filter.fwmark ^ mark)
+			return false;
+	}
+	if (filter.fwmask) {
+		__u32 mask = 0;
+		if (tb[FRA_FWMASK])
+			mask = rta_getattr_u32(tb[FRA_FWMASK]);
+		if (filter.fwmask ^ mask)
+			return false;
+	}
+
+	if (filter.iifmask) {
+		if (tb[FRA_IFNAME]) {
+			if (strcmp(filter.iif, rta_getattr_str(tb[FRA_IFNAME])) != 0)
+				return false;
+		} else {
+			return false;
+		}
+	}
+
+	if (filter.oifmask) {
+		if (tb[FRA_OIFNAME]) {
+			if (strcmp(filter.oif, rta_getattr_str(tb[FRA_OIFNAME])) != 0)
+				return false;
+		} else {
+			return false;
+		}
+	}
+
+	if (filter.l3mdev && !(tb[FRA_L3MDEV] && rta_getattr_u8(tb[FRA_L3MDEV])))
+		return false;
+
+	table = rtm_get_table(r, tb);
+	if (filter.tb > 0 && filter.tb ^ table)
+		return false;
+
+	return true;
+}
+
 int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 {
 	FILE *fp = (FILE *)arg;
@@ -77,6 +177,9 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 	host_len = af_bit_len(r->rtm_family);
 
+	if(!filter_nlmsg(n, tb, host_len))
+		return 0;
+
 	if (n->nlmsg_type == RTM_DELRULE)
 		fprintf(fp, "Deleted ");
 
@@ -287,9 +390,9 @@ static int iprule_list_flush_or_save(int argc, char **argv, int action)
 	if (af == AF_UNSPEC)
 		af = AF_INET;
 
-	if (argc > 0) {
-		fprintf(stderr,
-			"\"ip rule list/flush/save\" does not take any arguments\n");
+	if (action != IPRULE_LIST && argc > 0) {
+		fprintf(stderr, "\"ip rule %s\" does not take any arguments.\n",
+				action == IPRULE_SAVE ? "save" : "flush");
 		return -1;
 	}
 
@@ -306,6 +409,75 @@ static int iprule_list_flush_or_save(int argc, char **argv, int action)
 		filter_fn = print_rule;
 	}
 
+	memset(&filter, 0, sizeof(filter));
+
+	while (argc > 0) {
+		if (matches(*argv, "preference") == 0 ||
+		    matches(*argv, "order") == 0 ||
+		    matches(*argv, "priority") == 0) {
+			__u32 pref;
+			NEXT_ARG();
+			if (get_u32(&pref, *argv, 0))
+				invarg("preference value is invalid\n", *argv);
+			filter.pref = pref;
+			filter.prefmask = 1;
+		} else if (strcmp(*argv, "not") == 0) {
+			filter.not = 1;
+		} else if (strcmp(*argv, "tos") == 0) {
+			__u32 tos;
+			NEXT_ARG();
+			if (rtnl_dsfield_a2n(&tos, *argv))
+				invarg("TOS value is invalid\n", *argv);
+			filter.tos = tos;
+			filter.tosmask = 1;
+		} else if (strcmp(*argv, "fwmark") == 0) {
+			char *slash;
+			__u32 fwmark, fwmask;
+			NEXT_ARG();
+			slash = strchr(*argv, '/');
+			if (slash != NULL)
+				*slash = '\0';
+			if (get_u32(&fwmark, *argv, 0))
+				invarg("fwmark value is invalid\n", *argv);
+			filter.fwmark = fwmark;
+			if (slash) {
+				if (get_u32(&fwmask, slash+1, 0))
+					invarg("fwmask value is invalid\n",
+					       slash+1);
+				filter.fwmask = fwmask;
+			}
+		} else if (strcmp(*argv, "dev") == 0 ||
+			   strcmp(*argv, "iif") == 0) {
+			NEXT_ARG();
+			strncpy(filter.iif, *argv, IFNAMSIZ);
+			filter.iifmask = 1;
+		} else if (strcmp(*argv, "oif") == 0) {
+			NEXT_ARG();
+			strncpy(filter.oif, *argv, IFNAMSIZ);
+			filter.oifmask = 1;
+		} else if (strcmp(*argv, "l3mdev") == 0) {
+			filter.l3mdev = 1;
+		} else if (matches(*argv, "lookup") == 0 ||
+			   matches(*argv, "table") == 0 ) {
+			__u32 tid;
+			NEXT_ARG();
+			if (rtnl_rttable_a2n(&tid, *argv))
+				invarg("table id value is invalid\n", *argv);
+			filter.tb = tid;
+		} else if (matches(*argv, "from") == 0 ||
+			   matches(*argv, "src") == 0) {
+			NEXT_ARG();
+			get_prefix(&filter.src, *argv, af);
+		} else {
+			if (matches(*argv, "dst") == 0 ||
+			    matches(*argv, "to") == 0) {
+				NEXT_ARG();
+			}
+			get_prefix(&filter.dst, *argv, af);
+		}
+		argc--; argv++;
+	}
+
 	if (rtnl_wilddump_request(&rth, af, RTM_GETRULE) < 0) {
 		perror("Cannot send dump request");
 		return 1;
diff --git a/man/man8/ip-rule.8 b/man/man8/ip-rule.8
index 3508d80..48e4490 100644
--- a/man/man8/ip-rule.8
+++ b/man/man8/ip-rule.8
@@ -15,7 +15,8 @@ ip-rule \- routing policy database management
 
 .ti -8
 .B  ip rule
-.RB "[ " list " ]"
+.RB "[ " list
+.RI "[ " SELECTOR " ]]"
 
 .ti -8
 .B  ip rule
@@ -42,7 +43,8 @@ ip-rule \- routing policy database management
 .B  oif
 .IR STRING " ] [ "
 .B  pref
-.IR NUMBER " ]"
+.IR NUMBER " ] [ "
+.BR l3mdev " ]"
 
 .ti -8
 .IR ACTION " := [ "
-- 
2.5.5
