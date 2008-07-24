From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch inside] kernel crash, RTL8101E [10ec:8136]
Date: Thu, 24 Jul 2008 23:02:45 +0200
Message-ID: <20080724210245.GA27489@electric-eye.fr.zoreil.com>
References: <200807241534.m6OFYBmc029095@post.webmailer.de> <f56c1ba00807240857xd5b2e84q9c3fc9642fd68dc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: martin capitanio <martin@capitanio.org>,
	Mario Limonciello <Mario_Limonciello@dell.com>,
	kernel@vger.kernel.org, netdev@vger.kernel.org,
	c4p7n1@capitanio.org
To: =?iso-8859-1?Q?C=E9dric?= Augonnet <cedric.augonnet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:45284 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751350AbYGXVDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 17:03:15 -0400
Content-Disposition: inline
In-Reply-To: <f56c1ba00807240857xd5b2e84q9c3fc9642fd68dc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

C=E9dric Augonnet <cedric.augonnet@gmail.com> :
> Hi all,
>=20
> >        case RTL_GIGA_MAC_VER_04:
> >                rtl8169sb_hw_phy_config(ioaddr);
> >                break;
> > +       case RTL_GIGA_MAC_VER_13:
> > +       case RTL_GIGA_MAC_VER_16:
> > +               rtl8101_hw_phy_config(ioaddr);
>=20
> Should not there be a "break;" here or is it intended to go through
> the next case as well?

8101 and 8102 should be handled differently, yes.

On top of curent 2.6.26-git, it could look like:

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index a3e3895..86ee894 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -95,6 +95,10 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_04 =3D 0x04, // 8169SB
 	RTL_GIGA_MAC_VER_05 =3D 0x05, // 8110SCd
 	RTL_GIGA_MAC_VER_06 =3D 0x06, // 8110SCe
+	RTL_GIGA_MAC_VER_07 =3D 0x07, // 8102e
+	RTL_GIGA_MAC_VER_08 =3D 0x08, // 8102e
+	RTL_GIGA_MAC_VER_09 =3D 0x09, // 8102e
+	RTL_GIGA_MAC_VER_10 =3D 0x0a, // 8101e
 	RTL_GIGA_MAC_VER_11 =3D 0x0b, // 8168Bb
 	RTL_GIGA_MAC_VER_12 =3D 0x0c, // 8168Be
 	RTL_GIGA_MAC_VER_13 =3D 0x0d, // 8101Eb
@@ -121,6 +125,10 @@ static const struct {
 	_R("RTL8169sb/8110sb",	RTL_GIGA_MAC_VER_04, 0xff7e1880), // 8169SB
 	_R("RTL8169sc/8110sc",	RTL_GIGA_MAC_VER_05, 0xff7e1880), // 8110SCd
 	_R("RTL8169sc/8110sc",	RTL_GIGA_MAC_VER_06, 0xff7e1880), // 8110SCe
+	_R("RTL8102e",		RTL_GIGA_MAC_VER_07, 0xff7e1880), // PCI-E
+	_R("RTL8102e",		RTL_GIGA_MAC_VER_08, 0xff7e1880), // PCI-E
+	_R("RTL8102e",		RTL_GIGA_MAC_VER_09, 0xff7e1880), // PCI-E
+	_R("RTL8101e",		RTL_GIGA_MAC_VER_10, 0xff7e1880), // PCI-E
 	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_11, 0xff7e1880), // PCI-E
 	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_12, 0xff7e1880), // PCI-E
 	_R("RTL8101e",		RTL_GIGA_MAC_VER_13, 0xff7e1880), // PCI-E 8139
@@ -482,6 +490,11 @@ static int mdio_read(void __iomem *ioaddr, int reg=
_addr)
 	return value;
 }
=20
+static void mdio_patch(void __iomem *ioaddr, int reg_addr, int value)
+{
+	mdio_write(ioaddr, reg_addr, mdio_read(ioaddr, reg_addr) | value);
+}
+
 static void rtl8169_irq_mask_and_ack(void __iomem *ioaddr)
 {
 	RTL_W16(IntrMask, 0x0000);
@@ -1116,8 +1129,16 @@ static void rtl8169_get_mac_version(struct rtl81=
69_private *tp,
 		{ 0x7c800000, 0x30000000,	RTL_GIGA_MAC_VER_11 },
=20
 		/* 8101 family. */
+		{ 0x7cf00000, 0x34a00000,	RTL_GIGA_MAC_VER_09 },
+		{ 0x7cf00000, 0x24a00000,	RTL_GIGA_MAC_VER_09 },
+		{ 0x7cf00000, 0x34900000,	RTL_GIGA_MAC_VER_08 },
+		{ 0x7cf00000, 0x24900000,	RTL_GIGA_MAC_VER_08 },
+		{ 0x7cf00000, 0x34800000,	RTL_GIGA_MAC_VER_07 },
+		{ 0x7cf00000, 0x24800000,	RTL_GIGA_MAC_VER_07 },
 		{ 0x7cf00000, 0x34000000,	RTL_GIGA_MAC_VER_13 },
+		{ 0x7cf00000, 0x34300000,	RTL_GIGA_MAC_VER_10 },
 		{ 0x7cf00000, 0x34200000,	RTL_GIGA_MAC_VER_16 },
+		{ 0x7c800000, 0x34800000,	RTL_GIGA_MAC_VER_09 },
 		{ 0x7c800000, 0x34000000,	RTL_GIGA_MAC_VER_16 },
 		/* FIXME: where did these entries come from ? -- FR */
 		{ 0xfc800000, 0x38800000,	RTL_GIGA_MAC_VER_15 },
@@ -1279,6 +1300,22 @@ static void rtl8168cx_hw_phy_config(void __iomem=
 *ioaddr)
 	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
=20
+static void rtl8102e_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] =3D {
+		{ 0x1f, 0x0003 },
+		{ 0x08, 0x441d },
+		{ 0x01, 0x9100 },
+		{ 0x1f, 0x0000 }
+	};
+
+	mdio_write(ioaddr, 0x1f, 0x0000);
+	mdio_patch(ioaddr, 0x11, 1 << 12);
+	mdio_patch(ioaddr, 0x19, 1 << 13);
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
 static void rtl_hw_phy_config(struct net_device *dev)
 {
 	struct rtl8169_private *tp =3D netdev_priv(dev);
@@ -1296,6 +1333,11 @@ static void rtl_hw_phy_config(struct net_device =
*dev)
 	case RTL_GIGA_MAC_VER_04:
 		rtl8169sb_hw_phy_config(ioaddr);
 		break;
+	case RTL_GIGA_MAC_VER_07:
+	case RTL_GIGA_MAC_VER_08:
+	case RTL_GIGA_MAC_VER_09:
+		rtl8102e_hw_phy_config(ioaddr);
+		break;
 	case RTL_GIGA_MAC_VER_18:
 		rtl8168cp_hw_phy_config(ioaddr);
 		break;
---

On top of 2.6.26, one needs to apply beforehand:

http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commit;h=3Df887cce8de019bb32917789379af89ae4c0294ee
http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commit;h=3D77332894c21165404496c56763d7df6c15c4bb09

--=20
Ueimor
