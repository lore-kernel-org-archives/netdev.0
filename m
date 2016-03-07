From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] sh_eth: advance 'rxdesc' later in sh_eth_ring_format()
Date: Tue, 08 Mar 2016 01:37:09 +0300
Message-ID: <3282122.t8AnRHByyx@wasted.cogentembedded.com>
References: <4881302.XJJSmqvE1J@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:35020 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753567AbcCGWhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 17:37:13 -0500
Received: by mail-lb0-f182.google.com with SMTP id bc4so148168539lbc.2
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 14:37:12 -0800 (PST)
In-Reply-To: <4881302.XJJSmqvE1J@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Iff dma_map_single() fails, 'rxdesc'  should point  to the last filled RX
descriptor, so  that it can be marked as the last one, however the driver
would have  already  advanced it by that time. In order to fix that, only
fill  an RX descriptor  once all the data for it is ready.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

Index: net/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net/drivers/net/ethernet/renesas/sh_eth.c
@@ -1136,11 +1136,8 @@ static void sh_eth_ring_format(struct ne
 			break;
 		sh_eth_set_receive_align(skb);
 
-		/* RX descriptor */
-		rxdesc = &mdp->rx_ring[i];
 		/* The size of the buffer is a multiple of 32 bytes. */
 		buf_len = ALIGN(mdp->rx_buf_sz, 32);
-		rxdesc->len = cpu_to_le32(buf_len << 16);
 		dma_addr = dma_map_single(&ndev->dev, skb->data, buf_len,
 					  DMA_FROM_DEVICE);
 		if (dma_mapping_error(&ndev->dev, dma_addr)) {
@@ -1148,6 +1145,10 @@ static void sh_eth_ring_format(struct ne
 			break;
 		}
 		mdp->rx_skbuff[i] = skb;
+
+		/* RX descriptor */
+		rxdesc = &mdp->rx_ring[i];
+		rxdesc->len = cpu_to_le32(buf_len << 16);
 		rxdesc->addr = cpu_to_le32(dma_addr);
 		rxdesc->status = cpu_to_le32(RD_RACT | RD_RFP);
 
