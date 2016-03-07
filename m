From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 04/13] net: Add MSG_BATCH flag
Date: Mon, 7 Mar 2016 14:11:03 -0800
Message-ID: <1457388672-2600559-5-git-send-email-tom@herbertland.com>
References: <1457388672-2600559-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:6114 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753664AbcCGWL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 17:11:59 -0500
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u27MABQl022008
	for <netdev@vger.kernel.org>; Mon, 7 Mar 2016 14:11:58 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 21hh470b0c-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 14:11:58 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 9b8c2878e4b111e599860002c9521c9e-b91d7420 for <netdev@vger.kernel.org>;	Mon,
 07 Mar 2016 14:11:57 -0800
In-Reply-To: <1457388672-2600559-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new msg flag called MSG_BATCH. This flag is used in sendmsg to
indicate that more messages will follow (i.e. a batch of messages is
being sent). This is similar to MSG_MORE except that the following
messages are not merged into one packet, they are sent individually.
sendmmsg is updated so that each contained message except for the
last one is marked as MSG_BATCH.

MSG_BATCH is a performance optimization in cases where a socket
implementation can benefit by transmitting packets in a batch.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/socket.h | 1 +
 net/socket.c           | 5 +++++
 2 files changed, 6 insertions(+)

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
index 0dd4dd8..886649c 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2008,6 +2008,7 @@ int __sys_sendmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 	struct compat_mmsghdr __user *compat_entry;
 	struct msghdr msg_sys;
 	struct used_address used_address;
+	unsigned int oflags = flags;
 
 	if (vlen > UIO_MAXIOV)
 		vlen = UIO_MAXIOV;
@@ -2022,8 +2023,12 @@ int __sys_sendmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
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
 					     &msg_sys, flags, &used_address, MSG_EOR);
-- 
2.6.5
