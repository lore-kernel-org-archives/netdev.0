From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/11] ixgbe: Reset the NIC if up2tc has changed
Date: Thu, 31 Jan 2013 23:53:21 -0800
Message-ID: <1359705211-11342-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359705211-11342-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Amir Hanania <amir.hanania@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12706 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751098Ab3BAHxx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 02:53:53 -0500
In-Reply-To: <1359705211-11342-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Hanania <amir.hanania@intel.com>

Check for up2tc change and call ixgbe_dcbnl_devreset() if the mapping has
changed but the number of TC's in use has not changed.

Signed-off-by: Amir Hanania <amir.hanania@intel.com>
Tested-by: Jack Morgan <jack.morgan@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
index 6718fb4..c261333 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
@@ -302,7 +302,6 @@ static void ixgbe_dcbnl_get_pfc_cfg(struct net_device *netdev, int priority,
 	*setting = adapter->dcb_cfg.tc_config[priority].dcb_pfc;
 }
 
-#ifdef IXGBE_FCOE
 static void ixgbe_dcbnl_devreset(struct net_device *dev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
@@ -321,7 +320,6 @@ static void ixgbe_dcbnl_devreset(struct net_device *dev)
 
 	clear_bit(__IXGBE_RESETTING, &adapter->state);
 }
-#endif
 
 static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 {
@@ -542,6 +540,7 @@ static int ixgbe_dcbnl_ieee_setets(struct net_device *dev,
 	int max_frame = dev->mtu + ETH_HLEN + ETH_FCS_LEN;
 	int i, err = 0;
 	__u8 max_tc = 0;
+	__u8 map_chg = 0;
 
 	if (!(adapter->dcbx_cap & DCB_CAP_DCBX_VER_IEEE))
 		return -EINVAL;
@@ -551,15 +550,22 @@ static int ixgbe_dcbnl_ieee_setets(struct net_device *dev,
 						  GFP_KERNEL);
 		if (!adapter->ixgbe_ieee_ets)
 			return -ENOMEM;
-	}
 
-	memcpy(adapter->ixgbe_ieee_ets, ets, sizeof(*adapter->ixgbe_ieee_ets));
+		/* initialize UP2TC mappings to invalid value */
+		for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++)
+			adapter->ixgbe_ieee_ets->prio_tc[i] =
+				IEEE_8021QAZ_MAX_TCS;
+	}
 
 	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
 		if (ets->prio_tc[i] > max_tc)
 			max_tc = ets->prio_tc[i];
+		if (ets->prio_tc[i] != adapter->ixgbe_ieee_ets->prio_tc[i])
+			map_chg = 1;
 	}
 
+	memcpy(adapter->ixgbe_ieee_ets, ets, sizeof(*adapter->ixgbe_ieee_ets));
+
 	if (max_tc)
 		max_tc++;
 
@@ -568,6 +574,8 @@ static int ixgbe_dcbnl_ieee_setets(struct net_device *dev,
 
 	if (max_tc != netdev_get_num_tc(dev))
 		err = ixgbe_setup_tc(dev, max_tc);
+	else if (map_chg)
+		ixgbe_dcbnl_devreset(dev);
 
 	if (err)
 		goto err_out;
-- 
1.7.11.7
