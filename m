From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: refresh skb timestamp at retransmit time
Date: Mon, 09 May 2016 20:55:16 -0700
Message-ID: <1462852516.23934.46.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36059 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047AbcEJDzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 23:55:19 -0400
Received: by mail-pf0-f182.google.com with SMTP id c189so482558pfb.3
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 20:55:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In the very unlikely case __tcp_retransmit_skb() can not use the cloning
done in tcp_transmit_skb(), we need to refresh skb_mstamp before doing
the copy and transmit, otherwise TCP TS val will be an exact copy of
original transmit.

Fixes: 7faee5c0d514 ("tcp: remove TCP_SKB_CB(skb)->when")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_output.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 441ae9da3a23..79a03b87a771 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2640,8 +2640,10 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	 */
 	if (unlikely((NET_IP_ALIGN && ((unsigned long)skb->data & 3)) ||
 		     skb_headroom(skb) >= 0xFFFF)) {
-		struct sk_buff *nskb = __pskb_copy(skb, MAX_TCP_HEADER,
-						   GFP_ATOMIC);
+		struct sk_buff *nskb;
+
+		skb_mstamp_get(&skb->skb_mstamp);
+		nskb = __pskb_copy(skb, MAX_TCP_HEADER, GFP_ATOMIC);
 		err = nskb ? tcp_transmit_skb(sk, nskb, 0, GFP_ATOMIC) :
 			     -ENOBUFS;
 	} else {
