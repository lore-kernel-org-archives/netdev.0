From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 2/5] tg3: Cleanup IPV6 LSO
Date: Wed, 17 Dec 2008 18:15:06 -0800
Message-ID: <1229717359.5499@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1180 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750973AbYLSUJa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2008 15:09:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch attempts to make the relationship between IPV6 checksum
offload and IPV6 LSO more obvious.  The patch also toggles a bit
needed for IPV6 LSO on 5785 and 57780 devices.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   47 +++++++++++++++++++++++------------------------
 drivers/net/tg3.h |    2 ++
 2 files changed, 25 insertions(+), 24 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index bacbfc5..9af8c9b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7518,7 +7518,11 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		rdmac_mode |= RDMAC_MODE_FIFO_LONG_BURST;
 
 	if (tp->tg3_flags2 & TG3_FLG2_HW_TSO)
-		rdmac_mode |= (1 << 27);
+		rdmac_mode |= RDMAC_MODE_IPV4_LSO_EN;
+
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
+		rdmac_mode |= RDMAC_MODE_IPV6_LSO_EN;
 
 	/* Receive/send statistics. */
 	if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS) {
@@ -9274,8 +9278,8 @@ static int tg3_set_tso(struct net_device *dev, u32 value)
 			return -EINVAL;
 		return 0;
 	}
-	if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_2) &&
-	    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906)) {
+	if ((dev->features & NETIF_F_IPV6_CSUM) &&
+	    (tp->tg3_flags2 & TG3_FLG2_HW_TSO_2)) {
 		if (value) {
 			dev->features |= NETIF_F_TSO6;
 			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
@@ -12358,6 +12362,18 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    (tp->tg3_flags2 & TG3_FLG2_5750_PLUS))
 		tp->tg3_flags2 |= TG3_FLG2_5705_PLUS;
 
+	/* 5700 B0 chips do not support checksumming correctly due
+	 * to hardware bugs.
+	 */
+	if (tp->pci_chip_rev_id == CHIPREV_ID_5700_B0)
+		tp->tg3_flags |= TG3_FLAG_BROKEN_CHECKSUMS;
+	else {
+		tp->tg3_flags |= TG3_FLAG_RX_CHECKSUMS;
+		tp->dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
+		if (tp->tg3_flags3 & TG3_FLG3_5755_PLUS)
+			tp->dev->features |= NETIF_F_IPV6_CSUM;
+	}
+
 	if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS) {
 		tp->tg3_flags |= TG3_FLAG_SUPPORT_MSI;
 		if (GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5750_AX ||
@@ -12614,12 +12630,6 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		return err;
 	}
 
-	/* 5700 B0 chips do not support checksumming correctly due
-	 * to hardware bugs.
-	 */
-	if (tp->pci_chip_rev_id == CHIPREV_ID_5700_B0)
-		tp->tg3_flags |= TG3_FLAG_BROKEN_CHECKSUMS;
-
 	/* Derive initial jumbo mode from MTU assigned in
 	 * ether_setup() via the alloc_etherdev() call
 	 */
@@ -13756,9 +13766,10 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	 * is off by default, but can be enabled using ethtool.
 	 */
 	if (tp->tg3_flags2 & TG3_FLG2_HW_TSO) {
-		dev->features |= NETIF_F_TSO;
-		if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_2) &&
-		    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906))
+		if (dev->features & NETIF_F_IP_CSUM)
+			dev->features |= NETIF_F_TSO;
+		if ((dev->features & NETIF_F_IPV6_CSUM) &&
+		    (tp->tg3_flags2 & TG3_FLG2_HW_TSO_2))
 			dev->features |= NETIF_F_TSO6;
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
 		    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
@@ -13812,18 +13823,6 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		goto err_out_apeunmap;
 	}
 
-	/* Tigon3 can do ipv4 only... and some chips have buggy
-	 * checksumming.
-	 */
-	if ((tp->tg3_flags & TG3_FLAG_BROKEN_CHECKSUMS) == 0) {
-		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
-		if (tp->tg3_flags3 & TG3_FLG3_5755_PLUS)
-			dev->features |= NETIF_F_IPV6_CSUM;
-
-		tp->tg3_flags |= TG3_FLAG_RX_CHECKSUMS;
-	} else
-		tp->tg3_flags &= ~TG3_FLAG_RX_CHECKSUMS;
-
 	/* flow control autonegotiation is default behavior */
 	tp->tg3_flags |= TG3_FLAG_PAUSE_AUTONEG;
 	tp->link_config.flowctrl = FLOW_CTRL_TX | FLOW_CTRL_RX;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 0880cfa..f3cda64 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1207,6 +1207,8 @@
 #define  RDMAC_MODE_MBUF_SBD_CRPT_ENAB	 0x00002000
 #define  RDMAC_MODE_FIFO_SIZE_128	 0x00020000
 #define  RDMAC_MODE_FIFO_LONG_BURST	 0x00030000
+#define  RDMAC_MODE_IPV4_LSO_EN		 0x08000000
+#define  RDMAC_MODE_IPV6_LSO_EN		 0x10000000
 #define RDMAC_STATUS			0x00004804
 #define  RDMAC_STATUS_TGTABORT		 0x00000004
 #define  RDMAC_STATUS_MSTABORT		 0x00000008
-- 
1.5.6.4


