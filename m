From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [RFC 2/2] qlcnic: Add support to configure SR-IOV VF minimum and maximum Tx rate through ip tool.
Date: Wed, 5 Mar 2014 02:33:36 -0500
Message-ID: <1394004816-23436-3-git-send-email-sucheta.chakraborty@qlogic.com>
References: <1394004816-23436-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:65139 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751551AbaCEIJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 03:09:36 -0500
In-Reply-To: <1394004816-23436-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o ip command can be used to configure minimum and maximum Tx rate.

o "min_tx_rate" option has been added for minimum Tx rate. Hence, for
  consistent naming, "max_tx_rate" option has been introduced for maximum
  Tx rate. And plan is to deprecate "rate" option of ip tool.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h  |   1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   | 102 +++++++++++++++++++--
 3 files changed, 94 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index a335472..58cc49f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -485,6 +485,7 @@ static const struct net_device_ops qlcnic_netdev_ops = {
 #ifdef CONFIG_QLCNIC_SRIOV
 	.ndo_set_vf_mac		= qlcnic_sriov_set_vf_mac,
 	.ndo_set_vf_tx_rate	= qlcnic_sriov_set_vf_tx_rate,
+	.ndo_set_vf_rate	= qlcnic_sriov_set_vf_rate,
 	.ndo_get_vf_config	= qlcnic_sriov_get_vf_config,
 	.ndo_set_vf_vlan	= qlcnic_sriov_set_vf_vlan,
 	.ndo_set_vf_spoofchk	= qlcnic_sriov_set_vf_spoofchk,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
index 396bd1f..7d53caa 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
@@ -232,6 +232,7 @@ void qlcnic_sriov_pf_reset(struct qlcnic_adapter *);
 int qlcnic_sriov_pf_reinit(struct qlcnic_adapter *);
 int qlcnic_sriov_set_vf_mac(struct net_device *, int, u8 *);
 int qlcnic_sriov_set_vf_tx_rate(struct net_device *, int, int);
+int qlcnic_sriov_set_vf_rate(struct net_device *, int, int, int);
 int qlcnic_sriov_get_vf_config(struct net_device *, int ,
 			       struct ifla_vf_info *);
 int qlcnic_sriov_set_vf_vlan(struct net_device *, int, u16, u8);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index a28460c..69bf0b2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -1821,28 +1821,32 @@ int qlcnic_sriov_set_vf_tx_rate(struct net_device *netdev, int vf, int tx_rate)
 	struct qlcnic_vf_info *vf_info;
 	struct qlcnic_info nic_info;
 	struct qlcnic_vport *vp;
-	u16 vpid;
+	u16 vpid, min_tx_rate;
 
-	if (!qlcnic_sriov_pf_check(adapter))
+	if (!qlcnic_sriov_pf_check(adapter) || qlcnic_84xx_check(adapter))
 		return -EOPNOTSUPP;
 
 	if (vf >= sriov->num_vfs)
 		return -EINVAL;
 
-	if (tx_rate >= 10000 || tx_rate < 100) {
+	vf_info = &sriov->vf_info[vf];
+	vp = vf_info->vp;
+	vpid = vp->handle;
+
+	min_tx_rate = vp->min_tx_bw * 100;
+	if (!min_tx_rate)
+		min_tx_rate = QLC_VF_MIN_TX_RATE;
+
+	if (tx_rate >= 10000 || tx_rate < min_tx_rate) {
 		netdev_err(netdev,
 			   "Invalid Tx rate, allowed range is [%d - %d]",
-			   QLC_VF_MIN_TX_RATE, QLC_VF_MAX_TX_RATE);
+			   min_tx_rate, QLC_VF_MAX_TX_RATE);
 		return -EINVAL;
 	}
 
 	if (tx_rate == 0)
 		tx_rate = 10000;
 
-	vf_info = &sriov->vf_info[vf];
-	vp = vf_info->vp;
-	vpid = vp->handle;
-
 	if (test_bit(QLC_BC_VF_STATE, &vf_info->state)) {
 		if (qlcnic_sriov_get_vf_vport_info(adapter, &nic_info, vpid))
 			return -EIO;
@@ -1952,13 +1956,24 @@ int qlcnic_sriov_get_vf_config(struct net_device *netdev,
 
 	vp = sriov->vf_info[vf].vp;
 	memcpy(&ivi->mac, vp->mac, ETH_ALEN);
+	ivi->tx_rate = 0;
 	ivi->vlan = qlcnic_sriov_get_vf_vlan(adapter, vp, vf);
 	ivi->qos = vp->qos;
 	ivi->spoofchk = vp->spoofchk;
 	if (vp->max_tx_bw == MAX_BW)
-		ivi->tx_rate = 0;
+		ivi->max_tx_rate = 0;
 	else
-		ivi->tx_rate = vp->max_tx_bw * 100;
+		ivi->max_tx_rate = vp->max_tx_bw * 100;
+
+	if (vp->min_tx_bw * 100 == QLC_VF_MIN_TX_RATE)
+		ivi->min_tx_rate = 0;
+	else
+		ivi->min_tx_rate = vp->min_tx_bw * 100;
+
+	if (!qlcnic_84xx_check(adapter) && !ivi->min_tx_rate) {
+		ivi->tx_rate = ivi->max_tx_rate;
+		ivi->max_tx_rate = 0;
+	}
 
 	ivi->vf = vf;
 	return 0;
@@ -1989,3 +2004,70 @@ int qlcnic_sriov_set_vf_spoofchk(struct net_device *netdev, int vf, bool chk)
 	vp->spoofchk = chk;
 	return 0;
 }
+
+int qlcnic_sriov_set_vf_rate(struct net_device *netdev, int vf,
+			     int min_tx_rate, int max_tx_rate)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	struct qlcnic_sriov *sriov = adapter->ahw->sriov;
+	struct qlcnic_vf_info *vf_info;
+	struct qlcnic_info nic_info;
+	struct qlcnic_vport *vp;
+	u16 vpid;
+
+	if (!qlcnic_sriov_pf_check(adapter))
+		return -EOPNOTSUPP;
+
+	if (vf >= sriov->num_vfs)
+		return -EINVAL;
+
+	vf_info = &sriov->vf_info[vf];
+	vp = vf_info->vp;
+	vpid = vp->handle;
+
+	if (!min_tx_rate)
+		min_tx_rate = QLC_VF_MIN_TX_RATE;
+
+	if (max_tx_rate &&
+	    (max_tx_rate >= 10000 || max_tx_rate < min_tx_rate)) {
+		netdev_err(netdev,
+			   "Invalid max Tx rate, allowed range is [%d - %d]",
+			   min_tx_rate, QLC_VF_MAX_TX_RATE);
+		return -EINVAL;
+	}
+
+	if (!max_tx_rate)
+		max_tx_rate = 10000;
+
+	if (min_tx_rate &&
+	    (min_tx_rate > max_tx_rate || min_tx_rate < QLC_VF_MIN_TX_RATE)) {
+		netdev_err(netdev,
+			   "Invalid min Tx rate, allowed range is [%d - %d]",
+			   QLC_VF_MIN_TX_RATE, max_tx_rate);
+		return -EINVAL;
+	}
+
+	if (test_bit(QLC_BC_VF_STATE, &vf_info->state)) {
+		if (qlcnic_sriov_get_vf_vport_info(adapter, &nic_info, vpid))
+			return -EIO;
+
+		nic_info.max_tx_bw = max_tx_rate / 100;
+		nic_info.min_tx_bw = min_tx_rate / 100;
+		nic_info.bit_offsets = BIT_0;
+
+		if (qlcnic_sriov_pf_set_vport_info(adapter, &nic_info, vpid))
+			return -EIO;
+	}
+
+	vp->max_tx_bw = max_tx_rate / 100;
+	netdev_info(netdev,
+		    "Setting Max Tx rate %d (Mbps), %d %% of PF bandwidth, for VF %d\n",
+		    max_tx_rate, vp->max_tx_bw, vf);
+
+	vp->min_tx_bw = min_tx_rate / 100;
+	netdev_info(netdev,
+		    "%s: Setting Min Tx rate %d (Mbps), %d %% of PF bandwidth, for VF %d\n",
+		    __func__, min_tx_rate, vp->min_tx_bw, vf);
+
+	return 0;
+}
-- 
1.8.1.4
