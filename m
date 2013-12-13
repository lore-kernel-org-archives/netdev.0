From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH] dmaengine: fix sleep in atomic
Date: Fri, 13 Dec 2013 01:01:18 -0800
Message-ID: <20131213090100.23207.82563.stgit@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dave.jiang@intel.com
To: dmaengine@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16599 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752176Ab3LMJBT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Dec 2013 04:01:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 BUG: sleeping function called from invalid context at mm/mempool.c:203
 in_atomic(): 1, irqs_disabled(): 0, pid: 43502, name: linbug
 no locks held by linbug/43502.
 CPU: 7 PID: 43502 Comm: linbug Not tainted 3.13.0-rc1+ #15
 Hardware name:
  0000000000000010 ffff88005ebd1878 ffffffff8172d512 ffff8801752bc1c0
  ffff8801752bc1c0 ffff88005ebd1898 ffffffff8109d1f6 ffff88005f9a3c58
  ffff880177f0f080 ffff88005ebd1918 ffffffff81161f43 ffff88005ebd18f8
 Call Trace:
  [<ffffffff8172d512>] dump_stack+0x4e/0x68
  [<ffffffff8109d1f6>] __might_sleep+0xe6/0x120
  [<ffffffff81161f43>] mempool_alloc+0x93/0x170
  [<ffffffff810c0c34>] ? mark_held_locks+0x74/0x140
  [<ffffffff8118a826>] ? follow_page_mask+0x556/0x600
  [<ffffffff814107ae>] dmaengine_get_unmap_data+0x2e/0x60
  [<ffffffff81410f11>] dma_async_memcpy_pg_to_pg+0x41/0x1c0
  [<ffffffff814110e0>] dma_async_memcpy_buf_to_pg+0x50/0x60
  [<ffffffff81411bdc>] dma_memcpy_to_iovec+0xfc/0x190
  [<ffffffff816163af>] dma_skb_copy_datagram_iovec+0x6f/0x2b0

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/dmaengine.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
index b601024f518c..ef63b9058f3c 100644
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -1054,7 +1054,7 @@ dma_async_memcpy_pg_to_pg(struct dma_chan *chan, struct page *dest_pg,
 	dma_cookie_t cookie;
 	unsigned long flags;
 
-	unmap = dmaengine_get_unmap_data(dev->dev, 2, GFP_NOIO);
+	unmap = dmaengine_get_unmap_data(dev->dev, 2, GFP_NOWAIT);
 	if (!unmap)
 		return -ENOMEM;
 
