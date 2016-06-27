From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v2 iproute2 2/3] ss: Allow ssfilter_bytecompile to return 0
Date: Mon, 27 Jun 2016 11:34:24 -0700
Message-ID: <1467052465-14488-3-git-send-email-dsa@cumulusnetworks.com>
References: <1467052465-14488-1-git-send-email-dsa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33009 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639AbcF0Sei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 14:34:38 -0400
Received: by mail-pf0-f178.google.com with SMTP id i123so64307493pfg.0
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 11:34:38 -0700 (PDT)
In-Reply-To: <1467052465-14488-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow ssfilter_bytecompile to return 0 for filter ops the kernel
does not support. If such an op is in the filter string then all
filtering is done in userspace.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 misc/ss.c | 52 +++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 37 insertions(+), 15 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index f164ca920308..0510701619ac 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1273,11 +1273,16 @@ static int ssfilter_bytecompile(struct ssfilter *f, char **bytecode)
 
 		case SSF_AND:
 	{
-		char *a1, *a2, *a;
+		char *a1 = NULL, *a2 = NULL, *a;
 		int l1, l2;
 
 		l1 = ssfilter_bytecompile(f->pred, &a1);
 		l2 = ssfilter_bytecompile(f->post, &a2);
+		if (!l1 || !l2) {
+			free(a1);
+			free(a2);
+			return 0;
+		}
 		if (!(a = malloc(l1+l2))) abort();
 		memcpy(a, a1, l1);
 		memcpy(a+l1, a2, l2);
@@ -1288,11 +1293,16 @@ static int ssfilter_bytecompile(struct ssfilter *f, char **bytecode)
 	}
 		case SSF_OR:
 	{
-		char *a1, *a2, *a;
+		char *a1 = NULL, *a2 = NULL, *a;
 		int l1, l2;
 
 		l1 = ssfilter_bytecompile(f->pred, &a1);
 		l2 = ssfilter_bytecompile(f->post, &a2);
+		if (!l1 || !l2) {
+			free(a1);
+			free(a2);
+			return 0;
+		}
 		if (!(a = malloc(l1+l2+4))) abort();
 		memcpy(a, a1, l1);
 		memcpy(a+l1+4, a2, l2);
@@ -1303,10 +1313,14 @@ static int ssfilter_bytecompile(struct ssfilter *f, char **bytecode)
 	}
 		case SSF_NOT:
 	{
-		char *a1, *a;
+		char *a1 = NULL, *a;
 		int l1;
 
 		l1 = ssfilter_bytecompile(f->pred, &a1);
+		if (!l1) {
+			free(a1);
+			return 0;
+		}
 		if (!(a = malloc(l1+4))) abort();
 		memcpy(a, a1, l1);
 		free(a1);
@@ -2127,6 +2141,7 @@ static int tcpdiag_send(int fd, int protocol, struct filter *f)
 	struct msghdr msg;
 	struct rtattr rta;
 	struct iovec iov[3];
+	int iovlen = 1;
 
 	if (protocol == IPPROTO_UDP)
 		return -1;
@@ -2162,18 +2177,21 @@ static int tcpdiag_send(int fd, int protocol, struct filter *f)
 	};
 	if (f->f) {
 		bclen = ssfilter_bytecompile(f->f, &bc);
-		rta.rta_type = INET_DIAG_REQ_BYTECODE;
-		rta.rta_len = RTA_LENGTH(bclen);
-		iov[1] = (struct iovec){ &rta, sizeof(rta) };
-		iov[2] = (struct iovec){ bc, bclen };
-		req.nlh.nlmsg_len += RTA_LENGTH(bclen);
+		if (bclen) {
+			rta.rta_type = INET_DIAG_REQ_BYTECODE;
+			rta.rta_len = RTA_LENGTH(bclen);
+			iov[1] = (struct iovec){ &rta, sizeof(rta) };
+			iov[2] = (struct iovec){ bc, bclen };
+			req.nlh.nlmsg_len += RTA_LENGTH(bclen);
+			iovlen = 3;
+		}
 	}
 
 	msg = (struct msghdr) {
 		.msg_name = (void *)&nladdr,
 		.msg_namelen = sizeof(nladdr),
 		.msg_iov = iov,
-		.msg_iovlen = f->f ? 3 : 1,
+		.msg_iovlen = iovlen,
 	};
 
 	if (sendmsg(fd, &msg, 0) < 0) {
@@ -2194,6 +2212,7 @@ static int sockdiag_send(int family, int fd, int protocol, struct filter *f)
 	struct msghdr msg;
 	struct rtattr rta;
 	struct iovec iov[3];
+	int iovlen = 1;
 
 	if (family == PF_UNSPEC)
 		return tcpdiag_send(fd, protocol, f);
@@ -2222,18 +2241,21 @@ static int sockdiag_send(int family, int fd, int protocol, struct filter *f)
 	};
 	if (f->f) {
 		bclen = ssfilter_bytecompile(f->f, &bc);
-		rta.rta_type = INET_DIAG_REQ_BYTECODE;
-		rta.rta_len = RTA_LENGTH(bclen);
-		iov[1] = (struct iovec){ &rta, sizeof(rta) };
-		iov[2] = (struct iovec){ bc, bclen };
-		req.nlh.nlmsg_len += RTA_LENGTH(bclen);
+		if (bclen) {
+			rta.rta_type = INET_DIAG_REQ_BYTECODE;
+			rta.rta_len = RTA_LENGTH(bclen);
+			iov[1] = (struct iovec){ &rta, sizeof(rta) };
+			iov[2] = (struct iovec){ bc, bclen };
+			req.nlh.nlmsg_len += RTA_LENGTH(bclen);
+			iovlen = 3;
+		}
 	}
 
 	msg = (struct msghdr) {
 		.msg_name = (void *)&nladdr,
 		.msg_namelen = sizeof(nladdr),
 		.msg_iov = iov,
-		.msg_iovlen = f->f ? 3 : 1,
+		.msg_iovlen = iovlen,
 	};
 
 	if (sendmsg(fd, &msg, 0) < 0) {
-- 
2.1.4
