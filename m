From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH] ixgbe: change config srrctl to only program one
	register per VMDq/RSS id
Date: Sat, 30 Aug 2008 00:29:10 -0700
Message-ID: <20080830072910.8019.28627.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:62525 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856AbYH3H3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Aug 2008 03:29:13 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1089271wfd.4
        for <netdev@vger.kernel.org>; Sat, 30 Aug 2008 00:29:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so only one srrctl register is programmed per VMDq id, and if VMDq is not enabled it is one register per RSS queue.  Currently this function is working correctly for the multiqueue RSS and single queue cases, but if any advances features such as VMDq or DCB would have been enabled this function would have caused issues as it was not correct.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   25 +++++++++++++++----------
 1 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 198b9d9..99e0b34 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1417,18 +1417,23 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter, int index)
 	struct ixgbe_ring *rx_ring;
 	u32 srrctl;
 	int queue0;
-	unsigned long *mask, maskval = 1;
-	long shift, len;
-
-	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
-		mask = (unsigned long *) &adapter->ring_feature[RING_F_RSS].mask;
-		len = sizeof(adapter->ring_feature[RING_F_RSS].mask) * 8;
+	unsigned long mask;
+
+	/* program one srrctl register per VMDq index */
+	if (adapter->flags & IXGBE_FLAG_VMDQ_ENABLED) {
+		long shift, len;
+		mask = (unsigned long) adapter->ring_feature[RING_F_RSS].mask;
+		len = sizeof(adapter->ring_feature[RING_F_VMDQ].mask) * 8;
+		shift = find_first_bit(&mask, len);
+		queue0 = index & mask;
+		index = (index & mask) >> shift;
+	/* program one srrctl per RSS queue since RDRXCTL.MVMEN is enabled */
 	} else {
-		mask = &maskval;
-		len = 1;
+		mask = (unsigned long) adapter->ring_feature[RING_F_RSS].mask;
+		queue0 = index & mask;
+		index = index & mask;
 	}
-	shift = find_first_bit(mask, len);
-	queue0 = index << shift;
+
 	rx_ring = &adapter->rx_ring[queue0];
 
 	srrctl = IXGBE_READ_REG(&adapter->hw, IXGBE_SRRCTL(index));

