From: Feng Tang <feng.tang@intel.com>
Subject: Backported alx driver fix for stable 4.4 kernel and older
Date: Tue, 28 Jun 2016 16:23:44 +0800
Message-ID: <20160628082344.GA8213@shbuild888>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="d6Gm4EdcadzBjdND"
Cc: Eric Dumazet <edumazet@google.com>, Ole Lukoie <olelukoie@mail.ru>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:39465 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752020AbcF1IVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 04:21:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--d6Gm4EdcadzBjdND
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi David,

Greg KH has picked up the alx driver fix for 4.6 stable kernel, and
people are asking about plan for 4.4/4.1 stable kernel in
	https://bugzilla.kernel.org/show_bug.cgi?id=70761

Since the fix patch in your "net" git can't be applied to 4.4 and older
kernel as is, so I backport it as follows. Could you help to add it
to your stable queue.

Let me know if I break any netdev+stable patch rule, thanks

- Feng

----

>From 9c9caee22400c7ed3a514b1ee5e017e5e5b6b812 Mon Sep 17 00:00:00 2001
From: Feng Tang <feng.tang@intel.com>
Date: Fri, 24 Jun 2016 15:26:05 +0800
Subject: [PATCH] net: alx: Work around the DMA RX overflow issue

Note: This is a verified backported patch for stable 4.4 kernel, and it
could also be applied to 4.3/4.2/4.1/3.18/3.16

There is a problem with alx devices, that the network link will be
lost in 1-5 minutes after the device is up.

>From debugging without datasheet, we found the error always
happen when the DMA RX address is set to 0x....fc0, which is very
likely to be a HW/silicon problem.

This patch will apply rx skb with 64 bytes longer space, and if the
allocated skb has a 0x...fc0 address, it will use skb_resever(skb, 64)
to advance the address, so that the RX overflow can be avoided.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=70761
Signed-off-by: Feng Tang <feng.tang@intel.com>
Suggested-by: Eric Dumazet <edumazet@google.com>
Tested-by: Ole Lukoie <olelukoie@mail.ru>
---
 drivers/net/ethernet/atheros/alx/main.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index c8af3ce..a43d6a8 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -86,9 +86,14 @@ static int alx_refill_rx_ring(struct alx_priv *alx, gfp_t gfp)
 	while (!cur_buf->skb && next != rxq->read_idx) {
 		struct alx_rfd *rfd = &rxq->rfd[cur];
 
-		skb = __netdev_alloc_skb(alx->dev, alx->rxbuf_size, gfp);
+		skb = __netdev_alloc_skb(alx->dev, alx->rxbuf_size + 64, gfp);
 		if (!skb)
 			break;
+
+		/* Workround for the HW RX DMA overflow issue */
+		if (((unsigned long)skb->data & 0xfff) == 0xfc0)
+			skb_reserve(skb, 64);
+
 		dma = dma_map_single(&alx->hw.pdev->dev,
 				     skb->data, alx->rxbuf_size,
 				     DMA_FROM_DEVICE);
-- 
2.5.0


--d6Gm4EdcadzBjdND
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-net-alx-Work-around-the-DMA-RX-overflow-issue.patch"

>From 9c9caee22400c7ed3a514b1ee5e017e5e5b6b812 Mon Sep 17 00:00:00 2001
From: Feng Tang <feng.tang@intel.com>
Date: Fri, 24 Jun 2016 15:26:05 +0800
Subject: [PATCH] net: alx: Work around the DMA RX overflow issue

Note: This is a verified backported patch for stable 4.4 kernel, and it
could also be applied to 4.3/4.2/4.1/3.18/3.16

There is a problem with alx devices, that the network link will be
lost in 1-5 minutes after the device is up.

>From debugging without datasheet, we found the error always
happen when the DMA RX address is set to 0x....fc0, which is very
likely to be a HW/silicon problem.

This patch will apply rx skb with 64 bytes longer space, and if the
allocated skb has a 0x...fc0 address, it will use skb_resever(skb, 64)
to advance the address, so that the RX overflow can be avoided.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=70761
Signed-off-by: Feng Tang <feng.tang@intel.com>
Suggested-by: Eric Dumazet <edumazet@google.com>
Tested-by: Ole Lukoie <olelukoie@mail.ru>
---
 drivers/net/ethernet/atheros/alx/main.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index c8af3ce..a43d6a8 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -86,9 +86,14 @@ static int alx_refill_rx_ring(struct alx_priv *alx, gfp_t gfp)
 	while (!cur_buf->skb && next != rxq->read_idx) {
 		struct alx_rfd *rfd = &rxq->rfd[cur];
 
-		skb = __netdev_alloc_skb(alx->dev, alx->rxbuf_size, gfp);
+		skb = __netdev_alloc_skb(alx->dev, alx->rxbuf_size + 64, gfp);
 		if (!skb)
 			break;
+
+		/* Workround for the HW RX DMA overflow issue */
+		if (((unsigned long)skb->data & 0xfff) == 0xfc0)
+			skb_reserve(skb, 64);
+
 		dma = dma_map_single(&alx->hw.pdev->dev,
 				     skb->data, alx->rxbuf_size,
 				     DMA_FROM_DEVICE);
-- 
2.5.0


--d6Gm4EdcadzBjdND--
