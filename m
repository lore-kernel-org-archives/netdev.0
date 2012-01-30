From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ss: should support CONFIG_INET_UDP_DIAG=n kernels
Date: Mon, 30 Jan 2012 17:05:45 +0100
Message-ID: <1327939545.2297.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@parallels.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:49194 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752672Ab2A3QFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 11:05:49 -0500
Received: by bkas6 with SMTP id s6so3317293bka.19
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 08:05:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ss -x currently fails if CONFIG_INET_UDP_DIAG=n or old kernels

Also close file descriptors while we are at it.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
---
 misc/ss.c |   22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 7a15d69..eb42fd6 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2092,8 +2092,10 @@ static int unix_show_netlink(struct filter *f, FILE *dump_fp)
 		.msg_iovlen = f->f ? 3 : 1,
 	};
 
-	if (sendmsg(fd, &msg, 0) < 0)
+	if (sendmsg(fd, &msg, 0) < 0) {
+		close(fd);
 		return -1;
+	}
 
 	iov[0] = (struct iovec){
 		.iov_base = buf,
@@ -2121,6 +2123,7 @@ static int unix_show_netlink(struct filter *f, FILE *dump_fp)
 		}
 		if (status == 0) {
 			fprintf(stderr, "EOF on netlink\n");
+			close(fd);
 			return 0;
 		}
 
@@ -2135,22 +2138,28 @@ static int unix_show_netlink(struct filter *f, FILE *dump_fp)
 			    h->nlmsg_seq != 123456)
 				goto skip_it;
 
-			if (h->nlmsg_type == NLMSG_DONE)
+			if (h->nlmsg_type == NLMSG_DONE) {
+				close(fd);
 				return 0;
+			}
 			if (h->nlmsg_type == NLMSG_ERROR) {
 				struct nlmsgerr *err = (struct nlmsgerr*)NLMSG_DATA(h);
 				if (h->nlmsg_len < NLMSG_LENGTH(sizeof(struct nlmsgerr))) {
 					fprintf(stderr, "ERROR truncated\n");
 				} else {
 					errno = -err->error;
-					perror("TCPDIAG answers");
+					if (errno != ENOENT)
+						fprintf(stderr, "UDIAG answers %d\n", errno);
 				}
-				return 0;
+				close(fd);
+				return -1;
 			}
 			if (!dump_fp) {
 				err = unix_show_sock(h, f);
-				if (err < 0)
+				if (err < 0) {
+					close(fd);
 					return err;
+				}
 			}
 
 skip_it:
@@ -2165,6 +2174,7 @@ skip_it:
 			exit(1);
 		}
 	}
+	close(fd);
 	return 0;
 }
 
@@ -2241,7 +2251,7 @@ int unix_show(struct filter *f)
 			cnt = 0;
 		}
 	}
-
+	fclose(fp);
 	if (list) {
 		unix_list_print(list, f);
 		unix_list_free(list);
