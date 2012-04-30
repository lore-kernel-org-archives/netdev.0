From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/3] ixgbe: fix calling skb_put on nonlinear skb assertion bug
Date: Mon, 30 Apr 2012 16:16:34 -0700
Message-ID: <1335827794-26992-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1335827794-26992-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yi Zou <yi.zou@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24865 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756884Ab2D3XQh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2012 19:16:37 -0400
In-Reply-To: <1335827794-26992-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

With the support to bounce buffer added, the skb is coming as nonlinear in the
case of non-DDPed data frames for FCoE, which is mostly ok as the FCoE stack
would take care of that. However, for target mode, we have to set the FC CRC
and FC EOF field to allow the protocol stack to not drop the frame for the last
data frame of that sequence. So fix this by linearizing the skb first before
doing skb_put().

Signed-off-by: Yi Zou <yi.zou@intel.com>
Tested-by: Marcus Dennis <marcusx.e.dennis@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
index 77ea4b7..bc07933 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -437,6 +437,7 @@ int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
 	 */
 	if ((fh->fh_r_ctl == FC_RCTL_DD_SOL_DATA) &&
 	    (fctl & FC_FC_END_SEQ)) {
+		skb_linearize(skb);
 		crc = (struct fcoe_crc_eof *)skb_put(skb, sizeof(*crc));
 		crc->fcoe_eof = FC_EOF_T;
 	}
-- 
1.7.7.6
