From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ss: Use generic handle_netlink_request for packet
Date: Thu, 16 Oct 2014 17:40:32 +0300
Message-ID: <1413470432-28588-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:36724 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208AbaJPOuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2014 10:50:03 -0400
Received: by mail-lb0-f177.google.com with SMTP id w7so2891743lbi.8
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2014 07:50:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of self-handling and creating of Netlink socket for show packet
socket stats.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 80 +++------------------------------------------------------------
 1 file changed, 3 insertions(+), 77 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 2420b51..b3cc455 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2777,17 +2777,11 @@ static int packet_show_sock(struct nlmsghdr *nlh, struct filter *f)
 
 static int packet_show_netlink(struct filter *f, FILE *dump_fp)
 {
-	int fd;
 	struct {
 		struct nlmsghdr nlh;
 		struct packet_diag_req r;
-	} req;
-	char	buf[8192];
-
-	if ((fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_INET_DIAG)) < 0)
-		return -1;
+	} req = {};
 
-	memset(&req, 0, sizeof(req));
 	req.nlh.nlmsg_len = sizeof(req);
 	req.nlh.nlmsg_type = SOCK_DIAG_BY_FAMILY;
 	req.nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
@@ -2796,76 +2790,8 @@ static int packet_show_netlink(struct filter *f, FILE *dump_fp)
 	req.r.sdiag_family = AF_PACKET;
 	req.r.pdiag_show = PACKET_SHOW_INFO | PACKET_SHOW_MEMINFO | PACKET_SHOW_FILTER;
 
-	if (send(fd, &req, sizeof(req), 0) < 0) {
-		close(fd);
-		return -1;
-	}
-
-	while (1) {
-		ssize_t status;
-		struct nlmsghdr *h;
-		struct sockaddr_nl nladdr;
-		socklen_t slen = sizeof(nladdr);
-
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
-
-			if (h->nlmsg_seq != 123456)
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
-						fprintf(stderr, "UDIAG answers %d\n", errno);
-				}
-				close(fd);
-				return -1;
-			}
-			if (!dump_fp) {
-				err = packet_show_sock(h, f);
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
+	return handle_netlink_request(f, dump_fp, &req.nlh, sizeof(req),
+			packet_show_sock);
 }
 
 
-- 
2.1.0
