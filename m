From: yuan linyu <cugyly@163.com>
Subject: [PATCH v2] scm: fix possible control message header alignment issue
Date: Thu, 29 Dec 2016 20:39:32 +0800
Message-ID: <1483015172-5017-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-138.163.com ([123.125.50.138]:37158 "EHLO m50-138.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752474AbcL2MlC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Dec 2016 07:41:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

1. put_cmsg{_compat}() may copy data to user when buffer free space less than
   control message header alignment size.
2. scm_detach_fds{_compat}() may calc wrong fdmax if control message header
   have greater alignment size.

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 net/compat.c   | 10 ++++++++--
 net/core/scm.c |  8 +++++---
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/net/compat.c b/net/compat.c
index 96c544b..ffe7a04 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -245,7 +245,9 @@ int put_cmsg_compat(struct msghdr *kmsg, int level, int type, int len, void *dat
 
 	if (copy_to_user(cm, &cmhdr, sizeof cmhdr))
 		return -EFAULT;
-	if (copy_to_user(CMSG_COMPAT_DATA(cm), data, cmlen - sizeof(struct compat_cmsghdr)))
+	if (cmlen > CMSG_COMPAT_ALIGN(sizeof(struct compat_cmsghdr)) &&
+	    copy_to_user(CMSG_COMPAT_DATA(cm), data,
+			    cmlen - CMSG_COMPAT_ALIGN(sizeof(struct compat_cmsghdr))))
 		return -EFAULT;
 	cmlen = CMSG_COMPAT_SPACE(len);
 	if (kmsg->msg_controllen < cmlen)
@@ -258,12 +260,16 @@ int put_cmsg_compat(struct msghdr *kmsg, int level, int type, int len, void *dat
 void scm_detach_fds_compat(struct msghdr *kmsg, struct scm_cookie *scm)
 {
 	struct compat_cmsghdr __user *cm = (struct compat_cmsghdr __user *) kmsg->msg_control;
-	int fdmax = (kmsg->msg_controllen - sizeof(struct compat_cmsghdr)) / sizeof(int);
+	int fdmax = 0;
 	int fdnum = scm->fp->count;
 	struct file **fp = scm->fp->fp;
 	int __user *cmfptr;
 	int err = 0, i;
 
+	if (kmsg->msg_controllen > CMSG_COMPAT_ALIGN(sizeof(struct compat_cmsghdr)))
+		fdmax = (kmsg->msg_controllen -
+		         CMSG_COMPAT_ALIGN(sizeof(struct compat_cmsghdr))) / sizeof(int);
+
 	if (fdnum < fdmax)
 		fdmax = fdnum;
 
diff --git a/net/core/scm.c b/net/core/scm.c
index d882043..b2e60fd 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -238,7 +238,9 @@ int put_cmsg(struct msghdr * msg, int level, int type, int len, void *data)
 	err = -EFAULT;
 	if (copy_to_user(cm, &cmhdr, sizeof cmhdr))
 		goto out;
-	if (copy_to_user(CMSG_DATA(cm), data, cmlen - sizeof(struct cmsghdr)))
+	if (cmlen > CMSG_ALIGN(sizeof(struct cmsghdr)) &&
+	    copy_to_user(CMSG_DATA(cm), data,
+			    cmlen - CMSG_ALIGN(sizeof(struct cmsghdr))))
 		goto out;
 	cmlen = CMSG_SPACE(len);
 	if (msg->msg_controllen < cmlen)
@@ -267,8 +269,8 @@ void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm)
 		return;
 	}
 
-	if (msg->msg_controllen > sizeof(struct cmsghdr))
-		fdmax = ((msg->msg_controllen - sizeof(struct cmsghdr))
+	if (msg->msg_controllen > CMSG_ALIGN(sizeof(struct cmsghdr)))
+		fdmax = ((msg->msg_controllen - CMSG_ALIGN(sizeof(struct cmsghdr)))
 			 / sizeof(int));
 
 	if (fdnum < fdmax)
-- 
2.7.4
