From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] skge: add GRO support
Date: Wed, 01 Sep 2010 00:32:36 +0200
Message-ID: <1283293956.2198.46.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59627 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752555Ab0HaWck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 18:32:40 -0400
Received: by wyb35 with SMTP id 35so8428813wyb.19
        for <netdev@vger.kernel.org>; Tue, 31 Aug 2010 15:32:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- use napi_gro_receive() instead of netif_receive_skb()
- use napi_complete() instead of __napi_complete()
- turn on NETIF_F_GRO by default
- Tested on a Marvell 88E8801 Gigabit NIC

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/skge.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 40e5c46..c2e29e3 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3178,8 +3178,7 @@ static int skge_poll(struct napi_struct *napi, int to_do)
 
 		skb = skge_rx_get(dev, e, control, rd->status, rd->csum2);
 		if (likely(skb)) {
-			netif_receive_skb(skb);
-
+			napi_gro_receive(napi, skb);
 			++work_done;
 		}
 	}
@@ -3193,7 +3192,7 @@ static int skge_poll(struct napi_struct *napi, int to_do)
 		unsigned long flags;
 
 		spin_lock_irqsave(&hw->hw_lock, flags);
-		__napi_complete(napi);
+		napi_complete(napi);
 		hw->intr_mask |= napimask[skge->port];
 		skge_write32(hw, B0_IMSK, hw->intr_mask);
 		skge_read32(hw, B0_IMSK);
@@ -3849,6 +3848,7 @@ static struct net_device *skge_devinit(struct skge_hw *hw, int port,
 		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 		skge->rx_csum = 1;
 	}
+	dev->features |= NETIF_F_GRO;
 
 	/* read the mac address */
 	memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port*8, ETH_ALEN);


