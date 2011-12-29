From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 5/5] unix_diag: Fixup RQLEN extenstion report
Date: Thu, 29 Dec 2011 18:15:14 +0400
Message-ID: <4EFC75F2.3060902@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:37142 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751409Ab1L2OPU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Dec 2011 09:15:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While it's not too late fix the recently added RQLEN diag extension
to report rqlen and wqlen in the same way as TCP does.

I.e. for listening sockets the ack backlog length (which is the input
queue length for socket) in rqlen and the max ack backlog length in
wqlen, and what the CINQ/OUTQ ioctls do for established.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/unix_diag.h |    5 +++++
 net/unix/diag.c           |   13 ++++++++++++-
 2 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/include/linux/unix_diag.h b/include/linux/unix_diag.h
index 5255f51..68ecc8f 100644
--- a/include/linux/unix_diag.h
+++ b/include/linux/unix_diag.h
@@ -44,4 +44,9 @@ struct unix_diag_vfs {
 	__u32	udiag_vfs_dev;
 };
 
+struct unix_diag_rqlen {
+	__u32	udiag_rqueue;
+	__u32	udiag_wqueue;
+};
+
 #endif
diff --git a/net/unix/diag.c b/net/unix/diag.c
index 9517bdd..9eb63a4 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -101,7 +101,18 @@ rtattr_failure:
 
 static int sk_diag_show_rqlen(struct sock *sk, struct sk_buff *nlskb)
 {
-	RTA_PUT_U32(nlskb, UNIX_DIAG_RQLEN, sk->sk_receive_queue.qlen);
+	struct unix_diag_rqlen *rql;
+
+	rql = UNIX_DIAG_PUT(nlskb, UNIX_DIAG_RQLEN, sizeof(*rql));
+
+	if (sk->sk_state == TCP_LISTEN) {
+		rql->udiag_rqueue = sk->sk_receive_queue.qlen;
+		rql->udiag_wqueue = sk->sk_max_ack_backlog;
+	} else {
+		rql->udiag_rqueue = (__u32)unix_inq_len(sk);
+		rql->udiag_wqueue = (__u32)unix_outq_len(sk);
+	}
+
 	return 0;
 
 rtattr_failure:
-- 
1.5.5.6
