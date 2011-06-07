From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 17/40] ixgbe: setup redirection table for multiple packet buffers
Date: Tue,  7 Jun 2011 05:32:52 -0700
Message-ID: <1307449995-9458-18-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:54890 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753286Ab1FGMdZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 08:33:25 -0400
In-Reply-To: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Setup RSS redirection table to be compatible with multiple packet
buffers. Currently, this works on 82599 devices because the RSS
redirection index is masked by the number of queues per packet
buffer.

This sets the cap on the RSS table to maxq.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 111c3f9..2634c67 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2938,6 +2938,10 @@ static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 	u32 rxcsum;
 	int i, j;
 	u8 tcs = netdev_get_num_tc(adapter->netdev);
+	int maxq = adapter->ring_feature[RING_F_RSS].indices;
+
+	if (tcs)
+		maxq = min(maxq, adapter->num_tx_queues / tcs);
 
 	/* Fill out hash function seeds */
 	for (i = 0; i < 10; i++)
@@ -2945,7 +2949,7 @@ static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 
 	/* Fill out redirection table */
 	for (i = 0, j = 0; i < 128; i++, j++) {
-		if (j == adapter->ring_feature[RING_F_RSS].indices)
+		if (j == maxq)
 			j = 0;
 		/* reta = 4-byte sliding window of
 		 * 0x00..(indices-1)(indices-1)00..etc. */
-- 
1.7.5.2

