From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/4] ixgbe: handle parameters for tx and rx EITR,
	no div0
Date: Tue, 24 Nov 2009 20:51:06 -0800
Message-ID: <20091125045059.23932.10997.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:58702
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934503AbZKYEvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 23:51:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The driver was doing a divide by zero when adjusting tx-usecs.
This patch removes the divide by zero code and changes the logic slightly
to ignore tx-usecs in the case of shared TxRx vectors.

Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 84ab4db..a5ca289 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1972,6 +1972,10 @@ static int ixgbe_get_coalesce(struct net_device *netdev,
 		break;
 	}
 
+	/* if in mixed tx/rx queues per vector mode, report only rx settings */
+	if (adapter->q_vector[0]->txr_count && adapter->q_vector[0]->rxr_count)
+		return 0;
+
 	/* only valid if in constant ITR mode */
 	switch (adapter->tx_itr_setting) {
 	case 0:
@@ -1997,12 +2001,9 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 	struct ixgbe_q_vector *q_vector;
 	int i;
 
-	/*
-	 * don't accept tx specific changes if we've got mixed RxTx vectors
-	 * test and jump out here if needed before changing the rx numbers
-	 */
-	if ((1000000/ec->tx_coalesce_usecs) != adapter->tx_eitr_param &&
-	    adapter->q_vector[0]->txr_count && adapter->q_vector[0]->rxr_count)
+	/* don't accept tx specific changes if we've got mixed RxTx vectors */
+	if (adapter->q_vector[0]->txr_count && adapter->q_vector[0]->rxr_count
+	   && ec->tx_coalesce_usecs)
 		return -EINVAL;
 
 	if (ec->tx_max_coalesced_frames_irq)

