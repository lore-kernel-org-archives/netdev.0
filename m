From: "Jyri Reitel" <jyri.reitel@mail.ee>
Subject: [PATCH 2.6.11.1] net/8139cp.c - get and set eeprom II
Date: Thu, 24 Mar 2005 17:02:02 +0200
Message-ID: <200503241502.j2OF22ZS018789@mail-fe79.tele2.ee>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="=_d4e681fa30c2f538507875941c625129"
Cc: <jgarzik@pobox.com>, <mroos@linux.ee>
To: <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=_d4e681fa30c2f538507875941c625129
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id j2OF5iQ0030926

Hi. My next patch where removed the pci table modification because most p=
eople don't want (need) this.
Also indentification should be ok now?

When answering please add jyri.reitel@mail.ee to the cc line, because i'm=
 not the member of the mainling list

Signed-off-by: J=FCri Reitel <jyri.reitel@mail.ee>

--- linux-2.6.11.1/drivers/net/8139cp.c.orig	Thu Mar 24 10:08:32 2005
+++ linux-2.6.11.1/drivers/net/8139cp.c	Thu Mar 24 16:37:42 2005
@@ -110,6 +110,11 @@ MODULE_PARM_DESC (multicast_filter_limit
 #define TRUE (!FALSE)
 #endif
=20
+#define RTL8139_EEPROM_SIZE 128
+static int get_eeprom(struct net_device *dev, struct ethtool_eeprom *eep=
rom, u8 *data);
+static int set_eeprom(struct net_device *dev, struct ethtool_eeprom *eep=
rom, u8 *data);
+static int get_eeprom_len(struct net_device *dev);
+
 #define CP_DEF_MSG_ENABLE	(NETIF_MSG_DRV		| \
 				 NETIF_MSG_PROBE 	| \
 				 NETIF_MSG_LINK)
@@ -400,6 +405,15 @@ static struct pci_device_id cp_pci_tbl[]
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, },
 	{ PCI_VENDOR_ID_TTTECH, PCI_DEVICE_ID_TTTECH_MC322,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, },
+
+	/*=20
+	* comment out this when the eeprom is corrupted or not preprogrammed
+	* and you want this driver to be loaded, thus allowing to program=20
+	* the eeprom with ethtool
+	* It would be good idea not to compile 8139too driver then
+	{ PCI_VENDOR_ID_REALTEK, PCI_DEVICE_ID_REALTEK_8129,
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, },
+	*/
 	{ },
 };
 MODULE_DEVICE_TABLE(pci, cp_pci_tbl);
@@ -1543,6 +1557,9 @@ static struct ethtool_ops cp_ethtool_ops
 	.set_wol		=3D cp_set_wol,
 	.get_strings		=3D cp_get_strings,
 	.get_ethtool_stats	=3D cp_get_ethtool_stats,
+	.get_eeprom		=3D get_eeprom,
+	.set_eeprom		=3D set_eeprom,
+	.get_eeprom_len		=3D get_eeprom_len,
 };
=20
 static int cp_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
