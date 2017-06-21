From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next] udp: prefetch rmem_alloc in udp_queue_rcv_skb()
Date: Wed, 21 Jun 2017 10:24:40 +0200
Message-ID: <ec963336242664e99c2f47f399c621aa7f5e2885.1498033422.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45064 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752413AbdFUIta (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 04:49:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On UDP packets processing, if the BH is the bottle-neck, it
always sees a cache miss while updating rmem_alloc; try to
avoid it prefetching the value as soon as we have the socket
available.

Performances under flood with multiple NIC rx queues used are
unaffected, but when a single NIC rx queue is in use, this
gives ~10% performance improvement.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/udp.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f3450f0..067a607 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1949,6 +1949,7 @@ static int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		}
 	}
 
+	prefetch(&sk->sk_rmem_alloc);
 	if (rcu_access_pointer(sk->sk_filter) &&
 	    udp_lib_checksum_complete(skb))
 			goto csum_error;
-- 
2.9.4
