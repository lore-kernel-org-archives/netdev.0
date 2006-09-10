From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 3/7] 8139cp: ring_info removal for the receive path
Date: Sun, 10 Sep 2006 23:10:11 +0200
Message-ID: <20060910211011.GA22313@electric-eye.fr.zoreil.com>
References: <20060831204717.GA13650@electric-eye.fr.zoreil.com> <20060831204954.GC14181@electric-eye.fr.zoreil.com> <44FEDF64.4000105@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Pierre Ossman <drzeus-list@drzeus.cx>,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:61664 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1750785AbWIJVN3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Sep 2006 17:13:29 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <44FEDF64.4000105@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> :
> Francois Romieu wrote:
> >The ring_info.len field is not used at all. cp_private.rx_skb is
> >turned into an array of sk_buff *.
> >
> >Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> 
> Need to remove the now-dead struct ring_info.

I should have written "is not used at all in the receive path".

If one wants to remove ring_info completely, something like the
patch below is required:

    8139cp: ring_info removal for the transmit path
    
    <handwaving>
    As long as the descriptor fits on a single cacheline, the change
    should be really free.
    </handwaving>
    
    Now ring_info is not used at all.
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index bbdaa18..c3b8400 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -314,11 +314,6 @@ struct cp_desc {
 	u64		addr;
 };
 
-struct ring_info {
-	struct sk_buff		*skb;
-	u32			len;
-};
-
 struct cp_dma_stats {
 	u64			tx_ok;
 	u64			rx_ok;
@@ -360,7 +355,7 @@ struct cp_private {
 	unsigned		tx_head		____cacheline_aligned;
 	unsigned		tx_tail;
 	struct cp_desc		*tx_ring;
-	struct ring_info	tx_skb[CP_TX_RING_SIZE];
+	struct sk_buff		*tx_skb[CP_TX_RING_SIZE];
 
 	unsigned		rx_buf_sz;
 	unsigned		wol_enabled : 1; /* Is Wake-on-LAN enabled? */
@@ -721,11 +716,12 @@ static void cp_tx (struct cp_private *cp
 		if (status & DescOwn)
 			break;
 
-		skb = cp->tx_skb[tx_tail].skb;
+		skb = cp->tx_skb[tx_tail];
 		BUG_ON(!skb);
 
 		pci_unmap_single(cp->pdev, le64_to_cpu(txd->addr),
-				 cp->tx_skb[tx_tail].len, PCI_DMA_TODEVICE);
+				 le32_to_cpu(txd->opts1) & 0xffff,
+				 PCI_DMA_TODEVICE);
 
 		if (status & LastFrag) {
 			if (status & (TxError | TxFIFOUnder)) {
@@ -752,7 +748,7 @@ static void cp_tx (struct cp_private *cp
 			dev_kfree_skb_irq(skb);
 		}
 
-		cp->tx_skb[tx_tail].skb = NULL;
+		cp->tx_skb[tx_tail] = NULL;
 
 		tx_tail = NEXT_TX(tx_tail);
 	}
@@ -822,8 +818,7 @@ #endif
 		txd->opts1 = cpu_to_le32(flags);
 		wmb();
 
-		cp->tx_skb[entry].skb = skb;
-		cp->tx_skb[entry].len = len;
+		cp->tx_skb[entry] = skb;
 		entry = NEXT_TX(entry);
 	} else {
 		struct cp_desc *txd;
@@ -839,8 +834,7 @@ #endif
 		first_len = skb_headlen(skb);
 		first_mapping = pci_map_single(cp->pdev, skb->data,
 					       first_len, PCI_DMA_TODEVICE);
-		cp->tx_skb[entry].skb = skb;
-		cp->tx_skb[entry].len = first_len;
+		cp->tx_skb[entry] = skb;
 		entry = NEXT_TX(entry);
 
 		for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
@@ -881,8 +875,7 @@ #endif
 			txd->opts1 = cpu_to_le32(ctrl);
 			wmb();
 
-			cp->tx_skb[entry].skb = skb;
-			cp->tx_skb[entry].len = len;
+			cp->tx_skb[entry] = skb;
 			entry = NEXT_TX(entry);
 		}
 
@@ -1159,12 +1152,13 @@ static void cp_clean_rings (struct cp_pr
 	}
 
 	for (i = 0; i < CP_TX_RING_SIZE; i++) {
-		if (cp->tx_skb[i].skb) {
-			struct sk_buff *skb = cp->tx_skb[i].skb;
+		if (cp->tx_skb[i]) {
+			struct sk_buff *skb = cp->tx_skb[i];
 
 			desc = cp->tx_ring + i;
 			pci_unmap_single(cp->pdev, le64_to_cpu(desc->addr),
-				 	 cp->tx_skb[i].len, PCI_DMA_TODEVICE);
+					 le32_to_cpu(desc->opts1) & 0xffff,
+					 PCI_DMA_TODEVICE);
 			if (le32_to_cpu(desc->opts1) & LastFrag)
 				dev_kfree_skb(skb);
 			cp->net_stats.tx_dropped++;
@@ -1175,7 +1169,7 @@ static void cp_clean_rings (struct cp_pr
 	memset(cp->tx_ring, 0, sizeof(struct cp_desc) * CP_TX_RING_SIZE);
 
 	memset(cp->rx_skb, 0, sizeof(struct sk_buff *) * CP_RX_RING_SIZE);
-	memset(&cp->tx_skb, 0, sizeof(struct ring_info) * CP_TX_RING_SIZE);
+	memset(cp->tx_skb, 0, sizeof(struct sk_buff *) * CP_TX_RING_SIZE);
 }
 
 static void cp_free_rings (struct cp_private *cp)
