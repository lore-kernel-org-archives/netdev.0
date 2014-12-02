From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ss: Use rtnl_dump_filter in handle_netlink_request
Date: Tue,  2 Dec 2014 16:53:04 +0200
Message-ID: <1417531984-3522-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:41549 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263AbaLBPCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 10:02:49 -0500
Received: by mail-lb0-f175.google.com with SMTP id u10so10792931lbd.34
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 07:02:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replaced handling netlink messages by rtnl_dump_filter
from lib/libnetlink.c, also:

    - removed unused dump_fp arg;
    - added MAGIC_SEQ #define for 123456 seq id

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 128 ++++++++++++++++++--------------------------------------------
 1 file changed, 36 insertions(+), 92 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index a99294d..1c0ece2 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -41,6 +41,8 @@
 #include <linux/packet_diag.h>
 #include <linux/netlink_diag.h>
 
+#define MAGIC_SEQ 123456
+
 #define DIAG_REQUEST(_req, _r)						    \
 	struct {							    \
 		struct nlmsghdr nlh;					    \
@@ -49,7 +51,7 @@
 		.nlh = {						    \
 			.nlmsg_type = SOCK_DIAG_BY_FAMILY,		    \
 			.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST,\
-			.nlmsg_seq = 123456,				    \
+			.nlmsg_seq = MAGIC_SEQ,				    \
 			.nlmsg_len = sizeof(_req),			    \
 		},							    \
 	}
@@ -1777,7 +1779,7 @@ static int tcpdiag_send(int fd, int protocol, struct filter *f)
 		req.nlh.nlmsg_type = DCCPDIAG_GETSOCK;
 	req.nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
 	req.nlh.nlmsg_pid = 0;
-	req.nlh.nlmsg_seq = 123456;
+	req.nlh.nlmsg_seq = MAGIC_SEQ;
 	memset(&req.r, 0, sizeof(req.r));
 	req.r.idiag_family = AF_INET;
 	req.r.idiag_states = f->states;
@@ -1937,7 +1939,7 @@ again:
 			struct inet_diag_msg *r = NLMSG_DATA(h);
 
 			if (/*h->nlmsg_pid != rth->local.nl_pid ||*/
-			    h->nlmsg_seq != 123456)
+			    h->nlmsg_seq != MAGIC_SEQ)
 				goto skip_it;
 
 			if (h->nlmsg_type == NLMSG_DONE)
@@ -2422,8 +2424,10 @@ static void unix_list_print(struct unixstat *list, struct filter *f)
 	}
 }
 
-static int unix_show_sock(struct nlmsghdr *nlh, struct filter *f)
+static int unix_show_sock(const struct sockaddr_nl *addr, struct nlmsghdr *nlh,
+		void *arg)
 {
+	struct filter *f = (struct filter *)arg;
 	struct unix_diag_msg *r = NLMSG_DATA(nlh);
 	struct rtattr *tb[UNIX_DIAG_MAX+1];
 	char name[128];
@@ -2512,90 +2516,30 @@ static int unix_show_sock(struct nlmsghdr *nlh, struct filter *f)
 	return 0;
 }
 
-static int handle_netlink_request(struct filter *f, FILE *dump_fp,
-				  struct nlmsghdr *req, size_t size,
-				  int (* show_one_sock)(struct nlmsghdr *nlh, struct filter *f))
+static int handle_netlink_request(struct filter *f, struct nlmsghdr *req,
+		size_t size, rtnl_filter_t show_one_sock)
 {
-	int fd;
-	char	buf[16384];
+	int ret = -1;
+	struct rtnl_handle rth;
 
-	if ((fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_INET_DIAG)) < 0)
+	if (rtnl_open_byproto(&rth, 0, NETLINK_INET_DIAG))
 		return -1;
 
-	if (send(fd, req, size, 0) < 0) {
-		close(fd);
-		return -1;
-	}
+	rth.dump = MAGIC_SEQ;
 
-	while (1) {
-		ssize_t status;
-		struct nlmsghdr *h;
-		struct sockaddr_nl nladdr;
-		socklen_t slen = sizeof(nladdr);
+	if (rtnl_send(&rth, req, size) < 0)
+		goto Exit;
 
-		status = recvfrom(fd, buf, sizeof(buf), 0,
-				  (struct sockaddr *) &nladdr, &slen);
-		if (status < 0) {
-			if (errno == EINTR)
-				continue;
-			perror("OVERRUN");
-			continue;
-		}
-		if (status == 0) {
-			fprintf(stderr, "EOF on netlink\n");
-			goto close_it;
-		}
-
-		if (dump_fp)
-			fwrite(buf, 1, NLMSG_ALIGN(status), dump_fp);
-
-		h = (struct nlmsghdr*)buf;
-		while (NLMSG_OK(h, status)) {
-			int err;
+	if (rtnl_dump_filter(&rth, show_one_sock, f))
+		goto Exit;
 
-			if (/*h->nlmsg_pid != rth->local.nl_pid ||*/
-			    h->nlmsg_seq != 123456)
-				goto skip_it;
-
-			if (h->nlmsg_type == NLMSG_DONE)
-				goto close_it;
-
-			if (h->nlmsg_type == NLMSG_ERROR) {
-				struct nlmsgerr *err = (struct nlmsgerr*)NLMSG_DATA(h);
-				if (h->nlmsg_len < NLMSG_LENGTH(sizeof(struct nlmsgerr))) {
-					fprintf(stderr, "ERROR truncated\n");
-				} else {
-					errno = -err->error;
-					if (errno != ENOENT)
-						fprintf(stderr, "DIAG answers %d\n", errno);
-				}
-				close(fd);
-				return -1;
-			}
-			if (!dump_fp) {
-				err = show_one_sock(h, f);
-				if (err < 0) {
-					close(fd);
-					return err;
-				}
-			}
-
-skip_it:
-			h = NLMSG_NEXT(h, status);
-		}
-
-		if (status) {
-			fprintf(stderr, "!!!Remnant of size %zd\n", status);
-			exit(1);
-		}
-	}
-
-close_it:
-	close(fd);
-	return 0;
+	ret = 0;
+Exit:
+	rtnl_close(&rth);
+	return ret;
 }
 
