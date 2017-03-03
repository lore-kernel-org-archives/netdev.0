From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net 4/7] bnx2x: fix detection of VLAN filtering feature for VF
Date: Fri,  3 Mar 2017 17:08:31 +0100
Message-ID: <20170303160834.4125-5-mschmidt@redhat.com>
References: <20170303160834.4125-1-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <ariel.elior@cavium.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37548 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752027AbdCCQIn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Mar 2017 11:08:43 -0500
In-Reply-To: <20170303160834.4125-1-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VFs are currently missing the VLAN filtering feature, because we were
checking the PF's acquire response before actually performing the acquire.

Fix it by setting the feature flag later when we have the PF response.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index d57290b9ea..ac76fc251d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -13292,17 +13292,15 @@ static int bnx2x_init_dev(struct bnx2x *bp, struct pci_dev *pdev,
 	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_HIGHDMA;
 
-	/* VF with OLD Hypervisor or old PF do not support filtering */
 	if (IS_PF(bp)) {
 		if (chip_is_e1x)
 			bp->accept_any_vlan = true;
 		else
 			dev->hw_features |= NETIF_F_HW_VLAN_CTAG_FILTER;
-#ifdef CONFIG_BNX2X_SRIOV
-	} else if (bp->acquire_resp.pfdev_info.pf_cap & PFVF_CAP_VLAN_FILTER) {
-		dev->hw_features |= NETIF_F_HW_VLAN_CTAG_FILTER;
-#endif
 	}
+	/* For VF we'll know whether to enable VLAN filtering after
+	 * getting a response to CHANNEL_TLV_ACQUIRE from PF.
+	 */
 
 	dev->features |= dev->hw_features | NETIF_F_HW_VLAN_CTAG_RX;
 	dev->features |= NETIF_F_HIGHDMA;
@@ -14009,6 +14007,14 @@ static int bnx2x_init_one(struct pci_dev *pdev,
 		rc = bnx2x_vfpf_acquire(bp, tx_count, rx_count);
 		if (rc)
 			goto init_one_freemem;
+
+#ifdef CONFIG_BNX2X_SRIOV
+		/* VF with OLD Hypervisor or old PF do not support filtering */
+		if (bp->acquire_resp.pfdev_info.pf_cap & PFVF_CAP_VLAN_FILTER) {
+			dev->hw_features |= NETIF_F_HW_VLAN_CTAG_FILTER;
+			dev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
+		}
+#endif
 	}
 
 	/* Enable SRIOV if capability found in configuration space */
-- 
2.9.3
