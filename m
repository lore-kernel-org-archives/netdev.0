From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] ixgbe: fix possible null buffer error
Date: Tue, 20 Sep 2011 18:13:03 -0700
Message-ID: <1316567583-28673-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	stable@kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:45168 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750711Ab1IUBNG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Sep 2011 21:13:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

It seems that at least one PPC machine would occasionally give a (valid) 0 as
the return value from dma_map, this caused the ixgbe code to not work
correctly.  A fix is pending in the PPC tree to not return 0 from dma map, but
we can also fix the driver to make sure we don't mess up in other arches as
well.

This patch is applicable to all current stable kernels.

Ref: https://bugzilla.redhat.com/show_bug.cgi?id=683611

Reported-by: Neil Horman <nhorman@redhat.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
CC: stable@kernel.org
Tested-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 2279039..e1fcc95 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1321,8 +1321,8 @@ static void ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		if (ring_is_rsc_enabled(rx_ring))
 			pkt_is_rsc = ixgbe_get_rsc_state(rx_desc);
 
-		/* if this is a skb from previous receive DMA will be 0 */
-		if (rx_buffer_info->dma) {
+		/* linear means we are building an skb from multiple pages */
+		if (!skb_is_nonlinear(skb)) {
 			u16 hlen;
 			if (pkt_is_rsc &&
 			    !(staterr & IXGBE_RXD_STAT_EOP) &&
-- 
1.7.6.2
