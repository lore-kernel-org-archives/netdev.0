From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 5/6] qed: PF enforce MAC limitation of VFs
Date: Sun, 5 Jun 2016 13:11:15 +0300
Message-ID: <1465121476-32494-6-git-send-email-Yuval.Mintz@qlogic.com>
References: <1465121476-32494-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:55189 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751142AbcFEKLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 06:11:42 -0400
In-Reply-To: <1465121476-32494-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only limitation relating to MACs the PF enforce today on its VFs
is in case it has a forced-unicast MAC address for them, in which case
they can't configure other unicast addresses.
Specifically, the PF isn't enforcing the number of MAC addresse a VF can
configure regardless of the nubmer of such filters agreed upon by PF and
VF during the acquisition process.

PF's shadow-config is now extended to also contain information about its
VFs' unicast addresses configuration, allowing such enforcement.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 83 ++++++++++++++++++++++++++---
 drivers/net/ethernet/qlogic/qed/qed_sriov.h |  2 +
 2 files changed, 79 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 0094f86..50b535a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -2309,15 +2309,12 @@ out:
 	qed_iov_send_response(p_hwfn, p_ptt, vf, length, status);
 }
 
-static int qed_iov_vf_update_unicast_shadow(struct qed_hwfn *p_hwfn,
-					    struct qed_vf_info *p_vf,
-					    struct qed_filter_ucast *p_params)
+static int qed_iov_vf_update_vlan_shadow(struct qed_hwfn *p_hwfn,
+					 struct qed_vf_info *p_vf,
+					 struct qed_filter_ucast *p_params)
 {
 	int i;
 
-	if (p_params->type == QED_FILTER_MAC)
-		return 0;
-
 	/* First remove entries and then add new ones */
 	if (p_params->opcode == QED_FILTER_REMOVE) {
 		for (i = 0; i < QED_ETH_VF_NUM_VLAN_FILTERS + 1; i++)
@@ -2370,6 +2367,80 @@ static int qed_iov_vf_update_unicast_shadow(struct qed_hwfn *p_hwfn,
 	return 0;
 }
 
+static int qed_iov_vf_update_mac_shadow(struct qed_hwfn *p_hwfn,
+					struct qed_vf_info *p_vf,
+					struct qed_filter_ucast *p_params)
+{
+	int i;
+
+	/* If we're in forced-mode, we don't allow any change */
+	if (p_vf->bulletin.p_virt->valid_bitmap & (1 << MAC_ADDR_FORCED))
+		return 0;
+
+	/* First remove entries and then add new ones */
+	if (p_params->opcode == QED_FILTER_REMOVE) {
+		for (i = 0; i < QED_ETH_VF_NUM_MAC_FILTERS; i++) {
+			if (ether_addr_equal(p_vf->shadow_config.macs[i],
+					     p_params->mac)) {
+				memset(p_vf->shadow_config.macs[i], 0,
+				       ETH_ALEN);
+				break;
+			}
+		}
+
+		if (i == QED_ETH_VF_NUM_MAC_FILTERS) {
+			DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+				   "MAC isn't configured\n");
+			return -EINVAL;
+		}
+	} else if (p_params->opcode == QED_FILTER_REPLACE ||
+		   p_params->opcode == QED_FILTER_FLUSH) {
+		for (i = 0; i < QED_ETH_VF_NUM_MAC_FILTERS; i++)
+			memset(p_vf->shadow_config.macs[i], 0, ETH_ALEN);
+	}
+
+	/* List the new MAC address */
+	if (p_params->opcode != QED_FILTER_ADD &&
+	    p_params->opcode != QED_FILTER_REPLACE)
+		return 0;
+
+	for (i = 0; i < QED_ETH_VF_NUM_MAC_FILTERS; i++) {
+		if (is_zero_ether_addr(p_vf->shadow_config.macs[i])) {
+			ether_addr_copy(p_vf->shadow_config.macs[i],
+					p_params->mac);
+			DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+				   "Added MAC at %d entry in shadow\n", i);
+			break;
+		}
+	}
+
+	if (i == QED_ETH_VF_NUM_MAC_FILTERS) {
+		DP_VERBOSE(p_hwfn, QED_MSG_IOV, "No available place for MAC\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int
+qed_iov_vf_update_unicast_shadow(struct qed_hwfn *p_hwfn,
+				 struct qed_vf_info *p_vf,
+				 struct qed_filter_ucast *p_params)
+{
+	int rc = 0;
+
+	if (p_params->type == QED_FILTER_MAC) {
+		rc = qed_iov_vf_update_mac_shadow(p_hwfn, p_vf, p_params);
+		if (rc)
+			return rc;
+	}
+
+	if (p_params->type == QED_FILTER_VLAN)
+		rc = qed_iov_vf_update_vlan_shadow(p_hwfn, p_vf, p_params);
+
+	return rc;
+}
+
 int qed_iov_chk_ucast(struct qed_hwfn *hwfn,
 		      int vfid, struct qed_filter_ucast *params)
 {
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.h b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
index ea24795..96a7273 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
@@ -120,6 +120,8 @@ struct qed_vf_shadow_config {
 	/* Shadow copy of all guest vlans */
 	struct qed_vf_vlan_shadow vlans[QED_ETH_VF_NUM_VLAN_FILTERS + 1];
 
+	/* Shadow copy of all configured MACs; Empty if forcing MACs */
+	u8 macs[QED_ETH_VF_NUM_MAC_FILTERS][ETH_ALEN];
 	u8 inner_vlan_removal;
 };
 
-- 
1.9.3
