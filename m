From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 4/4] udp: no need to preserve skb->dst
Date: Thu,  3 Aug 2017 18:07:08 +0200
Message-ID: <99a44bf71b12638ac2367fb2448c070bb19f5b74.1501775813.git.pabeni@redhat.com>
References: <cover.1501775813.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51712 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751704AbdHCQHo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Aug 2017 12:07:44 -0400
In-Reply-To: <cover.1501775813.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__ip_options_echo() does not need anymore skb->dst, so we can
avoid explicitly preserving it for its own sake.

This is almost a revert of commit 0ddf3fb2c43d ("udp: preserve
skb->dst if required for IP options processing") plus some
lifting to fit later changes.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/udp.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index e6276fa3750b..38bca2c4897d 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1176,7 +1176,11 @@ static void udp_set_dev_scratch(struct sk_buff *skb)
 	scratch->csum_unnecessary = !!skb_csum_unnecessary(skb);
 	scratch->is_linear = !skb_is_nonlinear(skb);
 #endif
-	if (likely(!skb->_skb_refdst))
+	/* all head states execept sp (dst, sk, nf) are always cleared by
+	 * udp_rcv() and we need to preserve secpath, if present, to eventually
+	 * process IP_CMSG_PASSSEC at recvmsg() time
+	 */
+	if (likely(!skb_sec_path(skb)))
 		scratch->_tsize_state |= UDP_SKB_IS_STATELESS;
 }
 
@@ -1782,13 +1786,6 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		sk_mark_napi_id_once(sk, skb);
 	}
 
-	/* At recvmsg() time we may access skb->dst or skb->sp depending on
-	 * the IP options and the cmsg flags, elsewhere can we clear all
-	 * pending head states while they are hot in the cache
-	 */
-	if (likely(IPCB(skb)->opt.optlen == 0 && !skb_sec_path(skb)))
-		skb_release_head_state(skb);
-
 	rc = __udp_enqueue_schedule_skb(sk, skb);
 	if (rc < 0) {
 		int is_udplite = IS_UDPLITE(sk);
-- 
2.13.3
