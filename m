From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/2] ixgbe: fix Si errata - require L0's disable on
	upstream device
Date: Sat, 21 Feb 2009 14:23:19 -0800
Message-ID: <20090221222318.6451.16633.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:36857 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750954AbZBUWXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2009 17:23:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

In order to work around a silicon errata on 82598 we need to disable L0's
in the PCIe switch port to which the 82598 is connected, to prevent the
duplicate completions caused by L0s.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   30 +++++++++++++++++++++++++++++-
 1 files changed, 29 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 8c32c18..a935949 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -28,6 +28,7 @@
 #include <linux/types.h>
 #include <linux/module.h>
 #include <linux/pci.h>
+#include <linux/pci-aspm.h>
 #include <linux/netdevice.h>
 #include <linux/vmalloc.h>
 #include <linux/string.h>
@@ -3962,10 +3963,12 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	struct net_device *netdev;
 	struct ixgbe_adapter *adapter = NULL;
 	struct ixgbe_hw *hw;
+	struct pci_dev *us_dev;
 	const struct ixgbe_info *ii = ixgbe_info_tbl[ent->driver_data];
 	static int cards_found;
-	int i, err, pci_using_dac;
+	int i, err, pci_using_dac, pos;
 	u16 link_status, link_speed, link_width;
+	u16 state = 0;
 	u32 part_num, eec;
 
 	err = pci_enable_device(pdev);
@@ -3994,6 +3997,31 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		goto err_pci_reg;
 	}
 
+	/*
+	 * Workaround of Silicon errata on 82598.  Disable L0s in the PCIe
+	 * switch port to which the 82598 is connected to prevent duplicate
+	 * completions caused by L0s.  We check the mac type so that we only
+	 * do this on 82598 devices.
+	 */
+	if (ii->mac == ixgbe_mac_82598EB) {
+		us_dev = pdev->bus->self;
+		pos = pci_find_capability(us_dev, PCI_CAP_ID_EXP);
+		if (pos) {
+			pci_read_config_word(us_dev,
+			                     pos + PCI_EXP_LNKCTL,
+			                     &state);
+			state &= ~PCIE_LINK_STATE_L0S;
+			pci_write_config_word(us_dev,
+			                      pos + PCI_EXP_LNKCTL,
+			                      state);
+			printk(KERN_INFO "ixgbe: Disabling ASPM L0s between "
+			       "%x:%x.%x and %x:%x.%x\n",
+			       us_dev->bus->number, PCI_SLOT(us_dev->devfn),
+			       PCI_FUNC(us_dev->devfn), pdev->bus->number,
+			       PCI_SLOT(pdev->devfn), PCI_FUNC(pdev->devfn));
+		}
+	}
+
 	err = pci_enable_pcie_error_reporting(pdev);
 	if (err) {
 		dev_err(&pdev->dev, "pci_enable_pcie_error_reporting failed "

