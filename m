From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] tg3: allow TSO on vlan devices
Date: Thu, 08 Jul 2010 18:14:55 +0200
Message-ID: <1278605695.2651.48.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42289 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754628Ab0GHQO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 12:14:59 -0400
Received: by mail-wy0-f174.google.com with SMTP id 23so695017wyf.19
        for <netdev@vger.kernel.org>; Thu, 08 Jul 2010 09:14:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to commit 72dccb01e8632aa (bnx2: Update vlan_features)

In order to enable TSO on vlan devices, tg3 needs to update
dev->vlan_features.

Tested on HP NC326m (aka BCM5715S (rev a3))

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/tg3.c |   28 +++++++++++++++++++++-------
 1 file changed, 21 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 289cdc5..68329a9 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12800,6 +12800,13 @@ done:
 
 static struct pci_dev * __devinit tg3_find_peer(struct tg3 *);
 
+static void inline vlan_features_add(struct net_device *dev, unsigned long flags)
+{
+#if TG3_VLAN_TAG_USED
+	dev->vlan_features |= flags;
+#endif
+}
+
 static int __devinit tg3_get_invariants(struct tg3 *tp)
 {
 	static struct pci_device_id write_reorder_chipsets[] = {
@@ -13032,11 +13039,13 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5700_B0)
 		tp->tg3_flags |= TG3_FLAG_BROKEN_CHECKSUMS;
 	else {
+		unsigned long features = NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_GRO;
+
 		tp->tg3_flags |= TG3_FLAG_RX_CHECKSUMS;
-		tp->dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 		if (tp->tg3_flags3 & TG3_FLG3_5755_PLUS)
-			tp->dev->features |= NETIF_F_IPV6_CSUM;
-		tp->dev->features |= NETIF_F_GRO;
+			features |= NETIF_F_IPV6_CSUM;
+		tp->dev->features |= features;
+		vlan_features_add(tp->dev, features);
 	}
 
 	/* Determine TSO capabilities */
@@ -14525,20 +14534,25 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	 * is off by default, but can be enabled using ethtool.
 	 */
 	if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO) &&
-	    (dev->features & NETIF_F_IP_CSUM))
+	    (dev->features & NETIF_F_IP_CSUM)) {
 		dev->features |= NETIF_F_TSO;
-
+		vlan_features_add(dev, NETIF_F_TSO);
+	}
 	if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_2) ||
 	    (tp->tg3_flags2 & TG3_FLG2_HW_TSO_3)) {
-		if (dev->features & NETIF_F_IPV6_CSUM)
+		if (dev->features & NETIF_F_IPV6_CSUM) {
 			dev->features |= NETIF_F_TSO6;
+			vlan_features_add(dev, NETIF_F_TSO6);
+		}
 		if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_3) ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
 		    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
 		     GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX) ||
 			GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780) {
 			dev->features |= NETIF_F_TSO_ECN;
+			vlan_features_add(dev, NETIF_F_TSO_ECN);
+		}
 	}
 
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5705_A1 &&


