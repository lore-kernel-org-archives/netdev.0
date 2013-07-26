From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net 3/4] qlcnic: Fix setting Guest VLAN
Date: Fri, 26 Jul 2013 16:24:02 -0400
Message-ID: <8efa036fe12b6f34dbe1a22bb81174ef2a833bf9.1374891091.git.himanshu.madhani@qlogic.com>
References: <cover.1374891091.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	<himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:52905 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760648Ab3GZVYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 17:24:24 -0400
In-Reply-To: <cover.1374891091.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o When configuring guest VLAN after PVID configuration, VF was loading
  with previously configured PVID. Clear the PVID which was previously
  configured before configuring guest VLAN.

o Display guest VLAN when it is configured

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   | 26 +++++++++++++++++++++-
 1 file changed, 25 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index 9bdd51e..eb49cd6 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -1749,6 +1749,7 @@ int qlcnic_sriov_set_vf_vlan(struct net_device *netdev, int vf,
 
 	switch (vlan) {
 	case 4095:
+		vp->vlan = 0;
 		vp->vlan_mode = QLC_GUEST_VLAN_MODE;
 		break;
 	case 0:
@@ -1767,6 +1768,29 @@ int qlcnic_sriov_set_vf_vlan(struct net_device *netdev, int vf,
 	return 0;
 }
 
+static inline __u32 qlcnic_sriov_get_vf_vlan(struct qlcnic_adapter *adapter,
+					     struct qlcnic_vport *vp, int vf)
+{
+	__u32 vlan = 0;
+
+	switch (vp->vlan_mode) {
+	case QLC_PVID_MODE:
+		vlan = vp->vlan;
+		break;
+	case QLC_GUEST_VLAN_MODE:
+		vlan = MAX_VLAN_ID;
+		break;
+	case QLC_NO_VLAN_MODE:
+		vlan = 0;
+		break;
+	default:
+		netdev_info(adapter->netdev, "Invalid VLAN mode = %d for VF %d\n",
+			    vp->vlan_mode, vf);
+	}
+
+	return vlan;
+}
+
 int qlcnic_sriov_get_vf_config(struct net_device *netdev,
 			       int vf, struct ifla_vf_info *ivi)
 {
@@ -1782,7 +1806,7 @@ int qlcnic_sriov_get_vf_config(struct net_device *netdev,
 
 	vp = sriov->vf_info[vf].vp;
 	memcpy(&ivi->mac, vp->mac, ETH_ALEN);
-	ivi->vlan = vp->vlan;
+	ivi->vlan = qlcnic_sriov_get_vf_vlan(adapter, vp, vf);
 	ivi->qos = vp->qos;
 	ivi->spoofchk = vp->spoofchk;
 	if (vp->max_tx_bw == MAX_BW)
-- 
1.8.1.4
