From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH] sctp: Fix regression introduced by new sctp_connectx api
Date: Wed, 11 Nov 2009 13:19:24 -0500
Message-ID: <1257963564-26376-1-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:6195 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758302AbZKKSTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 13:19:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A new (unrealeased to the user) sctp_connectx api

c6ba68a26645dbc5029a9faa5687ebe6fcfc53e4
    sctp: support non-blocking version of the new sctp_connectx() API

introduced a regression cought by the user regression test
suite.  In particular, the API requires the user library to
re-allocate the buffer and could potentially trigger a SIGFAULT.

This change corrects that regression by passing the original
address buffer to the kernel unmodified, but still allows for
a returned association id.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/socket.c |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index bf705ba..3a95fcb 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1276,22 +1276,30 @@ SCTP_STATIC int sctp_setsockopt_connectx(struct sock* sk,
 }
 
 /*
- * New (hopefully final) interface for the API.  The option buffer is used
- * both for the returned association id and the addresses.
+ * New (hopefully final) interface for the API.
+ * We use the sctp_getaddrs_old structure so that use-space library
+ * can avoid any unnecessary allocations.   The only defferent part
+ * is that we store the actual length of the address buffer into the
+ * addrs_num structure member.  That way we can re-use the existing
+ * code.
  */
 SCTP_STATIC int sctp_getsockopt_connectx3(struct sock* sk, int len,
 					char __user *optval,
 					int __user *optlen)
 {
+	struct sctp_getaddrs_old param;
 	sctp_assoc_t assoc_id = 0;
 	int err = 0;
 
-	if (len < sizeof(assoc_id))
+	if (len < sizeof(param))
 		return -EINVAL;
 
+	if (copy_from_user(&param, optval, sizeof(param)))
+		return -EFAULT;
+
 	err = __sctp_setsockopt_connectx(sk,
-			(struct sockaddr __user *)(optval + sizeof(assoc_id)),
-			len - sizeof(assoc_id), &assoc_id);
+			(struct sockaddr __user *)param.addrs,
+			param.addr_num, &assoc_id);
 
 	if (err == 0 || err == -EINPROGRESS) {
 		if (copy_to_user(optval, &assoc_id, sizeof(assoc_id)))
-- 
1.6.0.4

