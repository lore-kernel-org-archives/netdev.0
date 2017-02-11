From: yuan linyu <cugyly@163.com>
Subject: [PATH v3 net-next] net: remove member 'max' of struct scm_fp_list
Date: Sat, 11 Feb 2017 11:41:17 +0800
Message-ID: <1486784477-3892-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-13.163.com ([220.181.12.13]:46412 "EHLO m12-13.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751716AbdBKDmS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 10 Feb 2017 22:42:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

'max' only used at three places in scm.c,
1. in scm_fp_copy(), fpl->max = SCM_MAX_FD;
2. in scm_fp_copy(), if (fpl->count + num > fpl->max)
3. in scm_fp_dup(), new_fpl->max = new_fpl->count;
at place 3, the worst case is new_fpl->count = SCM_MAX_FD,
so do a full size dup, then 'max' field will always
SCM_MAX_FD and it can be removed.

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
v2->v3:
	change scm_fp_dup() to do a full size dup

v1->v2:
	update commit log to describe correct reason to remove 'max'

 include/net/scm.h |  3 +--
 net/core/scm.c    | 23 ++++++-----------------
 2 files changed, 7 insertions(+), 19 deletions(-)

diff --git a/include/net/scm.h b/include/net/scm.h
index 59fa93c..1301227 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -19,8 +19,7 @@ struct scm_creds {
 };
 
 struct scm_fp_list {
-	short			count;
-	short			max;
+	unsigned int	count;
 	struct user_struct	*user;
 	struct file		*fp[SCM_MAX_FD];
 };
diff --git a/net/core/scm.c b/net/core/scm.c
index b6d8368..fb3ab32 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -69,15 +69,7 @@ static int scm_fp_copy(struct cmsghdr *cmsg, struct scm_fp_list **fplp)
 	int *fdp = (int*)CMSG_DATA(cmsg);
 	struct scm_fp_list *fpl = *fplp;
 	struct file **fpp;
-	int i, num;
-
-	num = (cmsg->cmsg_len - sizeof(struct cmsghdr))/sizeof(int);
-
-	if (num <= 0)
-		return 0;
-
-	if (num > SCM_MAX_FD)
-		return -EINVAL;
+	unsigned int i, num;
 
 	if (!fpl)
 	{
@@ -86,18 +78,17 @@ static int scm_fp_copy(struct cmsghdr *cmsg, struct scm_fp_list **fplp)
 			return -ENOMEM;
 		*fplp = fpl;
 		fpl->count = 0;
-		fpl->max = SCM_MAX_FD;
 		fpl->user = NULL;
 	}
-	fpp = &fpl->fp[fpl->count];
 
-	if (fpl->count + num > fpl->max)
+	num = (cmsg->cmsg_len - sizeof(struct cmsghdr))/sizeof(int);
+	if (fpl->count + num > SCM_MAX_FD)
 		return -EINVAL;
 
 	/*
 	 *	Verify the descriptors and increment the usage count.
 	 */
-
+	fpp = &fpl->fp[fpl->count];
 	for (i=0; i< num; i++)
 	{
 		int fd = fdp[i];
@@ -112,7 +103,7 @@ static int scm_fp_copy(struct cmsghdr *cmsg, struct scm_fp_list **fplp)
 	if (!fpl->user)
 		fpl->user = get_uid(current_user());
 
-	return num;
+	return 0;
 }
 
 void __scm_destroy(struct scm_cookie *scm)
@@ -336,12 +327,10 @@ struct scm_fp_list *scm_fp_dup(struct scm_fp_list *fpl)
 	if (!fpl)
 		return NULL;
 
-	new_fpl = kmemdup(fpl, offsetof(struct scm_fp_list, fp[fpl->count]),
-			  GFP_KERNEL);
+	new_fpl = kmemdup(fpl, sizeof(*fpl), GFP_KERNEL);
 	if (new_fpl) {
 		for (i = 0; i < fpl->count; i++)
 			get_file(fpl->fp[i]);
-		new_fpl->max = new_fpl->count;
 		new_fpl->user = get_uid(fpl->user);
 	}
 	return new_fpl;
-- 
2.7.4
