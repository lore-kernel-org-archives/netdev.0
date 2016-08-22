From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 2/4] qed: Prevent VFs from pause flooding
Date: Mon, 22 Aug 2016 13:25:10 +0300
Message-ID: <1471861512-30104-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1471861512-30104-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:46053 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753827AbcHVKZ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 06:25:26 -0400
In-Reply-To: <1471861512-30104-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Firmware would silently drop any control frame sent by VF to prevent
a malicious VF from generating pause flood in the network.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c    | 3 +++
 drivers/net/ethernet/qlogic/qed/qed_l2.h    | 2 ++
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 1 +
 3 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index c04162d..bf43301 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -101,6 +101,9 @@ int qed_sp_eth_vport_start(struct qed_hwfn *p_hwfn,
 
 	p_ramrod->tx_switching_en = p_params->tx_switching;
 
+	p_ramrod->ctl_frame_mac_check_en = !!p_params->check_mac;
+	p_ramrod->ctl_frame_ethtype_check_en = !!p_params->check_ethtype;
+
 	/* Software Function ID in hwfn (PFs are 0 - 15, VFs are 16 - 135) */
 	p_ramrod->sw_fid = qed_concrete_to_sw_fid(p_hwfn->cdev,
 						  p_params->concrete_fid);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.h b/drivers/net/ethernet/qlogic/qed/qed_l2.h
index ea93519..e495d62 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.h
@@ -102,6 +102,8 @@ struct qed_sp_vport_start_params {
 	u16 opaque_fid;
 	u8 vport_id;
 	u16 mtu;
+	bool check_mac;
+	bool check_ethtype;
 };
 
 int qed_sp_eth_vport_start(struct qed_hwfn *p_hwfn,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index f1fae77..cb68674 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -1680,6 +1680,7 @@ static void qed_iov_vf_mbx_start_vport(struct qed_hwfn *p_hwfn,
 	params.vport_id = vf->vport_id;
 	params.max_buffers_per_cqe = start->max_buffers_per_cqe;
 	params.mtu = vf->mtu;
+	params.check_mac = true;
 
 	rc = qed_sp_eth_vport_start(p_hwfn, &params);
 	if (rc) {
-- 
1.9.3
