From: Sakari Ailus <sakari.ailus@iki.fi>
Subject: [PATCH] tlan: Fix small (< 64 bytes) datagram transmissions
Date: Tue, 16 Dec 2008 09:27:05 +0200
Message-ID: <1229412425-2619-1-git-send-email-sakari.ailus@iki.fi>
Cc: Sakari Ailus <sakari.ailus@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw01.mail.saunalahti.fi ([195.197.172.115]:41200 "EHLO
	gw01.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189AbYLPHfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 02:35:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TLAN chip does not support tranmissions smaller than 64 bytes. Smaller
transfers need to be padded up to that size. This was broken by commit id
41873e9aff0632d80c74380d58a89e8d420151bd.

<URL:http://bugzilla.kernel.org/show_bug.cgi?id=11754>

Signed-off-by: Sakari Ailus <sakari.ailus@iki.fi>
---
 drivers/net/tlan.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index c41d687..cf8cdaf 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -1098,6 +1098,7 @@ static int TLan_StartTx( struct sk_buff *skb, struct net_device *dev )
 	dma_addr_t	tail_list_phys;
 	u8		*tail_buffer;
 	unsigned long	flags;
+	unsigned int    txlen;
 
 	if ( ! priv->phyOnline ) {
 		TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  %s PHY is not ready\n",
@@ -1108,6 +1109,7 @@ static int TLan_StartTx( struct sk_buff *skb, struct net_device *dev )
 
 	if (skb_padto(skb, TLAN_MIN_FRAME_SIZE))
 		return 0;
+	txlen = max(skb->len, (unsigned int)TLAN_MIN_FRAME_SIZE);
 
 	tail_list = priv->txList + priv->txTail;
 	tail_list_phys = priv->txListDMA + sizeof(TLanList) * priv->txTail;
@@ -1125,16 +1127,16 @@ static int TLan_StartTx( struct sk_buff *skb, struct net_device *dev )
 
 	if ( bbuf ) {
 		tail_buffer = priv->txBuffer + ( priv->txTail * TLAN_MAX_FRAME_SIZE );
-		skb_copy_from_linear_data(skb, tail_buffer, skb->len);
+		skb_copy_from_linear_data(skb, tail_buffer, txlen);
 	} else {
 		tail_list->buffer[0].address = pci_map_single(priv->pciDev,
-							      skb->data, skb->len,
+							      skb->data, txlen,
 							      PCI_DMA_TODEVICE);
 		TLan_StoreSKB(tail_list, skb);
 	}
 
-	tail_list->frameSize = (u16) skb->len;
-	tail_list->buffer[0].count = TLAN_LAST_BUFFER | (u32) skb->len;
+	tail_list->frameSize = (u16) txlen;
+	tail_list->buffer[0].count = TLAN_LAST_BUFFER | (u32) txlen;
 	tail_list->buffer[1].count = 0;
 	tail_list->buffer[1].address = 0;
 
-- 
1.5.6.5

