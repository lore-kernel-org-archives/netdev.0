From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 3/6] net: Add MSG_BATCH flag
Date: Fri, 20 Nov 2015 13:21:57 -0800
Message-ID: <1448054520-1464587-4-git-send-email-tom@herbertland.com>
References: <1448054520-1464587-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <davewatson@fb.com>,
	<alexei.starovoitov@gmail.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:60749 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934593AbbKTVWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 16:22:22 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tAKLIevb028205
	for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 13:22:22 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1y9us1bn3a-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 13:22:22 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 c8dad8e08fcc11e5bc8d24be0595f910-165fb230 for <netdev@vger.kernel.org>;	Fri,
 20 Nov 2015 13:22:21 -0800
In-Reply-To: <1448054520-1464587-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new msg flag called MSG_BATCH. This flag is used in sendmsg to
indicate that more messages will follow (i.e. a batch of messages is
being sent). This is similar to MSG_MORE except that the following
messages are not merged into one packet, they are sent individually.

MSG_BATCH is a performance optimization in cases where a socket
implementation can benefit by transmitting packets in a batch.

This patch also updates sendmmsg so that each contained message except
for the last one is marked as MSG_BATCH.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/socket.h |  1 +
 net/socket.c           | 17 +++++++++++++----
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 5bf59c8..d834af2 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -274,6 +274,7 @@ struct ucred {
 #define MSG_MORE	0x8000	/* Sender will send more */
 #define MSG_WAITFORONE	0x10000	/* recvmmsg(): block until 1+ packets avail */
 #define MSG_SENDPAGE_NOTLAST 0x20000 /* sendpage() internal : not the last page */
+#define MSG_BATCH	0x40000 /* sendmmsg(): more messages coming */
 #define MSG_EOF         MSG_FIN
 
 #define MSG_FASTOPEN	0x20000000	/* Send data in TCP SYN */
diff --git a/net/socket.c b/net/socket.c
index 21373f8..ef64b72 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1880,7 +1880,7 @@ static int copy_msghdr_from_user(struct msghdr *kmsg,
 
 static int ___sys_sendmsg(struct socket *sock, struct user_msghdr __user *msg,
 			 struct msghdr *msg_sys, unsigned int flags,
-			 struct used_address *used_address)
+			 struct used_address *used_address, bool doing_mmsg)
 {
 	struct compat_msghdr __user *msg_compat =
 	    (struct compat_msghdr __user *)msg;
@@ -1906,6 +1906,8 @@ static int ___sys_sendmsg(struct socket *sock, struct user_msghdr __user *msg,
 
 	if (msg_sys->msg_controllen > INT_MAX)
 		goto out_freeiov;
+	if (doing_mmsg)
+		flags |= (msg_sys->msg_flags & MSG_EOR);
 	ctl_len = msg_sys->msg_controllen;
 	if ((MSG_CMSG_COMPAT & flags) && ctl_len) {
 		err =
@@ -1984,7 +1986,7 @@ long __sys_sendmsg(int fd, struct user_msghdr __user *msg, unsigned flags)
 	if (!sock)
 		goto out;
 
-	err = ___sys_sendmsg(sock, msg, &msg_sys, flags, NULL);
+	err = ___sys_sendmsg(sock, msg, &msg_sys, flags, NULL, false);
 
 	fput_light(sock->file, fput_needed);
 out:
@@ -2011,6 +2013,7 @@ int __sys_sendmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 	struct compat_mmsghdr __user *compat_entry;
 	struct msghdr msg_sys;
 	struct used_address used_address;
+	unsigned int oflags = flags;
 
 	if (vlen > UIO_MAXIOV)
 		vlen = UIO_MAXIOV;
@@ -2025,11 +2028,16 @@ int __sys_sendmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 	entry = mmsg;
 	compat_entry = (struct compat_mmsghdr __user *)mmsg;
 	err = 0;
+	flags |= MSG_BATCH;
 
 	while (datagrams < vlen) {
+		if (datagrams == vlen - 1)
+			flags = oflags;
+
 		if (MSG_CMSG_COMPAT & flags) {
 			err = ___sys_sendmsg(sock, (struct user_msghdr __user *)compat_entry,
-					     &msg_sys, flags, &used_address);
+					     &msg_sys, flags, &used_address,
+					     true);
 			if (err < 0)
 				break;
 			err = __put_user(err, &compat_entry->msg_len);
@@ -2037,7 +2045,8 @@ int __sys_sendmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 		} else {
 			err = ___sys_sendmsg(sock,
 					     (struct user_msghdr __user *)entry,
-					     &msg_sys, flags, &used_address);
+					     &msg_sys, flags, &used_address,
+					     true);
 			if (err < 0)
 				break;
 			err = put_user(err, &entry->msg_len);
-- 
2.4.6
