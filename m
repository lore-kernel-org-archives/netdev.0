From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 3/4] e1000: look in the page and not in skb->data for the last byte
Date: Thu, 17 May 2012 05:31:51 -0700
Message-ID: <1337257912-8487-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1337257912-8487-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:56414 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760586Ab2EQMb5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 08:31:57 -0400
In-Reply-To: <1337257912-8487-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

The code seems to want to look at the last byte where the HW puts some
information. Since the skb->data area is never seen by the HW I guess it
does not work as expected. We pass the page address to the HW so I
*think* in order to get to the last byte where the information might be
one should use the page buffer and take a look.
This is of course not more than just compile tested.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index fefbf4d..37b7d1c 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -4066,7 +4066,11 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 		/* errors is only valid for DD + EOP descriptors */
 		if (unlikely((status & E1000_RXD_STAT_EOP) &&
 		    (rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK))) {
-			u8 last_byte = *(skb->data + length - 1);
+			u8 *mapped;
+			u8 last_byte;
+
+			mapped = page_address(buffer_info->page);
+			last_byte = *(mapped + length - 1);
 			if (TBI_ACCEPT(hw, status, rx_desc->errors, length,
 				       last_byte)) {
 				spin_lock_irqsave(&adapter->stats_lock,
-- 
1.7.7.6
