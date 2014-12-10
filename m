From: David Miller <davem@davemloft.net>
Subject: errors in alignment changes..
Date: Wed, 10 Dec 2014 15:52:03 -0500 (EST)
Message-ID: <20141210.155203.1136471667049608187.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mitsuhiro.kimura.kc@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47756 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932116AbaLJUwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 15:52:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I just re-reviewed this change:

commit 4d6a949c62f123569fb355b6ec7f314b76f93735
Author: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
Date:   Thu Nov 27 20:34:00 2014 +0900

    sh_eth: Fix skb alloc size and alignment adjust rule.

and it has serious problems.  Well, actually the code has
always been broken in this area.

+		/* The size of the buffer is a multiple of 16 bytes. */
+		rxdesc->buffer_length = ALIGN(mdp->rx_buf_sz, 16);
+		dma_map_single(&ndev->dev, skb->data, rxdesc->buffer_length,
+			       DMA_FROM_DEVICE);
 		rxdesc->addr = virt_to_phys(PTR_ALIGN(skb->data, 4));
 		rxdesc->status = cpu_to_edmac(mdp, RD_RACT | RD_RFP);

It doesn't make any sense to call dma_map_single() if you aren't
even going to use the return value.  The DMA mapping created is
the whole point of calling this function.

And then later we pass:

 			dma_sync_single_for_cpu(&ndev->dev, rxdesc->addr,
-						mdp->rx_buf_sz,
+						ALIGN(mdp->rx_buf_sz, 16),
 						DMA_FROM_DEVICE);

rxdesc->addr as the "DMA address", but that must be the return value
from dma_map_single() not what you've actually stored there which is
virt_to_phys() run on the skb->data.

This code must be fixed to:

1) Put the return value from dma_map_single() into a local variable,
   and check for mapping errors.

2) On success put that return value into rxdesc->addr
