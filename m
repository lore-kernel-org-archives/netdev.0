From: akpm@linux-foundation.org
Subject: [patch 3/4] WOL bugfix for 3c59x.c
Date: Tue, 16 Oct 2007 14:24:09 -0700
Message-ID: <200710162124.l9GLO9t6017971@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	klassert@mathematik.tu-chemnitz.de, hcoin@n4comm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35033 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933685AbXJPVZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 17:25:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>

Some NICs (3c905B) can not generate PME in power state PCI_D0, while others
like 3c905C can.  Call pci_enable_wake() with PCI_D3hot should give proper
WOL for 3c905B.

Signed-off-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Tested-by: Harry Coin <hcoin@n4comm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/3c59x.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff -puN drivers/net/3c59x.c~wol-bugfix-for-3c59xc drivers/net/3c59x.c
--- a/drivers/net/3c59x.c~wol-bugfix-for-3c59xc
+++ a/drivers/net/3c59x.c
@@ -3118,7 +3118,13 @@ static void acpi_set_WOL(struct net_devi
 		iowrite16(SetRxFilter|RxStation|RxMulticast|RxBroadcast, ioaddr + EL3_CMD);
 		iowrite16(RxEnable, ioaddr + EL3_CMD);
 
-		pci_enable_wake(VORTEX_PCI(vp), 0, 1);
+		if (pci_enable_wake(VORTEX_PCI(vp), PCI_D3hot, 1)) {
+			printk(KERN_INFO "%s: WOL not supported.\n",
+					pci_name(VORTEX_PCI(vp)));
+
+			vp->enable_wol = 0;
+			return;
+		}
 
 		/* Change the power state to D3; RxEnable doesn't take effect. */
 		pci_set_power_state(VORTEX_PCI(vp), PCI_D3hot);
_
