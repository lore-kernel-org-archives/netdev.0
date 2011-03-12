From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 08/21] ixgbe: DCB, implement ieee_setapp dcbnl ops
Date: Sat, 12 Mar 2011 04:20:15 -0800
Message-ID: <1299932428-3114-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58767 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754007Ab1CLMVB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 07:21:01 -0500
In-Reply-To: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Implement ieee_setapp dcbnl ops in ixgbe. This is required
to setup FCoE which requires dedicated resources. If the
app data is not for FCoE then no action is taken in ixgbe
except to add it to the dcb_app_list.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_dcb_nl.c |   30 ++++++++++++++++++++++++++++++
 1 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index d7c456f..8d139f7 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -709,6 +709,35 @@ static int ixgbe_dcbnl_ieee_setpfc(struct net_device *dev,
 	return err;
 }
 
+static int ixgbe_dcbnl_ieee_setapp(struct net_device *dev,
+				   struct dcb_app *app)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+
+	if (!(adapter->dcbx_cap & DCB_CAP_DCBX_VER_IEEE))
+		return -EINVAL;
+#ifdef IXGBE_FCOE
+	if (app->selector == 1 && app->protocol == ETH_P_FCOE) {
+		if (adapter->fcoe.tc == app->priority)
+			goto setapp;
+
+		/* In IEEE mode map up to tc 1:1 */
+		adapter->fcoe.tc = app->priority;
+		adapter->fcoe.up = app->priority;
+
+		/* Force hardware reset required to push FCoE
+		 * setup on {tx|rx}_rings
+		 */
+		adapter->dcb_set_bitmap |= BIT_APP_UPCHG;
+		ixgbe_dcbnl_set_all(dev);
+	}
+
+setapp:
+#endif
+	dcb_setapp(dev, app);
+	return 0;
+}
+
 static u8 ixgbe_dcbnl_getdcbx(struct net_device *dev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
@@ -759,6 +788,7 @@ const struct dcbnl_rtnl_ops dcbnl_ops = {
 	.ieee_setets	= ixgbe_dcbnl_ieee_setets,
 	.ieee_getpfc	= ixgbe_dcbnl_ieee_getpfc,
 	.ieee_setpfc	= ixgbe_dcbnl_ieee_setpfc,
+	.ieee_setapp	= ixgbe_dcbnl_ieee_setapp,
 	.getstate	= ixgbe_dcbnl_get_state,
 	.setstate	= ixgbe_dcbnl_set_state,
 	.getpermhwaddr	= ixgbe_dcbnl_get_perm_hw_addr,
-- 
1.7.4

