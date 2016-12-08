From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v3 net-next 3/4] udp: add batching to udp_rmem_release()
Date: Thu,  8 Dec 2016 11:41:56 -0800
Message-ID: <1481226117-31288-4-git-send-email-edumazet@google.com>
References: <1481226117-31288-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36361 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932455AbcLHTmJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 14:42:09 -0500
Received: by mail-pf0-f181.google.com with SMTP id 189so85043484pfz.3
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 11:42:08 -0800 (PST)
In-Reply-To: <1481226117-31288-1-git-send-email-edumazet@google.com>
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
 net/ipv4/udp.c      | 12 ++++++++++++
 2 files changed, 15 insertions(+)

diff --git a/include/linux/udp.h b/include/linux/udp.h
index d1fd8cd39478b635ef5396b5ae1c63f8c965..c0f530809d1f3db7323e51a52224eb49d8f9 100644
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
index c608334d99aa5620858d9cceec500b2be944..5a38faa12cde7fdcd5b6d86cdc0f4bc33de4 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1177,8 +1177,20 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
 /* fully reclaim rmem/fwd memory allocated for skb */
 static void udp_rmem_release(struct sock *sk, int size, int partial)
 {
+	struct udp_sock *up = udp_sk(sk);
 	int amt;
 
+	if (likely(partial)) {
+		up->forward_deficit += size;
+		size = up->forward_deficit;
+		if (size < (sk->sk_rcvbuf >> 2) &&
+		    !skb_queue_empty(&sk->sk_receive_queue))
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
