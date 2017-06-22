From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next] udp/v6: prefetch rmem_alloc in udp6_queue_rcv_skb()
Date: Thu, 22 Jun 2017 15:01:22 +0200
Message-ID: <9152ab05a2fe6b6230b44b7a23056b367ca19f5e.1498127002.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55992 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751149AbdFVNEE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 09:04:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

very similar to commit dd99e425be23 ("udp: prefetch
rmem_alloc in udp_queue_rcv_skb()"), this allows saving a cache
miss when the BH is bottle-neck for UDP over ipv6 packet
processing, e.g. for small packets when a single RX NIC ingress
queue is in use.

Performances under flood when multiple NIC RX queues used are
unaffected, but when a single NIC rx queue is in use, this
gives ~8% performance improvement.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv6/udp.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 2b33847..d1d7288 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -630,6 +630,7 @@ static int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		}
 	}
 
+	prefetch(&sk->sk_rmem_alloc);
 	if (rcu_access_pointer(sk->sk_filter) &&
 	    udp_lib_checksum_complete(skb))
 		goto csum_error;
-- 
2.9.4
