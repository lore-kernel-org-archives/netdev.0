From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] r8169: WakeOnLan fix for the 8168
Date: Sat, 25 Jul 2009 00:34:19 +0200
Message-ID: <20090724223419.GA13085@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?iso-8859-1?Q?Jarom=EDr_C=E1p=EDk?= <tavvva@volny.cz>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58893 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754836AbZGXWbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 18:31:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

More stuff for http://bugzilla.kernel.org/show_bug.cgi?id=3D9512

Some 8168 are unable to WoL when receiving is not enabled (plain
old 8169 do not seem to care).

It is not exactly pretty to leave the receiver enabled but we
should now enable DMA late enough for it to be safe. Some late
stage boot failure due to pxe and friends may benefit from the
delayed enabling of bus-mastering as well.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Tested-by: Jarom=EDr C=E1p=EDk <tavvva@volny.cz>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 4b53b58..b82780d 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2060,8 +2060,6 @@ rtl8169_init_one(struct pci_dev *pdev, const stru=
ct pci_device_id *ent)
 		}
 	}
=20
-	pci_set_master(pdev);
-
 	/* ioremap MMIO region */
 	ioaddr =3D ioremap(pci_resource_start(pdev, region), R8169_REGS_SIZE)=
;
 	if (!ioaddr) {
@@ -2089,6 +2087,8 @@ rtl8169_init_one(struct pci_dev *pdev, const stru=
ct pci_device_id *ent)
=20
 	RTL_W16(IntrStatus, 0xffff);
=20
+	pci_set_master(pdev);
+
 	/* Identify chip attached to board */
 	rtl8169_get_mac_version(tp, ioaddr);
=20
@@ -3874,6 +3874,15 @@ static void rtl_shutdown(struct pci_dev *pdev)
 	spin_unlock_irq(&tp->lock);
=20
 	if (system_state =3D=3D SYSTEM_POWER_OFF) {
+		/* WoL fails with some 8168 when the receiver is disabled. */
+		if (tp->features & RTL_FEATURE_WOL) {
+			pci_clear_master(pdev);
+
+			RTL_W8(ChipCmd, CmdRxEnb);
+			/* PCI commit */
+			RTL_R8(ChipCmd);
+		}
+
 		pci_wake_from_d3(pdev, true);
 		pci_set_power_state(pdev, PCI_D3hot);
 	}
--=20
1.6.2.5

