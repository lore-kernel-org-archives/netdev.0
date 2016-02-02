From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH net-next 1/6] i40e: call ndo_stop() instead of dev_close() when running offline selftest
Date: Tue,  2 Feb 2016 11:13:43 +0100
Message-ID: <1454408028-16986-2-git-send-email-sassmann@kpanic.de>
References: <1454408028-16986-1-git-send-email-sassmann@kpanic.de>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, sassmann@kpanic.de
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39673 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754487AbcBBKQW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 05:16:22 -0500
In-Reply-To: <1454408028-16986-1-git-send-email-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calling dev_close() causes IFF_UP to be cleared which will remove the
interfaces routes and some addresses. That's probably not what the user
intended when running the offline selftest. Besides this does not happen
if the interface is brought down before the test, so the current
behaviour is inconsistent.
Instead call the net_device_ops ndo_stop function directly and avoid
touching IFF_UP at all.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
---
 drivers/net/ethernet/intel/i40e/i40e.h         | 2 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 4 ++--
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 4 ----
 3 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 68f2204..7e16c55 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -773,6 +773,7 @@ int i40e_vlan_rx_kill_vid(struct net_device *netdev,
 			  __always_unused __be16 proto, u16 vid);
 #endif
 int i40e_open(struct net_device *netdev);
+int i40e_close(struct net_device *netdev);
 int i40e_vsi_open(struct i40e_vsi *vsi);
 void i40e_vlan_stripping_disable(struct i40e_vsi *vsi);
 int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid);
@@ -785,7 +786,6 @@ bool i40e_is_vsi_in_vlan(struct i40e_vsi *vsi);
 struct i40e_mac_filter *i40e_find_mac(struct i40e_vsi *vsi, u8 *macaddr,
 				      bool is_vf, bool is_netdev);
 #ifdef I40E_FCOE
-int i40e_close(struct net_device *netdev);
 int i40e_setup_tc(struct net_device *netdev, u8 tc);
 void i40e_netpoll(struct net_device *netdev);
 int i40e_fcoe_enable(struct net_device *netdev);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 29d5833..eeca530 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1704,7 +1704,7 @@ static void i40e_diag_test(struct net_device *netdev,
 		/* If the device is online then take it offline */
 		if (if_running)
 			/* indicate we're in test mode */
-			dev_close(netdev);
+			i40e_close(netdev);
 		else
 			/* This reset does not affect link - if it is
 			 * changed to a type of reset that does affect
@@ -1733,7 +1733,7 @@ static void i40e_diag_test(struct net_device *netdev,
 		i40e_do_reset(pf, BIT(__I40E_PF_RESET_REQUESTED));
 
 		if (if_running)
-			dev_open(netdev);
+			i40e_open(netdev);
 	} else {
 		/* Online tests */
 		netif_info(pf, drv, netdev, "online testing starting\n");
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index bb4612c..9792961 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5459,11 +5459,7 @@ static void i40e_fdir_filter_exit(struct i40e_pf *pf)
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
2.5.0
