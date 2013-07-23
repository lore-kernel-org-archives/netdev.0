From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: [PATCH iproute2] add prefixlength option to "ip rule"
Date: Wed, 24 Jul 2013 00:21:01 +0200
Message-ID: <20130723222101.GQ10216@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:53684 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933734Ab3GWWVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 18:21:04 -0400
Received: from stefan by zirkel.wertarbyte.de with local (Exim 4.72)
	(envelope-from <stefan.tomanek@wertarbyte.de>)
	id 1V1kx3-0005MD-Ga
	for netdev@vger.kernel.org; Wed, 24 Jul 2013 00:21:01 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When configuring a system with multiple network uplinks and default routes, it
is often convinient to reference the main routing table multiple times - but
omitting the default route. Using this modified "ip" utility and the
corresponding kernel patch, this can be achieved by using the following command
sequence:

$ ip route add table secuplink default via 10.42.23.1

$ ip rule add pref 100            table main prefixlength 1
$ ip rule add pref 150 fwmark 0xA table secuplink

With this setup, packets marked 0xA will be processed by the additional routing
table "secuplink", but only if no suitable route in the main routing table can
be found. By using a minimum prefixlength of 1, the default route (/0) of the
table "main" is hidden to packets processed by rule 100; packets traveling to
destinations via more specific routes are processed as usual.

Signed-off-by: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
---
 include/linux/fib_rules.h |    2 +-
 ip/iprule.c               |   19 ++++++++++++++++---
 man/man8/ip-rule.8        |    9 +++++++++
 3 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/include/linux/fib_rules.h b/include/linux/fib_rules.h
index 51da65b..59cd31b 100644
--- a/include/linux/fib_rules.h
+++ b/include/linux/fib_rules.h
@@ -45,7 +45,7 @@ enum {
 	FRA_FLOW,	/* flow/class id */
 	FRA_UNUSED6,
 	FRA_UNUSED7,
-	FRA_UNUSED8,
+	FRA_TABLE_PREFIXLEN_MIN,
 	FRA_TABLE,	/* Extended table id */
 	FRA_FWMASK,	/* mask for netfilter mark */
 	FRA_OIFNAME,
diff --git a/ip/iprule.c b/ip/iprule.c
index a5fcd43..0fa174a 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -35,7 +35,7 @@ static void usage(void)
 	fprintf(stderr, "Usage: ip rule [ list | add | del | flush ] SELECTOR ACTION\n");
 	fprintf(stderr, "SELECTOR := [ not ] [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark FWMARK[/MASK] ]\n");
 	fprintf(stderr, "            [ iif STRING ] [ oif STRING ] [ pref NUMBER ]\n");
-	fprintf(stderr, "ACTION := [ table TABLE_ID ]\n");
+	fprintf(stderr, "ACTION := [ table TABLE_ID [ prefixlength NUMBER ] ]\n");
 	fprintf(stderr, "          [ prohibit | reject | unreachable ]\n");
 	fprintf(stderr, "          [ realms [SRCREALM/]DSTREALM ]\n");
 	fprintf(stderr, "          [ goto NUMBER ]\n");
@@ -153,9 +153,15 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	}
 
 	table = rtm_get_table(r, tb);
-	if (table)
+	if (table) {
 		fprintf(fp, "lookup %s ", rtnl_rttable_n2a(table, b1, sizeof(b1)));
-
+		if (tb[FRA_TABLE_PREFIXLEN_MIN]) {
+			__u8 pl = rta_getattr_u8(tb[FRA_TABLE_PREFIXLEN_MIN]);
+			if (pl) {
+				fprintf(fp, "prefixlength %u ", pl);
+			}
+		}
+	}
 	if (tb[FRA_FLOW]) {
 		__u32 to = rta_getattr_u32(tb[FRA_FLOW]);
 		__u32 from = to>>16;
@@ -310,6 +316,13 @@ static int iprule_modify(int cmd, int argc, char **argv)
 				addattr32(&req.n, sizeof(req), FRA_TABLE, tid);
 			}
 			table_ok = 1;
+		} else if (matches(*argv, "prefixlength") == 0 ||
+			   strcmp(*argv, "pl") == 0) {
+			__u8 pl;
+			NEXT_ARG();
+			if (get_u8(&pl, *argv, 0))
+				invarg("prefixlength value is invalid\n", *argv);
+			addattr8(&req.n, sizeof(req), FRA_TABLE_PREFIXLEN_MIN, pl);
 		} else if (strcmp(*argv, "dev") == 0 ||
 			   strcmp(*argv, "iif") == 0) {
 			NEXT_ARG();
diff --git a/man/man8/ip-rule.8 b/man/man8/ip-rule.8
index 36e46f1..ae72fe5 100644
--- a/man/man8/ip-rule.8
+++ b/man/man8/ip-rule.8
@@ -39,6 +39,9 @@ ip-rule \- routing policy database management
 .IR ACTION " := [ "
 .B  table
 .IR TABLE_ID " ] [ "
+.IR TABLE_ID " ] [ "
+.B  prefixlength
+.IR NUMBER " ] [ "
 .B  nat
 .IR ADDRESS " ] [ "
 .BR prohibit " | " reject " | " unreachable " ] [ " realms
@@ -217,6 +220,12 @@ the routing table identifier to lookup if the rule selector matches.
 It is also possible to use lookup instead of table.
 
 .TP
+.BI prefixlength " NUMBER"
+only consider routes that have a minimum prefix length of NUMBER.
+Entries inside the referenced table with a lower prefix length
+will be ignored.
+
+.TP
 .BI realms " FROM/TO"
 Realms to select if the rule matched and the routing table lookup
 succeeded.  Realm
-- 
1.7.10.4
