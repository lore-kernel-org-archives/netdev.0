From: stufever@gmail.com
Subject: [PATCH] ATM: Fix wrong usage of INIT_WORK
Date: Thu,  7 Jul 2011 19:51:52 +0800
Message-ID: <1310039512-17579-1-git-send-email-wangshaoyan.pt@taobao.com>
Cc: Wang Shaoyan <wangshaoyan.pt@taobao.com>,
	Chas Williams <chas@cmf.nrl.navy.mil> (maintainer:ATM),
	linux-atm-general@lists.sourceforge.net (open list:ATM)
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:61193 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755698Ab1GGLrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 07:47:46 -0400
Received: by iwn6 with SMTP id 6so758886iwn.19
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2011 04:47:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Shaoyan <wangshaoyan.pt@taobao.com>

If we define FILL_RX_POOLS_IN_BH, the compiler will report error such as
  drivers/atm/ambassador.c:2159:64: error: macro "INIT_WORK" passed 3 arguments, but takes just 2
because the function INIT_WORK() don't accept "data" now, it only has
two arguments, so use the right way to initialise work queue.

Cc: Chas Williams <chas@cmf.nrl.navy.mil> (maintainer:ATM)
Cc: linux-atm-general@lists.sourceforge.net (open list:ATM)
Signed-off-by: Wang Shaoyan <wangshaoyan.pt@taobao.com>
---
 drivers/atm/ambassador.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
index a5fcb1e..3618c5c 100644
--- a/drivers/atm/ambassador.c
+++ b/drivers/atm/ambassador.c
@@ -814,7 +814,12 @@ static void fill_rx_pool (amb_dev * dev, unsigned char pool,
 }
 
 // top up all RX pools (can also be called as a bottom half)
+#ifdef FILL_RX_POOLS_IN_BH
+static void fill_rx_pools (struct work_struct * work) {
+  amb_dev * dev = container_of(work, amb_dev, bh);
+#else
 static void fill_rx_pools (amb_dev * dev) {
+#endif
   unsigned char pool;
   
   PRINTD (DBG_FLOW|DBG_POOL, "fill_rx_pools %p", dev);
@@ -1503,7 +1508,11 @@ static void do_housekeeping (unsigned long arg) {
   // could collect device-specific (not driver/atm-linux) stats here
       
   // last resort refill once every ten seconds
+#ifdef FILL_RX_POOLS_IN_BH
+  fill_rx_pools (&dev->bh);
+#else
   fill_rx_pools (dev);
+#endif
   mod_timer(&dev->housekeeping, jiffies + 10*HZ);
   
   return;
@@ -2156,7 +2165,7 @@ static void setup_dev(amb_dev *dev, struct pci_dev *pci_dev)
       
 #ifdef FILL_RX_POOLS_IN_BH
       // initialise bottom half
-      INIT_WORK(&dev->bh, (void (*)(void *)) fill_rx_pools, dev);
+      INIT_WORK(&dev->bh, fill_rx_pools);
 #endif
       
       // semaphore for txer/rxer modifications - we cannot use a
-- 
1.7.4.1

