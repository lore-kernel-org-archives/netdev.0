From: Tom Walsh <tomwalsh73@gmail.com>
Subject: Patch: fix rotting packet OKI PCH_GBE switch
Date: Wed, 27 Jul 2016 10:59:05 -0500
Message-ID: <CAMSBNFuhWKGrenCGqPWkARKqdu6tQjRUwXxWL64VVr2wAPdf+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:35972 "EHLO
	mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754085AbcG0P7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 11:59:08 -0400
Received: by mail-lf0-f66.google.com with SMTP id 33so2293734lfw.3
        for <netdev@vger.kernel.org>; Wed, 27 Jul 2016 08:59:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is against torvalds 4.7.0 repo
This resolves a rotting SYN-ACK packet issue with
the OKI PCH_GBE switch.  The problem showed up
intermittently where a client would attempt to
establish a TCP connection to the host on an
otherwise quiet network.  No other activity had
occurred for a significant time.

This was a race condition that was finally duplicated
using a controlled set of timings between the SYN /
ACK / SYN-ACK sequence.  We found that by adjusting
the timing between the host ACK and the client
transmission of the SYN-ACK that we had the SYN-ACK
"stuck" in the switch data register.

The problem is that pch_gbe_irq_enable() is called
when the transmit of the ACK has completed, then
pch_gbe_irq_enable() will enable the interrupts of
the switch, followed by a read of the INT_ST which
results in clearing the status bits.

While the device would still issue an interrupt,
the pch_gbe_intr() handler would not see any pending
requests as the status register had been cleared.
Thus, the packet remains "stuck".

Signed-off-by: Tom Walsh <tomwalsh73@gmail.com>

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 3cd87a4..baba31d 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -809,13 +809,16 @@ static void pch_gbe_irq_disable(struct
pch_gbe_adapter *adapter)
  * pch_gbe_irq_enable - Enable default interrupt generation settings
  * @adapter:  Board private structure
  */
-static void pch_gbe_irq_enable(struct pch_gbe_adapter *adapter)
+static void pch_gbe_irq_enable(struct pch_gbe_adapter *adapter,
+       bool reset_status_register)
 {
  struct pch_gbe_hw *hw = &adapter->hw;

- if (likely(atomic_dec_and_test(&adapter->irq_sem)))
+ if (likely(atomic_dec_and_test(&adapter->irq_sem))) {
  iowrite32(PCH_GBE_INT_ENABLE_MASK, &hw->reg->INT_EN);
- ioread32(&hw->reg->INT_ST);
+ if (reset_status_register)
+ ioread32(&hw->reg->INT_ST);
+ }
  netdev_dbg(adapter->netdev, "INT_EN reg : 0x%08x\n",
    ioread32(&hw->reg->INT_EN));
 }
@@ -1976,7 +1979,7 @@ int pch_gbe_up(struct pch_gbe_adapter *adapter)
  mod_timer(&adapter->watchdog_timer, jiffies);

  napi_enable(&adapter->napi);
- pch_gbe_irq_enable(adapter);
+ pch_gbe_irq_enable(adapter, true);
  netif_start_queue(adapter->netdev);

  return 0;
@@ -2392,7 +2395,7 @@ static int pch_gbe_napi_poll(struct napi_struct
*napi, int budget)

  if (poll_end_flag) {
  napi_complete(napi);
- pch_gbe_irq_enable(adapter);
+ pch_gbe_irq_enable(adapter, false);
  }

  if (adapter->rx_stop_flag) {