@@ -1566,8 +1583,8 @@ static int cp_ioctl (struct net_device *
 #define EE_SHIFT_CLK	0x04	/* EEPROM shift clock. */
 #define EE_CS			0x08	/* EEPROM chip select. */
 #define EE_DATA_WRITE	0x02	/* EEPROM chip data in. */
-#define EE_WRITE_0		0x00
-#define EE_WRITE_1		0x02
+#define EE_WRITE_0		(0x00 | EE_ENB)
+#define EE_WRITE_1		(0x02 | EE_ENB)
 #define EE_DATA_READ	0x01	/* EEPROM chip data out. */
 #define EE_ENB			(0x80 | EE_CS)
=20
@@ -1582,7 +1599,7 @@ static int cp_ioctl (struct net_device *
 #define EE_READ_CMD		(6)
 #define EE_ERASE_CMD	(7)
=20
-static int read_eeprom (void __iomem *ioaddr, int location, int addr_len=
)
+static int read_eeprom(void __iomem *ioaddr, int location, int addr_len)
 {
 	int i;
 	unsigned retval =3D 0;
@@ -1608,8 +1625,7 @@ static int read_eeprom (void __iomem *io
 		writeb (EE_ENB | EE_SHIFT_CLK, ee_addr);
 		eeprom_delay ();
 		retval =3D
-		    (retval << 1) | ((readb (ee_addr) & EE_DATA_READ) ? 1 :
-				     0);
+		    (retval << 1) | ((readb (ee_addr) & EE_DATA_READ) ? 1 : 0);
 		writeb (EE_ENB, ee_addr);
 		eeprom_delay ();
 	}
@@ -1619,6 +1635,130 @@ static int read_eeprom (void __iomem *io
 	eeprom_delay ();
=20
 	return retval;
+}
+
+/* This executes a generic EEPROM command, typically a write or write en=
able.
+   It returns the data output from the EEPROM, and thus may also be used=
 for
+   reads. */
+static int do_eeprom_cmd(void __iomem *ioaddr, int cmd, int cmd_len)
+{
+	unsigned retval =3D 0;
+	void __iomem *ee_addr =3D ioaddr + Cfg9346;
+
+	writeb(EE_ENB | EE_SHIFT_CLK, ee_addr);
+
+	/* Shift the command bits out. */
+	do {
+		short dataval =3D (cmd & (1 << cmd_len)) ? EE_WRITE_1 : EE_WRITE_0;
+		writeb(dataval, ee_addr);
+		eeprom_delay();
+		writeb(dataval | EE_SHIFT_CLK, ee_addr);
+		eeprom_delay();
+		retval =3D (retval << 1) | ((readb(ee_addr) & EE_DATA_READ) ? 1 : 0);
+	} while (--cmd_len >=3D 0);
+	writeb(EE_ENB, ee_addr);
+
+	/* Terminate the EEPROM access. */
+	writeb(EE_ENB & ~EE_CS, ee_addr);
+	writeb(~EE_CS, ee_addr);
+	return retval;
+}
+
+
+static void write_eeprom(void __iomem *ioaddr, int index, u16 value, int=
 ee_addr_size)
+{
+	int i;
+	/* Enable programming modes. */
+	do_eeprom_cmd(ioaddr, (0x4f << (ee_addr_size - 4)), 3 + ee_addr_size);
+	/* Do the actual write. */
+	do_eeprom_cmd(ioaddr,
+		(((EE_WRITE_CMD << ee_addr_size) | index) << 16) | value,
+		3 + ee_addr_size + 16
+	);
+	/* Poll for write finished. */
+	writeb(EE_ENB, ioaddr + Cfg9346);
+	for (i =3D 0; i < 10000; i++)			/* Typical 2000 ticks */
+		if (readb(ioaddr + Cfg9346) & EE_DATA_READ)
+			break;
+	/* Disable programming. */
+	do_eeprom_cmd(ioaddr, (0x40 << (ee_addr_size - 4)), 3 + ee_addr_size);
+}
+
+
+static int get_eeprom_len(struct net_device *dev)
+{
+	return RTL8139_EEPROM_SIZE;
+}
+
+static int get_eeprom(struct net_device *dev, struct ethtool_eeprom *eep=
rom, u8 *data)
+{
+	struct cp_private *cp =3D netdev_priv(dev);
+	unsigned int addr_len;
+	u16 eep_data_word =3D 0;
+	u32 i;
+
+	eeprom->magic =3D PCI_VENDOR_ID_REALTEK | (PCI_DEVICE_ID_REALTEK_8139 <=
< 16);
+	spin_lock_irq(&cp->lock);
+
+	addr_len =3D (read_eeprom(cp->regs, 0, 8) =3D=3D 0x8129)? 8 : 6;
+
+	/* reading word by word from the eeprom */
+
+	if (eeprom->offset & 1) {
+		/* offset is odd */
+		eep_data_word =3D le16_to_cpu(read_eeprom(cp->regs, eeprom->offset >> =
1, addr_len));
+	}
+	for (i =3D eeprom->offset; i < (eeprom->offset + eeprom->len); i++) {
+		if (i & 1) {
+			/* copy odd byte */
+			data[i - eeprom->offset] =3D (u8)(eep_data_word >> 8);
+		} else {
+			/* reading even byte so lets fech next word from eeprom */
+			eep_data_word =3D le16_to_cpu(read_eeprom(cp->regs, i >> 1, addr_len)=
);
+			data[i - eeprom->offset] =3D (u8)eep_data_word;
+		}
+	}
+	spin_unlock_irq(&cp->lock);
+	return 0;
+}
+
+static int set_eeprom(struct net_device *dev, struct ethtool_eeprom *eep=
rom, u8 *data)
+{
+	struct cp_private *cp =3D netdev_priv(dev);
+	unsigned int addr_len;
+	u16 eep_data_word =3D 0;
+	u32 i;
+	/*
+	if(eeprom->magic !=3D (PCI_VENDOR_ID_REALTEK | (PCI_DEVICE_ID_REALTEK_8=
139 << 16))) {
+		return -ENODEV;
+	}
+	*/
+	spin_lock_irq(&cp->lock);
+
+	addr_len =3D (read_eeprom(cp->regs, 0, 8) =3D=3D 0x8129)? 8 : 6;
+
+	if (eeprom->offset & 1) {
+		/* offset is odd, so read the word to later replace MSB byte */
+		eep_data_word =3D le16_to_cpu(read_eeprom(cp->regs, eeprom->offset >> =
1, addr_len));
+	}
+	for (i =3D eeprom->offset; i < (eeprom->offset + eeprom->len); i++) {
+		if (i & 1) {
+			/* copy odd byte, to the word data to be stored to the eeprom */
+			eep_data_word |=3D (u16)data[i - eeprom->offset] << 8;
+			write_eeprom(cp->regs, i >> 1, eep_data_word, addr_len);
+		} else {
+			/* reading even byte so lets fech next word from eeprom */
+			eep_data_word =3D (u16)data[i - eeprom->offset];
+			if (i + 1 =3D=3D (eeprom->offset + eeprom->len)) {
+				/* when writing last byte that is LSB, i.e. must get the MSB from ee=
prom */
+				eep_data_word |=3D le16_to_cpu(read_eeprom(cp->regs, i >> 1, addr_le=
n)) & 0xFF00;
+				write_eeprom(cp->regs, i >> 1, eep_data_word, addr_len);
+			}
+		}
+	}
+
+	spin_unlock_irq(&cp->lock);
+	return 0;
 }
=20
 /* Put the board into D3cold state and wait for WakeUp signal */

--=_d4e681fa30c2f538507875941c625129--
