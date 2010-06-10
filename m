From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-2.6] ixgbe: fix automatic LRO/RSC settings for low
	latency
Date: Thu, 10 Jun 2010 14:12:04 -0400
Message-ID: <20100610181204.GO7497@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stanislaw Gruszka <sgruszka@redhat.com>, stable@kernel.org
To: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51356 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759657Ab0FJSMe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jun 2010 14:12:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch added to 2.6.34:

	commit f8d1dcaf88bddc7f282722ec1fdddbcb06a72f18
	Author: Jesse Brandeburg <jesse.brandeburg@intel.com>
	Date:   Tue Apr 27 01:37:20 2010 +0000

	    ixgbe: enable extremely low latency

introduced a feature where LRO (called RSC on the hardware) was disabled
automatically when setting rx-usecs to 0 via ethtool.  Some might not
like the fact that LRO was disabled automatically, but I'm fine with
that.  What I don't like is that LRO/RSC is automatically enabled when
rx-usecs is set >0 via ethtool.

This would certainly be a problem if the device was used for forwarding
and it was determined that the low latency wasn't needed after the
device was already forwarding.  I played around with saving the state of
LRO in the driver, but it just didn't seem worthwhile and would require
a small change to dev_disable_lro() that I did not like.

This patch simply leaves LRO disabled when setting rx-usecs >0 and
requires that the user enable it again.  An extra informational message
will also now appear in the log so users can understand why LRO isn't
being enabled as they expect.

Inconsistency of LRO setting first noticed by Stanislaw Gruszka.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
CC: Stanislaw Gruszka <sgruszka@redhat.com>
CC: stable@kernel.org

---
 drivers/net/ixgbe/ixgbe_ethtool.c |   37 ++++++++-----------------------------
 1 files changed, 8 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index c50a754..9e672ee 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2077,25 +2077,6 @@ static int ixgbe_get_coalesce(struct net_device *netdev,
 	return 0;
 }
 
-/*
- * this function must be called before setting the new value of
- * rx_itr_setting
- */
-static bool ixgbe_reenable_rsc(struct ixgbe_adapter *adapter,
-                               struct ethtool_coalesce *ec)
-{
-	/* check the old value and enable RSC if necessary */
-	if ((adapter->rx_itr_setting == 0) &&
-	    (adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE)) {
-		adapter->flags2 |= IXGBE_FLAG2_RSC_ENABLED;
-		adapter->netdev->features |= NETIF_F_LRO;
-		DPRINTK(PROBE, INFO, "rx-usecs set to %d, re-enabling RSC\n",
-		        ec->rx_coalesce_usecs);
-		return true;
-	}
-	return false;
-}
-
 static int ixgbe_set_coalesce(struct net_device *netdev,
                               struct ethtool_coalesce *ec)
 {
@@ -2124,9 +2105,6 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 		    (1000000/ec->rx_coalesce_usecs < IXGBE_MIN_INT_RATE))
 			return -EINVAL;
 
-		/* check the old value and enable RSC if necessary */
-		need_reset = ixgbe_reenable_rsc(adapter, ec);
-
 		/* store the value in ints/second */
 		adapter->rx_eitr_param = 1000000/ec->rx_coalesce_usecs;
 
@@ -2135,9 +2113,6 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 		/* clear the lower bit as its used for dynamic state */
 		adapter->rx_itr_setting &= ~1;
 	} else if (ec->rx_coalesce_usecs == 1) {
-		/* check the old value and enable RSC if necessary */
-		need_reset = ixgbe_reenable_rsc(adapter, ec);
-
 		/* 1 means dynamic mode */
 		adapter->rx_eitr_param = 20000;
 		adapter->rx_itr_setting = 1;
@@ -2157,10 +2132,11 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 		 */
 		if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
 			adapter->flags2 &= ~IXGBE_FLAG2_RSC_ENABLED;
-			netdev->features &= ~NETIF_F_LRO;
-			DPRINTK(PROBE, INFO,
-			        "rx-usecs set to 0, disabling RSC\n");
-
+			if (netdev->features & NETIF_F_LRO) {
+				netdev->features &= ~NETIF_F_LRO;
+				DPRINTK(PROBE, INFO, "rx-usecs set to 0, "
+					"disabling LRO/RSC\n");
+			}
 			need_reset = true;
 		}
 	}
@@ -2255,6 +2231,9 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 			}
 		} else if (!adapter->rx_itr_setting) {
 			netdev->features &= ~ETH_FLAG_LRO;
+			if (data & ETH_FLAG_LRO)
+				DPRINTK(PROBE, INFO, "rx-usecs set to 0, "
+					"LRO/RSC cannot be enabled.\n");
 		}
 	}
 
