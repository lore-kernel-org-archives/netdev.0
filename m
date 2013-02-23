From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 2/2] sock_diag: Simplify sock_diag_handlers[] handling in __sock_diag_rcv_msg
Date: Sat, 23 Feb 2013 12:13:48 +0100
Message-ID: <1361618028-9024-3-git-send-email-minipli@googlemail.com>
References: <1361618028-9024-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f47.google.com ([209.85.214.47]:47700 "EHLO
	mail-bk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757505Ab3BWLON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2013 06:14:13 -0500
Received: by mail-bk0-f47.google.com with SMTP id jc3so636635bkc.6
        for <netdev@vger.kernel.org>; Sat, 23 Feb 2013 03:14:12 -0800 (PST)
In-Reply-To: <1361618028-9024-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sock_diag_lock_handler() and sock_diag_unlock_handler() actually
make the code less readable. Get rid of them and make the lock usage
and access to sock_diag_handlers[] clear on the first sight.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/core/sock_diag.c |   24 +++++++-----------------
 1 file changed, 7 insertions(+), 17 deletions(-)

diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index 750f44f..a29e90c 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -97,21 +97,6 @@ void sock_diag_unregister(const struct sock_diag_handler *hnld)
 }
 EXPORT_SYMBOL_GPL(sock_diag_unregister);
 
-static const inline struct sock_diag_handler *sock_diag_lock_handler(int family)
-{
-	if (sock_diag_handlers[family] == NULL)
-		request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
-				NETLINK_SOCK_DIAG, family);
-
-	mutex_lock(&sock_diag_table_mutex);
-	return sock_diag_handlers[family];
-}
-
-static inline void sock_diag_unlock_handler(const struct sock_diag_handler *h)
-{
-	mutex_unlock(&sock_diag_table_mutex);
-}
-
 static int __sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	int err;
@@ -124,12 +109,17 @@ static int __sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (req->sdiag_family >= AF_MAX)
 		return -EINVAL;
 
-	hndl = sock_diag_lock_handler(req->sdiag_family);
+	if (sock_diag_handlers[req->sdiag_family] == NULL)
+		request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
+				NETLINK_SOCK_DIAG, req->sdiag_family);
+
+	mutex_lock(&sock_diag_table_mutex);
+	hndl = sock_diag_handlers[req->sdiag_family];
 	if (hndl == NULL)
 		err = -ENOENT;
 	else
 		err = hndl->dump(skb, nlh);
-	sock_diag_unlock_handler(hndl);
+	mutex_unlock(&sock_diag_table_mutex);
 
 	return err;
 }
-- 
1.7.10.4
