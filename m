From: jamal <hadi@cyberus.ca>
Subject: [IPROUTE2 PATCH][GENETLINK]  Add controller support for new
	features exposed
Date: Wed, 06 Dec 2006 12:35:52 -0500
Message-ID: <1165426552.3749.15.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-uPX9PsGU2XfYkBw9tvoA"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.234]:51418 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936928AbWLFRgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 12:36:04 -0500
Received: by wr-out-0506.google.com with SMTP id i7so419748wra
        for <netdev@vger.kernel.org>; Wed, 06 Dec 2006 09:36:03 -0800 (PST)
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-uPX9PsGU2XfYkBw9tvoA
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Ok, heres hopefully the last one in this series for generic netlink ..


cheers,
jamal


--=-uPX9PsGU2XfYkBw9tvoA
Content-Disposition: attachment; filename=genl-p3
Content-Type: text/plain; name=genl-p3; charset=us-ascii
Content-Transfer-Encoding: 7bit

[GENL]: Add controller support for new features exposed

Update the controller to spit out the new features being exposed
from the kernel

Signed-off-by: J Hadi Salim <hadi@cyberus.ca>

---
commit 241e28d5d5d326d33b2d71752d574e2ae118f671
tree ccda0d9dd9b85180fdd803f79ad11d305f2ffc53
parent 515370c958be14b417e20611258eecbe9fda2382
author Jamal Hadi Salim <hadi@cyberus.ca> Wed, 06 Dec 2006 12:30:36 -0500
committer Jamal Hadi Salim <hadi@cyberus.ca> Wed, 06 Dec 2006 12:30:36 -0500

 genl/ctrl.c |   84 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 82 insertions(+), 2 deletions(-)

diff --git a/genl/ctrl.c b/genl/ctrl.c
index 0d4750d..fe010f3 100644
--- a/genl/ctrl.c
+++ b/genl/ctrl.c
@@ -22,6 +22,7 @@
 #include "utils.h"
 #include "genl_utils.h"
 
+#define GENL_MAX_FAM_OPS	256
 static int usage(void)
 {
 	fprintf(stderr,"Usage: ctrl <CMD>\n" \
@@ -108,6 +109,51 @@ errout:
 	return ret;
 }
 
+void print_ctrl_cmd_flags(FILE *fp, __u32 fl)
+{
+	fprintf(fp, "\n\t\tCapabilities (0x%x):\n ", fl);
+	if (!fl) {
+		fprintf(fp, "\n");
+		return;
+	}
+	fprintf(fp, "\t\t ");
+
+	if (fl & GENL_ADMIN_PERM)
+		fprintf(fp, " requires admin permission;");
+	if (fl & GENL_CMD_CAP_DO)
+		fprintf(fp, " can doit;");
+	if (fl & GENL_CMD_CAP_DUMP)
+		fprintf(fp, " can dumpit;");
+	if (fl & GENL_CMD_CAP_HASPOL)
+		fprintf(fp, " has policy");
+
+	fprintf(fp, "\n");
+}
+	
+static int print_ctrl_cmds(FILE *fp, struct rtattr *arg, __u32 ctrl_ver)
+{
+	struct rtattr *tb[CTRL_ATTR_OP_MAX + 1];
+
+	if (arg == NULL)
+		return -1;
+
+	parse_rtattr_nested(tb, CTRL_ATTR_OP_MAX, arg);
+	if (tb[CTRL_ATTR_OP_ID]) {
+		__u32 *id = RTA_DATA(tb[CTRL_ATTR_OP_ID]);
+		fprintf(fp, " ID-0x%x ",*id);
+	}
+	/* we are only gonna do this for newer version of the controller */
+	if (tb[CTRL_ATTR_OP_FLAGS] && ctrl_ver >= 0x2) {
+		__u32 *fl = RTA_DATA(tb[CTRL_ATTR_OP_FLAGS]);
+		print_ctrl_cmd_flags(fp, *fl);
+	}
+	return 0;
+
+}
+
+/*
+ * The controller sends one nlmsg per family
+*/
 static int print_ctrl(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		      void *arg)
 {
@@ -116,6 +162,7 @@ static int print_ctrl(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	int len = n->nlmsg_len;
 	struct rtattr *attrs;
 	FILE *fp = (FILE *) arg;
+	__u32 ctrl_v = 0x1; 
 
 	if (n->nlmsg_type !=  GENL_ID_CTRL) {
 		fprintf(stderr, "Not a controller message, nlmsg_len=%d "
@@ -142,13 +189,46 @@ static int print_ctrl(const struct sockaddr_nl *who, struct nlmsghdr *n,
 
 	if (tb[CTRL_ATTR_FAMILY_NAME]) {
 		char *name = RTA_DATA(tb[CTRL_ATTR_FAMILY_NAME]);
-		fprintf(fp, "Name: %s\n",name);
+		fprintf(fp, "\nName: %s\n",name);
 	}
 	if (tb[CTRL_ATTR_FAMILY_ID]) {
 		__u16 *id = RTA_DATA(tb[CTRL_ATTR_FAMILY_ID]);
-		fprintf(fp, "ID: 0x%x\n",*id);
+		fprintf(fp, "\tID: 0x%x ",*id);
+	}
+	if (tb[CTRL_ATTR_VERSION]) {
+		__u32 *v = RTA_DATA(tb[CTRL_ATTR_VERSION]);
+		fprintf(fp, " Version: 0x%x ",*v);
+		ctrl_v = *v;
 	}
+	if (tb[CTRL_ATTR_HDRSIZE]) {
+		__u32 *h = RTA_DATA(tb[CTRL_ATTR_HDRSIZE]);
+		fprintf(fp, " header size: %d ",*h);
+	}
+	if (tb[CTRL_ATTR_MAXATTR]) {
+		__u32 *ma = RTA_DATA(tb[CTRL_ATTR_MAXATTR]);
+		fprintf(fp, " max attribs: %d ",*ma);
+	}
+	/* end of family definitions .. */
+	fprintf(fp,"\n");
+	if (tb[CTRL_ATTR_OPS]) {
+		struct rtattr *tb2[GENL_MAX_FAM_OPS];
+		int i=0;
+		parse_rtattr_nested(tb2, GENL_MAX_FAM_OPS, tb[CTRL_ATTR_OPS]);
+		fprintf(fp, "\tcommands supported: \n");
+		for (i = 0; i < GENL_MAX_FAM_OPS; i++) {
+			if (tb2[i]) {
+				fprintf(fp, "\t\t#%d: ", i);
+				if (0 > print_ctrl_cmds(fp, tb2[i], ctrl_v)) {
+					fprintf(fp, "Error printing command\n");
+				}
+				/* for next command */
+				fprintf(fp,"\n");
+			}
+		}
 
+		/* end of family::cmds definitions .. */
+		fprintf(fp,"\n");
+	}
 	fflush(fp);
 	return 0;
 }

--=-uPX9PsGU2XfYkBw9tvoA--

