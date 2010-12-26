From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] Broadcom CNIC core network driver: fix mem leak on allocation
 failures in cnic_alloc_uio_rings()
Date: Sun, 26 Dec 2010 21:30:43 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1012262124320.20797@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org,
	"John(Zongxi) Chen" <zongxi@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:18421 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752621Ab0LZUkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Dec 2010 15:40:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We are leaking memory in drivers/net/cnic.c::cnic_alloc_uio_rings() if 
either of the calls to dma_alloc_coherent() fail. This patch fixes it by 
freeing both the memory allocated with kzalloc() and memory allocated with 
previous calls to dma_alloc_coherent() when there's a failure.


Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 cnic.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

  compile tested only since I don't have the hardware to do a proper test.

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 92bac19..f094159 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -939,16 +939,22 @@ static int cnic_alloc_uio_rings(struct cnic_dev *dev, int pages)
 	udev->l2_ring = dma_alloc_coherent(&udev->pdev->dev, udev->l2_ring_size,
 					   &udev->l2_ring_map,
 					   GFP_KERNEL | __GFP_COMP);
-	if (!udev->l2_ring)
+	if (!udev->l2_ring) {
+		kfree(udev);
 		return -ENOMEM;
+	}
 
 	udev->l2_buf_size = (cp->l2_rx_ring_size + 1) * cp->l2_single_buf_size;
 	udev->l2_buf_size = PAGE_ALIGN(udev->l2_buf_size);
 	udev->l2_buf = dma_alloc_coherent(&udev->pdev->dev, udev->l2_buf_size,
 					  &udev->l2_buf_map,
 					  GFP_KERNEL | __GFP_COMP);
-	if (!udev->l2_buf)
+	if (!udev->l2_buf) {
+		dma_free_coherent(&udev->pdev->dev, udev->l2_ring_size,
+				  udev->l2_ring, udev->l2_ring_map);
+		kfree(udev);
 		return -ENOMEM;
+	}
 
 	write_lock(&cnic_dev_lock);
 	list_add(&udev->list, &cnic_udev_list);


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

