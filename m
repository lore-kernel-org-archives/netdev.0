From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] ixgbe: Fix output from ixgbe_dump
Date: Tue, 18 Apr 2017 16:02:05 -0700
Message-ID: <20170418230205.37223-16-jeffrey.t.kirsher@intel.com>
References: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:58032 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757972AbdDRXCU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 19:02:20 -0400
In-Reply-To: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

I just found that when we had changed the Rx path to check for length
instead of the DD bit we introduced an issue in ixgbe_dump since we were no
longer clearing the status bits.

To correct this I am updating ixgbe_dump to look for the length bits in the
descriptor since that is what we are using in the Rx path.

Fixes: c3630cc40b4f ("ixgbe: Use length to determine if descriptor is done")
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 536dd9b1ad97..afff2ca7f8c0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -606,7 +606,6 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 	struct ixgbe_ring *rx_ring;
 	union ixgbe_adv_rx_desc *rx_desc;
 	struct ixgbe_rx_buffer *rx_buffer_info;
-	u32 staterr;
 	int i = 0;
 
 	if (!netif_msg_hw(adapter))
@@ -827,8 +826,7 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 			rx_buffer_info = &rx_ring->rx_buffer_info[i];
 			rx_desc = IXGBE_RX_DESC(rx_ring, i);
 			u0 = (struct my_u0 *)rx_desc;
-			staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
-			if (staterr & IXGBE_RXD_STAT_DD) {
+			if (rx_desc->wb.upper.length) {
 				/* Descriptor Done */
 				pr_info("RWB[0x%03X]     %016llX %016llX ---------------- %p%s\n",
 					i,
-- 
2.12.2
