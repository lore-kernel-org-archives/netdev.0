From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ss: Use rtnl_dump_filter for inet_show_netlink
Date: Fri, 26 Dec 2014 04:26:27 +0200
Message-ID: <1419560787-7665-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:50570 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800AbaLZCgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2014 21:36:36 -0500
Received: by mail-lb0-f169.google.com with SMTP id p9so8254086lbv.28
        for <netdev@vger.kernel.org>; Thu, 25 Dec 2014 18:36:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Just another refactoring for ss to use rtnl API from lib

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
It would be good to make better testing with opened different
kind of sockets to test if ss behaves correctly and does not
shows any errors.

 include/libnetlink.h |   1 +
 lib/libnetlink.c     |  17 +++++--
 misc/ss.c            | 139 ++++++++++++++-------------------------------------
 3 files changed, 50 insertions(+), 107 deletions(-)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index 3794ef1..db04969 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -19,6 +19,7 @@ struct rtnl_handle
 	__u32			seq;
 	__u32			dump;
 	int			proto;
+	FILE		       *dump_fp;
 };
 
 extern int rcvbuf;
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index e3b7862..45ff90a 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -220,12 +220,15 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
 			return -1;
 		}
 
+		if (rth->dump_fp)
+			fwrite(buf, 1, NLMSG_ALIGN(status), rth->dump_fp);
+
 		for (a = arg; a->filter; a++) {
 			struct nlmsghdr *h = (struct nlmsghdr*)buf;
 			msglen = status;
 
 			while (NLMSG_OK(h, msglen)) {
-				int err;
+				int err = 0;
 
 				if (nladdr.nl_pid != 0 ||
 				    h->nlmsg_pid != rth->local.nl_pid ||
@@ -247,16 +250,20 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
 					} else {
 						errno = -err->error;
 						if (rth->proto == NETLINK_SOCK_DIAG &&
-						    errno == ENOENT)
+						    (errno == ENOENT ||
+						     errno == EOPNOTSUPP))
 							return -1;
 
 						perror("RTNETLINK answers");
 					}
 					return -1;
 				}
-				err = a->filter(&nladdr, h, a->arg1);
-				if (err < 0)
-					return err;
+
+				if (!rth->dump_fp) {
+					err = a->filter(&nladdr, h, a->arg1);
+					if (err < 0)
+						return err;
+				}
 
 skip_it:
 				h = NLMSG_NEXT(h, msglen);
diff --git a/misc/ss.c b/misc/ss.c
index 706b5ba..f0c7b34 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1871,122 +1871,57 @@ static int sockdiag_send(int family, int fd, int protocol, struct filter *f)
 	return 0;
 }
 
-static int inet_show_netlink(struct filter *f, FILE *dump_fp, int protocol)
-{
-	int fd, family;
-	struct sockaddr_nl nladdr;
-	struct msghdr msg;
-	char	buf[16384];
-	struct iovec iov[3];
-
-	if ((fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_INET_DIAG)) < 0)
-		return -1;
-
-	family = PF_INET;
-again:
-	if (sockdiag_send(family, fd, protocol, f))
-		return -1;
-
-	memset(&nladdr, 0, sizeof(nladdr));
-	nladdr.nl_family = AF_NETLINK;
-
-	iov[0] = (struct iovec){
-		.iov_base = buf,
-		.iov_len = sizeof(buf)
-	};
-
-	while (1) {
-		int status;
-		struct nlmsghdr *h;
-
-		msg = (struct msghdr) {
-			(void*)&nladdr, sizeof(nladdr),
-			iov,	1,
-			NULL,	0,
-			0
-		};
-
-		status = recvmsg(fd, &msg, 0);
-
-		if (status < 0) {
-			if (errno == EINTR)
-				continue;
-			perror("OVERRUN");
-			continue;
-		}
-		if (status == 0) {
-			fprintf(stderr, "EOF on netlink\n");
-			close(fd);
-			return 0;
-		}
-
-		if (dump_fp)
-			fwrite(buf, 1, NLMSG_ALIGN(status), dump_fp);
+struct inet_diag_arg {
+	struct filter *f;
+	int protocol;
+};
 
-		h = (struct nlmsghdr*)buf;
-		while (NLMSG_OK(h, status)) {
-			int err;
-			struct inet_diag_msg *r = NLMSG_DATA(h);
+static int show_one_inet_sock(const struct sockaddr_nl *addr,
+		struct nlmsghdr *h, void *arg)
+{
+	int err;
+	struct inet_diag_arg *diag_arg = arg;
+	struct inet_diag_msg *r = NLMSG_DATA(h);
 
-			if (/*h->nlmsg_pid != rth->local.nl_pid ||*/
-			    h->nlmsg_seq != MAGIC_SEQ)
-				goto skip_it;
+	if (!(diag_arg->f->families & (1 << r->idiag_family)))
+		return 0;
+	if ((err = inet_show_sock(h, NULL, diag_arg->protocol)) < 0)
+		return err;
 
-			if (h->nlmsg_type == NLMSG_DONE)
-				goto done;
+	return 0;
+}
 
-			if (h->nlmsg_type == NLMSG_ERROR) {
-				struct nlmsgerr *err = (struct nlmsgerr*)NLMSG_DATA(h);
-				if (h->nlmsg_len < NLMSG_LENGTH(sizeof(struct nlmsgerr))) {
-					fprintf(stderr, "ERROR truncated\n");
-				} else {
-					if (family != PF_UNSPEC) {
-						family = PF_UNSPEC;
-						goto again;
-					}
+static int inet_show_netlink(struct filter *f, FILE *dump_fp, int protocol)
+{
+	int err = 0;
+	struct rtnl_handle rth;
+	int family = PF_INET;
+	struct inet_diag_arg arg = { .f = f, .protocol = protocol };
 
-					errno = -err->error;
-					if (errno == EOPNOTSUPP) {
-						close(fd);
-						return -1;
-					}
-					perror("TCPDIAG answers");
-				}
+	if (rtnl_open_byproto(&rth, 0, NETLINK_SOCK_DIAG))
+		return -1;
+	rth.dump = MAGIC_SEQ;
+	rth.dump_fp = dump_fp;
 
-				goto done;
-			}
-			if (!dump_fp) {
-				if (!(f->families & (1<<r->idiag_family))) {
-					h = NLMSG_NEXT(h, status);
-					continue;
-				}
-				err = inet_show_sock(h, NULL, protocol);
-				if (err < 0) {
-					close(fd);
-					return err;
-				}
-			}
+again:
+	if ((err = sockdiag_send(family, rth.fd, protocol, f)))
+		goto Exit;
 
-skip_it:
-			h = NLMSG_NEXT(h, status);
-		}
-		if (msg.msg_flags & MSG_TRUNC) {
-			fprintf(stderr, "Message truncated\n");
-			continue;
-		}
-		if (status) {
-			fprintf(stderr, "!!!Remnant of size %d\n", status);
-			exit(1);
+	if ((err = rtnl_dump_filter(&rth, show_one_inet_sock, &arg))) {
+		if (family != PF_UNSPEC) {
+			family = PF_UNSPEC;
+			goto again;
 		}
+		goto Exit;
 	}
-done:
 	if (family == PF_INET) {
 		family = PF_INET6;
 		goto again;
 	}
 
-	close(fd);
-	return 0;
+Exit:
+	rtnl_close(&rth);
+	return err;
 }
 
 static int tcp_show_netlink_file(struct filter *f)
-- 
2.1.3
