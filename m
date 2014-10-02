From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH] net: systemport: fix bcm_sysport_insert_tsb()
Date: Thu,  2 Oct 2014 09:43:16 -0700
Message-ID: <1412268196-16086-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:39501 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906AbaJBQnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 12:43:20 -0400
Received: by mail-pa0-f48.google.com with SMTP id eu11so2835316pac.7
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 09:43:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to commit bc23333ba11fb7f959b7e87e121122f5a0fbbca8 ("net:
bcmgenet: fix bcmgenet_put_tx_csum()"), we need to return the skb
pointer in case we had to reallocate the SKB headroom.

Fixes: 80105befdb4b8 ("net: systemport: add Broadcom SYSTEMPORT Ethernet MAC driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 77f1ff7396ac..075688188644 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -857,7 +857,8 @@ static irqreturn_t bcm_sysport_wol_isr(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-static int bcm_sysport_insert_tsb(struct sk_buff *skb, struct net_device *dev)
+static struct sk_buff *bcm_sysport_insert_tsb(struct sk_buff *skb,
+					      struct net_device *dev)
 {
 	struct sk_buff *nskb;
 	struct bcm_tsb *tsb;
@@ -873,7 +874,7 @@ static int bcm_sysport_insert_tsb(struct sk_buff *skb, struct net_device *dev)
 		if (!nskb) {
 			dev->stats.tx_errors++;
 			dev->stats.tx_dropped++;
-			return -ENOMEM;
+			return NULL;
 		}
 		skb = nskb;
 	}
@@ -892,7 +893,7 @@ static int bcm_sysport_insert_tsb(struct sk_buff *skb, struct net_device *dev)
 			ip_proto = ipv6_hdr(skb)->nexthdr;
 			break;
 		default:
-			return 0;
+			return skb;
 		}
 
 		/* Get the checksum offset and the L4 (transport) offset */
@@ -911,7 +912,7 @@ static int bcm_sysport_insert_tsb(struct sk_buff *skb, struct net_device *dev)
 		tsb->l4_ptr_dest_map = csum_info;
 	}
 
-	return 0;
+	return skb;
 }
 
 static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
@@ -945,8 +946,8 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
 
 	/* Insert TSB and checksum infos */
 	if (priv->tsb_en) {
-		ret = bcm_sysport_insert_tsb(skb, dev);
-		if (ret) {
+		skb = bcm_sysport_insert_tsb(skb, dev);
+		if (!skb) {
 			ret = NETDEV_TX_OK;
 			goto out;
 		}
-- 
1.9.1
