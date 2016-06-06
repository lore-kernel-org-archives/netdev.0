From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 2/3] bnxt_en: Enable and disable RX CTAG and RX STAG VLAN acceleration together.
Date: Mon,  6 Jun 2016 02:37:15 -0400
Message-ID: <1465195036-4107-3-git-send-email-michael.chan@broadcom.com>
References: <1465195036-4107-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34571 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbcFFGh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 02:37:27 -0400
Received: by mail-pf0-f177.google.com with SMTP id 62so63837996pfd.1
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2016 23:37:27 -0700 (PDT)
In-Reply-To: <1465195036-4107-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hardware can only be set to strip or not strip both the VLAN CTAG and
STAG.  It cannot strip one and not strip the other.  Add logic to
bnxt_fix_features() to toggle both feature flags when the user is toggling
one of them.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 4615ed4..ae2b264 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5467,6 +5467,20 @@ static netdev_features_t bnxt_fix_features(struct net_device *dev,
 
 	if (!bnxt_rfs_capable(bp))
 		features &= ~NETIF_F_NTUPLE;
+
+	/* Both CTAG and STAG VLAN accelaration on the RX side have to be
+	 * turned on or off together.
+	 */
+	if ((features & (NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_HW_VLAN_STAG_RX)) !=
+	    (NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_HW_VLAN_STAG_RX)) {
+		if (dev->features & NETIF_F_HW_VLAN_CTAG_RX)
+			features &= ~(NETIF_F_HW_VLAN_CTAG_RX |
+				      NETIF_F_HW_VLAN_STAG_RX);
+		else
+			features |= NETIF_F_HW_VLAN_CTAG_RX |
+				    NETIF_F_HW_VLAN_STAG_RX;
+	}
+
 	return features;
 }
 
-- 
1.8.3.1
