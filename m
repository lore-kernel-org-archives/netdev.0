From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] i40e: Add method to keep track of current rxnfc settings
Date: Wed, 25 Feb 2015 00:58:28 -0800
Message-ID: <1424854720-18825-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424854720-18825-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:20292 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752338AbbBYI6p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 03:58:45 -0500
In-Reply-To: <1424854720-18825-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch adds a struct to the VSI struct to keep track of rxnfc
settings done via ethtool.  Without this patch, the device can only
list the options available, not the current settings and this is not
clear to the user.  Without current settings, the available settings
never changing looks like a bug.

Also update the copyright year.

Change-ID: I087bbfdb33b330496a671630a7586773e3b3e589
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         | 5 ++++-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 8 ++++++++
 2 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 5912fdf..3ee730d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
  *
  * Intel Ethernet Controller XL710 Family Linux Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+ * Copyright(c) 2013 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -505,6 +505,9 @@ struct i40e_vsi {
 
 	/* VSI specific handlers */
 	irqreturn_t (*irq_handler)(int irq, void *data);
+
+	/* current rxnfc data */
+	struct ethtool_rxnfc rxnfc; /* current rss hash opts */
 } ____cacheline_internodealigned_in_smp;
 
 struct i40e_netdev_priv {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 5854460..5ef77dd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1741,6 +1741,11 @@ static int i40e_get_rss_hash_opts(struct i40e_pf *pf, struct ethtool_rxnfc *cmd)
 {
 	cmd->data = 0;
 
+	if (pf->vsi[pf->lan_vsi]->rxnfc.data != 0) {
+		cmd->data = pf->vsi[pf->lan_vsi]->rxnfc.data;
+		cmd->flow_type = pf->vsi[pf->lan_vsi]->rxnfc.flow_type;
+		return 0;
+	}
 	/* Report default options for RSS on i40e */
 	switch (cmd->flow_type) {
 	case TCP_V4_FLOW:
@@ -2012,6 +2017,9 @@ static int i40e_set_rss_hash_opt(struct i40e_pf *pf, struct ethtool_rxnfc *nfc)
 	wr32(hw, I40E_PFQF_HENA(1), (u32)(hena >> 32));
 	i40e_flush(hw);
 
+	/* Save setting for future output/update */
+	pf->vsi[pf->lan_vsi]->rxnfc = *nfc;
+
 	return 0;
 }
 
-- 
1.9.3
