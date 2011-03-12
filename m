From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 07/21] ixgbe: DCB, implement capabilities flags
Date: Sat, 12 Mar 2011 04:20:14 -0800
Message-ID: <1299932428-3114-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2695 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753906Ab1CLMUy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 07:20:54 -0500
In-Reply-To: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

This implements dcbnl get and set capabilities ops. The
devices supported by ixgbe can be configured to run in
IEEE or CEE modes but not both.

With the DCBX set capabilities bit we add an explicit
signal that must be used to toggle between these modes.
This patch adds logic to fail the CEE command set_hw_all()
which programs the device with a CEE configuration if
the CEE caps bit is not set. Similarly, IEEE set
commands will fail if the IEEE caps bit is not set. We
allow most CEE config set commands to occur because they
do not touch the hardware until set_hw_all() is called.

The one exception to the above is the {set|get}app routines.
These must always be protected by caps bits to ensure
side effects do not corrupt the current configured mode.

By requiring the caps bit to be set correctly we can
maintain a consistent configuration in the hardware
for CEE or IEEE modes and prevent partial hardware
configurations that may occur if user space does
not send a complete IEEE or CEE configurations.

It is expected that user space will signal a DCBX mode
before programming device.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h        |    1 +
 drivers/net/ixgbe/ixgbe_dcb_nl.c |  129 +++++++++++++++++++++++++++-----------
 drivers/net/ixgbe/ixgbe_main.c   |    1 +
 3 files changed, 95 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 1e546fc..815edfd 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -341,6 +341,7 @@ struct ixgbe_adapter {
 	struct ixgbe_dcb_config dcb_cfg;
 	struct ixgbe_dcb_config temp_dcb_cfg;
 	u8 dcb_set_bitmap;
+	u8 dcbx_cap;
 	enum ixgbe_fc_mode last_lfc_mode;
 
 	/* Interrupt Throttle Rate */
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index d7f0024..d7c456f 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -346,7 +346,8 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	int ret;
 
-	if (!adapter->dcb_set_bitmap)
+	if (!adapter->dcb_set_bitmap ||
+	    !(adapter->dcbx_cap & DCB_CAP_DCBX_VER_CEE))
 		return DCB_NO_HW_CHG;
 
 	ret = ixgbe_copy_dcb_cfg(&adapter->temp_dcb_cfg, &adapter->dcb_cfg,
@@ -448,40 +449,38 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 static u8 ixgbe_dcbnl_getcap(struct net_device *netdev, int capid, u8 *cap)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	u8 rval = 0;
 
-	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-		switch (capid) {
-		case DCB_CAP_ATTR_PG:
-			*cap = true;
-			break;
-		case DCB_CAP_ATTR_PFC:
-			*cap = true;
-			break;
-		case DCB_CAP_ATTR_UP2TC:
-			*cap = false;
-			break;
-		case DCB_CAP_ATTR_PG_TCS:
-			*cap = 0x80;
-			break;
-		case DCB_CAP_ATTR_PFC_TCS:
-			*cap = 0x80;
-			break;
-		case DCB_CAP_ATTR_GSP:
-			*cap = true;
-			break;
-		case DCB_CAP_ATTR_BCN:
-			*cap = false;
-			break;
-		default:
-			rval = -EINVAL;
-			break;
-		}
-	} else {
-		rval = -EINVAL;
+	switch (capid) {
+	case DCB_CAP_ATTR_PG:
+		*cap = true;
+		break;
+	case DCB_CAP_ATTR_PFC:
+		*cap = true;
+		break;
+	case DCB_CAP_ATTR_UP2TC:
+		*cap = false;
+		break;
+	case DCB_CAP_ATTR_PG_TCS:
+		*cap = 0x80;
+		break;
+	case DCB_CAP_ATTR_PFC_TCS:
+		*cap = 0x80;
+		break;
+	case DCB_CAP_ATTR_GSP:
+		*cap = true;
+		break;
+	case DCB_CAP_ATTR_BCN:
+		*cap = false;
+		break;
+	case DCB_CAP_ATTR_DCBX:
+		*cap = adapter->dcbx_cap;
+		break;
+	default:
+		*cap = false;
+		break;
 	}
 
-	return rval;
+	return 0;
 }
 
 static u8 ixgbe_dcbnl_getnumtcs(struct net_device *netdev, int tcid, u8 *num)
@@ -542,13 +541,17 @@ static void ixgbe_dcbnl_setpfcstate(struct net_device *netdev, u8 state)
  */
 static u8 ixgbe_dcbnl_getapp(struct net_device *netdev, u8 idtype, u16 id)
 {
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	u8 rval = 0;
 
+	if (!(adapter->dcbx_cap & DCB_CAP_DCBX_VER_CEE))
+		return rval;
+
 	switch (idtype) {
 	case DCB_APP_IDTYPE_ETHTYPE:
 #ifdef IXGBE_FCOE
 		if (id == ETH_P_FCOE)
-			rval = ixgbe_fcoe_getapp(netdev_priv(netdev));
+			rval = ixgbe_fcoe_getapp(adapter);
 #endif
 		break;
 	case DCB_APP_IDTYPE_PORTNUM:
@@ -571,14 +574,17 @@ static u8 ixgbe_dcbnl_getapp(struct net_device *netdev, u8 idtype, u16 id)
 static u8 ixgbe_dcbnl_setapp(struct net_device *netdev,
                              u8 idtype, u16 id, u8 up)
 {
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	u8 rval = 1;
 
+	if (!(adapter->dcbx_cap & DCB_CAP_DCBX_VER_CEE))
+		return rval;
+
 	switch (idtype) {
 	case DCB_APP_IDTYPE_ETHTYPE:
 #ifdef IXGBE_FCOE
 		if (id == ETH_P_FCOE) {
 			u8 old_tc;
-			struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
 			/* Get current programmed tc */
 			old_tc = adapter->fcoe.tc;
@@ -640,6 +646,9 @@ static int ixgbe_dcbnl_ieee_setets(struct net_device *dev,
 	/* naively give each TC a bwg to map onto CEE hardware */
 	__u8 bwg_id[IEEE_8021QAZ_MAX_TCS] = {0, 1, 2, 3, 4, 5, 6, 7};
 
+	if (!(adapter->dcbx_cap & DCB_CAP_DCBX_VER_IEEE))
+		return -EINVAL;
+
 	if (!adapter->ixgbe_ieee_ets) {
 		adapter->ixgbe_ieee_ets = kmalloc(sizeof(struct ieee_ets),
 						  GFP_KERNEL);
@@ -647,7 +656,6 @@ static int ixgbe_dcbnl_ieee_setets(struct net_device *dev,
 			return -ENOMEM;
 	}
 
-
 	memcpy(adapter->ixgbe_ieee_ets, ets, sizeof(*adapter->ixgbe_ieee_ets));
 
 	ixgbe_ieee_credits(ets->tc_tx_bw, refill, max, max_frame);
@@ -686,6 +694,9 @@ static int ixgbe_dcbnl_ieee_setpfc(struct net_device *dev,
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	int err;
 
+	if (!(adapter->dcbx_cap & DCB_CAP_DCBX_VER_IEEE))
+		return -EINVAL;
+
 	if (!adapter->ixgbe_ieee_pfc) {
 		adapter->ixgbe_ieee_pfc = kmalloc(sizeof(struct ieee_pfc),
 						  GFP_KERNEL);
@@ -698,6 +709,51 @@ static int ixgbe_dcbnl_ieee_setpfc(struct net_device *dev,
 	return err;
 }
 
+static u8 ixgbe_dcbnl_getdcbx(struct net_device *dev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	return adapter->dcbx_cap;
+}
+
+static u8 ixgbe_dcbnl_setdcbx(struct net_device *dev, u8 mode)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	struct ieee_ets ets = {0};
+	struct ieee_pfc pfc = {0};
+
+	/* no support for LLD_MANAGED modes or CEE+IEEE */
+	if ((mode & DCB_CAP_DCBX_LLD_MANAGED) ||
+	    ((mode & DCB_CAP_DCBX_VER_IEEE) && (mode & DCB_CAP_DCBX_VER_CEE)) ||
+	    !(mode & DCB_CAP_DCBX_HOST))
+		return 1;
+
+	if (mode == adapter->dcbx_cap)
+		return 0;
+
+	adapter->dcbx_cap = mode;
+
+	/* ETS and PFC defaults */
+	ets.ets_cap = 8;
+	pfc.pfc_cap = 8;
+
+	if (mode & DCB_CAP_DCBX_VER_IEEE) {
+		ixgbe_dcbnl_ieee_setets(dev, &ets);
+		ixgbe_dcbnl_ieee_setpfc(dev, &pfc);
+	} else if (mode & DCB_CAP_DCBX_VER_CEE) {
+		adapter->dcb_set_bitmap |= (BIT_PFC & BIT_PG_TX & BIT_PG_RX);
+		ixgbe_dcbnl_set_all(dev);
+	} else {
+		/* Drop into single TC mode strict priority as this
+		 * indicates CEE and IEEE versions are disabled
+		 */
+		ixgbe_dcbnl_ieee_setets(dev, &ets);
+		ixgbe_dcbnl_ieee_setpfc(dev, &pfc);
+		ixgbe_dcbnl_set_state(dev, 0);
+	}
+
+	return 0;
+}
+
 const struct dcbnl_rtnl_ops dcbnl_ops = {
 	.ieee_getets	= ixgbe_dcbnl_ieee_getets,
 	.ieee_setets	= ixgbe_dcbnl_ieee_setets,
@@ -724,5 +780,6 @@ const struct dcbnl_rtnl_ops dcbnl_ops = {
 	.setpfcstate	= ixgbe_dcbnl_setpfcstate,
 	.getapp		= ixgbe_dcbnl_getapp,
 	.setapp		= ixgbe_dcbnl_setapp,
+	.getdcbx	= ixgbe_dcbnl_getdcbx,
+	.setdcbx	= ixgbe_dcbnl_setdcbx,
 };
-
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 5998dc9..4aeade8 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5190,6 +5190,7 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->dcb_cfg.rx_pba_cfg = pba_equal;
 	adapter->dcb_cfg.pfc_mode_enable = false;
 	adapter->dcb_set_bitmap = 0x00;
+	adapter->dcbx_cap = DCB_CAP_DCBX_HOST | DCB_CAP_DCBX_VER_CEE;
 	ixgbe_copy_dcb_cfg(&adapter->dcb_cfg, &adapter->temp_dcb_cfg,
 			   adapter->ring_feature[RING_F_DCB].indices);
 
-- 
1.7.4

