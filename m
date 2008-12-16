From: Sakari Ailus <sakari.ailus@iki.fi>
Subject: [PATCH 1/2] tlan: Fix pci memory unmapping
Date: Tue, 16 Dec 2008 17:25:15 +0200
Message-ID: <1229441116-15077-1-git-send-email-sakari.ailus@iki.fi>
References: <4947C842.1020503@iki.fi>
Cc: Sakari Ailus <sakari.ailus@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw01.mail.saunalahti.fi ([195.197.172.115]:45126 "EHLO
	gw01.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756444AbYLPPZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 10:25:23 -0500
In-Reply-To: <4947C842.1020503@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix pci unmapping problem introduced by commit id
8953f1282793882a5444924f7a273dc72a43d0a3 "tlan: Fix small (< 64 bytes)
datagram transmissions".

Signed-off-by: Sakari Ailus <sakari.ailus@iki.fi>
---
 drivers/net/tlan.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index cf8cdaf..e604982 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -1433,7 +1433,9 @@ static u32 TLan_HandleTxEOF( struct net_device *dev, u16 host_int )
 		if ( ! bbuf ) {
 			struct sk_buff *skb = TLan_GetSKB(head_list);
 			pci_unmap_single(priv->pciDev, head_list->buffer[0].address,
-					 skb->len, PCI_DMA_TODEVICE);
+					 max(skb->len,
+					     (unsigned int)TLAN_MIN_FRAME_SIZE),
+					 PCI_DMA_TODEVICE);
 			dev_kfree_skb_any(skb);
 			head_list->buffer[8].address = 0;
 			head_list->buffer[9].address = 0;
@@ -2057,9 +2059,12 @@ static void TLan_FreeLists( struct net_device *dev )
 			list = priv->txList + i;
 			skb = TLan_GetSKB(list);
 			if ( skb ) {
-				pci_unmap_single(priv->pciDev,
-						 list->buffer[0].address, skb->len,
-						 PCI_DMA_TODEVICE);
+				pci_unmap_single(
+					priv->pciDev,
+					list->buffer[0].address,
+					max(skb->len,
+					    (unsigned int)TLAN_MIN_FRAME_SIZE),
+					PCI_DMA_TODEVICE);
 				dev_kfree_skb_any( skb );
 				list->buffer[8].address = 0;
 				list->buffer[9].address = 0;
-- 
1.5.6.5

