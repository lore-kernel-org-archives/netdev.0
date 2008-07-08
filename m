From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 08/25] ixgb: fix race on rx_buffer_len in mtu change
Date: Tue, 08 Jul 2008 15:51:42 -0700
Message-ID: <20080708225142.6925.9117.stgit@localhost.localdomain>
References: <20080708224858.6925.29725.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34581 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753620AbYGHWvn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:51:43 -0400
In-Reply-To: <20080708224858.6925.29725.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

some random coverage testing found that when changing mtu
under heavy traffic load, NAPI would use the rx_buffer_len variable
after it had been changed by change_mtu.

Similar to e1000 bugs found long ago.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 4bf6bbc..c3234c4 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1573,14 +1573,18 @@ ixgb_change_mtu(struct net_device *netdev, int new_mtu)
 		return -EINVAL;
 	}
 
+	if (old_max_frame == max_frame)
+		return 0;
+
+	if (netif_running(netdev))
+		ixgb_down(adapter, true);
+
 	adapter->rx_buffer_len = max_frame + 8; /* + 8 for errata */
 
 	netdev->mtu = new_mtu;
 
-	if ((old_max_frame != max_frame) && netif_running(netdev)) {
-		ixgb_down(adapter, true);
+	if (netif_running(netdev))
 		ixgb_up(adapter);
-	}
 
 	return 0;
 }

