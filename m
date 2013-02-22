From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH net-next] vmxnet3: fix ethtool ring buffer size setting
Date: Fri, 22 Feb 2013 15:32:24 -0500
Message-ID: <1361565144-18301-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50075 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808Ab3BVUcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 15:32:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noticed that vmxnet3's get_ringparam function was returning the summation of all
ring buffers on a NIC, rather than just the size of any one ring.  This causes
problems when a vmxnet3 instance has multiple queues, as ethtool, when setting
ring parameters, first gets the current ring parameters to set the existing
values in the set_ringparm commannd.  The result is, that unless both rx and tx
ring sizes are set in a single operation, which ever ring is not set will
silently have its ring count multiplied by the number of queues on the NIC until
it reaches a driver defined maxiumum value.

Fix it by not multiplying the rx and tx ring sizes by the number of queues in
the system, like every other driver.  Tested by myself successfully.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Shreyas Bhatewara <sbhatewara@vmware.com>
CC: "VMware, Inc." <pv-drivers@vmware.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/vmxnet3/vmxnet3_ethtool.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index 9bc542b..a0feb17 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -448,10 +448,8 @@ vmxnet3_get_ringparam(struct net_device *netdev,
 	param->rx_mini_max_pending = 0;
 	param->rx_jumbo_max_pending = 0;
 
-	param->rx_pending = adapter->rx_queue[0].rx_ring[0].size *
-			    adapter->num_rx_queues;
-	param->tx_pending = adapter->tx_queue[0].tx_ring.size *
-			    adapter->num_tx_queues;
+	param->rx_pending = adapter->rx_queue[0].rx_ring[0].size;
+	param->tx_pending = adapter->tx_queue[0].tx_ring.size;
 	param->rx_mini_pending = 0;
 	param->rx_jumbo_pending = 0;
 }
-- 
1.7.11.7
