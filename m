From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 08/12] qed*: RSS indirection based on queue-handles
Date: Sun, 1 Jan 2017 13:57:07 +0200
Message-ID: <1483271831-25890-9-git-send-email-Yuval.Mintz@cavium.com>
References: <1483271831-25890-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:53888 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932128AbdAAL6X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:58:23 -0500
In-Reply-To: <1483271831-25890-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A step toward having qede agnostic to the queue configurations
in firmware/hardware - let the RSS indirections use queue handles
instead of actual queue indices.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c        | 232 +++++++++++++++---------
 drivers/net/ethernet/qlogic/qed/qed_l2.h        |  28 +--
 drivers/net/ethernet/qlogic/qed/qed_sriov.c     |  82 +++++----
 drivers/net/ethernet/qlogic/qed/qed_vf.c        |  12 +-
 drivers/net/ethernet/qlogic/qede/qede.h         |   6 +-
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c |  77 ++++----
 drivers/net/ethernet/qlogic/qede/qede_filter.c  |  92 ++++++++--
 drivers/net/ethernet/qlogic/qede/qede_main.c    | 126 +++++--------
 include/linux/qed/qed_eth_if.h                  |   2 +-
 9 files changed, 392 insertions(+), 265 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 03d31b3..a35db69 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -98,6 +98,7 @@ struct qed_queue_cid *
 	p_cid->cid = cid;
 	p_cid->vf_qid = vf_qid;
 	p_cid->rel = *p_params;
+	p_cid->p_owner = p_hwfn;
 
 	/* Don't try calculating the absolute indices for VFs */
 	if (IS_VF(p_hwfn->cdev)) {
@@ -272,76 +273,103 @@ static int qed_sp_vport_start(struct qed_hwfn *p_hwfn,
 static int
 qed_sp_vport_update_rss(struct qed_hwfn *p_hwfn,
 			struct vport_update_ramrod_data *p_ramrod,
-			struct qed_rss_params *p_params)
+			struct qed_rss_params *p_rss)
 {
-	struct eth_vport_rss_config *rss = &p_ramrod->rss_config;
-	u16 abs_l2_queue = 0, capabilities = 0;
-	int rc = 0, i;
+	struct eth_vport_rss_config *p_config;
+	u16 capabilities = 0;
+	int i, table_size;
+	int rc = 0;
 
-	if (!p_params) {
+	if (!p_rss) {
 		p_ramrod->common.update_rss_flg = 0;
 		return rc;
 	}
+	p_config = &p_ramrod->rss_config;
 
-	BUILD_BUG_ON(QED_RSS_IND_TABLE_SIZE !=
-		     ETH_RSS_IND_TABLE_ENTRIES_NUM);
+	BUILD_BUG_ON(QED_RSS_IND_TABLE_SIZE != ETH_RSS_IND_TABLE_ENTRIES_NUM);
 
-	rc = qed_fw_rss_eng(p_hwfn, p_params->rss_eng_id, &rss->rss_id);
+	rc = qed_fw_rss_eng(p_hwfn, p_rss->rss_eng_id, &p_config->rss_id);
 	if (rc)
 		return rc;
 
-	p_ramrod->common.update_rss_flg = p_params->update_rss_config;
-	rss->update_rss_capabilities = p_params->update_rss_capabilities;
-	rss->update_rss_ind_table = p_params->update_rss_ind_table;
-	rss->update_rss_key = p_params->update_rss_key;
+	p_ramrod->common.update_rss_flg = p_rss->update_rss_config;
+	p_config->update_rss_capabilities = p_rss->update_rss_capabilities;
+	p_config->update_rss_ind_table = p_rss->update_rss_ind_table;
+	p_config->update_rss_key = p_rss->update_rss_key;
 
-	rss->rss_mode = p_params->rss_enable ?
-			ETH_VPORT_RSS_MODE_REGULAR :
-			ETH_VPORT_RSS_MODE_DISABLED;
+	p_config->rss_mode = p_rss->rss_enable ?
+			     ETH_VPORT_RSS_MODE_REGULAR :
+			     ETH_VPORT_RSS_MODE_DISABLED;
 
 	SET_FIELD(capabilities,
 		  ETH_VPORT_RSS_CONFIG_IPV4_CAPABILITY,
-		  !!(p_params->rss_caps & QED_RSS_IPV4));
+		  !!(p_rss->rss_caps & QED_RSS_IPV4));
 	SET_FIELD(capabilities,
 		  ETH_VPORT_RSS_CONFIG_IPV6_CAPABILITY,
-		  !!(p_params->rss_caps & QED_RSS_IPV6));
+		  !!(p_rss->rss_caps & QED_RSS_IPV6));
 	SET_FIELD(capabilities,
 		  ETH_VPORT_RSS_CONFIG_IPV4_TCP_CAPABILITY,
-		  !!(p_params->rss_caps & QED_RSS_IPV4_TCP));
+		  !!(p_rss->rss_caps & QED_RSS_IPV4_TCP));
 	SET_FIELD(capabilities,
 		  ETH_VPORT_RSS_CONFIG_IPV6_TCP_CAPABILITY,
-		  !!(p_params->rss_caps & QED_RSS_IPV6_TCP));
+		  !!(p_rss->rss_caps & QED_RSS_IPV6_TCP));
 	SET_FIELD(capabilities,
 		  ETH_VPORT_RSS_CONFIG_IPV4_UDP_CAPABILITY,
-		  !!(p_params->rss_caps & QED_RSS_IPV4_UDP));
+		  !!(p_rss->rss_caps & QED_RSS_IPV4_UDP));
 	SET_FIELD(capabilities,
 		  ETH_VPORT_RSS_CONFIG_IPV6_UDP_CAPABILITY,
-		  !!(p_params->rss_caps & QED_RSS_IPV6_UDP));
-	rss->tbl_size = p_params->rss_table_size_log;
+		  !!(p_rss->rss_caps & QED_RSS_IPV6_UDP));
+	p_config->tbl_size = p_rss->rss_table_size_log;
 
-	rss->capabilities = cpu_to_le16(capabilities);
+	p_config->capabilities = cpu_to_le16(capabilities);
 
 	DP_VERBOSE(p_hwfn, NETIF_MSG_IFUP,
 		   "update rss flag %d, rss_mode = %d, update_caps = %d, capabilities = %d, update_ind = %d, update_rss_key = %d\n",
 		   p_ramrod->common.update_rss_flg,
-		   rss->rss_mode, rss->update_rss_capabilities,
-		   capabilities, rss->update_rss_ind_table,
-		   rss->update_rss_key);
+		   p_config->rss_mode,
+		   p_config->update_rss_capabilities,
+		   p_config->capabilities,
+		   p_config->update_rss_ind_table, p_config->update_rss_key);
 
