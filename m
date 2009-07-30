From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 3/3] ixgbe: Fix RSC completion delay causing Rx
	interrupts to stop
Date: Thu, 30 Jul 2009 15:26:00 -0700
Message-ID: <20090730222559.26121.13496.stgit@localhost.localdomain>
References: <20090730222501.26121.2952.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:56062 "EHLO
	QMTA08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752551AbZG3W0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 18:26:16 -0400
In-Reply-To: <20090730222501.26121.2952.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

When a user disables interrupt throttling with ethtool on 82599 devices,
the interrupt timer may not be re-enabled if hardware RSC is running.  The
RSC completions in hardware don't complete before the next ITR event tries
to fire, so the ITR timer never gets re-armed.  This patch increases the
amount of time between interrupts when throttling is disabled (rx-usecs =
0) when the hardware RSC deature is enabled.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |    2 ++
 drivers/net/ixgbe/ixgbe_ethtool.c |    5 ++++-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 1b12c7b..e11d83d 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -96,6 +96,8 @@
 #define IXGBE_TX_FLAGS_VLAN_PRIO_MASK   0x0000e000
 #define IXGBE_TX_FLAGS_VLAN_SHIFT	16
 
+#define IXGBE_MAX_RSC_INT_RATE          162760
+
 /* wrapper around a pointer to a socket buffer,
  * so a DMA handle can be stored along with the buffer */
 struct ixgbe_tx_buffer {
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 7ddb50c..79144e9 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1975,7 +1975,10 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 		 * any other value means disable eitr, which is best
 		 * served by setting the interrupt rate very high
 		 */
-		adapter->eitr_param = IXGBE_MAX_INT_RATE;
+		if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)
+			adapter->eitr_param = IXGBE_MAX_RSC_INT_RATE;
+		else
+			adapter->eitr_param = IXGBE_MAX_INT_RATE;
 		adapter->itr_setting = 0;
 	}
 

