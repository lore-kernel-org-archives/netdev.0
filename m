From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] gianfar: fix potential sk_wmem_alloc imbalance
Date: Thu, 05 Jul 2012 23:45:13 +0200
Message-ID: <1341524713.3265.41.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Manfred Rudigier <manfred.rudigier@omicron.at>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Jiajun Wu <b06378@freescale.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Andy Fleming <afleming@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:62270 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756525Ab2GEVpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 17:45:20 -0400
Received: by wibhm11 with SMTP id hm11so125481wib.1
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 14:45:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit db83d136d7f753 (gianfar: Fix missing sock reference when
processing TX time stamps) added a potential sk_wmem_alloc imbalance

If the new skb has a different truesize than old one, we can get a
negative sk_wmem_alloc once new skb is orphaned at TX completion.

Now we no longer early orphan skbs in dev_hard_start_xmit(), this
probably can lead to fatal bugs.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Manfred Rudigier <manfred.rudigier@omicron.at>
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>
Cc: Jiajun Wu <b06378@freescale.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Andy Fleming <afleming@freescale.com>
---

Note : I don't have the hardware and discovered this problem by code
analysis. So please compile and run this patch before Acking it,
thanks !

BTW, dev->needed_headroom should be set to GMAC_FCB_LEN + GMAC_TXPAL_LEN
to avoid reallocations...

 drivers/net/ethernet/freescale/gianfar.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index f2db8fc..ab1d80f 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2063,10 +2063,9 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			return NETDEV_TX_OK;
 		}
 
-		/* Steal sock reference for processing TX time stamps */
-		swap(skb_new->sk, skb->sk);
-		swap(skb_new->destructor, skb->destructor);
-		kfree_skb(skb);
+		if (skb->sk)
+			skb_set_owner_w(skb_new, skb->sk);
+		consume_skb(skb);
 		skb = skb_new;
 	}
 
