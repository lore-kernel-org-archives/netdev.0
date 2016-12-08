From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 4/4] udp: add batching to udp_rmem_release()
Date: Thu,  8 Dec 2016 09:38:59 -0800
Message-ID: <1481218739-27089-5-git-send-email-edumazet@google.com>
References: <1481218739-27089-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:35120 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751139AbcLHRjM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 12:39:12 -0500
Received: by mail-pg0-f52.google.com with SMTP id p66so176135249pga.2
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 09:39:12 -0800 (PST)
In-Reply-To: <1481218739-27089-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If udp_recvmsg() constantly releases sk_rmem_alloc
for every read packet, it gives opportunity for
producers to immediately grab spinlocks and desperatly
try adding another packet, causing false sharing.

We can add a simple heuristic to give the signal
by batches of ~25 % of the queue capacity.

This patch considerably increases performance under
flood by about 50 %, since the thread draining the queue
is no longer slowed by false sharing.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/udp.h |  3 +++
 net/ipv4/udp.c      | 11 +++++++++++
 2 files changed, 14 insertions(+)

diff --git a/include/linux/udp.h b/include/linux/udp.h
index d1fd8cd39478..c0f530809d1f 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -79,6 +79,9 @@ struct udp_sock {
 	int			(*gro_complete)(struct sock *sk,
 						struct sk_buff *skb,
 						int nhoff);
+
+	/* This field is dirtied by udp_recvmsg() */
+	int		forward_deficit;
 };
 
 static inline struct udp_sock *udp_sk(const struct sock *sk)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 880cd3d84abf..f0096d088104 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1177,8 +1177,19 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
 /* fully reclaim rmem/fwd memory allocated for skb */
 static void udp_rmem_release(struct sock *sk, int size, int partial)
 {
+	struct udp_sock *up = udp_sk(sk);
 	int amt;
 
+	if (likely(partial)) {
+		up->forward_deficit += size;
+		size = up->forward_deficit;
+		if (size < (sk->sk_rcvbuf >> 2))
+			return;
+	} else {
+		size += up->forward_deficit;
+	}
+	up->forward_deficit = 0;
+
 	atomic_sub(size, &sk->sk_rmem_alloc);
 	sk->sk_forward_alloc += size;
 	amt = (sk->sk_forward_alloc - partial) & ~(SK_MEM_QUANTUM - 1);
-- 
2.8.0.rc3.226.g39d4020
