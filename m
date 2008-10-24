From: Johannes Berg <johannes@sipsolutions.net>
Subject: iproute2: make genl ctrl ls print multicast groups
Date: Fri, 24 Oct 2008 17:25:52 +0200
Message-ID: <1224861953.3919.1.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:58057 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752848AbYJXRLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 13:11:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the genl tool print multicast groups, useful for
discovering which multicast groups are supported.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 genl/ctrl.c               |   39 ++++++++++++++++++++++++++++++++++++---
 include/linux/genetlink.h |   13 +++++++++++++
 2 files changed, 49 insertions(+), 3 deletions(-)

diff --git a/genl/ctrl.c b/genl/ctrl.c
index ee5acb8..5c02ee1 100644
--- a/genl/ctrl.c
+++ b/genl/ctrl.c
@@ -23,6 +23,7 @@
 #include "genl_utils.h"
 
 #define GENL_MAX_FAM_OPS	256
+#define GENL_MAX_FAM_MCAST	256
 static int usage(void)
 {
 	fprintf(stderr,"Usage: ctrl <CMD>\n" \
@@ -151,6 +152,24 @@ static int print_ctrl_cmds(FILE *fp, struct rtattr *arg, __u32 ctrl_ver)
 
 }
 
+static int print_mcast_grp(FILE *fp, struct rtattr *arg)
+{
+	struct rtattr *tb[CTRL_ATTR_MCAST_GRP_MAX + 1];
+
+	if (!arg)
+		return -1;
+
+	parse_rtattr_nested(tb, CTRL_ATTR_MCAST_GRP_MAX, arg);
+	if (tb[CTRL_ATTR_MCAST_GRP_NAME])
+		fprintf(fp, "%s", (char *)RTA_DATA(tb[CTRL_ATTR_MCAST_GRP_NAME]));
+
+	if (tb[CTRL_ATTR_MCAST_GRP_ID]) {
+		__u32 *id = RTA_DATA(tb[CTRL_ATTR_MCAST_GRP_ID]);
+		fprintf(fp, " (%d)", *id);
+	}
+	return 0;
+}
+
 /*
  * The controller sends one nlmsg per family
 */
@@ -225,10 +244,24 @@ static int print_ctrl(const struct sockaddr_nl *who, struct nlmsghdr *n,
 				fprintf(fp,"\n");
 			}
 		}
-
-		/* end of family::cmds definitions .. */
-		fprintf(fp,"\n");
 	}
+	if (tb[CTRL_ATTR_MCAST_GROUPS]) {
+		struct rtattr *tb2[GENL_MAX_FAM_MCAST];
+		int i=0;
+		parse_rtattr_nested(tb2, GENL_MAX_FAM_MCAST, tb[CTRL_ATTR_MCAST_GROUPS]);
+		fprintf(fp, "\tmulticast groups: \n");
+		for (i = 0; i < GENL_MAX_FAM_MCAST; i++) {
+			if (tb2[i]) {
+				fprintf(fp, "\t\t- ", i);
+				if (0 > print_mcast_grp(fp, tb2[i]))
+					fprintf(fp, "Error printing command\n");
+				/* for next command */
+				fprintf(fp,"\n");
+			}
+		}
+	}
+	fprintf(fp,"\n");
+
 	fflush(fp);
 	return 0;
 }
diff --git a/include/linux/genetlink.h b/include/linux/genetlink.h
index f7a9377..7da02c9 100644
--- a/include/linux/genetlink.h
+++ b/include/linux/genetlink.h
@@ -39,6 +39,9 @@ enum {
 	CTRL_CMD_NEWOPS,
 	CTRL_CMD_DELOPS,
 	CTRL_CMD_GETOPS,
+	CTRL_CMD_NEWMCAST_GRP,
+	CTRL_CMD_DELMCAST_GRP,
+	CTRL_CMD_GETMCAST_GRP, /* unused */
 	__CTRL_CMD_MAX,
 };
 
@@ -52,6 +55,7 @@ enum {
 	CTRL_ATTR_HDRSIZE,
 	CTRL_ATTR_MAXATTR,
 	CTRL_ATTR_OPS,
+	CTRL_ATTR_MCAST_GROUPS,
 	__CTRL_ATTR_MAX,
 };
 
@@ -66,4 +70,13 @@ enum {
 
 #define CTRL_ATTR_OP_MAX (__CTRL_ATTR_OP_MAX - 1)
 
+enum {
+	CTRL_ATTR_MCAST_GRP_UNSPEC,
+	CTRL_ATTR_MCAST_GRP_NAME,
+	CTRL_ATTR_MCAST_GRP_ID,
+	__CTRL_ATTR_MCAST_GRP_MAX,
+};
+
+#define CTRL_ATTR_MCAST_GRP_MAX (__CTRL_ATTR_MCAST_GRP_MAX - 1)
+
 #endif	/* __LINUX_GENERIC_NETLINK_H */


