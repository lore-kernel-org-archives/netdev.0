From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH 3/4 net-next] enic: add devcmd2 resources
Date: Sun, 16 Aug 2015 01:44:53 +0530
Message-ID: <1439669694-21744-4-git-send-email-_govind@gmx.com>
References: <1439669694-21744-1-git-send-email-_govind@gmx.com>
Cc: nalreddy@cisco.com, ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:56926 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753332AbbHOUPx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Aug 2015 16:15:53 -0400
In-Reply-To: <1439669694-21744-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add devcmd resources to vnic_res_type. Add data types used by devcmd.

Signed-off-by: N V V Satyanarayana Reddy <nalreddy@cisco.com>
Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/vnic_dev.h      |  1 +
 drivers/net/ethernet/cisco/enic/vnic_devcmd.h   | 23 +++++++++++++++++++++++
 drivers/net/ethernet/cisco/enic/vnic_resource.h |  7 +++++++
 drivers/net/ethernet/cisco/enic/vnic_wq.h       | 11 +++++++++++
 4 files changed, 42 insertions(+)

diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.h b/drivers/net/ethernet/cisco/enic/vnic_dev.h
index 90bca09..51aae05 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.h
@@ -107,6 +107,7 @@ struct vnic_dev {
 	u32 proxy_index;
 	u64 args[VNIC_DEVCMD_NARGS];
 	struct vnic_intr_coal_timer_info intr_coal_timer_info;
+	struct devcmd2_controller *devcmd2;
 };
 
 struct vnic_stats;
diff --git a/drivers/net/ethernet/cisco/enic/vnic_devcmd.h b/drivers/net/ethernet/cisco/enic/vnic_devcmd.h
index 435d0cd..09e8039 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_devcmd.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_devcmd.h
@@ -365,6 +365,12 @@ enum vnic_devcmd_cmd {
 	 */
 	CMD_PROV_INFO_UPDATE = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 56),
 
+	/* Initialization for the devcmd2 interface.
+	 * in: (u64) a0 = host result buffer physical address
+	 * in: (u16) a1 = number of entries in result buffer
+	 */
+	CMD_INITIALIZE_DEVCMD2 = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ALL, 57),
+
 	/* Add a filter.
 	 * in: (u64) a0= filter address
 	 *     (u32) a1= size of filter
@@ -629,4 +635,21 @@ struct vnic_devcmd {
 	u64 args[VNIC_DEVCMD_NARGS];	/* RW cmd args (little-endian) */
 };
 
+#define VNIC_DEVCMD2_NARGS	VNIC_DEVCMD_NARGS
+struct vnic_devcmd2 {
+	u16 pad;
+	u16 flags;
+	u32 cmd;
+	u64 args[VNIC_DEVCMD2_NARGS];
+};
+
+#define VNIC_DEVCMD2_NRESULTS	VNIC_DEVCMD_NARGS
+struct devcmd2_result {
+	u64 results[VNIC_DEVCMD2_NRESULTS];
+	u32 pad;
+	u16 completed_index;
+	u8  error;
+	u8  color;
+};
+
 #endif /* _VNIC_DEVCMD_H_ */
diff --git a/drivers/net/ethernet/cisco/enic/vnic_resource.h b/drivers/net/ethernet/cisco/enic/vnic_resource.h
index e0a73f1..4e45f88 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_resource.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_resource.h
@@ -48,6 +48,13 @@ enum vnic_res_type {
 	RES_TYPE_RSVD7,
 	RES_TYPE_DEVCMD,		/* Device command region */
 	RES_TYPE_PASS_THRU_PAGE,	/* Pass-thru page */
+	RES_TYPE_SUBVNIC,		/* subvnic resource type */
+	RES_TYPE_MQ_WQ,			/* MQ Work queues */
+	RES_TYPE_MQ_RQ,			/* MQ Receive queues */
+	RES_TYPE_MQ_CQ,			/* MQ Completion queues */
+	RES_TYPE_DEPRECATED1,		/* Old version of devcmd 2 */
+	RES_TYPE_DEPRECATED2,		/* Old version of devcmd 2 */
+	RES_TYPE_DEVCMD2,		/* Device control region */
 
 	RES_TYPE_MAX,			/* Count of resource types */
 };
diff --git a/drivers/net/ethernet/cisco/enic/vnic_wq.h b/drivers/net/ethernet/cisco/enic/vnic_wq.h
index 2961543..d5ea706 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_wq.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_wq.h
@@ -88,6 +88,17 @@ struct vnic_wq {
 	unsigned int pkts_outstanding;
 };
 
+struct devcmd2_controller {
+	struct vnic_wq_ctrl __iomem *wq_ctrl;
+	struct vnic_devcmd2 *cmd_ring;
+	struct devcmd2_result *result;
+	u16 next_result;
+	u16 result_size;
+	int color;
+	struct vnic_dev_ring results_ring;
+	struct vnic_wq wq;
+};
+
 static inline unsigned int vnic_wq_desc_avail(struct vnic_wq *wq)
 {
 	/* how many does SW own? */
-- 
2.5.0
