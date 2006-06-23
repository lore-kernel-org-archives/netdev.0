From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH wireless-dev] add adm8211 driver
Date: Fri, 23 Jun 2006 09:51:24 -0700
Message-ID: <200606230951.33961.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4721134.FydJFvklTN";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:23518 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1751777AbWFWQvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 12:51:44 -0400
To: linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart4721134.FydJFvklTN
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

(resend, please merge)

This patch adds support for the ADMtek ADM8211 card. It is not completed ye=
t,=20
but I feel the code is clean enough to merge into wireless-dev. It currentl=
y=20
supports STA mode.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>

diff --git a/drivers/net/wireless/d80211/Kconfig=20
b/drivers/net/wireless/d80211/Kconfig
index 972c473..3656ee5 100644
=2D-- a/drivers/net/wireless/d80211/Kconfig
+++ b/drivers/net/wireless/d80211/Kconfig
@@ -1,2 +1,3 @@
 source "drivers/net/wireless/d80211/bcm43xx/Kconfig"
 source "drivers/net/wireless/d80211/rt2x00/Kconfig"
+source "drivers/net/wireless/d80211/adm8211/Kconfig"
diff --git a/drivers/net/wireless/d80211/Makefile=20
b/drivers/net/wireless/d80211/Makefile
index 32c5c8d..e491a41 100644
=2D-- a/drivers/net/wireless/d80211/Makefile
+++ b/drivers/net/wireless/d80211/Makefile
@@ -1,2 +1,3 @@
 obj-$(CONFIG_BCM43XX_D80211)	+=3D bcm43xx/
 obj-$(CONFIG_RT2X00)		+=3D rt2x00/
