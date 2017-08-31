From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/2] net: prepare (struct ubuf_info)->refcnt conversion
Date: Thu, 31 Aug 2017 13:30:12 -0700
Message-ID: <20170831203013.9219-2-edumazet@google.com>
References: <20170831203013.9219-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33430 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751053AbdHaUaW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 16:30:22 -0400
Received: by mail-pf0-f169.google.com with SMTP id n73so2123185pfj.0
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 13:30:22 -0700 (PDT)
In-Reply-To: <20170831203013.9219-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to convert this atomic_t refcnt to refcount_t,
we need to init the refcount to one to not trigger
a 0 -> 1 transition.

This also removes one atomic operation in fast path.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/skbuff.c | 3 ++-
 net/ipv4/tcp.c    | 2 --
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 917da73d3ab3b82163cf0a9ee944da09cb5a391f..65b9ca3945f8fd2b1bef4aef5dd774be04e5d128 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -963,7 +963,7 @@ struct ubuf_info *sock_zerocopy_alloc(struct sock *sk, size_t size)
 	uarg->len = 1;
 	uarg->bytelen = size;
 	uarg->zerocopy = 1;
-	atomic_set(&uarg->refcnt, 0);
+	atomic_set(&uarg->refcnt, 1);
 	sock_hold(sk);
 
 	return uarg;
@@ -1005,6 +1005,7 @@ struct ubuf_info *sock_zerocopy_realloc(struct sock *sk, size_t size,
 			uarg->len++;
 			uarg->bytelen = bytelen;
 			atomic_set(&sk->sk_zckey, ++next);
+			sock_zerocopy_get(uarg);
 			return uarg;
 		}
 	}
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 21ca2df274c5130a13d31a391a1408d779af34af..fff4d7bc3b8b46174e7bd0a04d7c212307e55cb5 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1190,8 +1190,6 @@ int tcp_sendmsg_locked(struct sock *sk, struct msghdr *msg, size_t size)
 			goto out_err;
 		}
 
-		/* skb may be freed in main loop, keep extra ref on uarg */
-		sock_zerocopy_get(uarg);
 		if (!(sk_check_csum_caps(sk) && sk->sk_route_caps & NETIF_F_SG))
 			uarg->zerocopy = 0;
 	}
-- 
2.14.1.581.gf28d330327-goog
