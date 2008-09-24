From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH] r8169: read MAC address from EEPROM on init
Date: Wed, 24 Sep 2008 10:46:29 +0200
Message-ID: <48D9FE65.40709@redhat.com>
References: <48D25BA2.6070008@redhat.com> <Pine.LNX.4.64.0809182235550.4742@wrl-59.cs.helsinki.fi> <48D3A381.1080500@redhat.com> <Pine.LNX.4.64.0809210100020.16838@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:53917 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751573AbYIXIr2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 04:47:28 -0400
In-Reply-To: <Pine.LNX.4.64.0809210100020.16838@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> Aa, one more thing here, there's nowadays print_mac() and=20
> DECLARE_MAC_BUF() for printing MAC-addresses using %s. Since this is=20
> not perf-critical in anyway here, it will save some bytes when used i=
n=20
> kernel-wide scale.
>=20
>=20
> Reviewed-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
OK :-), I hope the patch below is finally the right one.

Ivan

---
 drivers/net/r8169.c |   73 +++++++++++++++++++++++++++++++++++++++++++=
+++++++-
 1 files changed, 72 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index befc927..e979cf5 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1910,6 +1910,74 @@ static void rtl_disable_msi(struct pci_dev *pdev=
, struct rtl8169_private *tp)
 	}
 }

+static int rtl_eeprom_read(struct pci_dev *pdev, int cap, int addr, __=
le32 *val)
+{
+	int ret, count =3D 100;
+	u16 status =3D 0;
+	u32 value;
+
+	ret =3D pci_write_config_word(pdev, cap + PCI_VPD_ADDR, addr);
+	if (ret < 0)
+		return ret;
+
+	do {
+		udelay(10);
+		ret =3D pci_read_config_word(pdev, cap + PCI_VPD_ADDR, &status);
+		if (ret < 0)
+			return ret;
+	} while (!(status & PCI_VPD_ADDR_F) && --count);
+
+	if (!(status & PCI_VPD_ADDR_F))
+		return -ETIMEDOUT;
+
+	ret =3D pci_read_config_dword(pdev, cap + PCI_VPD_DATA, &value);
+	if (ret < 0)
+		return ret;
+
+	*val =3D cpu_to_le32(value);
+
+	return 0;
+}
+
+static void rtl_init_mac_address(struct rtl8169_private *tp,
+				 void __iomem *ioaddr)
+{
+	struct pci_dev *pdev =3D tp->pci_dev;
+	u8 cfg1;
+	int vpd_cap;
+	u8 mac[8];
+	DECLARE_MAC_BUF(buf);
+
+	cfg1 =3D RTL_R8(Config1);
+	if (!(cfg1  & VPD)) {
+		dprintk("VPD access not enabled, enabling\n");
+		RTL_W8(Cfg9346, Cfg9346_Unlock);
+		RTL_W8(Config1, cfg1 | VPD);
+		RTL_W8(Cfg9346, Cfg9346_Lock);
+	}
+
+	vpd_cap =3D pci_find_capability(pdev, PCI_CAP_ID_VPD);
+	if (!vpd_cap)
+		return;
+
+	/* MAC address is stored in EEPROM at offset 0x0e
+	 * Realtek says: "The VPD address does not have to be a DWORD-aligned
+	 * address as defined in the PCI 2.2 Specifications, but the VPD data
+	 * is always consecutive 4-byte data starting from the VPD address
+	 * specified."
+	 */
+	if (rtl_eeprom_read(pdev, vpd_cap, 0x000e, (__le32*)&mac[0]) < 0 ||
+	    rtl_eeprom_read(pdev, vpd_cap, 0x0012, (__le32*)&mac[4]) < 0) {
+		dprintk("Reading MAC address from EEPROM failed\n");
+		return;
+	}
+
+	dprintk("MAC address found in EEPROM: %s\n", print_mac(buf, mac));
+
+	/* Write MAC address */
+	rtl_rar_set(tp, mac);
+}
+
 static int __devinit
 rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent=
)
 {
@@ -2079,7 +2147,10 @@ rtl8169_init_one(struct pci_dev *pdev, const str=
uct pci_device_id *ent)
 		dev->do_ioctl =3D rtl8169_ioctl;
 	}

-	/* Get MAC address.  FIXME: read EEPROM */
+	/* Read MAC address from EEPROM */
+	rtl_init_mac_address(tp, ioaddr);
+
+	/* Get MAC address */
 	for (i =3D 0; i < MAC_ADDR_LEN; i++)
 		dev->dev_addr[i] =3D RTL_R8(MAC0 + i);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
--=20
1.5.4.3
