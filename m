From: Eric Wheeler <netdev@lists.ewheeler.net>
Subject: [PATCH net] bna: page allocation during interrupts to use a
 mempool.
Date: Mon, 6 Oct 2014 18:57:24 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1410061850120.5129@ware.dreamhost.com>
References: <alpine.DEB.2.00.1409271631530.26069@ware.dreamhost.com> <20140929092833.6c2cb7e9@urahara> <262CB373A6D1F14F9B81E82F74F77D5A4704FAE7@avmb2.qlogic.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	"rmody@brocade.com" <rmody@brocade.com>,
	Rasesh Mody <rasesh.mody@qlogic.com>
To: Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from homie.mail.dreamhost.com ([208.97.132.208]:40241 "EHLO
	homiemail-a60.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751213AbaJGBmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 21:42:02 -0400
In-Reply-To: <262CB373A6D1F14F9B81E82F74F77D5A4704FAE7@avmb2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes an order:2 memory allocation error backtrace by 
guaranteeing that memory is available during simultaneous high memory 
pressure and packet rates when using 9k jumbo frames.

Tests between two systems (one patched, one not) succeeded with ~1TB of 
data transferred over DRBD.  As expected, the unpatched host gave 
warn_alloc_failed's, and the patched host worked correctly.  This patch 
increases kernel memory usage by 32 order-2 allocation when this module is 
loaded (512k on x86) which should be negligible on hosts that use 10GbE 
cards.

Fixes:
[<ffffffff8113b17b>] warn_alloc_failed+0xeb/0x150
[<ffffffff8113e2f0>] __alloc_pages_slowpath+0x4a0/0x7e0
[<ffffffff8113e8e2>] __alloc_pages_nodemask+0x2b2/0x2c0
[<ffffffff81181232>] alloc_pages_current+0xb2/0x170
[<ffffffffa0239cb4>] bnad_rxq_refill_page+0x154/0x1e0 [bna]
[<ffffffffa023c282>] bnad_cq_process+0x462/0x840 [bna]
[<ffffffffa023c6af>] bnad_napi_poll_rx+0x4f/0xc0 [bna]
[<ffffffff814dcf4c>] net_rx_action+0xfc/0x280
[<ffffffff8105ba83>] __do_softirq+0xf3/0x2c0
[<ffffffff8105bd5d>] irq_exit+0xbd/0xd0
[<ffffffff815ae697>] do_IRQ+0x67/0x110
[<ffffffff815a39ad>] common_interrupt+0x6d/0x6d
<EOI>
[<ffffffff81486275>] ? cpuidle_enter_state+0x55/0xd0
[<ffffffff8148626b>] ? cpuidle_enter_state+0x4b/0xd0
[<ffffffff814863b7>] cpuidle_idle_call+0xc7/0x160
[<ffffffff8100d73e>] arch_cpu_idle+0xe/0x30
[<ffffffff810b187e>] cpu_idle_loop+0x9e/0x250
[<ffffffff810b1aa0>] cpu_startup_entry+0x70/0x80
[<ffffffff810350d2>] start_secondary+0xd2/0xe0

Signed-off-by: Eric Wheeler <netdev@lists.ewheeler.net>
---
  drivers/net/ethernet/brocade/bna/bnad.c |   27 ++++++++++++++++++++++++---
  1 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 3a77f9e..8906ad1 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -26,6 +26,7 @@
  #include <linux/ip.h>
  #include <linux/prefetch.h>
  #include <linux/module.h>
+#include <linux/mempool.h>

  #include "bnad.h"
  #include "bna.h"
@@ -58,6 +59,8 @@ static struct mutex bnad_list_mutex;
  static LIST_HEAD(bnad_list);
  static const u8 bnad_bcast_addr[] =  {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};

+static mempool_t *rxq_mempool_o2 = NULL;
+
  /*
   * Local MACROS
   */
@@ -321,7 +324,7 @@ bnad_rxq_cleanup_page(struct bnad *bnad, struct bnad_rx_unmap *unmap)
  	dma_unmap_page(&bnad->pcidev->dev,
  			dma_unmap_addr(&unmap->vector, dma_addr),
  			unmap->vector.len, DMA_FROM_DEVICE);
-	put_page(unmap->page);
+	mempool_free(unmap->page, rxq_mempool_o2);
  	unmap->page = NULL;
  	dma_unmap_addr_set(&unmap->vector, dma_addr, 0);
  	unmap->vector.len = 0;
@@ -380,8 +383,11 @@ bnad_rxq_refill_page(struct bnad *bnad, struct bna_rcb *rcb, u32 nalloc)
  		unmap = &unmap_q->unmap[prod];

  		if (unmap_q->reuse_pi < 0) {
-			page = alloc_pages(GFP_ATOMIC | __GFP_COMP,
-					unmap_q->alloc_order);
+			if (unmap_q->alloc_order == 2)
+				page = mempool_alloc(rxq_mempool_o2, GFP_ATOMIC | __GFP_COMP);
+			else
+				page = alloc_pages(GFP_ATOMIC | __GFP_COMP,
+						unmap_q->alloc_order);
  			page_offset = 0;
  		} else {
  			prev = &unmap_q->unmap[unmap_q->reuse_pi];
@@ -3861,6 +3867,16 @@ static struct pci_driver bnad_pci_driver = {
  	.remove = bnad_pci_remove,
  };

+void *bnad_rxq_mempool_alloc_o2(gfp_t gfp_mask, void *pool_data)
+{
+	return (void*) alloc_pages(gfp_mask, 2);
+}
+
+void bnad_rxq_mempool_free_o2(void *page, void *pool_data)
+{
+	put_page((struct page*)page);
+}
+
  static int __init
  bnad_module_init(void)
  {
@@ -3878,6 +3894,10 @@ bnad_module_init(void)
  		return err;
  	}

+	rxq_mempool_o2 = mempool_create(32, /* how many do we really need? */
+		bnad_rxq_mempool_alloc_o2,
+		bnad_rxq_mempool_free_o2, NULL);
+
  	return 0;
  }

@@ -3886,6 +3906,7 @@ bnad_module_exit(void)
  {
  	pci_unregister_driver(&bnad_pci_driver);
  	release_firmware(bfi_fw);
+	mempool_destroy(rxq_mempool_o2);
  }

  module_init(bnad_module_init);
-- 
1.7.1
