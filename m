From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] gianfar: fix headroom expansion code
Date: Thu, 26 Mar 2009 10:08:56 -0700
Message-ID: <20090326100856.265f7872@nehalam>
References: <20090325.172139.142233386.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: leoli@freescale.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54350 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759328AbZCZRJE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 13:09:04 -0400
In-Reply-To: <20090325.172139.142233386.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code that was added to increase headroom was wrong.
It doesn't handle the case where gfar_add_fcb() changes the skb.
Better to do check at start of transmit (outside of lock), where
error handling is better anyway.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/gianfar.c	2009-03-26 09:14:39.273669929 -0700
+++ b/drivers/net/gianfar.c	2009-03-26 09:22:46.477545004 -0700
@@ -1239,19 +1239,9 @@ static int gfar_enet_open(struct net_dev
 	return err;
 }
 
-static inline struct txfcb *gfar_add_fcb(struct sk_buff **skbp)
+static inline struct txfcb *gfar_add_fcb(struct sk_buff *skb)
 {
-	struct txfcb *fcb;
-	struct sk_buff *skb = *skbp;
-
-	if (unlikely(skb_headroom(skb) < GMAC_FCB_LEN)) {
-		struct sk_buff *old_skb = skb;
-		skb = skb_realloc_headroom(old_skb, GMAC_FCB_LEN);
-		if (!skb)
-			return NULL;
-		dev_kfree_skb_any(old_skb);
-	}
-	fcb = (struct txfcb *)skb_push(skb, GMAC_FCB_LEN);
+	struct txfcb *fcb = (struct txfcb *)skb_push(skb, GMAC_FCB_LEN);
 	cacheable_memzero(fcb, GMAC_FCB_LEN);
 
 	return fcb;
@@ -1320,6 +1310,20 @@ static int gfar_start_xmit(struct sk_buf
 
 	base = priv->tx_bd_base;
 
+	/* make space for additional header */
+	if (skb_headroom(skb) < GMAC_FCB_LEN) {
+		struct sk_buff *skb_new;
+
+		skb_new = skb_realloc_headroom(skb, GMAC_FCB_LEN);
+		if (!skb_new) {
+			dev->stats.tx_errors++;
+			kfree(skb);
+			return NETDEV_TX_OK;
+		}
+		kfree_skb(skb);
+		skb = skb_new;
+	}
+
 	/* total number of fragments in the SKB */
 	nr_frags = skb_shinfo(skb)->nr_frags;
 
@@ -1372,20 +1376,18 @@ static int gfar_start_xmit(struct sk_buf
 
 	/* Set up checksumming */
 	if (CHECKSUM_PARTIAL == skb->ip_summed) {
-		fcb = gfar_add_fcb(&skb);
-		if (likely(fcb != NULL)) {
-			lstatus |= BD_LFLAG(TXBD_TOE);
-			gfar_tx_checksum(skb, fcb);
-		}
+		fcb = gfar_add_fcb(skb);
+		lstatus |= BD_LFLAG(TXBD_TOE);
+		gfar_tx_checksum(skb, fcb);
 	}
 
 	if (priv->vlgrp && vlan_tx_tag_present(skb)) {
-		if (unlikely(NULL == fcb))
-			fcb = gfar_add_fcb(&skb);
-		if (likely(fcb != NULL)) {
+		if (unlikely(NULL == fcb)) {
+			fcb = gfar_add_fcb(skb);
 			lstatus |= BD_LFLAG(TXBD_TOE);
-			gfar_tx_vlan(skb, fcb);
 		}
+
+		gfar_tx_vlan(skb, fcb);
 	}
 
 	/* setup the TxBD length and buffer pointer for the first BD */
@@ -1433,7 +1435,7 @@ static int gfar_start_xmit(struct sk_buf
 	/* Unlock priv */
 	spin_unlock_irqrestore(&priv->txlock, flags);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* Stops the kernel queue, and halts the controller */
