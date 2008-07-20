From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/2] r8169: avoid thrashing PCI conf space above
	RTL_GIGA_MAC_VER_06
Date: Sun, 20 Jul 2008 20:06:57 +0200
Message-ID: <20080720180657.GC31465@electric-eye.fr.zoreil.com>
References: <20080720180451.GA31465@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=unknown-8bit
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Marcus Sundberg <marcus@ingate.com>,
	Johan =?unknown-8bit?Q?Myr=C3=A9en?= <jem@iki.fi>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	David Miller <davem@davemloft.net>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:35151 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757690AbYGTSHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 14:07:44 -0400
Content-Disposition: inline
In-Reply-To: <20080720180451.GA31465@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The magic write to register 0x82 will often cause PCI config space on
my 8168 (PCI ID 10ec:8168, revision 2. mounted in an LG P300 laptop)
to be filled with ones during driver load, and thus breaking NIC
operation until reboot. If it does not happen on first driver load it
can easily be reproduced by unloading and loading the driver a few
times.

The magic write was added long ago by this commit:

Author: Fran=C3=A7ois Romieu <romieu@fr.zoreil.com>
Date:   Sat Jan 10 06:00:46 2004 -0500

     [netdrvr r8169] Merge of changes done by Realtek to rtl8169_init_o=
ne():
     - phy capability settings allows lower or equal capability as sugg=
ested
       in Realtek's changes;
     - I/O voodoo;
     - no need to s/mdio_write/RTL8169_WRITE_GMII_REG/;
     - s/rtl8169_hw_PHY_config/rtl8169_hw_phy_config/;
     - rtl8169_hw_phy_config(): ad-hoc struct "phy_magic" to limit dupl=
ication
       of code (yep, the u16 -> int conversions should work as expected=
);
     - variable renames and whitepace changes ignored.

As the 8168 wasn't supported by that version this patch simply removes
the bogus write from mac versions <=3D RTL_GIGA_MAC_VER_06.

[The change above makes sense for the 8101/8102 too -- Ueimor]

Signed-off-by: Marcus Sundberg <marcus@ingate.com>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 2a5486f..a3e3895 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1418,8 +1418,10 @@ static void rtl8169_init_phy(struct net_device *=
dev, struct rtl8169_private *tp)
=20
 	rtl_hw_phy_config(dev);
=20
-	dprintk("Set MAC Reg C+CR Offset 0x82h =3D 0x01h\n");
-	RTL_W8(0x82, 0x01);
+	if (tp->mac_version <=3D RTL_GIGA_MAC_VER_06) {
+		dprintk("Set MAC Reg C+CR Offset 0x82h =3D 0x01h\n");
+		RTL_W8(0x82, 0x01);
+	}
=20
 	pci_write_config_byte(tp->pci_dev, PCI_LATENCY_TIMER, 0x40);
=20
--=20
1.5.3.3

