From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] korina: Read buffer overflow
Date: Fri, 07 Aug 2009 17:33:31 +0200
Message-ID: <4A7C494B.2060204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, n0-1@freewrt.org,
	florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:59713 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751667AbZHGP35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 11:29:57 -0400
Received: by ewy10 with SMTP id 10so1616609ewy.37
        for <netdev@vger.kernel.org>; Fri, 07 Aug 2009 08:29:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the loop breaks with an i of 0, then we read lp->rd_ring[-1].

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
Should we clean up like this? please review

diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index b4cf602..b965b2b 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -754,7 +754,7 @@ static void korina_alloc_ring(struct net_device *dev)
 {
 	struct korina_private *lp = netdev_priv(dev);
 	struct sk_buff *skb;
-	int i;
+	int i, j;
 
 	/* Initialize the transmit descriptors */
 	for (i = 0; i < KORINA_NUM_TDS; i++) {
@@ -771,7 +771,7 @@ static void korina_alloc_ring(struct net_device *dev)
 	for (i = 0; i < KORINA_NUM_RDS; i++) {
 		skb = dev_alloc_skb(KORINA_RBSIZE + 2);
 		if (!skb)
-			break;
+			goto err_free;
 		skb_reserve(skb, 2);
 		lp->rx_skb[i] = skb;
 		lp->rd_ring[i].control = DMA_DESC_IOD |
@@ -790,6 +790,12 @@ static void korina_alloc_ring(struct net_device *dev)
 	lp->rx_chain_head = 0;
 	lp->rx_chain_tail = 0;
 	lp->rx_chain_status = desc_empty;
+err_free:
+	for (j = 0; j < i; j++) {
+		lp->rd_ring[j].control = 0;
+		dev_kfree_skb_any(lp->rx_skb[j]);
+		lp->rx_skb[j] = NULL;
+	}
 }
 
 static void korina_free_ring(struct net_device *dev)
