From: Daniel Schwierzeck <daniel.schwierzeck@googlemail.com>
Subject: [PATCH] atm: br2684: Fix oops due to skb->dev being NULL
Date: Sat, 20 Aug 2011 00:04:20 +0200
Message-ID: <1313791460-13652-1-git-send-email-daniel.schwierzeck@googlemail.com>
Cc: stable@kernel.org, "David S . Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:65469 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753295Ab1HSWEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 18:04:30 -0400
Received: by fxh19 with SMTP id 19so2199556fxh.19
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 15:04:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This oops have been already fixed with commit

    27141666b69f535a4d63d7bc6d9e84ee5032f82a

    atm: [br2684] Fix oops due to skb->dev being NULL

    It happens that if a packet arrives in a VC between the call to open it on
    the hardware and the call to change the backend to br2684, br2684_regvcc
    processes the packet and oopses dereferencing skb->dev because it is
    NULL before the call to br2684_push().

but have been introduced again with commit

    b6211ae7f2e56837c6a4849316396d1535606e90

    atm: Use SKB queue and list helpers instead of doing it by-hand.

Signed-off-by: Daniel Schwierzeck <daniel.schwierzeck@googlemail.com>
---
 net/atm/br2684.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 52cfd0c..d07223c 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -558,12 +558,13 @@ static int br2684_regvcc(struct atm_vcc *atmvcc, void __user * arg)
 	spin_unlock_irqrestore(&rq->lock, flags);
 
 	skb_queue_walk_safe(&queue, skb, tmp) {
-		struct net_device *dev = skb->dev;
+		struct net_device *dev;
+
+		br2684_push(atmvcc, skb);
+		dev = skb->dev;
 
 		dev->stats.rx_bytes -= skb->len;
 		dev->stats.rx_packets--;
-
-		br2684_push(atmvcc, skb);
 	}
 
 	/* initialize netdev carrier state */
-- 
1.7.6

