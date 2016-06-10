From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2] ip rule: Add support for l3mdev rules
Date: Fri, 10 Jun 2016 10:47:17 -0700
Message-ID: <1465580837-8743-1-git-send-email-dsa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33297 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbcFJRrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 13:47:24 -0400
Received: by mail-pa0-f49.google.com with SMTP id b13so3119097pat.0
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 10:47:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel commit 96c63fa7393d ("net: Add l3mdev rule") added support for
the FRA_L3MDEV attribute. The attribute enables use of l3mdev rules
which mean 'get table id from l3 master device'. This patch adds
support to iproute2 to show, add and delete rules with this attribute.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
Assumes FRA_L3MDEV is added by header sync to latest kernel tree

 include/linux/fib_rules.h |  1 +
 ip/iprule.c               | 21 ++++++++++++++++++---
 2 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/ip/iprule.c b/ip/iprule.c
index 7cb19e4d5ebd..b0566d5e4259 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -37,7 +37,7 @@ static void usage(void)
 	fprintf(stderr, "       ip rule { flush | save | restore }\n");
 	fprintf(stderr, "       ip rule [ list ]\n");
 	fprintf(stderr, "SELECTOR := [ not ] [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark FWMARK[/MASK] ]\n");
-	fprintf(stderr, "            [ iif STRING ] [ oif STRING ] [ pref NUMBER ]\n");
+	fprintf(stderr, "            [ iif STRING ] [ oif STRING ] [ pref NUMBER ] [ l3mdev ]\n");
 	fprintf(stderr, "ACTION := [ table TABLE_ID ]\n");
 	fprintf(stderr, "          [ nat ADDRESS ]\n");
 	fprintf(stderr, "          [ realms [SRCREALM/]DSTREALM ]\n");
@@ -139,6 +139,11 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			fprintf(fp, "[detached] ");
 	}
 
+	if (tb[FRA_L3MDEV]) {
+		if (rta_getattr_u8(tb[FRA_L3MDEV]))
+			fprintf(fp, "lookup [l3mdev-table] ");
+	}
+
 	table = rtm_get_table(r, tb);
 	if (table) {
 		fprintf(fp, "lookup %s ", rtnl_rttable_n2a(table, b1, sizeof(b1)));
@@ -311,7 +316,9 @@ static int iprule_restore(void)
 
 static int iprule_modify(int cmd, int argc, char **argv)
 {
+	int l3mdev_rule = 0;
 	int table_ok = 0;
+	__u32 tid = 0;
 	struct {
 		struct nlmsghdr	n;
 		struct rtmsg		r;
@@ -393,8 +400,6 @@ static int iprule_modify(int cmd, int argc, char **argv)
 			addattr32(&req.n, sizeof(req), FRA_FLOW, realm);
 		} else if (matches(*argv, "table") == 0 ||
 			   strcmp(*argv, "lookup") == 0) {
-			__u32 tid;
-
 			NEXT_ARG();
 			if (rtnl_rttable_a2n(&tid, *argv))
 				invarg("invalid table ID\n", *argv);
@@ -428,6 +433,10 @@ static int iprule_modify(int cmd, int argc, char **argv)
 		} else if (strcmp(*argv, "oif") == 0) {
 			NEXT_ARG();
 			addattr_l(&req.n, sizeof(req), FRA_OIFNAME, *argv, strlen(*argv)+1);
+		} else if (strcmp(*argv, "l3mdev") == 0) {
+			addattr8(&req.n, sizeof(req), FRA_L3MDEV, 1);
+			table_ok = 1;
+			l3mdev_rule = 1;
 		} else if (strcmp(*argv, "nat") == 0 ||
 			   matches(*argv, "map-to") == 0) {
 			NEXT_ARG();
@@ -461,6 +470,12 @@ static int iprule_modify(int cmd, int argc, char **argv)
 		argv++;
 	}
 
+	if (l3mdev_rule && tid != 0) {
+		fprintf(stderr,
+			"table can not be specified for l3mdev rules\n");
+		return -EINVAL;
+	}
+
 	if (req.r.rtm_family == AF_UNSPEC)
 		req.r.rtm_family = AF_INET;
 
-- 
2.1.4