-static int unix_show_netlink(struct filter *f, FILE *dump_fp)
+static int unix_show_netlink(struct filter *f)
 {
 	DIAG_REQUEST(req, struct unix_diag_req r);
 
@@ -2605,8 +2549,7 @@ static int unix_show_netlink(struct filter *f, FILE *dump_fp)
 	if (show_mem)
 		req.r.udiag_show |= UDIAG_SHOW_MEMINFO;
 
-	return handle_netlink_request(f, dump_fp, &req.nlh,
-					sizeof(req), unix_show_sock);
+	return handle_netlink_request(f, &req.nlh, sizeof(req), unix_show_sock);
 }
 
 static int unix_show(struct filter *f)
@@ -2619,7 +2562,7 @@ static int unix_show(struct filter *f)
 	struct unixstat *list = NULL;
 
 	if (!getenv("PROC_NET_UNIX") && !getenv("PROC_ROOT")
-	    && unix_show_netlink(f, NULL) == 0)
+	    && unix_show_netlink(f) == 0)
 		return 0;
 
 	if ((fp = net_unix_open()) == NULL)
@@ -2693,7 +2636,8 @@ static int unix_show(struct filter *f)
 	return 0;
 }
 
-static int packet_show_sock(struct nlmsghdr *nlh, struct filter *f)
+static int packet_show_sock(const struct sockaddr_nl *addr,
+		struct nlmsghdr *nlh, void *arg)
 {
 	struct packet_diag_msg *r = NLMSG_DATA(nlh);
 	struct rtattr *tb[PACKET_DIAG_MAX+1];
@@ -2786,15 +2730,14 @@ static int packet_show_sock(struct nlmsghdr *nlh, struct filter *f)
 	return 0;
 }
 
-static int packet_show_netlink(struct filter *f, FILE *dump_fp)
+static int packet_show_netlink(struct filter *f)
 {
 	DIAG_REQUEST(req, struct packet_diag_req r);
 
 	req.r.sdiag_family = AF_PACKET;
 	req.r.pdiag_show = PACKET_SHOW_INFO | PACKET_SHOW_MEMINFO | PACKET_SHOW_FILTER;
 
-	return handle_netlink_request(f, dump_fp, &req.nlh, sizeof(req),
-			packet_show_sock);
+	return handle_netlink_request(f, &req.nlh, sizeof(req), packet_show_sock);
 }
 
 
@@ -2811,7 +2754,7 @@ static int packet_show(struct filter *f)
 	int ino;
 	unsigned long long sk;
 
-	if (packet_show_netlink(f, NULL) == 0)
+	if (packet_show_netlink(f) == 0)
 		return 0;
 
 	if ((fp = net_packet_open()) == NULL)
@@ -2982,8 +2925,10 @@ static void netlink_show_one(struct filter *f,
 	return;
 }
 
-static int netlink_show_sock(struct nlmsghdr *nlh, struct filter *f)
+static int netlink_show_sock(const struct sockaddr_nl *addr,
+		struct nlmsghdr *nlh, void *arg)
 {
+	struct filter *f = (struct filter *)arg;
 	struct netlink_diag_msg *r = NLMSG_DATA(nlh);
 	struct rtattr *tb[NETLINK_DIAG_MAX+1];
 	int rq = 0, wq = 0;
@@ -3016,7 +2961,7 @@ static int netlink_show_sock(struct nlmsghdr *nlh, struct filter *f)
 	return 0;
 }
 
-static int netlink_show_netlink(struct filter *f, FILE *dump_fp)
+static int netlink_show_netlink(struct filter *f)
 {
 	DIAG_REQUEST(req, struct netlink_diag_req r);
 
@@ -3024,8 +2969,7 @@ static int netlink_show_netlink(struct filter *f, FILE *dump_fp)
 	req.r.sdiag_protocol = NDIAG_PROTO_ALL;
 	req.r.ndiag_show = NDIAG_SHOW_GROUPS | NDIAG_SHOW_MEMINFO;
 
-	return handle_netlink_request(f, dump_fp, &req.nlh,
-					sizeof(req), netlink_show_sock);
+	return handle_netlink_request(f, &req.nlh, sizeof(req), netlink_show_sock);
 }
 
 static int netlink_show(struct filter *f)
@@ -3038,7 +2982,7 @@ static int netlink_show(struct filter *f)
 	unsigned long long sk, cb;
 
 	if (!getenv("PROC_NET_NETLINK") && !getenv("PROC_ROOT") &&
-		netlink_show_netlink(f, NULL) == 0)
+		netlink_show_netlink(f) == 0)
 		return 0;
 
 	if ((fp = net_netlink_open()) == NULL)
-- 
2.1.3
