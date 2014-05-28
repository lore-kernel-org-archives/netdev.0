From: Amos Kong <akong@redhat.com>
Subject: [PATCH] mvme147: use correct order of ram pages
Date: Wed, 28 May 2014 12:07:53 +0800
Message-ID: <1401250073-16603-1-git-send-email-akong@redhat.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: geert@linux-m68k.org, linux-m68k@vger.kernel.org
Return-path: <linux-m68k-owner@vger.kernel.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

16K is 2^2 * PAGE_SIZE, so the page order should be 2, not 3.

This patch uses get_order() to get correct order, and fixes
one typo in comment.

Signed-off-by: Amos Kong <akong@redhat.com>
---
This patch wasn't built. Geert, can you help to test it?
I don't know if it needs a head file by using get_order().
---
 drivers/net/ethernet/amd/mvme147.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/amd/mvme147.c b/drivers/net/ethernet/amd/mvme147.c
index 0e8399d..4e98bf8 100644
--- a/drivers/net/ethernet/amd/mvme147.c
+++ b/drivers/net/ethernet/amd/mvme147.c
@@ -26,10 +26,11 @@
 #include <asm/pgtable.h>
 #include <asm/mvme147hw.h>
 
-/* We have 16834 bytes of RAM for the init block and buffers. This places
+/* We have 16384 bytes of RAM for the init block and buffers. This places
  * an upper limit on the number of buffers we can use. NetBSD uses 8 Rx
  * buffers and 2 Tx buffers.
  */
+#define M147LANCE_RAM_SIZE   16384 /* 16K */
 #define LANCE_LOG_TX_BUFFERS 1
 #define LANCE_LOG_RX_BUFFERS 3
 
@@ -111,7 +112,7 @@ struct net_device * __init mvme147lance_probe(int unit)
 	       dev->dev_addr);
 
 	lp = netdev_priv(dev);
-	lp->ram = __get_dma_pages(GFP_ATOMIC, 3);	/* 16K */
+	lp->ram = __get_dma_pages(GFP_ATOMIC, get_order(M147LANCE_RAM_SIZE));
 	if (!lp->ram) {
 		printk("%s: No memory for LANCE buffers\n", dev->name);
 		free_netdev(dev);
@@ -134,7 +135,7 @@ struct net_device * __init mvme147lance_probe(int unit)
 
 	err = register_netdev(dev);
 	if (err) {
-		free_pages(lp->ram, 3);
+		free_pages(lp->ram, get_order(M147LANCE_RAM_SIZE));
 		free_netdev(dev);
 		return ERR_PTR(err);
 	}
@@ -193,7 +194,7 @@ void __exit cleanup_module(void)
 {
 	struct m147lance_private *lp = netdev_priv(dev_mvme147_lance);
 	unregister_netdev(dev_mvme147_lance);
-	free_pages(lp->ram, 3);
+	free_pages(lp->ram, get_order(M147LANCE_RAM_SIZE));
 	free_netdev(dev_mvme147_lance);
 }
 
-- 
1.9.0
