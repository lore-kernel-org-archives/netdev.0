From: Hangbin Liu <haliu@redhat.com>
Subject: [PATCHv4 iproute2 1/2] lib/libnetlink: re malloc buff if size is not enough
Date: Thu, 28 Sep 2017 21:33:45 +0800
Message-ID: <1506605626-1744-2-git-send-email-haliu@redhat.com>
References: <1506605626-1744-1-git-send-email-haliu@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Michal Kubecek <mkubecek@suse.cz>, Phil Sutter <phil@nwl.cc>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52354 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753198AbdI1NeC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 28 Sep 2017 09:34:02 -0400
In-Reply-To: <1506605626-1744-1-git-send-email-haliu@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hangbin Liu <liuhangbin@gmail.com>

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
 lib/libnetlink.c | 114 ++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 80 insertions(+), 34 deletions(-)

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index be7ac86..1847c0b 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -402,6 +402,64 @@ static void rtnl_dump_error(const struct rtnl_handle *rth,
 	}
 }
 
+static int __rtnl_recvmsg(int fd, struct msghdr *msg, int flags)
+{
+	int len;
+
+	do {
+		len = recvmsg(fd, msg, flags);
+	} while (len < 0 && (errno == EINTR || errno == EAGAIN));
+
+	if (len < 0) {
+		fprintf(stderr, "netlink receive error %s (%d)\n",
+			strerror(errno), errno);
+		return -errno;
+	}
+
+	if (len == 0) {
+		fprintf(stderr, "EOF on netlink\n");
+		return -ENODATA;
+	}
+
+	return len;
+}
+
+static int rtnl_recvmsg(int fd, struct msghdr *msg, char **answer)
+{
+	struct iovec *iov = msg->msg_iov;
+	char *buf;
+	int len;
+
+	iov->iov_base = NULL;
+	iov->iov_len = 0;
+
+	len = __rtnl_recvmsg(fd, msg, MSG_PEEK | MSG_TRUNC);
+	if (len < 0)
+		return len;
+
+	buf = malloc(len);
+	if (!buf) {
+		fprintf(stderr, "malloc error: not enough buffer\n");
+		return -ENOMEM;
+	}
+
+	iov->iov_base = buf;
+	iov->iov_len = len;
+
+	len = __rtnl_recvmsg(fd, msg, 0);
+	if (len < 0) {
+		free(buf);
+		return len;
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
@@ -413,31 +471,18 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
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
@@ -462,8 +507,10 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
 
 				if (h->nlmsg_type == NLMSG_DONE) {
 					err = rtnl_dump_done(h);
-					if (err < 0)
+					if (err < 0) {
+						free(buf);
 						return -1;
+					}
 
 					found_done = 1;
 					break; /* process next filter */
@@ -471,19 +518,23 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
 
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
@@ -543,7 +594,7 @@ static int __rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 		.msg_iov = &iov,
 		.msg_iovlen = 1,
 	};
-	char   buf[32768] = {};
+	char *buf;
 
 	n->nlmsg_seq = seq = ++rtnl->seq;
 
@@ -556,22 +607,12 @@ static int __rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
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
@@ -585,6 +626,7 @@ static int __rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 			if (l < 0 || len > status) {
 				if (msg.msg_flags & MSG_TRUNC) {
 					fprintf(stderr, "Truncated message\n");
+					free(buf);
 					return -1;
 				}
 				fprintf(stderr,
@@ -611,6 +653,7 @@ static int __rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 					if (answer)
 						memcpy(answer, h,
 						       MIN(maxlen, h->nlmsg_len));
+					free(buf);
 					return 0;
 				}
 
@@ -619,12 +662,14 @@ static int __rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
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
 
@@ -633,6 +678,7 @@ static int __rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 			status -= NLMSG_ALIGN(len);
 			h = (struct nlmsghdr *)((char *)h + NLMSG_ALIGN(len));
 		}
+		free(buf);
 
 		if (msg.msg_flags & MSG_TRUNC) {
 			fprintf(stderr, "Message truncated\n");
-- 
2.5.5
