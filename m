From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: do not leak non zero tstamp in output packets
Date: Wed, 05 Mar 2014 14:08:38 -0800
Message-ID: <1394057318.27473.15.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:61352 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757123AbaCEWIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 17:08:46 -0500
Received: by mail-pd0-f181.google.com with SMTP id p10so1601476pdj.26
        for <netdev@vger.kernel.org>; Wed, 05 Mar 2014 14:08:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Usage of skb->tstamp should remain private to TCP stack
(only set on packets on write queue, not on cloned ones)

Otherwise, packets given to loopback interface with a non null tstamp
can confuse netif_rx() / net_timestamp_check()

Other possibility would be to clear tstamp in loopback_xmit(),
as done in skb_scrub_packet()

Fixes: 740b0f1841f6 ("tcp: switch rtt estimations to usec resolution")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/tcp_output.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index aaa68f5b1055..2b50b6e425b8 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -882,6 +882,8 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 			skb = skb_clone(skb, gfp_mask);
 		if (unlikely(!skb))
 			return -ENOBUFS;
+		/* Our usage of tstamp should remain private */
+		skb->tstamp.tv64 = 0;
 	}
 
 	inet = inet_sk(sk);
