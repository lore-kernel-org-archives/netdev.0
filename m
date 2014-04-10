From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] packet: fix potential use after free
Date: Wed, 09 Apr 2014 18:22:39 -0700
Message-ID: <1397092959.16584.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Xi Wang <xii@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:42627 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932996AbaDJBWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 21:22:41 -0400
Received: by mail-pb0-f42.google.com with SMTP id rr13so3279021pbb.1
        for <netdev@vger.kernel.org>; Wed, 09 Apr 2014 18:22:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

As soon skb is queued into sk_receive_queue, it can be consumed,
so its racy to access skb->len.

Given that sk_data_ready() / sock_def_readable() don't really care, just
use 0 instead of skb->len

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Xi Wang <xii@google.com>
---
 net/packet/af_packet.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 72e0c71fb01d..373d557e22ee 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1848,7 +1848,8 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 	skb->dropcount = atomic_read(&sk->sk_drops);
 	__skb_queue_tail(&sk->sk_receive_queue, skb);
 	spin_unlock(&sk->sk_receive_queue.lock);
-	sk->sk_data_ready(sk, skb->len);
+	/* Remember: we can not reference skb after this point */
+	sk->sk_data_ready(sk, 0);
 	return 0;
 
 drop_n_acct:
