From: Andrei Vagin <avagin@openvz.org>
Subject: [PATCH v2] net/unix: don't show information about sockets from other namespaces
Date: Wed, 25 Oct 2017 10:16:42 -0700
Message-ID: <20171025171642.2926-1-avagin@openvz.org>
References: <1508938636.30291.115.camel@edumazet-glaptop3.roam.corp.google.com>
Cc: netdev@vger.kernel.org, Andrei Vagin <avagin@openvz.org>
To: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:52422 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751854AbdJYRQw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 13:16:52 -0400
Received: by mail-lf0-f67.google.com with SMTP id b190so778320lfg.9
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 10:16:51 -0700 (PDT)
In-Reply-To: <1508938636.30291.115.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

socket_diag shows information only about sockets from a namespace where
a diag socket lives.

But if we request information about one unix socket, the kernel don't
check that its netns is matched with a diag socket namespace, so any
user can get information about any unix socket in a system. This looks
like a bug.

v2: add a Fixes tag

Fixes: 51d7cccf0723 ("net: make sock diag per-namespace")
Signed-off-by: Andrei Vagin <avagin@openvz.org>
---
 net/unix/diag.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/unix/diag.c b/net/unix/diag.c
index 4d9679701a6d..384c84e83462 100644
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
2.13.6
