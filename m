From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 2/2] ixgbe: only allow WOL for 82599 KX4 NIC
Date: Wed, 08 Apr 2009 16:20:50 -0700
Message-ID: <20090408232050.8781.68279.stgit@localhost.localdomain>
References: <20090408232031.8781.83459.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:60626
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757230AbZDIHtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 03:49:17 -0400
In-Reply-To: <20090408232031.8781.83459.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

All NICs were reporting WOL support when only the KX4 NIC is capable of
supporting WOL.  This patch adds a function to check for and exclude all
non-WOL capable nics from enabling WOL in ethtool.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |   24 +++++++++++++++++++++++-
 1 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index aafc120..f0a20fa 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -943,6 +943,24 @@ static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
 }
 
 
+static int ixgbe_wol_exclusion(struct ixgbe_adapter *adapter,
+                               struct ethtool_wolinfo *wol)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	int retval = 1;
+
+	switch(hw->device_id) {
+	case IXGBE_DEV_ID_82599_KX4:
+		retval = 0;
+		break;
+	default:
+		wol->supported = 0;
+		retval = 0;
+	}
+
+	return retval;
+}
+
 static void ixgbe_get_wol(struct net_device *netdev,
                           struct ethtool_wolinfo *wol)
 {
@@ -952,7 +970,8 @@ static void ixgbe_get_wol(struct net_device *netdev,
 	                 WAKE_BCAST | WAKE_MAGIC;
 	wol->wolopts = 0;
 
-	if (!device_can_wakeup(&adapter->pdev->dev))
+	if (ixgbe_wol_exclusion(adapter, wol) ||
+	    !device_can_wakeup(&adapter->pdev->dev))
 		return;
 
 	if (adapter->wol & IXGBE_WUFC_EX)
@@ -974,6 +993,9 @@ static int ixgbe_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 	if (wol->wolopts & (WAKE_PHY | WAKE_ARP | WAKE_MAGICSECURE))
 		return -EOPNOTSUPP;
 
+	if (ixgbe_wol_exclusion(adapter, wol))
+		return wol->wolopts ? -EOPNOTSUPP : 0;
+
 	adapter->wol = 0;
 
 	if (wol->wolopts & WAKE_UCAST)

