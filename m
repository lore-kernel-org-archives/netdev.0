From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/1] r8169: reset IntrStatus after chip reset
Date: Thu, 2 Apr 2009 00:09:41 +0200
Message-ID: <20090401220941.GA22077@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karsten Wiese <fzu@wemgehoertderstaat.de>,
	Josep <josep.puigdemont@gmail.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:36997 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750863AbZDAWFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 18:05:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Original comment (Karsten):
On a MSI MS-6702E mainboard, when in rtl8169_init_one() for the first time
after BIOS has run, IntrStatus reads 5 after chip has been reset.
IntrStatus should equal 0 there, so patch changes IntrStatus reset to happen
after chip reset instead of before.

Remark (Francois):
Assuming that the loglevel of the driver is increased above NETIF_MSG_INTR,
the bug reveals itself with a typical "interrupt 0025 in poll" message
at startup. In retrospect, the message should had been read as an hint of
an unexpected hardware state several months ago :o(

Fixes (at least part of) https://bugzilla.redhat.com/show_bug.cgi?id=460747

Signed-off-by: Karsten Wiese <fzu@wemgehoertderstaat.de>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Tested-by: Josep <josep.puigdemont@gmail.com>
---
 drivers/net/r8169.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 06c5352..e1a638a 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2075,8 +2075,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (!tp->pcie_cap && netif_msg_probe(tp))
 		dev_info(&pdev->dev, "no PCI Express capability\n");
 
-	/* Unneeded ? Don't mess with Mrs. Murphy. */
-	rtl8169_irq_mask_and_ack(ioaddr);
+	RTL_W16(IntrMask, 0x0000);
 
 	/* Soft reset the chip. */
 	RTL_W8(ChipCmd, CmdReset);
@@ -2088,6 +2087,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		msleep_interruptible(1);
 	}
 
+	RTL_W16(IntrStatus, 0xffff);
+
 	/* Identify chip attached to board */
 	rtl8169_get_mac_version(tp, ioaddr);
 
-- 
1.6.0.6

