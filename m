From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: diag: Fix refcnt leak in error path destroying socket
Date: Tue, 23 Aug 2016 21:05:27 -0700
Message-ID: <1472011527-16760-1-git-send-email-dsa@cumulusnetworks.com>
Cc: eric.dumazet@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36258 "EHLO
        mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751000AbcHXEFe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 00:05:34 -0400
Received: by mail-pa0-f42.google.com with SMTP id di2so2112647pad.3
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 21:05:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet_diag_find_one_icsk takes a reference to a socket that is not
released if sock_diag_destroy returns an error. Fix by changing
tcp_diag_destroy to manage the refcnt for all cases and remove
the sock_put calls from tcp_abort.

Fixes: c1e64e298b8ca ("net: diag: Support destroying TCP sockets")
Reported-by: Lorenzo Colitti <lorenzo@google.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/tcp.c      | 2 --
 net/ipv4/tcp_diag.c | 7 ++++++-
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index f1a9a0a8a1f3..54c5d0a8f6e9 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3176,7 +3176,6 @@ int tcp_abort(struct sock *sk, int err)
 			local_bh_enable();
 			return 0;
 		}
-		sock_gen_put(sk);
 		return -EOPNOTSUPP;
 	}
 
@@ -3205,7 +3204,6 @@ int tcp_abort(struct sock *sk, int err)
 	bh_unlock_sock(sk);
 	local_bh_enable();
 	release_sock(sk);
-	sock_put(sk);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(tcp_abort);
diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index 4d610934fb39..a748c74aa8b7 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -54,11 +54,16 @@ static int tcp_diag_destroy(struct sk_buff *in_skb,
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct sock *sk = inet_diag_find_one_icsk(net, &tcp_hashinfo, req);
+	int err;
 
 	if (IS_ERR(sk))
 		return PTR_ERR(sk);
 
-	return sock_diag_destroy(sk, ECONNABORTED);
+	err = sock_diag_destroy(sk, ECONNABORTED);
+
+	sock_gen_put(sk);
+
+	return err;
 }
 #endif
 
-- 
2.1.4
