From: yuan linyu <cugyly@163.com>
Subject: [PATCH] net: remove member 'max' of struct scm_fp_list
Date: Fri, 10 Feb 2017 20:11:13 +0800
Message-ID: <1486728673-19466-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mproxygzt1.163.com ([113.108.225.5]:60849 "EHLO
        mproxygzt1.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752389AbdBJQMz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 11:12:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

SCM_MAX_FD can fully replace it.

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 include/net/scm.h |  3 +--
 net/core/scm.c    | 20 +++++---------------
 2 files changed, 6 insertions(+), 17 deletions(-)

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
index b6d8368..53679517 100644
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
@@ -341,7 +332,6 @@ struct scm_fp_list *scm_fp_dup(struct scm_fp_list *fpl)
 	if (new_fpl) {
 		for (i = 0; i < fpl->count; i++)
 			get_file(fpl->fp[i]);
-		new_fpl->max = new_fpl->count;
 		new_fpl->user = get_uid(fpl->user);
 	}
 	return new_fpl;
-- 
2.7.4
