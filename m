From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next] bnx2: disable toggling of rxvlan if necessary
Date: Thu, 26 Feb 2015 14:48:07 +0100
Message-ID: <1424958487-5737-1-git-send-email-ivecera@redhat.com>
Cc: Sony Chacko <sony.chacko@qlogic.com>,
	Dept-HSGLinuxNICDev@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53784 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753475AbbBZNsM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2015 08:48:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bnx2 driver uses .ndo_fix_features to force enable of Rx VLAN tag
stripping when the card cannot disable it. The driver should remove
NETIF_F_HW_VLAN_CTAG_RX flag from hw_features instead so it is fixed
for the ethtool.

Cc: Sony Chacko <sony.chacko@qlogic.com>
Cc: Dept-HSGLinuxNICDev@qlogic.com
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2.c | 15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 9f146b9..2b66ef3 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -7708,17 +7708,6 @@ bnx2_set_phys_id(struct net_device *dev, enum ethtool_phys_id_state state)
 	return 0;
 }
 
-static netdev_features_t
-bnx2_fix_features(struct net_device *dev, netdev_features_t features)
-{
-	struct bnx2 *bp = netdev_priv(dev);
-
-	if (!(bp->flags & BNX2_FLAG_CAN_KEEP_VLAN))
-		features |= NETIF_F_HW_VLAN_CTAG_RX;
-
-	return features;
-}
-
 static int
 bnx2_set_features(struct net_device *dev, netdev_features_t features)
 {
@@ -8525,7 +8514,6 @@ static const struct net_device_ops bnx2_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= bnx2_change_mac_addr,
 	.ndo_change_mtu		= bnx2_change_mtu,
-	.ndo_fix_features	= bnx2_fix_features,
 	.ndo_set_features	= bnx2_set_features,
 	.ndo_tx_timeout		= bnx2_tx_timeout,
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -8576,6 +8564,9 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->features |= dev->hw_features;
 	dev->priv_flags |= IFF_UNICAST_FLT;
 
+	if (!(bp->flags & BNX2_FLAG_CAN_KEEP_VLAN))
+		dev->hw_features &= ~NETIF_F_HW_VLAN_CTAG_RX;
+
 	if ((rc = register_netdev(dev))) {
 		dev_err(&pdev->dev, "Cannot register net device\n");
 		goto error;
-- 
2.0.5
