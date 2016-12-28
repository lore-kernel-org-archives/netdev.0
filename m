From: yuan linyu <cugyly@163.com>
Subject: [PATCH] net: avoid put_cmsg() possible copy longer data than input
Date: Wed, 28 Dec 2016 22:34:23 +0800
Message-ID: <1482935663-3428-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-15.163.com ([220.181.12.15]:59337 "EHLO m12-15.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750882AbcL1OfK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Dec 2016 09:35:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

if CMSG_ALIGN(sizeof(struct cmsghdr)) > sizeof(struct cmsghdr),
original (cmlen - sizeof(struct cmsghdr)) may greater than
input len.
---
 include/linux/socket.h | 12 ++++++------
 net/compat.c           | 28 +++++++++++++++-------------
 net/core/scm.c         | 10 +++++-----
 net/ipv4/ip_sockglue.c |  2 +-
 net/rxrpc/sendmsg.c    |  2 +-
 net/socket.c           |  3 +--
 6 files changed, 29 insertions(+), 28 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index b5cc5a6..72b61d8 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -78,8 +78,8 @@ struct mmsghdr {
 
 struct cmsghdr {
 	__kernel_size_t	cmsg_len;	/* data byte count, including hdr */
-        int		cmsg_level;	/* originating protocol */
-        int		cmsg_type;	/* protocol-specific type */
+	int		cmsg_level;	/* originating protocol */
+	int		cmsg_type;	/* protocol-specific type */
 };
 
 /*
@@ -91,10 +91,10 @@ struct cmsghdr {
 #define CMSG_NXTHDR(mhdr, cmsg) cmsg_nxthdr((mhdr), (cmsg))
 
 #define CMSG_ALIGN(len) ( ((len)+sizeof(long)-1) & ~(sizeof(long)-1) )
-
-#define CMSG_DATA(cmsg)	((void *)((char *)(cmsg) + CMSG_ALIGN(sizeof(struct cmsghdr))))
-#define CMSG_SPACE(len) (CMSG_ALIGN(sizeof(struct cmsghdr)) + CMSG_ALIGN(len))
-#define CMSG_LEN(len) (CMSG_ALIGN(sizeof(struct cmsghdr)) + (len))
+#define CMSG_ALIGN_HDR_LEN CMSG_ALIGN(sizeof(struct cmsghdr))
+#define CMSG_DATA(cmsg)	((void *)((char *)(cmsg) + CMSG_ALIGN_HDR_LEN))
+#define CMSG_SPACE(len) (CMSG_ALIGN_HDR_LEN + CMSG_ALIGN(len))
+#define CMSG_LEN(len) (CMSG_ALIGN_HDR_LEN + (len))
 
 #define __CMSG_FIRSTHDR(ctl,len) ((len) >= sizeof(struct cmsghdr) ? \
 				  (struct cmsghdr *)(ctl) : \
diff --git a/net/compat.c b/net/compat.c
index 96c544b..b291ff4 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -88,13 +88,13 @@ int get_compat_msghdr(struct msghdr *kmsg,
 
 /* Bleech... */
 #define CMSG_COMPAT_ALIGN(len)	ALIGN((len), sizeof(s32))
-
+#define CMSG_COMPAT_ALIGN_HDR_LEN	CMSG_COMPAT_ALIGN(sizeof(struct compat_cmsghdr))
 #define CMSG_COMPAT_DATA(cmsg)				\
-	((void __user *)((char __user *)(cmsg) + CMSG_COMPAT_ALIGN(sizeof(struct compat_cmsghdr))))
+	((void __user *)((char __user *)(cmsg) + CMSG_COMPAT_ALIGN_HDR_LEN))
 #define CMSG_COMPAT_SPACE(len)				\
-	(CMSG_COMPAT_ALIGN(sizeof(struct compat_cmsghdr)) + CMSG_COMPAT_ALIGN(len))
+	(CMSG_COMPAT_ALIGN_HDR_LEN + CMSG_COMPAT_ALIGN(len))
 #define CMSG_COMPAT_LEN(len)				\
-	(CMSG_COMPAT_ALIGN(sizeof(struct compat_cmsghdr)) + (len))
+	(CMSG_COMPAT_ALIGN_HDR_LEN + (len))
 
 #define CMSG_COMPAT_FIRSTHDR(msg)			\
 	(((msg)->msg_controllen) >= sizeof(struct compat_cmsghdr) ?	\
@@ -141,9 +141,8 @@ int cmsghdr_from_user_compat_to_kern(struct msghdr *kmsg, struct sock *sk,
 		if (!CMSG_COMPAT_OK(ucmlen, ucmsg, kmsg))
 			return -EINVAL;
 
-		tmp = ((ucmlen - CMSG_COMPAT_ALIGN(sizeof(*ucmsg))) +
-		       CMSG_ALIGN(sizeof(struct cmsghdr)));
-		tmp = CMSG_ALIGN(tmp);
+		tmp = (ucmlen - CMSG_COMPAT_ALIGN_HDR_LEN);
+		tmp = CMSG_SPACE(tmp);
 		kcmlen += tmp;
 		ucmsg = cmsg_compat_nxthdr(kmsg, ucmsg, ucmlen);
 	}
@@ -168,9 +167,8 @@ int cmsghdr_from_user_compat_to_kern(struct msghdr *kmsg, struct sock *sk,
 			goto Efault;
 		if (!CMSG_COMPAT_OK(ucmlen, ucmsg, kmsg))
 			goto Einval;
-		tmp = ((ucmlen - CMSG_COMPAT_ALIGN(sizeof(*ucmsg))) +
-		       CMSG_ALIGN(sizeof(struct cmsghdr)));
-		if ((char *)kcmsg_base + kcmlen - (char *)kcmsg < CMSG_ALIGN(tmp))
+		tmp = (ucmlen - CMSG_COMPAT_ALIGN_HDR_LEN);
+		if ((char *)kcmsg_base + kcmlen - (char *)kcmsg < CMSG_SPACE(tmp))
 			goto Einval;
 		kcmsg->cmsg_len = tmp;
 		tmp = CMSG_ALIGN(tmp);
@@ -178,7 +176,7 @@ int cmsghdr_from_user_compat_to_kern(struct msghdr *kmsg, struct sock *sk,
 		    __get_user(kcmsg->cmsg_type, &ucmsg->cmsg_type) ||
 		    copy_from_user(CMSG_DATA(kcmsg),
 				   CMSG_COMPAT_DATA(ucmsg),
-				   (ucmlen - CMSG_COMPAT_ALIGN(sizeof(*ucmsg)))))
+				   (ucmlen - CMSG_COMPAT_ALIGN_HDR_LEN)))
 			goto Efault;
 
 		/* Advance. */
@@ -245,7 +243,8 @@ int put_cmsg_compat(struct msghdr *kmsg, int level, int type, int len, void *dat
 
 	if (copy_to_user(cm, &cmhdr, sizeof cmhdr))
 		return -EFAULT;
-	if (copy_to_user(CMSG_COMPAT_DATA(cm), data, cmlen - sizeof(struct compat_cmsghdr)))
+	if (cmlen > CMSG_COMPAT_ALIGN_HDR_LEN && 
+	    copy_to_user(CMSG_COMPAT_DATA(cm), data, cmlen - CMSG_COMPAT_ALIGN_HDR_LEN))
 		return -EFAULT;
 	cmlen = CMSG_COMPAT_SPACE(len);
 	if (kmsg->msg_controllen < cmlen)
@@ -258,12 +257,15 @@ int put_cmsg_compat(struct msghdr *kmsg, int level, int type, int len, void *dat
 void scm_detach_fds_compat(struct msghdr *kmsg, struct scm_cookie *scm)
 {
 	struct compat_cmsghdr __user *cm = (struct compat_cmsghdr __user *) kmsg->msg_control;
-	int fdmax = (kmsg->msg_controllen - sizeof(struct compat_cmsghdr)) / sizeof(int);
+	int fdmax = 0;
 	int fdnum = scm->fp->count;
 	struct file **fp = scm->fp->fp;
 	int __user *cmfptr;
 	int err = 0, i;
 
+	if (kmsg->msg_controllen > CMSG_COMPAT_ALIGN_HDR_LEN)
+		fdmax = (kmsg->msg_controllen - CMSG_COMPAT_ALIGN_HDR_LEN) / sizeof(int);
+
 	if (fdnum < fdmax)
 		fdmax = fdnum;
 
diff --git a/net/core/scm.c b/net/core/scm.c
index d882043..262c4cf 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -223,7 +223,7 @@ int put_cmsg(struct msghdr * msg, int level, int type, int len, void *data)
 	if (MSG_CMSG_COMPAT & msg->msg_flags)
 		return put_cmsg_compat(msg, level, type, len, data);
 
-	if (cm==NULL || msg->msg_controllen < sizeof(*cm)) {
+	if (cm == NULL || msg->msg_controllen < sizeof(*cm)) {
 		msg->msg_flags |= MSG_CTRUNC;
 		return 0; /* XXX: return error? check spec. */
 	}
@@ -238,7 +238,8 @@ int put_cmsg(struct msghdr * msg, int level, int type, int len, void *data)
 	err = -EFAULT;
 	if (copy_to_user(cm, &cmhdr, sizeof cmhdr))
 		goto out;
-	if (copy_to_user(CMSG_DATA(cm), data, cmlen - sizeof(struct cmsghdr)))
+	if (cmlen > CMSG_ALIGN_HDR_LEN && 
+	    copy_to_user(CMSG_DATA(cm), data, cmlen - CMSG_ALIGN_HDR_LEN))
 		goto out;
 	cmlen = CMSG_SPACE(len);
 	if (msg->msg_controllen < cmlen)
@@ -267,9 +268,8 @@ void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm)
 		return;
 	}
 
-	if (msg->msg_controllen > sizeof(struct cmsghdr))
-		fdmax = ((msg->msg_controllen - sizeof(struct cmsghdr))
-			 / sizeof(int));
+	if (msg->msg_controllen > CMSG_ALIGN_HDR_LEN)
+		fdmax = ((msg->msg_controllen - CMSG_ALIGN_HDR_LEN) / sizeof(int));
 
 	if (fdnum < fdmax)
 		fdmax = fdnum;
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 57e1405..a9d00db 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -272,7 +272,7 @@ int ip_cmsg_send(struct sock *sk, struct msghdr *msg, struct ipcm_cookie *ipc,
 			continue;
 		switch (cmsg->cmsg_type) {
 		case IP_RETOPTS:
-			err = cmsg->cmsg_len - CMSG_ALIGN(sizeof(struct cmsghdr));
+			err = cmsg->cmsg_len - CMSG_ALIGN_HDR_LEN;
 
 			/* Our caller is responsible for freeing ipc->opt */
 			err = ip_options_get(net, &ipc->opt, CMSG_DATA(cmsg),
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index b214a4d..acf4ca5 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -376,7 +376,7 @@ static int rxrpc_sendmsg_cmsg(struct msghdr *msg,
 		if (!CMSG_OK(msg, cmsg))
 			return -EINVAL;
 
-		len = cmsg->cmsg_len - CMSG_ALIGN(sizeof(struct cmsghdr));
+		len = cmsg->cmsg_len - CMSG_ALIGN_HDR_LEN;
 		_debug("CMSG %d, %d, %d",
 		       cmsg->cmsg_level, cmsg->cmsg_type, len);
 
diff --git a/net/socket.c b/net/socket.c
index 8487bf1..17f05ab 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1917,8 +1917,7 @@ static int ___sys_sendmsg(struct socket *sock, struct user_msghdr __user *msg,
 	    (struct compat_msghdr __user *)msg;
 	struct sockaddr_storage address;
 	struct iovec iovstack[UIO_FASTIOV], *iov = iovstack;
-	unsigned char ctl[sizeof(struct cmsghdr) + 20]
-				__aligned(sizeof(__kernel_size_t));
+	unsigned char ctl[CMSG_LEN(20)] __aligned(sizeof(__kernel_size_t));
 	/* 20 is size of ipv6_pktinfo */
 	unsigned char *ctl_buf = ctl;
 	int ctl_len;
-- 
2.7.4
