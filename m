From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/16] i40e: add switch for link polling
Date: Thu,  8 Oct 2015 18:32:46 -0700
Message-ID: <1444354374-24351-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17941 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755527AbbJIBc7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 21:32:59 -0400
In-Reply-To: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

There's been some need for controlling the periodic link polling for
debugging link issues.  This patch enables switching it off and on
through an ethtool private flag.  The link poll remains on by default,
but can be turned off with
	ethtool --set-priv-flags p261p1 LinkPolling off
and later turned back on with
	ethtool --set-priv-flags p261p1 LinkPolling on

To check the current status, use
	ethtool --show-priv-flags p261p1

Change-ID: I32e4ab654ff3eec90a06cf144899971b82d71c40
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  2 ++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 26 ++++++++++++++++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_main.c    |  4 +++-
 3 files changed, 29 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 0c73404..f26dcb2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -101,6 +101,7 @@
 
 /* Ethtool Private Flags */
 #define I40E_PRIV_FLAGS_NPAR_FLAG	BIT(0)
+#define I40E_PRIV_FLAGS_LINKPOLL_FLAG	BIT(1)
 
 #define I40E_NVM_VERSION_LO_SHIFT  0
 #define I40E_NVM_VERSION_LO_MASK   (0xff << I40E_NVM_VERSION_LO_SHIFT)
@@ -327,6 +328,7 @@ struct i40e_pf {
 #define I40E_FLAG_WB_ON_ITR_CAPABLE		BIT_ULL(35)
 #define I40E_FLAG_VEB_STATS_ENABLED		BIT_ULL(37)
 #define I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE	BIT_ULL(38)
+#define I40E_FLAG_LINK_POLLING_ENABLED		BIT_ULL(39)
 #define I40E_FLAG_VEB_MODE_ENABLED		BIT_ULL(40)
 
 	/* tracks features that get auto disabled by errors */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index f2b4f8b..5a726f2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -230,10 +230,10 @@ static const char i40e_gstrings_test[][ETH_GSTRING_LEN] = {
 
 static const char i40e_priv_flags_strings[][ETH_GSTRING_LEN] = {
 	"NPAR",
+	"LinkPolling",
 };
 
-#define I40E_PRIV_FLAGS_STR_LEN \
-	(sizeof(i40e_priv_flags_strings) / ETH_GSTRING_LEN)
+#define I40E_PRIV_FLAGS_STR_LEN ARRAY_SIZE(i40e_priv_flags_strings)
 
 /**
  * i40e_partition_setting_complaint - generic complaint for MFP restriction
@@ -2636,10 +2636,31 @@ static u32 i40e_get_priv_flags(struct net_device *dev)
 
 	ret_flags |= pf->hw.func_caps.npar_enable ?
 		I40E_PRIV_FLAGS_NPAR_FLAG : 0;
+	ret_flags |= pf->flags & I40E_FLAG_LINK_POLLING_ENABLED ?
+		I40E_PRIV_FLAGS_LINKPOLL_FLAG : 0;
 
 	return ret_flags;
 }
 
+/**
+ * i40e_set_priv_flags - set private flags
+ * @dev: network interface device structure
+ * @flags: bit flags to be set
+ **/
+static int i40e_set_priv_flags(struct net_device *dev, u32 flags)
+{
+	struct i40e_netdev_priv *np = netdev_priv(dev);
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
+
+	if (flags & I40E_PRIV_FLAGS_LINKPOLL_FLAG)
+		pf->flags |= I40E_FLAG_LINK_POLLING_ENABLED;
+	else
+		pf->flags &= ~I40E_FLAG_LINK_POLLING_ENABLED;
+
+	return 0;
+}
+
 static const struct ethtool_ops i40e_ethtool_ops = {
 	.get_settings		= i40e_get_settings,
 	.set_settings		= i40e_set_settings,
@@ -2676,6 +2697,7 @@ static const struct ethtool_ops i40e_ethtool_ops = {
 	.set_channels		= i40e_set_channels,
 	.get_ts_info		= i40e_get_ts_info,
 	.get_priv_flags		= i40e_get_priv_flags,
+	.set_priv_flags		= i40e_set_priv_flags,
 };
 
 void i40e_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e05e6aa..23a7b40 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5892,7 +5892,8 @@ static void i40e_watchdog_subtask(struct i40e_pf *pf)
 		return;
 	pf->service_timer_previous = jiffies;
 
-	i40e_link_event(pf);
+	if (pf->flags & I40E_FLAG_LINK_POLLING_ENABLED)
+		i40e_link_event(pf);
 
 	/* Update the stats for active netdevs so the network stack
 	 * can look at updated numbers whenever it cares to
@@ -7908,6 +7909,7 @@ static int i40e_sw_init(struct i40e_pf *pf)
 	/* Set default capability flags */
 	pf->flags = I40E_FLAG_RX_CSUM_ENABLED |
 		    I40E_FLAG_MSI_ENABLED     |
+		    I40E_FLAG_LINK_POLLING_ENABLED |
 		    I40E_FLAG_MSIX_ENABLED;
 
 	if (iommu_present(&pci_bus_type))
-- 
2.4.3
