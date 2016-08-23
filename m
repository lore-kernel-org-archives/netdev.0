From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH net] tun: fix transmit timestamp support
Date: Tue, 23 Aug 2016 18:22:33 -0400
Message-ID: <1471990953-6793-1-git-send-email-soheil.kdev@gmail.com>
Cc: Soheil Hassas Yeganeh <soheil@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:34294 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754335AbcHWWXr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 18:23:47 -0400
Received: by mail-qt0-f194.google.com with SMTP id c52so4304807qte.1
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 15:22:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

Instead of using sock_tx_timestamp, use skb_tx_timestamp to record
software transmit timestamp of a packet.

sock_tx_timestamp resets and overrides the tx_flags of the skb.
The function is intended to be called from within the protocol
layer when creating the skb, not from a device driver. This is
inconsistent with other drivers and will cause issues for TCP.

In TCP, we intend to sample the timestamps for the last byte
for each sendmsg/sendpage. For that reason, tcp_sendmsg calls
tcp_tx_timestamp only with the last skb that it generates.
For example, if a 128KB message is split into two 64KB packets
we want to sample the SND timestamp of the last packet. The current
code in the tun driver, however, will result in sampling the SND
timestamp for both packets.

Also, when the last packet is split into smaller packets for
retranmission (see tcp_fragment), the tun driver will record
timestamps for all of the retransmitted packets and not only the
last packet.

Fixes: eda297729171 (tun: Support software transmit time stamping.)
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Signed-off-by: Francis Yan <francisyyan@google.com>
---
 drivers/net/tun.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index e249428..8093e39 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -888,11 +888,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
 		goto drop;
 
-	if (skb->sk && sk_fullsock(skb->sk)) {
-		sock_tx_timestamp(skb->sk, skb->sk->sk_tsflags,
-				  &skb_shinfo(skb)->tx_flags);
-		sw_tx_timestamp(skb);
-	}
+	skb_tx_timestamp(skb);
 
 	/* Orphan the skb - required as we might hang on to it
 	 * for indefinite time.
-- 
2.8.0.rc3.226.g39d4020
