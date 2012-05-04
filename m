From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/4] ixgbe: dcb: BIT_APP_UPCHG not set by ixgbe_copy_dcb_cfg()
Date: Fri,  4 May 2012 04:05:02 -0700
Message-ID: <1336129504-29919-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336129504-29919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56123 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755416Ab2EDLFH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2012 07:05:07 -0400
In-Reply-To: <1336129504-29919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

After this commit:

commit aacc1bea190d731755a65cb8ec31dd756f4e263e
Author: Multanen, Eric W <eric.w.multanen@intel.com>
Date:   Wed Mar 28 07:49:09 2012 +0000

    ixgbe: driver fix for link flap

The BIT_APP_UPCHG bit is no longer set when ixgbe_dcbnl_set_all() is
called. This results in the FCoE app user priority never getting set
and the driver will not configure the tx_rings correctly for FCoE
packets which use the SAN MTU and FCoE offloads.

We resolve this regression by fixing ixgbe_copy_dcb_cfg() to also
check for FCoE application changes. Additionally, we can drop the
IEEE variants of get_dcb_app() because this path is never called
with the IEEE mode enabled.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h        |    3 --
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |   43 ++++++++++------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |    4 +-
 3 files changed, 22 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 74e1921..81b1555 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -574,9 +574,6 @@ extern struct ixgbe_info ixgbe_82599_info;
 extern struct ixgbe_info ixgbe_X540_info;
 #ifdef CONFIG_IXGBE_DCB
 extern const struct dcbnl_rtnl_ops dcbnl_ops;
-extern int ixgbe_copy_dcb_cfg(struct ixgbe_dcb_config *src_dcb_cfg,
-                              struct ixgbe_dcb_config *dst_dcb_cfg,
-                              int tc_max);
 #endif
 
 extern char ixgbe_driver_name[];
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
index 652e4b0..32e5c02 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
@@ -44,18 +44,26 @@
 #define DCB_NO_HW_CHG   1  /* DCB configuration did not change */
 #define DCB_HW_CHG      2  /* DCB configuration changed, no reset */
 
-int ixgbe_copy_dcb_cfg(struct ixgbe_dcb_config *scfg,
-		       struct ixgbe_dcb_config *dcfg, int tc_max)
+static int ixgbe_copy_dcb_cfg(struct ixgbe_adapter *adapter, int tc_max)
 {
+	struct ixgbe_dcb_config *scfg = &adapter->temp_dcb_cfg;
+	struct ixgbe_dcb_config *dcfg = &adapter->dcb_cfg;
 	struct tc_configuration *src = NULL;
 	struct tc_configuration *dst = NULL;
 	int i, j;
 	int tx = DCB_TX_CONFIG;
 	int rx = DCB_RX_CONFIG;
 	int changes = 0;
+#ifdef IXGBE_FCOE
+	struct dcb_app app = {
+			      .selector = DCB_APP_IDTYPE_ETHTYPE,
+			      .protocol = ETH_P_FCOE,
+			     };
+	u8 up = dcb_getapp(adapter->netdev, &app);
 
-	if (!scfg || !dcfg)
-		return changes;
+	if (up && !(up & (1 << adapter->fcoe.up)))
+		changes |= BIT_APP_UPCHG;
+#endif
 
 	for (i = DCB_PG_ATTR_TC_0; i < tc_max + DCB_PG_ATTR_TC_0; i++) {
 		src = &scfg->tc_config[i - DCB_PG_ATTR_TC_0];
@@ -332,28 +340,12 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	int ret = DCB_NO_HW_CHG;
 	int i;
-#ifdef IXGBE_FCOE
-	struct dcb_app app = {
-			      .selector = DCB_APP_IDTYPE_ETHTYPE,
-			      .protocol = ETH_P_FCOE,
-			     };
-	u8 up;
-
-	/* In IEEE mode, use the IEEE Ethertype selector value */
-	if (adapter->dcbx_cap & DCB_CAP_DCBX_VER_IEEE) {
-		app.selector = IEEE_8021QAZ_APP_SEL_ETHERTYPE;
-		up = dcb_ieee_getapp_mask(netdev, &app);
-	} else {
-		up = dcb_getapp(netdev, &app);
-	}
-#endif
 
 	/* Fail command if not in CEE mode */
 	if (!(adapter->dcbx_cap & DCB_CAP_DCBX_VER_CEE))
 		return ret;
 
-	adapter->dcb_set_bitmap |= ixgbe_copy_dcb_cfg(&adapter->temp_dcb_cfg,
-						      &adapter->dcb_cfg,
+	adapter->dcb_set_bitmap |= ixgbe_copy_dcb_cfg(adapter,
 						      MAX_TRAFFIC_CLASS);
 	if (!adapter->dcb_set_bitmap)
 		return ret;
@@ -440,8 +432,13 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 	 * FCoE is using changes. This happens if the APP info
 	 * changes or the up2tc mapping is updated.
 	 */
-	if ((up && !(up & (1 << adapter->fcoe.up))) ||
-	    (adapter->dcb_set_bitmap & BIT_APP_UPCHG)) {
+	if (adapter->dcb_set_bitmap & BIT_APP_UPCHG) {
+		struct dcb_app app = {
+				      .selector = DCB_APP_IDTYPE_ETHTYPE,
+				      .protocol = ETH_P_FCOE,
+				     };
+		u8 up = dcb_getapp(netdev, &app);
+
 		adapter->fcoe.up = ffs(up) - 1;
 		ixgbe_dcbnl_devreset(netdev);
 		ret = DCB_HW_CHG_RST;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d9dbf87..50f0700 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4418,8 +4418,8 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->dcb_cfg.pfc_mode_enable = false;
 	adapter->dcb_set_bitmap = 0x00;
 	adapter->dcbx_cap = DCB_CAP_DCBX_HOST | DCB_CAP_DCBX_VER_CEE;
-	ixgbe_copy_dcb_cfg(&adapter->dcb_cfg, &adapter->temp_dcb_cfg,
-			   MAX_TRAFFIC_CLASS);
+	memcpy(&adapter->temp_dcb_cfg, &adapter->dcb_cfg,
+	       sizeof(adapter->temp_dcb_cfg));
 
 #endif
 
-- 
1.7.7.6
