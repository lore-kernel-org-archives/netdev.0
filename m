From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH iproute2] show multicast groups
Date: Thu, 19 Jul 2007 11:13:18 +0200
Message-ID: <1184836399.3894.3.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jamal <hadi@cyberus.ca>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:35643 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936090AbXGSKHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 06:07:08 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update the included version of the genetlink.h header to the multicast
group API and make the generic netlink controller part show multicast
groups where applicable. Also fix two typos.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

diff --git a/genl/ctrl.c b/genl/ctrl.c
index fe010f3..72d39a0 100644
--- a/genl/ctrl.c
+++ b/genl/ctrl.c
@@ -6,7 +6,8 @@
  *		as published by the Free Software Foundation; either version
  *		2 of the License, or (at your option) any later version.
  *
- * Authors:  J Hadi Salim (hadi@cyberus.ca)
+ * Authors:	J Hadi Salim (hadi@cyberus.ca)
+ *		Johannes Berg (johannes@sipsolutions.net)
  */
 
 #include <stdio.h>
@@ -23,6 +24,8 @@
 #include "genl_utils.h"
 
 #define GENL_MAX_FAM_OPS	256
+#define GENL_MAX_FAM_GRPS	256
+
 static int usage(void)
 {
 	fprintf(stderr,"Usage: ctrl <CMD>\n" \
@@ -82,7 +85,7 @@ int genl_ctrl_resolve_family(const char *family)
 		}
 
 		if (ghdr->cmd != CTRL_CMD_NEWFAMILY) {
-			fprintf(stderr, "Unkown controller command %d\n", ghdr->cmd);
+			fprintf(stderr, "Unknown controller command %d\n", ghdr->cmd);
 			goto errout;
 		}
 
@@ -151,6 +154,26 @@ static int print_ctrl_cmds(FILE *fp, struct rtattr *arg, __u32 ctrl_ver)
 
 }
 
+static int print_ctrl_grp(FILE *fp, struct rtattr *arg, __u32 ctrl_ver)
+{
+	struct rtattr *tb[CTRL_ATTR_MCAST_GRP_MAX + 1];
+
+	if (arg == NULL)
+		return -1;
+
+	parse_rtattr_nested(tb, CTRL_ATTR_MCAST_GRP_MAX, arg);
+	if (tb[2]) {
+		__u32 *id = RTA_DATA(tb[CTRL_ATTR_MCAST_GRP_ID]);
+		fprintf(fp, " ID-0x%x ",*id);
+	}
+	if (tb[1]) {
+		char *name = RTA_DATA(tb[CTRL_ATTR_MCAST_GRP_NAME]);
+		fprintf(fp, " name: %s ", name);
+	}
+	return 0;
+
+}
+
 /*
  * The controller sends one nlmsg per family
 */
@@ -172,8 +195,10 @@ static int print_ctrl(const struct sockaddr_nl *who, struct nlmsghdr *n,
 
 	if (ghdr->cmd != CTRL_CMD_GETFAMILY &&
 	    ghdr->cmd != CTRL_CMD_DELFAMILY &&
-	    ghdr->cmd != CTRL_CMD_NEWFAMILY) {
-		fprintf(stderr, "Unkown controller command %d\n", ghdr->cmd);
+	    ghdr->cmd != CTRL_CMD_NEWFAMILY &&
+	    ghdr->cmd != CTRL_CMD_NEWMCAST_GRP &&
+	    ghdr->cmd != CTRL_CMD_DELMCAST_GRP) {
+		fprintf(stderr, "Unknown controller command %d\n", ghdr->cmd);
 		return 0;
 	}
 
@@ -229,6 +254,29 @@ static int print_ctrl(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		/* end of family::cmds definitions .. */
 		fprintf(fp,"\n");
 	}
+
+	if (tb[CTRL_ATTR_MCAST_GROUPS]) {
+		struct rtattr *tb2[GENL_MAX_FAM_GRPS + 1];
+		int i;
+
+		parse_rtattr_nested(tb2, GENL_MAX_FAM_GRPS,
+				    tb[CTRL_ATTR_MCAST_GROUPS]);
+		fprintf(fp, "\tmulticast groups:\n");
+
+		for (i = 0; i < GENL_MAX_FAM_GRPS; i++) {
+			if (tb2[i]) {
+				fprintf(fp, "\t\t#%d: ", i);
+				if (0 > print_ctrl_grp(fp, tb2[i], ctrl_v))
+					fprintf(fp, "Error printing group\n");
+				/* for next group */
+				fprintf(fp,"\n");
+			}
+		}
+
+		/* end of family::groups definitions .. */
+		fprintf(fp,"\n");
+	}
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


