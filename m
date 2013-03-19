From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH] Truncate MCAST_GRP_NAME and FAMILY_NAME char arrays as C strings
Date: Tue, 19 Mar 2013 21:27:09 +0900
Message-ID: <1363696029-12559-1-git-send-email-yamato@redhat.com>
Cc: Masatake YAMATO <yamato@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h219-110-095-248.catv01.itscom.jp ([219.110.95.248]:55726 "EHLO
	localhost.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932483Ab3CSR2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 13:28:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a patch for genl command in iproute2.

You will see garbage at the end of line in the output of following command line:

	$ genl ctrl show | grep thermal_mc_group
        #1:  ID-0x2  name: thermal_mc_group^B

The type of structure field for "name" is char[16] in kernel:

    #define GENL_NAMSIZ	16	/* length of family name */
    ...
    struct genl_multicast_group {
            ...
	    char		name[GENL_NAMSIZ];
            ...
    };

strlen("thermal_mc_group") == 16 is too long for the array size.

This patch protects genl process from this kind of bug by putting
nul char at the end of array after receiving a message from the
kernel.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 genl/ctrl.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/genl/ctrl.c b/genl/ctrl.c
index 7c42578..fd5a50a 100644
--- a/genl/ctrl.c
+++ b/genl/ctrl.c
@@ -168,6 +168,7 @@ static int print_ctrl_grp(FILE *fp, struct rtattr *arg, __u32 ctrl_ver)
 	}
 	if (tb[1]) {
 		char *name = RTA_DATA(tb[CTRL_ATTR_MCAST_GRP_NAME]);
+		name[GENL_NAMSIZ - 1] = '\0';
 		fprintf(fp, " name: %s ", name);
 	}
 	return 0;
@@ -214,6 +215,7 @@ static int print_ctrl(const struct sockaddr_nl *who, struct nlmsghdr *n,
 
 	if (tb[CTRL_ATTR_FAMILY_NAME]) {
 		char *name = RTA_DATA(tb[CTRL_ATTR_FAMILY_NAME]);
+		name[GENL_NAMSIZ - 1] = '\0';
 		fprintf(fp, "\nName: %s\n",name);
 	}
 	if (tb[CTRL_ATTR_FAMILY_ID]) {
-- 
1.7.11.7
