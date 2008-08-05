From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 2/4] e1000e: perform basic 82573 EEPROM checks for known issues
Date: Mon, 04 Aug 2008 17:21:20 -0700
Message-ID: <20080805002047.24137.20065.stgit@localhost.localdomain>
References: <20080805002030.24137.10360.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org, Auke Kok <auke-jan.h.kok@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:34231 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755212AbYHEAVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2008 20:21:22 -0400
In-Reply-To: <20080805002030.24137.10360.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Auke Kok <auke-jan.h.kok@intel.com>

82573 EEPROMs have been shipped out with known issues. While most
people will never see the issues some people do and we know
how to address them. Warn the user if we find one of these
EEPROM issues.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 378335f..589e542 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4177,6 +4177,28 @@ static void e1000_print_device_info(struct e1000_adapter *adapter)
 	       hw->mac.type, hw->phy.type, (pba_num >> 8), (pba_num & 0xff));
 }
 
+static void e1000_eeprom_checks(struct e1000_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	int ret_val;
+	u16 buf = 0;
+
+	if (hw->mac.type != e1000_82573)
+		return;
+
+	ret_val = e1000_read_nvm(hw, NVM_INIT_CONTROL2_REG, 1, &buf);
+	if (!(le16_to_cpu(buf) & (1 << 0))) {
+		/* Deep Smart Power Down (DSPD) */
+		e_warn("Warning: detected DSPD enabled in EEPROM\n");
+	}
+
+	ret_val = e1000_read_nvm(hw, NVM_INIT_3GIO_3, 1, &buf);
+	if (le16_to_cpu(buf) & (3 << 2)) {
+		/* ASPM enable */
+		e_warn("Warning: detected ASPM enabled in EEPROM\n");
+	}
+}
+
 /**
  * e1000e_is_need_ioport - determine if an adapter needs ioport resources or not
  * @pdev: PCI device information struct
@@ -4400,6 +4422,8 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		}
 	}
 
+	e1000_eeprom_checks(adapter);
+
 	/* copy the MAC address out of the NVM */
 	if (e1000e_read_mac_addr(&adapter->hw))
 		e_err("NVM Read Error while reading MAC address\n");

