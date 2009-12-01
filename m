From: Arnaldo Carvalho de Melo <acme@infradead.org>
Subject: [PATCH 1/1] net: compat_mmsghdr must be used in sys_recvmmsg
Date: Tue,  1 Dec 2009 16:47:26 -0200
Message-ID: <1259693246-30341-1-git-send-email-acme@infradead.org>
Cc: netdev@vger.kernel.org,
	Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:52873 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320AbZLASrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 13:47:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>

Both to traverse the entries and to set the msg_len field.

Commiter note: folded two patches and avoided one branch repeating the
compat test.

Signed-off-by: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/socket.c |   24 ++++++++++++++++++------
 1 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 402abb3..b94c3dd 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2144,6 +2144,7 @@ int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 	int fput_needed, err, datagrams;
 	struct socket *sock;
 	struct mmsghdr __user *entry;
+	struct compat_mmsghdr __user *compat_entry;
 	struct msghdr msg_sys;
 	struct timespec end_time;
 
@@ -2163,19 +2164,30 @@ int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 		goto out_put;
 
 	entry = mmsg;
+	compat_entry = (struct compat_mmsghdr __user *)mmsg;
 
 	while (datagrams < vlen) {
 		/*
 		 * No need to ask LSM for more than the first datagram.
 		 */
-		err = __sys_recvmsg(sock, (struct msghdr __user *)entry,
-				    &msg_sys, flags, datagrams);
-		if (err < 0)
-			break;
-		err = put_user(err, &entry->msg_len);
+		if (MSG_CMSG_COMPAT & flags) {
+			err = __sys_recvmsg(sock, (struct msghdr __user *)compat_entry,
+					    &msg_sys, flags, datagrams);
+			if (err < 0)
+				break;
+			err = __put_user(err, &compat_entry->msg_len);
+			++compat_entry;
+		} else {
+			err = __sys_recvmsg(sock, (struct msghdr __user *)entry,
+					    &msg_sys, flags, datagrams);
+			if (err < 0)
+				break;
+			err = put_user(err, &entry->msg_len);
+			++entry;
+		}
+
 		if (err)
 			break;
-		++entry;
 		++datagrams;
 
 		if (timeout) {
-- 
1.6.2.5

