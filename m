From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ss: Refactor to use macro for define diag nl request
Date: Sun, 19 Oct 2014 02:50:29 +0300
Message-ID: <1413676229-23258-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:38079 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593AbaJRX7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2014 19:59:23 -0400
Received: by mail-lb0-f181.google.com with SMTP id l4so2227695lbv.40
        for <netdev@vger.kernel.org>; Sat, 18 Oct 2014 16:59:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 57 ++++++++++++++++++---------------------------------------
 1 file changed, 18 insertions(+), 39 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 2420b51..261847b 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -41,6 +41,20 @@
 #include <linux/packet_diag.h>
 #include <linux/netlink_diag.h>
 
+#define DIAG_REQUEST(_req, _r)						    \
+	struct {							    \
+		struct nlmsghdr nlh;					    \
+		_r;							    \
+	} _req = {							    \
+		.nlh = {						    \
+			.nlmsg_type = SOCK_DIAG_BY_FAMILY,		    \
+			.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST,\
+			.nlmsg_seq = 123456,				    \
+			.nlmsg_len = sizeof(_req),			    \
+			.nlmsg_pid = 0,					    \
+		},							    \
+	}
+
 #if HAVE_SELINUX
 #include <selinux/selinux.h>
 #else
@@ -1795,10 +1809,7 @@ static int tcpdiag_send(int fd, int protocol, struct filter *f)
 static int sockdiag_send(int family, int fd, int protocol, struct filter *f)
 {
 	struct sockaddr_nl nladdr;
-	struct {
-		struct nlmsghdr nlh;
-		struct inet_diag_req_v2 r;
-	} req;
+	DIAG_REQUEST(req, struct inet_diag_req_v2 r);
 	char    *bc = NULL;
 	int	bclen;
 	struct msghdr msg;
@@ -1811,11 +1822,6 @@ static int sockdiag_send(int family, int fd, int protocol, struct filter *f)
 	memset(&nladdr, 0, sizeof(nladdr));
 	nladdr.nl_family = AF_NETLINK;
 
-	req.nlh.nlmsg_len = sizeof(req);
-	req.nlh.nlmsg_type = SOCK_DIAG_BY_FAMILY;
-	req.nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
-	req.nlh.nlmsg_pid = 0;
-	req.nlh.nlmsg_seq = 123456;
 	memset(&req.r, 0, sizeof(req.r));
 	req.r.sdiag_family = family;
 	req.r.sdiag_protocol = protocol;
@@ -2577,16 +2583,7 @@ close_it:
 
 static int unix_show_netlink(struct filter *f, FILE *dump_fp)
 {
-	struct {
-		struct nlmsghdr nlh;
-		struct unix_diag_req r;
-	} req;
-
-	memset(&req, 0, sizeof(req));
-	req.nlh.nlmsg_len = sizeof(req);
-	req.nlh.nlmsg_type = SOCK_DIAG_BY_FAMILY;
-	req.nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
-	req.nlh.nlmsg_seq = 123456;
+	DIAG_REQUEST(req, struct unix_diag_req r);
 
 	req.r.sdiag_family = AF_UNIX;
 	req.r.udiag_states = f->states;
@@ -2778,21 +2775,12 @@ static int packet_show_sock(struct nlmsghdr *nlh, struct filter *f)
 static int packet_show_netlink(struct filter *f, FILE *dump_fp)
 {
 	int fd;
-	struct {
-		struct nlmsghdr nlh;
-		struct packet_diag_req r;
-	} req;
+	DIAG_REQUEST(req, struct packet_diag_req r);
 	char	buf[8192];
 
 	if ((fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_INET_DIAG)) < 0)
 		return -1;
 
-	memset(&req, 0, sizeof(req));
-	req.nlh.nlmsg_len = sizeof(req);
-	req.nlh.nlmsg_type = SOCK_DIAG_BY_FAMILY;
-	req.nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
-	req.nlh.nlmsg_seq = 123456;
-
 	req.r.sdiag_family = AF_PACKET;
 	req.r.pdiag_show = PACKET_SHOW_INFO | PACKET_SHOW_MEMINFO | PACKET_SHOW_FILTER;
 
@@ -3091,16 +3079,7 @@ static int netlink_show_sock(struct nlmsghdr *nlh, struct filter *f)
 
 static int netlink_show_netlink(struct filter *f, FILE *dump_fp)
 {
-	struct {
-		struct nlmsghdr nlh;
-		struct netlink_diag_req r;
-	} req;
-
-	memset(&req, 0, sizeof(req));
-	req.nlh.nlmsg_len = sizeof(req);
-	req.nlh.nlmsg_type = SOCK_DIAG_BY_FAMILY;
-	req.nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
-	req.nlh.nlmsg_seq = 123456;
+	DIAG_REQUEST(req, struct netlink_diag_req r);
 
 	req.r.sdiag_family = AF_NETLINK;
 	req.r.sdiag_protocol = NDIAG_PROTO_ALL;
-- 
2.1.0
