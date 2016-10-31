From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 2/2] qed: Correct VF mac number
Date: Mon, 31 Oct 2016 22:26:54 +0200
Message-ID: <1477945614-29133-3-git-send-email-Yuval.Mintz@cavium.com>
References: <1477945614-29133-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:41208 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S946471AbcJaU1I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 16:27:08 -0400
In-Reply-To: <1477945614-29133-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When relaxing the limitation on the number of unicast MAC filters
an interface can configure, qed started passing the MAC quota to
qede. However, the value is initialized only for PFs, causing VFs
to always try and configure themselves as promiscuous
[as they believe they lack the resources to configure the rx-mode].

Fixes: 7b7e70f979e3 ("qed*: Allow unicast filtering")
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c |  2 ++
 drivers/net/ethernet/qlogic/qed/qed_vf.c |  7 +++++++
 drivers/net/ethernet/qlogic/qed/qed_vf.h | 13 +++++++++++++
 3 files changed, 22 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 1e3a16e..900b253 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -1692,6 +1692,8 @@ static int qed_fill_eth_dev_info(struct qed_dev *cdev,
 
 		qed_vf_get_num_vlan_filters(&cdev->hwfns[0],
 					    (u8 *)&info->num_vlan_filters);
+		qed_vf_get_num_mac_filters(&cdev->hwfns[0],
+					   (u8 *)&info->num_mac_filters);
 		qed_vf_get_port_mac(&cdev->hwfns[0], info->port_mac);
 
 		info->is_legacy = !!cdev->hwfns[0].vf_iov_info->b_pre_fp_hsi;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.c b/drivers/net/ethernet/qlogic/qed/qed_vf.c
index f580bf4..3c06336 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.c
@@ -1171,6 +1171,13 @@ void qed_vf_get_num_vlan_filters(struct qed_hwfn *p_hwfn, u8 *num_vlan_filters)
 	*num_vlan_filters = p_vf->acquire_resp.resc.num_vlan_filters;
 }
 
+void qed_vf_get_num_mac_filters(struct qed_hwfn *p_hwfn, u8 *num_mac_filters)
+{
+	struct qed_vf_iov *p_vf = p_hwfn->vf_iov_info;
+
+	*num_mac_filters = p_vf->acquire_resp.resc.num_mac_filters;
+}
+
 bool qed_vf_check_mac(struct qed_hwfn *p_hwfn, u8 *mac)
 {
 	struct qed_bulletin_content *bulletin;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.h b/drivers/net/ethernet/qlogic/qed/qed_vf.h
index 944745b..325c250 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.h
@@ -623,6 +623,14 @@ void qed_vf_get_num_vlan_filters(struct qed_hwfn *p_hwfn,
 				 u8 *num_vlan_filters);
 
 /**
+ * @brief Get number of MAC filters allocated for VF by qed
+ *
+ *  @param p_hwfn
+ *  @param num_rxqs - allocated MAC filters
+ */
+void qed_vf_get_num_mac_filters(struct qed_hwfn *p_hwfn, u8 *num_mac_filters);
+
+/**
  * @brief Check if VF can set a MAC address
  *
  * @param p_hwfn
@@ -872,6 +880,11 @@ static inline void qed_vf_get_num_vlan_filters(struct qed_hwfn *p_hwfn,
 {
 }
 
+static inline void qed_vf_get_num_mac_filters(struct qed_hwfn *p_hwfn,
+					      u8 *num_mac_filters)
+{
+}
+
 static inline bool qed_vf_check_mac(struct qed_hwfn *p_hwfn, u8 *mac)
 {
 	return false;
-- 
1.9.3