-	for (i = 0; i < QED_RSS_IND_TABLE_SIZE; i++) {
-		rc = qed_fw_l2_queue(p_hwfn,
-				     (u8)p_params->rss_ind_table[i],
-				     &abs_l2_queue);
-		if (rc)
-			return rc;
+	table_size = min_t(int, QED_RSS_IND_TABLE_SIZE,
+			   1 << p_config->tbl_size);
+	for (i = 0; i < table_size; i++) {
+		struct qed_queue_cid *p_queue = p_rss->rss_ind_table[i];
 
-		rss->indirection_table[i] = cpu_to_le16(abs_l2_queue);
-		DP_VERBOSE(p_hwfn, NETIF_MSG_IFUP, "i= %d, queue = %d\n",
-			   i, rss->indirection_table[i]);
+		if (!p_queue)
+			return -EINVAL;
+
+		p_config->indirection_table[i] =
+		    cpu_to_le16(p_queue->abs.queue_id);
+	}
+
+	DP_VERBOSE(p_hwfn, NETIF_MSG_IFUP,
+		   "Configured RSS indirection table [%d entries]:\n",
+		   table_size);
+	for (i = 0; i < QED_RSS_IND_TABLE_SIZE; i += 0x10) {
+		DP_VERBOSE(p_hwfn,
+			   NETIF_MSG_IFUP,
+			   "%04x %04x %04x %04x %04x %04x %04x %04x %04x %04x %04x %04x %04x %04x %04x %04x\n",
+			   le16_to_cpu(p_config->indirection_table[i]),
+			   le16_to_cpu(p_config->indirection_table[i + 1]),
+			   le16_to_cpu(p_config->indirection_table[i + 2]),
+			   le16_to_cpu(p_config->indirection_table[i + 3]),
+			   le16_to_cpu(p_config->indirection_table[i + 4]),
+			   le16_to_cpu(p_config->indirection_table[i + 5]),
+			   le16_to_cpu(p_config->indirection_table[i + 6]),
+			   le16_to_cpu(p_config->indirection_table[i + 7]),
+			   le16_to_cpu(p_config->indirection_table[i + 8]),
+			   le16_to_cpu(p_config->indirection_table[i + 9]),
+			   le16_to_cpu(p_config->indirection_table[i + 10]),
+			   le16_to_cpu(p_config->indirection_table[i + 11]),
+			   le16_to_cpu(p_config->indirection_table[i + 12]),
+			   le16_to_cpu(p_config->indirection_table[i + 13]),
+			   le16_to_cpu(p_config->indirection_table[i + 14]),
+			   le16_to_cpu(p_config->indirection_table[i + 15]));
 	}
 
 	for (i = 0; i < 10; i++)
-		rss->rss_key[i] = cpu_to_le32(p_params->rss_key[i]);
+		p_config->rss_key[i] = cpu_to_le32(p_rss->rss_key[i]);
 
 	return rc;
 }
@@ -1899,18 +1927,84 @@ static int qed_stop_vport(struct qed_dev *cdev, u8 vport_id)
 	return 0;
 }
 
