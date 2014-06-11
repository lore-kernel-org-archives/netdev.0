From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] i40e: Separate out DCB capability and enabled flags
Date: Wed, 11 Jun 2014 09:33:16 -0700
Message-ID: <1402504404-8954-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402504404-8954-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55595 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932544AbaFKQdb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 12:33:31 -0400
In-Reply-To: <1402504404-8954-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

Currently if the firmware reports DCB capability the driver enables
I40E_FLAG_DCB_ENABLED flag. When this flag is enabled the driver
inserts a tag when transmitting a packet from the port even if there
are no DCB traffic classes configured at the port.

This patch adds a new flag I40E_FLAG_DCB_CAPABLE that will be set
when the DCB capability is present and the existing flag
I40E_FLAG_DCB_ENABLED will be set only if there are more than one
traffic classes configured at the port.

Change-ID: I24ccbf53ef293db2eba80c8a9772acf729795bd5
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h        |  1 +
 drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c |  4 ++--
 drivers/net/ethernet/intel/i40e/i40e_main.c   | 30 ++++++++++++++++++++-------
 3 files changed, 25 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index fc1bd10..5a8bbaa 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -264,6 +264,7 @@ struct i40e_pf {
 #ifdef CONFIG_I40E_VXLAN
 #define I40E_FLAG_VXLAN_FILTER_SYNC            (u64)(1 << 27)
 #endif
+#define I40E_FLAG_DCB_CAPABLE                  (u64)(1 << 29)
 
 	/* tracks features that get auto disabled by errors */
 	u64 auto_disable_flags;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c b/drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c
index 871831a..00bc0cd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c
@@ -302,8 +302,8 @@ void i40e_dcbnl_setup(struct i40e_vsi *vsi)
 	struct net_device *dev = vsi->netdev;
 	struct i40e_pf *pf = i40e_netdev_to_pf(dev);
 
-	/* DCB not enabled */
-	if (!(pf->flags & I40E_FLAG_DCB_ENABLED))
+	/* Not DCB capable */
+	if (!(pf->flags & I40E_FLAG_DCB_CAPABLE))
 		return;
 
 	/* Do not setup DCB NL ops for MFP mode */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 145cb9f..676bebb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4130,7 +4130,11 @@ static int i40e_init_pf_dcb(struct i40e_pf *pf)
 			/* When status is not DISABLED then DCBX in FW */
 			pf->dcbx_cap = DCB_CAP_DCBX_LLD_MANAGED |
 				       DCB_CAP_DCBX_VER_IEEE;
-			pf->flags |= I40E_FLAG_DCB_ENABLED;
+
+			pf->flags |= I40E_FLAG_DCB_CAPABLE;
+			/* Enable DCB tagging only when more than one TC */
+			if (i40e_dcb_get_num_tc(&hw->local_dcbx_config) > 1)
+				pf->flags |= I40E_FLAG_DCB_ENABLED;
 		}
 	} else {
 		dev_info(&pf->pdev->dev, "AQ Querying DCB configuration failed: %d\n",
@@ -4685,6 +4689,10 @@ static int i40e_handle_lldp_event(struct i40e_pf *pf,
 	int ret = 0;
 	u8 type;
 
+	/* Not DCB capable or capability disabled */
+	if (!(pf->flags & I40E_FLAG_DCB_CAPABLE))
+		return ret;
+
 	/* Ignore if event is not for Nearest Bridge */
 	type = ((mib->type >> I40E_AQ_LLDP_BRIDGE_TYPE_SHIFT)
 		& I40E_AQ_LLDP_BRIDGE_TYPE_MASK);
@@ -4726,6 +4734,12 @@ static int i40e_handle_lldp_event(struct i40e_pf *pf,
 	if (!need_reconfig)
 		goto exit;
 
+	/* Enable DCB tagging only when more than one TC */
+	if (i40e_dcb_get_num_tc(dcbx_cfg) > 1)
+		pf->flags |= I40E_FLAG_DCB_ENABLED;
+	else
+		pf->flags &= ~I40E_FLAG_DCB_ENABLED;
+
 	/* Reconfiguration needed quiesce all VSIs */
 	i40e_pf_quiesce_all_vsi(pf);
 
@@ -6365,7 +6379,7 @@ static void i40e_init_interrupt_scheme(struct i40e_pf *pf)
 		if (err) {
 			pf->flags &= ~(I40E_FLAG_MSIX_ENABLED	|
 				       I40E_FLAG_RSS_ENABLED	|
-				       I40E_FLAG_DCB_ENABLED	|
+				       I40E_FLAG_DCB_CAPABLE	|
 				       I40E_FLAG_SRIOV_ENABLED	|
 				       I40E_FLAG_FD_SB_ENABLED	|
 				       I40E_FLAG_FD_ATR_ENABLED	|
@@ -8187,13 +8201,13 @@ static void i40e_determine_queue_usage(struct i40e_pf *pf)
 		pf->flags &= ~(I40E_FLAG_RSS_ENABLED	|
 			       I40E_FLAG_FD_SB_ENABLED	|
 			       I40E_FLAG_FD_ATR_ENABLED	|
-			       I40E_FLAG_DCB_ENABLED	|
+			       I40E_FLAG_DCB_CAPABLE	|
 			       I40E_FLAG_SRIOV_ENABLED	|
 			       I40E_FLAG_VMDQ_ENABLED);
 	} else if (!(pf->flags & (I40E_FLAG_RSS_ENABLED |
 				  I40E_FLAG_FD_SB_ENABLED |
 				  I40E_FLAG_FD_ATR_ENABLED |
-				  I40E_FLAG_DCB_ENABLED))) {
+				  I40E_FLAG_DCB_CAPABLE))) {
 		/* one qp for PF */
 		pf->rss_size = pf->num_lan_qps = 1;
 		queues_left -= pf->num_lan_qps;
@@ -8205,9 +8219,9 @@ static void i40e_determine_queue_usage(struct i40e_pf *pf)
 			       I40E_FLAG_VMDQ_ENABLED);
 	} else {
 		/* Not enough queues for all TCs */
-		if ((pf->flags & I40E_FLAG_DCB_ENABLED) &&
+		if ((pf->flags & I40E_FLAG_DCB_CAPABLE) &&
 		    (queues_left < I40E_MAX_TRAFFIC_CLASS)) {
-			pf->flags &= ~I40E_FLAG_DCB_ENABLED;
+			pf->flags &= ~I40E_FLAG_DCB_CAPABLE;
 			dev_info(&pf->pdev->dev, "not enough queues for DCB. DCB is disabled.\n");
 		}
 		pf->num_lan_qps = pf->rss_size_max;
@@ -8300,7 +8314,7 @@ static void i40e_print_features(struct i40e_pf *pf)
 		buf += sprintf(buf, "FD_SB ");
 		buf += sprintf(buf, "NTUPLE ");
 	}
-	if (pf->flags & I40E_FLAG_DCB_ENABLED)
+	if (pf->flags & I40E_FLAG_DCB_CAPABLE)
 		buf += sprintf(buf, "DCB ");
 	if (pf->flags & I40E_FLAG_PTP)
 		buf += sprintf(buf, "PTP ");
@@ -8486,7 +8500,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	err = i40e_init_pf_dcb(pf);
 	if (err) {
 		dev_info(&pdev->dev, "init_pf_dcb failed: %d\n", err);
-		pf->flags &= ~I40E_FLAG_DCB_ENABLED;
+		pf->flags &= ~I40E_FLAG_DCB_CAPABLE;
 		/* Continue without DCB enabled */
 	}
 #endif /* CONFIG_I40E_DCB */
-- 
1.9.3
