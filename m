From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/10] ixgbe: remove unneeded fdir pb alloc case
Date: Mon, 29 Aug 2011 01:41:02 -0700
Message-ID: <1314607268-26958-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1314607268-26958-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:36890 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753230Ab1H2IlP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Aug 2011 04:41:15 -0400
In-Reply-To: <1314607268-26958-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

The packet buffer is correctly allocated by generic pb allocation
path in ixgbe_configure() there is no need to do the allocation
here as well.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c |   87 ------------------------
 1 files changed, 0 insertions(+), 87 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index 34f30ec..f193fc2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -1108,79 +1108,6 @@ s32 ixgbe_reinit_fdir_tables_82599(struct ixgbe_hw *hw)
 }
 
 /**
- *  ixgbe_set_fdir_rxpba_82599 - Initialize Flow Director Rx packet buffer
- *  @hw: pointer to hardware structure
- *  @pballoc: which mode to allocate filters with
- **/
-static s32 ixgbe_set_fdir_rxpba_82599(struct ixgbe_hw *hw, const u32 pballoc)
-{
-	u32 fdir_pbsize = hw->mac.rx_pb_size << IXGBE_RXPBSIZE_SHIFT;
-	u32 current_rxpbsize = 0;
-	int i;
-
-	/* reserve space for Flow Director filters */
-	switch (pballoc) {
-	case IXGBE_FDIR_PBALLOC_256K:
-		fdir_pbsize -= 256 << IXGBE_RXPBSIZE_SHIFT;
-		break;
-	case IXGBE_FDIR_PBALLOC_128K:
-		fdir_pbsize -= 128 << IXGBE_RXPBSIZE_SHIFT;
-		break;
-	case IXGBE_FDIR_PBALLOC_64K:
-		fdir_pbsize -= 64 << IXGBE_RXPBSIZE_SHIFT;
-		break;
-	case IXGBE_FDIR_PBALLOC_NONE:
-	default:
-		return IXGBE_ERR_PARAM;
-	}
-
-	/* determine current RX packet buffer size */
-	for (i = 0; i < 8; i++)
-		current_rxpbsize += IXGBE_READ_REG(hw, IXGBE_RXPBSIZE(i));
-
-	/* if there is already room for the filters do nothing */
-	if (current_rxpbsize <= fdir_pbsize)
-		return 0;
-
-	if (current_rxpbsize > hw->mac.rx_pb_size) {
-		/*
-		 * if rxpbsize is greater than max then HW max the Rx buffer
-		 * sizes are unconfigured or misconfigured since HW default is
-		 * to give the full buffer to each traffic class resulting in
-		 * the total size being buffer size 8x actual size
-		 *
-		 * This assumes no DCB since the RXPBSIZE registers appear to
-		 * be unconfigured.
-		 */
-		IXGBE_WRITE_REG(hw, IXGBE_RXPBSIZE(0), fdir_pbsize);
-		for (i = 1; i < 8; i++)
-			IXGBE_WRITE_REG(hw, IXGBE_RXPBSIZE(i), 0);
-	} else {
-		/*
-		 * Since the Rx packet buffer appears to have already been
-		 * configured we need to shrink each packet buffer by enough
-		 * to make room for the filters.  As such we take each rxpbsize
-		 * value and multiply it by a fraction representing the size
-		 * needed over the size we currently have.
-		 *
-		 * We need to reduce fdir_pbsize and current_rxpbsize to
-		 * 1/1024 of their original values in order to avoid
-		 * overflowing the u32 being used to store rxpbsize.
-		 */
-		fdir_pbsize >>= IXGBE_RXPBSIZE_SHIFT;
-		current_rxpbsize >>= IXGBE_RXPBSIZE_SHIFT;
-		for (i = 0; i < 8; i++) {
-			u32 rxpbsize = IXGBE_READ_REG(hw, IXGBE_RXPBSIZE(i));
-			rxpbsize *= fdir_pbsize;
-			rxpbsize /= current_rxpbsize;
-			IXGBE_WRITE_REG(hw, IXGBE_RXPBSIZE(i), rxpbsize);
-		}
-	}
-
-	return 0;
-}
-
-/**
  *  ixgbe_fdir_enable_82599 - Initialize Flow Director control registers
  *  @hw: pointer to hardware structure
  *  @fdirctrl: value to write to flow director control register
@@ -1227,13 +1154,6 @@ static void ixgbe_fdir_enable_82599(struct ixgbe_hw *hw, u32 fdirctrl)
  **/
 s32 ixgbe_init_fdir_signature_82599(struct ixgbe_hw *hw, u32 fdirctrl)
 {
-	s32 err;
-
-	/* Before enabling Flow Director, verify the Rx Packet Buffer size */
-	err = ixgbe_set_fdir_rxpba_82599(hw, fdirctrl);
-	if (err)
-		return err;
-
 	/*
 	 * Continue setup of fdirctrl register bits:
 	 *  Move the flexible bytes to use the ethertype - shift 6 words
@@ -1258,13 +1178,6 @@ s32 ixgbe_init_fdir_signature_82599(struct ixgbe_hw *hw, u32 fdirctrl)
  **/
 s32 ixgbe_init_fdir_perfect_82599(struct ixgbe_hw *hw, u32 fdirctrl)
 {
-	s32 err;
-
-	/* Before enabling Flow Director, verify the Rx Packet Buffer size */
-	err = ixgbe_set_fdir_rxpba_82599(hw, fdirctrl);
-	if (err)
-		return err;
-
 	/*
 	 * Continue setup of fdirctrl register bits:
 	 *  Turn perfect match filtering on
-- 
1.7.6
