From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ss: Use generic handle_netlink_request for packet
Date: Sat, 29 Nov 2014 23:44:32 +0200
Message-ID: <1417297472-32716-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:53000 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751163AbaK2VyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2014 16:54:12 -0500
Received: by mail-wg0-f50.google.com with SMTP id k14so11131768wgh.23
        for <netdev@vger.kernel.org>; Sat, 29 Nov 2014 13:54:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of self-handling and creating of Netlink socket for show packet
socket stats.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 77 ++-------------------------------------------------------------
 1 file changed, 2 insertions(+), 75 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 0526205..a99294d 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2788,86 +2788,13 @@ static int packet_show_sock(struct nlmsghdr *nlh, struct filter *f)
 
 static int packet_show_netlink(struct filter *f, FILE *dump_fp)
 {
-	int fd;
 	DIAG_REQUEST(req, struct packet_diag_req r);
-	char	buf[16384];
-
-	if ((fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_INET_DIAG)) < 0)
-		return -1;
 
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
2.1.3
