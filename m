From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 03/13] net: Allow MSG_EOR in each msghdr of sendmmsg
Date: Mon, 7 Mar 2016 14:11:02 -0800
Message-ID: <1457388672-2600559-4-git-send-email-tom@herbertland.com>
References: <1457388672-2600559-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45614 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753660AbcCGWL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 17:11:58 -0500
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.15.0.59/8.15.0.59) with SMTP id u27M8dmL006509
	for <netdev@vger.kernel.org>; Mon, 7 Mar 2016 14:11:56 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 21futqhk25-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 14:11:56 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 998df01ae4b111e599860002c9521c9e-b91d7420 for <netdev@vger.kernel.org>;	Mon,
 07 Mar 2016 14:11:54 -0800
In-Reply-To: <1457388672-2600559-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows setting MSG_EOR in each individual msghdr passed
in sendmmsg. This allows a sendmmsg to send multiple messages when
using SOCK_SEQPACKET.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/socket.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 38a78d4..0dd4dd8 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1875,7 +1875,8 @@ static int copy_msghdr_from_user(struct msghdr *kmsg,
 
 static int ___sys_sendmsg(struct socket *sock, struct user_msghdr __user *msg,
 			 struct msghdr *msg_sys, unsigned int flags,
-			 struct used_address *used_address)
+			 struct used_address *used_address,
+			 unsigned int allowed_msghdr_flags)
 {
 	struct compat_msghdr __user *msg_compat =
 	    (struct compat_msghdr __user *)msg;
@@ -1901,6 +1902,7 @@ static int ___sys_sendmsg(struct socket *sock, struct user_msghdr __user *msg,
 
 	if (msg_sys->msg_controllen > INT_MAX)
 		goto out_freeiov;
+	flags |= (msg_sys->msg_flags & allowed_msghdr_flags);
 	ctl_len = msg_sys->msg_controllen;
 	if ((MSG_CMSG_COMPAT & flags) && ctl_len) {
 		err =
@@ -1979,7 +1981,7 @@ long __sys_sendmsg(int fd, struct user_msghdr __user *msg, unsigned flags)
 	if (!sock)
 		goto out;
 
-	err = ___sys_sendmsg(sock, msg, &msg_sys, flags, NULL);
+	err = ___sys_sendmsg(sock, msg, &msg_sys, flags, NULL, 0);
 
 	fput_light(sock->file, fput_needed);
 out:
@@ -2024,7 +2026,7 @@ int __sys_sendmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 	while (datagrams < vlen) {
 		if (MSG_CMSG_COMPAT & flags) {
 			err = ___sys_sendmsg(sock, (struct user_msghdr __user *)compat_entry,
-					     &msg_sys, flags, &used_address);
+					     &msg_sys, flags, &used_address, MSG_EOR);
 			if (err < 0)
 				break;
 			err = __put_user(err, &compat_entry->msg_len);
@@ -2032,7 +2034,7 @@ int __sys_sendmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 		} else {
 			err = ___sys_sendmsg(sock,
 					     (struct user_msghdr __user *)entry,
-					     &msg_sys, flags, &used_address);
+					     &msg_sys, flags, &used_address, MSG_EOR);
 			if (err < 0)
 				break;
 			err = put_user(err, &entry->msg_len);
-- 
2.6.5
