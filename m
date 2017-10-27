From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [jkirsher/next-queue PATCH v5 5/6] i40e: Clean up of cloud filters
Date: Fri, 27 Oct 2017 02:35:56 -0700
Message-ID: <150909695619.48377.144660296731703103.stgit@anamdev.jf.intel.com>
References: <150909628755.48377.16561267691881106259.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, jiri@resnulli.us,
        amritha.nambiar@intel.com, netdev@vger.kernel.org,
        jhs@mojatatu.com, alexander.duyck@gmail.com,
        shannon.nelson@oracle.com, xiyou.wangcong@gmail.com
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41816 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752166AbdJ0Jhd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Oct 2017 05:37:33 -0400
In-Reply-To: <150909628755.48377.16561267691881106259.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce the cloud filter datastructure and cleanup of cloud
filters associated with the device.

v5: Fixed a typo.
v2: Moved field comments in struct i40e_cloud_filter to the right.
Removed hlist_empty check from i40e_cloud_filter_exit()

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |    9 +++++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c |   24 ++++++++++++++++++++++++
 2 files changed, 33 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index f3c501e..b938bb4a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -253,6 +253,12 @@ struct i40e_fdir_filter {
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
@@ -420,6 +426,9 @@ struct i40e_pf {
 	struct i40e_udp_port_config udp_ports[I40E_MAX_PF_UDP_OFFLOAD_PORTS];
 	u16 pending_udp_bitmap;
 
+	struct hlist_head cloud_filter_list;
+	u16 num_cloud_filters;
+
 	enum i40e_interrupt_policy int_policy;
 	u16 rx_itr_default;
 	u16 tx_itr_default;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 128f259..fbe3450 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6937,6 +6937,26 @@ static void i40e_fdir_filter_exit(struct i40e_pf *pf)
 }
 
 /**
+ * i40e_cloud_filter_exit - Cleans up the cloud filters
+ * @pf: Pointer to PF
+ *
+ * This function destroys the hlist where all the cloud filters
+ * were saved.
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
@@ -12196,6 +12216,7 @@ static int i40e_setup_pf_switch(struct i40e_pf *pf, bool reinit)
 			vsi = i40e_vsi_reinit_setup(pf->vsi[pf->lan_vsi]);
 		if (!vsi) {
 			dev_info(&pf->pdev->dev, "setup of MAIN VSI failed\n");
+			i40e_cloud_filter_exit(pf);
 			i40e_fdir_teardown(pf);
 			return -EAGAIN;
 		}
@@ -13030,6 +13051,8 @@ static void i40e_remove(struct pci_dev *pdev)
 	if (pf->vsi[pf->lan_vsi])
 		i40e_vsi_release(pf->vsi[pf->lan_vsi]);
 
+	i40e_cloud_filter_exit(pf);
+
 	/* remove attached clients */
 	if (pf->flags & I40E_FLAG_IWARP_ENABLED) {
 		ret_code = i40e_lan_del_device(pf);
@@ -13261,6 +13284,7 @@ static void i40e_shutdown(struct pci_dev *pdev)
 
 	del_timer_sync(&pf->service_timer);
 	cancel_work_sync(&pf->service_task);
+	i40e_cloud_filter_exit(pf);
 	i40e_fdir_teardown(pf);
 
 	/* Client close must be called explicitly here because the timer
