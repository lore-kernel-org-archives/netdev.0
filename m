From: Lorenzo Colitti <lorenzo@google.com>
Subject: [iproute PATCH v3 1/2] libnetlink: add a variant of rtnl_send_check that consumes ACKs
Date: Tue, 22 Dec 2015 17:31:33 +0900
Message-ID: <1450773094-7978-2-git-send-email-lorenzo@google.com>
References: <20151221214222.5ee87383@xeon-e3>
 <1450773094-7978-1-git-send-email-lorenzo@google.com>
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	zenczykowski@gmail.com, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34053 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752463AbbLVIcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 03:32:18 -0500
Received: by mail-pf0-f170.google.com with SMTP id u7so56492627pfb.1
        for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 00:32:18 -0800 (PST)
In-Reply-To: <1450773094-7978-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new variant is identical to rtnl_send_check, except it also
consumes the kernel response instead of using MSG_PEEK. This is
useful for callers that send simple commands that never cause a
response but only ACKs, and that expect to receive and deal
with errors without printing them to stderr like rtnl_talk does.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/libnetlink.h |  2 ++
 lib/libnetlink.c     | 16 +++++++++++++---
 2 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index 431189e..a88cb4d 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -75,6 +75,8 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 	__attribute__((warn_unused_result));
 int rtnl_send(struct rtnl_handle *rth, const void *buf, int)
 	__attribute__((warn_unused_result));
+int rtnl_send_check_ack(struct rtnl_handle *rth, const void *buf, int, int)
+	__attribute__((warn_unused_result));
 int rtnl_send_check(struct rtnl_handle *rth, const void *buf, int)
 	__attribute__((warn_unused_result));
 
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 1658214..43cc73b 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -134,18 +134,21 @@ int rtnl_send(struct rtnl_handle *rth, const void *buf, int len)
 	return send(rth->fd, buf, len, 0);
 }
 
-int rtnl_send_check(struct rtnl_handle *rth, const void *buf, int len)
+int rtnl_send_check_ack(struct rtnl_handle *rth, const void *buf, int len,
+		int ack)
 {
 	struct nlmsghdr *h;
-	int status;
+	int status, flags;
 	char resp[1024];
 
 	status = send(rth->fd, buf, len, 0);
 	if (status < 0)
 		return status;
 
+	flags = ack ? 0 : MSG_DONTWAIT|MSG_PEEK;
+
 	/* Check for immediate errors */
-	status = recv(rth->fd, resp, sizeof(resp), MSG_DONTWAIT|MSG_PEEK);
+	status = recv(rth->fd, resp, sizeof(resp), flags);
 	if (status < 0) {
 		if (errno == EAGAIN)
 			return 0;
@@ -160,6 +163,8 @@ int rtnl_send_check(struct rtnl_handle *rth, const void *buf, int len)
 				fprintf(stderr, "ERROR truncated\n");
 			else 
 				errno = -err->error;
+			if (ack && errno == 0)
+				return 0;
 			return -1;
 		}
 	}
@@ -167,6 +172,11 @@ int rtnl_send_check(struct rtnl_handle *rth, const void *buf, int len)
 	return 0;
 }
 
+int rtnl_send_check(struct rtnl_handle *rth, const void *buf, int len)
+{
+	return rtnl_send_check_ack(rth, buf, len, 0);
+}
+
 int rtnl_dump_request(struct rtnl_handle *rth, int type, void *req, int len)
 {
 	struct nlmsghdr nlh;
-- 
2.6.0.rc2.230.g3dd15c0
