From: Matt Tierney <tierney@cs.nyu.edu>
Subject: [PATCH iproute2] ss: Close file descriptors in tcp_show_netlink.
Date: Wed, 15 Feb 2012 18:20:38 -0500
Message-ID: <1329348038-12646-1-git-send-email-tierney@cs.nyu.edu>
Cc: netdev@vger.kernel.org, Matt Tierney <tierney@cs.nyu.edu>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:41903 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963Ab2BOXUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 18:20:45 -0500
Received: by qadc10 with SMTP id c10so3746192qad.19
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 15:20:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ss: Close file descriptors in tcp_show_netlink.

Signed-off-by: Matt Tierney <tierney@cs.nyu.edu>
---
 misc/ss.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index eb42fd6..2caac4a 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1563,6 +1563,7 @@ static int tcp_show_netlink(struct filter *f, FILE *dump_fp, int socktype)
 		}
 		if (status == 0) {
 			fprintf(stderr, "EOF on netlink\n");
+			close(fd);
 			return 0;
 		}

@@ -1578,8 +1579,10 @@ static int tcp_show_netlink(struct filter *f, FILE *dump_fp, int socktype)
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
@@ -1588,6 +1591,7 @@ static int tcp_show_netlink(struct filter *f, FILE *dump_fp, int socktype)
 					errno = -err->error;
 					perror("TCPDIAG answers");
 				}
+				close(fd);
 				return 0;
 			}
 			if (!dump_fp) {
@@ -1596,8 +1600,10 @@ static int tcp_show_netlink(struct filter *f, FILE *dump_fp, int socktype)
 					continue;
 				}
 				err = tcp_show_sock(h, NULL);
-				if (err < 0)
+				if (err < 0) {
+					close(fd);
 					return err;
+				}
 			}

 skip_it:
@@ -1612,6 +1618,7 @@ skip_it:
 			exit(1);
 		}
 	}
+	close(fd);
 	return 0;
 }

--
1.7.5.4
