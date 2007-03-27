From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] iproute2: support for goto/nop action and detached flag
Date: Tue, 27 Mar 2007 02:04:10 +0200
Message-ID: <20070327000410.GI521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:52642 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933819AbXC0ADt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Mar 2007 20:03:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen,

Patch to support the new fib rules features I just posted
on netdev.

Index: iproute2.git/include/linux/fib_rules.h
===================================================================
--- iproute2.git.orig/include/linux/fib_rules.h	2007-03-25 22:26:33.000000000 +0200
+++ iproute2.git/include/linux/fib_rules.h	2007-03-27 02:00:48.000000000 +0200
@@ -7,6 +7,8 @@
 /* rule is permanent, and cannot be deleted */
 #define FIB_RULE_PERMANENT	1
 #define FIB_RULE_INVERT		2
+#define FIB_RULE_UNRESOLVED	4
+#define FIB_RULE_DEV_DETACHED	8
 
 struct fib_rule_hdr
 {
@@ -29,7 +31,7 @@ enum
 	FRA_DST,	/* destination address */
 	FRA_SRC,	/* source address */
 	FRA_IFNAME,	/* interface name */
-	FRA_UNUSED1,
+	FRA_GOTO,	/* target to jump to (FR_ACT_GOTO) */
 	FRA_UNUSED2,
 	FRA_PRIORITY,	/* priority/preference */
 	FRA_UNUSED3,
@@ -51,8 +53,8 @@ enum
 {
 	FR_ACT_UNSPEC,
 	FR_ACT_TO_TBL,		/* Pass to fixed table */
-	FR_ACT_RES1,
-	FR_ACT_RES2,
+	FR_ACT_GOTO,		/* Jump to another rule */
+	FR_ACT_NOP,		/* No operation */
 	FR_ACT_RES3,
 	FR_ACT_RES4,
 	FR_ACT_BLACKHOLE,	/* Drop without notification */
Index: iproute2.git/ip/iprule.c
===================================================================
--- iproute2.git.orig/ip/iprule.c	2007-03-25 22:25:28.000000000 +0200
+++ iproute2.git/ip/iprule.c	2007-03-27 02:00:48.000000000 +0200
@@ -42,6 +42,7 @@ static void usage(void)
 	fprintf(stderr, "ACTION := [ table TABLE_ID ]\n");
 	fprintf(stderr, "          [ prohibit | reject | unreachable ]\n");
 	fprintf(stderr, "          [ realms [SRCREALM/]DSTREALM ]\n");
+	fprintf(stderr, "          [ goto NUMBER ]\n");
 	fprintf(stderr, "TABLE_ID := [ local | main | default | NUMBER ]\n");
 	exit(-1);
 }
@@ -144,6 +145,8 @@ int print_rule(const struct sockaddr_nl 
 
 	if (tb[RTA_IIF]) {
 		fprintf(fp, "iif %s ", (char*)RTA_DATA(tb[RTA_IIF]));
+		if (r->rtm_flags & FIB_RULE_DEV_DETACHED)
+			fprintf(fp, "[detached] ");
 	}
 
 	table = rtm_get_table(r, tb);
@@ -171,7 +174,17 @@ int print_rule(const struct sockaddr_nl 
 					    abuf, sizeof(abuf)));
 		} else
 			fprintf(fp, "masquerade");
-	} else if (r->rtm_type != RTN_UNICAST)
+	} else if (r->rtm_type == FR_ACT_GOTO) {
+		fprintf(fp, "goto ");
+		if (tb[FRA_GOTO])
+			fprintf(fp, "%u", *(__u32 *) RTA_DATA(tb[FRA_GOTO]));
+		else
+			fprintf(fp, "none");
+		if (r->rtm_flags & FIB_RULE_UNRESOLVED)
+			fprintf(fp, " [unresolved]");
+	} else if (r->rtm_type == FR_ACT_NOP)
+		fprintf(fp, "nop");
+	else if (r->rtm_type != RTN_UNICAST)
 		fprintf(fp, "%s", rtnl_rtntype_n2a(r->rtm_type, b1, sizeof(b1)));
 
 	fprintf(fp, "\n");
@@ -311,9 +324,19 @@ static int iprule_modify(int cmd, int ar
 			}
 			if (matches(*argv, "help") == 0)
 				usage();
-			if (rtnl_rtntype_a2n(&type, *argv))
+			else if (matches(*argv, "goto") == 0) {
+				__u32 target;
+				type = FR_ACT_GOTO;
+				NEXT_ARG();
+				if (get_u32(&target, *argv, 0))
+					invarg("invalid target\n", *argv);
+				addattr32(&req.n, sizeof(req), FRA_GOTO, target);
+			} else if (matches(*argv, "nop") == 0)
+				type = FR_ACT_NOP;
+			else if (rtnl_rtntype_a2n(&type, *argv))
 				invarg("Failed to parse rule type", *argv);
 			req.r.rtm_type = type;
+			table_ok = 1;
 		}
 		argc--;
 		argv++;
