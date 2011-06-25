From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 9/9] ixgbe: implement DCB ops dcb_ieee_del()
Date: Sat, 25 Jun 2011 00:22:26 -0700
Message-ID: <1308986546-12964-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1308986546-12964-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38346 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751541Ab1FYHWb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 03:22:31 -0400
In-Reply-To: <1308986546-12964-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Implement DCB ops dcb_ieee_del() and set FCoE to the default
priority when no priority exists.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_dcb_nl.c |   48 +++++++++++++++++++++++++++++++++----
 1 files changed, 42 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 1a13765..0ace6ce 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -670,6 +670,22 @@ static int ixgbe_dcbnl_ieee_setpfc(struct net_device *dev,
 	return err;
 }
 
+#ifdef IXGBE_FCOE
+static void ixgbe_dcbnl_devreset(struct net_device *dev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+
+	if (netif_running(dev))
+		dev->netdev_ops->ndo_stop(dev);
+
+	ixgbe_clear_interrupt_scheme(adapter);
+	ixgbe_init_interrupt_scheme(adapter);
+
+	if (netif_running(dev))
+		dev->netdev_ops->ndo_open(dev);
+}
+#endif
+
 static int ixgbe_dcbnl_ieee_setapp(struct net_device *dev,
 				   struct dcb_app *app)
 {
@@ -690,15 +706,34 @@ static int ixgbe_dcbnl_ieee_setapp(struct net_device *dev,
 			return err;
 
 		adapter->fcoe.up = app->priority;
+		ixgbe_dcbnl_devreset(dev);
+	}
+#endif
+	return 0;
+}
+
+static int ixgbe_dcbnl_ieee_delapp(struct net_device *dev,
+				   struct dcb_app *app)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	int err;
+
+	if (!(adapter->dcbx_cap & DCB_CAP_DCBX_VER_IEEE))
+		return -EINVAL;
 
-		if (netif_running(dev))
-			dev->netdev_ops->ndo_stop(dev);
+	err = dcb_ieee_delapp(dev, app);
 
-		ixgbe_clear_interrupt_scheme(adapter);
-		ixgbe_init_interrupt_scheme(adapter);
+#ifdef IXGBE_FCOE
+	if (!err && app->selector == IEEE_8021QAZ_APP_SEL_ETHERTYPE &&
+	    app->protocol == ETH_P_FCOE) {
+		u8 app_mask = dcb_ieee_getapp_mask(dev, app);
+
+		if (app_mask & (1 << adapter->fcoe.up))
+			return err;
 
-		if (netif_running(dev))
-			dev->netdev_ops->ndo_open(dev);
+		adapter->fcoe.up = app_mask ?
+				   ffs(app_mask) - 1 : IXGBE_FCOE_DEFTC;
+		ixgbe_dcbnl_devreset(dev);
 	}
 #endif
 	return err;
@@ -755,6 +790,7 @@ const struct dcbnl_rtnl_ops dcbnl_ops = {
 	.ieee_getpfc	= ixgbe_dcbnl_ieee_getpfc,
 	.ieee_setpfc	= ixgbe_dcbnl_ieee_setpfc,
 	.ieee_setapp	= ixgbe_dcbnl_ieee_setapp,
+	.ieee_delapp	= ixgbe_dcbnl_ieee_delapp,
 	.getstate	= ixgbe_dcbnl_get_state,
 	.setstate	= ixgbe_dcbnl_set_state,
 	.getpermhwaddr	= ixgbe_dcbnl_get_perm_hw_addr,
-- 
1.7.5.4

