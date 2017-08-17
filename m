From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [RFC PATCH v2 5/6] [net-next]net: i40e: Clean up of cloud filters
Date: Thu, 17 Aug 2017 03:27:12 -0700
Message-ID: <150296563274.16910.10498393956826509184.stgit@anamdev.jf.intel.com>
References: <150296538797.16910.13738130623106637990.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, kiran.patil@intel.com,
        amritha.nambiar@intel.com, netdev@vger.kernel.org,
        mitch.a.williams@intel.com, alexander.duyck@gmail.com,
        neerav.parikh@intel.com, sridhar.samudrala@intel.com,
        carolyn.wyborny@intel.com
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:18737 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752172AbdHQK2E (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 06:28:04 -0400
In-Reply-To: <150296538797.16910.13738130623106637990.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce the cloud filter datastructure and cleanup of cloud
filters associated with the device.

v2: Moved field comments in struct i40e_cloud_filter to the right.
Removed hlist_empty check from i40e_cloud_filter_exit()

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |    9 +++++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c |   24 ++++++++++++++++++++++++
 2 files changed, 33 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 1391e5d..ac57ab0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -252,6 +252,12 @@ struct i40e_fdir_filter {
 	u32 fd_id;
 };
 
+struct i40e_cloud_filter {
+	struct hlist_node cloud_node;
+	unsigned long cookie;
+	u16 seid;	/* filter control */
+};
+
 #define I40E_ETH_P_LLDP			0x88cc
 
 #define I40E_DCB_PRIO_TYPE_STRICT	0
@@ -419,6 +425,9 @@ struct i40e_pf {
 	struct i40e_udp_port_config udp_ports[I40E_MAX_PF_UDP_OFFLOAD_PORTS];
 	u16 pending_udp_bitmap;
 
+	struct hlist_head cloud_filter_list;
+	u16 num_cloud_filters;
+
 	enum i40e_interrupt_policy int_policy;
 	u16 rx_itr_default;
 	u16 tx_itr_default;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e53d1be..15f0975 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6967,6 +6967,26 @@ static void i40e_fdir_filter_exit(struct i40e_pf *pf)
 }
 
 /**
+ * i40e_cloud_filter_exit - Cleans up the Cloud Filters
+ * @pf: Pointer to PF
+ *
+ * This function destroys the hlist where all the Cloud Filters
+ * filters were saved.
+ **/
+static void i40e_cloud_filter_exit(struct i40e_pf *pf)
+{
+	struct i40e_cloud_filter *cfilter;
+	struct hlist_node *node;
+
+	hlist_for_each_entry_safe(cfilter, node,
+				  &pf->cloud_filter_list, cloud_node) {
+		hlist_del(&cfilter->cloud_node);
+		kfree(cfilter);
+	}
+	pf->num_cloud_filters = 0;
+}
+
+/**
  * i40e_close - Disables a network interface
  * @netdev: network interface device structure
  *
@@ -12176,6 +12196,7 @@ static int i40e_setup_pf_switch(struct i40e_pf *pf, bool reinit)
 			vsi = i40e_vsi_reinit_setup(pf->vsi[pf->lan_vsi]);
 		if (!vsi) {
 			dev_info(&pf->pdev->dev, "setup of MAIN VSI failed\n");
+			i40e_cloud_filter_exit(pf);
 			i40e_fdir_teardown(pf);
 			return -EAGAIN;
 		}
@@ -13003,6 +13024,8 @@ static void i40e_remove(struct pci_dev *pdev)
 	if (pf->vsi[pf->lan_vsi])
 		i40e_vsi_release(pf->vsi[pf->lan_vsi]);
 
+	i40e_cloud_filter_exit(pf);
+
 	/* remove attached clients */
 	if (pf->flags & I40E_FLAG_IWARP_ENABLED) {
 		ret_code = i40e_lan_del_device(pf);
@@ -13212,6 +13235,7 @@ static void i40e_shutdown(struct pci_dev *pdev)
 
 	del_timer_sync(&pf->service_timer);
 	cancel_work_sync(&pf->service_task);
+	i40e_cloud_filter_exit(pf);
 	i40e_fdir_teardown(pf);
 
 	/* Client close must be called explicitly here because the timer
