From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 v3] ss: Refactor to use macro for define diag nl request
Date: Thu, 30 Oct 2014 18:49:25 +0200
Message-ID: <1414687765-21112-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:43286 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934023AbaJ3Q6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 12:58:33 -0400
Received: by mail-wg0-f46.google.com with SMTP id x13so4741098wgg.19
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 09:58:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 56 +++++++++++++++++---------------------------------------
 1 file changed, 17 insertions(+), 39 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index b7e0ef0..240d36b 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -41,6 +41,19 @@
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
+		},							    \
+	}
+
 #if HAVE_SELINUX
 #include <selinux/selinux.h>
 #else
@@ -1808,10 +1821,7 @@ static int tcpdiag_send(int fd, int protocol, struct filter *f)
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
@@ -1824,11 +1834,6 @@ static int sockdiag_send(int family, int fd, int protocol, struct filter *f)
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
@@ -2590,16 +2595,7 @@ close_it:
 
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
@@ -2791,21 +2787,12 @@ static int packet_show_sock(struct nlmsghdr *nlh, struct filter *f)
 static int packet_show_netlink(struct filter *f, FILE *dump_fp)
 {
 	int fd;
-	struct {
-		struct nlmsghdr nlh;
-		struct packet_diag_req r;
-	} req;
+	DIAG_REQUEST(req, struct packet_diag_req r);
 	char	buf[16384];
 
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
 
@@ -3104,16 +3091,7 @@ static int netlink_show_sock(struct nlmsghdr *nlh, struct filter *f)
 
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
