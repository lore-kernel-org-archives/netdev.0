From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 5/8] tg3: Obtain PCI function number from device
Date: Fri, 4 Nov 2011 12:15:02 -0700
Message-ID: <1320434105-12898-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1783 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756108Ab1KDTOD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 15:14:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code to attempt to obtain the PCI function number from
the device rather than accept the number handed by the kernel.  In
pass-through scenarios, the function number handed by the kernel may not
reflect the true function of the device.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   30 ++++++++++++++++++++++++------
 drivers/net/ethernet/broadcom/tg3.h |    9 +++++++++
 2 files changed, 33 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 0413e1e..6973d01 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -14230,12 +14230,30 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	val = tr32(MEMARB_MODE);
 	tw32(MEMARB_MODE, val | MEMARB_MODE_ENABLE);
 
-	if (tg3_flag(tp, PCIX_MODE)) {
-		pci_read_config_dword(tp->pdev,
-				      tp->pcix_cap + PCI_X_STATUS, &val);
-		tp->pci_fn = val & 0x7;
-	} else {
-		tp->pci_fn = PCI_FUNC(tp->pdev->devfn) & 3;
+	tp->pci_fn = PCI_FUNC(tp->pdev->devfn) & 3;
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704 ||
+	    tg3_flag(tp, 5780_CLASS)) {
+		if (tg3_flag(tp, PCIX_MODE)) {
+			pci_read_config_dword(tp->pdev,
+					      tp->pcix_cap + PCI_X_STATUS,
+					      &val);
+			tp->pci_fn = val & 0x7;
+		}
+	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) {
+		tg3_read_mem(tp, NIC_SRAM_CPMU_STATUS, &val);
+		if ((val & NIC_SRAM_CPMUSTAT_SIG_MSK) ==
+		    NIC_SRAM_CPMUSTAT_SIG) {
+			tp->pci_fn = val & TG3_CPMU_STATUS_FMSK_5717;
+			tp->pci_fn = tp->pci_fn ? 1 : 0;
+		}
+	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+		   GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) {
+		tg3_read_mem(tp, NIC_SRAM_CPMU_STATUS, &val);
+		if ((val & NIC_SRAM_CPMUSTAT_SIG_MSK) ==
+		    NIC_SRAM_CPMUSTAT_SIG) {
+			tp->pci_fn = (val & TG3_CPMU_STATUS_FMSK_5719) >>
+				     TG3_CPMU_STATUS_FSHFT_5719;
+		}
 	}
 
 	/* Get eeprom hw config before calling tg3_set_power_state().
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 03fab8c..acfa265 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -1095,6 +1095,11 @@
 #define TG3_CPMU_CLCK_ORIDE		0x00003624
 #define  CPMU_CLCK_ORIDE_MAC_ORIDE_EN	 0x80000000
 
+#define TG3_CPMU_STATUS			0x0000362c
+#define  TG3_CPMU_STATUS_FMSK_5717	 0x20000000
+#define  TG3_CPMU_STATUS_FMSK_5719	 0xc0000000
+#define  TG3_CPMU_STATUS_FSHFT_5719	 30
+
 #define TG3_CPMU_CLCK_STAT		0x00003630
 #define  CPMU_CLCK_STAT_MAC_CLCK_MASK	 0x001f0000
 #define  CPMU_CLCK_STAT_MAC_CLCK_62_5	 0x00000000
@@ -2128,6 +2133,10 @@
 #define  NIC_SRAM_RGMII_EXT_IBND_RX_EN	 0x00000008
 #define  NIC_SRAM_RGMII_EXT_IBND_TX_EN	 0x00000010
 
+#define NIC_SRAM_CPMU_STATUS		0x00000e00
+#define  NIC_SRAM_CPMUSTAT_SIG		0x0000362c
+#define  NIC_SRAM_CPMUSTAT_SIG_MSK	0x0000ffff
+
 #define NIC_SRAM_RX_MINI_BUFFER_DESC	0x00001000
 
 #define NIC_SRAM_DMA_DESC_POOL_BASE	0x00002000
-- 
1.7.3.4
