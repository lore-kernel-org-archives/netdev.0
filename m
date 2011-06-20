From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/17] ixgbe: setup redirection table for multiple packet buffers
Date: Sun, 19 Jun 2011 17:58:33 -0700
Message-ID: <1308531518-17298-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1308531518-17298-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:13160 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751888Ab1FTA7E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jun 2011 20:59:04 -0400
In-Reply-To: <1308531518-17298-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
index f829d36..e81dc85 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2939,6 +2939,10 @@ static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 	u32 rxcsum;
 	int i, j;
 	u8 tcs = netdev_get_num_tc(adapter->netdev);
+	int maxq = adapter->ring_feature[RING_F_RSS].indices;
+
+	if (tcs)
+		maxq = min(maxq, adapter->num_tx_queues / tcs);
 
 	/* Fill out hash function seeds */
 	for (i = 0; i < 10; i++)
@@ -2946,7 +2950,7 @@ static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 
 	/* Fill out redirection table */
 	for (i = 0, j = 0; i < 128; i++, j++) {
-		if (j == adapter->ring_feature[RING_F_RSS].indices)
+		if (j == maxq)
 			j = 0;
 		/* reta = 4-byte sliding window of
 		 * 0x00..(indices-1)(indices-1)00..etc. */
-- 
1.7.5.4

