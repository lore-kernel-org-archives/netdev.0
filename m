From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 4/7] tg3: Determine PCI function number in one
 place
Date: Wed, 13 Jul 2011 12:27:30 -0700
Message-ID: <1310585253-4817-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3271 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750745Ab1GMT2D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2011 15:28:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tg3 devices will need to know exactly what function number they are so
that they can communicate their status to the other functions.  In a KVM
environment, the function number of a device presented by the kernel
might not be the true function number, so an alternative method to
determine the function number is needed.

This patch used to contain an implementation for the alternative method,
but recently we discovered a hardware bug that renders it incorrect.
While new method is not yet known, it is still useful to consolidate the
code that determines the PCI function to one location and use the
results throughout the code.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |   14 +++++++++++---
 drivers/net/tg3.h |    1 +
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5d4283e..6f1f36c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1170,7 +1170,7 @@ static int tg3_mdio_init(struct tg3 *tp)
 	if (tg3_flag(tp, 5717_PLUS)) {
 		u32 is_serdes;
 
-		tp->phy_addr = PCI_FUNC(tp->pdev->devfn) + 1;
+		tp->phy_addr = tp->pci_fn + 1;
 
 		if (tp->pci_chip_rev_id != CHIPREV_ID_5717_A0)
 			is_serdes = tr32(SG_DIG_STATUS) & SG_DIG_IS_SERDES;
@@ -13951,6 +13951,14 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	val = tr32(MEMARB_MODE);
 	tw32(MEMARB_MODE, val | MEMARB_MODE_ENABLE);
 
+	if (tg3_flag(tp, PCIX_MODE)) {
+		pci_read_config_dword(tp->pdev,
+				      tp->pcix_cap + PCI_X_STATUS, &val);
+		tp->pci_fn = val & 0x7;
+	} else {
+		tp->pci_fn = PCI_FUNC(tp->pdev->devfn) & 3;
+	}
+
 	/* Get eeprom hw config before calling tg3_set_power_state().
 	 * In particular, the TG3_FLAG_IS_NIC flag must be
 	 * determined before calling tg3_set_power_state() so that
@@ -14316,9 +14324,9 @@ static int __devinit tg3_get_device_address(struct tg3 *tp)
 		else
 			tg3_nvram_unlock(tp);
 	} else if (tg3_flag(tp, 5717_PLUS)) {
-		if (PCI_FUNC(tp->pdev->devfn) & 1)
+		if (tp->pci_fn & 1)
 			mac_offset = 0xcc;
-		if (PCI_FUNC(tp->pdev->devfn) > 1)
+		if (tp->pci_fn > 1)
 			mac_offset += 0x18c;
 	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 		mac_offset = 0x10;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 5f250ae..b4c003d 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -3020,6 +3020,7 @@ struct tg3 {
 	u8				pci_cacheline_sz;
 	u8				pci_lat_timer;
 
+	int				pci_fn;
 	int				pm_cap;
 	int				msi_cap;
 	int				pcix_cap;
-- 
1.7.3.4


