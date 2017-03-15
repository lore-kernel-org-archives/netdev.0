From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: properly release sk_frag.page
Date: Wed, 15 Mar 2017 13:21:28 -0700
Message-ID: <1489609288.28631.161.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35513 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753368AbdCOU3u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 16:29:50 -0400
Received: by mail-pf0-f195.google.com with SMTP id x63so3166699pfx.2
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 13:29:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

I mistakenly added the code to release sk->sk_frag in
sk_common_release() instead of sk_destruct()

TCP sockets using sk->sk_allocation == GFP_ATOMIC do no call
sk_common_release() at close time, thus leaking one (order-3) page.

iSCSI is using such sockets.

Fixes: 5640f7685831 ("net: use a per task frag allocator")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/sock.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index a96d5f7a5734a52dfd6a2df8490c7bd7f5f6599a..acb0d413749968f24ffc7df3e366b095f80e10f4 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1442,6 +1442,11 @@ static void __sk_destruct(struct rcu_head *head)
 		pr_debug("%s: optmem leakage (%d bytes) detected\n",
 			 __func__, atomic_read(&sk->sk_omem_alloc));
 
+	if (sk->sk_frag.page) {
+		put_page(sk->sk_frag.page);
+		sk->sk_frag.page = NULL;
+	}
+
 	if (sk->sk_peer_cred)
 		put_cred(sk->sk_peer_cred);
 	put_pid(sk->sk_peer_pid);
@@ -2787,11 +2792,6 @@ void sk_common_release(struct sock *sk)
 
 	sk_refcnt_debug_release(sk);
 
-	if (sk->sk_frag.page) {
-		put_page(sk->sk_frag.page);
-		sk->sk_frag.page = NULL;
-	}
-
 	sock_put(sk);
 }
 EXPORT_SYMBOL(sk_common_release);
