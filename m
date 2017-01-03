From: yuan linyu <cugyly@163.com>
Subject: [PATCH] scm: remove use CMSG{_COMPAT}_ALIGN(sizeof(struct {compat_}cmsghdr))
Date: Tue,  3 Jan 2017 20:42:17 +0800
Message-ID: <1483447337-4976-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-132.163.com ([123.125.50.132]:35460 "EHLO m50-132.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933078AbdACMnb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 07:43:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

sizeof(struct cmsghdr) and sizeof(struct compat_cmsghdr) already aligned.
remove use CMSG_ALIGN(sizeof(struct cmsghdr)) and
CMSG_COMPAT_ALIGN(sizeof(struct compat_cmsghdr)) keep code consistent.

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 include/linux/socket.h |  6 +++---
 net/compat.c           | 14 ++++++--------
 net/core/scm.c         |  2 +-
 net/ipv4/ip_sockglue.c |  2 +-
 net/rxrpc/sendmsg.c    |  2 +-
 5 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index b5cc5a6..c064380 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -92,9 +92,9 @@ struct cmsghdr {
 
 #define CMSG_ALIGN(len) ( ((len)+sizeof(long)-1) & ~(sizeof(long)-1) )
 
-#define CMSG_DATA(cmsg)	((void *)((char *)(cmsg) + CMSG_ALIGN(sizeof(struct cmsghdr))))
-#define CMSG_SPACE(len) (CMSG_ALIGN(sizeof(struct cmsghdr)) + CMSG_ALIGN(len))
-#define CMSG_LEN(len) (CMSG_ALIGN(sizeof(struct cmsghdr)) + (len))
+#define CMSG_DATA(cmsg)	((void *)((char *)(cmsg) + sizeof(struct cmsghdr)))
+#define CMSG_SPACE(len) (sizeof(struct cmsghdr) + CMSG_ALIGN(len))
+#define CMSG_LEN(len) (sizeof(struct cmsghdr) + (len))
 
 #define __CMSG_FIRSTHDR(ctl,len) ((len) >= sizeof(struct cmsghdr) ? \
 				  (struct cmsghdr *)(ctl) : \
diff --git a/net/compat.c b/net/compat.c
index 96c544b..4e27dd1 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -90,11 +90,11 @@ int get_compat_msghdr(struct msghdr *kmsg,
 #define CMSG_COMPAT_ALIGN(len)	ALIGN((len), sizeof(s32))
 
 #define CMSG_COMPAT_DATA(cmsg)				\
-	((void __user *)((char __user *)(cmsg) + CMSG_COMPAT_ALIGN(sizeof(struct compat_cmsghdr))))
+	((void __user *)((char __user *)(cmsg) + sizeof(struct compat_cmsghdr)))
 #define CMSG_COMPAT_SPACE(len)				\
-	(CMSG_COMPAT_ALIGN(sizeof(struct compat_cmsghdr)) + CMSG_COMPAT_ALIGN(len))
+	(sizeof(struct compat_cmsghdr) + CMSG_COMPAT_ALIGN(len))
 #define CMSG_COMPAT_LEN(len)				\
-	(CMSG_COMPAT_ALIGN(sizeof(struct compat_cmsghdr)) + (len))
+	(sizeof(struct compat_cmsghdr) + (len))
 
 #define CMSG_COMPAT_FIRSTHDR(msg)			\
 	(((msg)->msg_controllen) >= sizeof(struct compat_cmsghdr) ?	\
@@ -141,8 +141,7 @@ int cmsghdr_from_user_compat_to_kern(struct msghdr *kmsg, struct sock *sk,
 		if (!CMSG_COMPAT_OK(ucmlen, ucmsg, kmsg))
 			return -EINVAL;
 
-		tmp = ((ucmlen - CMSG_COMPAT_ALIGN(sizeof(*ucmsg))) +
-		       CMSG_ALIGN(sizeof(struct cmsghdr)));
+		tmp = ((ucmlen - sizeof(*ucmsg)) + sizeof(struct cmsghdr));
 		tmp = CMSG_ALIGN(tmp);
 		kcmlen += tmp;
 		ucmsg = cmsg_compat_nxthdr(kmsg, ucmsg, ucmlen);
@@ -168,8 +167,7 @@ int cmsghdr_from_user_compat_to_kern(struct msghdr *kmsg, struct sock *sk,
 			goto Efault;
 		if (!CMSG_COMPAT_OK(ucmlen, ucmsg, kmsg))
 			goto Einval;
-		tmp = ((ucmlen - CMSG_COMPAT_ALIGN(sizeof(*ucmsg))) +
-		       CMSG_ALIGN(sizeof(struct cmsghdr)));
+		tmp = ((ucmlen - sizeof(*ucmsg)) + sizeof(struct cmsghdr));
 		if ((char *)kcmsg_base + kcmlen - (char *)kcmsg < CMSG_ALIGN(tmp))
 			goto Einval;
 		kcmsg->cmsg_len = tmp;
@@ -178,7 +176,7 @@ int cmsghdr_from_user_compat_to_kern(struct msghdr *kmsg, struct sock *sk,
 		    __get_user(kcmsg->cmsg_type, &ucmsg->cmsg_type) ||
 		    copy_from_user(CMSG_DATA(kcmsg),
 				   CMSG_COMPAT_DATA(ucmsg),
-				   (ucmlen - CMSG_COMPAT_ALIGN(sizeof(*ucmsg)))))
+				   (ucmlen - sizeof(*ucmsg))))
 			goto Efault;
 
 		/* Advance. */
diff --git a/net/core/scm.c b/net/core/scm.c
index d882043..b6d8368 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -71,7 +71,7 @@ static int scm_fp_copy(struct cmsghdr *cmsg, struct scm_fp_list **fplp)
 	struct file **fpp;
 	int i, num;
 
-	num = (cmsg->cmsg_len - CMSG_ALIGN(sizeof(struct cmsghdr)))/sizeof(int);
+	num = (cmsg->cmsg_len - sizeof(struct cmsghdr))/sizeof(int);
 
 	if (num <= 0)
 		return 0;
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 53ae0c6..c77e65e 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -272,7 +272,7 @@ int ip_cmsg_send(struct sock *sk, struct msghdr *msg, struct ipcm_cookie *ipc,
 			continue;
 		switch (cmsg->cmsg_type) {
 		case IP_RETOPTS:
-			err = cmsg->cmsg_len - CMSG_ALIGN(sizeof(struct cmsghdr));
+			err = cmsg->cmsg_len - sizeof(struct cmsghdr);
 
 			/* Our caller is responsible for freeing ipc->opt */
 			err = ip_options_get(net, &ipc->opt, CMSG_DATA(cmsg),
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index b214a4d..0a6ef21 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -376,7 +376,7 @@ static int rxrpc_sendmsg_cmsg(struct msghdr *msg,
 		if (!CMSG_OK(msg, cmsg))
 			return -EINVAL;
 
-		len = cmsg->cmsg_len - CMSG_ALIGN(sizeof(struct cmsghdr));
+		len = cmsg->cmsg_len - sizeof(struct cmsghdr);
 		_debug("CMSG %d, %d, %d",
 		       cmsg->cmsg_level, cmsg->cmsg_type, len);
 
-- 
2.7.4
