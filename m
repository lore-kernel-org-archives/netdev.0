From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 01/14] e1000e: disable correctable errors for quad
	ports while going to D3
Date: Fri, 21 Nov 2008 10:59:00 -0800
Message-ID: <20081121185859.32313.42332.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:37258 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752040AbYKUS7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 13:59:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

There has been an issue seen with the pci-e quad port adapters that will
cause them to generate a pci-e correctable error on some system while
transitioning to D3.

Since no action is needed on this correctable error the simplest solution
is to mask off the reporting of correctable errors.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |   22 +++++++++++++++++++++-
 1 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index cc0502b..ebbb9f0 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4462,7 +4462,27 @@ static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	pci_disable_device(pdev);
 
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+	/*
+	 * The pci-e switch on some quad port adapters will report a
+	 * correctable error when the MAC transitions from D0 to D3.  To
+	 * prevent this we need to mask off the correctable errors on the
+	 * downstream port of the pci-e switch.
+	 */
+	if (adapter->flags & FLAG_IS_QUAD_PORT) {
+		struct pci_dev *us_dev = pdev->bus->self;
+		int pos = pci_find_capability(us_dev, PCI_CAP_ID_EXP);
+		u16 devctl;
+
+		pci_read_config_word(us_dev, pos + PCI_EXP_DEVCTL, &devctl);
+		pci_write_config_word(us_dev, pos + PCI_EXP_DEVCTL,
+		                      (devctl & ~PCI_EXP_DEVCTL_CERE));
+
+		pci_set_power_state(pdev, pci_choose_state(pdev, state));
+
+		pci_write_config_word(us_dev, pos + PCI_EXP_DEVCTL, devctl);
+	} else {
+		pci_set_power_state(pdev, pci_choose_state(pdev, state));
+	}
 
 	return 0;
 }

