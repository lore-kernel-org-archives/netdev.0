From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: [PATCH iproute2 v2 2/2] ip rule: add route suppression options
Date: Sat, 3 Aug 2013 14:23:16 +0200
Message-ID: <20130803122316.GN21970@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:53919 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751729Ab3HCMXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 08:23:17 -0400
Received: from stefan by zirkel.wertarbyte.de with local (Exim 4.72)
	(envelope-from <stefan.tomanek@wertarbyte.de>)
	id 1V5arc-0001Vi-Rk
	for netdev@vger.kernel.org; Sat, 03 Aug 2013 14:23:16 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When configuring a system with multiple network uplinks and default routes, it
is often convenient to reference a routing table multiple times - but reject
its routing decision if certain constraints are not met by it.

Consider this setup:

$ ip route add table secuplink default via 10.42.23.1

$ ip rule add pref 100            table main suppress_prefixlength 0
$ ip rule add pref 150 fwmark 0xA table secuplink

With this setup, packets marked 0xA will be processed by the additional routing
table "secuplink", but only if no suitable route in the main routing table can
be found. By suppressing entries with a prefixlength of 0 (or less), the
default route (/0) of the table "main" is hidden to packets processed by rule
100; packets traveling to destinations via more specific routes are processed
as usual.

It is also possible to suppress a routing entry if a device belonging to
a specific interface group is to be used:

$ ip rule add pref 150 table main suppress_group 1

Signed-off-by: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
---
 include/linux/fib_rules.h |    4 ++--
 ip/iprule.c               |   34 +++++++++++++++++++++++++++++++++-
 man/man8/ip-rule.8        |   17 +++++++++++++++++
 3 files changed, 52 insertions(+), 3 deletions(-)

diff --git a/include/linux/fib_rules.h b/include/linux/fib_rules.h
index 51da65b..2b82d7e 100644
--- a/include/linux/fib_rules.h
+++ b/include/linux/fib_rules.h
@@ -44,8 +44,8 @@ enum {
 	FRA_FWMARK,	/* mark */
 	FRA_FLOW,	/* flow/class id */
 	FRA_UNUSED6,
-	FRA_UNUSED7,
-	FRA_UNUSED8,
+	FRA_SUPPRESS_IFGROUP,
+	FRA_SUPPRESS_PREFIXLEN,
 	FRA_TABLE,	/* Extended table id */
 	FRA_FWMASK,	/* mask for netfilter mark */
 	FRA_OIFNAME,
diff --git a/ip/iprule.c b/ip/iprule.c
index a5fcd43..d934f67 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -39,6 +39,9 @@ static void usage(void)
 	fprintf(stderr, "          [ prohibit | reject | unreachable ]\n");
 	fprintf(stderr, "          [ realms [SRCREALM/]DSTREALM ]\n");
 	fprintf(stderr, "          [ goto NUMBER ]\n");
+	fprintf(stderr, "          SUPPRESSOR\n");
+	fprintf(stderr, "SUPPRESSOR := [ suppress_prefixlength NUMBER ]\n");
+	fprintf(stderr, "              [ suppress_ifgroup DEVGROUP ]\n");
 	fprintf(stderr, "TABLE_ID := [ local | main | default | NUMBER ]\n");
 	exit(-1);
 }
@@ -153,9 +156,24 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	}
 
 	table = rtm_get_table(r, tb);
-	if (table)
+	if (table) {
 		fprintf(fp, "lookup %s ", rtnl_rttable_n2a(table, b1, sizeof(b1)));
 
+		if (tb[FRA_SUPPRESS_PREFIXLEN]) {
+			int pl = rta_getattr_u32(tb[FRA_SUPPRESS_PREFIXLEN]);
+			if (pl != -1) {
+				fprintf(fp, "suppress_prefixlength %d ", pl);
+			}
+		}
+		if (tb[FRA_SUPPRESS_IFGROUP]) {
+			int group = rta_getattr_u32(tb[FRA_SUPPRESS_IFGROUP]);
+			if (group != -1) {
+				SPRINT_BUF(b1);
+				fprintf(fp, "suppress_ifgroup %s ", rtnl_group_n2a(group, b1, sizeof(b1)));
+			}
+		}
+	}
+
 	if (tb[FRA_FLOW]) {
 		__u32 to = rta_getattr_u32(tb[FRA_FLOW]);
 		__u32 from = to>>16;
@@ -310,6 +328,20 @@ static int iprule_modify(int cmd, int argc, char **argv)
 				addattr32(&req.n, sizeof(req), FRA_TABLE, tid);
 			}
 			table_ok = 1;
+		} else if (matches(*argv, "suppress_prefixlength") == 0 ||
+			   strcmp(*argv, "sup_pl") == 0) {
+			int pl;
+			NEXT_ARG();
+			if (get_s32(&pl, *argv, 0) || pl < 0)
+				invarg("suppress_prefixlength value is invalid\n", *argv);
+			addattr32(&req.n, sizeof(req), FRA_SUPPRESS_PREFIXLEN, pl);
+		} else if (matches(*argv, "suppress_ifgroup") == 0 ||
+			   strcmp(*argv, "sup_group") == 0) {
+			NEXT_ARG();
+			int group;
+			if (rtnl_group_a2n(&group, *argv))
+				invarg("Invalid \"suppress_ifgroup\" value\n", *argv);
+			addattr32(&req.n, sizeof(req), FRA_SUPPRESS_IFGROUP, group);
 		} else if (strcmp(*argv, "dev") == 0 ||
 			   strcmp(*argv, "iif") == 0) {
 			NEXT_ARG();
diff --git a/man/man8/ip-rule.8 b/man/man8/ip-rule.8
index 36e46f1..62df3b0 100644
--- a/man/man8/ip-rule.8
+++ b/man/man8/ip-rule.8
@@ -43,6 +43,14 @@ ip-rule \- routing policy database management
 .IR ADDRESS " ] [ "
 .BR prohibit " | " reject " | " unreachable " ] [ " realms
 .RI "[" SRCREALM "/]" DSTREALM " ]"
+.I  SUPPRESSOR
+
+.ti -8
+.IR SUPPRESSOR " := [ "
+.B  suppress_prefixlength
+.IR NUMBER " ] [ "
+.B  suppress_ifgroup
+.IR GROUP " ]"
 
 .ti -8
 .IR TABLE_ID " := [ "
@@ -217,6 +225,15 @@ the routing table identifier to lookup if the rule selector matches.
 It is also possible to use lookup instead of table.
 
 .TP
+.BI suppress_prefixlength " NUMBER"
+reject routing decisions that have a prefix length of NUMBER or less.
+
+.TP
+.BI suppress_ifgroup " GROUP"
+reject routing decisions that use a device belonging to the interface
+group GROUP.
+
+.TP
 .BI realms " FROM/TO"
 Realms to select if the rule matched and the routing table lookup
 succeeded.  Realm
-- 
1.7.10.4
