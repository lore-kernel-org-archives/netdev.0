From: Daniele Venzano <webvenza@libero.it>
Subject: Re: [PATCH] WOL for sis900
Date: Sat, 30 Oct 2004 21:00:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041030185959.GA7088@renditai.milesteg.arr>
References: <4183B6B0.7010906@gmx.de> <4183BDB3.8000302@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="J2SCkAp4GZ/dPZZf"
Cc: Malte =?iso-8859-1?Q?Schr=F6der?= <MalteSch@gmx.de>,
        Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>
Content-Disposition: inline
In-Reply-To: <4183BDB3.8000302@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id i9UJ2U0M004794

On Sat, Oct 30, 2004 at 12:13:39PM -0400, Jeff Garzik wrote:
> Malte Schr=F6der wrote:
> >Hello,
> >I have applied the patch from http://lkml.org/lkml/2003/7/16/88 manual=
ly=20
> >to 2.6.7 (also works on 2.6.{8,9}) and have been using it since then.
> >Attached is a diff against 2.6.9.
>=20
> 2) Please use ethtool to enable/disable WOL.  No need for a module opti=
on.

Attached is a first try at this wol via ethtool thing. I don't think to
have got it right, but here it is.

I tried to test WoL on my laptop, obvioulsy it didn't work, but I don't
even know if I have the hardware support for it.
On this page:
http://www.sis.com/products/connectivity/900.htm
it says that the magic packet feature is optional.

I would really like to have some way to check if WoL is supported by the
hardware before thinking to include this. I didn't find any
documentation of some use for this.

Finally, I have never realized the sorry state of sis900 wrt ethtool,
I'll try to get some more support...

The attached patch is against clean 2.6.9 and is NOT for inclusion.

--=20
------------------------------
Daniele Venzano
Web: http://teg.homeunix.org

--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sis900_wol_ethtool.diff"

Index: sis900.c
===================================================================
--- sis900.c	(revision 13)
+++ sis900.c	(working copy)
@@ -120,6 +120,7 @@
 } mii_chip_table[] = {
 	{ "SiS 900 Internal MII PHY", 		0x001d, 0x8000, LAN },
 	{ "SiS 7014 Physical Layer Solution", 	0x0016, 0xf830, LAN },
+	{ "Altimata AC101LF PHY",               0x0022, 0x5520, LAN },
 	{ "AMD 79C901 10BASE-T PHY",  		0x0000, 0x6B70, LAN },
 	{ "AMD 79C901 HomePNA PHY",		0x0000, 0x6B90, HOME},
 	{ "ICS LAN PHY",			0x0015, 0xF440, LAN },
@@ -1903,8 +1904,41 @@
 	strcpy (info->bus_info, pci_name(sis_priv->pci_dev));
 }
 
+static int sis900_set_wol(struct net_device *net_dev, struct ethtool_wolinfo *wol)
+{
+	struct sis900_private *sis_priv = net_dev->priv;
+	long ioaddr = net_dev->base_addr;
+	u32 cfgpmcsr;
+	
+	if (wol->wolopts & WAKE_MAGIC) {
+		pci_read_config_dword(sis_priv->pci_dev, CFGPMCSR, &cfgpmcsr);
+		cfgpmcsr |= PME_EN;
+		pci_write_config_dword(sis_priv->pci_dev, CFGPMCSR, cfgpmcsr);
+		outl(inl(ioaddr + pmctrl) | MAGICPKT | ALGORITHM, ioaddr + pmctrl);
+	} else if (wol->wolopts) {
+		return -EINVAL;
+	} else {
+		pci_read_config_dword(sis_priv->pci_dev, CFGPMCSR, &cfgpmcsr);
+		cfgpmcsr |= ~PME_EN;
+		pci_write_config_dword(sis_priv->pci_dev, CFGPMCSR, cfgpmcsr);
+		outl(inl(ioaddr + pmctrl) & ~MAGICPKT, ioaddr + pmctrl);
+	}
+
+	return 0;
+}
+
+static void sis900_get_wol(struct net_device *net_dev, struct ethtool_wolinfo *wol)
+{
+	long ioaddr = net_dev->base_addr;
+
+	if (inl(ioaddr + pmctrl) & MAGICPKT, ioaddr + pmctrl)
+		wol->wolopts |= WAKE_MAGIC;
+}
+
 static struct ethtool_ops sis900_ethtool_ops = {
 	.get_drvinfo =		sis900_get_drvinfo,
+	.get_wol =		sis900_get_wol,
+	.set_wol =		sis900_set_wol,	
 };
 
 /**
Index: sis900.h
===================================================================
--- sis900.h	(revision 13)
+++ sis900.h	(working copy)
@@ -140,6 +140,25 @@
 	EEREQ = 0x00000400, EEDONE = 0x00000200, EEGNT = 0x00000100
 };
 
+/* Wake-on-LAN support. */
+enum sis900_power_management_control_register_bits {
+	LINKLOSS  = 0x00000001,
+	LINKON    = 0x00000002,
+	MAGICPKT  = 0x00000400,
+	ALGORITHM = 0x00000800,
+	FRM1EN    = 0x00100000,
+	FRM2EN    = 0x00200000,
+	FRM3EN    = 0x00400000,
+	FRM1ACS   = 0x01000000,
+	FRM2ACS   = 0x02000000,
+	FRM3ACS   = 0x04000000,
+	WAKEALL   = 0x40000000,
+	GATECLK   = 0x80000000
+};
+
+#define CFGPMCSR 0x44
+#define PME_EN 0x100
+
 /* Management Data I/O (mdio) frame */
 #define MIIread         0x6000
 #define MIIwrite        0x5002

--J2SCkAp4GZ/dPZZf--
