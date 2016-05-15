From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/13] i40e: Add allmulti support for the VF
Date: Sat, 14 May 2016 21:57:24 -0700
Message-ID: <1463288255-1654-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51923 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752046AbcEOE5i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2016 00:57:38 -0400
In-Reply-To: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

This patch enables a feature to enable/disable all multicast
for a trusted VF.

Change-Id: I926eba7f8850c8d40f8ad7e08bbe4056bbd3985f
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf.h          |  3 +++
 drivers/net/ethernet/intel/i40evf/i40evf_main.c     | 15 ++++++++++++++-
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c | 15 +++++++++++++--
 3 files changed, 30 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index fa044a9..76ed97d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -215,6 +215,7 @@ struct i40evf_adapter {
 #define I40EVF_FLAG_OUTER_UDP_CSUM_CAPABLE	BIT(12)
 #define I40EVF_FLAG_ADDR_SET_BY_PF		BIT(13)
 #define I40EVF_FLAG_PROMISC_ON			BIT(15)
+#define I40EVF_FLAG_ALLMULTI_ON			BIT(16)
 /* duplicates for common code */
 #define I40E_FLAG_FDIR_ATR_ENABLED		 0
 #define I40E_FLAG_DCB_ENABLED			 0
@@ -241,6 +242,8 @@ struct i40evf_adapter {
 #define I40EVF_FLAG_AQ_SET_RSS_LUT		BIT(14)
 #define I40EVF_FLAG_AQ_REQUEST_PROMISC		BIT(15)
 #define I40EVF_FLAG_AQ_RELEASE_PROMISC		BIT(16)
+#define I40EVF_FLAG_AQ_REQUEST_ALLMULTI		BIT(17)
+#define I40EVF_FLAG_AQ_RELEASE_ALLMULTI		BIT(18)
 
 	/* OS defined structs */
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index b548dbe..642bb45 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -934,6 +934,13 @@ bottom_of_search_loop:
 		 adapter->flags & I40EVF_FLAG_PROMISC_ON)
 		adapter->aq_required |= I40EVF_FLAG_AQ_RELEASE_PROMISC;
 
+	if (netdev->flags & IFF_ALLMULTI &&
+	    !(adapter->flags & I40EVF_FLAG_ALLMULTI_ON))
+		adapter->aq_required |= I40EVF_FLAG_AQ_REQUEST_ALLMULTI;
+	else if (!(netdev->flags & IFF_ALLMULTI) &&
+		 adapter->flags & I40EVF_FLAG_ALLMULTI_ON)
+		adapter->aq_required |= I40EVF_FLAG_AQ_RELEASE_ALLMULTI;
+
 	clear_bit(__I40EVF_IN_CRITICAL_TASK, &adapter->crit_section);
 }
 
@@ -1612,7 +1619,13 @@ static void i40evf_watchdog_task(struct work_struct *work)
 		goto watchdog_done;
 	}
 
-	if (adapter->aq_required & I40EVF_FLAG_AQ_RELEASE_PROMISC) {
+	if (adapter->aq_required & I40EVF_FLAG_AQ_REQUEST_ALLMULTI) {
+		i40evf_set_promiscuous(adapter, I40E_FLAG_VF_MULTICAST_PROMISC);
+		goto watchdog_done;
+	}
+
+	if ((adapter->aq_required & I40EVF_FLAG_AQ_RELEASE_PROMISC) &&
+	    (adapter->aq_required & I40EVF_FLAG_AQ_RELEASE_ALLMULTI)) {
 		i40evf_set_promiscuous(adapter, 0);
 		goto watchdog_done;
 	}
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index c5d33a2..f134456 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -641,6 +641,7 @@ void i40evf_del_vlans(struct i40evf_adapter *adapter)
 void i40evf_set_promiscuous(struct i40evf_adapter *adapter, int flags)
 {
 	struct i40e_virtchnl_promisc_info vpi;
+	int promisc_all;
 
 	if (adapter->current_op != I40E_VIRTCHNL_OP_UNKNOWN) {
 		/* bail because we already have a command pending */
@@ -649,11 +650,21 @@ void i40evf_set_promiscuous(struct i40evf_adapter *adapter, int flags)
 		return;
 	}
 
-	if (flags) {
+	promisc_all = I40E_FLAG_VF_UNICAST_PROMISC |
+		      I40E_FLAG_VF_MULTICAST_PROMISC;
+	if ((flags & promisc_all) == promisc_all) {
 		adapter->flags |= I40EVF_FLAG_PROMISC_ON;
 		adapter->aq_required &= ~I40EVF_FLAG_AQ_REQUEST_PROMISC;
 		dev_info(&adapter->pdev->dev, "Entering promiscuous mode\n");
-	} else {
+	}
+
+	if (flags & I40E_FLAG_VF_MULTICAST_PROMISC) {
+		adapter->flags |= I40EVF_FLAG_ALLMULTI_ON;
+		adapter->aq_required &= ~I40EVF_FLAG_AQ_REQUEST_ALLMULTI;
+		dev_info(&adapter->pdev->dev, "Entering multicast promiscuous mode\n");
+	}
+
+	if (!flags) {
 		adapter->flags &= ~I40EVF_FLAG_PROMISC_ON;
 		adapter->aq_required &= ~I40EVF_FLAG_AQ_RELEASE_PROMISC;
 		dev_info(&adapter->pdev->dev, "Leaving promiscuous mode\n");
-- 
2.5.5
