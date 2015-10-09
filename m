From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tun: use sk_fullsock() before reading
 sk->sk_tsflags
Date: Fri, 09 Oct 2015 15:42:21 -0700
Message-ID: <1444430541.27760.109.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33821 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754292AbbJIWmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 18:42:23 -0400
Received: by padhy16 with SMTP id hy16so98081552pad.1
        for <netdev@vger.kernel.org>; Fri, 09 Oct 2015 15:42:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

timewait or request sockets are small and do not contain sk->sk_tsflags

Without this fix, we might read garbage, and crash later in

__skb_complete_tx_timestamp()
 -> sock_queue_err_skb()

(These pseudo sockets do not have an error queue either)

Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 Note this bug also exists on net tree for timewait sockets but only
 in exceptional conditions (routing glitches and IP early demux)

 drivers/net/tun.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 976aa9704297..b1878faea397 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -858,7 +858,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
 		goto drop;
 
-	if (skb->sk) {
+	if (skb->sk && sk_fullsock(skb->sk)) {
 		sock_tx_timestamp(skb->sk, &skb_shinfo(skb)->tx_flags);
 		sw_tx_timestamp(skb);
 	}
