From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH iproute2 4/9] actions ife: Introduce encoding and decoding of tcindex metadata
Date: Sat,  1 Oct 2016 16:48:32 -0400
Message-ID: <1475354917-7912-5-git-send-email-jhs@emojatatu.com>
References: <1475354917-7912-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34923 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751953AbcJAUtQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2016 16:49:16 -0400
Received: by mail-pa0-f66.google.com with SMTP id t6so2767648pae.2
        for <netdev@vger.kernel.org>; Sat, 01 Oct 2016 13:48:54 -0700 (PDT)
In-Reply-To: <1475354917-7912-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/linux/tc_act/tc_ife.h |  3 ++-
 tc/m_ife.c                    | 29 +++++++++++++++++++++++------
 2 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/include/linux/tc_act/tc_ife.h b/include/linux/tc_act/tc_ife.h
index 4ece02a..cd18360 100644
--- a/include/linux/tc_act/tc_ife.h
+++ b/include/linux/tc_act/tc_ife.h
@@ -32,8 +32,9 @@ enum {
 #define IFE_META_HASHID 2
 #define	IFE_META_PRIO 3
 #define	IFE_META_QMAP 4
+#define	IFE_META_TCINDEX 5
 /*Can be overridden at runtime by module option*/
-#define	__IFE_META_MAX 5
+#define	__IFE_META_MAX 6
 #define IFE_META_MAX (__IFE_META_MAX - 1)
 
 #endif
diff --git a/tc/m_ife.c b/tc/m_ife.c
index 862461b..e6f6153 100644
--- a/tc/m_ife.c
+++ b/tc/m_ife.c
@@ -67,6 +67,8 @@ static int parse_ife(struct action_util *a, int *argc_p, char ***argv_p,
 	__u32 ife_prio_v = 0;
 	__u32 ife_mark = 0;
 	__u32 ife_mark_v = 0;
+	__u16 ife_tcindex = 0;
+	__u16 ife_tcindex_v = 0;
 	char *daddr = NULL;
 	char *saddr = NULL;
 
@@ -89,6 +91,8 @@ static int parse_ife(struct action_util *a, int *argc_p, char ***argv_p,
 				ife_mark = IFE_META_SKBMARK;
 			} else if (matches(*argv, "prio") == 0) {
 				ife_prio = IFE_META_PRIO;
+			} else if (matches(*argv, "tcindex") == 0) {
+				ife_prio = IFE_META_TCINDEX;
 			} else {
 				fprintf(stderr, "Illegal meta define <%s>\n",
 					*argv);
@@ -106,6 +110,11 @@ static int parse_ife(struct action_util *a, int *argc_p, char ***argv_p,
 				if (get_u32(&ife_prio_v, *argv, 0))
 					invarg("ife prio val is invalid",
 					       *argv);
+			} else if (matches(*argv, "tcindex") == 0) {
+				NEXT_ARG();
+				if (get_u16(&ife_tcindex_v, *argv, 0))
+					invarg("ife tcindex val is invalid",
+					       *argv);
 			} else {
 				fprintf(stderr, "Illegal meta use type <%s>\n",
 					*argv);
@@ -196,6 +205,13 @@ static int parse_ife(struct action_util *a, int *argc_p, char ***argv_p,
 		else
 			addattr_l(n, MAX_MSG, IFE_META_PRIO, NULL, 0);
 	}
+	if (ife_tcindex || ife_tcindex_v) {
+		if (ife_tcindex_v)
+			addattr_l(n, MAX_MSG, IFE_META_TCINDEX, &ife_tcindex_v,
+				  2);
+		else
+			addattr_l(n, MAX_MSG, IFE_META_TCINDEX, NULL, 0);
+	}
 
 	tail2->rta_len = (void *)NLMSG_TAIL(n) - (void *)tail2;
 
@@ -213,7 +229,7 @@ static int print_ife(struct action_util *au, FILE *f, struct rtattr *arg)
 	struct rtattr *tb[TCA_IFE_MAX + 1];
 	__u16 ife_type = 0;
 	__u32 mmark = 0;
-	__u32 mhash = 0;
+	__u16 mtcindex = 0;
 	__u32 mprio = 0;
 	int has_optional = 0;
 	SPRINT_BUF(b2);
@@ -258,13 +274,14 @@ static int print_ife(struct action_util *au, FILE *f, struct rtattr *arg)
 				fprintf(f, "allow mark ");
 		}
 
-		if (metalist[IFE_META_HASHID]) {
-			len = RTA_PAYLOAD(metalist[IFE_META_HASHID]);
+		if (metalist[IFE_META_TCINDEX]) {
+			len = RTA_PAYLOAD(metalist[IFE_META_TCINDEX]);
 			if (len) {
-				mhash = rta_getattr_u32(metalist[IFE_META_HASHID]);
-				fprintf(f, "use hash %u ", mhash);
+				mtcindex =
+					rta_getattr_u16(metalist[IFE_META_TCINDEX]);
+				fprintf(f, "use tcindex %d ", mtcindex);
 			} else
-				fprintf(f, "allow hash ");
+				fprintf(f, "allow tcindex ");
 		}
 
 		if (metalist[IFE_META_PRIO]) {
-- 
1.9.1
