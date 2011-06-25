From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/9] ixgbe: remove unused fcoe.tc field and fcoe_setapp()
Date: Sat, 25 Jun 2011 00:22:25 -0700
Message-ID: <1308986546-12964-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1308986546-12964-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28761 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751514Ab1FYHWb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 03:22:31 -0400
In-Reply-To: <1308986546-12964-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

The fcoe.tc field is no longer used so remove it. After
the field is removed there is no need to keep fcoe_setapp()
around so remove it as well. And finally we can get rid
of some DCB #ifdef's in the fcoe code.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_dcb_nl.c |    2 +-
 drivers/net/ixgbe/ixgbe_fcoe.c   |   54 --------------------------------------
 drivers/net/ixgbe/ixgbe_fcoe.h   |    1 -
 drivers/net/ixgbe/ixgbe_main.c   |    1 -
 4 files changed, 1 insertions(+), 57 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index db659df..1a13765 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -357,7 +357,7 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 		while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
 			usleep_range(1000, 2000);
 
-		ixgbe_fcoe_setapp(adapter, up);
+		adapter->fcoe.up = ffs(up) - 1;
 
 		if (netif_running(netdev))
 			netdev->netdev_ops->ndo_stop(netdev);
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index 9c20077..f0c1018 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -26,9 +26,6 @@
 *******************************************************************************/
 
 #include "ixgbe.h"
-#ifdef CONFIG_IXGBE_DCB
-#include "ixgbe_dcb_82599.h"
-#endif /* CONFIG_IXGBE_DCB */
 #include <linux/if_ether.h>
 #include <linux/gfp.h>
 #include <linux/if_vlan.h>
@@ -625,10 +622,6 @@ void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct ixgbe_fcoe *fcoe = &adapter->fcoe;
 	struct ixgbe_ring_feature *f = &adapter->ring_feature[RING_F_FCOE];
-#ifdef CONFIG_IXGBE_DCB
-	u8 tc;
-	u32 up2tc;
-#endif
 
 	if (!fcoe->pool) {
 		spin_lock_init(&fcoe->lock);
@@ -694,18 +687,6 @@ void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 			IXGBE_FCRXCTRL_FCOELLI |
 			IXGBE_FCRXCTRL_FCCRCBO |
 			(FC_FCOE_VER << IXGBE_FCRXCTRL_FCOEVER_SHIFT));
-#ifdef CONFIG_IXGBE_DCB
-	up2tc = IXGBE_READ_REG(&adapter->hw, IXGBE_RTTUP2TC);
-	for (i = 0; i < MAX_USER_PRIORITY; i++) {
-		tc = (u8)(up2tc >> (i * IXGBE_RTTUP2TC_UP_SHIFT));
-		tc &= (MAX_TRAFFIC_CLASS - 1);
-		if (fcoe->tc == tc) {
-			fcoe->up = i;
-			break;
-		}
-	}
-#endif
-
 	return;
 
 out_extra_ddp_buffer:
@@ -833,41 +814,6 @@ out_disable:
 	return rc;
 }
 
-#ifdef CONFIG_IXGBE_DCB
-/**
- * ixgbe_fcoe_setapp - sets the user priority bitmap for FCoE
- * @adapter : ixgbe adapter
- * @up : 802.1p user priority bitmap
- *
- * Finds out the traffic class from the input user priority
- * bitmap for FCoE.
- *
- * Returns : 0 on success otherwise returns 1 on error
- */
-u8 ixgbe_fcoe_setapp(struct ixgbe_adapter *adapter, u8 up)
-{
-	int i;
-	u32 up2tc;
-
-	/* valid user priority bitmap must not be 0 */
-	if (up) {
-		/* from user priority to the corresponding traffic class */
-		up2tc = IXGBE_READ_REG(&adapter->hw, IXGBE_RTTUP2TC);
-		for (i = 0; i < MAX_USER_PRIORITY; i++) {
-			if (up & (1 << i)) {
-				up2tc >>= (i * IXGBE_RTTUP2TC_UP_SHIFT);
-				up2tc &= (MAX_TRAFFIC_CLASS - 1);
-				adapter->fcoe.tc = (u8)up2tc;
-				adapter->fcoe.up = i;
-				return 0;
-			}
-		}
-	}
-
-	return 1;
-}
-#endif /* CONFIG_IXGBE_DCB */
-
 /**
  * ixgbe_fcoe_get_wwn - get world wide name for the node or the port
  * @netdev : ixgbe adapter
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.h b/drivers/net/ixgbe/ixgbe_fcoe.h
index d876e7a..99de145 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.h
+++ b/drivers/net/ixgbe/ixgbe_fcoe.h
@@ -74,7 +74,6 @@ struct ixgbe_fcoe {
 	dma_addr_t extra_ddp_buffer_dma;
 	unsigned long mode;
 #ifdef CONFIG_IXGBE_DCB
-	u8 tc;
 	u8 up;
 #endif
 };
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 305e1e4..fa671ae 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5169,7 +5169,6 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		adapter->ring_feature[RING_F_FCOE].indices = 0;
 #ifdef CONFIG_IXGBE_DCB
 		/* Default traffic class to use for FCoE */
-		adapter->fcoe.tc = IXGBE_FCOE_DEFTC;
 		adapter->fcoe.up = IXGBE_FCOE_DEFTC;
 #endif
 #endif /* IXGBE_FCOE */
-- 
1.7.5.4

