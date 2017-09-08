From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH iproute2 1/2] lib/libnetlink: re malloc buff if size is not enough
Date: Fri,  8 Sep 2017 18:14:56 +0800
Message-ID: <1504865697-27274-2-git-send-email-liuhangbin@gmail.com>
References: <1504865697-27274-1-git-send-email-liuhangbin@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Michal Kubecek <mkubecek@suse.cz>, Phil Sutter <phil@nwl.cc>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36824 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752372AbdIHKPf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 06:15:35 -0400
Received: by mail-pg0-f68.google.com with SMTP id d8so1126807pgt.3
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 03:15:35 -0700 (PDT)
In-Reply-To: <1504865697-27274-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With commit 72b365e8e0fd ("libnetlink: Double the dump buffer size")
we doubled the buffer size to support more VFs. But the VFs number is
increasing all the time. Some customers even use more than 200 VFs now.

We could not double it everytime when the buffer is not enough. Let's just
not hard code the buffer size and malloc the correct number when running.

Introduce a new function rtnl_recvmsg() to get correct buffer.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 lib/libnetlink.c | 98 ++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 66 insertions(+), 32 deletions(-)

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index be7ac86..37cfb5a 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -402,6 +402,59 @@ static void rtnl_dump_error(const struct rtnl_handle *rth,
 	}
 }
 
+static int rtnl_recvmsg(int fd, struct msghdr *msg, char **buf)
+{
+	struct iovec *iov;
+	int len = -1, buf_len = 32768;
+	char *buffer = *buf;
+
+	int flag = MSG_PEEK | MSG_TRUNC;
+
+	if (buffer == NULL)
+re_malloc:
+		buffer = malloc(buf_len);
+
+	if (buffer == NULL) {
+		fprintf(stderr, "malloc error: no enough buffer\n");
+		return -1;
+	}
+
+	iov = msg->msg_iov;
+	iov->iov_base = buffer;
+	iov->iov_len = buf_len;
+
+re_recv:
+	len = recvmsg(fd, msg, flag);
+
+	if (len < 0) {
+		if (errno == EINTR || errno == EAGAIN)
+			return 0;
+		fprintf(stderr, "netlink receive error %s (%d)\n",
+			strerror(errno), errno);
+		return len;
+	}
+
+	if (len == 0) {
+		fprintf(stderr, "EOF on netlink\n");
+		return -1;
+	}
+
+	if (len > buf_len) {
+		free(buffer);
+		buf_len = len;
+		flag = 0;
+		goto re_malloc;
+	}
+
+	if (flag != 0) {
+		flag = 0;
+		goto re_recv;
+	}
+
+	*buf = buffer;
+	return len;
+}
+
 int rtnl_dump_filter_l(struct rtnl_handle *rth,
 		       const struct rtnl_dump_filter_arg *arg)
 {
@@ -413,31 +466,20 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
 		.msg_iov = &iov,
 		.msg_iovlen = 1,
 	};
-	char buf[32768];
+	static char *buf = NULL;
 	int dump_intr = 0;
 
-	iov.iov_base = buf;
 	while (1) {
 		int status;
 		const struct rtnl_dump_filter_arg *a;
 		int found_done = 0;
 		int msglen = 0;
 
-		iov.iov_len = sizeof(buf);
-		status = recvmsg(rth->fd, &msg, 0);
-
-		if (status < 0) {
-			if (errno == EINTR || errno == EAGAIN)
-				continue;
-			fprintf(stderr, "netlink receive error %s (%d)\n",
-				strerror(errno), errno);
-			return -1;
-		}
-
-		if (status == 0) {
-			fprintf(stderr, "EOF on netlink\n");
-			return -1;
-		}
+		status = rtnl_recvmsg(rth->fd, &msg, &buf);
+		if (status < 0)
+			return status;
+		else if (status == 0)
+			continue;
 
 		if (rth->dump_fp)
 			fwrite(buf, 1, NLMSG_ALIGN(status), rth->dump_fp);
@@ -543,7 +585,7 @@ static int __rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 		.msg_iov = &iov,
 		.msg_iovlen = 1,
 	};
-	char   buf[32768] = {};
+	static char *buf = NULL;
 
 	n->nlmsg_seq = seq = ++rtnl->seq;
 
@@ -556,22 +598,14 @@ static int __rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 		return -1;
 	}
 
-	iov.iov_base = buf;
 	while (1) {
-		iov.iov_len = sizeof(buf);
-		status = recvmsg(rtnl->fd, &msg, 0);
+		status = rtnl_recvmsg(rtnl->fd, &msg, &buf);
+
+		if (status < 0)
+			return status;
+		else if (status == 0)
+			continue;
 
-		if (status < 0) {
-			if (errno == EINTR || errno == EAGAIN)
-				continue;
-			fprintf(stderr, "netlink receive error %s (%d)\n",
-				strerror(errno), errno);
-			return -1;
-		}
-		if (status == 0) {
-			fprintf(stderr, "EOF on netlink\n");
-			return -1;
-		}
 		if (msg.msg_namelen != sizeof(nladdr)) {
 			fprintf(stderr,
 				"sender address length == %d\n",
-- 
2.5.5
