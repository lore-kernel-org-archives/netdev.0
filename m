From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 1/1] tg3: Avoid Send BD corruption
Date: Wed, 10 Sep 2008 22:12:45 -0700
Message-ID: <20080911051244.GA27384@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1521 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751157AbYIKFJy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2008 01:09:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5761 and 5784 ASIC revision chips, there is a chance that send BDs
can be corrupted when CLKREQ is enabled.  This patch turns CLKREQ off
while the driver is in control of the device.

This patch also bumps up the version to 3.95.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

---
 drivers/net/tg3.c |   43 ++++++++++++++++++++++++++++++++++---------
 drivers/net/tg3.h |    1 +
 2 files changed, 35 insertions(+), 9 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 71d2c5c..a9c751f 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -66,8 +66,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.94"
-#define DRV_MODULE_RELDATE	"August 14, 2008"
+#define DRV_MODULE_VERSION	"3.95"
+#define DRV_MODULE_RELDATE	"September 10, 2008"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
@@ -2039,6 +2039,23 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 			tp->dev->name, state);
 		return -EINVAL;
 	}
+
+	/* Restore the CLKREQ setting. */
+	if (tp->tg3_flags3 & TG3_FLG3_CLKREQ_BUG) {
+		int pcie_cap;
+		u16 lnkctl;
+
+		pcie_cap = pci_find_capability(tp->pdev, PCI_CAP_ID_EXP);
+
+		pci_read_config_word(tp->pdev,
+				     pcie_cap + PCI_EXP_LNKCTL,
+				     &lnkctl);
+		lnkctl |= PCI_EXP_LNKCTL_CLKREQ_EN;
+		pci_write_config_word(tp->pdev,
+				      pcie_cap + PCI_EXP_LNKCTL,
+				      lnkctl);
+	}
+
 	misc_host_ctrl = tr32(TG3PCI_MISC_HOST_CTRL);
 	tw32(TG3PCI_MISC_HOST_CTRL,
 	     misc_host_ctrl | MISC_HOST_CTRL_MASK_PCI_INT);
@@ -12099,18 +12116,26 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 
 	pcie_cap = pci_find_capability(tp->pdev, PCI_CAP_ID_EXP);
 	if (pcie_cap != 0) {
+		u16 lnkctl;
+
 		tp->tg3_flags2 |= TG3_FLG2_PCI_EXPRESS;
 
 		pcie_set_readrq(tp->pdev, 4096);
 
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
-			u16 lnkctl;
-
-			pci_read_config_word(tp->pdev,
-					     pcie_cap + PCI_EXP_LNKCTL,
-					     &lnkctl);
-			if (lnkctl & PCI_EXP_LNKCTL_CLKREQ_EN)
+		pci_read_config_word(tp->pdev,
+				     pcie_cap + PCI_EXP_LNKCTL,
+				     &lnkctl);
+		if (lnkctl & PCI_EXP_LNKCTL_CLKREQ_EN) {
+			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 				tp->tg3_flags2 &= ~TG3_FLG2_HW_TSO_2;
+			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
+			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761) {
+				tp->tg3_flags3 |= TG3_FLG3_CLKREQ_BUG;
+				lnkctl &= ~PCI_EXP_LNKCTL_CLKREQ_EN;
+				pci_write_config_word(tp->pdev,
+						      pcie_cap + PCI_EXP_LNKCTL,
+						      lnkctl);
+			}
 		}
 	}
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index f5b8cab..49a017d 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2517,6 +2517,7 @@ struct tg3 {
 #define TG3_FLG3_RGMII_STD_IBND_DISABLE	0x00000100
 #define TG3_FLG3_RGMII_EXT_IBND_RX_EN	0x00000200
 #define TG3_FLG3_RGMII_EXT_IBND_TX_EN	0x00000400
+#define TG3_FLG3_CLKREQ_BUG		0x00000800
 
 	struct timer_list		timer;
 	u16				timer_counter;
-- 
1.5.6.4



