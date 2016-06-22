From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2 2/3] ss: Allow ssfilter_bytecompile to return 0
Date: Tue, 21 Jun 2016 20:38:25 -0700
Message-ID: <1466566706-1511-3-git-send-email-dsa@cumulusnetworks.com>
References: <1466566706-1511-1-git-send-email-dsa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36793 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523AbcFVDii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 23:38:38 -0400
Received: by mail-pf0-f173.google.com with SMTP id t190so12997633pfb.3
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 20:38:36 -0700 (PDT)
In-Reply-To: <1466566706-1511-1-git-send-email-dsa@cumulusnetworks.com>
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
index a22cfebadfa2..3419a88c33be 100644
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
@@ -2126,6 +2140,7 @@ static int tcpdiag_send(int fd, int protocol, struct filter *f)
 	struct msghdr msg;
 	struct rtattr rta;
 	struct iovec iov[3];
+	int iovlen = 1;
 
 	if (protocol == IPPROTO_UDP)
 		return -1;
@@ -2161,18 +2176,21 @@ static int tcpdiag_send(int fd, int protocol, struct filter *f)
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
@@ -2193,6 +2211,7 @@ static int sockdiag_send(int family, int fd, int protocol, struct filter *f)
 	struct msghdr msg;
 	struct rtattr rta;
 	struct iovec iov[3];
+	int iovlen = 1;
 
 	if (family == PF_UNSPEC)
 		return tcpdiag_send(fd, protocol, f);
@@ -2221,18 +2240,21 @@ static int sockdiag_send(int family, int fd, int protocol, struct filter *f)
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
