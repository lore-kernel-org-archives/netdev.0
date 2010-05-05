From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 1/6] netdev: octeon_mgmt: Use proper MAC addresses.
Date: Wed,  5 May 2010 16:03:08 -0700
Message-ID: <1273100593-11043-2-git-send-email-ddaney@caviumnetworks.com>
References: <1273100593-11043-1-git-send-email-ddaney@caviumnetworks.com>
Cc: linux-mips@linux-mips.org, David Daney <ddaney@caviumnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:1662 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754563Ab0EEXDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 19:03:49 -0400
In-Reply-To: <1273100593-11043-1-git-send-email-ddaney@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original implementation incorrectly uses netdev->dev_addrs.

Use netdev->uc instead.  Also use netdev_for_each_uc_addr to iterate
over the addresses.  Fix comment.

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 drivers/net/octeon/octeon_mgmt.c |   15 +++++----------
 1 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/net/octeon/octeon_mgmt.c b/drivers/net/octeon/octeon_mgmt.c
index 6b1d443..bbbd737 100644
--- a/drivers/net/octeon/octeon_mgmt.c
+++ b/drivers/net/octeon/octeon_mgmt.c
@@ -475,12 +475,11 @@ static void octeon_mgmt_set_rx_filtering(struct net_device *netdev)
 	unsigned int multicast_mode = 1; /* 1 - Reject all multicast.  */
 	struct octeon_mgmt_cam_state cam_state;
 	struct netdev_hw_addr *ha;
-	struct list_head *pos;
 	int available_cam_entries;
 
 	memset(&cam_state, 0, sizeof(cam_state));
 
-	if ((netdev->flags & IFF_PROMISC) || netdev->dev_addrs.count > 7) {
+	if ((netdev->flags & IFF_PROMISC) || netdev->uc.count > 7) {
 		cam_mode = 0;
 		available_cam_entries = 8;
 	} else {
@@ -488,13 +487,13 @@ static void octeon_mgmt_set_rx_filtering(struct net_device *netdev)
 		 * One CAM entry for the primary address, leaves seven
 		 * for the secondary addresses.
 		 */
-		available_cam_entries = 7 - netdev->dev_addrs.count;
+		available_cam_entries = 7 - netdev->uc.count;
 	}
 
 	if (netdev->flags & IFF_MULTICAST) {
 		if (cam_mode == 0 || (netdev->flags & IFF_ALLMULTI) ||
 		    netdev_mc_count(netdev) > available_cam_entries)
-			multicast_mode = 2; /* 1 - Accept all multicast.  */
+			multicast_mode = 2; /* 2 - Accept all multicast.  */
 		else
 			multicast_mode = 0; /* 0 - Use CAM.  */
 	}
@@ -502,12 +501,8 @@ static void octeon_mgmt_set_rx_filtering(struct net_device *netdev)
 	if (cam_mode == 1) {
 		/* Add primary address. */
 		octeon_mgmt_cam_state_add(&cam_state, netdev->dev_addr);
-		list_for_each(pos, &netdev->dev_addrs.list) {
-			struct netdev_hw_addr *hw_addr;
-			hw_addr = list_entry(pos, struct netdev_hw_addr, list);
-			octeon_mgmt_cam_state_add(&cam_state, hw_addr->addr);
-			list = list->next;
-		}
+		netdev_for_each_uc_addr(ha, netdev)
+			octeon_mgmt_cam_state_add(&cam_state, ha->addr);
 	}
 	if (multicast_mode == 0) {
 		netdev_for_each_mc_addr(ha, netdev)
-- 
1.6.6.1

