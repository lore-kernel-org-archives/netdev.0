From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 06/20] tg3: Add new HW_TSO_3 flag for 5717
Date: Fri, 13 Nov 2009 15:03:38 -0800
Message-ID: <1258153432-7036-7-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4655 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932470AbZKMXEW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 18:04:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 5717 sets up TSO slightly differently in the transmit path.  It
looks like this method will be the new way of doing things.  This patch
defines a flag to indicate this.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   41 +++++++++++++++++++++++------------------
 drivers/net/tg3.h |    5 ++++-
 2 files changed, 27 insertions(+), 19 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 29276e6..6831289 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5206,7 +5206,7 @@ static void tg3_set_txd(struct tg3_napi *tnapi, int entry,
 }
 
 /* hard_start_xmit for devices that don't have any bugs and
- * support TG3_FLG2_HW_TSO_2 only.
+ * support TG3_FLG2_HW_TSO_2 and TG3_FLG2_HW_TSO_3 only.
  */
 static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 				  struct net_device *dev)
@@ -5265,7 +5265,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 			hdrlen = ip_tcp_len + tcp_opt_len;
 		}
 
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) {
+		if (tp->tg3_flags2 & TG3_FLG2_HW_TSO_3) {
 			mss |= (hdrlen & 0xc) << 12;
 			if (hdrlen & 0x10)
 				base_flags |= 0x00000010;
@@ -7523,7 +7523,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	if (tp->tg3_flags2 & TG3_FLG2_HW_TSO)
 		rdmac_mode |= RDMAC_MODE_IPV4_LSO_EN;
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
+	if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_3) ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
 		rdmac_mode |= RDMAC_MODE_IPV6_LSO_EN;
 
@@ -9513,15 +9514,16 @@ static int tg3_set_tso(struct net_device *dev, u32 value)
 		return 0;
 	}
 	if ((dev->features & NETIF_F_IPV6_CSUM) &&
-	    (tp->tg3_flags2 & TG3_FLG2_HW_TSO_2)) {
+	    ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_2) ||
+	     (tp->tg3_flags2 & TG3_FLG2_HW_TSO_3))) {
 		if (value) {
 			dev->features |= NETIF_F_TSO6;
-			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
+			if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_3) ||
+			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
 			    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
 			     GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX) ||
 			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
-			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 ||
-			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717)
+			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
 				dev->features |= NETIF_F_TSO_ECN;
 		} else
 			dev->features &= ~(NETIF_F_TSO6 | NETIF_F_TSO_ECN);
@@ -12670,8 +12672,10 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	}
 
 	/* Determine TSO capabilities */
-	if ((tp->tg3_flags3 & TG3_FLG3_5755_PLUS) ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717)
+		tp->tg3_flags2 |= TG3_FLG2_HW_TSO_3;
+	else if ((tp->tg3_flags3 & TG3_FLG3_5755_PLUS) ||
+		 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 		tp->tg3_flags2 |= TG3_FLG2_HW_TSO_2;
 	else if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS) {
 		tp->tg3_flags2 |= TG3_FLG2_HW_TSO_1 | TG3_FLG2_TSO_BUG;
@@ -14136,22 +14140,23 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	 * Firmware TSO on older chips gives lower performance, so it
 	 * is off by default, but can be enabled using ethtool.
 	 */
-	if (tp->tg3_flags2 & TG3_FLG2_HW_TSO) {
-		if (dev->features & NETIF_F_IP_CSUM)
-			dev->features |= NETIF_F_TSO;
-		if ((dev->features & NETIF_F_IPV6_CSUM) &&
-		    (tp->tg3_flags2 & TG3_FLG2_HW_TSO_2))
+	if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO) &&
+	    (dev->features & NETIF_F_IP_CSUM))
+		dev->features |= NETIF_F_TSO;
+
+	if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_2) ||
+	    (tp->tg3_flags2 & TG3_FLG2_HW_TSO_3)) {
+		if (dev->features & NETIF_F_IPV6_CSUM)
 			dev->features |= NETIF_F_TSO6;
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
+		if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_3) ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
 		    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
 		     GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX) ||
 			GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717)
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
 			dev->features |= NETIF_F_TSO_ECN;
 	}
 
-
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5705_A1 &&
 	    !(tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) &&
 	    !(tr32(TG3PCI_PCISTATE) & PCISTATE_BUS_SPEED_HIGH)) {
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 590a692..5fe5760 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2753,6 +2753,7 @@ struct tg3 {
 #define TG3_FLG2_SERDES_PREEMPHASIS	0x00020000
 #define TG3_FLG2_5705_PLUS		0x00040000
 #define TG3_FLG2_5750_PLUS		0x00080000
+#define TG3_FLG2_HW_TSO_3		0x00100000
 #define TG3_FLG2_USING_MSI		0x00200000
 #define TG3_FLG2_USING_MSIX		0x00400000
 #define TG3_FLG2_USING_MSI_OR_MSIX	(TG3_FLG2_USING_MSI | \
@@ -2764,7 +2765,9 @@ struct tg3 {
 #define TG3_FLG2_ICH_WORKAROUND		0x02000000
 #define TG3_FLG2_5780_CLASS		0x04000000
 #define TG3_FLG2_HW_TSO_2		0x08000000
-#define TG3_FLG2_HW_TSO			(TG3_FLG2_HW_TSO_1 | TG3_FLG2_HW_TSO_2)
+#define TG3_FLG2_HW_TSO			(TG3_FLG2_HW_TSO_1 | \
+					 TG3_FLG2_HW_TSO_2 | \
+					 TG3_FLG2_HW_TSO_3)
 #define TG3_FLG2_1SHOT_MSI		0x10000000
 #define TG3_FLG2_PHY_JITTER_BUG		0x20000000
 #define TG3_FLG2_NO_FWARE_REPORTED	0x40000000
-- 
1.6.4.4


