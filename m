From: Andrei Vagin <avagin@openvz.org>
Subject: [PATCH] net/unix: don't show information about sockets from other namespaces
Date: Wed, 25 Oct 2017 00:17:44 -0700
Message-ID: <20171025071744.29095-1-avagin@openvz.org>
Cc: netdev@vger.kernel.org, Andrei Vagin <avagin@openvz.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:56463 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751455AbdJYHR6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 03:17:58 -0400
Received: by mail-lf0-f66.google.com with SMTP id 90so26655933lfs.13
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 00:17:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

socket_diag shows information only about sockets from a namespace where
a diag socket lives.

But if we request information about one unix socket, the kernel don't
check that its netns is matched with a diag socket namespace, so any
user can get information about any unix socket in a system. This looks
like a bug.

Signed-off-by: Andrei Vagin <avagin@openvz.org>
---
 net/unix/diag.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/unix/diag.c b/net/unix/diag.c
index 4d96797..384c84e 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -257,6 +257,8 @@ static int unix_diag_get_exact(struct sk_buff *in_skb,
 	err = -ENOENT;
 	if (sk == NULL)
 		goto out_nosk;
+	if (!net_eq(sock_net(sk), net))
+		goto out;
 
 	err = sock_diag_check_cookie(sk, req->udiag_cookie);
 	if (err)
-- 
2.9.4
