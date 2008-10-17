From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] igb: fix tx data corruption with transition to L0s on 82575
Date: Thu, 16 Oct 2008 21:26:57 -0700
Message-ID: <20081017042657.7080.17171.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:37191
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750801AbYJQE1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 00:27:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The 82575 has an issue in which the DMA will go out of sync if the link
partner goes into an L0s state.  To prevent this we set the pci-e link
partner capability bits to disable the L0s transition on the hw.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   27 +++++++++++++++++++++++++--
 1 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 93d02ef..53cbeae 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -966,10 +966,11 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	struct net_device *netdev;
 	struct igb_adapter *adapter;
 	struct e1000_hw *hw;
+	struct pci_dev *us_dev;
 	const struct e1000_info *ei = igb_info_tbl[ent->driver_data];
 	unsigned long mmio_start, mmio_len;
-	int i, err, pci_using_dac;
-	u16 eeprom_data = 0;
+	int i, err, pci_using_dac, pos;
+	u16 eeprom_data = 0, state = 0;
 	u16 eeprom_apme_mask = IGB_EEPROM_APME;
 	u32 part_num;
 	int bars, need_ioport;
@@ -1004,6 +1005,28 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		}
 	}
 
+	/* 82575 requires that the pci-e link partner disable the L0s state */
+	switch (pdev->device) {
+	case E1000_DEV_ID_82575EB_COPPER:
+	case E1000_DEV_ID_82575EB_FIBER_SERDES:
+	case E1000_DEV_ID_82575GB_QUAD_COPPER:
+		us_dev = pdev->bus->self;
+		pos = pci_find_capability(us_dev, PCI_CAP_ID_EXP);
+		if (pos) {
+			pci_read_config_word(us_dev, pos + PCI_EXP_LNKCTL,
+			                     &state);
+			state &= ~PCIE_LINK_STATE_L0S;
+			pci_write_config_word(us_dev, pos + PCI_EXP_LNKCTL,
+			                      state);
+			printk(KERN_INFO "Disabling ASPM L0s upstream switch "
+			       "port %x:%x.%x\n", us_dev->bus->number,
+			       PCI_SLOT(us_dev->devfn),
+			       PCI_FUNC(us_dev->devfn));
+		}
+	default:
+		break;
+	}
+
 	err = pci_request_selected_regions(pdev, bars, igb_driver_name);
 	if (err)
 		goto err_pci_reg;

