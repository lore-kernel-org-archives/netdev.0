From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH 1/4] ss: handle socket diag request in a separate function
Date: Wed,  5 Jun 2013 12:41:58 +0400
Message-ID: <1370421721-30814-2-git-send-email-avagin@openvz.org>
References: <1370421721-30814-1-git-send-email-avagin@openvz.org>
Cc: netdev@vger.kernel.org, Andrey Vagin <avagin@openvz.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:4540 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753437Ab3FEIoX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 04:44:23 -0400
In-Reply-To: <1370421721-30814-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It will be reused to show netlink sockets

Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 misc/ss.c | 49 +++++++++++++++++++++++++++++--------------------
 1 file changed, 29 insertions(+), 20 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 418dd6f..2d6ddef 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2226,31 +2226,17 @@ static int unix_show_sock(struct nlmsghdr *nlh, struct filter *f)
 	return 0;
 }
 
-static int unix_show_netlink(struct filter *f, FILE *dump_fp)
+static int handle_netlink_request(struct filter *f, FILE *dump_fp,
+				  struct nlmsghdr *req, size_t size,
+				  int (* show_one_sock)(struct nlmsghdr *nlh, struct filter *f))
 {
 	int fd;
-	struct {
-		struct nlmsghdr nlh;
-		struct unix_diag_req r;
-	} req;
 	char	buf[8192];
 
 	if ((fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_INET_DIAG)) < 0)
 		return -1;
 
-	memset(&req, 0, sizeof(req));
-	req.nlh.nlmsg_len = sizeof(req);
-	req.nlh.nlmsg_type = SOCK_DIAG_BY_FAMILY;
-	req.nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
-	req.nlh.nlmsg_seq = 123456;
-
-	req.r.sdiag_family = AF_UNIX;
-	req.r.udiag_states = f->states;
-	req.r.udiag_show = UDIAG_SHOW_NAME | UDIAG_SHOW_PEER | UDIAG_SHOW_RQLEN;
-	if (show_mem)
-		req.r.udiag_show |= UDIAG_SHOW_MEMINFO;
-
-	if (send(fd, &req, sizeof(req), 0) < 0) {
+	if (send(fd, req, size, 0) < 0) {
 		close(fd);
 		return -1;
 	}
@@ -2295,13 +2281,13 @@ static int unix_show_netlink(struct filter *f, FILE *dump_fp)
 				} else {
 					errno = -err->error;
 					if (errno != ENOENT)
-						fprintf(stderr, "UDIAG answers %d\n", errno);
+						fprintf(stderr, "DIAG answers %d\n", errno);
 				}
 				close(fd);
 				return -1;
 			}
 			if (!dump_fp) {
-				err = unix_show_sock(h, f);
+				err = show_one_sock(h, f);
 				if (err < 0) {
 					close(fd);
 					return err;
@@ -2323,6 +2309,29 @@ close_it:
 	return 0;
 }
 
+static int unix_show_netlink(struct filter *f, FILE *dump_fp)
+{
+	struct {
+		struct nlmsghdr nlh;
+		struct unix_diag_req r;
+	} req;
+
+	memset(&req, 0, sizeof(req));
+	req.nlh.nlmsg_len = sizeof(req);
+	req.nlh.nlmsg_type = SOCK_DIAG_BY_FAMILY;
+	req.nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
+	req.nlh.nlmsg_seq = 123456;
+
+	req.r.sdiag_family = AF_UNIX;
+	req.r.udiag_states = f->states;
+	req.r.udiag_show = UDIAG_SHOW_NAME | UDIAG_SHOW_PEER | UDIAG_SHOW_RQLEN;
+	if (show_mem)
+		req.r.udiag_show |= UDIAG_SHOW_MEMINFO;
+
+	return handle_netlink_request(f, dump_fp, &req.nlh,
+					sizeof(req), unix_show_sock);
+}
+
 static int unix_show(struct filter *f)
 {
 	FILE *fp;
-- 
1.8.1.4
