From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH iproute] ip: support UID range routing.
Date: Mon,  7 Nov 2016 01:26:51 +0900
Message-ID: <1478449611-139263-1-git-send-email-lorenzo@google.com>
Cc: stephen@networkplumber.org, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33231 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750764AbcKFQ06 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Nov 2016 11:26:58 -0500
Received: by mail-pf0-f176.google.com with SMTP id d2so78451596pfd.0
        for <netdev@vger.kernel.org>; Sun, 06 Nov 2016 08:26:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Support adding, deleting and showing IP rules with UID ranges.
- Support querying per-UID routes via "ip route get uid <UID>".

UID range routing was added to net-next in 4fb7450683 ("Merge
branch 'uid-routing'")

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/linux/fib_rules.h |  6 ++++++
 include/linux/rtnetlink.h |  1 +
 ip/iproute.c              | 12 ++++++++++++
 ip/iprule.c               | 35 ++++++++++++++++++++++++++++++++++-
 4 files changed, 53 insertions(+), 1 deletion(-)

diff --git a/include/linux/fib_rules.h b/include/linux/fib_rules.h
index 14404b3..bbf02a6 100644
--- a/include/linux/fib_rules.h
+++ b/include/linux/fib_rules.h
@@ -29,6 +29,11 @@ struct fib_rule_hdr {
 	__u32		flags;
 };
 
+struct fib_rule_uid_range {
+	__u32		start;
+	__u32		end;
+};
+
 enum {
 	FRA_UNSPEC,
 	FRA_DST,	/* destination address */
@@ -51,6 +56,7 @@ enum {
 	FRA_OIFNAME,
 	FRA_PAD,
 	FRA_L3MDEV,	/* iif or oif is l3mdev goto its table */
+	FRA_UID_RANGE,	/* UID range */
 	__FRA_MAX
 };
 
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 2d2e3e6..066cfa7 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -318,6 +318,7 @@ enum rtattr_type_t {
 	RTA_ENCAP,
 	RTA_EXPIRES,
 	RTA_PAD,
+	RTA_UID,
 	__RTA_MAX
 };
 
diff --git a/ip/iproute.c b/ip/iproute.c
index 98bfad6..15273be 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -68,6 +68,7 @@ static void usage(void)
 	fprintf(stderr, "       ip route get ADDRESS [ from ADDRESS iif STRING ]\n");
 	fprintf(stderr, "                            [ oif STRING ] [ tos TOS ]\n");
 	fprintf(stderr, "                            [ mark NUMBER ] [ vrf NAME ]\n");
+	fprintf(stderr, "                            [ uid NUMBER ]\n");
 	fprintf(stderr, "       ip route { add | del | change | append | replace } ROUTE\n");
 	fprintf(stderr, "SELECTOR := [ root PREFIX ] [ match PREFIX ] [ exact PREFIX ]\n");
 	fprintf(stderr, "            [ table TABLE_ID ] [ vrf NAME ] [ proto RTPROTO ]\n");
@@ -471,6 +472,10 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		fprintf(fp, "%s ",
 			rtnl_rtrealm_n2a(to, b1, sizeof(b1)));
 	}
+
+	if (tb[RTA_UID])
+		fprintf(fp, "uid %u ", rta_getattr_u32(tb[RTA_UID]));
+
 	if ((r->rtm_flags&RTM_F_CLONED) && r->rtm_family == AF_INET) {
 		__u32 flags = r->rtm_flags&~0xFFFF;
 		int first = 1;
@@ -1684,6 +1689,13 @@ static int iproute_get(int argc, char **argv)
 			if (!name_is_vrf(*argv))
 				invarg("Invalid VRF\n", *argv);
 			odev = *argv;
+		} else if (matches(*argv, "uid") == 0) {
+			uid_t uid;
+
+			NEXT_ARG();
+			if (get_unsigned(&uid, *argv, 0))
+				invarg("invalid UID\n", *argv);
+			addattr32(&req.n, sizeof(req), RTA_UID, uid);
 		} else {
 			inet_prefix addr;
 
diff --git a/ip/iprule.c b/ip/iprule.c
index e61127e..8313138 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -46,6 +46,7 @@ static void usage(void)
 		"       ip rule [ list [ SELECTOR ]]\n"
 		"SELECTOR := [ not ] [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark FWMARK[/MASK] ]\n"
 		"            [ iif STRING ] [ oif STRING ] [ pref NUMBER ] [ l3mdev ]\n"
+		"            [ uidrange NUMBER-NUMBER ]\n"
 		"ACTION := [ table TABLE_ID ]\n"
 		"          [ nat ADDRESS ]\n"
 		"          [ realms [SRCREALM/]DSTREALM ]\n"
@@ -61,13 +62,14 @@ static struct
 {
 	int not;
 	int l3mdev;
-	int iifmask, oifmask;
+	int iifmask, oifmask, uidrange;
 	unsigned int tb;
 	unsigned int tos, tosmask;
 	unsigned int pref, prefmask;
 	unsigned int fwmark, fwmask;
 	char iif[IFNAMSIZ];
 	char oif[IFNAMSIZ];
+	struct fib_rule_uid_range range;
 	inet_prefix src;
 	inet_prefix dst;
 } filter;
@@ -151,6 +153,15 @@ static bool filter_nlmsg(struct nlmsghdr *n, struct rtattr **tb, int host_len)
 	if (filter.l3mdev && !(tb[FRA_L3MDEV] && rta_getattr_u8(tb[FRA_L3MDEV])))
 		return false;
 
+	if (filter.uidrange) {
+		struct fib_rule_uid_range *r = RTA_DATA(tb[FRA_UID_RANGE]);
+
+		if (!tb[FRA_UID_RANGE] ||
+		    r->start != filter.range.start ||
+		    r->end != filter.range.end)
+			return false;
+	}
+
 	table = rtm_get_table(r, tb);
 	if (filter.tb > 0 && filter.tb ^ table)
 		return false;
@@ -259,6 +270,12 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			fprintf(fp, "lookup [l3mdev-table] ");
 	}
 
+	if (tb[FRA_UID_RANGE]) {
+		struct fib_rule_uid_range *r = RTA_DATA(tb[FRA_UID_RANGE]);
+
+		fprintf(fp, "uidrange %u-%u ", r->start, r->end);
+	}
+
 	table = rtm_get_table(r, tb);
 	if (table) {
 		fprintf(fp, "lookup %s ",
@@ -463,6 +480,14 @@ static int iprule_list_flush_or_save(int argc, char **argv, int action)
 			filter.oifmask = 1;
 		} else if (strcmp(*argv, "l3mdev") == 0) {
 			filter.l3mdev = 1;
+		} else if (strcmp(*argv, "uidrange") == 0) {
+			NEXT_ARG();
+			filter.uidrange = 1;
+			if (sscanf(*argv, "%u-%u",
+				   &filter.range.start,
+				   &filter.range.end) != 2)
+				invarg("invalid UID range\n", *argv);
+
 		} else if (matches(*argv, "lookup") == 0 ||
 			   matches(*argv, "table") == 0) {
 			__u32 tid;
@@ -680,6 +705,14 @@ static int iprule_modify(int cmd, int argc, char **argv)
 			addattr8(&req.n, sizeof(req), FRA_L3MDEV, 1);
 			table_ok = 1;
 			l3mdev_rule = 1;
+		} else if (strcmp(*argv, "uidrange") == 0) {
+			struct fib_rule_uid_range r;
+
+			NEXT_ARG();
+			if (sscanf(*argv, "%u-%u", &r.start, &r.end) != 2)
+				invarg("invalid UID range\n", *argv);
+			addattr_l(&req.n, sizeof(req), FRA_UID_RANGE, &r,
+				  sizeof(r));
 		} else if (strcmp(*argv, "nat") == 0 ||
 			   matches(*argv, "map-to") == 0) {
 			NEXT_ARG();
-- 
2.8.0.rc3.226.g39d4020