+static int qed_update_vport_rss(struct qed_dev *cdev,
+				struct qed_update_vport_rss_params *input,
+				struct qed_rss_params *rss)
+{
+	int i, fn;
+
+	/* Update configuration with what's correct regardless of CMT */
+	rss->update_rss_config = 1;
+	rss->rss_enable = 1;
+	rss->update_rss_capabilities = 1;
+	rss->update_rss_ind_table = 1;
+	rss->update_rss_key = 1;
+	rss->rss_caps = input->rss_caps;
+	memcpy(rss->rss_key, input->rss_key, QED_RSS_KEY_SIZE * sizeof(u32));
+
+	/* In regular scenario, we'd simply need to take input handlers.
+	 * But in CMT, we'd have to split the handlers according to the
+	 * engine they were configured on. We'd then have to understand
+	 * whether RSS is really required, since 2-queues on CMT doesn't
+	 * require RSS.
+	 */
+	if (cdev->num_hwfns == 1) {
+		memcpy(rss->rss_ind_table,
+		       input->rss_ind_table,
+		       QED_RSS_IND_TABLE_SIZE * sizeof(void *));
+		rss->rss_table_size_log = 7;
+		return 0;
+	}
+
+	/* Start by copying the non-spcific information to the 2nd copy */
+	memcpy(&rss[1], &rss[0], sizeof(struct qed_rss_params));
+
+	/* CMT should be round-robin */
+	for (i = 0; i < QED_RSS_IND_TABLE_SIZE; i++) {
+		struct qed_queue_cid *cid = input->rss_ind_table[i];
+		struct qed_rss_params *t_rss;
+
+		if (cid->p_owner == QED_LEADING_HWFN(cdev))
+			t_rss = &rss[0];
+		else
+			t_rss = &rss[1];
+
+		t_rss->rss_ind_table[i / cdev->num_hwfns] = cid;
+	}
+
+	/* Make sure RSS is actually required */
+	for_each_hwfn(cdev, fn) {
+		for (i = 1; i < QED_RSS_IND_TABLE_SIZE / cdev->num_hwfns; i++) {
+			if (rss[fn].rss_ind_table[i] !=
+			    rss[fn].rss_ind_table[0])
+				break;
+		}
+		if (i == QED_RSS_IND_TABLE_SIZE / cdev->num_hwfns) {
+			DP_VERBOSE(cdev, NETIF_MSG_IFUP,
+				   "CMT - 1 queue per-hwfn; Disabling RSS\n");
+			return -EINVAL;
+		}
+		rss[fn].rss_table_size_log = 6;
+	}
+
+	return 0;
+}
+
 static int qed_update_vport(struct qed_dev *cdev,
 			    struct qed_update_vport_params *params)
 {
 	struct qed_sp_vport_update_params sp_params;
-	struct qed_rss_params sp_rss_params;
-	int rc, i;
+	struct qed_rss_params *rss;
+	int rc = 0, i;
 
 	if (!cdev)
 		return -ENODEV;
 
+	rss = vzalloc(sizeof(*rss) * cdev->num_hwfns);
+	if (!rss)
+		return -ENOMEM;
+
 	memset(&sp_params, 0, sizeof(sp_params));
-	memset(&sp_rss_params, 0, sizeof(sp_rss_params));
 
 	/* Translate protocol params into sp params */
 	sp_params.vport_id = params->vport_id;
@@ -1924,66 +2018,24 @@ static int qed_update_vport(struct qed_dev *cdev,
 	sp_params.update_accept_any_vlan_flg =
 		params->update_accept_any_vlan_flg;
 
-	/* RSS - is a bit tricky, since upper-layer isn't familiar with hwfns.
-	 * We need to re-fix the rss values per engine for CMT.
-	 */
-	if (cdev->num_hwfns > 1 && params->update_rss_flg) {
-		struct qed_update_vport_rss_params *rss = &params->rss_params;
-		int k, max = 0;
-
-		/* Find largest entry, since it's possible RSS needs to
-		 * be disabled [in case only 1 queue per-hwfn]
-		 */
-		for (k = 0; k < QED_RSS_IND_TABLE_SIZE; k++)
-			max = (max > rss->rss_ind_table[k]) ?
-				max : rss->rss_ind_table[k];
-
-		/* Either fix RSS values or disable RSS */
-		if (cdev->num_hwfns < max + 1) {
-			int divisor = (max + cdev->num_hwfns - 1) /
-				cdev->num_hwfns;
-
-			DP_VERBOSE(cdev, (QED_MSG_SPQ | NETIF_MSG_IFUP),
-				   "CMT - fixing RSS values (modulo %02x)\n",
-				   divisor);
-
-			for (k = 0; k < QED_RSS_IND_TABLE_SIZE; k++)
-				rss->rss_ind_table[k] =
-					rss->rss_ind_table[k] % divisor;
-		} else {
-			DP_VERBOSE(cdev, (QED_MSG_SPQ | NETIF_MSG_IFUP),
-				   "CMT - 1 queue per-hwfn; Disabling RSS\n");
+	/* Prepare the RSS configuration */
+	if (params->update_rss_flg)
+		if (qed_update_vport_rss(cdev, &params->rss_params, rss))
 			params->update_rss_flg = 0;
-		}
-	}
-
-	/* Now, update the RSS configuration for actual configuration */
-	if (params->update_rss_flg) {
-		sp_rss_params.update_rss_config = 1;
-		sp_rss_params.rss_enable = 1;
-		sp_rss_params.update_rss_capabilities = 1;
-		sp_rss_params.update_rss_ind_table = 1;
-		sp_rss_params.update_rss_key = 1;
-		sp_rss_params.rss_caps = params->rss_params.rss_caps;
-		sp_rss_params.rss_table_size_log = 7; /* 2^7 = 128 */
-		memcpy(sp_rss_params.rss_ind_table,
-		       params->rss_params.rss_ind_table,
-		       QED_RSS_IND_TABLE_SIZE * sizeof(u16));
-		memcpy(sp_rss_params.rss_key, params->rss_params.rss_key,
-		       QED_RSS_KEY_SIZE * sizeof(u32));
-		sp_params.rss_params = &sp_rss_params;
-	}
 
 	for_each_hwfn(cdev, i) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
 
+		if (params->update_rss_flg)
+			sp_params.rss_params = &rss[i];
+
 		sp_params.opaque_fid = p_hwfn->hw_info.opaque_fid;
 		rc = qed_sp_vport_update(p_hwfn, &sp_params,
 					 QED_SPQ_MODE_EBLOCK,
 					 NULL);
 		if (rc) {
 			DP_ERR(cdev, "Failed to update VPORT\n");
-			return rc;
+			goto out;
 		}
 
 		DP_VERBOSE(cdev, (QED_MSG_SPQ | NETIF_MSG_IFUP),
@@ -1992,7 +2044,9 @@ static int qed_update_vport(struct qed_dev *cdev,
 			   params->update_vport_active_flg);
 	}
 
-	return 0;
+out:
+	vfree(rss);
+	return rc;
 }
 
 static int qed_start_rxq(struct qed_dev *cdev,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.h b/drivers/net/ethernet/qlogic/qed/qed_l2.h
index 2f03037..93cb932 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.h
@@ -39,6 +39,20 @@
 #include "qed.h"
 #include "qed_hw.h"
 #include "qed_sp.h"
+struct qed_rss_params {
+	u8 update_rss_config;
+	u8 rss_enable;
+	u8 rss_eng_id;
+	u8 update_rss_capabilities;
+	u8 update_rss_ind_table;
+	u8 update_rss_key;
+	u8 rss_caps;
+	u8 rss_table_size_log;
+
+	/* Indirection table consist of rx queue handles */
+	void *rss_ind_table[QED_RSS_IND_TABLE_SIZE];
+	u32 rss_key[QED_RSS_KEY_SIZE];
+};
 
 struct qed_sge_tpa_params {
 	u8 max_buffers_per_cqe;
@@ -156,18 +170,6 @@ struct qed_sp_vport_start_params {
 int qed_sp_eth_vport_start(struct qed_hwfn *p_hwfn,
 			   struct qed_sp_vport_start_params *p_params);
 
-struct qed_rss_params {
-	u8	update_rss_config;
-	u8	rss_enable;
-	u8	rss_eng_id;
-	u8	update_rss_capabilities;
-	u8	update_rss_ind_table;
-	u8	update_rss_key;
-	u8	rss_caps;
-	u8	rss_table_size_log;
-	u16	rss_ind_table[QED_RSS_IND_TABLE_SIZE];
-	u32	rss_key[QED_RSS_KEY_SIZE];
-};
 
 struct qed_filter_accept_flags {
 	u8	update_rx_mode_config;
@@ -287,6 +289,8 @@ struct qed_queue_cid {
 
 	/* Legacy VFs might have Rx producer located elsewhere */
 	bool b_legacy_vf;
+
+	struct qed_hwfn *p_owner;
 };
 
 void qed_eth_queue_cid_release(struct qed_hwfn *p_hwfn,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 469e857f5..b22baf5 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -32,6 +32,7 @@
 
 #include <linux/etherdevice.h>
 #include <linux/crc32.h>
+#include <linux/vmalloc.h>
 #include <linux/qed/qed_iov_if.h>
 #include "qed_cxt.h"
 #include "qed_hsi.h"
@@ -2318,12 +2319,14 @@ void *qed_iov_search_list_tlvs(struct qed_hwfn *p_hwfn,
 			    struct qed_vf_info *vf,
 			    struct qed_sp_vport_update_params *p_data,
 			    struct qed_rss_params *p_rss,
-			    struct qed_iov_vf_mbx *p_mbx, u16 *tlvs_mask)
+			    struct qed_iov_vf_mbx *p_mbx,
+			    u16 *tlvs_mask, u16 *tlvs_accepted)
 {
 	struct vfpf_vport_update_rss_tlv *p_rss_tlv;
 	u16 tlv = CHANNEL_TLV_VPORT_UPDATE_RSS;
-	u16 i, q_idx, max_q_idx;
+	bool b_reject = false;
 	u16 table_size;
+	u16 i, q_idx;
 
 	p_rss_tlv = (struct vfpf_vport_update_rss_tlv *)
 		    qed_iov_search_list_tlvs(p_hwfn, p_mbx->req_virt, tlv);
@@ -2347,34 +2350,39 @@ void *qed_iov_search_list_tlvs(struct qed_hwfn *p_hwfn,
 	p_rss->rss_eng_id = vf->relative_vf_id + 1;
 	p_rss->rss_caps = p_rss_tlv->rss_caps;
 	p_rss->rss_table_size_log = p_rss_tlv->rss_table_size_log;
-	memcpy(p_rss->rss_ind_table, p_rss_tlv->rss_ind_table,
-	       sizeof(p_rss->rss_ind_table));
 	memcpy(p_rss->rss_key, p_rss_tlv->rss_key, sizeof(p_rss->rss_key));
 
 	table_size = min_t(u16, ARRAY_SIZE(p_rss->rss_ind_table),
 			   (1 << p_rss_tlv->rss_table_size_log));
 
-	max_q_idx = ARRAY_SIZE(vf->vf_queues);
-
 	for (i = 0; i < table_size; i++) {
-		u16 index = vf->vf_queues[0].fw_rx_qid;
+		q_idx = p_rss_tlv->rss_ind_table[i];
+		if (!qed_iov_validate_rxq(p_hwfn, vf, q_idx)) {
+			DP_VERBOSE(p_hwfn,
+				   QED_MSG_IOV,
+				   "VF[%d]: Omitting RSS due to wrong queue %04x\n",
+				   vf->relative_vf_id, q_idx);
+			b_reject = true;
+			goto out;
+		}
 
-		q_idx = p_rss->rss_ind_table[i];
-		if (q_idx >= max_q_idx)
-			DP_NOTICE(p_hwfn,
-				  "rss_ind_table[%d] = %d, rxq is out of range\n",
-				  i, q_idx);
-		else if (!vf->vf_queues[q_idx].p_rx_cid)
-			DP_NOTICE(p_hwfn,
-				  "rss_ind_table[%d] = %d, rxq is not active\n",
-				  i, q_idx);
-		else
-			index = vf->vf_queues[q_idx].fw_rx_qid;
-		p_rss->rss_ind_table[i] = index;
+		if (!vf->vf_queues[q_idx].p_rx_cid) {
+			DP_VERBOSE(p_hwfn,
+				   QED_MSG_IOV,
+				   "VF[%d]: Omitting RSS due to inactive queue %08x\n",
+				   vf->relative_vf_id, q_idx);
+			b_reject = true;
+			goto out;
+		}
+
+		p_rss->rss_ind_table[i] = vf->vf_queues[q_idx].p_rx_cid;
 	}
 
 	p_data->rss_params = p_rss;
+out:
 	*tlvs_mask |= 1 << QED_IOV_VP_UPDATE_RSS;
+	if (!b_reject)
+		*tlvs_accepted |= 1 << QED_IOV_VP_UPDATE_RSS;
 }
 
 static void
@@ -2429,12 +2437,12 @@ static void qed_iov_vf_mbx_vport_update(struct qed_hwfn *p_hwfn,
 					struct qed_ptt *p_ptt,
 					struct qed_vf_info *vf)
 {
+	struct qed_rss_params *p_rss_params = NULL;
 	struct qed_sp_vport_update_params params;
 	struct qed_iov_vf_mbx *mbx = &vf->vf_mbx;
 	struct qed_sge_tpa_params sge_tpa_params;
-	struct qed_rss_params rss_params;
+	u16 tlvs_mask = 0, tlvs_accepted = 0;
 	u8 status = PFVF_STATUS_SUCCESS;
-	u16 tlvs_mask = 0;
 	u16 length;
 	int rc;
 
@@ -2447,6 +2455,11 @@ static void qed_iov_vf_mbx_vport_update(struct qed_hwfn *p_hwfn,
 		status = PFVF_STATUS_FAILURE;
 		goto out;
 	}
+	p_rss_params = vzalloc(sizeof(*p_rss_params));
+	if (p_rss_params == NULL) {
+		status = PFVF_STATUS_FAILURE;
+		goto out;
+	}
 
 	memset(&params, 0, sizeof(params));
 	params.opaque_fid = vf->opaque_fid;
@@ -2461,20 +2474,26 @@ static void qed_iov_vf_mbx_vport_update(struct qed_hwfn *p_hwfn,
 	qed_iov_vp_update_tx_switch(p_hwfn, &params, mbx, &tlvs_mask);
 	qed_iov_vp_update_mcast_bin_param(p_hwfn, &params, mbx, &tlvs_mask);
 	qed_iov_vp_update_accept_flag(p_hwfn, &params, mbx, &tlvs_mask);
-	qed_iov_vp_update_rss_param(p_hwfn, vf, &params, &rss_params,
-				    mbx, &tlvs_mask);
 	qed_iov_vp_update_accept_any_vlan(p_hwfn, &params, mbx, &tlvs_mask);
 	qed_iov_vp_update_sge_tpa_param(p_hwfn, vf, &params,
 					&sge_tpa_params, mbx, &tlvs_mask);
 
-	/* Just log a message if there is no single extended tlv in buffer.
-	 * When all features of vport update ramrod would be requested by VF
-	 * as extended TLVs in buffer then an error can be returned in response
-	 * if there is no extended TLV present in buffer.
+	tlvs_accepted = tlvs_mask;
+
+	/* Some of the extended TLVs need to be validated first; In that case,
+	 * they can update the mask without updating the accepted [so that
+	 * PF could communicate to VF it has rejected request].
 	 */
-	if (!tlvs_mask) {
-		DP_NOTICE(p_hwfn,
-			  "No feature tlvs found for vport update\n");
+	qed_iov_vp_update_rss_param(p_hwfn, vf, &params, p_rss_params,
+				    mbx, &tlvs_mask, &tlvs_accepted);
+
+	if (!tlvs_accepted) {
+		if (tlvs_mask)
+			DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+				   "Upper-layer prevents VF vport configuration\n");
+		else
+			DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+				   "No feature tlvs found for vport update\n");
 		status = PFVF_STATUS_NOT_SUPPORTED;
 		goto out;
 	}
@@ -2485,8 +2504,9 @@ static void qed_iov_vf_mbx_vport_update(struct qed_hwfn *p_hwfn,
 		status = PFVF_STATUS_FAILURE;
 
 out:
+	vfree(p_rss_params);
 	length = qed_iov_prep_vp_update_resp_tlvs(p_hwfn, vf, mbx, status,
-						  tlvs_mask, tlvs_mask);
+						  tlvs_mask, tlvs_accepted);
 	qed_iov_send_response(p_hwfn, p_ptt, vf, length, status);
 }
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.c b/drivers/net/ethernet/qlogic/qed/qed_vf.c
index af0542c..9667059 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.c
@@ -838,6 +838,7 @@ int qed_vf_pf_vport_update(struct qed_hwfn *p_hwfn,
 	if (p_params->rss_params) {
 		struct qed_rss_params *rss_params = p_params->rss_params;
 		struct vfpf_vport_update_rss_tlv *p_rss_tlv;
+		int i, table_size;
 
 		size = sizeof(struct vfpf_vport_update_rss_tlv);
 		p_rss_tlv = qed_add_tlv(p_hwfn,
@@ -860,8 +861,15 @@ int qed_vf_pf_vport_update(struct qed_hwfn *p_hwfn,
 		p_rss_tlv->rss_enable = rss_params->rss_enable;
 		p_rss_tlv->rss_caps = rss_params->rss_caps;
 		p_rss_tlv->rss_table_size_log = rss_params->rss_table_size_log;
-		memcpy(p_rss_tlv->rss_ind_table, rss_params->rss_ind_table,
-		       sizeof(rss_params->rss_ind_table));
+
+		table_size = min_t(int, T_ETH_INDIRECTION_TABLE_SIZE,
+				   1 << p_rss_tlv->rss_table_size_log);
+		for (i = 0; i < table_size; i++) {
+			struct qed_queue_cid *p_queue;
+
+			p_queue = rss_params->rss_ind_table[i];
+			p_rss_tlv->rss_ind_table[i] = p_queue->rel.queue_id;
+		}
 		memcpy(p_rss_tlv->rss_key, rss_params->rss_key,
 		       sizeof(rss_params->rss_key));
 	}
diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 1c5aac4..f4e9423 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -164,6 +164,7 @@ struct qede_dev {
 	u16				num_queues;
 #define QEDE_QUEUE_CNT(edev)	((edev)->num_queues)
 #define QEDE_RSS_COUNT(edev)	((edev)->num_queues - (edev)->fp_num_tx)
+#define QEDE_RX_QUEUE_IDX(edev, i)	(i)
 #define QEDE_TSS_COUNT(edev)	((edev)->num_queues - (edev)->fp_num_rx)
 
 	struct qed_int_info		int_info;
@@ -194,7 +195,10 @@ struct qede_dev {
 #define QEDE_RSS_KEY_INITED	BIT(1)
 #define QEDE_RSS_CAPS_INITED	BIT(2)
 	u32 rss_params_inited; /* bit-field to track initialized rss params */
-	struct qed_update_vport_rss_params	rss_params;
+	u16 rss_ind_table[128];
+	u32 rss_key[10];
+	u8 rss_caps;
+
 	u16			q_num_rx_buffers; /* Must be a power of two */
 	u16			q_num_tx_buffers; /* Must be a power of two */
 
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 8e971b2..baf2642 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -37,6 +37,7 @@
 #include <linux/string.h>
 #include <linux/pci.h>
 #include <linux/capability.h>
+#include <linux/vmalloc.h>
 #include "qede.h"
 
 #define QEDE_RQSTAT_OFFSET(stat_name) \
@@ -931,8 +932,7 @@ static int qede_set_channels(struct net_device *dev,
 	/* Reset the indirection table if rx queue count is updated */
 	if ((edev->req_queues - edev->req_num_tx) != QEDE_RSS_COUNT(edev)) {
 		edev->rss_params_inited &= ~QEDE_RSS_INDIR_INITED;
-		memset(&edev->rss_params.rss_ind_table, 0,
-		       sizeof(edev->rss_params.rss_ind_table));
+		memset(edev->rss_ind_table, 0, sizeof(edev->rss_ind_table));
 	}
 
 	qede_reload(edev, NULL, false);
@@ -978,11 +978,11 @@ static int qede_get_rss_flags(struct qede_dev *edev, struct ethtool_rxnfc *info)
 		info->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
 		break;
 	case UDP_V4_FLOW:
-		if (edev->rss_params.rss_caps & QED_RSS_IPV4_UDP)
+		if (edev->rss_caps & QED_RSS_IPV4_UDP)
 			info->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
 		break;
 	case UDP_V6_FLOW:
-		if (edev->rss_params.rss_caps & QED_RSS_IPV6_UDP)
+		if (edev->rss_caps & QED_RSS_IPV6_UDP)
 			info->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
 		break;
 	case IPV4_FLOW:
@@ -1015,8 +1015,9 @@ static int qede_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
 
 static int qede_set_rss_flags(struct qede_dev *edev, struct ethtool_rxnfc *info)
 {
-	struct qed_update_vport_params vport_update_params;
+	struct qed_update_vport_params *vport_update_params;
 	u8 set_caps = 0, clr_caps = 0;
+	int rc = 0;
 
 	DP_VERBOSE(edev, QED_MSG_DEBUG,
 		   "Set rss flags command parameters: flow type = %d, data = %llu\n",
@@ -1091,27 +1092,29 @@ static int qede_set_rss_flags(struct qede_dev *edev, struct ethtool_rxnfc *info)
 	}
 
 	/* No action is needed if there is no change in the rss capability */
-	if (edev->rss_params.rss_caps == ((edev->rss_params.rss_caps &
-					   ~clr_caps) | set_caps))
+	if (edev->rss_caps == ((edev->rss_caps & ~clr_caps) | set_caps))
 		return 0;
 
 	/* Update internal configuration */
-	edev->rss_params.rss_caps = (edev->rss_params.rss_caps & ~clr_caps) |
-				    set_caps;
+	edev->rss_caps = ((edev->rss_caps & ~clr_caps) | set_caps);
 	edev->rss_params_inited |= QEDE_RSS_CAPS_INITED;
 
 	/* Re-configure if possible */
-	if (netif_running(edev->ndev)) {
-		memset(&vport_update_params, 0, sizeof(vport_update_params));
-		vport_update_params.update_rss_flg = 1;
-		vport_update_params.vport_id = 0;
-		memcpy(&vport_update_params.rss_params, &edev->rss_params,
-		       sizeof(vport_update_params.rss_params));
-		return edev->ops->vport_update(edev->cdev,
-					       &vport_update_params);
+	__qede_lock(edev);
+	if (edev->state == QEDE_STATE_OPEN) {
+		vport_update_params = vzalloc(sizeof(*vport_update_params));
+		if (!vport_update_params) {
+			__qede_unlock(edev);
+			return -ENOMEM;
+		}
+		qede_fill_rss_params(edev, &vport_update_params->rss_params,
+				     &vport_update_params->update_rss_flg);
+		rc = edev->ops->vport_update(edev->cdev, vport_update_params);
+		vfree(vport_update_params);
 	}
+	__qede_unlock(edev);
 
-	return 0;
+	return rc;
 }
 
 static int qede_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info)
@@ -1136,7 +1139,7 @@ static u32 qede_get_rxfh_key_size(struct net_device *dev)
 {
 	struct qede_dev *edev = netdev_priv(dev);
 
-	return sizeof(edev->rss_params.rss_key);
+	return sizeof(edev->rss_key);
 }
 
 static int qede_get_rxfh(struct net_device *dev, u32 *indir, u8 *key, u8 *hfunc)
@@ -1151,11 +1154,10 @@ static int qede_get_rxfh(struct net_device *dev, u32 *indir, u8 *key, u8 *hfunc)
 		return 0;
 
 	for (i = 0; i < QED_RSS_IND_TABLE_SIZE; i++)
-		indir[i] = edev->rss_params.rss_ind_table[i];
+		indir[i] = edev->rss_ind_table[i];
 
 	if (key)
-		memcpy(key, edev->rss_params.rss_key,
-		       qede_get_rxfh_key_size(dev));
+		memcpy(key, edev->rss_key, qede_get_rxfh_key_size(dev));
 
 	return 0;
 }
@@ -1163,9 +1165,9 @@ static int qede_get_rxfh(struct net_device *dev, u32 *indir, u8 *key, u8 *hfunc)
 static int qede_set_rxfh(struct net_device *dev, const u32 *indir,
 			 const u8 *key, const u8 hfunc)
 {
-	struct qed_update_vport_params vport_update_params;
+	struct qed_update_vport_params *vport_update_params;
 	struct qede_dev *edev = netdev_priv(dev);
-	int i;
+	int i, rc = 0;
 
 	if (edev->dev_info.common.num_hwfns > 1) {
 		DP_INFO(edev,
@@ -1181,27 +1183,30 @@ static int qede_set_rxfh(struct net_device *dev, const u32 *indir,
 
 	if (indir) {
 		for (i = 0; i < QED_RSS_IND_TABLE_SIZE; i++)
-			edev->rss_params.rss_ind_table[i] = indir[i];
+			edev->rss_ind_table[i] = indir[i];
 		edev->rss_params_inited |= QEDE_RSS_INDIR_INITED;
 	}
 
 	if (key) {
-		memcpy(&edev->rss_params.rss_key, key,
-		       qede_get_rxfh_key_size(dev));
+		memcpy(&edev->rss_key, key, qede_get_rxfh_key_size(dev));
 		edev->rss_params_inited |= QEDE_RSS_KEY_INITED;
 	}
 
-	if (netif_running(edev->ndev)) {
-		memset(&vport_update_params, 0, sizeof(vport_update_params));
-		vport_update_params.update_rss_flg = 1;
-		vport_update_params.vport_id = 0;
-		memcpy(&vport_update_params.rss_params, &edev->rss_params,
-		       sizeof(vport_update_params.rss_params));
-		return edev->ops->vport_update(edev->cdev,
-					       &vport_update_params);
+	__qede_lock(edev);
+	if (edev->state == QEDE_STATE_OPEN) {
+		vport_update_params = vzalloc(sizeof(*vport_update_params));
+		if (!vport_update_params) {
+			__qede_unlock(edev);
+			return -ENOMEM;
+		}
+		qede_fill_rss_params(edev, &vport_update_params->rss_params,
+				     &vport_update_params->update_rss_flg);
+		rc = edev->ops->vport_update(edev->cdev, vport_update_params);
+		vfree(vport_update_params);
 	}
+	__qede_unlock(edev);
 
-	return 0;
+	return rc;
 }
 
 /* This function enables the interrupt generation and the NAPI on the device */
diff --git a/drivers/net/ethernet/qlogic/qede/qede_filter.c b/drivers/net/ethernet/qlogic/qede/qede_filter.c
index 6161e09..03e2a81 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_filter.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_filter.c
@@ -33,6 +33,7 @@
 #include <linux/etherdevice.h>
 #include <net/udp_tunnel.h>
 #include <linux/bitops.h>
+#include <linux/vmalloc.h>
 
 #include <linux/qed/qed_if.h>
 #include "qede.h"
@@ -49,6 +50,60 @@ void qede_force_mac(void *dev, u8 *mac, bool forced)
 	ether_addr_copy(edev->primary_mac, mac);
 }
 
+void qede_fill_rss_params(struct qede_dev *edev,
+			  struct qed_update_vport_rss_params *rss, u8 *update)
+{
+	bool need_reset = false;
+	int i;
+
+	if (QEDE_RSS_COUNT(edev) <= 1) {
+		memset(rss, 0, sizeof(*rss));
+		*update = 0;
+		return;
+	}
+
+	/* Need to validate current RSS config uses valid entries */
+	for (i = 0; i < QED_RSS_IND_TABLE_SIZE; i++) {
+		if (edev->rss_ind_table[i] >= QEDE_RSS_COUNT(edev)) {
+			need_reset = true;
+			break;
+		}
+	}
+
+	if (!(edev->rss_params_inited & QEDE_RSS_INDIR_INITED) || need_reset) {
+		for (i = 0; i < QED_RSS_IND_TABLE_SIZE; i++) {
+			u16 indir_val, val;
+
+			val = QEDE_RSS_COUNT(edev);
+			indir_val = ethtool_rxfh_indir_default(i, val);
+			edev->rss_ind_table[i] = indir_val;
+		}
+		edev->rss_params_inited |= QEDE_RSS_INDIR_INITED;
+	}
+
+	/* Now that we have the queue-indirection, prepare the handles */
+	for (i = 0; i < QED_RSS_IND_TABLE_SIZE; i++) {
+		u16 idx = QEDE_RX_QUEUE_IDX(edev, edev->rss_ind_table[i]);
+
+		rss->rss_ind_table[i] = edev->fp_array[idx].rxq->handle;
+	}
+
+	if (!(edev->rss_params_inited & QEDE_RSS_KEY_INITED)) {
+		netdev_rss_key_fill(edev->rss_key, sizeof(edev->rss_key));
+		edev->rss_params_inited |= QEDE_RSS_KEY_INITED;
+	}
+	memcpy(rss->rss_key, edev->rss_key, sizeof(rss->rss_key));
+
+	if (!(edev->rss_params_inited & QEDE_RSS_CAPS_INITED)) {
+		edev->rss_caps = QED_RSS_IPV4 | QED_RSS_IPV6 |
+		    QED_RSS_IPV4_TCP | QED_RSS_IPV6_TCP;
+		edev->rss_params_inited |= QEDE_RSS_CAPS_INITED;
+	}
+	rss->rss_caps = edev->rss_caps;
+
+	*update = 1;
+}
+
 static int qede_set_ucast_rx_mac(struct qede_dev *edev,
 				 enum qed_filter_xcast_params_type opcode,
 				 unsigned char mac[ETH_ALEN])
@@ -79,22 +134,24 @@ static int qede_set_ucast_rx_vlan(struct qede_dev *edev,
 	return edev->ops->filter_config(edev->cdev, &filter_cmd);
 }
 
-static void qede_config_accept_any_vlan(struct qede_dev *edev, bool action)
+static int qede_config_accept_any_vlan(struct qede_dev *edev, bool action)
 {
-	struct qed_update_vport_params params;
+	struct qed_update_vport_params *params;
 	int rc;
 
 	/* Proceed only if action actually needs to be performed */
 	if (edev->accept_any_vlan == action)
-		return;
+		return 0;
 
-	memset(&params, 0, sizeof(params));
+	params = vzalloc(sizeof(*params));
+	if (!params)
+		return -ENOMEM;
 
-	params.vport_id = 0;
-	params.accept_any_vlan = action;
-	params.update_accept_any_vlan_flg = 1;
+	params->vport_id = 0;
+	params->accept_any_vlan = action;
+	params->update_accept_any_vlan_flg = 1;
 
-	rc = edev->ops->vport_update(edev->cdev, &params);
+	rc = edev->ops->vport_update(edev->cdev, params);
 	if (rc) {
 		DP_ERR(edev, "Failed to %s accept-any-vlan\n",
 		       action ? "enable" : "disable");
@@ -103,6 +160,9 @@ static void qede_config_accept_any_vlan(struct qede_dev *edev, bool action)
 			action ? "enabled" : "disabled");
 		edev->accept_any_vlan = action;
 	}
+
+	vfree(params);
+	return 0;
 }
 
 int qede_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
@@ -166,8 +226,13 @@ int qede_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
 			edev->configured_vlans++;
 	} else {
 		/* Out of quota; Activate accept-any-VLAN mode */
-		if (!edev->non_configured_vlans)
-			qede_config_accept_any_vlan(edev, true);
+		if (!edev->non_configured_vlans) {
+			rc = qede_config_accept_any_vlan(edev, true);
+			if (rc) {
+				kfree(vlan);
+				goto out;
+			}
+		}
 
 		edev->non_configured_vlans++;
 	}
@@ -242,9 +307,12 @@ int qede_configure_vlan_filters(struct qede_dev *edev)
 	 */
 
 	if (accept_any_vlan)
-		qede_config_accept_any_vlan(edev, true);
+		rc = qede_config_accept_any_vlan(edev, true);
 	else if (!edev->non_configured_vlans)
-		qede_config_accept_any_vlan(edev, false);
+		rc = qede_config_accept_any_vlan(edev, false);
+
+	if (rc && !real_rc)
+		real_rc = rc;
 
 	return real_rc;
 }
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index be4121c..88d47d6 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -59,6 +59,7 @@
 #include <linux/random.h>
 #include <net/ip6_checksum.h>
 #include <linux/bitops.h>
+#include <linux/vmalloc.h>
 #include <linux/qed/qede_roce.h>
 #include "qede.h"
 
@@ -177,8 +178,12 @@ static int qede_sriov_configure(struct pci_dev *pdev, int num_vfs_param)
 {
 	struct qede_dev *edev = netdev_priv(pci_get_drvdata(pdev));
 	struct qed_dev_info *qed_info = &edev->dev_info.common;
+	struct qed_update_vport_params *vport_params;
 	int rc;
 
+	vport_params = vzalloc(sizeof(*vport_params));
+	if (!vport_params)
+		return -ENOMEM;
 	DP_VERBOSE(edev, QED_MSG_IOV, "Requested %d VFs\n", num_vfs_param);
 
 	rc = edev->ops->iov->configure(edev->cdev, num_vfs_param);
@@ -186,15 +191,13 @@ static int qede_sriov_configure(struct pci_dev *pdev, int num_vfs_param)
 	/* Enable/Disable Tx switching for PF */
 	if ((rc == num_vfs_param) && netif_running(edev->ndev) &&
 	    qed_info->mf_mode != QED_MF_NPAR && qed_info->tx_switching) {
-		struct qed_update_vport_params params;
-
-		memset(&params, 0, sizeof(params));
-		params.vport_id = 0;
-		params.update_tx_switching_flg = 1;
-		params.tx_switching_flg = num_vfs_param ? 1 : 0;
-		edev->ops->vport_update(edev->cdev, &params);
+		vport_params->vport_id = 0;
+		vport_params->update_tx_switching_flg = 1;
+		vport_params->tx_switching_flg = num_vfs_param ? 1 : 0;
+		edev->ops->vport_update(edev->cdev, vport_params);
 	}
 
+	vfree(vport_params);
 	return rc;
 }
 #endif
@@ -1504,19 +1507,24 @@ static int qede_stop_txq(struct qede_dev *edev,
 
 static int qede_stop_queues(struct qede_dev *edev)
 {
-	struct qed_update_vport_params vport_update_params;
+	struct qed_update_vport_params *vport_update_params;
 	struct qed_dev *cdev = edev->cdev;
 	struct qede_fastpath *fp;
 	int rc, i;
 
 	/* Disable the vport */
-	memset(&vport_update_params, 0, sizeof(vport_update_params));
-	vport_update_params.vport_id = 0;
-	vport_update_params.update_vport_active_flg = 1;
-	vport_update_params.vport_active_flg = 0;
-	vport_update_params.update_rss_flg = 0;
+	vport_update_params = vzalloc(sizeof(*vport_update_params));
+	if (!vport_update_params)
+		return -ENOMEM;
+
+	vport_update_params->vport_id = 0;
+	vport_update_params->update_vport_active_flg = 1;
+	vport_update_params->vport_active_flg = 0;
+	vport_update_params->update_rss_flg = 0;
+
+	rc = edev->ops->vport_update(cdev, vport_update_params);
+	vfree(vport_update_params);
 
-	rc = edev->ops->vport_update(cdev, &vport_update_params);
 	if (rc) {
 		DP_ERR(edev, "Failed to update vport\n");
 		return rc;
@@ -1628,11 +1636,10 @@ static int qede_start_queues(struct qede_dev *edev, bool clear_stats)
 {
 	int vlan_removal_en = 1;
 	struct qed_dev *cdev = edev->cdev;
-	struct qed_update_vport_params vport_update_params;
-	struct qed_queue_start_common_params q_params;
 	struct qed_dev_info *qed_info = &edev->dev_info.common;
+	struct qed_update_vport_params *vport_update_params;
+	struct qed_queue_start_common_params q_params;
 	struct qed_start_vport_params start = {0};
-	bool reset_rss_indir = false;
 	int rc, i;
 
 	if (!edev->num_queues) {
@@ -1641,6 +1648,10 @@ static int qede_start_queues(struct qede_dev *edev, bool clear_stats)
 		return -EINVAL;
 	}
 
+	vport_update_params = vzalloc(sizeof(*vport_update_params));
+	if (!vport_update_params)
+		return -ENOMEM;
+
 	start.gro_enable = !edev->gro_disable;
 	start.mtu = edev->ndev->mtu;
 	start.vport_id = 0;
@@ -1652,7 +1663,7 @@ static int qede_start_queues(struct qede_dev *edev, bool clear_stats)
 
 	if (rc) {
 		DP_ERR(edev, "Start V-PORT failed %d\n", rc);
-		return rc;
+		goto out;
 	}
 
 	DP_VERBOSE(edev, NETIF_MSG_IFUP,
@@ -1688,7 +1699,7 @@ static int qede_start_queues(struct qede_dev *edev, bool clear_stats)
 			if (rc) {
 				DP_ERR(edev, "Start RXQ #%d failed %d\n", i,
 				       rc);
-				return rc;
+				goto out;
 			}
 
 			/* Use the return parameters */
@@ -1704,93 +1715,46 @@ static int qede_start_queues(struct qede_dev *edev, bool clear_stats)
 		if (fp->type & QEDE_FASTPATH_XDP) {
 			rc = qede_start_txq(edev, fp, fp->xdp_tx, i, XDP_PI);
 			if (rc)
-				return rc;
+				goto out;
 
 			fp->rxq->xdp_prog = bpf_prog_add(edev->xdp_prog, 1);
 			if (IS_ERR(fp->rxq->xdp_prog)) {
 				rc = PTR_ERR(fp->rxq->xdp_prog);
 				fp->rxq->xdp_prog = NULL;
-				return rc;
+				goto out;
 			}
 		}
 
 		if (fp->type & QEDE_FASTPATH_TX) {
 			rc = qede_start_txq(edev, fp, fp->txq, i, TX_PI(0));
 			if (rc)
-				return rc;
+				goto out;
 		}
 	}
 
 	/* Prepare and send the vport enable */
-	memset(&vport_update_params, 0, sizeof(vport_update_params));
-	vport_update_params.vport_id = start.vport_id;
-	vport_update_params.update_vport_active_flg = 1;
-	vport_update_params.vport_active_flg = 1;
+	vport_update_params->vport_id = start.vport_id;
+	vport_update_params->update_vport_active_flg = 1;
+	vport_update_params->vport_active_flg = 1;
 
 	if ((qed_info->mf_mode == QED_MF_NPAR || pci_num_vf(edev->pdev)) &&
 	    qed_info->tx_switching) {
-		vport_update_params.update_tx_switching_flg = 1;
-		vport_update_params.tx_switching_flg = 1;
+		vport_update_params->update_tx_switching_flg = 1;
+		vport_update_params->tx_switching_flg = 1;
 	}
 
-	/* Fill struct with RSS params */
-	if (QEDE_RSS_COUNT(edev) > 1) {
-		vport_update_params.update_rss_flg = 1;
-
-		/* Need to validate current RSS config uses valid entries */
-		for (i = 0; i < QED_RSS_IND_TABLE_SIZE; i++) {
-			if (edev->rss_params.rss_ind_table[i] >=
-			    QEDE_RSS_COUNT(edev)) {
-				reset_rss_indir = true;
-				break;
-			}
-		}
-
-		if (!(edev->rss_params_inited & QEDE_RSS_INDIR_INITED) ||
-		    reset_rss_indir) {
-			u16 val;
+	qede_fill_rss_params(edev, &vport_update_params->rss_params,
+			     &vport_update_params->update_rss_flg);
 
-			for (i = 0; i < QED_RSS_IND_TABLE_SIZE; i++) {
-				u16 indir_val;
-
-				val = QEDE_RSS_COUNT(edev);
-				indir_val = ethtool_rxfh_indir_default(i, val);
-				edev->rss_params.rss_ind_table[i] = indir_val;
-			}
-			edev->rss_params_inited |= QEDE_RSS_INDIR_INITED;
-		}
-
-		if (!(edev->rss_params_inited & QEDE_RSS_KEY_INITED)) {
-			netdev_rss_key_fill(edev->rss_params.rss_key,
-					    sizeof(edev->rss_params.rss_key));
-			edev->rss_params_inited |= QEDE_RSS_KEY_INITED;
-		}
-
-		if (!(edev->rss_params_inited & QEDE_RSS_CAPS_INITED)) {
-			edev->rss_params.rss_caps = QED_RSS_IPV4 |
-						    QED_RSS_IPV6 |
-						    QED_RSS_IPV4_TCP |
-						    QED_RSS_IPV6_TCP;
-			edev->rss_params_inited |= QEDE_RSS_CAPS_INITED;
-		}
-
-		memcpy(&vport_update_params.rss_params, &edev->rss_params,
-		       sizeof(vport_update_params.rss_params));
-	} else {
-		memset(&vport_update_params.rss_params, 0,
-		       sizeof(vport_update_params.rss_params));
-	}
-
-	rc = edev->ops->vport_update(cdev, &vport_update_params);
-	if (rc) {
+	rc = edev->ops->vport_update(cdev, vport_update_params);
+	if (rc)
 		DP_ERR(edev, "Update V-PORT failed %d\n", rc);
-		return rc;
-	}
 
-	return 0;
+out:
+	vfree(vport_update_params);
+	return rc;
 }
 
-
 enum qede_unload_mode {
 	QEDE_UNLOAD_NORMAL,
 };
diff --git a/include/linux/qed/qed_eth_if.h b/include/linux/qed/qed_eth_if.h
index d91651e..3613d63 100644
--- a/include/linux/qed/qed_eth_if.h
+++ b/include/linux/qed/qed_eth_if.h
@@ -77,7 +77,7 @@ struct qed_dev_eth_info {
 };
 
 struct qed_update_vport_rss_params {
-	u16	rss_ind_table[128];
+	void	*rss_ind_table[128];
 	u32	rss_key[10];
 	u8	rss_caps;
 };
-- 
1.9.3
