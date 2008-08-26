From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 01/13] ixgbe: fix rx csum return status
	misinterpretation
Date: Tue, 26 Aug 2008 04:26:56 -0700
Message-ID: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:37405 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751686AbYHZL05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 07:26:57 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2099738rvb.1
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 04:26:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

the driver was misinterpreting rx_csum return value in the descriptor
so occassionally we would indicate an rx_csum error in our stats
when there was none.  This would have no effect on traffic because
we would just hand the packet to the stack anyway without the offload
flag set, but would increase CPU for those packets that needed a recompute.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 53f41b6..b14192f 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -420,14 +420,12 @@ static void ixgbe_receive_skb(struct ixgbe_adapter *adapter,
  * @skb: skb currently being received and modified
  **/
 static inline void ixgbe_rx_checksum(struct ixgbe_adapter *adapter,
-					 u32 status_err,
-					 struct sk_buff *skb)
+                                     u32 status_err, struct sk_buff *skb)
 {
 	skb->ip_summed = CHECKSUM_NONE;
 
-	/* Ignore Checksum bit is set, or rx csum disabled */
-	if ((status_err & IXGBE_RXD_STAT_IXSM) ||
-	    !(adapter->flags & IXGBE_FLAG_RX_CSUM_ENABLED))
+	/* Rx csum disabled */
+	if (!(adapter->flags & IXGBE_FLAG_RX_CSUM_ENABLED))
 		return;
 
 	/* if IP and error */

