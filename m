From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/10] igb: use igb_adapter->io_addr instead of e1000_hw->hw_addr
Date: Fri,  6 Jan 2017 02:48:47 -0800
Message-ID: <20170106104852.10363-6-jeffrey.t.kirsher@intel.com>
References: <20170106104852.10363-1-jeffrey.t.kirsher@intel.com>
Cc: Cao jin <caoj.fnst@cn.fujitsu.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:26908 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965548AbdAFKtY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 05:49:24 -0500
In-Reply-To: <20170106104852.10363-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cao jin <caoj.fnst@cn.fujitsu.com>

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

A similar issue & solution could be found at:
    http://patchwork.ozlabs.org/patch/689592/

Signed-off-by: Cao jin <caoj.fnst@cn.fujitsu.com>
Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index a761001..1e4bd84 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3394,7 +3394,7 @@ void igb_configure_tx_ring(struct igb_adapter *adapter,
 	     tdba & 0x00000000ffffffffULL);
 	wr32(E1000_TDBAH(reg_idx), tdba >> 32);
 
-	ring->tail = hw->hw_addr + E1000_TDT(reg_idx);
+	ring->tail = adapter->io_addr + E1000_TDT(reg_idx);
 	wr32(E1000_TDH(reg_idx), 0);
 	writel(0, ring->tail);
 
@@ -3733,7 +3733,7 @@ void igb_configure_rx_ring(struct igb_adapter *adapter,
 	     ring->count * sizeof(union e1000_adv_rx_desc));
 
 	/* initialize head and tail */
-	ring->tail = hw->hw_addr + E1000_RDT(reg_idx);
+	ring->tail = adapter->io_addr + E1000_RDT(reg_idx);
 	wr32(E1000_RDH(reg_idx), 0);
 	writel(0, ring->tail);
 
-- 
2.9.3