+obj-$(CONFIG_ADM8211)		+=3D adm8211/
diff --git a/drivers/net/wireless/d80211/adm8211/Kconfig=20
b/drivers/net/wireless/d80211/adm8211/Kconfig
new file mode 100644
index 0000000..9846cdf
=2D-- /dev/null
+++ b/drivers/net/wireless/d80211/adm8211/Kconfig
@@ -0,0 +1,24 @@
+config ADM8211
+	tristate "ADMtek ADM8211 support"
+	depends on NET_RADIO && PCI && D80211 && EXPERIMENTAL
+	---help---
+	  This driver is for ADM8211A, ADM8211B, and ADM8211C based cards.
+	  These are PCI/mini-PCI/Cardbus 802.11b chips found in cards such as:
+
+	  Xterasys Cardbus XN-2411b
+	  Blitz NetWave Point PC
+	  TrendNet 221pc
+	  Belkin F5D6001
+	  SMC 2635W
+	  Linksys WPC11 v1
+	  Fiberline FL-WL-200X
+	  3com Office Connect (3CRSHPW796)
+	  Corega WLPCIB-11
+	  SMC 2602W V2 EU
+	  D-Link DWL-520 Revision C
+
+	  However, some of these cards have been replaced with other chips
+	  like the RTL8180L (Xterasys Cardbus XN-2411b, Belkin F5D6001) or
+	  the Ralink RT2400 (SMC2635W) without a model number change.
+
+	  Thanks to Infineon-ADMtek for their support of this driver.
diff --git a/drivers/net/wireless/d80211/adm8211/Makefile=20
b/drivers/net/wireless/d80211/adm8211/Makefile
new file mode 100644
index 0000000..9cca7e5
=2D-- /dev/null
+++ b/drivers/net/wireless/d80211/adm8211/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_ADM8211)	+=3D adm8211.o
diff --git a/drivers/net/wireless/d80211/adm8211/adm8211.c=20
b/drivers/net/wireless/d80211/adm8211/adm8211.c
new file mode 100644
index 0000000..c766c4e
=2D-- /dev/null
+++ b/drivers/net/wireless/d80211/adm8211/adm8211.c
@@ -0,0 +1,2202 @@
+
+/*
+ * Linux device driver for ADMtek ADM8211 (IEEE 802.11b MAC/BBP)
+ *
+ * Copyright (c) 2003, Jouni Malinen <jkmaline@cc.hut.fi>
+ * Copyright (c) 2004-2006, Michael Wu <flamingice@sourmilk.net>
+ * Some parts copyright (c) 2003 by David Young <dyoung@pobox.com>
+ * and used with permission.
+ *
+ * Much thanks to Infineon-ADMtek for their support of this driver.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation. See README and COPYING for
+ * more details.
+ */
+
+#include <linux/config.h>
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/init.h>
+#include <linux/if.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ioport.h>
+#include <linux/pci.h>
+#include <linux/if_arp.h>
+#include <linux/delay.h>
+#include <linux/crc32.h>
+#include <linux/wireless.h>
+#include <net/d80211.h>
+#include <asm/delay.h>
+#include <asm/unaligned.h>
+#include <asm/types.h>
+#include <asm/div64.h>
+
+#include "adm8211.h"
+
+MODULE_AUTHOR("Michael Wu <flamingice@sourmilk.net>, Jouni Malinen=20
<jkmaline@cc.hut.fi>");
+MODULE_DESCRIPTION("Driver for IEEE 802.11b wireless LAN cards based on=20
ADMtek ADM8211");
+MODULE_SUPPORTED_DEVICE("ADM8211");
+MODULE_LICENSE("GPL");
+
+static unsigned int tx_ring_size =3D 16;
+static unsigned int rx_ring_size =3D 16;
+static int debug =3D 1;
+
+module_param(tx_ring_size, uint, 0);
+module_param(rx_ring_size, uint, 0);
+module_param(debug, int, 0);
+
+static const char *version =3D KERN_INFO "adm8211: "=20
+"Copyright 2003, Jouni Malinen <jkmaline@cc.hut.fi>; "
+"Copyright 2004-2006, Michael Wu <flamingice@sourmilk.net>\n";
+
+
+static struct pci_device_id adm8211_pci_id_table[] __devinitdata =3D {
+	/* ADMtek ADM8211 */
+	{ 0x10B7, 0x6000, PCI_ANY_ID, PCI_ANY_ID }, /* 3Com 3CRSHPW796 */
+	{ 0x1200, 0x8201, PCI_ANY_ID, PCI_ANY_ID }, /* ? */
+	{ 0x1317, 0x8201, PCI_ANY_ID, PCI_ANY_ID }, /* ADM8211A */
+	{ 0x1317, 0x8211, PCI_ANY_ID, PCI_ANY_ID }, /* ADM8211B/C */
+	{ 0 }
+};
+
+#define ADM8211_INTMASK \
+(ADM8211_IER_NIE | ADM8211_IER_AIE | ADM8211_IER_RCIE | ADM8211_IER_TCIE |=
 \
+ADM8211_IER_TDUIE | ADM8211_IER_GPTIE)
+
+#define PLCP_SIGNAL_1M		0x0a
+#define PLCP_SIGNAL_2M		0x14
+#define PLCP_SIGNAL_5M5		0x37
+#define PLCP_SIGNAL_11M		0x6e
+
+#define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
+#define MAC_ARG(x) ((u8*)(x))[0],((u8*)(x))[1],((u8*)(x))[2],((u8*)(x))[3],
((u8*)(x))[4],((u8*)(x))[5]
+
+struct adm8211_tx_hdr {
+	u8 da[6];
+	u8 signal; /* PLCP signal / TX rate in 100 Kbps */
+	u8 service;
+	__le16 frame_body_size;
+	__le16 frame_control;
+	__le16 plcp_frag_tail_len;
+	__le16 plcp_frag_head_len;
+	__le16 dur_frag_tail;
+	__le16 dur_frag_head;
+	u8 addr4[6];
+
+#define ADM8211_TXHDRCTL_SHORT_PREAMBLE		(1 <<  0)
+#define ADM8211_TXHDRCTL_MORE_FRAG		(1 <<  1)
+#define ADM8211_TXHDRCTL_MORE_DATA		(1 <<  2)
+#define ADM8211_TXHDRCTL_FRAG_NO		(1 <<  3) /* ? */
+#define ADM8211_TXHDRCTL_ENABLE_RTS		(1 <<  4)
+#define ADM8211_TXHDRCTL_ENABLE_WEP_ENGINE	(1 <<  5)
+#define ADM8211_TXHDRCTL_ENABLE_EXTEND_HEADER	(1 << 15) /* ? */
+	__le16 header_control;
+	__le16 frag;
+	u8 reserved_0;
+	u8 retry_limit;
+
+	u32 wep2key0;
+	u32 wep2key1;
+	u32 wep2key2;
+	u32 wep2key3;
+
+	u8 keyid;
+	u8 entry_control;	// huh??
+	u16 reserved_1;
+	u32 reserved_2;
+} __attribute__ ((packed));
+
+
+#define RX_COPY_BREAK 128
+#define RX_PKT_SIZE 2500
+
+/* Serial EEPROM reading for 93C66/93C46 */
+#define EE_ENB		(0x4000 | ADM8211_SPR_SRS | ADM8211_SPR_SCS)
+#define EE_READ_CMD	(6)
+#define eeprom_delay()	ADM8211_CSR_READ(SPR);
+
+
+static u16 adm8211_eeprom_read_word(struct net_device *dev, unsigned int=20
addr,
+				    unsigned int addr_len)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	unsigned int read_cmd =3D addr | (EE_READ_CMD << addr_len);
+	int i;
+	u16 retval =3D 0;
+
+	ADM8211_CSR_WRITE(SPR, __constant_cpu_to_le32(EE_ENB & ~ADM8211_SPR_SCS));
+	eeprom_delay();
+	ADM8211_CSR_WRITE(SPR, __constant_cpu_to_le32(EE_ENB));
+	eeprom_delay();
+
+	/* Shift the read command bits out. */
+	for (i =3D 4 + addr_len; i >=3D 0; i--) {
+		u32 dataval =3D EE_ENB | ((read_cmd & (1 << i)) ? ADM8211_SPR_SDI : 0);
+		ADM8211_CSR_WRITE(SPR, cpu_to_le32(dataval));
+		eeprom_delay();
+		ADM8211_CSR_WRITE(SPR, cpu_to_le32(dataval | ADM8211_SPR_SCLK));
+		eeprom_delay();
+	}
+
+	ADM8211_CSR_WRITE(SPR, __constant_cpu_to_le32(EE_ENB));
+	eeprom_delay();
+
+	for (i =3D 16; i > 0; i--) {
+		ADM8211_CSR_WRITE(SPR, __constant_cpu_to_le32(EE_ENB | ADM8211_SPR_SCLK)=
);
+		eeprom_delay();
+		retval <<=3D 1;
+		if (ADM8211_CSR_READ(SPR) & __constant_cpu_to_le32(ADM8211_SPR_SDO))
+			retval |=3D 1;
+		ADM8211_CSR_WRITE(SPR, __constant_cpu_to_le32(EE_ENB));
+		eeprom_delay();
+	}
+
+	/* Terminate the EEPROM access. */
+	ADM8211_CSR_WRITE(SPR, __constant_cpu_to_le32(EE_ENB & ~ADM8211_SPR_SCS));
+
+	return retval;
+}
+
+
+static int adm8211_read_eeprom(struct net_device *dev)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	unsigned int addr_len, words, i;
+	struct ieee80211_chan_range chan_range;
+	u16 cr49;
+
+	if (ADM8211_CSR_READ(CSR_TEST0) & __constant_cpu_to_le32
(ADM8211_CSR_TEST0_EPTYP)) {
+		printk(KERN_DEBUG "%s (adm8211): EEPROM type: 93C66\n",=20
pci_name(priv->pdev));
+		/* 256 * 16-bit =3D 512 bytes */
+		addr_len =3D 8;
+		words =3D 256;
+	} else {
+		printk(KERN_DEBUG "%s (adm8211): EEPROM type 93C46\n",=20
pci_name(priv->pdev));
+		/* 64 * 16-bit =3D 128 bytes */
+		addr_len =3D 6;
+		words =3D 64;
+	}
+
+	priv->eeprom_len =3D words * 2;
+	priv->eeprom =3D kmalloc(priv->eeprom_len, GFP_KERNEL);
+	if (priv->eeprom =3D=3D NULL)
+		return -ENOMEM;
+
+	for (i =3D 0; i < words; i++)
+		*((u16 *) &((u8 *)priv->eeprom)[i * 2]) =3D
+			adm8211_eeprom_read_word(dev, i, addr_len);
+
+	cr49 =3D le16_to_cpu(priv->eeprom->cr49);
+	priv->rf_type =3D (cr49 >> 3) & 0x7;
+	switch (priv->rf_type) {
+	case ADM8211_TYPE_INTERSIL:
+	case ADM8211_TYPE_RFMD:
+	case ADM8211_TYPE_MARVEL:
+	case ADM8211_TYPE_AIROHA:
+	case ADM8211_TYPE_ADMTEK:
+		break;
+=09
+	default:
+		if (priv->revid < ADM8211_REV_CA)
+			priv->rf_type =3D ADM8211_TYPE_RFMD;
+		else
+			priv->rf_type =3D ADM8211_TYPE_AIROHA;
+
+		printk(KERN_WARNING "%s (adm8211): Invalid or unsupported RFtype: %d,=20
assuming %d\n",
+		       pci_name(priv->pdev), (cr49 >> 3) & 0x7, priv->rf_type);
+	}
+
+	priv->bbp_type =3D cr49 & 0x7;
+	switch (priv->bbp_type) {
+	case ADM8211_TYPE_INTERSIL:
+	case ADM8211_TYPE_RFMD:
+	case ADM8211_TYPE_MARVEL:
+	case ADM8211_TYPE_AIROHA:
+	case ADM8211_TYPE_ADMTEK:
+		break;
+=09
+	default:
+		if (priv->revid < ADM8211_REV_CA)
+			priv->bbp_type =3D ADM8211_TYPE_RFMD;
+		else
+			priv->bbp_type =3D ADM8211_TYPE_ADMTEK;
+
+		printk(KERN_WARNING "%s (adm8211): Invalid or unsupported BBPtype: %d,=20
assuming %d\n",
+		       pci_name(priv->pdev), cr49 >> 3, priv->bbp_type);
+	}
+
+	if (priv->eeprom->country_code >=3D ARRAY_SIZE(cranges)) {
+		printk(KERN_WARNING "%s (adm8211): Invalid country code (%d) in EEPROM,=
=20
assuming ETSI\n",
+		       pci_name(priv->pdev), priv->eeprom->country_code);
+
+		chan_range =3D cranges[2];
+	} else
+		chan_range =3D cranges[priv->eeprom->country_code];
+
+	printk(KERN_DEBUG "%s (adm8211): Channel range: %d - %d\n",
+	       pci_name(priv->pdev), (int)chan_range.min, (int)chan_range.max);
+
+	priv->modes[0].num_channels =3D chan_range.max - chan_range.min + 1;
+	priv->modes[0].channels =3D kmalloc(priv->modes[0].num_channels *=20
sizeof(struct ieee80211_channel), GFP_KERNEL);
+	if (priv->modes[0].channels =3D=3D NULL) {
+		kfree(priv->eeprom);
+		return -ENOMEM;
+	}
+
+	memcpy(priv->modes[0].channels, &adm8211_channels[chan_range.min-1],
+		priv->modes[0].num_channels * sizeof(struct ieee80211_channel));
+
+	switch (priv->eeprom->specific_bbptype) {
+	case ADM8211_BBP_RFMD3000:
+	case ADM8211_BBP_RFMD3002:
+	case ADM8211_BBP_ADM8011:
+		priv->specific_bbptype =3D priv->eeprom->specific_bbptype;
+		break;
+=09
+	default:
+		if (priv->revid < ADM8211_REV_CA)
+			priv->specific_bbptype =3D ADM8211_BBP_RFMD3000;
+		else
+			priv->specific_bbptype =3D ADM8211_BBP_ADM8011;
+
+		printk(KERN_WARNING "%s (adm8211): Invalid or unsupported specific BBP: =
%d,=20
assuming %d\n",
+		       pci_name(priv->pdev), priv->eeprom->specific_bbptype,=20
priv->specific_bbptype);
+	}
+=09
+	switch (priv->eeprom->specific_rftype) {
+	case ADM8211_RFMD2948:
+	case ADM8211_RFMD2958:
+	case ADM8211_RFMD2958_RF3000_CONTROL_POWER:
+	case ADM8211_MAX2820:
+	case ADM8211_AL2210L:
+		priv->transceiver_type =3D priv->eeprom->specific_rftype;
+		break;
+
+	default:
+		if (priv->revid =3D=3D ADM8211_REV_BA)
+			priv->transceiver_type =3D ADM8211_RFMD2958_RF3000_CONTROL_POWER;
+		else if (priv->revid =3D=3D ADM8211_REV_CA)
+			priv->transceiver_type =3D ADM8211_AL2210L;
+		else if (priv->revid =3D=3D ADM8211_REV_AB)
+			priv->transceiver_type =3D ADM8211_RFMD2948;
+
+		printk(KERN_WARNING "%s (adm8211): Invalid or unsupported transceiver: %=
d,=20
assuming %d\n",
+		       pci_name(priv->pdev), priv->eeprom->specific_rftype,=20
priv->transceiver_type);
+
+		break;
+	}
+
+	printk(KERN_DEBUG "%s (adm8211): RFtype=3D%d BBPtype=3D%d Specific BBP=3D=
%d=20
Transceiver=3D%d\n",
+	       pci_name(priv->pdev), priv->rf_type, priv->bbp_type,
+	       priv->specific_bbptype, priv->transceiver_type);
+
+	return 0;
+}
+
+static inline void adm8211_write_sram(struct net_device *dev, u32 addr,=20
__le32 data)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+
+	ADM8211_CSR_WRITE(WEPCTL, cpu_to_le32(addr | ADM8211_WEPCTL_TABLE_WR |
+			  (priv->revid < ADM8211_REV_BA ?
+			   0 : ADM8211_WEPCTL_SEL_WEPTABLE )) );
+	ADM8211_CSR_READ(WEPCTL);
+	mdelay(1);
+
+	ADM8211_CSR_WRITE(WESK, data);
+	ADM8211_CSR_READ(WESK);
+	mdelay(1);
+}
+
+static void adm8211_write_sram_bytes(struct net_device *dev,
+				     unsigned int addr, u8 *buf, unsigned int len)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	__le32 reg =3D ADM8211_CSR_READ(WEPCTL);
+	unsigned int i;
+
+	if (priv->revid < ADM8211_REV_BA) {
+		for (i =3D 0; i < len; i +=3D 2) {
+			u16 val =3D buf[i] | buf[i + 1] << 8;
+			adm8211_write_sram(dev, addr + i / 2, cpu_to_le32(val));
+		}
+	} else {
+		for (i =3D 0; i < len; i +=3D 4) {
+			u32 val =3D (buf[i + 0] << 0 ) | (buf[i + 1] << 8 ) |
+				  (buf[i + 2] << 16) | (buf[i + 3] << 24);
+			adm8211_write_sram(dev, addr + i / 4, cpu_to_le32(val));
+		}
+	}
+
+	ADM8211_CSR_WRITE(WEPCTL, reg);
+}
+
+static void adm8211_clear_sram(struct net_device *dev)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	__le32 reg =3D ADM8211_CSR_READ(WEPCTL);
+	unsigned int addr;
+
+	for (addr =3D 0; addr < ADM8211_SRAM_SIZE; addr++)
+			adm8211_write_sram(dev, addr, 0);
+
+	ADM8211_CSR_WRITE(WEPCTL, reg);
+}
+
+static int adm8211_get_stats(struct net_device *dev,
+			     struct ieee80211_low_level_stats *stats)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+
+	memcpy(stats, &priv->stats, sizeof(*stats));
+
+	return 0;
+}
+
+static void adm8211_set_rx_mode(struct net_device *dev,
+				unsigned short flags, int mc_count)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	unsigned int bit_nr;
+	__le32 mc_filter[2];
+	struct dev_mc_list *mclist;
+	void *tmp;
+
+		mc_filter[1] =3D mc_filter[0] =3D 0;
+	if (flags & IFF_PROMISC) {
+		priv->nar |=3D ADM8211_NAR_PR;
+		priv->nar &=3D ~ADM8211_NAR_MM;
+		mc_filter[1] =3D mc_filter[0] =3D __constant_cpu_to_le32(~0);
+	} else if ((flags & IFF_ALLMULTI) || (mc_count > -1)) {
+		priv->nar &=3D ~ADM8211_NAR_PR;
+		priv->nar |=3D ADM8211_NAR_MM;
+		mc_filter[1] =3D mc_filter[0] =3D __constant_cpu_to_le32(~0);
+	} else {
+		priv->nar &=3D ~(ADM8211_NAR_MM | ADM8211_NAR_PR);
+		mc_filter[1] =3D mc_filter[0] =3D 0;
+		mclist =3D NULL;
+		while ((mclist =3D ieee80211_get_mc_list_item(dev, mclist, &tmp))) {
+			bit_nr =3D ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
+
+			bit_nr &=3D 0x3F;
+			mc_filter[bit_nr >> 5] |=3D cpu_to_le32(1 << (bit_nr & 31));
+		}
+	}
+
+	ADM8211_IDLE_RX();
+
+	ADM8211_CSR_WRITE(MAR0, mc_filter[0]);
+	ADM8211_CSR_WRITE(MAR1, mc_filter[1]);
+	ADM8211_CSR_READ(NAR);
+
+	ADM8211_RESTORE();
+}
+
+static int adm8211_get_tx_stats(struct net_device *dev,
+				struct ieee80211_tx_queue_stats *stats)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	struct ieee80211_tx_queue_stats_data *data =3D &stats->data[0];
+
+	data->len =3D priv->cur_tx - priv->dirty_tx;
+	data->limit =3D priv->tx_ring_size - 2;
+	data->count =3D priv->dirty_tx;
+
+	return 0;
+}
+
+static void adm8211_interrupt_tci(struct net_device *dev)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	struct net_device_stats *stats =3D ieee80211_dev_stats(dev);
+	unsigned dirty_tx;
+
+	spin_lock(&priv->lock);
+
+	for (dirty_tx =3D priv->dirty_tx;
+	     priv->cur_tx - dirty_tx > 0; dirty_tx++) {
+		unsigned entry =3D dirty_tx % priv->tx_ring_size;
+		u32 status =3D le32_to_cpu(priv->tx_ring[entry].status);
+		struct sk_buff *skb;
+
+		if (status & TDES0_CONTROL_OWN ||
+		    !(status & TDES0_CONTROL_DONE))
+			break;
+
+		if (status & TDES0_STATUS_ES) {
+			stats->tx_errors++;
+			priv->tx_buffers[entry].tx_status.ack =3D 0;
+
+			if (status & (TDES0_STATUS_TUF | TDES0_STATUS_TRO))
+				stats->tx_fifo_errors++;
+		} else
+			priv->tx_buffers[entry].tx_status.ack =3D 1;
+
+		skb =3D priv->tx_buffers[entry].skb;
+		pci_unmap_single(priv->pdev, priv->tx_buffers[entry].mapping,
+				 skb->len, PCI_DMA_TODEVICE);
+
+		if (priv->tx_buffers[entry].tx_status.control.req_tx_status ||
+		    priv->tx_buffers[entry].unicast)
+			ieee80211_tx_status_irqsafe(dev, priv->tx_buffers[entry].skb,
+						    &priv->tx_buffers[entry].tx_status);
+		else
+			dev_kfree_skb_irq(priv->tx_buffers[entry].skb);
+		priv->tx_buffers[entry].skb =3D NULL;
+	}
+
+	if (priv->cur_tx - dirty_tx < priv->tx_ring_size - 2)
+		netif_wake_queue(dev);
+
+	priv->dirty_tx =3D dirty_tx;
+	spin_unlock(&priv->lock);
+}
+
+
+static void adm8211_interrupt_rci(struct net_device *dev)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	struct net_device_stats *stats =3D ieee80211_dev_stats(dev);
+	unsigned int entry =3D priv->cur_rx % priv->rx_ring_size;
+	u32 status;
+	unsigned pktlen;
+	struct sk_buff *skb, *newskb;
+	unsigned int limit =3D priv->rx_ring_size;
+	static const u8 rate_tbl[] =3D {10, 20, 55, 110, 220};
+	u8 rssi, rate;
+
+	while (!(priv->rx_ring[entry].status &
+		 __constant_cpu_to_le32(RDES0_STATUS_OWN))) {
+		if (limit-- =3D=3D 0)
+			break;
+
+		status =3D le32_to_cpu(priv->rx_ring[entry].status);
+		rate =3D (status & RDES0_STATUS_RXDR) >> 12;
+		rssi =3D le32_to_cpu(priv->rx_ring[entry].length) &
+			RDES1_STATUS_RSSI;
+
+		pktlen =3D status & RDES0_STATUS_FL;
+		if (pktlen > RX_PKT_SIZE) {
+			if (net_ratelimit())
+				printk(KERN_DEBUG "%s: too long frame (pktlen=3D%d)\n",
+				       dev->name, pktlen);
+			pktlen =3D RX_PKT_SIZE;
+		}
+
+		if (!priv->soft_rx_crc && status & RDES0_STATUS_ES) {
+			skb =3D NULL; /* old buffer will be reused */
+			stats->rx_errors++;
+			if (status & (RDES0_STATUS_CRC16E | RDES0_STATUS_CRC32E))
+				stats->rx_crc_errors++;
+
+		} else if (pktlen < RX_COPY_BREAK) {
+			skb =3D dev_alloc_skb(pktlen);
+			if (skb) {
+				skb->dev =3D dev;
+				pci_dma_sync_single_for_cpu(
+					priv->pdev,
+					priv->rx_buffers[entry].mapping,
+					pktlen, PCI_DMA_FROMDEVICE);
+				memcpy(skb_put(skb, pktlen),
+				       priv->rx_buffers[entry].skb->tail,
+				       pktlen);
+				pci_dma_sync_single_for_device(
+					priv->pdev,
+					priv->rx_buffers[entry].mapping,
+					RX_PKT_SIZE, PCI_DMA_FROMDEVICE);
+			}
+		} else {
+			newskb =3D dev_alloc_skb(RX_PKT_SIZE);
+			if (newskb) {
+				newskb->dev =3D dev;
+				skb =3D priv->rx_buffers[entry].skb;
+				skb_put(skb, pktlen);
+				pci_unmap_single(
+					priv->pdev,
+					priv->rx_buffers[entry].mapping,
+					RX_PKT_SIZE, PCI_DMA_FROMDEVICE);
+				priv->rx_buffers[entry].skb =3D newskb;
+				priv->rx_buffers[entry].mapping =3D
+					pci_map_single(priv->pdev,
+						       newskb->tail,
+						       RX_PKT_SIZE,
+						       PCI_DMA_FROMDEVICE);
+			} else {
+				skb =3D NULL;
+				stats->rx_dropped++;
+			}
+
+			priv->rx_ring[entry].buffer1 =3D
+				cpu_to_le32(priv->rx_buffers[entry].mapping);
+		}
+
+		priv->rx_ring[entry].status =3D cpu_to_le32( RDES0_STATUS_OWN |=20
RDES0_STATUS_SQL );
+		priv->rx_ring[entry].length =3D
+			cpu_to_le32(RX_PKT_SIZE |
+				    (entry =3D=3D priv->rx_ring_size - 1 ?
+				     RDES1_CONTROL_RER : 0));
+
+		if (skb) {
+			struct ieee80211_rx_status rx_status =3D {0};
+
+			if (priv->revid < ADM8211_REV_CA)
+				rx_status.ssi =3D rssi;
+			else
+				rx_status.ssi =3D 100 - rssi;
+
+			if (rate <=3D 4)
+				rx_status.rate =3D rate_tbl[rate];
+=09
+			/* remove FCS */
+			/* TODO: remove this and set flag in ieee80211_hw instead? */
+			if (dev->flags & IFF_PROMISC)
+				skb_trim(skb, skb->len - FCS_LEN);
+
+			ieee80211_rx_irqsafe(dev, skb, &rx_status);
+		}
+
+		entry =3D (++priv->cur_rx) % priv->rx_ring_size;
+	}
+
+	stats->rx_missed_errors +=3D le32_to_cpu(ADM8211_CSR_READ(LPC)) & 0xFFFF;
+}
+
+
+static irqreturn_t adm8211_interrupt(int irq, void *dev_id,
+				     struct pt_regs *regs)
+{
+#define ADM8211_INT(x) if (unlikely(stsr & ADM8211_STSR_ ## x))=20
printk(KERN_DEBUG "%s: " #x "\n", dev->name)
+
+	struct net_device *dev =3D dev_id;
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	unsigned int count =3D 0;
+	u32 stsr;
+
+	do {
+		stsr =3D le32_to_cpu(ADM8211_CSR_READ(STSR));
+		ADM8211_CSR_WRITE(STSR, cpu_to_le32(stsr));
+		if (stsr =3D=3D 0xffffffff)
+			return IRQ_HANDLED;
+
+		if (!(stsr & (ADM8211_STSR_NISS | ADM8211_STSR_AISS)))
+			break;
+
+		if (stsr & ADM8211_STSR_RCI)
+			adm8211_interrupt_rci(dev);
+		if (stsr & ADM8211_STSR_TCI)
+			adm8211_interrupt_tci(dev);
+
+		if ((stsr & (ADM8211_STSR_LinkOn | ADM8211_STSR_LinkOff))
+			 !=3D (ADM8211_STSR_LinkOn | ADM8211_STSR_LinkOff)) {
+			if (stsr & ADM8211_STSR_LinkOn)
+				printk(KERN_DEBUG "%s: LinkOn\n", dev->name);
+	=09
+			if (stsr & ADM8211_STSR_LinkOff)
+				printk(KERN_DEBUG "%s: LinkOff\n", dev->name);
+		}
+
+		ADM8211_INT(PCF);
+		ADM8211_INT(BCNTC);
+		ADM8211_INT(GPINT);
+		ADM8211_INT(ATIMTC);
+		ADM8211_INT(TSFTF);
+		ADM8211_INT(TSCZ);
+		ADM8211_INT(SQL);
+		ADM8211_INT(WEPTD);
+		ADM8211_INT(ATIME);
+		/*ADM8211_INT(TBTT);*/
+		ADM8211_INT(TEIS);
+		ADM8211_INT(FBE);
+		ADM8211_INT(REIS);
+		ADM8211_INT(GPTT);
+		ADM8211_INT(RPS);
+		ADM8211_INT(RDU);
+		ADM8211_INT(TUF);
+		/*ADM8211_INT(TRT);*/
+		/*ADM8211_INT(TLT);*/
+		/*ADM8211_INT(TDU);*/
+		ADM8211_INT(TPS);
+
+	} while (count++ < 20);
+
+	return IRQ_RETVAL(count);
+
+#undef ADM8211_INT
+}
+
+#define=20
WRITE_SYN(valmask,valshift,addrmask,addrshift,bits,prewrite,postwrite) do {\
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);\
+	unsigned int i;\
+	u32 reg, bitbuf;\
+	\
+	value &=3D valmask;\
+	addr &=3D addrmask;\
+	bitbuf =3D (value << valshift) | (addr << addrshift);\
+	\
+	ADM8211_CSR_WRITE(SYNRF, __constant_cpu_to_le32(ADM8211_SYNRF_IF_SELECT_1=
));
\
+	ADM8211_CSR_READ(SYNRF);\
+	ADM8211_CSR_WRITE(SYNRF, __constant_cpu_to_le32(ADM8211_SYNRF_IF_SELECT_0=
));
\
+	ADM8211_CSR_READ(SYNRF);\
+	\
+	if (prewrite) {\
+		ADM8211_CSR_WRITE(SYNRF, __constant_cpu_to_le32
(ADM8211_SYNRF_WRITE_SYNDATA_0));\
+		ADM8211_CSR_READ(SYNRF);\
+	}\
+	\
+	for (i =3D 0; i <=3D bits; i++) {\
+		if ( bitbuf & (1 << (bits - i)) )\
+			reg =3D ADM8211_SYNRF_WRITE_SYNDATA_1;\
+		else\
+			reg =3D ADM8211_SYNRF_WRITE_SYNDATA_0;\
+		\
+		ADM8211_CSR_WRITE(SYNRF, cpu_to_le32(reg));\
+		ADM8211_CSR_READ(SYNRF);\
+		\
+		ADM8211_CSR_WRITE(SYNRF, cpu_to_le32(reg | ADM8211_SYNRF_WRITE_CLOCK_1))=
;\
+		ADM8211_CSR_READ(SYNRF);\
+		ADM8211_CSR_WRITE(SYNRF, cpu_to_le32(reg | ADM8211_SYNRF_WRITE_CLOCK_0))=
;\
+		ADM8211_CSR_READ(SYNRF);\
+	}\
+	\
+	if (postwrite =3D=3D 1) {\
+		ADM8211_CSR_WRITE(SYNRF, cpu_to_le32(reg | ADM8211_SYNRF_IF_SELECT_0));\
+		ADM8211_CSR_READ(SYNRF);\
+	}\
+	if (postwrite =3D=3D 2) {\
+		ADM8211_CSR_WRITE(SYNRF, cpu_to_le32(reg | ADM8211_SYNRF_IF_SELECT_1));\
+		ADM8211_CSR_READ(SYNRF);\
+	}\
+	\
+	ADM8211_CSR_WRITE(SYNRF, 0);\
+	ADM8211_CSR_READ(SYNRF);\
+} while (0)
+
+static void adm8211_rf_write_syn_max2820 (struct net_device *dev, u16 addr=
,=20
u32 value)
+{
+	WRITE_SYN(0x00FFF, 0, 0x0F, 12, 15, 1, 1);
+}
+
+static void adm8211_rf_write_syn_al2210l (struct net_device *dev, u16 addr=
,=20
u32 value)
+{
+	WRITE_SYN(0xFFFFF, 4, 0x0F,  0, 23, 1, 1);
+}
+
+static void adm8211_rf_write_syn_rfmd2958 (struct net_device *dev, u16 add=
r,=20
u32 value)
+{
+	WRITE_SYN(0x3FFFF, 0, 0x1F, 18, 23, 0, 1);
+}
+
+static void adm8211_rf_write_syn_rfmd2948 (struct net_device *dev, u16 add=
r,=20
u32 value)
+{
+	WRITE_SYN(0x0FFFF, 4, 0x0F,  0, 21, 0, 2);
+}
+
+static int adm8211_write_bbp(struct net_device *dev, u8 addr, u8 data)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	unsigned int timeout;
+	u32 reg;
+
+	timeout =3D 10;
+	while (timeout > 0) {
+		reg =3D le32_to_cpu(ADM8211_CSR_READ(BBPCTL));
+		if (!(reg & (ADM8211_BBPCTL_WR | ADM8211_BBPCTL_RD)))
+			break;
+		timeout--;
+		mdelay(2);
+	}
+
+	if (timeout =3D=3D 0) {
+		printk(KERN_DEBUG "%s: adm8211_write_bbp(%d,%d) failed prewrite "
+		       "(reg=3D0x%08x)\n",
+		       dev->name, addr, data, reg);
+		return -ETIMEDOUT;
+	}
+
+	switch (priv->bbp_type) {
+	case ADM8211_TYPE_INTERSIL:
+		reg =3D ADM8211_BBPCTL_MMISEL;	/* three wire interface */
+		break;
+	case ADM8211_TYPE_RFMD:
+		reg =3D (0x20<<24) | ADM8211_BBPCTL_TXCE | ADM8211_BBPCTL_CCAP |
+		      (0x01<<18);
+		break;
+	case ADM8211_TYPE_ADMTEK:
+		reg =3D (0x20<<24) | ADM8211_BBPCTL_TXCE | ADM8211_BBPCTL_CCAP |
+		      (0x05<<18);
+		break;
+	}
+	reg |=3D ADM8211_BBPCTL_WR | (addr << 8) | data;
+
+	ADM8211_CSR_WRITE(BBPCTL, cpu_to_le32(reg));
+
+	timeout =3D 10;
+	while (timeout > 0) {
+		reg =3D le32_to_cpu(ADM8211_CSR_READ(BBPCTL));
+		if (!(reg & ADM8211_BBPCTL_WR))
+			break;
+		timeout--;
+		mdelay(2);
+	}
+
+	if (timeout =3D=3D 0) {
+		ADM8211_CSR_WRITE(BBPCTL, ADM8211_CSR_READ(BBPCTL) &
+				  __constant_cpu_to_le32(~ADM8211_BBPCTL_WR));
+		printk(KERN_DEBUG "%s: adm8211_write_bbp(%d,%d) failed postwrite "
+		       "(reg=3D0x%08x)\n",
+		       dev->name, addr, data, reg);
+		return -ETIMEDOUT;
+	}
+
+	return 0;
+}
+
+static int adm8211_rf_set_channel(struct net_device *dev, unsigned int=20
channel)
+{
+	static const u32 adm8211_rfmd2958_reg5[] =3D
+		{0x22BD, 0x22D2, 0x22E8, 0x22FE, 0x2314, 0x232A, 0x2340,
+		 0x2355, 0x236B, 0x2381, 0x2397, 0x23AD, 0x23C2, 0x23F7};
+	static const u32 adm8211_rfmd2958_reg6[] =3D
+		{0x05D17, 0x3A2E8, 0x2E8BA, 0x22E8B, 0x1745D, 0x0BA2E, 0x00000,
+		 0x345D1, 0x28BA2, 0x1D174, 0x11745, 0x05D17, 0x3A2E8, 0x11745};
+
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	u8 ant_power =3D priv->ant_power > 0x3F ?
+		priv->eeprom->antenna_power[channel-1] : priv->ant_power;
+	u8 tx_power =3D priv->tx_power > 0x3F ?
+		priv->eeprom->tx_power[channel-1] : priv->tx_power;
+	u8 lpf_cutoff =3D priv->lpf_cutoff =3D=3D 0xFF ?
+		priv->eeprom->lpf_cutoff[channel-1] : priv->lpf_cutoff;
+	u8 lnags_thresh =3D priv->lnags_threshold =3D=3D 0xFF ?
+		priv->eeprom->lnags_threshold[channel-1] : priv->lnags_threshold;
+	u32 reg;
+
+	if (channel < 1 || channel > 14)
+		return -EINVAL;
+
+	ADM8211_IDLE();
+
+	/* Program synthesizer to new channel */
+	switch (priv->transceiver_type) {
+	case ADM8211_RFMD2958:
+	case ADM8211_RFMD2958_RF3000_CONTROL_POWER:
+		adm8211_rf_write_syn_rfmd2958(dev, 0x00, 0x04007);
+		adm8211_rf_write_syn_rfmd2958(dev, 0x02, 0x00033);
+
+		adm8211_rf_write_syn_rfmd2958(dev, 0x05,
+					adm8211_rfmd2958_reg5[channel-1]);
+		adm8211_rf_write_syn_rfmd2958(dev, 0x06,
+					adm8211_rfmd2958_reg6[channel-1]);
+		break;
+
+	case ADM8211_RFMD2948:
+		adm8211_rf_write_syn_rfmd2948(dev, SI4126_MAIN_CONF, SI4126_MAIN_XINDIV2=
);
+		adm8211_rf_write_syn_rfmd2948(dev, SI4126_POWERDOWN,
+				     SI4126_POWERDOWN_PDIB | SI4126_POWERDOWN_PDRB);
+		adm8211_rf_write_syn_rfmd2948(dev, SI4126_PHASE_DET_GAIN, 0);
+		adm8211_rf_write_syn_rfmd2948(dev, SI4126_RF2_N_DIV,
+				     (channel =3D=3D 14 ? 2110 : (2033 + (channel * 5))));
+		adm8211_rf_write_syn_rfmd2948(dev, SI4126_IF_N_DIV, 1496);
+		adm8211_rf_write_syn_rfmd2948(dev, SI4126_RF2_R_DIV, 44);
+		adm8211_rf_write_syn_rfmd2948(dev, SI4126_IF_R_DIV, 44);
+		break;
+
+	case ADM8211_MAX2820:
+		adm8211_rf_write_syn_max2820(dev, 0x3,
+			(channel =3D=3D 14 ? 0x054 : (0x7 + (channel * 5))));
+		break;
+
+	case ADM8211_AL2210L:
+		adm8211_rf_write_syn_al2210l(dev, 0x0,
+			(channel =3D=3D 14 ? 0x229B4 : (0x22967 + (channel * 5))));
+		break;
+
+	default:
+		printk(KERN_DEBUG "%s: unsupported transceiver type %d\n",
+		       dev->name, priv->transceiver_type);
+		break;
+	}
+
+	/* write BBP regs */
+	if (priv->bbp_type =3D=3D ADM8211_TYPE_RFMD) {
+
+	/* SMC 2635W specific? adm8211b doesn't use the 2948 though.. */
+	/* TODO: remove if SMC 2635W doesn't need this */
+	if (priv->transceiver_type =3D=3D ADM8211_RFMD2948) {
+		reg =3D le32_to_cpu(ADM8211_CSR_READ(GPIO));
+		reg &=3D 0xfffc0000;
+		reg |=3D ADM8211_CSR_GPIO_EN0;
+		if (channel !=3D 14)
+			reg |=3D ADM8211_CSR_GPIO_O0;
+		ADM8211_CSR_WRITE(GPIO, cpu_to_le32(reg));
+	}
+
+	if (priv->transceiver_type =3D=3D ADM8211_RFMD2958) {
+		/* set PCNT2 */
+		adm8211_rf_write_syn_rfmd2958(dev, 0x0B, 0x07100);
+		/* set PCNT1 P_DESIRED/MID_BIAS */
+		reg =3D le16_to_cpu(priv->eeprom->cr49);
+		reg >>=3D 13;
+		reg <<=3D 15;
+		reg |=3D ant_power<<9;
+		adm8211_rf_write_syn_rfmd2958(dev, 0x0A, reg);
+		/* set TXRX TX_GAIN */
+		adm8211_rf_write_syn_rfmd2958(dev, 0x09, 0x00050 |
+			(priv->revid < ADM8211_REV_CA ? tx_power : 0));
+	} else {
+		reg =3D le32_to_cpu(ADM8211_CSR_READ(PLCPHD));
+		reg &=3D 0xff00ffff;
+		reg |=3D tx_power<<18;
+		ADM8211_CSR_WRITE(PLCPHD, cpu_to_le32(reg));
+	}
+
+	ADM8211_CSR_WRITE(SYNRF, __constant_cpu_to_le32(ADM8211_SYNRF_SELRF |
+			  ADM8211_SYNRF_PE1 | ADM8211_SYNRF_PHYRST));
+	ADM8211_CSR_READ(SYNRF);
+	mdelay(30);
+
+	/* RF3000 BBP */
+	if (priv->transceiver_type !=3D ADM8211_RFMD2958)
+		adm8211_write_bbp(dev, RF3000_TX_VAR_GAIN__TX_LEN_EXT,
+				  tx_power<<2);
+	adm8211_write_bbp(dev, RF3000_LOW_GAIN_CALIB, lpf_cutoff);
+	adm8211_write_bbp(dev, RF3000_HIGH_GAIN_CALIB, lnags_thresh);
+	adm8211_write_bbp(dev, 0x1c, priv->revid =3D=3D ADM8211_REV_BA
+			  ? priv->eeprom->cr28 : 0);
+	adm8211_write_bbp(dev, 0x1d, priv->eeprom->cr29);
+
+	ADM8211_CSR_WRITE(SYNRF, 0);
+
+	} else if (priv->bbp_type !=3D ADM8211_TYPE_ADMTEK) {	/* Nothing to do fo=
r=20
ADMtek BBP */
+		printk(KERN_DEBUG "%s: unsupported BBP type %d\n",
+		       dev->name, priv->bbp_type);
+	}
+
+	ADM8211_RESTORE();
+
+	/* update current channel for adhoc (and maybe AP mode) */
+	reg =3D le32_to_cpu(ADM8211_CSR_READ(CAP0));
+	reg &=3D ~0xF;
+	reg |=3D channel;
+	ADM8211_CSR_WRITE(CAP0, cpu_to_le32(reg));
+
+	return 0;
+}
+
+static void adm8211_update_mode(struct net_device *dev)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+
+	ADM8211_IDLE();
+
+	priv->soft_rx_crc =3D 0;
+	switch (priv->mode) {
+	case IEEE80211_IF_TYPE_STA:
+		priv->nar &=3D ~(ADM8211_NAR_PR | ADM8211_NAR_EA);
+		priv->nar |=3D ADM8211_NAR_ST | ADM8211_NAR_SR;
+		break;
+	case IEEE80211_IF_TYPE_IBSS:
+		priv->nar &=3D ~ADM8211_NAR_PR;
+		priv->nar |=3D ADM8211_NAR_EA | ADM8211_NAR_ST | ADM8211_NAR_SR;
+
+		/* don't trust the error bits on rev 0x20 and up in adhoc */
+		if (priv->revid >=3D ADM8211_REV_BA)
+			priv->soft_rx_crc =3D 1;
+		break;
+	case IEEE80211_IF_TYPE_MNTR:
+		priv->nar &=3D ~(ADM8211_NAR_EA | ADM8211_NAR_ST);
+		priv->nar |=3D ADM8211_NAR_PR | ADM8211_NAR_SR;
+		break;
+	}
+
+	ADM8211_RESTORE();
+}
+
+static void adm8211_hw_init_syn(struct net_device *dev)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+
+	switch (priv->transceiver_type) {
+	case ADM8211_RFMD2958:
+	case ADM8211_RFMD2958_RF3000_CONTROL_POWER:
+		/* comments taken from ADMtek driver */
+	=09
+		/* Reset RF2958 after power on */
+		adm8211_rf_write_syn_rfmd2958(dev, 0x1F, 0x00000);
+		/* Initialize RF VCO Core Bias to maximum */
+		adm8211_rf_write_syn_rfmd2958(dev, 0x0C, 0x3001F);
+		/* Initialize IF PLL */
+		adm8211_rf_write_syn_rfmd2958(dev, 0x01, 0x29C03);
+		/* Initialize IF PLL Coarse Tuning */
+		adm8211_rf_write_syn_rfmd2958(dev, 0x03, 0x1FF6F);
+		/* Initialize RF PLL */
+		adm8211_rf_write_syn_rfmd2958(dev, 0x04, 0x29403);
+		/* Initialize RF PLL Coarse Tuning */
+		adm8211_rf_write_syn_rfmd2958(dev, 0x07, 0x1456F);
+		/* Initialize TX gain and filter BW (R9) */
+		adm8211_rf_write_syn_rfmd2958(dev, 0x09,
+			(priv->transceiver_type =3D=3D ADM8211_RFMD2958
+			? 0x10050 : 0x00050) );
+		/* Initialize CAL register */
+		adm8211_rf_write_syn_rfmd2958(dev, 0x08, 0x3FFF8);
+		break;
+
+	case ADM8211_MAX2820:
+		adm8211_rf_write_syn_max2820(dev, 0x1, 0x01E);
+		adm8211_rf_write_syn_max2820(dev, 0x2, 0x001);
+		adm8211_rf_write_syn_max2820(dev, 0x3, 0x054);
+		adm8211_rf_write_syn_max2820(dev, 0x4, 0x310);
+		adm8211_rf_write_syn_max2820(dev, 0x5, 0x000);
+		break;
+
+	case ADM8211_AL2210L:
+		adm8211_rf_write_syn_al2210l(dev, 0x0, 0x0196C);
+		adm8211_rf_write_syn_al2210l(dev, 0x1, 0x007CB);
+		adm8211_rf_write_syn_al2210l(dev, 0x2, 0x3582F);
+		adm8211_rf_write_syn_al2210l(dev, 0x3, 0x010A9);
+		adm8211_rf_write_syn_al2210l(dev, 0x4, 0x77280);
+		adm8211_rf_write_syn_al2210l(dev, 0x5, 0x45641);
+		adm8211_rf_write_syn_al2210l(dev, 0x6, 0xEA130);
+		adm8211_rf_write_syn_al2210l(dev, 0x7, 0x80000);
+		adm8211_rf_write_syn_al2210l(dev, 0x8, 0x7850F);
+		adm8211_rf_write_syn_al2210l(dev, 0x9, 0xF900C);
+		adm8211_rf_write_syn_al2210l(dev, 0xA, 0x00000);
+		adm8211_rf_write_syn_al2210l(dev, 0xB, 0x00000);
+		break;
+
+	case ADM8211_RFMD2948:
+	default:
+		break;
+	}
+}
+
+static int adm8211_hw_init_bbp(struct net_device *dev)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	u32 reg;
+
+	/* write addresses */
+	if (priv->bbp_type =3D=3D ADM8211_TYPE_INTERSIL) {
+		ADM8211_CSR_WRITE(MMIWA,  __constant_cpu_to_le32(0x100E0C0A));
+		ADM8211_CSR_WRITE(MMIRD0, __constant_cpu_to_le32(0x00007c7e));
+		ADM8211_CSR_WRITE(MMIRD1, __constant_cpu_to_le32(0x00100000));
+	} else if (priv->bbp_type =3D=3D ADM8211_TYPE_RFMD ||
+		   priv->bbp_type =3D=3D ADM8211_TYPE_ADMTEK) {
+
+	/* check specific BBP type */
+	switch (priv->specific_bbptype) {
+	case ADM8211_BBP_RFMD3000:
+	case ADM8211_BBP_RFMD3002:
+		ADM8211_CSR_WRITE(MMIWA,  __constant_cpu_to_le32(0x00009101));
+		ADM8211_CSR_WRITE(MMIRD0, __constant_cpu_to_le32(0x00000301));
+		break;
+
+	case ADM8211_BBP_ADM8011:
+		ADM8211_CSR_WRITE(MMIWA,  __constant_cpu_to_le32(0x00008903));
+		ADM8211_CSR_WRITE(MMIRD0, __constant_cpu_to_le32(0x00001716));
+
+		reg =3D le32_to_cpu(ADM8211_CSR_READ(BBPCTL));
+		reg &=3D ~ADM8211_BBPCTL_TYPE;
+		reg |=3D 0x5 << 18;
+		ADM8211_CSR_WRITE(BBPCTL, cpu_to_le32(reg));
+		break;
+	}
+
+	switch (priv->revid) {
+	case ADM8211_REV_CA:
+		if (priv->transceiver_type =3D=3D ADM8211_RFMD2958 ||
+		    priv->transceiver_type =3D=3D ADM8211_RFMD2958_RF3000_CONTROL_POWER =
||
+		    priv->transceiver_type =3D=3D ADM8211_RFMD2948)
+			ADM8211_CSR_WRITE(SYNCTL, __constant_cpu_to_le32(0x1 << 22));
+		else if (priv->transceiver_type =3D=3D ADM8211_MAX2820 ||
+			 priv->transceiver_type =3D=3D ADM8211_AL2210L)
+			ADM8211_CSR_WRITE(SYNCTL, __constant_cpu_to_le32(0x3 << 22));
+		break;
+
+	case ADM8211_REV_BA:
+		reg  =3D le32_to_cpu(ADM8211_CSR_READ(MMIRD1));
+		reg &=3D 0x0000FFFF;
+		reg |=3D 0x7e100000;
+		ADM8211_CSR_WRITE(MMIRD1, cpu_to_le32(reg));
+		break;
+
+	case ADM8211_REV_AB:
+	case ADM8211_REV_AF:
+	default:
+		ADM8211_CSR_WRITE(MMIRD1, __constant_cpu_to_le32(0x7e100000));
+		break;
+	}
+
+	/* For RFMD */
+	ADM8211_CSR_WRITE(MACTEST, __constant_cpu_to_le32(0x800));
+	}
+
+	adm8211_hw_init_syn(dev);
+
+	/* Set RF Power control IF pin to PE1+PHYRST# */
+	ADM8211_CSR_WRITE(SYNRF, __constant_cpu_to_le32(ADM8211_SYNRF_SELRF |
+			  ADM8211_SYNRF_PE1 | ADM8211_SYNRF_PHYRST));
+	ADM8211_CSR_READ(SYNRF);
+	mdelay(20);
+
+	/* write BBP regs */
+	if (priv->bbp_type =3D=3D ADM8211_TYPE_RFMD) {
+		/* RF3000 BBP */
+		/* another set:
+		 * 11: c8
+		 * 14: 14
+		 * 15: 50 (chan 1..13; chan 14: d0)
+		 * 1c: 00
+		 * 1d: 84
+		 */
+		adm8211_write_bbp(dev, RF3000_CCA_CTRL, 0x80);
+		adm8211_write_bbp(dev, RF3000_DIVERSITY__RSSI, 0x80); /* antenna selecti=
on:=20
diversity */
+		adm8211_write_bbp(dev, RF3000_TX_VAR_GAIN__TX_LEN_EXT, 0x74);
+		adm8211_write_bbp(dev, RF3000_LOW_GAIN_CALIB, 0x38);
+		adm8211_write_bbp(dev, RF3000_HIGH_GAIN_CALIB, 0x40);
+
+		if (priv->eeprom->major_version < 2) {
+			adm8211_write_bbp(dev, 0x1c, 0x00);
+			adm8211_write_bbp(dev, 0x1d, 0x80);
+		} else {
+			if (priv->revid =3D=3D ADM8211_REV_BA)
+				adm8211_write_bbp(dev, 0x1c, priv->eeprom->cr28);
+			else
+				adm8211_write_bbp(dev, 0x1c, 0x00);
+
+			adm8211_write_bbp(dev, 0x1d, priv->eeprom->cr29);
+		}
+	} else if (priv->bbp_type =3D=3D ADM8211_TYPE_ADMTEK) {
+	adm8211_write_bbp(dev, 0x00, 0xFF);	/* reset baseband */
+	adm8211_write_bbp(dev, 0x07, 0x0A);	/* antenna selection: diversity */
+
+	/* TODO: find documentation for this */
+	switch (priv->transceiver_type) {
+	case ADM8211_RFMD2958:
+	case ADM8211_RFMD2958_RF3000_CONTROL_POWER:
+		adm8211_write_bbp(dev, 0x00, 0x00);
+		adm8211_write_bbp(dev, 0x01, 0x00);
+		adm8211_write_bbp(dev, 0x02, 0x00);
+		adm8211_write_bbp(dev, 0x03, 0x00);
+		adm8211_write_bbp(dev, 0x06, 0x0f);
+		adm8211_write_bbp(dev, 0x09, 0x00);
+		adm8211_write_bbp(dev, 0x0a, 0x00);
+		adm8211_write_bbp(dev, 0x0b, 0x00);
+		adm8211_write_bbp(dev, 0x0c, 0x00);
+		adm8211_write_bbp(dev, 0x0f, 0xAA);
+		adm8211_write_bbp(dev, 0x10, 0x8c);
+		adm8211_write_bbp(dev, 0x11, 0x43);
+		adm8211_write_bbp(dev, 0x18, 0x40);
+		adm8211_write_bbp(dev, 0x20, 0x23);
+		adm8211_write_bbp(dev, 0x21, 0x02);
+		adm8211_write_bbp(dev, 0x22, 0x28);
+		adm8211_write_bbp(dev, 0x23, 0x30);
+		adm8211_write_bbp(dev, 0x24, 0x2d);
+		adm8211_write_bbp(dev, 0x28, 0x35);
+		adm8211_write_bbp(dev, 0x2a, 0x8c);
+		adm8211_write_bbp(dev, 0x2b, 0x81);
+		adm8211_write_bbp(dev, 0x2c, 0x44);
+		adm8211_write_bbp(dev, 0x2d, 0x0A);
+		adm8211_write_bbp(dev, 0x29, 0x40);
+		adm8211_write_bbp(dev, 0x60, 0x08);
+		adm8211_write_bbp(dev, 0x64, 0x01);
+		break;
+
+	case ADM8211_MAX2820:
+		adm8211_write_bbp(dev, 0x00, 0x00);
+		adm8211_write_bbp(dev, 0x01, 0x00);
+		adm8211_write_bbp(dev, 0x02, 0x00);
+		adm8211_write_bbp(dev, 0x03, 0x00);
+		adm8211_write_bbp(dev, 0x06, 0x0f);
+		adm8211_write_bbp(dev, 0x09, 0x05);
+		adm8211_write_bbp(dev, 0x0a, 0x02);
+		adm8211_write_bbp(dev, 0x0b, 0x00);
+		adm8211_write_bbp(dev, 0x0c, 0x0f);
+		adm8211_write_bbp(dev, 0x0f, 0x55);
+		adm8211_write_bbp(dev, 0x10, 0x8d);
+		adm8211_write_bbp(dev, 0x11, 0x43);
+		adm8211_write_bbp(dev, 0x18, 0x4a);
+		adm8211_write_bbp(dev, 0x20, 0x20);
+		adm8211_write_bbp(dev, 0x21, 0x02);
+		adm8211_write_bbp(dev, 0x22, 0x23);
+		adm8211_write_bbp(dev, 0x23, 0x30);
+		adm8211_write_bbp(dev, 0x24, 0x2d);
+		adm8211_write_bbp(dev, 0x2a, 0x8c);
+		adm8211_write_bbp(dev, 0x2b, 0x81);
+		adm8211_write_bbp(dev, 0x2c, 0x44);
+		adm8211_write_bbp(dev, 0x29, 0x4a);
+		adm8211_write_bbp(dev, 0x60, 0x2b);
+		adm8211_write_bbp(dev, 0x64, 0x01);
+		break;
+
+	case ADM8211_AL2210L:
+		adm8211_write_bbp(dev, 0x00, 0x00);
+		adm8211_write_bbp(dev, 0x01, 0x00);
+		adm8211_write_bbp(dev, 0x02, 0x00);
+		adm8211_write_bbp(dev, 0x03, 0x00);
+		adm8211_write_bbp(dev, 0x06, 0x0f);
+		adm8211_write_bbp(dev, 0x07, 0x05);
+		adm8211_write_bbp(dev, 0x08, 0x03);
+		adm8211_write_bbp(dev, 0x09, 0x00);
+		adm8211_write_bbp(dev, 0x0a, 0x00);
+		adm8211_write_bbp(dev, 0x0b, 0x00);
+		adm8211_write_bbp(dev, 0x0c, 0x10);
+		adm8211_write_bbp(dev, 0x0f, 0x55);
+		adm8211_write_bbp(dev, 0x10, 0x8d);
+		adm8211_write_bbp(dev, 0x11, 0x43);
+		adm8211_write_bbp(dev, 0x18, 0x4a);
+		adm8211_write_bbp(dev, 0x20, 0x20);
+		adm8211_write_bbp(dev, 0x21, 0x02);
+		adm8211_write_bbp(dev, 0x22, 0x23);
+		adm8211_write_bbp(dev, 0x23, 0x30);
+		adm8211_write_bbp(dev, 0x24, 0x2d);
+		adm8211_write_bbp(dev, 0x2a, 0xaa);
+		adm8211_write_bbp(dev, 0x2b, 0x81);
+		adm8211_write_bbp(dev, 0x2c, 0x44);
+		adm8211_write_bbp(dev, 0x29, 0xfa);
+		adm8211_write_bbp(dev, 0x60, 0x2d);
+		adm8211_write_bbp(dev, 0x64, 0x01);
+		break;
+
+	case ADM8211_RFMD2948:
+		break;
+
+	default:
+		printk(KERN_DEBUG "%s: unsupported transceiver type %d\n",
+		       dev->name, priv->transceiver_type);
+		break;
+	}
+	} else {
+		printk(KERN_DEBUG "%s: unsupported BBP type %d\n",
+		       dev->name, priv->bbp_type);
+	}
+
+	ADM8211_CSR_WRITE(SYNRF, 0);
+
+	/* Set RF CAL control source to MAC control */
+	reg =3D le32_to_cpu(ADM8211_CSR_READ(SYNCTL));
+	reg |=3D ADM8211_SYNCTL_SELCAL;
+	ADM8211_CSR_WRITE(SYNCTL, cpu_to_le32(reg));
+
+	return 0;
+}
+
+// configures hw beacons/probe responses
+static int adm8211_set_rate(struct net_device *dev)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	u32 reg;
+	int i =3D 0;
+	u8 rate_buf[12] =3D {0};
+
+	/* write supported rates */
+	if (priv->revid !=3D ADM8211_REV_BA) {
+		rate_buf[0] =3D ARRAY_SIZE(adm8211_rates);
+		for (i =3D 0; i < ARRAY_SIZE(adm8211_rates); i++)
+			rate_buf[i+1] =3D (adm8211_rates[i].rate/5) | 0x80;
+	} else {
+		/* workaround for rev BA specific bug */
+		rate_buf[0]=3D4;
+		rate_buf[1]=3D0x82;
+		rate_buf[2]=3D0x04;
+		rate_buf[3]=3D0x0b;
+		rate_buf[4]=3D0x16;
+	}
+=09
+	adm8211_write_sram_bytes(dev, ADM8211_SRAM_SUPP_RATE, rate_buf,=20
ARRAY_SIZE(adm8211_rates)+1);
+
+	reg =3D le32_to_cpu(ADM8211_CSR_READ(PLCPHD)) & 0x00FFFFFF; /* keep bits =
0-23=20
*/
+	reg |=3D (1 << 15);	/* short preamble */
+	reg |=3D 110 << 24;
+	ADM8211_CSR_WRITE(PLCPHD, cpu_to_le32(reg));
+
+	/* MTMLT   =3D 512 TU (max TX MSDU lifetime)
+	 * BCNTSIG =3D plcp_signal (beacon, probe resp, and atim TX rate)
+	 * SRTYLIM =3D 224 (short retry limit, value in TX header used by default=
) */
+	ADM8211_CSR_WRITE(TXLMT, cpu_to_le32((512<<16) | (110<<8) | (224<<0)));
+
+	return 0;
+}
+
+static void adm8211_hw_init(struct net_device *dev)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	u32 reg;
+	u8 cacheline;
+
+	reg =3D le32_to_cpu(ADM8211_CSR_READ(PAR));
+	reg |=3D ADM8211_PAR_MRLE | ADM8211_PAR_MRME;
+	reg &=3D ~(ADM8211_PAR_BAR | ADM8211_PAR_CAL);
+
+	if (!pci_set_mwi(priv->pdev)) {
+		reg |=3D (0x1<<24);
+		pci_read_config_byte(priv->pdev, PCI_CACHE_LINE_SIZE, &cacheline);
+
+		switch (cacheline) {
+		case  0x8: reg |=3D (0x1<<14);
+			   break;
+		case 0x16: reg |=3D (0x2<<14);
+			   break;
+		case 0x32: reg |=3D (0x3<<14);
+			   break;
+		  default: reg |=3D (0x0<<14);
+			   break;
+		}
+	}
+
+	ADM8211_CSR_WRITE(PAR, cpu_to_le32(reg));
+
+	reg =3D le32_to_cpu(ADM8211_CSR_READ(CSR_TEST1));
+	reg &=3D ~(0xF<<28);
+	reg |=3D ((1 << 28) | (1 << 31));
+	ADM8211_CSR_WRITE(CSR_TEST1, cpu_to_le32(reg));
+
+	/* lose link after 4 lost beacons */
+	reg =3D (0x04 << 21) | ADM8211_WCSR_TSFTWE | ADM8211_WCSR_LSOE;
+	ADM8211_CSR_WRITE(WCSR, cpu_to_le32(reg));
+
+	/* Disable APM, enable receive FIFO threshold, and set drain receive
+	 * threshold to store-and-forward */
+	reg =3D le32_to_cpu(ADM8211_CSR_READ(CMDR));
+	reg &=3D ~(ADM8211_CMDR_APM | ADM8211_CMDR_DRT);
+	reg |=3D ADM8211_CMDR_RTE | ADM8211_CMDR_DRT_SF;
+	ADM8211_CSR_WRITE(CMDR, cpu_to_le32(reg));
+
+	adm8211_set_rate(dev);
+
+	/* 4-bit values:
+	 * PWR1UP   =3D 8 * 2 ms
+	 * PWR0PAPE =3D 8 us or 5 us
+	 * PWR1PAPE =3D 1 us or 3 us
+	 * PWR0TRSW =3D 5 us
+	 * PWR1TRSW =3D 12 us
+	 * PWR0PE2  =3D 13 us
+	 * PWR1PE2  =3D 1 us
+	 * PWR0TXPE =3D 8 or 6 */
+	if (priv->revid < ADM8211_REV_CA)
+		ADM8211_CSR_WRITE(TOFS2, __constant_cpu_to_le32(0x8815cd18));
+	else
+		ADM8211_CSR_WRITE(TOFS2, __constant_cpu_to_le32(0x8535cd16));
+
+	/* Enable store and forward for transmit */
+	priv->nar =3D ADM8211_NAR_SF | ADM8211_NAR_PB;
+	ADM8211_CSR_WRITE(NAR, cpu_to_le32(priv->nar));
+
+	/* Reset RF */
+	ADM8211_CSR_WRITE(SYNRF, __constant_cpu_to_le32(ADM8211_SYNRF_RADIO));
+	ADM8211_CSR_READ(SYNRF);
+	mdelay(10);
+	ADM8211_CSR_WRITE(SYNRF, 0);
+	ADM8211_CSR_READ(SYNRF);
+	mdelay(5);
+
+	/* Set CFP Max Duration to 0x10 TU */
+	reg =3D le32_to_cpu(ADM8211_CSR_READ(CFPP));
+	reg &=3D ~(0xffff<<8);
+	reg |=3D 0x0010<<8;
+	ADM8211_CSR_WRITE(CFPP, cpu_to_le32(reg));
+
+	/* USCNT =3D 0x16 (number of system clocks, 22 MHz, in 1us
+	 * TUCNT =3D 0x3ff - Tu counter 1024 us  */
+	ADM8211_CSR_WRITE(TOFS0, __constant_cpu_to_le32((0x16 << 24) | 0x3ff));
+
+	/* SLOT=3D20 us, SIFS=3D110 cycles of 22 MHz (5 us),
+	 * DIFS=3D50 us, EIFS=3D100 us */
+	if (priv->revid < ADM8211_REV_CA)
+		ADM8211_CSR_WRITE(IFST, __constant_cpu_to_le32(
+					(20 << 23) | (110 << 15) |
+					(50 << 9)  | 100));
+	else
+		ADM8211_CSR_WRITE(IFST, __constant_cpu_to_le32(
+					(20 << 23) | (24 << 15) |
+					(50 << 9)  | 100));
+
+	/* PCNT =3D 1 (MAC idle time awake/sleep, unit S)
+	 * RMRD =3D 2346 * 8 + 1 us (max RX duration)  */
+	ADM8211_CSR_WRITE(RMD, __constant_cpu_to_le32((1 << 16) | 18769));
+
+	/* MART=3D65535 us, MIRT=3D256 us, TSFTOFST=3D0 us */
+	ADM8211_CSR_WRITE(RSPT, __constant_cpu_to_le32(0xffffff00));
+
+	/* Initialize BBP (and SYN) */
+	adm8211_hw_init_bbp(dev);
+
+	/* make sure interrupts are off */
+	ADM8211_CSR_WRITE(IER, 0);
+
+	/* ACK interrupts */
+	ADM8211_CSR_WRITE(STSR, ADM8211_CSR_READ(STSR));
+
+	/* Setup WEP (turns it off for now) */
+	reg =3D le32_to_cpu(ADM8211_CSR_READ(MACTEST));
+	reg &=3D ~(7<<20);
+	ADM8211_CSR_WRITE(MACTEST, cpu_to_le32(reg));
+
+	reg =3D le32_to_cpu(ADM8211_CSR_READ(WEPCTL));
+	reg &=3D ~ADM8211_WEPCTL_WEPENABLE;
+	reg |=3D ADM8211_WEPCTL_WEPRXBYP;
+	ADM8211_CSR_WRITE(WEPCTL, cpu_to_le32(reg));
+
+	/* Clear the missed-packet counter. */
+	ADM8211_CSR_READ(LPC);
+
+	/* set mac address */
+	ADM8211_CSR_WRITE(PAR0, *(u32 *)dev->dev_addr);
+	ADM8211_CSR_WRITE(PAR1, *(u16 *)(dev->dev_addr + 4));
+}
+
+static int adm8211_hw_reset(struct net_device *dev)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	u32 reg;
+	__le32 tmp;
+	int timeout =3D 50;
+
+	/* Power-on issue */
+	/* TODO: check if this is necessary */
+	ADM8211_CSR_WRITE(FRCTL, 0);
+
+	/* Reset the chip */
+	tmp =3D ADM8211_CSR_READ(PAR);
+	ADM8211_CSR_WRITE(PAR, ADM8211_PAR_SWR);
+
+	while ((ADM8211_CSR_READ(PAR) & __constant_cpu_to_le32(ADM8211_PAR_SWR)) =
&&=20
timeout--)
+		mdelay(100);
+
+	if (timeout <=3D 0)
+		return -ETIMEDOUT;
+
+	ADM8211_CSR_WRITE(PAR, tmp);
+
+	if (priv->revid =3D=3D ADM8211_REV_BA &&
+	    ( priv->transceiver_type =3D=3D ADM8211_RFMD2958_RF3000_CONTROL_POWER
+	   || priv->transceiver_type =3D=3D ADM8211_RFMD2958)) {
+		reg =3D le32_to_cpu(ADM8211_CSR_READ(CSR_TEST1));
+		reg |=3D (1 << 4) | (1 << 5);
+		ADM8211_CSR_WRITE(CSR_TEST1, cpu_to_le32(reg));
+	} else if (priv->revid =3D=3D ADM8211_REV_CA) {
+		reg =3D le32_to_cpu(ADM8211_CSR_READ(CSR_TEST1));
+		reg &=3D ~((1 << 4) | (1 << 5));
+		ADM8211_CSR_WRITE(CSR_TEST1, cpu_to_le32(reg));
+	}
+
+	ADM8211_CSR_WRITE(FRCTL, 0);
+
+	reg =3D le32_to_cpu(ADM8211_CSR_READ(CSR_TEST0));
+	reg |=3D ADM8211_CSR_TEST0_EPRLD;	/* EEPROM Recall */
+	ADM8211_CSR_WRITE(CSR_TEST0, cpu_to_le32(reg));
+
+	adm8211_clear_sram(dev);
+
+	return 0;
+}
+
+static u64 adm8211_get_tsft(struct net_device *dev)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	u32 tsftl;
+	u64 tsft;
+
+	tsftl =3D le32_to_cpu(ADM8211_CSR_READ(TSFTL));
+	tsft =3D le32_to_cpu(ADM8211_CSR_READ(TSFTH));
+	tsft <<=3D 32;
+	tsft |=3D tsftl;
+
+	return tsft;
+}
+
+static void adm8211_set_interval(struct net_device *dev,
+				 unsigned short bi, unsigned short li)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	u32 reg;
+
+	/* BP (beacon interval) =3D data->beacon_interval
+	 * LI (listen interval) =3D data->listen_interval (in beacon intervals) */
+	reg =3D (bi << 16) | li;
+	ADM8211_CSR_WRITE(BPLI, cpu_to_le32(reg));
+}
+
+static void adm8211_set_bssid(struct net_device *dev, u8 *bssid)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	u32 reg;
+
+	reg =3D bssid[0] | (bssid[1] << 8) | (bssid[2] << 16) | (bssid[3] << 24);
+	ADM8211_CSR_WRITE(BSSID0, cpu_to_le32(reg));
+	reg =3D le32_to_cpu(ADM8211_CSR_READ(ABDA1));
+	reg &=3D 0x0000ffff;
+	reg |=3D (bssid[4] << 16) | (bssid[5] << 24);
+	ADM8211_CSR_WRITE(ABDA1, cpu_to_le32(reg));
+}
+
+static int adm8211_set_ssid(struct net_device *dev, u8 *ssid, size_t=20
ssid_len)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	u8 buf[36];
+
+	if (ssid_len > 32)
+		return -EINVAL;
+
+	memset(buf, 0, sizeof(buf));
+	buf[0] =3D ssid_len;
+	memcpy(buf + 1, ssid, ssid_len);
+	adm8211_write_sram_bytes(dev, ADM8211_SRAM_SSID, buf, 33);
+	//adm8211_set_beacon(dev);
+	return 0;
+}
+
+static int adm8211_config(struct net_device *dev, struct ieee80211_conf=20
*conf)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+
+	if (conf->channel !=3D priv->channel) {
+		priv->channel =3D conf->channel;
+		adm8211_rf_set_channel(dev, priv->channel);
+	}
+
+	return 0;
+}
+
+static int adm8211_config_interface(struct net_device *dev, int if_id,
+				    struct ieee80211_if_conf *conf)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+
+	if (memcmp(conf->bssid, priv->bssid, ETH_ALEN)) {
+		adm8211_set_bssid(dev, conf->bssid);
+		memcpy(priv->bssid, conf->bssid, ETH_ALEN);
+	}
+
+	if (conf->ssid_len !=3D priv->ssid_len ||
+	    memcmp(conf->ssid, priv->ssid, conf->ssid_len)) {
+		adm8211_set_ssid(dev, conf->ssid, conf->ssid_len);
+		priv->ssid_len =3D conf->ssid_len;
+		memcpy(priv->ssid, conf->ssid, conf->ssid_len);
+	}
+
+	return 0;
+}
+static int adm8211_scan(struct net_device *dev, int state,
+			struct ieee80211_scan_conf *conf)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	if (state =3D=3D IEEE80211_SCAN_START) {
+		priv->channel =3D conf->scan_channel;
+		adm8211_rf_set_channel(dev, conf->scan_channel);
+	} else if (state =3D=3D IEEE80211_SCAN_END) {
+		priv->channel =3D conf->running_channel;
+		adm8211_rf_set_channel(dev, conf->running_channel);
+	}
+
+	return 0;
+}
+
+static int adm8211_add_interface(struct net_device *dev,
+				 struct ieee80211_if_init_conf *conf)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	/* NOTE: using IEEE80211_IF_TYPE_MGMT to indicate no mode selected */
+	if (priv->mode !=3D IEEE80211_IF_TYPE_MGMT)
+		return -1;
+
+	switch (conf->type) {
+	case IEEE80211_IF_TYPE_STA:
+	case IEEE80211_IF_TYPE_MNTR:
+		priv->mode =3D conf->type;
+		return 0;
+	default:
+		return -1;
+	}
+}
+
+static void adm8211_remove_interface(struct net_device *dev,
+				     struct ieee80211_if_init_conf *conf)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	priv->mode =3D IEEE80211_IF_TYPE_MGMT;
+}
+
+static int adm8211_init_rings(struct net_device *dev)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	struct adm8211_desc *desc =3D NULL;
+	struct adm8211_ring_info *info;
+	unsigned int i;
+
+	for (i =3D 0; i < priv->rx_ring_size; i++) {
+		desc =3D &priv->rx_ring[i];
+		desc->status =3D 0;
+		desc->length =3D cpu_to_le32(RX_PKT_SIZE);
+		priv->rx_buffers[i].skb =3D NULL;
+	}
+	/* Mark the end of RX ring; hw returns to base address after this
+	 * descriptor */
+	desc->length |=3D cpu_to_le32(RDES1_CONTROL_RER);
+
+	for (i =3D 0; i < priv->rx_ring_size; i++) {
+		desc =3D &priv->rx_ring[i];
+		info =3D &priv->rx_buffers[i];
+
+		info->skb =3D dev_alloc_skb(RX_PKT_SIZE);
+		if (info->skb =3D=3D NULL)
+			break;
+		info->mapping =3D pci_map_single(priv->pdev, info->skb->tail,
+					       RX_PKT_SIZE,
+					       PCI_DMA_FROMDEVICE);
+		info->skb->dev =3D dev;
+		desc->buffer1 =3D cpu_to_le32(info->mapping);
+		desc->status =3D cpu_to_le32( RDES0_STATUS_OWN | RDES0_STATUS_SQL );
+	}
+
+	/* Setup TX ring. TX buffers descriptors will be filled in as needed */
+	for (i =3D 0; i < priv->tx_ring_size; i++) {
+		desc =3D &priv->tx_ring[i];
+		info =3D &priv->tx_buffers[i];
+
+		info->skb =3D NULL;
+		info->mapping =3D 0;
+		desc->status =3D 0;
+	}
+	desc->length =3D cpu_to_le32(TDES1_CONTROL_TER);
+
+	priv->cur_rx =3D priv->cur_tx =3D priv->dirty_tx =3D 0;
+	ADM8211_CSR_WRITE(RDB, cpu_to_le32(priv->rx_ring_dma));
+	ADM8211_CSR_WRITE(TDBD, cpu_to_le32(priv->tx_ring_dma));
+
+	return 0;
+}
+
+static void adm8211_free_rings(struct net_device *dev)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	unsigned int i;
+
+	for (i =3D 0; i < priv->rx_ring_size; i++) {
+		if (!priv->rx_buffers[i].skb)
+			continue;
+
+		pci_unmap_single(
+			priv->pdev,
+			priv->rx_buffers[i].mapping,
+			RX_PKT_SIZE, PCI_DMA_FROMDEVICE);
+
+		dev_kfree_skb(priv->rx_buffers[i].skb);
+	}
+
+	for (i =3D 0; i < priv->tx_ring_size; i++) {
+		if (!priv->tx_buffers[i].skb)
+			continue;
+
+		pci_unmap_single(
+			priv->pdev,
+			priv->tx_buffers[i].mapping,
+			priv->tx_buffers[i].skb->len, PCI_DMA_TODEVICE);
+
+		dev_kfree_skb(priv->tx_buffers[i].skb);
+	}
+}
+
+static int adm8211_open(struct net_device *dev)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	int retval;
+
+	/* Power up MAC and RF chips */
+	retval =3D adm8211_hw_reset(dev);
+	if (retval) {
+		printk(KERN_ERR "%s: hardware reset failed\n", dev->name);
+		goto fail;
+	}
+
+	retval =3D adm8211_init_rings(dev);
+	if (retval) {
+		printk(KERN_ERR "%s: failed to initialize rings\n", dev->name);
+		goto fail;
+	}
+
+	/* Init hardware */
+	adm8211_hw_init(dev);
+	adm8211_rf_set_channel(dev, priv->channel);
+
+	retval =3D request_irq(dev->irq, &adm8211_interrupt,
+			     SA_SHIRQ, dev->name, dev);
+	if (retval) {
+		printk(KERN_ERR "%s: failed to register IRQ handler\n",
+		       dev->name);
+		goto fail;
+	}
+
+	ADM8211_CSR_WRITE(IER, __constant_cpu_to_le32(ADM8211_INTMASK));
+	adm8211_update_mode(dev);
+	ADM8211_CSR_WRITE(RDR, 0);
+
+	adm8211_set_interval(dev, 100, 10);
+	return 0;
+
+fail:
+	return retval;
+}
+
+static int adm8211_stop(struct net_device *dev)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+
+	priv->nar =3D 0;
+	ADM8211_CSR_WRITE(NAR, 0);
+	ADM8211_CSR_WRITE(IER, 0);
+	ADM8211_CSR_READ(NAR);
+
+	free_irq(dev->irq, dev);
+
+	adm8211_free_rings(dev);
+
+	adm8211_hw_reset(dev);
+	return 0;
+}
+
+static int adm8211_reset(struct net_device *dev)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	int retval =3D 0;
+
+	priv->nar =3D 0;
+	ADM8211_CSR_WRITE(NAR, 0);
+	ADM8211_CSR_WRITE(IER, 0);
+	ADM8211_CSR_READ(NAR);
+
+	adm8211_free_rings(dev);
+
+	retval =3D adm8211_hw_reset(dev);
+	if (retval) {
+		printk(KERN_ERR "%s: hardware reset failed\n", dev->name);
+		goto fail;
+	}
+
+	retval =3D adm8211_init_rings(dev);
+	if (retval) {
+		printk(KERN_ERR "%s: failed to initialize rings\n", dev->name);
+		goto fail;
+	}
+
+	adm8211_hw_init(dev);
+	adm8211_rf_set_channel(dev, priv->channel);
+
+	ADM8211_CSR_WRITE(IER, __constant_cpu_to_le32(ADM8211_INTMASK));
+	adm8211_update_mode(dev);
+	ADM8211_CSR_WRITE(RDR, 0);
+
+fail:
+	return retval;
+}
+
+static void adm8211_calc_durations(int *dur, int *plcp, size_t payload_len=
,=20
int len,
+				   int plcp_signal, int short_preamble)
+{
+	/* Alternative calculation from NetBSD: */
+
+/* IEEE 802.11b durations for DSSS PHY in microseconds */
+#define IEEE80211_DUR_DS_LONG_PREAMBLE	144
+#define IEEE80211_DUR_DS_SHORT_PREAMBLE	72
+#define IEEE80211_DUR_DS_FAST_PLCPHDR	24
+#define IEEE80211_DUR_DS_SLOW_PLCPHDR	48
+#define IEEE80211_DUR_DS_SLOW_ACK	112
+#define IEEE80211_DUR_DS_FAST_ACK	56
+#define IEEE80211_DUR_DS_SLOW_CTS	112
+#define IEEE80211_DUR_DS_FAST_CTS	56
+#define IEEE80211_DUR_DS_SLOT		20
+#define IEEE80211_DUR_DS_SIFS		10
+
+	int remainder;
+
+	*dur =3D (80 * (24 + payload_len) + plcp_signal - 1)
+		/ plcp_signal;
+
+	if (plcp_signal <=3D PLCP_SIGNAL_2M)
+		/* 1-2Mbps WLAN: send ACK/CTS at 1Mbps */
+		*dur +=3D 3 * (IEEE80211_DUR_DS_SIFS +
+			     IEEE80211_DUR_DS_SHORT_PREAMBLE +
+			     IEEE80211_DUR_DS_FAST_PLCPHDR) +
+			     IEEE80211_DUR_DS_SLOW_CTS + IEEE80211_DUR_DS_SLOW_ACK;
+	else
+		/* 5-11Mbps WLAN: send ACK/CTS at 2Mbps */
+		*dur +=3D 3 * (IEEE80211_DUR_DS_SIFS +
+			     IEEE80211_DUR_DS_SHORT_PREAMBLE +
+			     IEEE80211_DUR_DS_FAST_PLCPHDR) +
+			     IEEE80211_DUR_DS_FAST_CTS + IEEE80211_DUR_DS_FAST_ACK;
+
+	/* lengthen duration if long preamble */
+	if (!short_preamble)
+		*dur +=3D	3 * (IEEE80211_DUR_DS_LONG_PREAMBLE -
+			     IEEE80211_DUR_DS_SHORT_PREAMBLE) +
+			3 * (IEEE80211_DUR_DS_SLOW_PLCPHDR -
+			     IEEE80211_DUR_DS_FAST_PLCPHDR);
+
+
+	*plcp =3D (80 * len) / plcp_signal;
+	remainder =3D (80 * len) % plcp_signal;
+	if (plcp_signal =3D=3D PLCP_SIGNAL_11M &&
+	    remainder <=3D 30 && remainder > 0)
+		*plcp =3D (*plcp | 0x8000) + 1;
+	else if (remainder)
+		(*plcp)++;
+}
+
+/* Transmit skb w/adm8211_tx_hdr (802.11 header created by hardware) */
+static void adm8211_tx_raw(struct net_device *dev, struct sk_buff *skb,
+			   u16 plcp_signal, struct ieee80211_tx_control *control, int unicast)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	unsigned long flags;
+	dma_addr_t mapping;
+	unsigned entry;
+	u32 flag;
+
+	mapping =3D pci_map_single(priv->pdev, skb->data, skb->len,
+				 PCI_DMA_TODEVICE);
+
+	spin_lock_irqsave(&priv->lock, flags);
+
+	if (priv->cur_tx - priv->dirty_tx < priv->tx_ring_size / 2)
+		flag =3D TDES1_CONTROL_IC | TDES1_CONTROL_LS | TDES1_CONTROL_FS;
+	else if (priv->cur_tx - priv->dirty_tx =3D=3D priv->tx_ring_size / 2)
+		flag =3D TDES1_CONTROL_IC | TDES1_CONTROL_LS | TDES1_CONTROL_FS;
+	else if (priv->cur_tx - priv->dirty_tx < priv->tx_ring_size - 2)
+		flag =3D TDES1_CONTROL_LS | TDES1_CONTROL_FS;
+	else {
+		flag =3D TDES1_CONTROL_IC | TDES1_CONTROL_LS | TDES1_CONTROL_FS;
+		printk(KERN_DEBUG "%s: Yikes, this shouldn't happen!\n", dev->name);
+		netif_stop_queue(dev);
+	}
+
+	entry =3D priv->cur_tx % priv->tx_ring_size;
+
+	priv->tx_buffers[entry].skb =3D skb;
+	priv->tx_buffers[entry].mapping =3D mapping;
+	memcpy(&priv->tx_buffers[entry].tx_status.control, control,=20
sizeof(*control));
+	priv->tx_buffers[entry].unicast =3D unicast;
+	priv->tx_ring[entry].buffer1 =3D cpu_to_le32(mapping);
+
+	if (entry =3D=3D priv->tx_ring_size - 1)
+		flag |=3D TDES1_CONTROL_TER;
+	priv->tx_ring[entry].length =3D cpu_to_le32(flag | skb->len);
+
+	/* Set TX rate (SIGNAL field in PLCP PPDU format) */
+	flag =3D TDES0_CONTROL_OWN | (plcp_signal << 20) | 8 /* ? */;
+	priv->tx_ring[entry].status =3D cpu_to_le32(flag);
+
+	priv->cur_tx++;
+
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	/* Trigger transmit poll */
+	ADM8211_CSR_WRITE(TDR, 0);
+
+	dev->trans_start =3D jiffies;
+}
+
+/* Put adm8211_tx_hdr on skb and transmit */
+static int adm8211_tx(struct net_device *dev, struct sk_buff *skb,
+		      struct ieee80211_tx_control *control)
+{
+	struct adm8211_tx_hdr *txhdr;
+	struct ieee80211_hdr *hdr;
+	u16 fc_;
+	__le16 fc;
+	u8 dst[ETH_ALEN];
+	size_t payload_len, hdrlen;
+	int plcp, dur, len;
+	int plcp_signal;
+	int short_preamble;
+
+	if (control->tx_rate < 0) {
+		short_preamble =3D 1;
+		plcp_signal =3D -control->tx_rate;
+	} else {
+		short_preamble =3D 0;
+		plcp_signal =3D control->tx_rate;
+	}
+
+	hdr =3D (struct ieee80211_hdr *)skb->data;
+	fc  =3D hdr->frame_control;
+	fc_ =3D le16_to_cpu(fc);
+	memcpy(dst, ieee80211_get_DA(hdr), ETH_ALEN);
+
+	hdrlen =3D ieee80211_get_hdrlen(fc_);
+	skb_pull(skb, hdrlen);
+	fc_ &=3D ~WLAN_FC_ISWEP;
+	payload_len =3D skb->len;
+
+	if (skb_headroom(skb) < sizeof(struct adm8211_tx_hdr)) {
+		if (pskb_expand_head(skb, sizeof(struct adm8211_tx_hdr), 0, GFP_ATOMIC))=
 {
+			printk(KERN_DEBUG "%s: failed to allocate room for TX "
+			       "header\n", dev->name);
+			dev_kfree_skb(skb);
+			return 0;
+		}
+	}
+
+	txhdr =3D (struct adm8211_tx_hdr *) skb_push(skb, sizeof(*txhdr));
+	memset(txhdr, 0, sizeof(*txhdr));
+	memcpy(txhdr->da, dst, ETH_ALEN);
+	txhdr->signal =3D plcp_signal;
+	txhdr->frame_body_size =3D cpu_to_le16(payload_len);
+	txhdr->frame_control =3D fc;
+
+	len =3D hdrlen + payload_len + FCS_LEN;
+	if (fc_ & WLAN_FC_ISWEP)
+		len +=3D 8;
+
+	txhdr->frag =3D cpu_to_le16(0x0FFF);
+	adm8211_calc_durations(&dur, &plcp, payload_len,
+			       len, plcp_signal, short_preamble);
+	txhdr->plcp_frag_head_len =3D cpu_to_le16(plcp);
+	txhdr->plcp_frag_tail_len =3D cpu_to_le16(plcp);
+	txhdr->dur_frag_head =3D cpu_to_le16(dur);
+	txhdr->dur_frag_tail =3D cpu_to_le16(dur);
+
+	txhdr->header_control =3D cpu_to_le16(ADM8211_TXHDRCTL_ENABLE_EXTEND_HEAD=
ER);
+
+	if (short_preamble)
+		txhdr->header_control |=3D cpu_to_le16(ADM8211_TXHDRCTL_SHORT_PREAMBLE);
+
+	if (control->use_rts_cts)
+		txhdr->header_control |=3D cpu_to_le16(ADM8211_TXHDRCTL_ENABLE_RTS);
+
+	if (fc_ & WLAN_FC_ISWEP)
+		txhdr->header_control |=3D cpu_to_le16(ADM8211_TXHDRCTL_ENABLE_WEP_ENGIN=
E);
+
+	txhdr->retry_limit =3D control->retry_limit;
+
+	adm8211_tx_raw(dev, skb, plcp_signal,=20
control, !is_multicast_ether_addr(dst));
+
+	return NETDEV_TX_OK;
+}
+
+static int adm8211_alloc_rings(struct net_device *dev)
+{
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+	unsigned int ring_size;
+
+	priv->rx_buffers =3D kmalloc(sizeof(struct adm8211_ring_info) *
+				(priv->rx_ring_size + priv->tx_ring_size), GFP_KERNEL);
+	if (!priv->rx_buffers)
+		return -ENOMEM;
+=09
+	priv->tx_buffers =3D ((void *)priv->rx_buffers) + sizeof(struct=20
adm8211_ring_info) * priv->tx_ring_size;
+
+	/* Allocate TX/RX descriptors */
+	ring_size =3D sizeof(struct adm8211_desc) * priv->rx_ring_size +
+		    sizeof(struct adm8211_desc) * priv->tx_ring_size;
+	priv->rx_ring =3D pci_alloc_consistent(priv->pdev, ring_size,
+					     &priv->rx_ring_dma);
+
+	if (!priv->rx_ring) {
+		kfree(priv->rx_buffers);
+		priv->rx_buffers =3D priv->tx_buffers =3D NULL;
+		return -ENOMEM;
+	}
+
+	priv->tx_ring =3D (struct adm8211_desc *) (priv->rx_ring +=20
priv->rx_ring_size);
+	priv->tx_ring_dma =3D priv->rx_ring_dma +
+		sizeof(struct adm8211_desc) * priv->rx_ring_size;
+
+	return 0;
+}
+
+static int __devinit adm8211_probe(struct pci_dev *pdev,
+				   const struct pci_device_id *id)
+{
+	struct net_device *dev;
+	struct ieee80211_hw *hw;
+	struct adm8211_priv *priv;
+	unsigned long mem_addr, mem_len;
+	unsigned int io_addr, io_len;
+	int err;
+	u32 reg;
+
+#ifndef MODULE
+	static unsigned int cardidx;
+	if (!cardidx++)
+		printk(version);
+#endif
+
+	err =3D pci_enable_device(pdev);
+	if (err) {
+		printk(KERN_ERR "%s (adm8211): Cannot enable new PCI device\n",=20
pci_name(pdev));
+		return err;
+	}
+
+	io_addr =3D pci_resource_start(pdev, 0);
+	io_len =3D pci_resource_len(pdev, 0);
+	mem_addr =3D pci_resource_start(pdev, 1);
+	mem_len =3D pci_resource_len(pdev, 1);
+	if (io_len < 256 || mem_len < 1024) {
+		printk(KERN_ERR "%s (adm8211): Too short PCI resources\n", pci_name(pdev=
));
+		goto err_disable_pdev;
+	}
+
+
+	/* check signature */
+	pci_read_config_dword(pdev, 0x80 /* CR32 */, &reg);
+	if (reg !=3D ADM8211_SIG1 && reg !=3D ADM8211_SIG2) {
+		printk(KERN_ERR "%s (adm8211): Invalid signature (0x%x)\n", pci_name(pde=
v),=20
reg);
+		goto err_disable_pdev;
+	}
+
+	err =3D pci_request_regions(pdev, "adm8211");
+	if (err) {
+		printk(KERN_ERR "%s (adm8211): Cannot obtain PCI resources\n",=20
pci_name(pdev));
+		return err; /* someone else grabbed it? don't disable it */
+	}
+
+	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK) ||
+	    pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK)) {
+		printk(KERN_ERR "%s (adm8211): No suitable DMA available\n",=20
pci_name(pdev));
+		goto err_free_reg;
+	}
+
+	pci_set_master(pdev);
+
+	dev =3D ieee80211_alloc_hw(sizeof(*priv), NULL);
+	if (!dev) {
+		printk(KERN_ERR "%s (adm8211): ieee80211 alloc failed\n", pci_name(pdev)=
);
+		err =3D -ENOMEM;
+		goto err_free_reg;
+	}
+	priv =3D ieee80211_dev_hw_data(dev);
+	hw =3D &priv->hw;
+	priv->pdev =3D pdev;
+
+	spin_lock_init(&priv->lock);
+
+	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
+
+	pci_set_drvdata(pdev, dev);
+	priv->msg_enable =3D netif_msg_init(debug, NETIF_MSG_DRV | NETIF_MSG_PROB=
E);
+
+	priv->map =3D pci_iomap(pdev, 1, mem_len);
+	if (!priv->map)
+		priv->map =3D pci_iomap(pdev, 0, io_len);
+
+	if (!priv->map) {
+		printk(KERN_ERR "%s (adm8211): Cannot map device memory\n",=20
pci_name(pdev));
+		goto err_free_dev;
+	}
+
+	dev->mem_start =3D mem_addr;
+	dev->mem_end =3D mem_addr + mem_len;
+	dev->base_addr =3D io_addr;
+	dev->irq =3D pdev->irq;
+
+	priv->rx_ring_size =3D rx_ring_size;
+	priv->tx_ring_size =3D tx_ring_size;
+=09
+	if (adm8211_alloc_rings(dev)) {
+		printk(KERN_ERR "%s (adm8211): Cannot allocate TX/RX ring\n",=20
pci_name(pdev));
+		goto err_iounmap;
+	}
+
+	pci_read_config_byte(pdev, PCI_CLASS_REVISION, &priv->revid);
+
+	put_unaligned(ADM8211_CSR_READ(PAR0), (u32 *) dev->dev_addr);
+	put_unaligned(ADM8211_CSR_READ(PAR1) & (__force u32) __constant_cpu_to_le=
32
(0xffff),
+		      (u16 *) &dev->dev_addr[4]);
+
+	if (!is_valid_ether_addr(dev->dev_addr)) {
+		printk(KERN_WARNING "%s (adm8211): Invalid hwaddr! Using randomly genera=
ted=20
hwaddr\n", pci_name(pdev));
+		random_ether_addr(dev->dev_addr);
+	}
+
+	hw->version =3D 2;
+	hw->name =3D "adm8211";
+	hw->host_gen_beacon =3D 0;
+	hw->device_hides_wep =3D 0;
+	hw->rx_includes_fcs =3D 0;	// however, FCS is kept in promisc mode
+	hw->host_broadcast_ps_buffering =3D 0;
+	hw->wep_include_iv =3D 1;
+	hw->data_nullfunc_ack =3D 0;
+	hw->no_tkip_wmm_hwaccel =3D 1;
+	hw->extra_hdr_room =3D 0;
+	hw->device_strips_mic =3D 0;
+	hw->monitor_during_oper =3D 0;
+	hw->fraglist =3D 0;
+	hw->channel_change_time =3D 1000;
+
+	hw->num_modes =3D 1;
+	hw->modes =3D priv->modes;
+	priv->modes[0].mode =3D MODE_IEEE80211B;
+	/* channel info filled in by adm8211_read_eeprom */
+	memcpy(priv->rates, adm8211_rates, sizeof(adm8211_rates));
+	priv->modes[0].num_rates =3D ARRAY_SIZE(adm8211_rates);
+	priv->modes[0].rates =3D priv->rates;
+
+	hw->tx =3D adm8211_tx;
+	hw->reset =3D adm8211_reset;
+	hw->open =3D adm8211_open;
+	hw->stop =3D adm8211_stop;
+	hw->add_interface =3D adm8211_add_interface;
+	hw->remove_interface =3D adm8211_remove_interface;
+
+	hw->config =3D adm8211_config;
+	hw->config_interface =3D adm8211_config_interface;
+	hw->set_multicast_list =3D adm8211_set_rx_mode;
+	hw->passive_scan =3D adm8211_scan;
+	hw->get_stats =3D adm8211_get_stats;
+	hw->get_tsf =3D adm8211_get_tsft;
+	hw->get_tx_stats =3D adm8211_get_tx_stats;
+	hw->queues =3D 1;		// ADM8211C supports more, maybe ADM8211B
+
+	priv->retry_limit =3D 3;
+	priv->ant_power =3D 0x40;
+	priv->tx_power =3D 0x40;
+	priv->lpf_cutoff =3D 0xFF;
+	priv->lnags_threshold =3D 0xFF;
+
+	/* Power-on issue. EEPROM won't read correctly without */
+	if (priv->revid >=3D ADM8211_REV_BA) {
+		ADM8211_CSR_WRITE(FRCTL, 0);
+		ADM8211_CSR_READ(FRCTL);
+		ADM8211_CSR_WRITE(FRCTL, 1);
+		ADM8211_CSR_READ(FRCTL);
+		mdelay(100);
+	}
+
+	err =3D adm8211_read_eeprom(dev);
+	if (err) {
+		printk(KERN_ERR "%s (adm8211): Cannot allocate eeprom buffer\n",=20
pci_name(pdev));
+		goto err_free_desc;
+	}
+
+	priv->channel =3D priv->modes[0].channels[0].chan;
+
+	err =3D ieee80211_register_hw(dev, &priv->hw);
+	if (err) {
+		printk(KERN_ERR "%s (adm8211): Cannot register netdevice\n",=20
pci_name(pdev));
+		goto err_free_desc;
+	}
+
+	printk("%s: hwaddr " MAC_FMT ", Rev 0x%02x\n",
+	       dev->name, MAC_ARG(dev->dev_addr), priv->revid);
+
+	return 0;
+
+ err_free_desc:
+	pci_free_consistent(pdev,
+			    sizeof(struct adm8211_desc) * priv->rx_ring_size +
+			    sizeof(struct adm8211_desc) * priv->tx_ring_size,
+			    priv->rx_ring, priv->rx_ring_dma);
+	kfree(priv->rx_buffers);
+
+ err_iounmap:
+	pci_iounmap(pdev, priv->map);
+
+ err_free_dev:
+	pci_set_drvdata(pdev, NULL);
+	ieee80211_free_hw(dev);
+
+ err_free_reg:
+	pci_release_regions(pdev);
+
+ err_disable_pdev:
+	pci_disable_device(pdev);
+	return err;
+}
+
+
+static void __devexit adm8211_remove(struct pci_dev *pdev)
+{
+	struct net_device *dev =3D pci_get_drvdata(pdev);
+	struct adm8211_priv *priv;
+
+	if (!dev)
+		return;
+
+	ieee80211_unregister_hw(dev);
+
+	priv =3D ieee80211_dev_hw_data(dev);
+
+	pci_free_consistent(pdev,
+			    sizeof(struct adm8211_desc) * priv->rx_ring_size +
+			    sizeof(struct adm8211_desc) * priv->tx_ring_size,
+			    priv->rx_ring, priv->rx_ring_dma);
+
+	kfree(priv->rx_buffers);
+	kfree(priv->eeprom);
+	pci_iounmap(pdev, priv->map);
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+	ieee80211_free_hw(dev);
+}
+
+
+#ifdef CONFIG_PM
+static int adm8211_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct net_device *dev =3D pci_get_drvdata(pdev);
+	netif_device_detach(dev);
+
+	if (dev->flags & IFF_UP)
+		dev->stop(dev);
+
+	pci_save_state(pdev);
+	pci_set_power_state(pdev, PCI_D3hot);
+	return 0;
+}
+
+static int adm8211_resume(struct pci_dev *pdev)
+{
+	struct net_device *dev =3D pci_get_drvdata(pdev);
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+
+	if (dev->flags & IFF_UP)
+		dev->open(dev);
+
+	netif_device_attach(dev);
+	return 0;
+}
+#endif /* CONFIG_PM */
+
+
+MODULE_DEVICE_TABLE(pci, adm8211_pci_id_table);
+
+/* TODO: enable_wake */
+static struct pci_driver adm8211_driver =3D {
+	.name		=3D "adm8211",
+	.id_table	=3D adm8211_pci_id_table,
+	.probe		=3D adm8211_probe,
+	.remove		=3D __devexit_p(adm8211_remove),
+#ifdef CONFIG_PM
+	.suspend	=3D adm8211_suspend,
+	.resume		=3D adm8211_resume,
+#endif /* CONFIG_PM */
+};
+
+
+
+static int __init adm8211_init(void)
+{
+#ifdef MODULE
+	printk(version);
+#endif
+
+	return pci_register_driver(&adm8211_driver);
+}
+
+
+static void __exit adm8211_exit(void)
+{
+	pci_unregister_driver(&adm8211_driver);
+}
+
+
+module_init(adm8211_init);
+module_exit(adm8211_exit);
diff --git a/drivers/net/wireless/d80211/adm8211/adm8211.h=20
b/drivers/net/wireless/d80211/adm8211/adm8211.h
new file mode 100644
index 0000000..c215013
=2D-- /dev/null
+++ b/drivers/net/wireless/d80211/adm8211/adm8211.h
@@ -0,0 +1,631 @@
+#ifndef ADM8211_H
+#define ADM8211_H
+
+/* ADM8211 Registers */
+
+/* CR32 (SIG) signature */
+#define ADM8211_SIG1		0x82011317 /* ADM8211A */
+#define ADM8211_SIG2		0x82111317 /* ADM8211B/ADM8211C */
+
+#define ADM8211_CSR_READ(r) ioread32(&priv->map->r)
+#define ADM8211_CSR_WRITE(r, val) iowrite32((__force u32)(val),=20
&priv->map->r)
+
+/* CSR (Host Control and Status Registers) */
+struct adm8211_csr {
+	__le32 PAR;		/* 0x00 CSR0 */
+	__le32 FRCTL;		/* 0x04 CSR0A */
+	__le32 TDR;		/* 0x08 CSR1 */
+	__le32 WTDP;		/* 0x0C CSR1A */
+	__le32 RDR;		/* 0x10 CSR2 */
+	__le32 WRDP;		/* 0x14 CSR2A */
+	__le32 RDB;		/* 0x18 CSR3 */
+	__le32 TDBH;		/* 0x1C CSR3A */
+	__le32 TDBD;		/* 0x20 CSR4 */
+	__le32 TDBP;		/* 0x24 CSR4A */
+	__le32 STSR;		/* 0x28 CSR5 */
+	__le32 TDBB;		/* 0x2C CSR5A */
+	__le32 NAR;		/* 0x30 CSR6 */
+	__le32 CSR6A;		/* reserved */
+	__le32 IER;		/* 0x38 CSR7 */
+	__le32 TKIPSCEP;	/* 0x3C CSR7A */=09
+	__le32 LPC;		/* 0x40 CSR8 */
+	__le32 CSR_TEST1;	/* 0x44 CSR8A */
+	__le32 SPR;		/* 0x48 CSR9 */
+	__le32 CSR_TEST0;	/* 0x4C CSR9A */
+	__le32 WCSR;		/* 0x50 CSR10 */
+	__le32 WPDR;		/* 0x54 CSR10A */
+	__le32 GPTMR;		/* 0x58 CSR11 */
+	__le32 GPIO;		/* 0x5C CSR11A */
+	__le32 BBPCTL;		/* 0x60 CSR12 */
+	__le32 SYNCTL;		/* 0x64 CSR12A */
+	__le32 PLCPHD;		/* 0x68 CSR13 */
+	__le32 MMIWA;		/* 0x6C CSR13A */
+	__le32 MMIRD0;		/* 0x70 CSR14 */
+	__le32 MMIRD1;		/* 0x74 CSR14A */
+	__le32 TXBR;		/* 0x78 CSR15 */
+	__le32 SYNDATA;		/* 0x7C CSR15A */
+	__le32 ALCS;		/* 0x80 CSR16 */
+	__le32 TOFS2;		/* 0x84 CSR17 */
+	__le32 CMDR;		/* 0x88 CSR18 */
+	__le32 PCIC;		/* 0x8C CSR19 */
+	__le32 PMCSR;		/* 0x90 CSR20 */
+	__le32 PAR0;		/* 0x94 CSR21 */
+	__le32 PAR1;		/* 0x98 CSR22 */
+	__le32 MAR0;		/* 0x9C CSR23 */
+	__le32 MAR1;		/* 0xA0 CSR24 */
+	__le32 ATIMDA0;		/* 0xA4 CSR25 */
+	__le32 ABDA1;		/* 0xA8 CSR26 */
+	__le32 BSSID0;		/* 0xAC CSR27 */
+	__le32 TXLMT;		/* 0xB0 CSR28 */
+	__le32 MIBCNT;		/* 0xB4 CSR29 */
+	__le32 BCNT;		/* 0xB8 CSR30 */
+	__le32 TSFTH;		/* 0xBC CSR31 */
+	__le32 TSC;		/* 0xC0 CSR32 */
+	__le32 SYNRF;		/* 0xC4 CSR33 */
+	__le32 BPLI;		/* 0xC8 CSR34 */
+	__le32 CAP0;		/* 0xCC CSR35 */
+	__le32 CAP1;		/* 0xD0 CSR36 */
+	__le32 RMD;		/* 0xD4 CSR37 */
+	__le32 CFPP;		/* 0xD8 CSR38 */
+	__le32 TOFS0;		/* 0xDC CSR39 */
+	__le32 TOFS1;		/* 0xE0 CSR40 */
+	__le32 IFST;		/* 0xE4 CSR41 */
+	__le32 RSPT;		/* 0xE8 CSR42 */
+	__le32 TSFTL;		/* 0xEC CSR43 */
+	__le32 WEPCTL;		/* 0xF0 CSR44 */
+	__le32 WESK;		/* 0xF4 CSR45 */
+	__le32 WEPCNT;		/* 0xF8 CSR46 */
+	__le32 MACTEST;		/* 0xFC CSR47 */
+	__le32 FER;		/* 0x100 */
+	__le32 FEMR;		/* 0x104 */
+	__le32 FPSR;		/* 0x108 */
+	__le32 FFER;		/* 0x10C */
+} __attribute__ ((packed));
+
+/* CSR0 - PAR (PCI Address Register) */
+#define ADM8211_PAR_MWIE	(1 << 24)
+#define ADM8211_PAR_MRLE	(1 << 23)
+#define ADM8211_PAR_MRME	(1 << 21)
+#define ADM8211_PAR_RAP		((1 << 18) | (1 << 17))
+#define ADM8211_PAR_CAL		((1 << 15) | (1 << 14))
+#define ADM8211_PAR_PBL		0x00003f00
+#define ADM8211_PAR_BLE		(1 << 7)
+#define ADM8211_PAR_DSL		0x0000007c
+#define ADM8211_PAR_BAR		(1 << 1)
+#define ADM8211_PAR_SWR		(1 << 0)
+
+/* CSR1 - FRCTL (Frame Control Register) */
+#define ADM8211_FRCTL_PWRMGT	(1 << 31)
+#define ADM8211_FRCTL_MAXPSP	(1 << 27)
+#define ADM8211_FRCTL_DRVPRSP	(1 << 26)
+#define ADM8211_FRCTL_DRVBCON	(1 << 25)
+#define ADM8211_FRCTL_AID	0x0000ffff
+#define ADM8211_FRCTL_AID_ON	0x0000c000
+
+/* CSR5 - STSR (Status Register) */
+#define ADM8211_STSR_PCF	(1 << 31)
+#define ADM8211_STSR_BCNTC	(1 << 30)
+#define ADM8211_STSR_GPINT	(1 << 29)
+#define ADM8211_STSR_LinkOff	(1 << 28)
+#define ADM8211_STSR_ATIMTC	(1 << 27)
+#define ADM8211_STSR_TSFTF	(1 << 26)
+#define ADM8211_STSR_TSCZ	(1 << 25)
+#define ADM8211_STSR_LinkOn	(1 << 24)
+#define ADM8211_STSR_SQL	(1 << 23)
+#define ADM8211_STSR_WEPTD	(1 << 22)
+#define ADM8211_STSR_ATIME	(1 << 21)
+#define ADM8211_STSR_TBTT	(1 << 20)
+#define ADM8211_STSR_NISS	(1 << 16)
+#define ADM8211_STSR_AISS	(1 << 15)
+#define ADM8211_STSR_TEIS	(1 << 14)
+#define ADM8211_STSR_FBE	(1 << 13)
+#define ADM8211_STSR_REIS	(1 << 12)
+#define ADM8211_STSR_GPTT	(1 << 11)
+#define ADM8211_STSR_RPS	(1 << 8)
+#define ADM8211_STSR_RDU	(1 << 7)
+#define ADM8211_STSR_RCI	(1 << 6)
+#define ADM8211_STSR_TUF	(1 << 5)
+#define ADM8211_STSR_TRT	(1 << 4)
+#define ADM8211_STSR_TLT	(1 << 3)
+#define ADM8211_STSR_TDU	(1 << 2)
+#define ADM8211_STSR_TPS	(1 << 1)
+#define ADM8211_STSR_TCI	(1 << 0)
+
+/* CSR6 - NAR (Network Access Register) */
+#define ADM8211_NAR_TXCF	(1 << 31)
+#define ADM8211_NAR_HF		(1 << 30)
+#define ADM8211_NAR_UTR		(1 << 29)
+#define ADM8211_NAR_SQ		(1 << 28)
+#define ADM8211_NAR_CFP		(1 << 27)
+#define ADM8211_NAR_SF		(1 << 21)
+#define ADM8211_NAR_TR		((1 << 15) | (1 << 14))
+#define ADM8211_NAR_ST		(1 << 13)
+#define ADM8211_NAR_OM		((1 << 11) | (1 << 10))
+#define ADM8211_NAR_MM		(1 << 7)
+#define ADM8211_NAR_PR		(1 << 6)
+#define ADM8211_NAR_EA		(1 << 5)
+#define ADM8211_NAR_PB		(1 << 3)
+#define ADM8211_NAR_STPDMA	(1 << 2)
+#define ADM8211_NAR_SR		(1 << 1)
+#define ADM8211_NAR_CTX		(1 << 0)
+
+#define ADM8211_IDLE()		do { \
+	if (priv->nar & (ADM8211_NAR_SR | ADM8211_NAR_ST)) {\
+		ADM8211_CSR_WRITE(NAR, cpu_to_le32(priv->nar & ~(ADM8211_NAR_SR |=20
ADM8211_NAR_ST)));\
+		ADM8211_CSR_READ(NAR);\
+		mdelay(20);\
+	}\
+} while (0)
+
+#define ADM8211_IDLE_RX()	do { \
+	if (priv->nar & ADM8211_NAR_SR) {\
+		ADM8211_CSR_WRITE(NAR, cpu_to_le32(priv->nar & ~ADM8211_NAR_SR));\
+		ADM8211_CSR_READ(NAR);\
+		mdelay(20);\
+	}\
+} while (0)
+
+#define ADM8211_IDLE_TX()	do { \
+	if (priv->nar & ADM8211_NAR_ST) {\
+		ADM8211_CSR_WRITE(NAR, cpu_to_le32(priv->nar & ~ADM8211_NAR_ST));\
+		ADM8211_CSR_READ(NAR);\
+		mdelay(20);\
+	}\
+} while (0)
+
+#define ADM8211_RESTORE()	do { \
+	if (priv->nar & (ADM8211_NAR_SR | ADM8211_NAR_ST)) \
+		ADM8211_CSR_WRITE(NAR, cpu_to_le32(priv->nar));\
+} while (0)
+
+/* CSR7 - IER (Interrupt Enable Register) */
+#define ADM8211_IER_PCFIE	(1 << 31)
+#define ADM8211_IER_BCNTCIE	(1 << 30)
+#define ADM8211_IER_GPIE	(1 << 29)
+#define ADM8211_IER_LinkOffIE	(1 << 28)
+#define ADM8211_IER_ATIMTCIE	(1 << 27)
+#define ADM8211_IER_TSFTFIE	(1 << 26)
+#define ADM8211_IER_TSCZE	(1 << 25)
+#define ADM8211_IER_LinkOnIE	(1 << 24)
+#define ADM8211_IER_SQLIE	(1 << 23)
+#define ADM8211_IER_WEPIE	(1 << 22)
+#define ADM8211_IER_ATIMEIE	(1 << 21)
+#define ADM8211_IER_TBTTIE	(1 << 20)
+#define ADM8211_IER_NIE		(1 << 16)
+#define ADM8211_IER_AIE		(1 << 15)
+#define ADM8211_IER_TEIE	(1 << 14)
+#define ADM8211_IER_FBEIE	(1 << 13)
+#define ADM8211_IER_REIE	(1 << 12)
+#define ADM8211_IER_GPTIE	(1 << 11)
+#define ADM8211_IER_RSIE	(1 << 8)
+#define ADM8211_IER_RUIE	(1 << 7)
+#define ADM8211_IER_RCIE	(1 << 6)
+#define ADM8211_IER_TUIE	(1 << 5)
+#define ADM8211_IER_TRTIE	(1 << 4)
+#define ADM8211_IER_TLTTIE	(1 << 3)
+#define ADM8211_IER_TDUIE	(1 << 2)
+#define ADM8211_IER_TPSIE	(1 << 1)
+#define ADM8211_IER_TCIE	(1 << 0)
+
+/* CSR9 - SPR (Serial Port Register) */
+#define ADM8211_SPR_SRS		(1 << 11)
+#define ADM8211_SPR_SDO		(1 << 3)
+#define ADM8211_SPR_SDI		(1 << 2)
+#define ADM8211_SPR_SCLK	(1 << 1)
+#define ADM8211_SPR_SCS		(1 << 0)
+
+/* CSR9A - CSR_TEST0 */
+#define ADM8211_CSR_TEST0_EPNE	(1 << 18)
+#define ADM8211_CSR_TEST0_EPSNM	(1 << 17)
+#define ADM8211_CSR_TEST0_EPTYP	(1 << 16)
+#define ADM8211_CSR_TEST0_EPRLD	(1 << 15)
+
+/* CSR10 - WCSR (Wake-up Control/Status Register) */
+#define ADM8211_WCSR_CRCT	(1 << 30)
+#define ADM8211_WCSR_TSFTWE	(1 << 20)
+#define ADM8211_WCSR_TIMWE	(1 << 19)
+#define ADM8211_WCSR_ATIMWE	(1 << 18)
+#define ADM8211_WCSR_KEYWE	(1 << 17)
+#define ADM8211_WCSR_MPRE	(1 << 9)
+#define ADM8211_WCSR_LSOE	(1 << 8)
+#define ADM8211_WCSR_KEYUP	(1 << 6)
+#define ADM8211_WCSR_TSFTW	(1 << 5)
+#define ADM8211_WCSR_TIMW	(1 << 4)
+#define ADM8211_WCSR_ATIMW	(1 << 3)
+#define ADM8211_WCSR_MPR	(1 << 1)
+#define ADM8211_WCSR_LSO	(1 << 0)
+
+/* CSR11A - GPIO */
+#define ADM8211_CSR_GPIO_EN5	(1 << 17)
+#define ADM8211_CSR_GPIO_EN4	(1 << 16)
+#define ADM8211_CSR_GPIO_EN3	(1 << 15)
+#define ADM8211_CSR_GPIO_EN2	(1 << 14)
+#define ADM8211_CSR_GPIO_EN1	(1 << 13)
+#define ADM8211_CSR_GPIO_EN0	(1 << 12)
+#define ADM8211_CSR_GPIO_O5	(1 << 11)
+#define ADM8211_CSR_GPIO_O4	(1 << 10)
+#define ADM8211_CSR_GPIO_O3	(1 << 9)
+#define ADM8211_CSR_GPIO_O2	(1 << 8)
+#define ADM8211_CSR_GPIO_O1	(1 << 7)
+#define ADM8211_CSR_GPIO_O0	(1 << 6)
+#define ADM8211_CSR_GPIO_IN	0x0000003f
+
+/* CSR12 - BBPCTL (BBP Control port) */
+#define ADM8211_BBPCTL_MMISEL	(1 << 31)
+#define ADM8211_BBPCTL_SPICADD  (0x7F << 24)
+#define ADM8211_BBPCTL_RF3000	(0x20 << 24)
+#define ADM8211_BBPCTL_TXCE	(1 << 23)
+#define ADM8211_BBPCTL_RXCE	(1 << 22)
+#define ADM8211_BBPCTL_CCAP	(1 << 21)
+#define ADM8211_BBPCTL_TYPE	0x001c0000
+#define ADM8211_BBPCTL_WR	(1 << 17)
+#define ADM8211_BBPCTL_RD	(1 << 16)
+#define ADM8211_BBPCTL_ADDR	0x0000ff00
+#define ADM8211_BBPCTL_DATA	0x000000ff
+
+/* CSR12A - SYNCTL (Synthesizer Control port) */
+#define ADM8211_SYNCTL_WR	(1 << 31)
+#define ADM8211_SYNCTL_RD	(1 << 30)
+#define ADM8211_SYNCTL_CS0	(1 << 29)
+#define ADM8211_SYNCTL_CS1	(1 << 28)
+#define ADM8211_SYNCTL_CAL	(1 << 27)
+#define ADM8211_SYNCTL_SELCAL	(1 << 26)
+#define ADM8211_SYNCTL_RFtype	((1 << 24) || (1 << 23) || (1 << 22))
+#define ADM8211_SYNCTL_RFMD	(1 << 22)
+#define ADM8211_SYNCTL_GENERAL	(0x7 << 22)
+/* SYNCTL 21:0 Data (Si4126: 18-bit data, 4-bit address) */
+
+/* CSR18 - CMDR (Command Register) */
+#define ADM8211_CMDR_PM		(1 << 19)
+#define ADM8211_CMDR_APM	(1 << 18)
+#define ADM8211_CMDR_RTE	(1 << 4)
+#define ADM8211_CMDR_DRT	((1 << 3) | (1 << 2))
+#define ADM8211_CMDR_DRT_8DW	(0x0 << 2)
+#define ADM8211_CMDR_DRT_16DW	(0x1 << 2)
+#define ADM8211_CMDR_DRT_SF	(0x2 << 2)
+
+/* CSR33 - SYNRF (SYNRF direct control) */
+#define ADM8211_SYNRF_SELSYN	(1 << 31)
+#define ADM8211_SYNRF_SELRF	(1 << 30)
+#define ADM8211_SYNRF_LERF	(1 << 29)
+#define ADM8211_SYNRF_LEIF	(1 << 28)
+#define ADM8211_SYNRF_SYNCLK	(1 << 27)
+#define ADM8211_SYNRF_SYNDATA	(1 << 26)
+#define ADM8211_SYNRF_PE1	(1 << 25)
+#define ADM8211_SYNRF_PE2	(1 << 24)
+#define ADM8211_SYNRF_PA_PE	(1 << 23)
+#define ADM8211_SYNRF_TR_SW	(1 << 22)
+#define ADM8211_SYNRF_TR_SWN	(1 << 21)
+#define ADM8211_SYNRF_RADIO	(1 << 20)
+#define ADM8211_SYNRF_CAL_EN	(1 << 19)
+#define ADM8211_SYNRF_PHYRST	(1 << 18)
+
+#define ADM8211_SYNRF_IF_SELECT_0 	(1 << 31)
+#define ADM8211_SYNRF_IF_SELECT_1 	((1 << 31) | (1 << 28))
+#define ADM8211_SYNRF_WRITE_SYNDATA_0	(1 << 31)
+#define ADM8211_SYNRF_WRITE_SYNDATA_1	((1 << 31) | (1 << 26))
+#define ADM8211_SYNRF_WRITE_CLOCK_0	(1 << 31)
+#define ADM8211_SYNRF_WRITE_CLOCK_1	((1 << 31) | (1 << 27))
+
+/* CSR44 - WEPCTL (WEP Control) */
+#define ADM8211_WEPCTL_WEPENABLE   (1 << 31)
+#define ADM8211_WEPCTL_WPAENABLE   (1 << 30)
+#define ADM8211_WEPCTL_CURRENT_TABLE (1 << 29)
+#define ADM8211_WEPCTL_TABLE_WR	(1 << 28)
+#define ADM8211_WEPCTL_TABLE_RD	(1 << 27)
+#define ADM8211_WEPCTL_WEPRXBYP	(1 << 25)
+#define ADM8211_WEPCTL_SEL_WEPTABLE (1 << 23)
+#define ADM8211_WEPCTL_ADDR	(0x000001ff)
+
+/* CSR45 - WESK (Data Entry for Share/Individual Key) */
+#define ADM8211_WESK_DATA	(0x0000ffff)
+
+/* FER (Function Event Register) */
+#define ADM8211_FER_INTR_EV_ENT	(1 << 15)
+
+
+/* Si4126 RF Synthesizer - Control Registers */
+#define SI4126_MAIN_CONF	0
+#define SI4126_PHASE_DET_GAIN	1
+#define SI4126_POWERDOWN	2
+#define SI4126_RF1_N_DIV	3 /* only Si4136 */
+#define SI4126_RF2_N_DIV	4
+#define SI4126_IF_N_DIV		5
+#define SI4126_RF1_R_DIV	6 /* only Si4136 */
+#define SI4126_RF2_R_DIV	7
+#define SI4126_IF_R_DIV		8
+
+/* Main Configuration */
+#define SI4126_MAIN_XINDIV2	(1 << 6)
+#define SI4126_MAIN_IFDIV	((1 << 11) | (1 << 10))
+/* Powerdown */
+#define SI4126_POWERDOWN_PDIB	(1 << 1)
+#define SI4126_POWERDOWN_PDRB	(1 << 0)
+
+
+/* RF3000 BBP - Control Port Registers */
+/* 0x00 - reserved */
+#define RF3000_MODEM_CTRL__RX_STATUS 0x01
+#define RF3000_CCA_CTRL 0x02
+#define RF3000_DIVERSITY__RSSI 0x03
+#define RF3000_RX_SIGNAL_FIELD 0x04
+#define RF3000_RX_LEN_MSB 0x05
+#define RF3000_RX_LEN_LSB 0x06
+#define RF3000_RX_SERVICE_FIELD 0x07
+#define RF3000_TX_VAR_GAIN__TX_LEN_EXT 0x11
+#define RF3000_TX_LEN_MSB 0x12
+#define RF3000_TX_LEN_LSB 0x13
+#define RF3000_LOW_GAIN_CALIB 0x14
+#define RF3000_HIGH_GAIN_CALIB 0x15
+
+/* ADM8211 revisions */
+#define ADM8211_REV_AB 0x11
+#define ADM8211_REV_AF 0x15
+#define ADM8211_REV_BA 0x20
+#define ADM8211_REV_CA 0x30
+
+struct adm8211_desc {
+	__le32 status;
+	__le32 length;
+	__le32 buffer1;
+	__le32 buffer2;
+};
+
+#define RDES0_STATUS_OWN	(1 << 31)
+#define RDES0_STATUS_ES		(1 << 30)
+#define RDES0_STATUS_SQL	(1 << 29)
+#define RDES0_STATUS_DE		(1 << 28)
+#define RDES0_STATUS_FS		(1 << 27)
+#define RDES0_STATUS_LS		(1 << 26)
+#define RDES0_STATUS_PCF	(1 << 25)
+#define RDES0_STATUS_SFDE	(1 << 24)
+#define RDES0_STATUS_SIGE	(1 << 23)
+#define RDES0_STATUS_CRC16E	(1 << 22)
+#define RDES0_STATUS_RXTOE	(1 << 21)
+#define RDES0_STATUS_CRC32E	(1 << 20)
+#define RDES0_STATUS_ICVE	(1 << 19)
+#define RDES0_STATUS_DA1	(1 << 17)
+#define RDES0_STATUS_DA0	(1 << 16)
+#define RDES0_STATUS_RXDR	((1 << 15) | (1 << 14) | (1 << 13) | (1 << 12))
+#define RDES0_STATUS_FL		(0x00000fff)
+
+#define RDES1_CONTROL_RER	(1 << 25)
+#define RDES1_CONTROL_RCH	(1 << 24)
+#define RDES1_CONTROL_RBS2	(0x00fff000)
+#define RDES1_CONTROL_RBS1	(0x00000fff)
+
+#define RDES1_STATUS_RSSI	(0x0000007f)
+
+
+#define TDES0_CONTROL_OWN	(1 << 31)
+#define TDES0_CONTROL_DONE	(1 << 30)
+#define TDES0_CONTROL_TXDR	(0x0ff00000)
+
+#define TDES0_STATUS_OWN	(1 << 31)
+#define TDES0_STATUS_DONE	(1 << 30)
+#define TDES0_STATUS_ES		(1 << 29)
+#define TDES0_STATUS_TLT	(1 << 28)
+#define TDES0_STATUS_TRT	(1 << 27)
+#define TDES0_STATUS_TUF	(1 << 26)
+#define TDES0_STATUS_TRO	(1 << 25)
+#define TDES0_STATUS_SOFBR	(1 << 24)
+#define TDES0_STATUS_ACR	(0x00000fff)
+
+#define TDES1_CONTROL_IC	(1 << 31)
+#define TDES1_CONTROL_LS	(1 << 30)
+#define TDES1_CONTROL_FS	(1 << 29)
+#define TDES1_CONTROL_TER	(1 << 25)
+#define TDES1_CONTROL_TCH	(1 << 24)
+#define TDES1_CONTROL_RBS2	(0x00fff000)
+#define TDES1_CONTROL_RBS1	(0x00000fff)
+
+/* SRAM offsets */
+#define ADM8211_SRAM(x) (priv->revid < ADM8211_REV_BA ? \
+        ADM8211_SRAM_A_ ## x : ADM8211_SRAM_B_ ## x)
+
+#define ADM8211_SRAM_INDIV_KEY   0x0000
+#define ADM8211_SRAM_A_SHARE_KEY 0x0160
+#define ADM8211_SRAM_B_SHARE_KEY 0x00c0
+
+#define ADM8211_SRAM_A_SSID      0x0180
+#define ADM8211_SRAM_B_SSID      0x00d4
+#define ADM8211_SRAM_SSID ADM8211_SRAM(SSID)
+
+#define ADM8211_SRAM_A_SUPP_RATE 0x0191
+#define ADM8211_SRAM_B_SUPP_RATE 0x00dd
+#define ADM8211_SRAM_SUPP_RATE ADM8211_SRAM(SUPP_RATE)
+
+#define ADM8211_SRAM_A_SIZE      0x0200
+#define ADM8211_SRAM_B_SIZE      0x01c0
+#define ADM8211_SRAM_SIZE ADM8211_SRAM(SIZE)
+
+struct adm8211_ring_info {
+	struct sk_buff *skb;
+	dma_addr_t mapping;
+	struct ieee80211_tx_status tx_status;
+	int unicast;
+};
+
+struct adm8211_eeprom {
+	__le16	signature;		/* 0x00 */
+	u8	major_version;		/* 0x02 */
+	u8	minor_version;		/* 0x03 */
+	u8	reserved_1[4];		/* 0x04 */
+	u8	hwaddr[6];		/* 0x08 */
+	u8	reserved_2[8];		/* 0x1E */
+	__le16	cr49;			/* 0x16 */
+	u8	cr03;			/* 0x18 */
+	u8	cr28;			/* 0x19 */
+	u8	cr29;			/* 0x1A */
+	u8	country_code;		/* 0x1B */
+
+/* specific bbp types */
+#define ADM8211_BBP_RFMD3000	0x00
+#define ADM8211_BBP_RFMD3002	0x01
+#define ADM8211_BBP_ADM8011	0x04
+	u8	specific_bbptype;	/* 0x1C */
+	u8	specific_rftype;	/* 0x1D */
+	u8	reserved_3[2];		/* 0x1E */
+	__le16	device_id;		/* 0x20 */
+	__le16	vendor_id;		/* 0x22 */
+	__le16	subsystem_id;		/* 0x24 */
+	__le16	subsystem_vendor_id;	/* 0x26 */
+	u8	maxlat;			/* 0x28 */
+	u8	mingnt;			/* 0x29 */
+	__le16	cis_pointer_low;	/* 0x2A */
+	__le16	cis_pointer_high;	/* 0x2C */
+	__le16	csr18;			/* 0x2E */
+	u8	reserved_4[16];		/* 0x30 */
+	u8	d1_pwrdara;		/* 0x40 */
+	u8	d0_pwrdara;		/* 0x41 */
+	u8	d3_pwrdara;		/* 0x42 */
+	u8	d2_pwrdara;		/* 0x43 */
+	u8	antenna_power[14];	/* 0x44 */
+	__le16	cis_wordcnt;		/* 0x52 */
+	u8	tx_power[14];		/* 0x54 */
+	u8	lpf_cutoff[14];		/* 0x62 */
+	u8	lnags_threshold[14];	/* 0x70 */
+	__le16	checksum;		/* 0x7E */
+	u8	cis_data[0];		/* 0x80, 384 bytes */
+} __attribute__ ((packed));
+
+static const struct ieee80211_rate adm8211_rates[] =3D {
+	{ .rate =3D 10,
+	  .val =3D 10,
+	  .val2 =3D -10,
+	  .flags =3D IEEE80211_RATE_PREAMBLE2 | IEEE80211_RATE_CCK },
+	{ .rate =3D 20,
+	  .val =3D 20,
+	  .val2 =3D -20,
+	  .flags =3D IEEE80211_RATE_PREAMBLE2 | IEEE80211_RATE_CCK_2 },
+	{ .rate =3D 55,
+	  .val =3D 55,
+	  .val2 =3D -55,
+	  .flags =3D IEEE80211_RATE_PREAMBLE2 | IEEE80211_RATE_CCK_2 },
+	{ .rate =3D 110,
+	  .val =3D 110,
+	  .val2 =3D -110,
+	  .flags =3D IEEE80211_RATE_PREAMBLE2 | IEEE80211_RATE_CCK_2 }
+};
+
+struct ieee80211_chan_range {
+	u8 min;
+	u8 max;
+};
+
+struct adm8211_priv {
+	struct pci_dev *pdev;
+	spinlock_t lock;
+	struct adm8211_csr __iomem *map;
+	struct adm8211_desc *rx_ring;
+	struct adm8211_desc *tx_ring;
+	dma_addr_t rx_ring_dma;
+	dma_addr_t tx_ring_dma;
+	struct adm8211_ring_info *rx_buffers;
+	struct adm8211_ring_info *tx_buffers;
+	unsigned rx_ring_size, tx_ring_size;
+	unsigned cur_tx, dirty_tx, cur_rx;
+
+	struct ieee80211_hw hw;
+	struct ieee80211_low_level_stats stats;
+	struct ieee80211_hw_modes modes[1];
+	struct ieee80211_rate rates[ARRAY_SIZE(adm8211_rates)];
+	int mode;
+
+	int channel;
+	u8 bssid[ETH_ALEN];
+	u8 ssid[32];
+	size_t ssid_len;
+
+	u32 msg_enable;
+
+	int (*eth_header_parse)(struct sk_buff *skb, unsigned char *haddr);
+
+	u8 soft_rx_crc;
+	u8 retry_limit;
+
+	u8 ant_power;
+	u8 tx_power;
+	u8 lpf_cutoff;
+	u8 lnags_threshold;
+	struct adm8211_eeprom *eeprom;
+	size_t eeprom_len;
+
+	u8 revid;
+
+	u32 nar;
+
+#define ADM8211_TYPE_INTERSIL	0x00
+#define ADM8211_TYPE_RFMD	0x01
+#define ADM8211_TYPE_MARVEL	0x02
+#define ADM8211_TYPE_AIROHA	0x03
+#define ADM8211_TYPE_ADMTEK     0x05
+	unsigned int rf_type:3;
+	unsigned int bbp_type:3;
+
+	u8 specific_bbptype;
+	enum {
+		ADM8211_RFMD2948 =3D 0x0,
+		ADM8211_RFMD2958 =3D 0x1,
+		ADM8211_RFMD2958_RF3000_CONTROL_POWER =3D 0x2,
+		ADM8211_MAX2820 =3D 0x8,
+		ADM8211_AL2210L =3D 0xC,	/* Airoha */
+	} transceiver_type;
+};
+
+static const struct ieee80211_chan_range cranges[] =3D {
+	{1,  11},	/* FCC */
+	{1,  11},	/* IC */
+	{1,  13},	/* ETSI */
+	{10, 11},	/* SPAIN */
+	{10, 13},	/* FRANCE */
+	{14, 14},	/* MMK */
+	{1,  14},	/* MMK2 */
+};
+
+static const struct ieee80211_channel adm8211_channels[] =3D {
+	{ .chan =3D 1,
+	  .freq =3D 2412,
+	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	{ .chan =3D 2,
+	  .freq =3D 2417,
+	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	{ .chan =3D 3,
+	  .freq =3D 2422,
+	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	{ .chan =3D 4,
+	  .freq =3D 2427,
+	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	{ .chan =3D 5,
+	  .freq =3D 2432,
+	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	{ .chan =3D 6,
+	  .freq =3D 2437,
+	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	{ .chan =3D 7,
+	  .freq =3D 2442,
+	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	{ .chan =3D 8,
+	  .freq =3D 2447,
+	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	{ .chan =3D 9,
+	  .freq =3D 2452,
+	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	{ .chan =3D 10,
+	  .freq =3D 2457,
+	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	{ .chan =3D 11,
+	  .freq =3D 2462,
+	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	{ .chan =3D 12,
+	  .freq =3D 2467,
+	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	{ .chan =3D 13,
+	  .freq =3D 2472,
+	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	{ .chan =3D 14,
+	  .freq =3D 2484,
+	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS}
+};
+
+#endif /* ADM8211_H */

--nextPart4721134.FydJFvklTN
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEnBwVT3Oqt9AH4aERAkJKAJsHHu8EIp2HGpkbrgpvbPaqpRWMWgCePSMG
QpK1/wJKe3Uw9+ZFawOwRNY=
=ZHBx
-----END PGP SIGNATURE-----

--nextPart4721134.FydJFvklTN--
