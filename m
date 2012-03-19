From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/10] ixgbe: cleanup logic for the service timer and VF hang detection
Date: Mon, 19 Mar 2012 14:22:31 -0700
Message-ID: <1332192158-14771-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1332192158-14771-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:11090 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755406Ab2CSVWm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2012 17:22:42 -0400
In-Reply-To: <1332192158-14771-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change just cleans up some of the logic in the service_timer function
so that we can avoid unnecessary swapping of the ready value between true to
false and back to true.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   29 ++++++++----------------
 1 files changed, 10 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 7817f04..6453e3a5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6480,41 +6480,32 @@ static void ixgbe_service_timer(unsigned long data)
 	unsigned long next_event_offset;
 	bool ready = true;
 
-#ifdef CONFIG_PCI_IOV
-	ready = false;
+	/* poll faster when waiting for link */
+	if (adapter->flags & IXGBE_FLAG_NEED_LINK_UPDATE)
+		next_event_offset = HZ / 10;
+	else
+		next_event_offset = HZ * 2;
 
+#ifdef CONFIG_PCI_IOV
 	/*
 	 * don't bother with SR-IOV VF DMA hang check if there are
 	 * no VFs or the link is down
 	 */
 	if (!adapter->num_vfs ||
-	    (adapter->flags & IXGBE_FLAG_NEED_LINK_UPDATE)) {
-		ready = true;
+	    (adapter->flags & IXGBE_FLAG_NEED_LINK_UPDATE))
 		goto normal_timer_service;
-	}
 
 	/* If we have VFs allocated then we must check for DMA hangs */
 	ixgbe_check_for_bad_vf(adapter);
 	next_event_offset = HZ / 50;
 	adapter->timer_event_accumulator++;
 
-	if (adapter->timer_event_accumulator >= 100) {
-		ready = true;
+	if (adapter->timer_event_accumulator >= 100)
 		adapter->timer_event_accumulator = 0;
-	}
-
-	goto schedule_event;
-
-normal_timer_service:
-#endif
-	/* poll faster when waiting for link */
-	if (adapter->flags & IXGBE_FLAG_NEED_LINK_UPDATE)
-		next_event_offset = HZ / 10;
 	else
-		next_event_offset = HZ * 2;
+		ready = false;
 
-#ifdef CONFIG_PCI_IOV
-schedule_event:
+normal_timer_service:
 #endif
 	/* Reset the timer */
 	mod_timer(&adapter->service_timer, next_event_offset + jiffies);
-- 
1.7.7.6
