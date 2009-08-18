From: Dan Smith <danms@us.ibm.com>
Subject: [PATCH 2/3] Expose may_setuid() in user.h and add may_setgid() (v2)
Date: Tue, 18 Aug 2009 12:57:14 -0700
Message-ID: <1250625435-16299-3-git-send-email-danms@us.ibm.com>
References: <1250625435-16299-1-git-send-email-danms@us.ibm.com>
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	Serge Hallyn <serue@us.ibm.com>
To: orenl@librato.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:34984 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751122AbZHRTyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 15:54:44 -0400
In-Reply-To: <1250625435-16299-1-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make these helpers available to others.

Changes in v2:
 - Avoid checking the groupinfo in ctx->realcred against the current in
   may_setgid()

Cc: Serge Hallyn <serue@us.ibm.com>
Signed-off-by: Dan Smith <danms@us.ibm.com>
---
 include/linux/user.h |    9 +++++++++
 kernel/user.c        |   13 ++++++++++++-
 2 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/include/linux/user.h b/include/linux/user.h
index 68daf84..c231e9c 100644
--- a/include/linux/user.h
+++ b/include/linux/user.h
@@ -1 +1,10 @@
+#ifndef _LINUX_USER_H
+#define _LINUX_USER_H
+
 #include <asm/user.h>
+#include <linux/sched.h>
+
+extern int may_setuid(struct user_namespace *ns, uid_t uid);
+extern int may_setgid(gid_t gid);
+
+#endif
diff --git a/kernel/user.c b/kernel/user.c
index a535ed6..a78fde7 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -604,7 +604,7 @@ int checkpoint_user(struct ckpt_ctx *ctx, void *ptr)
 	return do_checkpoint_user(ctx, (struct user_struct *) ptr);
 }
 
-static int may_setuid(struct user_namespace *ns, uid_t uid)
+int may_setuid(struct user_namespace *ns, uid_t uid)
 {
 	/*
 	 * this next check will one day become
@@ -631,6 +631,17 @@ static int may_setuid(struct user_namespace *ns, uid_t uid)
 	return 0;
 }
 
+int may_setgid(gid_t gid)
+{
+	if (capable(CAP_SETGID))
+		return 1;
+
+	if (in_egroup_p(gid))
+		return 1;
+
+	return 0;
+}
+
 static struct user_struct *do_restore_user(struct ckpt_ctx *ctx)
 {
 	struct user_struct *u;
-- 
1.6.2.5

