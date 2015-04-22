From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net] bnx2x: Prevent inner-reload while VFs exist
Date: Wed, 22 Apr 2015 12:47:32 +0300
Message-ID: <1429696052-27666-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:11290 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965206AbbDVJry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 05:47:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some feature changes, driver employes an inner-reload flow where it
resets the function and re-configures it with the new required set of
parameters.

Such a flow proves fatal to any VF since those were not intended to be used
while HW is being reset underneath, causing them [at best] to lose all
connectivity.

This changes driver behavior to fail all configuration changes [e.g., mtu
change] requested of the driver in case VFs are active.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
Hi Dave,

Please consider applying this to 'net'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    | 43 +++++++++++++++++-----
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    | 17 +++++++++
 2 files changed, 51 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 2f63467..6f7dc81 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -4809,6 +4809,23 @@ netdev_features_t bnx2x_fix_features(struct net_device *dev,
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
+	if (pci_num_vf(bp->pdev)) {
+		netdev_features_t changed = dev->features ^ features;
+
+		/* Revert the requested changes in features if they
+		 * would require internal reload of PF in bnx2x_set_features().
+		 */
+		if (!(features & NETIF_F_RXCSUM) && !bp->disable_tpa) {
+			features &= ~NETIF_F_RXCSUM;
+			features |= dev->features & NETIF_F_RXCSUM;
+		}
+
+		if (changed & NETIF_F_LOOPBACK) {
+			features &= ~NETIF_F_LOOPBACK;
+			features |= dev->features & NETIF_F_LOOPBACK;
+		}
+	}
+
 	/* TPA requires Rx CSUM offloading */
 	if (!(features & NETIF_F_RXCSUM)) {
 		features &= ~NETIF_F_LRO;
@@ -4839,15 +4856,18 @@ int bnx2x_set_features(struct net_device *dev, netdev_features_t features)
 	else
 		flags &= ~GRO_ENABLE_FLAG;
 
-	if (features & NETIF_F_LOOPBACK) {
-		if (bp->link_params.loopback_mode != LOOPBACK_BMAC) {
-			bp->link_params.loopback_mode = LOOPBACK_BMAC;
-			bnx2x_reload = true;
-		}
-	} else {
-		if (bp->link_params.loopback_mode != LOOPBACK_NONE) {
-			bp->link_params.loopback_mode = LOOPBACK_NONE;
-			bnx2x_reload = true;
+	/* VFs or non SRIOV PFs should be able to change loopback feature */
+	if (!pci_num_vf(bp->pdev)) {
+		if (features & NETIF_F_LOOPBACK) {
+			if (bp->link_params.loopback_mode != LOOPBACK_BMAC) {
+				bp->link_params.loopback_mode = LOOPBACK_BMAC;
+				bnx2x_reload = true;
+			}
+		} else {
+			if (bp->link_params.loopback_mode != LOOPBACK_NONE) {
+				bp->link_params.loopback_mode = LOOPBACK_NONE;
+				bnx2x_reload = true;
+			}
 		}
 	}
 
@@ -4931,6 +4951,11 @@ int bnx2x_resume(struct pci_dev *pdev)
 	}
 	bp = netdev_priv(dev);
 
+	if (pci_num_vf(bp->pdev)) {
+		DP(BNX2X_MSG_IOV, "VFs are enabled, can not change MTU\n");
+		return -EPERM;
+	}
+
 	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
 		BNX2X_ERR("Handling parity error recovery. Try again later\n");
 		return -EAGAIN;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index e3d853c..48ed005 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1843,6 +1843,12 @@ static int bnx2x_set_ringparam(struct net_device *dev,
 	   "set ring params command parameters: rx_pending = %d, tx_pending = %d\n",
 	   ering->rx_pending, ering->tx_pending);
 
+	if (pci_num_vf(bp->pdev)) {
+		DP(BNX2X_MSG_IOV,
+		   "VFs are enabled, can not change ring parameters\n");
+		return -EPERM;
+	}
+
 	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
 		DP(BNX2X_MSG_ETHTOOL,
 		   "Handling parity error recovery. Try again later\n");
@@ -2899,6 +2905,12 @@ static void bnx2x_self_test(struct net_device *dev,
 	u8 is_serdes, link_up;
 	int rc, cnt = 0;
 
+	if (pci_num_vf(bp->pdev)) {
+		DP(BNX2X_MSG_IOV,
+		   "VFs are enabled, can not perform self test\n");
+		return;
+	}
+
 	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
 		netdev_err(bp->dev,
 			   "Handling parity error recovery. Try again later\n");
@@ -3468,6 +3480,11 @@ static int bnx2x_set_channels(struct net_device *dev,
 	   channels->rx_count, channels->tx_count, channels->other_count,
 	   channels->combined_count);
 
+	if (pci_num_vf(bp->pdev)) {
+		DP(BNX2X_MSG_IOV, "VFs are enabled, can not set channels\n");
+		return -EPERM;
+	}
+
 	/* We don't support separate rx / tx channels.
 	 * We don't allow setting 'other' channels.
 	 */
-- 
1.9.3
