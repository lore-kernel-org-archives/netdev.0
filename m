From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 7/8] ixgbe: dcb: up2tc mapping lost on disable/enable CEE DCB state
Date: Thu,  9 Feb 2012 01:34:20 -0800
Message-ID: <1328780061-25000-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328780061-25000-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:13994 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757584Ab2BIJe2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Feb 2012 04:34:28 -0500
In-Reply-To: <1328780061-25000-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Users expect the up2tc mapping to be maintained across a DCB
enable/disable/enable transition. And since we maintain all
the other DCB attributes we should do this for up2tc mappings
as well just to be consistent. Also without this we break
user space applications that expect this to occur that
previously worked.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
index 005e5f2..79a92fe 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
@@ -112,6 +112,8 @@ static u8 ixgbe_dcbnl_get_state(struct net_device *netdev)
 static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 {
 	u8 err = 0;
+	u8 prio_tc[MAX_USER_PRIORITY] = {0};
+	int i;
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
 	/* Fail command if not in CEE mode */
@@ -122,10 +124,15 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 	if (!!state != !(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
 		return err;
 
-	if (state > 0)
+	if (state > 0) {
 		err = ixgbe_setup_tc(netdev, adapter->dcb_cfg.num_tcs.pg_tcs);
-	else
+		ixgbe_dcb_unpack_map(&adapter->dcb_cfg, DCB_TX_CONFIG, prio_tc);
+	} else {
 		err = ixgbe_setup_tc(netdev, 0);
+	}
+
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++)
+		netdev_set_prio_tc_map(netdev, i, prio_tc[i]);
 
 	return err;
 }
-- 
1.7.7.6
