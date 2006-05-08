From: Stephen Hemminger <shemminger@osdl.org>
Subject: [patch 4/9] sky2: use mask instead of modulo operation
Date: Mon, 08 May 2006 15:11:29 -0700
Message-ID: <20060508221228.811857000@localhost.localdomain>
References: <20060508221125.177816000@localhost.localdomain>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:11965 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751306AbWEHWXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 May 2006 18:23:52 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k48MNmtH003751
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 8 May 2006 15:23:49 -0700
Received: from shell0.pdx.osdl.net (localhost [127.0.0.1])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id k48MNmtJ023554
	for <netdev@vger.kernel.org>; Mon, 8 May 2006 15:23:48 -0700
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=sky2-ring-math.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gcc isn't smart enough to know that it can do a modulo
operation with power of 2 constant by doing a mask.
So add macro to do it for us.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sky2.c
+++ sky2/drivers/net/sky2.c
@@ -79,6 +79,8 @@
 #define NAPI_WEIGHT		64
 #define PHY_RETRIES		1000
 
+#define RING_NEXT(x,s)	(((x)+1) & ((s)-1))
+
 static const u32 default_msg =
     NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK
     | NETIF_MSG_TIMER | NETIF_MSG_TX_ERR | NETIF_MSG_RX_ERR
@@ -719,7 +721,7 @@ static inline struct sky2_tx_le *get_tx_
 {
 	struct sky2_tx_le *le = sky2->tx_le + sky2->tx_prod;
 
-	sky2->tx_prod = (sky2->tx_prod + 1) % TX_RING_SIZE;
+	sky2->tx_prod = RING_NEXT(sky2->tx_prod, TX_RING_SIZE);
 	return le;
 }
 
@@ -735,7 +737,7 @@ static inline void sky2_put_idx(struct s
 static inline struct sky2_rx_le *sky2_next_rx(struct sky2_port *sky2)
 {
 	struct sky2_rx_le *le = sky2->rx_le + sky2->rx_put;
-	sky2->rx_put = (sky2->rx_put + 1) % RX_LE_SIZE;
+	sky2->rx_put = RING_NEXT(sky2->rx_put, RX_LE_SIZE);
 	return le;
 }
 
@@ -1078,7 +1080,7 @@ err_out:
 /* Modular subtraction in ring */
 static inline int tx_dist(unsigned tail, unsigned head)
 {
-	return (head - tail) % TX_RING_SIZE;
+	return (head - tail) & (TX_RING_SIZE - 1);
 }
 
 /* Number of list elements available for next tx */
@@ -1255,7 +1257,7 @@ static int sky2_xmit_frame(struct sk_buf
 		le->opcode = OP_BUFFER | HW_OWNER;
 
 		fre = sky2->tx_ring
-		    + ((re - sky2->tx_ring) + i + 1) % TX_RING_SIZE;
+		    + RING_NEXT((re - sky2->tx_ring) + i, TX_RING_SIZE);
 		pci_unmap_addr_set(fre, mapaddr, mapping);
 	}
 
@@ -1315,7 +1317,7 @@ static void sky2_tx_complete(struct sky2
 
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			struct tx_ring_info *fre;
-			fre = sky2->tx_ring + (put + i + 1) % TX_RING_SIZE;
+			fre = sky2->tx_ring + RING_NEXT(put + i, TX_RING_SIZE);
 			pci_unmap_page(pdev, pci_unmap_addr(fre, mapaddr),
 				       skb_shinfo(skb)->frags[i].size,
 				       PCI_DMA_TODEVICE);
@@ -1876,7 +1878,7 @@ static int sky2_status_intr(struct sky2_
 			break;
 		opcode &= ~HW_OWNER;
 
-		hw->st_idx = (hw->st_idx + 1) % STATUS_RING_SIZE;
+		hw->st_idx = RING_NEXT(hw->st_idx, STATUS_RING_SIZE);
 		le->opcode = 0;
 
 		link = le->link;

--

