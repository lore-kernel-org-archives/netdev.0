From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/5] r8169: tweak the PCI data parity error recovery
Date: Mon, 4 Dec 2006 00:58:13 +0100
Message-ID: <20061203235813.GC3625@electric-eye.fr.zoreil.com>
References: <20061203235257.GA3625@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Martin Michlmayr <tbm@cyrius.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Riku Voipio <riku.voipio@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:30598 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1760046AbWLCX7G
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 18:59:06 -0500
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <20061203235257.GA3625@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 8110SB based n2100 board signals a lot of what ought to be
PCI data parity errors durint operation of the 8169 as target.
Experiment proved that the driver can ignore the error and
process the packet as if nothing had happened.

Let's add an ad-hoc knob to enable users to fix their system while
avoiding the risks of a wholesale change.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index c8fa9b1..7438049 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -225,6 +225,7 @@ MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl
 
 static int rx_copybreak = 200;
 static int use_dac;
+static int ignore_parity_err;
 static struct {
 	u32 msg_enable;
 } debug = { -1 };
@@ -469,6 +470,8 @@ module_param(use_dac, int, 0);
 MODULE_PARM_DESC(use_dac, "Enable PCI DAC. Unsafe on 32 bit PCI slot.");
 module_param_named(debug, debug.msg_enable, int, 0);
 MODULE_PARM_DESC(debug, "Debug verbosity level (0=none, ..., 16=all)");
+module_param_named(ignore_parity_err, ignore_parity_err, bool, 0);
+MODULE_PARM_DESC(ignore_parity_err, "Ignore PCI parity error as target. Default: false");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(RTL8169_VERSION);
 
@@ -2380,12 +2383,17 @@ static void rtl8169_pcierr_interrupt(str
 	/*
 	 * The recovery sequence below admits a very elaborated explanation:
 	 * - it seems to work;
-	 * - I did not see what else could be done.
+	 * - I did not see what else could be done;
+	 * - it makes iop3xx happy.
 	 *
 	 * Feel free to adjust to your needs.
 	 */
-	pci_write_config_word(pdev, PCI_COMMAND,
-			      pci_cmd | PCI_COMMAND_SERR | PCI_COMMAND_PARITY);
+	if (ignore_parity_err)
+		pci_cmd &= ~PCI_COMMAND_PARITY;
+	else
+		pci_cmd |= PCI_COMMAND_SERR | PCI_COMMAND_PARITY;
+
+	pci_write_config_word(pdev, PCI_COMMAND, pci_cmd);
 
 	pci_write_config_word(pdev, PCI_STATUS,
 		pci_status & (PCI_STATUS_DETECTED_PARITY |
@@ -2399,10 +2407,11 @@ static void rtl8169_pcierr_interrupt(str
 		tp->cp_cmd &= ~PCIDAC;
 		RTL_W16(CPlusCmd, tp->cp_cmd);
 		dev->features &= ~NETIF_F_HIGHDMA;
-		rtl8169_schedule_work(dev, rtl8169_reinit_task);
 	}
 
 	rtl8169_hw_reset(ioaddr);
+
+	rtl8169_schedule_work(dev, rtl8169_reinit_task);
 }
 
 static void
-- 
1.4.2.3
