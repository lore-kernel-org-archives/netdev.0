From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/2] sky2: rx allocation threshold change
Date: Wed, 28 Nov 2007 14:50:16 -0800
Message-ID: <20071128145016.2e7e85b8@freepuppy.rosehill>
References: <20071128142703.7f0b5e5d@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55744 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758505AbXK1Xf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 18:35:59 -0500
In-Reply-To: <20071128142703.7f0b5e5d@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When using larger MTU's sky2 driver changes from allocating one
data area, to using multiple pages. The threshold for this was based on
a heuristic where the cost of a single allocation is bigger than one
page.  Since the allocator has changed, this heuristic is now incorrect;
instead just make the threshold be when the total size of the allocation
is greater than one page.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-11-28 08:46:57.000000000 -0800
+++ b/drivers/net/sky2.c	2007-11-28 14:48:26.000000000 -0800
@@ -1231,7 +1231,7 @@ static int sky2_rx_start(struct sky2_por
 	struct sky2_hw *hw = sky2->hw;
 	struct rx_ring_info *re;
 	unsigned rxq = rxqaddr[sky2->port];
-	unsigned i, size, space, thresh;
+	unsigned i, size, thresh;
 
 	sky2->rx_put = sky2->rx_next = 0;
 	sky2_qset(hw, rxq);
@@ -1258,28 +1258,18 @@ static int sky2_rx_start(struct sky2_por
 	/* Stopping point for hardware truncation */
 	thresh = (size - 8) / sizeof(u32);
 
-	/* Account for overhead of skb - to avoid order > 0 allocation */
-	space = SKB_DATA_ALIGN(size) + NET_SKB_PAD
-		+ sizeof(struct skb_shared_info);
-
-	sky2->rx_nfrags = space >> PAGE_SHIFT;
+	sky2->rx_nfrags = size >> PAGE_SHIFT;
 	BUG_ON(sky2->rx_nfrags > ARRAY_SIZE(re->frag_addr));
 
-	if (sky2->rx_nfrags != 0) {
-		/* Compute residue after pages */
-		space = sky2->rx_nfrags << PAGE_SHIFT;
+	/* Compute residue after pages */
+	size -= sky2->rx_nfrags << PAGE_SHIFT;
 
-		if (space < size)
-			size -= space;
-		else
-			size = 0;
+	/* Optimize to handle small packets and headers */
+	if (size < copybreak)
+		size = copybreak;
+	if (size < ETH_HLEN)
+		size = ETH_HLEN;
 
-		/* Optimize to handle small packets and headers */
-		if (size < copybreak)
-			size = copybreak;
-		if (size < ETH_HLEN)
-			size = ETH_HLEN;
-	}
 	sky2->rx_data_size = size;
 
 	/* Fill Rx ring */
