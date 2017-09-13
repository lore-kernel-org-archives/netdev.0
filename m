From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCHv2 iproute2 1/2] lib/libnetlink: re malloc buff if size is not enough
Date: Wed, 13 Sep 2017 17:59:39 +0800
Message-ID: <1505296780-8444-2-git-send-email-liuhangbin@gmail.com>
References: <1505296780-8444-1-git-send-email-liuhangbin@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Michal Kubecek <mkubecek@suse.cz>, Phil Sutter <phil@nwl.cc>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:37050 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751714AbdIMKAT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 06:00:19 -0400
Received: by mail-pg0-f66.google.com with SMTP id v5so7419496pgn.4
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2017 03:00:19 -0700 (PDT)
In-Reply-To: <1505296780-8444-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With commit 72b365e8e0fd ("libnetlink: Double the dump buffer size")
we doubled the buffer size to support more VFs. But the VFs number is
increasing all the time. Some customers even use more than 200 VFs now.

We could not double it everytime when the buffer is not enough. Let's just
not hard code the buffer size and malloc the correct number when running.

Introduce function rtnl_recvmsg() to always return a newly allocated buffer.
The caller need to free it after using.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/libnetlink.c | 112 ++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 78 insertions(+), 34 deletions(-)

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index be7ac86..e3fa7cf 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -402,6 +402,62 @@ static void rtnl_dump_error(const struct rtnl_handle *rth,
 	}
 }
 
+static int rtnl_recvmsg(int fd, struct msghdr *msg, char **answer)
+{
+	struct iovec *iov;
+	int len = -1, buf_len = 32768;
+	char *bufp, *buf = NULL;
+
+	int flag = MSG_PEEK | MSG_TRUNC;
+
+realloc:
+	bufp = realloc(buf, buf_len);
+
+	if (bufp == NULL) {
+		fprintf(stderr, "malloc error: not enough buffer\n");
+		free(buf);
+		return -ENOMEM;
+	}
+	buf = bufp;
+	iov = msg->msg_iov;
+	iov->iov_base = buf;
+	iov->iov_len = buf_len;
+
+recv:
+	len = recvmsg(fd, msg, flag);
+
+	if (len < 0) {
+		if (errno == EINTR || errno == EAGAIN)
+			goto recv;
+		fprintf(stderr, "netlink receive error %s (%d)\n",
+			strerror(errno), errno);
+		return len;
+	}
+
+	if (len == 0) {
+		fprintf(stderr, "EOF on netlink\n");
+		return -ENODATA;
+	}
+
+	if (len > buf_len) {
+		buf_len = len;
+		flag = 0;
+		goto realloc;
+	}
+
+	if (flag != 0) {
+		flag = 0;
+		goto recv;
+	}
+
+	if (answer)
+		*answer = buf;
+	else
+		free(buf);
+
+	return len;
+}
+
 int rtnl_dump_filter_l(struct rtnl_handle *rth,
 		       const struct rtnl_dump_filter_arg *arg)
 {
@@ -413,31 +469,18 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
 		.msg_iov = &iov,
 		.msg_iovlen = 1,
 	};
-	char buf[32768];
+	char *buf;
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
 
 		if (rth->dump_fp)
 			fwrite(buf, 1, NLMSG_ALIGN(status), rth->dump_fp);
@@ -462,8 +505,10 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
 
 				if (h->nlmsg_type == NLMSG_DONE) {
 					err = rtnl_dump_done(h);
-					if (err < 0)
+					if (err < 0) {
+						free(buf);
 						return -1;
+					}
 
 					found_done = 1;
 					break; /* process next filter */
@@ -471,19 +516,23 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
 
 				if (h->nlmsg_type == NLMSG_ERROR) {
 					rtnl_dump_error(rth, h);
+					free(buf);
 					return -1;
 				}
 
 				if (!rth->dump_fp) {
 					err = a->filter(&nladdr, h, a->arg1);
-					if (err < 0)
+					if (err < 0) {
+						free(buf);
 						return err;
+					}
 				}
 
 skip_it:
 				h = NLMSG_NEXT(h, msglen);
 			}
 		}
+		free(buf);
 
 		if (found_done) {
 			if (dump_intr)
@@ -543,7 +592,7 @@ static int __rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 		.msg_iov = &iov,
 		.msg_iovlen = 1,
 	};
-	char   buf[32768] = {};
+	char *buf;
 
 	n->nlmsg_seq = seq = ++rtnl->seq;
 
@@ -556,22 +605,12 @@ static int __rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
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
@@ -585,6 +624,7 @@ static int __rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 			if (l < 0 || len > status) {
 				if (msg.msg_flags & MSG_TRUNC) {
 					fprintf(stderr, "Truncated message\n");
+					free(buf);
 					return -1;
 				}
 				fprintf(stderr,
@@ -611,6 +651,7 @@ static int __rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 					if (answer)
 						memcpy(answer, h,
 						       MIN(maxlen, h->nlmsg_len));
+					free(buf);
 					return 0;
 				}
 
@@ -619,12 +660,14 @@ static int __rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 					rtnl_talk_error(h, err, errfn);
 
 				errno = -err->error;
+				free(buf);
 				return -1;
 			}
 
 			if (answer) {
 				memcpy(answer, h,
 				       MIN(maxlen, h->nlmsg_len));
+				free(buf);
 				return 0;
 			}
 
@@ -633,6 +676,7 @@ static int __rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 			status -= NLMSG_ALIGN(len);
 			h = (struct nlmsghdr *)((char *)h + NLMSG_ALIGN(len));
 		}
+		free(buf);
 
 		if (msg.msg_flags & MSG_TRUNC) {
 			fprintf(stderr, "Message truncated\n");
-- 
2.5.5
