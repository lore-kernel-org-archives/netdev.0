From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/5] net: use sk_fullsock() in __netdev_pick_tx()
Date: Sun,  4 Oct 2015 21:08:10 -0700
Message-ID: <1444018091-21987-5-git-send-email-edumazet@google.com>
References: <1444018091-21987-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35070 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160AbbJEEIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 00:08:41 -0400
Received: by pacfv12 with SMTP id fv12so166861150pac.2
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 21:08:41 -0700 (PDT)
In-Reply-To: <1444018091-21987-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SYN_RECV & TIMEWAIT sockets are not full blown, they do not have a
sk_dst_cache pointer.

Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/request_sock.h | 1 +
 net/core/dev.c             | 1 +
 2 files changed, 2 insertions(+)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index dd423d840852..f83669460d82 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -92,6 +92,7 @@ reqsk_alloc(const struct request_sock_ops *ops, struct sock *sk_listener)
 		req->rsk_listener = sk_listener;
 		req_to_sk(req)->sk_prot = sk_listener->sk_prot;
 		sk_node_init(&req_to_sk(req)->sk_node);
+		sk_tx_queue_clear(req_to_sk(req));
 		req->saved_syn = NULL;
 		/* Following is temporary. It is coupled with debugging
 		 * helpers in reqsk_put() & reqsk_free()
diff --git a/net/core/dev.c b/net/core/dev.c
index 323c04edd779..a229bf0d649d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2974,6 +2974,7 @@ static u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb)
 			new_index = skb_tx_hash(dev, skb);
 
 		if (queue_index != new_index && sk &&
+		    sk_fullsock(sk) &&
 		    rcu_access_pointer(sk->sk_dst_cache))
 			sk_tx_queue_set(sk, new_index);
 
-- 
2.6.0.rc2.230.g3dd15c0
