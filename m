From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: [PATCH v2 2/2] ip rule: suppress routes based on ifgroup
Date: Thu, 1 Aug 2013 17:47:05 +0200
Message-ID: <20130801154705.GE21970@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:55974 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756608Ab3HAPrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 11:47:07 -0400
Received: from stefan by zirkel.wertarbyte.de with local (Exim 4.72)
	(envelope-from <stefan.tomanek@wertarbyte.de>)
	id 1V4v5l-00035E-4m
	for netdev@vger.kernel.org; Thu, 01 Aug 2013 17:47:05 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
---
 include/linux/fib_rules.h |    2 +-
 ip/iprule.c               |   13 +++++++++++++
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/linux/fib_rules.h b/include/linux/fib_rules.h
index 59cd31b..63e3116 100644
--- a/include/linux/fib_rules.h
+++ b/include/linux/fib_rules.h
@@ -44,7 +44,7 @@ enum {
 	FRA_FWMARK,	/* mark */
 	FRA_FLOW,	/* flow/class id */
 	FRA_UNUSED6,
-	FRA_UNUSED7,
+	FRA_SUPPRESS_IFGROUP,
 	FRA_TABLE_PREFIXLEN_MIN,
 	FRA_TABLE,	/* Extended table id */
 	FRA_FWMASK,	/* mask for netfilter mark */
diff --git a/ip/iprule.c b/ip/iprule.c
index a789863..de9f292 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -41,6 +41,7 @@ static void usage(void)
 	fprintf(stderr, "          [ goto NUMBER ]\n");
 	fprintf(stderr, "          SUPPRESSOR\n");
 	fprintf(stderr, "SUPPRESSOR := [ prefixlength NUMBER ]\n");
+	fprintf(stderr, "              [ suppress_group DEVGROUP ]\n");
 	fprintf(stderr, "TABLE_ID := [ local | main | default | NUMBER ]\n");
 	exit(-1);
 }
@@ -163,6 +164,12 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 				fprintf(fp, "prefixlength %u ", pl);
 			}
 		}
+		if (tb[FRA_SUPPRESS_IFGROUP]) {
+			int group = rta_getattr_u32(tb[FRA_SUPPRESS_IFGROUP]);
+			if (group) {
+				fprintf(fp, "suppress_ifgroup %d ", group);
+			}
+		}
 	}
 	if (tb[FRA_FLOW]) {
 		__u32 to = rta_getattr_u32(tb[FRA_FLOW]);
@@ -325,6 +332,12 @@ static int iprule_modify(int cmd, int argc, char **argv)
 			if (get_u8(&pl, *argv, 0))
 				invarg("prefixlength value is invalid\n", *argv);
 			addattr8(&req.n, sizeof(req), FRA_TABLE_PREFIXLEN_MIN, pl);
+		} else if (matches(*argv, "suppress_group") == 0) {
+			NEXT_ARG();
+			int group;
+			if (rtnl_group_a2n(&group, *argv))
+				invarg("Invalid \"suppress_group\" value\n", *argv);
+			addattr32(&req.n, sizeof(req), FRA_SUPPRESS_IFGROUP, group);
 		} else if (strcmp(*argv, "dev") == 0 ||
 			   strcmp(*argv, "iif") == 0) {
 			NEXT_ARG();
-- 
1.7.10.4
