From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] udp: preserve skb->dst if required for IP options processing
Date: Mon, 17 Jul 2017 22:59:23 +0200
Message-ID: <a72faa05ed7b5ede6467096121ad6cee1fee229d.1500325067.git.pabeni@redhat.com>
References: <1500275043.5566.1.camel@edumazet-glaptop3.roam.corp.google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41748 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752084AbdGQVRS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Jul 2017 17:17:18 -0400
In-Reply-To: <1500275043.5566.1.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric noticed that in udp_recvmsg() we still need to access
skb->dst while processing the IP options.
Since commit 0a463c78d25b ("udp: avoid a cache miss on dequeue")
skb->dst is no more available at recvmsg() time and bad things
will happen if we enter the relevant code path.

This commit address the issue, avoid clearing skb->dst if
any IP options are present into the relevant skb.
Since the IP CB is contained in the first skb cacheline, we can
test it to decide to leverage the consume_stateless_skb()
optimization, without measurable additional cost in the faster
path.

Fixes: b65ac44674dd ("udp: try to avoid 2 cache miss on dequeue")
Reported-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/udp.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 25294d4..b057653 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1388,6 +1388,11 @@ void skb_consume_udp(struct sock *sk, struct sk_buff *skb, int len)
 		unlock_sock_fast(sk, slow);
 	}
 
+	/* we cleared the head states previously only if the skb lacks any IP
+	 * options, see __udp_queue_rcv_skb().
+	 */
+	if (unlikely(IPCB(skb)->opt.optlen > 0))
+		skb_release_head_state(skb);
 	consume_stateless_skb(skb);
 }
 EXPORT_SYMBOL_GPL(skb_consume_udp);
@@ -1779,8 +1784,12 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		sk_mark_napi_id_once(sk, skb);
 	}
 
-	/* clear all pending head states while they are hot in the cache */
-	skb_release_head_state(skb);
+	/* At recvmsg() time we need skb->dst to process IP options-related
+	 * cmsg, elsewhere can we clear all pending head states while they are
+	 * hot in the cache
+	 */
+	if (likely(IPCB(skb)->opt.optlen == 0))
+		skb_release_head_state(skb);
 
 	rc = __udp_enqueue_schedule_skb(sk, skb);
 	if (rc < 0) {
-- 
2.9.4
