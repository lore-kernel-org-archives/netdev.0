From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net 2/3] qlcnic: Fix resource allocation for TX queues
Date: Thu, 2 Jan 2014 13:38:44 -0500
Message-ID: <1388687925-17882-3-git-send-email-manish.chopra@qlogic.com>
References: <1388687925-17882-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <rajesh.borundia@qlogic.com>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:27831 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750782AbaABTS0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 14:18:26 -0500
In-Reply-To: <1388687925-17882-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o TX queues allocation was getting distributed equally among all the
  functions of the port including VFs and PF. Which was leading to failure
  in PF's multiple TX queues creation.

o Instead of dividing queues equally allocate one TX queue for each VF as VF
  doesn't support multiple TX queues.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index 686f460..024f816 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -75,7 +75,6 @@ static int qlcnic_sriov_pf_cal_res_limit(struct qlcnic_adapter *adapter,
 	num_vfs = sriov->num_vfs;
 	max = num_vfs + 1;
 	info->bit_offsets = 0xffff;
-	info->max_tx_ques = res->num_tx_queues / max;
 	info->max_rx_mcast_mac_filters = res->num_rx_mcast_mac_filters;
 	num_vf_macs = QLCNIC_SRIOV_VF_MAX_MAC;
 
@@ -86,6 +85,7 @@ static int qlcnic_sriov_pf_cal_res_limit(struct qlcnic_adapter *adapter,
 		info->max_tx_mac_filters = temp;
 		info->min_tx_bw = 0;
 		info->max_tx_bw = MAX_BW;
+		info->max_tx_ques = res->num_tx_queues - sriov->num_vfs;
 	} else {
 		id = qlcnic_sriov_func_to_index(adapter, func);
 		if (id < 0)
@@ -95,6 +95,7 @@ static int qlcnic_sriov_pf_cal_res_limit(struct qlcnic_adapter *adapter,
 		info->max_tx_bw = vp->max_tx_bw;
 		info->max_rx_ucast_mac_filters = num_vf_macs;
 		info->max_tx_mac_filters = num_vf_macs;
+		info->max_tx_ques = QLCNIC_SINGLE_RING;
 	}
 
 	info->max_rx_ip_addr = res->num_destip / max;
-- 
1.8.3.1
