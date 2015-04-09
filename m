From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 2/3] amd-xgbe: Move Rx mode configuration into
 init
Date: Thu, 9 Apr 2015 12:11:57 -0500
Message-ID: <20150409171157.22188.69217.stgit@tlendack-t1.amdoffice.net>
References: <20150409171145.22188.37025.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0116.outbound.protection.outlook.com ([65.55.169.116]:4742
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753847AbbDIRMD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 13:12:03 -0400
In-Reply-To: <20150409171145.22188.37025.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently a call to configure the Rx mode (promiscuous mode, all
multicast mode, etc.) is made in xgbe_start separate from the xgbe_init
function. This call to set the Rx mode should be part of the xgbe_init
function so that calls to the init function don't have to be preceded
with calls to configure the Rx mode.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |   21 ++++++++++++++++++---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |   12 +-----------
 drivers/net/ethernet/amd/xgbe/xgbe.h     |    4 +---
 3 files changed, 20 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 96c5e4b..21d9497 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -853,6 +853,22 @@ static int xgbe_set_mac_address(struct xgbe_prv_data *pdata, u8 *addr)
 	return 0;
 }
 
+static int xgbe_config_rx_mode(struct xgbe_prv_data *pdata)
+{
+	struct net_device *netdev = pdata->netdev;
+	unsigned int pr_mode, am_mode;
+
+	pr_mode = ((netdev->flags & IFF_PROMISC) != 0);
+	am_mode = ((netdev->flags & IFF_ALLMULTI) != 0);
+
+	xgbe_set_promiscuous_mode(pdata, pr_mode);
+	xgbe_set_all_multicast_mode(pdata, am_mode);
+
+	xgbe_add_mac_addresses(pdata);
+
+	return 0;
+}
+
 static int xgbe_read_mmd_regs(struct xgbe_prv_data *pdata, int prtad,
 			      int mmd_reg)
 {
@@ -2808,6 +2824,7 @@ static int xgbe_init(struct xgbe_prv_data *pdata)
 	 * Initialize MAC related features
 	 */
 	xgbe_config_mac_address(pdata);
+	xgbe_config_rx_mode(pdata);
 	xgbe_config_jumbo_enable(pdata);
 	xgbe_config_flow_control(pdata);
 	xgbe_config_mac_speed(pdata);
@@ -2827,10 +2844,8 @@ void xgbe_init_function_ptrs_dev(struct xgbe_hw_if *hw_if)
 
 	hw_if->tx_complete = xgbe_tx_complete;
 
-	hw_if->set_promiscuous_mode = xgbe_set_promiscuous_mode;
-	hw_if->set_all_multicast_mode = xgbe_set_all_multicast_mode;
-	hw_if->add_mac_addresses = xgbe_add_mac_addresses;
 	hw_if->set_mac_address = xgbe_set_mac_address;
+	hw_if->config_rx_mode = xgbe_config_rx_mode;
 
 	hw_if->enable_rx_csum = xgbe_enable_rx_csum;
 	hw_if->disable_rx_csum = xgbe_disable_rx_csum;
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 74b4698..e10abc7 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -129,7 +129,6 @@
 
 static int xgbe_one_poll(struct napi_struct *, int);
 static int xgbe_all_poll(struct napi_struct *, int);
-static void xgbe_set_rx_mode(struct net_device *);
 
 static int xgbe_alloc_channels(struct xgbe_prv_data *pdata)
 {
@@ -952,8 +951,6 @@ static int xgbe_start(struct xgbe_prv_data *pdata)
 
 	DBGPR("-->xgbe_start\n");
 
-	xgbe_set_rx_mode(netdev);
-
 	hw_if->init(pdata);
 
 	phy_start(pdata->phydev);
@@ -1533,17 +1530,10 @@ static void xgbe_set_rx_mode(struct net_device *netdev)
 {
 	struct xgbe_prv_data *pdata = netdev_priv(netdev);
 	struct xgbe_hw_if *hw_if = &pdata->hw_if;
-	unsigned int pr_mode, am_mode;
 
 	DBGPR("-->xgbe_set_rx_mode\n");
 
-	pr_mode = ((netdev->flags & IFF_PROMISC) != 0);
-	am_mode = ((netdev->flags & IFF_ALLMULTI) != 0);
-
-	hw_if->set_promiscuous_mode(pdata, pr_mode);
-	hw_if->set_all_multicast_mode(pdata, am_mode);
-
-	hw_if->add_mac_addresses(pdata);
+	hw_if->config_rx_mode(pdata);
 
 	DBGPR("<--xgbe_set_rx_mode\n");
 }
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index a864eab..e62dfa2 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -495,10 +495,8 @@ struct xgbe_mmc_stats {
 struct xgbe_hw_if {
 	int (*tx_complete)(struct xgbe_ring_desc *);
 
-	int (*set_promiscuous_mode)(struct xgbe_prv_data *, unsigned int);
-	int (*set_all_multicast_mode)(struct xgbe_prv_data *, unsigned int);
-	int (*add_mac_addresses)(struct xgbe_prv_data *);
 	int (*set_mac_address)(struct xgbe_prv_data *, u8 *addr);
+	int (*config_rx_mode)(struct xgbe_prv_data *);
 
 	int (*enable_rx_csum)(struct xgbe_prv_data *);
 	int (*disable_rx_csum)(struct xgbe_prv_data *);
