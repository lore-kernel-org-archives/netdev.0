From: Cao jin <caoj.fnst@cn.fujitsu.com>
Subject: [PATCH] igb: use igb_adapter->io_addr instead of e1000_hw->hw_addr
Date: Tue, 8 Nov 2016 15:06:20 +0800
Message-ID: <1478588780-24480-1-git-send-email-caoj.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <intel-wired-lan@lists.osuosl.org>, <alexander.duyck@gmail.com>,
        <izumi.taku@jp.fujitsu.com>, <jeffrey.t.kirsher@intel.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:53722 "EHLO
        heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751453AbcKHHDq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 02:03:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When running as guest, under certain condition, it will oops as following.
writel() in igb_configure_tx_ring() results in oops, because hw->hw_addr
is NULL. While other register access won't oops kernel because they use
wr32/rd32 which have a defense against NULL pointer.

    [  141.225449] pcieport 0000:00:1c.0: AER: Multiple Uncorrected (Fatal)
    error received: id=0101
    [  141.225523] igb 0000:01:00.1: PCIe Bus Error:
    severity=Uncorrected (Fatal), type=Unaccessible,
    id=0101(Unregistered Agent ID)
    [  141.299442] igb 0000:01:00.1: broadcast error_detected message
    [  141.300539] igb 0000:01:00.0 enp1s0f0: PCIe link lost, device now
    detached
    [  141.351019] igb 0000:01:00.1 enp1s0f1: PCIe link lost, device now
    detached
    [  143.465904] pcieport 0000:00:1c.0: Root Port link has been reset
    [  143.465994] igb 0000:01:00.1: broadcast slot_reset message
    [  143.466039] igb 0000:01:00.0: enabling device (0000 -> 0002)
    [  144.389078] igb 0000:01:00.1: enabling device (0000 -> 0002)
    [  145.312078] igb 0000:01:00.1: broadcast resume message
    [  145.322211] BUG: unable to handle kernel paging request at
    0000000000003818
    [  145.361275] IP: [<ffffffffa02fd38d>]
    igb_configure_tx_ring+0x14d/0x280 [igb]
    [  145.400048] PGD 0
    [  145.438007] Oops: 0002 [#1] SMP

A similiar issue & solution could be found at:
    http://patchwork.ozlabs.org/patch/689592/

Signed-off-by: Cao jin <caoj.fnst@cn.fujitsu.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index edc9a6a..3f240ac 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3390,7 +3390,7 @@ void igb_configure_tx_ring(struct igb_adapter *adapter,
 	     tdba & 0x00000000ffffffffULL);
 	wr32(E1000_TDBAH(reg_idx), tdba >> 32);
 
-	ring->tail = hw->hw_addr + E1000_TDT(reg_idx);
+	ring->tail = adapter->io_addr + E1000_TDT(reg_idx);
 	wr32(E1000_TDH(reg_idx), 0);
 	writel(0, ring->tail);
 
@@ -3729,7 +3729,7 @@ void igb_configure_rx_ring(struct igb_adapter *adapter,
 	     ring->count * sizeof(union e1000_adv_rx_desc));
 
 	/* initialize head and tail */
-	ring->tail = hw->hw_addr + E1000_RDT(reg_idx);
+	ring->tail = adapter->io_addr + E1000_RDT(reg_idx);
 	wr32(E1000_RDH(reg_idx), 0);
 	writel(0, ring->tail);
 
-- 
2.1.0
