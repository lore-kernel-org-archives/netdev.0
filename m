From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 33/51] ss: Don't leak fd in tcp_show_netlink_file()
Date: Sat, 12 Aug 2017 14:04:52 +0200
Message-ID: <20170812120510.28750-34-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:57081 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751400AbdHLMIh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:08:37 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 32 ++++++++++++++++++++------------
 1 file changed, 20 insertions(+), 12 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 4d2f75b571ea6..cda5e3b6a2d6f 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2687,41 +2687,44 @@ static int tcp_show_netlink_file(struct filter *f)
 {
 	FILE	*fp;
 	char	buf[16384];
+	int	err = -1;
 
 	if ((fp = fopen(getenv("TCPDIAG_FILE"), "r")) == NULL) {
 		perror("fopen($TCPDIAG_FILE)");
-		return -1;
+		return err;
 	}
 
 	while (1) {
-		int status, err;
+		int status, err2;
 		struct nlmsghdr *h = (struct nlmsghdr *)buf;
 		struct sockstat s = {};
 
 		status = fread(buf, 1, sizeof(*h), fp);
 		if (status < 0) {
 			perror("Reading header from $TCPDIAG_FILE");
-			return -1;
+			break;
 		}
 		if (status != sizeof(*h)) {
 			perror("Unexpected EOF reading $TCPDIAG_FILE");
-			return -1;
+			break;
 		}
 
 		status = fread(h+1, 1, NLMSG_ALIGN(h->nlmsg_len-sizeof(*h)), fp);
 
 		if (status < 0) {
 			perror("Reading $TCPDIAG_FILE");
-			return -1;
+			break;
 		}
 		if (status + sizeof(*h) < h->nlmsg_len) {
 			perror("Unexpected EOF reading $TCPDIAG_FILE");
-			return -1;
+			break;
 		}
 
 		/* The only legal exit point */
-		if (h->nlmsg_type == NLMSG_DONE)
-			return 0;
+		if (h->nlmsg_type == NLMSG_DONE) {
+			err = 0;
+			break;
+		}
 
 		if (h->nlmsg_type == NLMSG_ERROR) {
 			struct nlmsgerr *err = (struct nlmsgerr *)NLMSG_DATA(h);
@@ -2732,7 +2735,7 @@ static int tcp_show_netlink_file(struct filter *f)
 				errno = -err->error;
 				perror("TCPDIAG answered");
 			}
-			return -1;
+			break;
 		}
 
 		parse_diag_msg(h, &s);
@@ -2741,10 +2744,15 @@ static int tcp_show_netlink_file(struct filter *f)
 		if (f && f->f && run_ssfilter(f->f, &s) == 0)
 			continue;
 
-		err = inet_show_sock(h, &s);
-		if (err < 0)
-			return err;
+		err2 = inet_show_sock(h, &s);
+		if (err2 < 0) {
+			err = err2;
+			break;
+		}
 	}
+
+	fclose(fp);
+	return err;
 }
 
 static int tcp_show(struct filter *f, int socktype)
-- 
2.13.1
