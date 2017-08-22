From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: [PATCH net-next v3 1/2] tcp: Get a proper dst before checking it.
Date: Mon, 21 Aug 2017 23:33:48 -0700
Message-ID: <1503383629-12392-2-git-send-email-xiangxia.m.yue@gmail.com>
References: <1503383629-12392-1-git-send-email-xiangxia.m.yue@gmail.com>
Cc: eric.dumazet@gmail.com, Tonghao Zhang <xiangxia.m.yue@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34685 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754433AbdHVGeJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 02:34:09 -0400
Received: by mail-pf0-f196.google.com with SMTP id w127so1225178pfd.1
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 23:34:09 -0700 (PDT)
In-Reply-To: <1503383629-12392-1-git-send-email-xiangxia.m.yue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_peer_is_proven needs a proper route to make the
determination, but dst always is NULL. This bug may
be there at the beginning of git tree. This does not
look serious enough to deserve backports to stable
versions.

Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
---
 net/ipv4/tcp_input.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d73903fe8c83..9397e989e1d1 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6112,6 +6112,10 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	if (tmp_opt.tstamp_ok)
 		tcp_rsk(req)->ts_off = af_ops->init_ts_off(net, skb);
 
+	dst = af_ops->route_req(sk, &fl, req);
+	if (!dst)
+		goto drop_and_free;
+
 	if (!want_cookie && !isn) {
 		/* Kill the following clause, if you dislike this way. */
 		if (!net->ipv4.sysctl_tcp_syncookies &&
@@ -6132,11 +6136,6 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 
 		isn = af_ops->init_seq(skb);
 	}
-	if (!dst) {
-		dst = af_ops->route_req(sk, &fl, req);
-		if (!dst)
-			goto drop_and_free;
-	}
 
 	tcp_ecn_create_request(req, skb, sk, dst);
 
-- 
2.13.4
