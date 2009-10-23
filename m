From: Naohiro Ooiwa <nooiwa@miraclelinux.com>
Subject: [PATCH] e1000: the power down when running ifdown command
Date: Fri, 23 Oct 2009 19:29:02 +0900
Message-ID: <4AE1856E.9090904@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	svaidy@linux.vnet.ibm.com, e1000-devel@lists.sourceforge.net,
	linux-kernel-owner@vger.kernel.org, akpm@linux-foundation.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Joh
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw.miraclelinux.com ([122.216.84.157]:10504 "EHLO
	mailgw.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450AbZJWK3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 06:29:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I resend the mail to maintainers of the e1000 driver.
and Andrew CC-ed.

-------- Original Message --------

Hi all

I'm trying to modify e1000 driver for power saving.

The e1000 driver doesn't let the power down when running ifdown command.
So, I set to the D3hot state of a PCI device at the end of e1000_close().

With this modification, e1000 driver reduces power by ifdown
to the same level as link-down case.

I spoke it in Collaboration Summit 2009.
For details and result of power measurement,
please refer the 36-38 page of following document.
http://events.linuxfoundation.org/archive/lfcs09_ooiwa.pdf

Could you please check the my patch ?

Should I consider WOL ?
Dosen't E1000_PCI_POWER_SAVE need ?


Thanks you.
Naohiro Ooiwa

Signed-off-by: Naohiro Ooiwa <nooiwa@miraclelinux.com>
---
 drivers/net/e1000/e1000_main.c |   32 ++++++++++++++++++++++++++++++++
 1 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index bcd192c..12e1a42 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -26,6 +26,11 @@

 *******************************************************************************/

+/*
+ * define this if you want pci save power while ifdown.
+ */
+#define E1000_PCI_POWER_SAVE
+
 #include "e1000.h"
 #include <net/ip6_checksum.h>

@@ -1248,6 +1253,23 @@ static int e1000_open(struct net_device *netdev)
 	struct e1000_hw *hw = &adapter->hw;
 	int err;

+#ifdef E1000_PCI_POWER_SAVE
+	struct pci_dev *pdev = adapter->pdev;
+
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+
+	if (adapter->need_ioport)
+		err = pci_enable_device(pdev);
+	else
+		err = pci_enable_device_mem(pdev);
+	if (err) {
+		printk(KERN_ERR "e1000: Cannot enable PCI device from power-save\n");
+		return err;
+	}
+	pci_set_master(pdev);
+#endif
+
 	/* disallow open during test */
 	if (test_bit(__E1000_TESTING, &adapter->flags))
 		return -EBUSY;
@@ -1265,6 +1287,7 @@ static int e1000_open(struct net_device *netdev)
 		goto err_setup_rx;

 	e1000_power_up_phy(adapter);
+	e1000_reset(adapter);

 	adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
 	if ((hw->mng_cookie.status &
@@ -1341,6 +1364,15 @@ static int e1000_close(struct net_device *netdev)
 		e1000_vlan_rx_kill_vid(netdev, adapter->mng_vlan_id);
 	}

+#ifdef E1000_PCI_POWER_SAVE
+#ifdef CONFIG_PM
+	pci_save_state(adapter->pdev);
+#endif
+	pci_disable_device(adapter->pdev);
+	pci_wake_from_d3(adapter->pdev, true);
+	pci_set_power_state(adapter->pdev, PCI_D3hot);
+#endif
+
 	return 0;
 }

-- 
1.5.4.1

--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

