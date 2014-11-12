From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH] e100: Don't enable WoL by default on Toshiba devices
Date: Wed, 12 Nov 2014 23:47:25 +0100
Message-ID: <1415832445-9524-1-git-send-email-linux@rainbow-software.org>
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: e1000-devel@lists.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enabling WoL on some Toshiba laptops (such as Portege R100) causes battery
drain after shutdown (WoL is active even on battery). These laptops have the
WoL bit set in EEPROM ID, causing e100 driver to enable WoL by default.

Check subsystem vendor ID and if it's Toshiba, don't enable WoL by default
from EEPROM settings.

Fixes https://bugs.launchpad.net/ubuntu/+source/linux/+bug/110784

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/ethernet/intel/e100.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 781065e..daf8fcc 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2949,9 +2949,12 @@ static int e100_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		}
 	}
 
-	/* Wol magic packet can be enabled from eeprom */
-	if ((nic->mac >= mac_82558_D101_A4) &&
-	   (nic->eeprom[eeprom_id] & eeprom_id_wol)) {
+	/* Wol magic packet can be enabled from eeprom
+	 * Don't enable WoL by default on Toshiba laptops as it causes battery
+	 * drain after shutdown */
+	if ((pdev->subsystem_vendor != PCI_VENDOR_ID_TOSHIBA) &&
+	    (nic->mac >= mac_82558_D101_A4) &&
+	    (nic->eeprom[eeprom_id] & eeprom_id_wol)) {
 		nic->flags |= wol_magic;
 		device_set_wakeup_enable(&pdev->dev, true);
 	}
-- 
Ondrej Zary
