From: Karsten Wiese <fzu@wemgehoertderstaat.de>
Subject: Re: [PATCH] r8169: Fix irq masking in rtl8169_interrupt()
Date: Tue, 24 Mar 2009 14:54:15 +0100
Message-ID: <200903241454.15853.fzu@wemgehoertderstaat.de>
References: <200903172034.55241.fzu@wemgehoertderstaat.de> <20090323224222.GA18951@electric-eye.fr.zoreil.com> <200903240138.32805.fzu@wemgehoertderstaat.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Rafael Wysocki <rjw@sisk.pl>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout4.freenet.de ([195.4.92.94]:39200 "EHLO mout4.freenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753739AbZCXNyW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 09:54:22 -0400
In-Reply-To: <200903240138.32805.fzu@wemgehoertderstaat.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag 24 M=E4rz 2009 schrieb Karsten Wiese:
> Am Montag 23 M=E4rz 2009 schrieb Francois Romieu:
> >=20
> > Does the patch below make a difference ?
>=20
> No.

patch below helps.

Thanks,
Karsten
--------------------->
[PATCH] r8169: Reset IntrStatus after chip rest

On a MSI MS-6702E mainboard, when in rtl8169_init_one() for the first t=
ime
after BIOS has run, IntrStatus reads 5 after chip has been reset.
IntrStatus should equal 0 there, so patch changes IntrStatus reset to h=
appen
after chip reset instead of before.
R8169_MSG_DEFAULT is changed to include NETIF_MSG_INTR, because without
an important error message from rtl8169_interrupt() isn't shown by defa=
ult.

Signed-off-by: Karsten Wiese <fzu@wemgehoertderstaat.de>
---
 drivers/net/r8169.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 56a1eb8..b06e153 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -45,8 +45,9 @@
 #define dprintk(fmt, args...)	do {} while (0)
 #endif /* RTL8169_DEBUG */
=20
-#define R8169_MSG_DEFAULT \
-	(NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_IFUP | NETIF_MSG_IFDOWN)
+#define R8169_MSG_DEFAULT					\
+	(NETIF_MSG_DRV | NETIF_MSG_PROBE |			\
+	 NETIF_MSG_IFUP | NETIF_MSG_IFDOWN | NETIF_MSG_INTR)
=20
 #define TX_BUFFS_AVAIL(tp) \
 	(tp->dirty_tx + NUM_TX_DESC - tp->cur_tx - 1)
@@ -2076,7 +2077,7 @@ rtl8169_init_one(struct pci_dev *pdev, const stru=
ct pci_device_id *ent)
 		dev_info(&pdev->dev, "no PCI Express capability\n");
=20
 	/* Unneeded ? Don't mess with Mrs. Murphy. */
-	rtl8169_irq_mask_and_ack(ioaddr);
+	RTL_W16(IntrMask, 0x0000);
=20
 	/* Soft reset the chip. */
 	RTL_W8(ChipCmd, CmdReset);
@@ -2088,6 +2089,11 @@ rtl8169_init_one(struct pci_dev *pdev, const str=
uct pci_device_id *ent)
 		msleep_interruptible(1);
 	}
=20
+	/* On an MSI MS-6702E, when here for the first time after
+	   BIOS has run, IntrStatus contains 5. Play safe.
+	*/
+	RTL_W16(IntrStatus, 0xffff);
+
 	/* Identify chip attached to board */
 	rtl8169_get_mac_version(tp, ioaddr);
=20
--=20
1.6.0.6

