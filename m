From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 6/6] qed: Prevent over-usage of vlan credits by PF
Date: Wed, 27 Jul 2016 14:45:24 +0300
Message-ID: <1469619924-12806-7-git-send-email-Yuval.Mintz@qlogic.com>
References: <1469619924-12806-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:59995 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755718AbcG0Lpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 07:45:46 -0400
In-Reply-To: <1469619924-12806-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each PF/VF has a limited number of vlan filters for
configuration purposes; This information is passed to qede
and is used to prevent over-usage - once a vlan is to be
configured and no filter credit is available, the driver
would switch into working in vlan-promisc mode.

Problem is the credit pool is shared by both PFs and VFs,
and currently PFs aren't deducting the filters that are
reserved for their VFs from their quota, which may lead
to some vlan filters failing unknowingly due to lack of credit.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index ff388208..4c46d14 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -1656,6 +1656,8 @@ static int qed_fill_eth_dev_info(struct qed_dev *cdev,
 	info->num_tc = 1;
 
 	if (IS_PF(cdev)) {
+		int max_vf_vlan_filters = 0;
+
 		if (cdev->int_params.out.int_mode == QED_INT_MODE_MSIX) {
 			for_each_hwfn(cdev, i)
 			    info->num_queues +=
@@ -1668,7 +1670,12 @@ static int qed_fill_eth_dev_info(struct qed_dev *cdev,
 			info->num_queues = cdev->num_hwfns;
 		}
 
-		info->num_vlan_filters = RESC_NUM(&cdev->hwfns[0], QED_VLAN);
+		if (IS_QED_SRIOV(cdev))
+			max_vf_vlan_filters = cdev->p_iov_info->total_vfs *
+					      QED_ETH_VF_NUM_VLAN_FILTERS;
+		info->num_vlan_filters = RESC_NUM(&cdev->hwfns[0], QED_VLAN) -
+					 max_vf_vlan_filters;
+
 		ether_addr_copy(info->port_mac,
 				cdev->hwfns[0].hw_info.hw_mac_addr);
 	} else {
-- 
1.9.3
