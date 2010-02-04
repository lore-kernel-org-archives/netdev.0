From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH 1/2] e1000: Fix DMA mapping error handling on TX
Date: Thu, 04 Feb 2010 14:00:21 +0100
Message-ID: <4B6AC4E5.4080104@gmail.com>
References: <20100121114244.GC32259@kryten>	 <9929d2391001221940r4482dde4k8e5409bc7933bc21@mail.gmail.com>	 <20100124004753.GB2996@kryten> <9929d2391001231958n3f8d5165yaeed9ec1e0d7121a@mail.gmail.com> <4B5F1164.8030102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	Anton Blanchard <anton@samba.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Yi Zou <yi.zou@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f228.google.com ([209.85.219.228]:33079 "EHLO
	mail-ew0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756508Ab0BDMyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 07:54:04 -0500
Received: by ewy28 with SMTP id 28so2832101ewy.28
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2010 04:54:01 -0800 (PST)
In-Reply-To: <4B5F1164.8030102@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These functions have off by one errors in their dma mapping error cleanup
paths. We decrement count and never clean the first successfully mapped
descriptor.

Reported-by: "Anton Blanchard" <anton@samba.org>
Reported-by: "Juha Leppanen" <juha_motorsportcom@luukku.com>
Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 drivers/net/e1000e/netdev.c    |    4 +---
 drivers/net/igbvf/netdev.c     |    4 +---
 drivers/net/ixgb/ixgb_main.c   |    4 +---
 drivers/net/ixgbe/ixgbe_main.c |    4 +---
 4 files changed, 4 insertions(+), 12 deletions(-)

My previous fix inadvertently introduced this change.

The e1000_tx_map() function in drivers/net/e1000/e1000_main.c is already
fixed by the patch sent by Anton Blanchard that can be found here:

http://www.mail-archive.com/e1000-devel@lists.sourceforge.net/msg02313.html

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 57f149b..57c3d44 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3967,12 +3967,10 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 dma_error:
 	dev_err(&pdev->dev, "TX DMA map failed\n");
 	buffer_info->dma = 0;
-	if (count)
-		count--;
 
 	while (count--) {
 		if (i==0)
-			i += tx_ring->count;
+			i = tx_ring->count;
 		i--;
 		buffer_info = &tx_ring->buffer_info[i];
 		e1000_put_txbuf(adapter, buffer_info);;
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 2aa71a7..3b12603 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -2164,13 +2164,11 @@ dma_error:
 	buffer_info->length = 0;
 	buffer_info->next_to_watch = 0;
 	buffer_info->mapped_as_page = false;
-	if (count)
-		count--;
 
 	/* clear timestamp and dma mappings for remaining portion of packet */
 	while (count--) {
 		if (i==0)
-			i += tx_ring->count;
+			i = tx_ring->count;
 		i--;
 		buffer_info = &tx_ring->buffer_info[i];
 		igbvf_put_txbuf(adapter, buffer_info);
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 593d1a4..de9b36c 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1363,12 +1363,10 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 dma_error:
 	dev_err(&pdev->dev, "TX DMA map failed\n");
 	buffer_info->dma = 0;
-	if (count)
-		count--;
 
 	while (count--) {
 		if (i==0)
-			i += tx_ring->count;
+			i = tx_ring->count;
 		i--;
 		buffer_info = &tx_ring->buffer_info[i];
 		ixgb_unmap_and_free_tx_resource(adapter, buffer_info);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index b5f64ad..1713258 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5167,13 +5167,11 @@ dma_error:
 	tx_buffer_info->dma = 0;
 	tx_buffer_info->time_stamp = 0;
 	tx_buffer_info->next_to_watch = 0;
-	if (count)
-		count--;
 
 	/* clear timestamp and dma mappings for remaining portion of packet */
 	while (count--) {
 		if (i==0)
-			i += tx_ring->count;
+			i = tx_ring->count;
 		i--;
 		tx_buffer_info = &tx_ring->tx_buffer_info[i];
 		ixgbe_unmap_and_free_tx_resource(adapter, tx_buffer_info);
