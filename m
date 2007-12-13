From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/2] tulip: hardware mitigation simplify
Date: Thu, 13 Dec 2007 09:35:54 -0800
Message-ID: <20071213093554.5c4909ed@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kristjan <kristjan.ugrin@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33821 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754668AbXLMRhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 12:37:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hardware mitigation in tulip can be simpified.
1. The budget with new NAPI will always be less than RX_RING_SIZE
   because RX_RING_SIZE is 128 and weight is 16.
2. The received counter is redundunt, just use the work_done value.
3. Only one value is used from the mit_table[]

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
This can wait for 2.6.25

--- a/drivers/net/tulip/interrupt.c	2007-12-13 09:26:35.000000000 -0800
+++ b/drivers/net/tulip/interrupt.c	2007-12-13 09:27:29.000000000 -0800
@@ -21,45 +21,6 @@
 int tulip_rx_copybreak;
 unsigned int tulip_max_interrupt_work;
 
-#ifdef CONFIG_TULIP_NAPI_HW_MITIGATION
-#define MIT_SIZE 15
-#define MIT_TABLE 15 /* We use 0 or max */
-
-static unsigned int mit_table[MIT_SIZE+1] =
-{
-        /*  CRS11 21143 hardware Mitigation Control Interrupt
-            We use only RX mitigation we other techniques for
-            TX intr. mitigation.
-
-           31    Cycle Size (timer control)
-           30:27 TX timer in 16 * Cycle size
-           26:24 TX No pkts before Int.
-           23:20 RX timer in Cycle size
-           19:17 RX No pkts before Int.
-           16       Continues Mode (CM)
-        */
-
-        0x0,             /* IM disabled */
-        0x80150000,      /* RX time = 1, RX pkts = 2, CM = 1 */
-        0x80150000,
-        0x80270000,
-        0x80370000,
-        0x80490000,
-        0x80590000,
-        0x80690000,
-        0x807B0000,
-        0x808B0000,
-        0x809D0000,
-        0x80AD0000,
-        0x80BD0000,
-        0x80CF0000,
-        0x80DF0000,
-//       0x80FF0000      /* RX time = 16, RX pkts = 7, CM = 1 */
-        0x80F10000      /* RX time = 16, RX pkts = 0, CM = 1 */
-};
-#endif
-
-
 int tulip_refill_rx(struct net_device *dev)
 {
 	struct tulip_private *tp = netdev_priv(dev);
@@ -113,21 +74,10 @@ int tulip_poll(struct napi_struct *napi,
 	struct net_device *dev = tp->dev;
 	int entry = tp->cur_rx % RX_RING_SIZE;
 	int work_done = 0;
-#ifdef CONFIG_TULIP_NAPI_HW_MITIGATION
-	int received = 0;
-#endif
 
 	if (!netif_running(dev))
 		goto done;
 
-#ifdef CONFIG_TULIP_NAPI_HW_MITIGATION
-
-/* that one buffer is needed for mit activation; or might be a
-   bug in the ring buffer code; check later -- JHS*/
-
-        if (budget >=RX_RING_SIZE) budget--;
-#endif
-
 	if (tulip_debug > 4)
 		printk(KERN_DEBUG " In tulip_rx(), entry %d %8.8x.\n", entry,
 			   tp->rx_ring[entry].status);
@@ -239,9 +189,6 @@ int tulip_poll(struct napi_struct *napi,
                                tp->stats.rx_packets++;
                                tp->stats.rx_bytes += pkt_len;
                        }
-#ifdef CONFIG_TULIP_NAPI_HW_MITIGATION
-		       received++;
-#endif
 
                        entry = (++tp->cur_rx) % RX_RING_SIZE;
                        if (tp->cur_rx - tp->dirty_rx > RX_RING_SIZE/4)
@@ -279,14 +226,14 @@ done:
             ON:  More then 1 pkt received (per intr.) OR we are dropping
              OFF: Only 1 pkt received
 
-             Note. We only use min and max (0, 15) settings from mit_table */
-
+             Note. We only use max or min values for mit */
 
           if( tp->flags &  HAS_INTR_MITIGATION) {
-                 if( received > 1 ) {
+                 if( work_done > 1 ) {
                          if( ! tp->mit_on ) {
                                  tp->mit_on = 1;
-                                 iowrite32(mit_table[MIT_TABLE], tp->base_addr + CSR11);
+				 /* RX time = 16, RX pkts = 0, CM = 1 */
+                                 iowrite32(0x80F10000, tp->base_addr + CSR11);
                          }
                   }
                  else {
