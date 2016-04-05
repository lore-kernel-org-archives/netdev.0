From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/18] i40e: call ndo_stop() instead of dev_close() when running offline selftest
Date: Tue,  5 Apr 2016 13:17:18 -0700
Message-ID: <1459887455-146634-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stefan Assmann <sassmann@kpanic.de>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10824 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759914AbcDEURi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 16:17:38 -0400
In-Reply-To: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@kpanic.de>

Calling dev_close() causes IFF_UP to be cleared which will remove the
interfaces routes and some addresses. That's probably not what the user
intended when running the offline selftest. Besides this does not happen
if the interface is brought down before the test, so the current
behaviour is inconsistent.
Instead call the net_device_ops ndo_stop function directly and avoid
touching IFF_UP at all.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         | 2 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 4 ++--
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 4 ----
 3 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 1ce6e9c..f208570 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -811,6 +811,7 @@ int i40e_vlan_rx_kill_vid(struct net_device *netdev,
 			  __always_unused __be16 proto, u16 vid);
 #endif
 int i40e_open(struct net_device *netdev);
+int i40e_close(struct net_device *netdev);
 int i40e_vsi_open(struct i40e_vsi *vsi);
 void i40e_vlan_stripping_disable(struct i40e_vsi *vsi);
 int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid);
@@ -823,7 +824,6 @@ bool i40e_is_vsi_in_vlan(struct i40e_vsi *vsi);
 struct i40e_mac_filter *i40e_find_mac(struct i40e_vsi *vsi, u8 *macaddr,
 				      bool is_vf, bool is_netdev);
 #ifdef I40E_FCOE
-int i40e_close(struct net_device *netdev);
 int __i40e_setup_tc(struct net_device *netdev, u32 handle, __be16 proto,
 		    struct tc_to_netdev *tc);
 void i40e_netpoll(struct net_device *netdev);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 784b165..410d237 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1714,7 +1714,7 @@ static void i40e_diag_test(struct net_device *netdev,
 		/* If the device is online then take it offline */
 		if (if_running)
 			/* indicate we're in test mode */
-			dev_close(netdev);
+			i40e_close(netdev);
 		else
 			/* This reset does not affect link - if it is
 			 * changed to a type of reset that does affect
@@ -1743,7 +1743,7 @@ static void i40e_diag_test(struct net_device *netdev,
 		i40e_do_reset(pf, BIT(__I40E_PF_RESET_REQUESTED));
 
 		if (if_running)
-			dev_open(netdev);
+			i40e_open(netdev);
 	} else {
 		/* Online tests */
 		netif_info(pf, drv, netdev, "online testing starting\n");
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 6700643..650336e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5509,11 +5509,7 @@ static void i40e_fdir_filter_exit(struct i40e_pf *pf)
  *
  * Returns 0, this is not allowed to fail
  **/
-#ifdef I40E_FCOE
 int i40e_close(struct net_device *netdev)
-#else
-static int i40e_close(struct net_device *netdev)
-#endif
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
-- 
2.5.5
