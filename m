From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/7] ixgbe: Populate the prio_tc_map in ixgbe_setup_tc
Date: Sat, 14 Jul 2012 16:07:03 -0700
Message-ID: <1342307225-28917-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342307225-28917-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:23399 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754280Ab2GNXHp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jul 2012 19:07:45 -0400
In-Reply-To: <1342307225-28917-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

There were cases where the prio_tc_map was not populated when we were
calling open.  This will result in us incorrectly configuring the traffic
classes when DCB is enabled.  In order to correct this I have updated the
code so that we now populate the values prior to allocating the q_vectors
and calling ixgbe_open.

Cc: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c    |    3 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h    |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |   26 ++++-----------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |   28 +++++++++++++++++++++++
 4 files changed, 35 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
index 39ac2fe..5442b35 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
@@ -228,8 +228,7 @@ void ixgbe_dcb_unpack_prio(struct ixgbe_dcb_config *cfg, int direction,
 		ptype[tc] = tc_config[tc].path[direction].prio_type;
 }
 
-static u8 ixgbe_dcb_get_tc_from_up(struct ixgbe_dcb_config *cfg,
-				   int direction, u8 up)
+u8 ixgbe_dcb_get_tc_from_up(struct ixgbe_dcb_config *cfg, int direction, u8 up)
 {
 	struct tc_configuration *tc_config = &cfg->tc_config[0];
 	u8 prio_mask = 1 << up;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h
index 24333b7..1f4108e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h
@@ -146,6 +146,7 @@ void ixgbe_dcb_unpack_max(struct ixgbe_dcb_config *, u16 *);
 void ixgbe_dcb_unpack_bwgid(struct ixgbe_dcb_config *, int, u8 *);
 void ixgbe_dcb_unpack_prio(struct ixgbe_dcb_config *, int, u8 *);
 void ixgbe_dcb_unpack_map(struct ixgbe_dcb_config *, int, u8 *);
+u8 ixgbe_dcb_get_tc_from_up(struct ixgbe_dcb_config *, int, u8);
 
 /* DCB credits calculation */
 s32 ixgbe_dcb_calculate_tc_credits(struct ixgbe_hw *,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
index 5164a21..f1e002d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
@@ -151,34 +151,21 @@ static u8 ixgbe_dcbnl_get_state(struct net_device *netdev)
 
 static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 {
-	int err = 0;
-	u8 prio_tc[MAX_USER_PRIORITY] = {0};
-	int i;
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	int err = 0;
 
 	/* Fail command if not in CEE mode */
 	if (!(adapter->dcbx_cap & DCB_CAP_DCBX_VER_CEE))
 		return 1;
 
 	/* verify there is something to do, if not then exit */
-	if (!!state != !(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
-		goto out;
-
-	if (state > 0) {
-		err = ixgbe_setup_tc(netdev, adapter->dcb_cfg.num_tcs.pg_tcs);
-		ixgbe_dcb_unpack_map(&adapter->dcb_cfg, DCB_TX_CONFIG, prio_tc);
-	} else {
-		err = ixgbe_setup_tc(netdev, 0);
-	}
-
-	if (err)
+	if (!state == !(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
 		goto out;
 
-	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++)
-		netdev_set_prio_tc_map(netdev, i, prio_tc[i]);
-
+	err = ixgbe_setup_tc(netdev,
+			     state ? adapter->dcb_cfg.num_tcs.pg_tcs : 0);
 out:
-	return err ? 1 : 0;
+	return !!err;
 }
 
 static void ixgbe_dcbnl_get_perm_hw_addr(struct net_device *netdev,
@@ -584,9 +571,6 @@ static int ixgbe_dcbnl_ieee_setets(struct net_device *dev,
 	if (err)
 		goto err_out;
 
-	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++)
-		netdev_set_prio_tc_map(dev, i, ets->prio_tc[i]);
-
 	err = ixgbe_dcb_hw_ets(&adapter->hw, ets, max_frame);
 err_out:
 	return err;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d3cf887..91bc60f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6596,6 +6596,31 @@ static void ixgbe_validate_rtr(struct ixgbe_adapter *adapter, u8 tc)
 }
 
 /**
+ * ixgbe_set_prio_tc_map - Configure netdev prio tc map
+ * @adapter: Pointer to adapter struct
+ *
+ * Populate the netdev user priority to tc map
+ */
+static void ixgbe_set_prio_tc_map(struct ixgbe_adapter *adapter)
+{
+	struct net_device *dev = adapter->netdev;
+	struct ixgbe_dcb_config *dcb_cfg = &adapter->dcb_cfg;
+	struct ieee_ets *ets = adapter->ixgbe_ieee_ets;
+	u8 prio;
+
+	for (prio = 0; prio < MAX_USER_PRIORITY; prio++) {
+		u8 tc = 0;
+
+		if (adapter->dcbx_cap & DCB_CAP_DCBX_VER_CEE)
+			tc = ixgbe_dcb_get_tc_from_up(dcb_cfg, 0, prio);
+		else if (ets)
+			tc = ets->prio_tc[prio];
+
+		netdev_set_prio_tc_map(dev, prio, tc);
+	}
+}
+
+/**
  * ixgbe_setup_tc - configure net_device for multiple traffic classes
  *
  * @netdev: net device to configure
@@ -6633,6 +6658,8 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 
 	if (tc) {
 		netdev_set_num_tc(dev, tc);
+		ixgbe_set_prio_tc_map(adapter);
+
 		adapter->flags |= IXGBE_FLAG_DCB_ENABLED;
 		adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
 
@@ -6642,6 +6669,7 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 		}
 	} else {
 		netdev_reset_tc(dev);
+
 		if (adapter->hw.mac.type == ixgbe_mac_82598EB)
 			adapter->hw.fc.requested_mode = adapter->last_lfc_mode;
 
-- 
1.7.10.4
