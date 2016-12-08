From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v3 net-next 4/4] udp: udp_rmem_release() should touch sk_rmem_alloc later
Date: Thu,  8 Dec 2016 11:41:57 -0800
Message-ID: <1481226117-31288-5-git-send-email-edumazet@google.com>
References: <1481226117-31288-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:36534 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932455AbcLHTmM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 14:42:12 -0500
Received: by mail-pg0-f48.google.com with SMTP id f188so176481081pgc.3
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 11:42:11 -0800 (PST)
In-Reply-To: <1481226117-31288-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In flood situations, keeping sk_rmem_alloc at a high value
prevents producers from touching the socket.

It makes sense to lower sk_rmem_alloc only at the end
of udp_rmem_release() after the thread draining receive
queue in udp_recvmsg() finished the writes to sk_forward_alloc.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/udp.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 5a38faa12cde7fdcd5b6d86cdc0f4bc33de4..9ca279b130d51f6feaa97785b1c906775810 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1191,13 +1191,14 @@ static void udp_rmem_release(struct sock *sk, int size, int partial)
 	}
 	up->forward_deficit = 0;
 
-	atomic_sub(size, &sk->sk_rmem_alloc);
 	sk->sk_forward_alloc += size;
 	amt = (sk->sk_forward_alloc - partial) & ~(SK_MEM_QUANTUM - 1);
 	sk->sk_forward_alloc -= amt;
 
 	if (amt)
 		__sk_mem_reduce_allocated(sk, amt >> SK_MEM_QUANTUM_SHIFT);
+
+	atomic_sub(size, &sk->sk_rmem_alloc);
 }
 
 /* Note: called with sk_receive_queue.lock held.
-- 
2.8.0.rc3.226.g39d4020
