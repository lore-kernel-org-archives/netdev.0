From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'upstream-rtl8187' branch of wireless-2.6
Date: Tue, 8 May 2007 13:41:18 -0400
Message-ID: <20070508174118.GI6479@tuxdriver.com>
References: <20070508173907.GH6479@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070508173907.GH6479-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is unchanged from Michael's previous patches, except it moves all
the files up into drivers/net/wireless and removes the CONFIG_RTL818X
option.

John

---

The following changes since commit 5b94f675f57e4ff16c8fda09088d7480a84dcd91:
  Linus Torvalds (1):
        Merge master.kernel.org:/.../davem/sparc-2.6

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-rtl8187

Ivo van Doorn (1):
      Add 93cx6 eeprom library

Michael Wu (1):
      Add rtl8187 wireless driver

 MAINTAINERS                            |   10 +
 drivers/misc/Kconfig                   |    6 +
 drivers/misc/Makefile                  |    1 +
 drivers/misc/eeprom_93cx6.c            |  347 +++++++++++++++
 drivers/net/wireless/Kconfig           |   12 +
 drivers/net/wireless/Makefile          |    3 +
 drivers/net/wireless/rtl8187.h         |  125 ++++++
 drivers/net/wireless/rtl8187_dev.c     |  730 +++++++++++++++++++++++++++++++
 drivers/net/wireless/rtl8187_rtl8225.c |  744 ++++++++++++++++++++++++++++++++
 drivers/net/wireless/rtl8187_rtl8225.h |   30 ++
 drivers/net/wireless/rtl818x.h         |  212 +++++++++
 include/linux/eeprom_93cx6.h           |   77 ++++
 12 files changed, 2297 insertions(+), 0 deletions(-)
 create mode 100644 drivers/misc/eeprom_93cx6.c
 create mode 100644 drivers/net/wireless/rtl8187.h
 create mode 100644 drivers/net/wireless/rtl8187_dev.c
 create mode 100644 drivers/net/wireless/rtl8187_rtl8225.c
 create mode 100644 drivers/net/wireless/rtl8187_rtl8225.h
 create mode 100644 drivers/net/wireless/rtl818x.h
 create mode 100644 include/linux/eeprom_93cx6.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 6d665ac..9315699 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2973,6 +2973,16 @@ S:	Maintained
 RISCOM8 DRIVER
 S:	Orphan
 
+RTL818X WIRELESS DRIVER
+P:	Michael Wu
+M:	flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org
+P:	Andrea Merello
+M:	andreamrl-IWqWACnzNjyonA0d6jMUrA@public.gmane.org
+L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
+W:	http://linuxwireless.org/
+T:	git kernel.org:/pub/scm/linux/kernel/git/mwu/mac80211-drivers.git
+S:	Maintained
+
 S3 SAVAGE FRAMEBUFFER DRIVER
 P:	Antonino Daplas
 M:	adaplas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
index a3c525b..607a180 100644
--- a/drivers/misc/Kconfig
+++ b/drivers/misc/Kconfig
@@ -178,4 +178,10 @@ config THINKPAD_ACPI_BAY
 
 	  If you are not sure, say Y here.
 
+config EEPROM_93CX6
+	tristate "EEPROM 93CX6 support"
+	---help---
+	  This is a driver for the EEPROM chipsets 93c46 and 93c66.
+	  The driver supports both read as well as write commands.
+
 endmenu
diff --git a/drivers/misc/Makefile b/drivers/misc/Makefile
index e325164..42b34a9 100644
--- a/drivers/misc/Makefile
+++ b/drivers/misc/Makefile
@@ -13,3 +13,4 @@ obj-$(CONFIG_TIFM_7XX1)       	+= tifm_7xx1.o
 obj-$(CONFIG_SGI_IOC4)		+= ioc4.o
 obj-$(CONFIG_SONY_LAPTOP)	+= sony-laptop.o
 obj-$(CONFIG_THINKPAD_ACPI)	+= thinkpad_acpi.o
+obj-$(CONFIG_EEPROM_93CX6)	+= eeprom_93cx6.o
diff --git a/drivers/misc/eeprom_93cx6.c b/drivers/misc/eeprom_93cx6.c
new file mode 100644
index 0000000..a948ddc
--- /dev/null
+++ b/drivers/misc/eeprom_93cx6.c
@@ -0,0 +1,347 @@
+/*
+	Copyright (C) 2004 - 2006 rt2x00 SourceForge Project
+	<http://rt2x00.serialmonkey.com>
+
+	This program is free software; you can redistribute it and/or modify
+	it under the terms of the GNU General Public License as published by
+	the Free Software Foundation; either version 2 of the License, or
+	(at your option) any later version.
+
+	This program is distributed in the hope that it will be useful,
+	but WITHOUT ANY WARRANTY; without even the implied warranty of
+	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+	GNU General Public License for more details.
+
+	You should have received a copy of the GNU General Public License
+	along with this program; if not, write to the
+	Free Software Foundation, Inc.,
+	59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ */
+
+/*
+	Module: eeprom_93cx6
+	Abstract: EEPROM reader routines for 93cx6 chipsets.
+	Supported chipsets: 93c46 & 93c66.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/delay.h>
+#include <linux/eeprom_93cx6.h>
+
+MODULE_AUTHOR("http://rt2x00.serialmonkey.com");
+MODULE_VERSION("1.0");
+MODULE_DESCRIPTION("EEPROM 93cx6 chip driver");
+MODULE_LICENSE("GPL");
+
+static inline void eeprom_93cx6_pulse_high(struct eeprom_93cx6 *eeprom)
+{
+	eeprom->reg_data_clock = 1;
+	eeprom->register_write(eeprom);
+	udelay(1);
+}
+
+static inline void eeprom_93cx6_pulse_low(struct eeprom_93cx6 *eeprom)
+{
+	eeprom->reg_data_clock = 0;
+	eeprom->register_write(eeprom);
+	udelay(1);
+}
+
+static void eeprom_93cx6_startup(struct eeprom_93cx6 *eeprom)
+{
+	/*
+	 * Clear all flags, and enable chip select.
+	 */
+	eeprom->register_read(eeprom);
+	eeprom->reg_data_in = 0;
+	eeprom->reg_data_out = 0;
+	eeprom->reg_data_clock = 0;
+	eeprom->reg_chip_select = 1;
+	eeprom->register_write(eeprom);
+
+	/*
+	 * kick a pulse.
+	 */
+	eeprom_93cx6_pulse_high(eeprom);
+	eeprom_93cx6_pulse_low(eeprom);
+}
+
+static void eeprom_93cx6_cleanup(struct eeprom_93cx6 *eeprom)
+{
+	/*
+	 * Clear chip_select and data_in flags.
+	 */
+	eeprom->register_read(eeprom);
+	eeprom->reg_data_in = 0;
+	eeprom->reg_chip_select = 0;
+	eeprom->register_write(eeprom);
+
+	/*
+	 * kick a pulse.
+	 */
+	eeprom_93cx6_pulse_high(eeprom);
+	eeprom_93cx6_pulse_low(eeprom);
+}
+
+static void eeprom_93cx6_write_bits(struct eeprom_93cx6 *eeprom,
+	const u16 data, const u16 count)
+{
+	unsigned int i;
+
+	eeprom->register_read(eeprom);
+
+	/*
+	 * Clear data flags.
+	 */
+	eeprom->reg_data_in = 0;
+	eeprom->reg_data_out = 0;
+
+	/*
+	 * Start writing all bits.
+	 */
+	for (i = count; i > 0; i--) {
+		/*
+		 * Check if this bit needs to be set.
+		 */
+		eeprom->reg_data_in = !!(data & (1 << (i - 1)));
+
+		/*
+		 * Write the bit to the eeprom register.
+		 */
+		eeprom->register_write(eeprom);
+
+		/*
+		 * Kick a pulse.
+		 */
+		eeprom_93cx6_pulse_high(eeprom);
+		eeprom_93cx6_pulse_low(eeprom);
+	}
+
+	eeprom->reg_data_in = 0;
+	eeprom->register_write(eeprom);
+}
+
+static void eeprom_93cx6_read_bits(struct eeprom_93cx6 *eeprom,
+	u16 *data, const u16 count)
+{
+	unsigned int i;
+	u16 buf = 0;
+
+	eeprom->register_read(eeprom);
+
+	/*
+	 * Clear data flags.
+	 */
+	eeprom->reg_data_in = 0;
+	eeprom->reg_data_out = 0;
+
+	/*
+	 * Start reading all bits.
+	 */
+	for (i = count; i > 0; i--) {
+		eeprom_93cx6_pulse_high(eeprom);
+
+		eeprom->register_read(eeprom);
+
+		/*
+		 * Clear data_in flag.
+		 */
+		eeprom->reg_data_in = 0;
+
+		/*
+		 * Read if the bit has been set.
+		 */
+		if (eeprom->reg_data_out)
+			buf |= (1 << (i - 1));
+
+		eeprom_93cx6_pulse_low(eeprom);
+	}
+
+	*data = buf;
+}
+
+static void eeprom_93cx6_ewen(struct eeprom_93cx6 *eeprom)
+{
+	/*
+	 * Initialize the eeprom register
+	 */
+	eeprom_93cx6_startup(eeprom);
+
+	/*
+	 * Select the read opcode and the word to be read.
+	 */
+	eeprom_93cx6_write_bits(eeprom, PCI_EEPROM_EWEN_OPCODE, 5);
+	eeprom_93cx6_write_bits(eeprom, 0, 6);
+
+	/*
+	 * Cleanup eeprom register.
+	 */
+	eeprom_93cx6_cleanup(eeprom);
+}
+
+static void eeprom_93cx6_ewds(struct eeprom_93cx6 *eeprom)
+{
+	/*
+	 * Initialize the eeprom register
+	 */
+	eeprom_93cx6_startup(eeprom);
+
+	/*
+	 * Select the read opcode and the word to be read.
+	 */
+	eeprom_93cx6_write_bits(eeprom, PCI_EEPROM_EWDS_OPCODE, 5);
+	eeprom_93cx6_write_bits(eeprom, 0, 6);
+
+	/*
+	 * Cleanup eeprom register.
+	 */
+	eeprom_93cx6_cleanup(eeprom);
+}
+
+/**
+ * eeprom_93cx6_read - Read multiple words from eeprom
+ * @eeprom: Pointer to eeprom structure
+ * @word: Word index from where we should start reading
+ * @data: target pointer where the information will have to be stored
+ *
+ * This function will read the eeprom data as host-endian word
+ * into the given data pointer.
+ */
+void eeprom_93cx6_read(struct eeprom_93cx6 *eeprom, const u8 word,
+	u16 *data)
+{
+	u16 command;
+
+	/*
+	 * Initialize the eeprom register
+	 */
+	eeprom_93cx6_startup(eeprom);
+
+	/*
+	 * Select the read opcode and the word to be read.
+	 */
+	command = (PCI_EEPROM_READ_OPCODE << eeprom->width) | word;
+	eeprom_93cx6_write_bits(eeprom, command,
+		PCI_EEPROM_WIDTH_OPCODE + eeprom->width);
+
+	/*
+	 * Read the requested 16 bits.
+	 */
+	eeprom_93cx6_read_bits(eeprom, data, 16);
+
+	/*
+	 * Cleanup eeprom register.
+	 */
+	eeprom_93cx6_cleanup(eeprom);
+}
+EXPORT_SYMBOL_GPL(eeprom_93cx6_read);
+
+/**
+ * eeprom_93cx6_multiread - Read multiple words from eeprom
+ * @eeprom: Pointer to eeprom structure
+ * @word: Word index from where we should start reading
+ * @data: target pointer where the information will have to be stored
+ * @words: Number of words that should be read.
+ *
+ * This function will read all requested words from the eeprom,
+ * this is done by calling eeprom_93cx6_read() multiple times.
+ * But with the additional change that while the eeprom_93cx6_read
+ * will return host ordered bytes, this method will return little
+ * endian words.
+ */
+void eeprom_93cx6_multiread(struct eeprom_93cx6 *eeprom, const u8 word,
+	__le16 *data, const u16 words)
+{
+	unsigned int i;
+	u16 tmp;
+
+	for (i = 0; i < words; i++) {
+		tmp = 0;
+		eeprom_93cx6_read(eeprom, word + i, &tmp);
+		data[i] = cpu_to_le16(tmp);
+	}
+}
+EXPORT_SYMBOL_GPL(eeprom_93cx6_multiread);
+
+/**
+ * eeprom_93cx6_write - Write multiple words to the eeprom
+ * @eeprom: Pointer to eeprom structure
+ * @word: Word index from where we should start writing
+ * @data: Data that will be written
+ *
+ * This function will write the eeprom data as host-endian word
+ * from the given data pointer.
+ */
+void eeprom_93cx6_write(struct eeprom_93cx6 *eeprom, const u8 word,
+	u16 data)
+{
+	u16 command;
+
+	/*
+	 * select the ewen opcode.
+	 */
+	eeprom_93cx6_ewen(eeprom);
+
+	/*
+	 * Initialize the eeprom register
+	 */
+	eeprom_93cx6_startup(eeprom);
+
+	/*
+	 * Select the write opcode and the word to be read.
+	 */
+	command = (PCI_EEPROM_WRITE_OPCODE << eeprom->width) | word;
+	eeprom_93cx6_write_bits(eeprom, command,
+		PCI_EEPROM_WIDTH_OPCODE + eeprom->width);
+
+	/*
+	 * Write the requested 16 bits.
+	 */
+	eeprom_93cx6_write_bits(eeprom, data, 16);
+
+	/*
+	 * Cleanup eeprom register.
+	 */
+	eeprom_93cx6_cleanup(eeprom);
+
+	/*
+	 * Take a short break.
+	 */
+	msleep(10000);
+
+	/*
+	 * select the ewen opcode.
+	 */
+	eeprom_93cx6_ewds(eeprom);
+
+	/*
+	 * Cleanup eeprom register.
+	 */
+	eeprom_93cx6_cleanup(eeprom);
+}
+EXPORT_SYMBOL_GPL(eeprom_93cx6_write);
+
+
+/**
+ * eeprom_93cx6_multiwrite - Write multiple words to the eeprom
+ * @eeprom: Pointer to eeprom structure
+ * @word: Word index from where we should start writing
+ * @data: Pointer where the information will be read from
+ * @words: Number of words that should be written.
+ *
+ * This function will write all requested words to the eeprom,
+ * this is done by calling eeprom_93cx6_write() multiple times.
+ * This method accepts little endian data, so it will first be
+ * converted into host endian.
+ */
+void eeprom_93cx6_multiwrite(struct eeprom_93cx6 *eeprom, const u8 word,
+	__le16 *data, const u16 words)
+{
+	unsigned int i;
+
+	for (i = 0; i < words; i++)
+		eeprom_93cx6_write(eeprom, word + i, le16_to_cpu(data[i]));
+}
+EXPORT_SYMBOL_GPL(eeprom_93cx6_multiwrite);
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 0184614..7dc2336 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -538,6 +538,18 @@ config USB_ZD1201
 	  To compile this driver as a module, choose M here: the
 	  module will be called zd1201.
 
+config RTL8187
+	tristate "Realtek 8187 USB support"
+	depends on MAC80211 && USB && WLAN_80211 && EXPERIMENTAL
+	select EEPROM_93CX6
+	---help---
+	  This is a driver for RTL8187 based cards.
+	  These are USB based chips found in cards such as:
+
+	  Netgear WG111v2
+
+	  Thanks to Realtek for their support!
+
 source "drivers/net/wireless/hostap/Kconfig"
 source "drivers/net/wireless/bcm43xx/Kconfig"
 source "drivers/net/wireless/zd1211rw/Kconfig"
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index d212460..ef35bc6 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -44,3 +44,6 @@ obj-$(CONFIG_PCMCIA_WL3501)	+= wl3501_cs.o
 
 obj-$(CONFIG_USB_ZD1201)	+= zd1201.o
 obj-$(CONFIG_LIBERTAS_USB)     += libertas/
+
+rtl8187-objs		:= rtl8187_dev.o rtl8187_rtl8225.o
+obj-$(CONFIG_RTL8187)	+= rtl8187.o
diff --git a/drivers/net/wireless/rtl8187.h b/drivers/net/wireless/rtl8187.h
new file mode 100644
index 0000000..bd0b6f9
--- /dev/null
+++ b/drivers/net/wireless/rtl8187.h
@@ -0,0 +1,125 @@
+#ifndef RTL8187_H
+#define RTL8187_H
+
+#include "rtl818x.h"
+
+#define RTL8187_REQT_READ	0xC0
+#define RTL8187_REQT_WRITE	0x40
+#define RTL8187_REQ_GET_REG	0x05
+#define RTL8187_REQ_SET_REG	0x05
+
+#define RTL8187_MAX_RX		0x9C4
+
+struct rtl8187_rx_info {
+	struct urb *urb;
+	struct ieee80211_hw *dev;
+};
+
+struct rtl8187_rx_hdr {
+	__le16 len;
+	__le16 rate;
+	u8 noise;
+	u8 signal;
+	u8 agc;
+	u8 reserved;
+	__le64 mac_time;
+} __attribute__((packed));
+
+struct rtl8187_tx_info {
+	struct ieee80211_tx_control *control;
+	struct urb *urb;
+	struct ieee80211_hw *dev;
+};
+
+struct rtl8187_tx_hdr {
+	__le32 flags;
+#define RTL8187_TX_FLAG_NO_ENCRYPT	(1 << 15)
+#define RTL8187_TX_FLAG_MORE_FRAG	(1 << 17)
+#define RTL8187_TX_FLAG_CTS		(1 << 18)
+#define RTL8187_TX_FLAG_RTS		(1 << 23)
+	__le16 rts_duration;
+	__le16 len;
+	__le32 retry;
+} __attribute__((packed));
+
+struct rtl8187_priv {
+	/* common between rtl818x drivers */
+	struct rtl818x_csr *map;
+	void (*rf_init)(struct ieee80211_hw *);
+	int mode;
+
+	/* rtl8187 specific */
+	struct ieee80211_channel channels[14];
+	struct ieee80211_rate rates[12];
+	struct ieee80211_hw_mode modes[2];
+	struct usb_device *udev;
+	u8 *hwaddr;
+	u16 txpwr_base;
+	u8 asic_rev;
+	struct sk_buff_head rx_queue;
+};
+
+void rtl8187_write_phy(struct ieee80211_hw *dev, u8 addr, u32 data);
+
+static inline u8 rtl818x_ioread8(struct rtl8187_priv *priv, u8 *addr)
+{
+	u8 val;
+
+	usb_control_msg(priv->udev, usb_rcvctrlpipe(priv->udev, 0),
+			RTL8187_REQ_GET_REG, RTL8187_REQT_READ,
+			(unsigned long)addr, 0, &val, sizeof(val), HZ / 2);
+
+	return val;
+}
+
+static inline u16 rtl818x_ioread16(struct rtl8187_priv *priv, __le16 *addr)
+{
+	__le16 val;
+
+	usb_control_msg(priv->udev, usb_rcvctrlpipe(priv->udev, 0),
+			RTL8187_REQ_GET_REG, RTL8187_REQT_READ,
+			(unsigned long)addr, 0, &val, sizeof(val), HZ / 2);
+
+	return le16_to_cpu(val);
+}
+
+static inline u32 rtl818x_ioread32(struct rtl8187_priv *priv, __le32 *addr)
+{
+	__le32 val;
+
+	usb_control_msg(priv->udev, usb_rcvctrlpipe(priv->udev, 0),
+			RTL8187_REQ_GET_REG, RTL8187_REQT_READ,
+			(unsigned long)addr, 0, &val, sizeof(val), HZ / 2);
+
+	return le32_to_cpu(val);
+}
+
+static inline void rtl818x_iowrite8(struct rtl8187_priv *priv,
+				    u8 *addr, u8 val)
+{
+	usb_control_msg(priv->udev, usb_sndctrlpipe(priv->udev, 0),
+			RTL8187_REQ_SET_REG, RTL8187_REQT_WRITE,
+			(unsigned long)addr, 0, &val, sizeof(val), HZ / 2);
+}
+
+static inline void rtl818x_iowrite16(struct rtl8187_priv *priv,
+				     __le16 *addr, u16 val)
+{
+	__le16 buf = cpu_to_le16(val);
+
+	usb_control_msg(priv->udev, usb_sndctrlpipe(priv->udev, 0),
+			RTL8187_REQ_SET_REG, RTL8187_REQT_WRITE,
+			(unsigned long)addr, 0, &buf, sizeof(buf), HZ / 2);
+}
+
+static inline void rtl818x_iowrite32(struct rtl8187_priv *priv,
+				     __le32 *addr, u32 val)
+{
+	__le32 buf = cpu_to_le32(val);
+
+	usb_control_msg(priv->udev, usb_sndctrlpipe(priv->udev, 0),
+			RTL8187_REQ_SET_REG, RTL8187_REQT_WRITE,
+			(unsigned long)addr, 0, &buf, sizeof(buf), HZ / 2);
+}
+
+#endif /* RTL8187_H */
diff --git a/drivers/net/wireless/rtl8187_dev.c b/drivers/net/wireless/rtl8187_dev.c
new file mode 100644
index 0000000..8f9e781
--- /dev/null
+++ b/drivers/net/wireless/rtl8187_dev.c
@@ -0,0 +1,730 @@
+
+/*
+ * Linux device driver for RTL8187
+ *
+ * Copyright 2007 Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
+ * Copyright 2007 Andrea Merello <andreamrl-IWqWACnzNjyonA0d6jMUrA@public.gmane.org>
+ *
+ * Based on the r8187 driver, which is:
+ * Copyright 2005 Andrea Merello <andreamrl-IWqWACnzNjyonA0d6jMUrA@public.gmane.org>, et al.
+ *
+ * Thanks to Realtek for their support!
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/init.h>
+#include <linux/usb.h>
+#include <linux/delay.h>
+#include <linux/etherdevice.h>
+#include <linux/eeprom_93cx6.h>
+#include <net/mac80211.h>
+
+#include "rtl8187.h"
+#include "rtl8187_rtl8225.h"
+
+MODULE_AUTHOR("Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>");
+MODULE_AUTHOR("Andrea Merello <andreamrl-IWqWACnzNjyonA0d6jMUrA@public.gmane.org>");
+MODULE_DESCRIPTION("RTL8187 USB wireless driver");
+MODULE_LICENSE("GPL");
+
+static struct usb_device_id rtl8187_table[] __devinitdata = {
+	/* Realtek */
+	{USB_DEVICE(0x0bda, 0x8187)},
+	/* Netgear */
+	{USB_DEVICE(0x0846, 0x6100)},
+	{USB_DEVICE(0x0846, 0x6a00)},
+	{}
+};
+
+MODULE_DEVICE_TABLE(usb, rtl8187_table);
+
+void rtl8187_write_phy(struct ieee80211_hw *dev, u8 addr, u32 data)
+{
+	struct rtl8187_priv *priv = dev->priv;
+
+	data <<= 8;
+	data |= addr | 0x80;
+
+	rtl818x_iowrite8(priv, &priv->map->PHY[3], (data >> 24) & 0xFF);
+	rtl818x_iowrite8(priv, &priv->map->PHY[2], (data >> 16) & 0xFF);
+	rtl818x_iowrite8(priv, &priv->map->PHY[1], (data >> 8) & 0xFF);
+	rtl818x_iowrite8(priv, &priv->map->PHY[0], data & 0xFF);
+
+	mdelay(1);
+}
+
+static void rtl8187_tx_cb(struct urb *urb)
+{
+	struct ieee80211_tx_status status = { {0} };
+	struct sk_buff *skb = (struct sk_buff *)urb->context;
+	struct rtl8187_tx_info *info = (struct rtl8187_tx_info *)skb->cb;
+
+	usb_free_urb(info->urb);
+	if (info->control)
+		memcpy(&status.control, info->control, sizeof(status.control));
+	kfree(info->control);
+	skb_pull(skb, sizeof(struct rtl8187_tx_hdr));
+	status.flags |= IEEE80211_TX_STATUS_ACK;
+	ieee80211_tx_status_irqsafe(info->dev, skb, &status);
+}
+
+static int rtl8187_tx(struct ieee80211_hw *dev, struct sk_buff *skb,
+		      struct ieee80211_tx_control *control)
+{
+	struct rtl8187_priv *priv = dev->priv;
+	struct rtl8187_tx_hdr *hdr;
+	struct rtl8187_tx_info *info;
+	struct urb *urb;
+	u32 tmp;
+
+	urb = usb_alloc_urb(0, GFP_ATOMIC);
+	if (!urb) {
+		kfree_skb(skb);
+		return 0;
+	}
+
+	hdr = (struct rtl8187_tx_hdr *)skb_push(skb, sizeof(*hdr));
+	tmp = skb->len - sizeof(*hdr);
+	tmp |= RTL8187_TX_FLAG_NO_ENCRYPT;
+	tmp |= control->rts_cts_rate << 19;
+	tmp |= control->tx_rate << 24;
+	if (ieee80211_get_morefrag((struct ieee80211_hdr *)skb))
+		tmp |= RTL8187_TX_FLAG_MORE_FRAG;
+	if (control->flags & IEEE80211_TXCTL_USE_RTS_CTS) {
+		tmp |= RTL8187_TX_FLAG_RTS;
+		hdr->rts_duration =
+			ieee80211_rts_duration(dev, skb->len, control);
+	}
+	if (control->flags & IEEE80211_TXCTL_USE_CTS_PROTECT)
+		tmp |= RTL8187_TX_FLAG_CTS;
+	hdr->flags = cpu_to_le32(tmp);
+	hdr->len = 0;
+	tmp = control->retry_limit << 8;
+	hdr->retry = cpu_to_le32(tmp);
+
+	info = (struct rtl8187_tx_info *)skb->cb;
+	info->control = kmemdup(control, sizeof(*control), GFP_ATOMIC);
+	info->urb = urb;
+	info->dev = dev;
+	usb_fill_bulk_urb(urb, priv->udev, usb_sndbulkpipe(priv->udev, 2),
+			  hdr, skb->len, rtl8187_tx_cb, skb);
+	usb_submit_urb(urb, GFP_ATOMIC);
+
+	return 0;
+}
+
+static void rtl8187_rx_cb(struct urb *urb)
+{
+	struct sk_buff *skb = (struct sk_buff *)urb->context;
+	struct rtl8187_rx_info *info = (struct rtl8187_rx_info *)skb->cb;
+	struct ieee80211_hw *dev = info->dev;
+	struct rtl8187_priv *priv = dev->priv;
+	struct rtl8187_rx_hdr *hdr;
+	struct ieee80211_rx_status rx_status = { 0 };
+	int rate, signal;
+
+	if (unlikely(urb->status)) {
+		info->urb = NULL;
+		usb_free_urb(urb);
+		return;
+	}
+
+	skb_unlink(skb, &priv->rx_queue);
+	skb_put(skb, urb->actual_length);
+	hdr = (struct rtl8187_rx_hdr *)(skb_tail_pointer(skb) - sizeof(*hdr));
+	skb_trim(skb, le16_to_cpu(hdr->len) & 0x0FFF);
+
+	signal = hdr->agc >> 1;
+	rate = (le16_to_cpu(hdr->rate) >> 4) & 0xF;
+	if (rate > 3) {	/* OFDM rate */
+		if (signal > 90)
+			signal = 90;
+		else if (signal < 25)
+			signal = 25;
+		signal = 90 - signal;
+	} else {	/* CCK rate */
+		if (signal > 95)
+			signal = 95;
+		else if (signal < 30)
+			signal = 30;
+		signal = 95 - signal;
+	}
+
+	rx_status.antenna = (hdr->signal >> 7) & 1;
+	rx_status.signal = 64 - min(hdr->noise, (u8)64);
+	rx_status.ssi = signal;
+	rx_status.rate = rate;
+	rx_status.freq = dev->conf.freq;
+	rx_status.channel = dev->conf.channel;
+	rx_status.phymode = dev->conf.phymode;
+	rx_status.mactime = le64_to_cpu(hdr->mac_time);
+	ieee80211_rx_irqsafe(dev, skb, &rx_status);
+
+	skb = dev_alloc_skb(RTL8187_MAX_RX);
+	if (unlikely(!skb)) {
+		usb_free_urb(urb);
+		/* TODO check rx queue length and refill *somewhere* */
+		return;
+	}
+
+	info = (struct rtl8187_rx_info *)skb->cb;
+	info->urb = urb;
+	info->dev = dev;
+	urb->transfer_buffer = skb_tail_pointer(skb);
+	urb->context = skb;
+	skb_queue_tail(&priv->rx_queue, skb);
+
+	usb_submit_urb(urb, GFP_ATOMIC);
+}
+
+static int rtl8187_init_urbs(struct ieee80211_hw *dev)
+{
+	struct rtl8187_priv *priv = dev->priv;
+	struct urb *entry;
+	struct sk_buff *skb;
+	struct rtl8187_rx_info *info;
+
+	while (skb_queue_len(&priv->rx_queue) < 8) {
+		skb = __dev_alloc_skb(RTL8187_MAX_RX, GFP_KERNEL);
+		if (!skb)
+			break;
+		entry = usb_alloc_urb(0, GFP_KERNEL);
+		if (!entry) {
+			kfree_skb(skb);
+			break;
+		}
+		usb_fill_bulk_urb(entry, priv->udev,
+				  usb_rcvbulkpipe(priv->udev, 1),
+				  skb_tail_pointer(skb),
+				  RTL8187_MAX_RX, rtl8187_rx_cb, skb);
+		info = (struct rtl8187_rx_info *)skb->cb;
+		info->urb = entry;
+		info->dev = dev;
+		skb_queue_tail(&priv->rx_queue, skb);
+		usb_submit_urb(entry, GFP_KERNEL);
+	}
+
+	return 0;
+}
+
+static int rtl8187_init_hw(struct ieee80211_hw *dev)
+{
+	struct rtl8187_priv *priv = dev->priv;
+	u8 reg;
+	int i;
+
+	/* reset */
+	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, RTL818X_EEPROM_CMD_CONFIG);
+	reg = rtl818x_ioread8(priv, &priv->map->CONFIG3);
+	rtl818x_iowrite8(priv, &priv->map->CONFIG3, reg | RTL818X_CONFIG3_ANAPARAM_WRITE);
+	rtl818x_iowrite32(priv, &priv->map->ANAPARAM, RTL8225_ANAPARAM_ON);
+	rtl818x_iowrite32(priv, &priv->map->ANAPARAM2, RTL8225_ANAPARAM2_ON);
+	rtl818x_iowrite8(priv, &priv->map->CONFIG3, reg & ~RTL818X_CONFIG3_ANAPARAM_WRITE);
+	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, RTL818X_EEPROM_CMD_NORMAL);
+
+	rtl818x_iowrite16(priv, &priv->map->INT_MASK, 0);
+
+	mdelay(200);
+	rtl818x_iowrite8(priv, (u8 *)0xFE18, 0x10);
+	rtl818x_iowrite8(priv, (u8 *)0xFE18, 0x11);
+	rtl818x_iowrite8(priv, (u8 *)0xFE18, 0x00);
+	mdelay(200);
+
+	reg = rtl818x_ioread8(priv, &priv->map->CMD);
+	reg &= (1 << 1);
+	reg |= RTL818X_CMD_RESET;
+	rtl818x_iowrite8(priv, &priv->map->CMD, reg);
+
+	i = 10;
+	do {
+		mdelay(2);
+		if (!(rtl818x_ioread8(priv, &priv->map->CMD) &
+		      RTL818X_CMD_RESET))
+			break;
+	} while (--i);
+
+	if (!i) {
+		printk(KERN_ERR "%s: Reset timeout!\n", wiphy_name(dev->wiphy));
+		return -ETIMEDOUT;
+	}
+
+	/* reload registers from eeprom */
+	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, RTL818X_EEPROM_CMD_LOAD);
+
+	i = 10;
+	do {
+		mdelay(4);
+		if (!(rtl818x_ioread8(priv, &priv->map->EEPROM_CMD) &
+		      RTL818X_EEPROM_CMD_CONFIG))
+			break;
+	} while (--i);
+
+	if (!i) {
+		printk(KERN_ERR "%s: eeprom reset timeout!\n",
+		       wiphy_name(dev->wiphy));
+		return -ETIMEDOUT;
+	}
+
+	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, RTL818X_EEPROM_CMD_CONFIG);
+	reg = rtl818x_ioread8(priv, &priv->map->CONFIG3);
+	rtl818x_iowrite8(priv, &priv->map->CONFIG3, reg | RTL818X_CONFIG3_ANAPARAM_WRITE);
+	rtl818x_iowrite32(priv, &priv->map->ANAPARAM, RTL8225_ANAPARAM_ON);
+	rtl818x_iowrite32(priv, &priv->map->ANAPARAM2, RTL8225_ANAPARAM2_ON);
+	rtl818x_iowrite8(priv, &priv->map->CONFIG3, reg & ~RTL818X_CONFIG3_ANAPARAM_WRITE);
+	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, RTL818X_EEPROM_CMD_NORMAL);
+
+	/* setup card */
+	rtl818x_iowrite8(priv, (u8 *)0xFF85, 0);
+	rtl818x_iowrite8(priv, &priv->map->GPIO, 0);
+
+	rtl818x_iowrite8(priv, (u8 *)0xFF85, 4);
+	rtl818x_iowrite8(priv, &priv->map->GPIO, 1);
+	rtl818x_iowrite8(priv, &priv->map->GP_ENABLE, 0);
+
+	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, RTL818X_EEPROM_CMD_CONFIG);
+	for (i = 0; i < ETH_ALEN; i++)
+		rtl818x_iowrite8(priv, &priv->map->MAC[i], priv->hwaddr[i]);
+
+	rtl818x_iowrite16(priv, (__le16 *)0xFFF4, 0xFFFF);
+	reg = rtl818x_ioread8(priv, &priv->map->CONFIG1);
+	reg &= 0x3F;
+	reg |= 0x80;
+	rtl818x_iowrite8(priv, &priv->map->CONFIG1, reg);
+
+	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, RTL818X_EEPROM_CMD_NORMAL);
+
+	rtl818x_iowrite32(priv, &priv->map->INT_TIMEOUT, 0);
+	rtl818x_iowrite8(priv, &priv->map->WPA_CONF, 0);
+	rtl818x_iowrite8(priv, &priv->map->RATE_FALLBACK, 0x81);
+
+	// TODO: set RESP_RATE and BRSR properly
+	rtl818x_iowrite8(priv, &priv->map->RESP_RATE, (8 << 4) | 0);
+	rtl818x_iowrite16(priv, &priv->map->BRSR, 0x01F3);
+
+	/* host_usb_init */
+	rtl818x_iowrite8(priv, (u8 *)0xFF85, 0);
+	rtl818x_iowrite8(priv, &priv->map->GPIO, 0);
+	reg = rtl818x_ioread8(priv, (u8 *)0xFE53);
+	rtl818x_iowrite8(priv, (u8 *)0xFE53, reg | (1 << 7));
+	rtl818x_iowrite8(priv, (u8 *)0xFF85, 4);
+	rtl818x_iowrite8(priv, &priv->map->GPIO, 0x20);
+	rtl818x_iowrite8(priv, &priv->map->GP_ENABLE, 0);
+	rtl818x_iowrite16(priv, &priv->map->RFPinsOutput, 0x80);
+	rtl818x_iowrite16(priv, &priv->map->RFPinsSelect, 0x80);
+	rtl818x_iowrite16(priv, &priv->map->RFPinsEnable, 0x80);
+	mdelay(100);
+
+	rtl818x_iowrite32(priv, &priv->map->RF_TIMING, 0x000a8008);
+	rtl818x_iowrite16(priv, &priv->map->BRSR, 0xFFFF);
+	rtl818x_iowrite32(priv, &priv->map->RF_PARA, 0x00100044);
+	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, RTL818X_EEPROM_CMD_CONFIG);
+	rtl818x_iowrite8(priv, &priv->map->CONFIG3, 0x44);
+	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, RTL818X_EEPROM_CMD_NORMAL);
+	rtl818x_iowrite16(priv, &priv->map->RFPinsEnable, 0x1FF7);
+	mdelay(100);
+
+	priv->rf_init(dev);
+
+	rtl818x_iowrite16(priv, &priv->map->BRSR, 0x01F3);
+	reg = rtl818x_ioread16(priv, &priv->map->PGSELECT) & 0xfffe;
+	rtl818x_iowrite16(priv, &priv->map->PGSELECT, reg | 0x1);
+	rtl818x_iowrite16(priv, (__le16 *)0xFFFE, 0x10);
+	rtl818x_iowrite8(priv, &priv->map->TALLY_SEL, 0x80);
+	rtl818x_iowrite8(priv, (u8 *)0xFFFF, 0x60);
+	rtl818x_iowrite16(priv, &priv->map->PGSELECT, reg);
+
+	return 0;
+}
+
+static void rtl8187_set_channel(struct ieee80211_hw *dev, int channel)
+{
+	u32 reg;
+	struct rtl8187_priv *priv = dev->priv;
+
+	reg = rtl818x_ioread32(priv, &priv->map->TX_CONF);
+	/* Enable TX loopback on MAC level to avoid TX during channel
+	 * changes, as this has be seen to causes problems and the
+	 * card will stop work until next reset
+	 */
+	rtl818x_iowrite32(priv, &priv->map->TX_CONF,
+			  reg | RTL818X_TX_CONF_LOOPBACK_MAC);
+	mdelay(10);
+	rtl8225_rf_set_channel(dev, channel);
+	mdelay(10);
+	rtl818x_iowrite32(priv, &priv->map->TX_CONF, reg);
+}
+
+static int rtl8187_open(struct ieee80211_hw *dev)
+{
+	struct rtl8187_priv *priv = dev->priv;
+	u32 reg;
+	int ret;
+
+	ret = rtl8187_init_hw(dev);
+	if (ret)
+		return ret;
+
+	rtl818x_iowrite16(priv, &priv->map->INT_MASK, 0xFFFF);
+
+	rtl8187_init_urbs(dev);
+
+	reg = RTL818X_RX_CONF_ONLYERLPKT |
+	      RTL818X_RX_CONF_RX_AUTORESETPHY |
+	      RTL818X_RX_CONF_BSSID |
+	      RTL818X_RX_CONF_MGMT |
+	      RTL818X_RX_CONF_CTRL |
+	      RTL818X_RX_CONF_DATA |
+	      (7 << 13 /* RX FIFO threshold NONE */) |
+	      (7 << 10 /* MAX RX DMA */) |
+	      RTL818X_RX_CONF_BROADCAST |
+	      RTL818X_RX_CONF_MULTICAST |
+	      RTL818X_RX_CONF_NICMAC;
+	if (priv->mode == IEEE80211_IF_TYPE_MNTR)
+		reg |= RTL818X_RX_CONF_MONITOR;
+
+	rtl818x_iowrite32(priv, &priv->map->RX_CONF, reg);
+
+	reg = rtl818x_ioread8(priv, &priv->map->CW_CONF);
+	reg &= ~RTL818X_CW_CONF_PERPACKET_CW_SHIFT;
+	reg |= RTL818X_CW_CONF_PERPACKET_RETRY_SHIFT;
+	rtl818x_iowrite8(priv, &priv->map->CW_CONF, reg);
+
+	reg = rtl818x_ioread8(priv, &priv->map->TX_AGC_CTL);
+	reg &= ~RTL818X_TX_AGC_CTL_PERPACKET_GAIN_SHIFT;
+	reg &= ~RTL818X_TX_AGC_CTL_PERPACKET_ANTSEL_SHIFT;
+	reg &= ~RTL818X_TX_AGC_CTL_FEEDBACK_ANT;
+	rtl818x_iowrite8(priv, &priv->map->TX_AGC_CTL, reg);
+
+	reg  = RTL818X_TX_CONF_CW_MIN |
+	       (7 << 21 /* MAX TX DMA */) |
+	       RTL818X_TX_CONF_NO_ICV;
+	rtl818x_iowrite32(priv, &priv->map->TX_CONF, reg);
+
+	reg = rtl818x_ioread8(priv, &priv->map->CMD);
+	reg |= RTL818X_CMD_TX_ENABLE;
+	reg |= RTL818X_CMD_RX_ENABLE;
+	rtl818x_iowrite8(priv, &priv->map->CMD, reg);
+
+	return 0;
+}
+
+static int rtl8187_stop(struct ieee80211_hw *dev)
+{
+	struct rtl8187_priv *priv = dev->priv;
+	struct rtl8187_rx_info *info;
+	struct sk_buff *skb;
+	u32 reg;
+
+	rtl818x_iowrite16(priv, &priv->map->INT_MASK, 0);
+
+	reg = rtl818x_ioread8(priv, &priv->map->CMD);
+	reg &= ~RTL818X_CMD_TX_ENABLE;
+	reg &= ~RTL818X_CMD_RX_ENABLE;
+	rtl818x_iowrite8(priv, &priv->map->CMD, reg);
+
+	rtl8225_rf_stop(dev);
+
+	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, RTL818X_EEPROM_CMD_CONFIG);
+	reg = rtl818x_ioread8(priv, &priv->map->CONFIG4);
+	rtl818x_iowrite8(priv, &priv->map->CONFIG4, reg | RTL818X_CONFIG4_VCOOFF);
+	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, RTL818X_EEPROM_CMD_NORMAL);
+
+	while ((skb = skb_dequeue(&priv->rx_queue))) {
+		info = (struct rtl8187_rx_info *)skb->cb;
+		if (!info->urb)
+			continue;
+
+		usb_kill_urb(info->urb);
+		kfree_skb(skb);
+	}
+	return 0;
+}
+
+static int rtl8187_add_interface(struct ieee80211_hw *dev,
+				 struct ieee80211_if_init_conf *conf)
+{
+	struct rtl8187_priv *priv = dev->priv;
+
+	/* NOTE: using IEEE80211_IF_TYPE_MGMT to indicate no mode selected */
+	if (priv->mode != IEEE80211_IF_TYPE_MGMT)
+		return -1;
+
+	switch (conf->type) {
+	case IEEE80211_IF_TYPE_STA:
+	case IEEE80211_IF_TYPE_MNTR:
+		priv->mode = conf->type;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	priv->hwaddr = conf->mac_addr;
+
+	return 0;
+}
+
+static void rtl8187_remove_interface(struct ieee80211_hw *dev,
+				     struct ieee80211_if_init_conf *conf)
+{
+	struct rtl8187_priv *priv = dev->priv;
+	priv->mode = IEEE80211_IF_TYPE_MGMT;
+}
+
+static int rtl8187_config(struct ieee80211_hw *dev, struct ieee80211_conf *conf)
+{
+	struct rtl8187_priv *priv = dev->priv;
+	rtl8187_set_channel(dev, conf->channel);
+
+	rtl818x_iowrite8(priv, &priv->map->SIFS, 0x22);
+
+	if (conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME)
+		rtl818x_iowrite8(priv, &priv->map->SLOT, 0x9);
+	else
+		rtl818x_iowrite8(priv, &priv->map->SLOT, 0x14);
+
+	switch (conf->phymode) {
+	case MODE_IEEE80211B:
+		rtl818x_iowrite8(priv, &priv->map->DIFS, 0x24);
+		rtl818x_iowrite8(priv, &priv->map->EIFS, 91 - 0x24);
+		rtl818x_iowrite8(priv, &priv->map->CW_VAL, 0xa5);
+		break;
+	case MODE_IEEE80211G:
+		rtl818x_iowrite8(priv, &priv->map->DIFS, 0x14);
+		rtl818x_iowrite8(priv, &priv->map->EIFS, 91 - 0x14);
+		rtl818x_iowrite8(priv, &priv->map->CW_VAL, 0x73);
+		break;
+	default:
+		BUG();
+		break;
+	}
+
+	rtl818x_iowrite16(priv, &priv->map->ATIM_WND, 2);
+	rtl818x_iowrite16(priv, &priv->map->ATIMTR_INTERVAL, 100);
+	rtl818x_iowrite16(priv, &priv->map->BEACON_INTERVAL, 100);
+	rtl818x_iowrite16(priv, &priv->map->BEACON_INTERVAL_TIME, 100);
+	return 0;
+}
+
+static int rtl8187_config_interface(struct ieee80211_hw *dev, int if_id,
+				    struct ieee80211_if_conf *conf)
+{
+	struct rtl8187_priv *priv = dev->priv;
+	int i;
+
+	for (i = 0; i < ETH_ALEN; i++)
+		rtl818x_iowrite8(priv, &priv->map->BSSID[i], conf->bssid[i]);
+
+	if (is_valid_ether_addr(conf->bssid))
+		rtl818x_iowrite8(priv, &priv->map->MSR, RTL818X_MSR_INFRA);
+	else
+		rtl818x_iowrite8(priv, &priv->map->MSR, RTL818X_MSR_NO_LINK);
+
+	return 0;
+}
+
+static const struct ieee80211_ops rtl8187_ops = {
+	.tx			= rtl8187_tx,
+	.open			= rtl8187_open,
+	.stop			= rtl8187_stop,
+	.add_interface		= rtl8187_add_interface,
+	.remove_interface	= rtl8187_remove_interface,
+	.config			= rtl8187_config,
+	.config_interface	= rtl8187_config_interface,
+};
+
+static void rtl8187_register_read(struct eeprom_93cx6 *eeprom)
+{
+	struct ieee80211_hw *dev = eeprom->data;
+	struct rtl8187_priv *priv = dev->priv;
+	u8 reg = rtl818x_ioread8(priv, &priv->map->EEPROM_CMD);
+
+	eeprom->reg_data_in = reg & RTL818X_EEPROM_CMD_WRITE;
+	eeprom->reg_data_out = reg & RTL818X_EEPROM_CMD_READ;
+	eeprom->reg_data_clock = reg & RTL818X_EEPROM_CMD_CK;
+	eeprom->reg_chip_select = reg & RTL818X_EEPROM_CMD_CS;
+}
+
+static void rtl8187_register_write(struct eeprom_93cx6 *eeprom)
+{
+	struct ieee80211_hw *dev = eeprom->data;
+	struct rtl8187_priv *priv = dev->priv;
+	u8 reg = RTL818X_EEPROM_CMD_PROGRAM;
+
+	if (eeprom->reg_data_in)
+		reg |= RTL818X_EEPROM_CMD_WRITE;
+	if (eeprom->reg_data_out)
+		reg |= RTL818X_EEPROM_CMD_READ;
+	if (eeprom->reg_data_clock)
+		reg |= RTL818X_EEPROM_CMD_CK;
+	if (eeprom->reg_chip_select)
+		reg |= RTL818X_EEPROM_CMD_CS;
+
+	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, reg);
+	udelay(10);
+}
+
+static int __devinit rtl8187_probe(struct usb_interface *intf,
+				   const struct usb_device_id *id)
+{
+	struct usb_device *udev = interface_to_usbdev(intf);
+	struct ieee80211_hw *dev;
+	struct rtl8187_priv *priv;
+	struct eeprom_93cx6 eeprom;
+	struct ieee80211_channel *channel;
+	u16 txpwr, reg;
+	int err, i;
+
+	dev = ieee80211_alloc_hw(sizeof(*priv), &rtl8187_ops);
+	if (!dev) {
+		printk(KERN_ERR "rtl8187: ieee80211 alloc failed\n");
+		return -ENOMEM;
+	}
+
+	priv = dev->priv;
+
+	SET_IEEE80211_DEV(dev, &intf->dev);
+	usb_set_intfdata(intf, dev);
+	priv->udev = udev;
+
+	usb_get_dev(udev);
+
+	skb_queue_head_init(&priv->rx_queue);
+	memcpy(priv->channels, rtl818x_channels, sizeof(rtl818x_channels));
+	memcpy(priv->rates, rtl818x_rates, sizeof(rtl818x_rates));
+	priv->map = (struct rtl818x_csr *)0xFF00;
+	priv->modes[0].mode = MODE_IEEE80211G;
+	priv->modes[0].num_rates = ARRAY_SIZE(rtl818x_rates);
+	priv->modes[0].rates = priv->rates;
+	priv->modes[0].num_channels = ARRAY_SIZE(rtl818x_channels);
+	priv->modes[0].channels = priv->channels;
+	priv->modes[1].mode = MODE_IEEE80211B;
+	priv->modes[1].num_rates = 4;
+	priv->modes[1].rates = priv->rates;
+	priv->modes[1].num_channels = ARRAY_SIZE(rtl818x_channels);
+	priv->modes[1].channels = priv->channels;
+	priv->mode = IEEE80211_IF_TYPE_MGMT;
+	dev->flags = IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING |
+		     IEEE80211_HW_RX_INCLUDES_FCS |
+		     IEEE80211_HW_WEP_INCLUDE_IV |
+		     IEEE80211_HW_DATA_NULLFUNC_ACK;
+	dev->extra_tx_headroom = sizeof(struct rtl8187_tx_hdr);
+	dev->queues = 1;
+	dev->max_rssi = 65;
+	dev->max_signal = 64;
+
+	for (i = 0; i < 2; i++)
+		if ((err = ieee80211_register_hwmode(dev, &priv->modes[i])))
+			goto err_free_dev;
+
+	eeprom.data = dev;
+	eeprom.register_read = rtl8187_register_read;
+	eeprom.register_write = rtl8187_register_write;
+	if (rtl818x_ioread32(priv, &priv->map->RX_CONF) & (1 << 6))
+		eeprom.width = PCI_EEPROM_WIDTH_93C66;
+	else
+		eeprom.width = PCI_EEPROM_WIDTH_93C46;
+
+	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, RTL818X_EEPROM_CMD_CONFIG);
+	udelay(10);
+
+	eeprom_93cx6_multiread(&eeprom, 0x7,
+			       (__le16 __force *)dev->wiphy->perm_addr, 3);
+	if (!is_valid_ether_addr(dev->wiphy->perm_addr)) {
+		printk(KERN_WARNING "rtl8187: Invalid hwaddr! Using randomly generated MAC address\n");
+		random_ether_addr(dev->wiphy->perm_addr);
+	}
+
+	channel = priv->channels;
+	for (i = 0; i < 3; i++) {
+		eeprom_93cx6_read(&eeprom, 0x16 + i, &txpwr);
+		(*channel++).val = txpwr & 0xFF;
+		(*channel++).val = txpwr >> 8;
+	}
+	for (i = 0; i < 2; i++) {
+		eeprom_93cx6_read(&eeprom, 0x3D + i, &txpwr);
+		(*channel++).val = txpwr & 0xFF;
+		(*channel++).val = txpwr >> 8;
+	}
+	for (i = 0; i < 2; i++) {
+		eeprom_93cx6_read(&eeprom, 0x1B + i, &txpwr);
+		(*channel++).val = txpwr & 0xFF;
+		(*channel++).val = txpwr >> 8;
+	}
+
+	eeprom_93cx6_read(&eeprom, 0x05, &priv->txpwr_base);
+
+	reg = rtl818x_ioread16(priv, &priv->map->PGSELECT) & ~1;
+	rtl818x_iowrite16(priv, &priv->map->PGSELECT, reg | 1);
+	/* 0 means asic B-cut, we should use SW 3 wire
+	 * bit-by-bit banging for radio. 1 means we can use
+	 * USB specific request to write radio registers */
+	priv->asic_rev = rtl818x_ioread8(priv, (u8 *)0xFFFE) & 0x3;
+	rtl818x_iowrite16(priv, &priv->map->PGSELECT, reg);
+	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, RTL818X_EEPROM_CMD_NORMAL);
+
+	rtl8225_write(dev, 0, 0x1B7);
+
+	if (rtl8225_read(dev, 8) != 0x588 || rtl8225_read(dev, 9) != 0x700)
+		priv->rf_init = rtl8225_rf_init;
+	else
+		priv->rf_init = rtl8225z2_rf_init;
+
+	rtl8225_write(dev, 0, 0x0B7);
+
+	err = ieee80211_register_hw(dev);
+	if (err) {
+		printk(KERN_ERR "rtl8187: Cannot register device\n");
+		goto err_free_dev;
+	}
+
+	printk(KERN_INFO "%s: hwaddr " MAC_FMT ", rtl8187 V%d + %s\n",
+	       wiphy_name(dev->wiphy), MAC_ARG(dev->wiphy->perm_addr),
+	       priv->asic_rev, priv->rf_init == rtl8225_rf_init ?
+	       "rtl8225" : "rtl8225z2");
+
+	return 0;
+
+ err_free_dev:
+	ieee80211_free_hw(dev);
+	usb_set_intfdata(intf, NULL);
+	usb_put_dev(udev);
+	return err;
+}
+
+static void __devexit rtl8187_disconnect(struct usb_interface *intf)
+{
+	struct ieee80211_hw *dev = usb_get_intfdata(intf);
+	struct rtl8187_priv *priv;
+
+	if (!dev)
+		return;
+
+	ieee80211_unregister_hw(dev);
+
+	priv = dev->priv;
+	usb_put_dev(interface_to_usbdev(intf));
+	ieee80211_free_hw(dev);
+}
+
+static struct usb_driver rtl8187_driver = {
+	.name		= KBUILD_MODNAME,
+	.id_table	= rtl8187_table,
+	.probe		= rtl8187_probe,
+	.disconnect	= rtl8187_disconnect,
+};
+
+static int __init rtl8187_init(void)
+{
+	return usb_register(&rtl8187_driver);
+}
+
+static void __exit rtl8187_exit(void)
+{
+	usb_deregister(&rtl8187_driver);
+}
+
+module_init(rtl8187_init);
+module_exit(rtl8187_exit);
diff --git a/drivers/net/wireless/rtl8187_rtl8225.c b/drivers/net/wireless/rtl8187_rtl8225.c
new file mode 100644
index 0000000..a89f023
--- /dev/null
+++ b/drivers/net/wireless/rtl8187_rtl8225.c
@@ -0,0 +1,744 @@
+
+/*
+ * Radio tuning for RTL8225 on RTL8187
+ *
+ * Copyright 2007 Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
+ * Copyright 2007 Andrea Merello <andreamrl-IWqWACnzNjyonA0d6jMUrA@public.gmane.org>
+ *
+ * Based on the r8187 driver, which is:
+ * Copyright 2005 Andrea Merello <andreamrl-IWqWACnzNjyonA0d6jMUrA@public.gmane.org>, et al.
+ *
+ * Thanks to Realtek for their support!
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/init.h>
+#include <linux/usb.h>
+#include <net/mac80211.h>
+
+#include "rtl8187.h"
+#include "rtl8187_rtl8225.h"
+
+static void rtl8225_write_bitbang(struct ieee80211_hw *dev, u8 addr, u16 data)
+{
+	struct rtl8187_priv *priv = dev->priv;
+	u16 reg80, reg84, reg82;
+	u32 bangdata;
+	int i;
+
+	bangdata = (data << 4) | (addr & 0xf);
+
+	reg80 = rtl818x_ioread16(priv, &priv->map->RFPinsOutput) & 0xfff3;
+	reg82 = rtl818x_ioread16(priv, &priv->map->RFPinsEnable);
+
+	rtl818x_iowrite16(priv, &priv->map->RFPinsEnable, reg82 | 0x7);
+
+	reg84 = rtl818x_ioread16(priv, &priv->map->RFPinsSelect);
+	rtl818x_iowrite16(priv, &priv->map->RFPinsSelect, reg84 | 0x7);
+	udelay(10);
+
+	rtl818x_iowrite16(priv, &priv->map->RFPinsOutput, reg80 | (1 << 2));
+	udelay(2);
+	rtl818x_iowrite16(priv, &priv->map->RFPinsOutput, reg80);
+	udelay(10);
+
+	for (i = 15; i >= 0; i--) {
+		u16 reg = reg80 | (bangdata & (1 << i)) >> i;
+
+		if (i & 1)
+			rtl818x_iowrite16(priv, &priv->map->RFPinsOutput, reg);
+
+		rtl818x_iowrite16(priv, &priv->map->RFPinsOutput, reg | (1 << 1));
+		rtl818x_iowrite16(priv, &priv->map->RFPinsOutput, reg | (1 << 1));
+
+		if (!(i & 1))
+			rtl818x_iowrite16(priv, &priv->map->RFPinsOutput, reg);
+	}
+
+	rtl818x_iowrite16(priv, &priv->map->RFPinsOutput, reg80 | (1 << 2));
+	udelay(10);
+
+	rtl818x_iowrite16(priv, &priv->map->RFPinsOutput, reg80 | (1 << 2));
+	rtl818x_iowrite16(priv, &priv->map->RFPinsSelect, reg84);
+	mdelay(2);
+}
+
+static void rtl8225_write_8051(struct ieee80211_hw *dev, u8 addr, u16 data)
+{
+	struct rtl8187_priv *priv = dev->priv;
+	u16 reg80, reg82, reg84;
+
+	reg80 = rtl818x_ioread16(priv, &priv->map->RFPinsOutput);
+	reg82 = rtl818x_ioread16(priv, &priv->map->RFPinsEnable);
+	reg84 = rtl818x_ioread16(priv, &priv->map->RFPinsSelect);
+
+	reg80 &= ~(0x3 << 2);
+	reg84 &= ~0xF;
+
+	rtl818x_iowrite16(priv, &priv->map->RFPinsEnable, reg82 | 0x0007);
+	rtl818x_iowrite16(priv, &priv->map->RFPinsSelect, reg84 | 0x0007);
+	udelay(10);
+
+	rtl818x_iowrite16(priv, &priv->map->RFPinsOutput, reg80 | (1 << 2));
+	udelay(2);
+
+	rtl818x_iowrite16(priv, &priv->map->RFPinsOutput, reg80);
+	udelay(10);
+
+	usb_control_msg(priv->udev, usb_sndctrlpipe(priv->udev, 0),
+			RTL8187_REQ_SET_REG, RTL8187_REQT_WRITE,
+			addr, 0x8225, &data, sizeof(data), HZ / 2);
+
+	rtl818x_iowrite16(priv, &priv->map->RFPinsOutput, reg80 | (1 << 2));
+	udelay(10);
+
+	rtl818x_iowrite16(priv, &priv->map->RFPinsOutput, reg80 | (1 << 2));
+	rtl818x_iowrite16(priv, &priv->map->RFPinsSelect, reg84);
+	mdelay(2);
+}
+
+void rtl8225_write(struct ieee80211_hw *dev, u8 addr, u16 data)
+{
+	struct rtl8187_priv *priv = dev->priv;
+
+	if (priv->asic_rev)
+		rtl8225_write_8051(dev, addr, data);
+	else
+		rtl8225_write_bitbang(dev, addr, data);
+}
+
+u16 rtl8225_read(struct ieee80211_hw *dev, u8 addr)
+{
+	struct rtl8187_priv *priv = dev->priv;
+	u16 reg80, reg82, reg84, out;
+	int i;
+
+	reg80 = rtl818x_ioread16(priv, &priv->map->RFPinsOutput);
+	reg82 = rtl818x_ioread16(priv, &priv->map->RFPinsEnable);
+	reg84 = rtl818x_ioread16(priv, &priv->map->RFPinsSelect);
+
+	reg80 &= ~0xF;
+
+	rtl818x_iowrite16(priv, &priv->map->RFPinsEnable, reg82 | 0x000F);
+	rtl818x_iowrite16(priv, &priv->map->RFPinsSelect, reg84 | 0x000F);
+
+	rtl818x_iowrite16(priv, &priv->map->RFPinsOutput, reg80 | (1 << 2));
+	udelay(4);
+	rtl818x_iowrite16(priv, &priv->map->RFPinsOutput, reg80);
+	udelay(5);
+
+	for (i = 4; i >= 0; i--) {
+		u16 reg = reg80 | ((addr >> i) & 1);
+
+		if (!(i & 1)) {
+			rtl818x_iowrite16(priv, &priv->map->RFPinsOutput, reg);
+			udelay(1);
+		}
+
+		rtl818x_iowrite16(priv, &priv->map->RFPinsOutput,
+				  reg | (1 << 1));
+		udelay(2);
+		rtl818x_iowrite16(priv, &priv->map->RFPinsOutput,
+				  reg | (1 << 1));
+		udelay(2);
+
+		if (i & 1) {
+			rtl818x_iowrite16(priv, &priv->map->RFPinsOutput, reg);
+			udelay(1);
+		}
+	}
+
+	rtl818x_iowrite16(priv, &priv->map->RFPinsOutput,
+			  reg80 | (1 << 3) | (1 << 1));
+	udelay(2);
+	rtl818x_iowrite16(priv, &priv->map->RFPinsOutput,
+			  reg80 | (1 << 3));
+	udelay(2);
+	rtl818x_iowrite16(priv, &priv->map->RFPinsOutput,
+			  reg80 | (1 << 3));
+	udelay(2);
+
+	out = 0;
+	for (i = 11; i >= 0; i--) {
+		rtl818x_iowrite16(priv, &priv->map->RFPinsOutput,
+				  reg80 | (1 << 3));
+		udelay(1);
+		rtl818x_iowrite16(priv, &priv->map->RFPinsOutput,
+				  reg80 | (1 << 3) | (1 << 1));
+		udelay(2);
+		rtl818x_iowrite16(priv, &priv->map->RFPinsOutput,
+				  reg80 | (1 << 3) | (1 << 1));
+		udelay(2);
+		rtl818x_iowrite16(priv, &priv->map->RFPinsOutput,
+				  reg80 | (1 << 3) | (1 << 1));
+		udelay(2);
+
+		if (rtl818x_ioread16(priv, &priv->map->RFPinsInput) & (1 << 1))
+			out |= 1 << i;
+
+		rtl818x_iowrite16(priv, &priv->map->RFPinsOutput,
+				  reg80 | (1 << 3));
+		udelay(2);
+	}
+
+	rtl818x_iowrite16(priv, &priv->map->RFPinsOutput,
+			  reg80 | (1 << 3) | (1 << 2));
+	udelay(2);
+
+	rtl818x_iowrite16(priv, &priv->map->RFPinsEnable, reg82);
+	rtl818x_iowrite16(priv, &priv->map->RFPinsSelect, reg84);
+	rtl818x_iowrite16(priv, &priv->map->RFPinsOutput, 0x03A0);
+
+	return out;
+}
+
+static const u16 rtl8225bcd_rxgain[] = {
+	0x0400, 0x0401, 0x0402, 0x0403, 0x0404, 0x0405, 0x0408, 0x0409,
+	0x040a, 0x040b, 0x0502, 0x0503, 0x0504, 0x0505, 0x0540, 0x0541,
+	0x0542, 0x0543, 0x0544, 0x0545, 0x0580, 0x0581, 0x0582, 0x0583,
+	0x0584, 0x0585, 0x0588, 0x0589, 0x058a, 0x058b, 0x0643, 0x0644,
+	0x0645, 0x0680, 0x0681, 0x0682, 0x0683, 0x0684, 0x0685, 0x0688,
+	0x0689, 0x068a, 0x068b, 0x068c, 0x0742, 0x0743, 0x0744, 0x0745,
+	0x0780, 0x0781, 0x0782, 0x0783, 0x0784, 0x0785, 0x0788, 0x0789,
+	0x078a, 0x078b, 0x078c, 0x078d, 0x0790, 0x0791, 0x0792, 0x0793,
+	0x0794, 0x0795, 0x0798, 0x0799, 0x079a, 0x079b, 0x079c, 0x079d,
+	0x07a0, 0x07a1, 0x07a2, 0x07a3, 0x07a4, 0x07a5, 0x07a8, 0x07a9,
+	0x07aa, 0x07ab, 0x07ac, 0x07ad, 0x07b0, 0x07b1, 0x07b2, 0x07b3,
+	0x07b4, 0x07b5, 0x07b8, 0x07b9, 0x07ba, 0x07bb, 0x07bb
+};
+
+static const u8 rtl8225_agc[] = {
+	0x9e, 0x9e, 0x9e, 0x9e, 0x9e, 0x9e, 0x9e, 0x9e,
+	0x9d, 0x9c, 0x9b, 0x9a, 0x99, 0x98, 0x97, 0x96,
+	0x95, 0x94, 0x93, 0x92, 0x91, 0x90, 0x8f, 0x8e,
+	0x8d, 0x8c, 0x8b, 0x8a, 0x89, 0x88, 0x87, 0x86,
+	0x85, 0x84, 0x83, 0x82, 0x81, 0x80, 0x3f, 0x3e,
+	0x3d, 0x3c, 0x3b, 0x3a, 0x39, 0x38, 0x37, 0x36,
+	0x35, 0x34, 0x33, 0x32, 0x31, 0x30, 0x2f, 0x2e,
+	0x2d, 0x2c, 0x2b, 0x2a, 0x29, 0x28, 0x27, 0x26,
+	0x25, 0x24, 0x23, 0x22, 0x21, 0x20, 0x1f, 0x1e,
+	0x1d, 0x1c, 0x1b, 0x1a, 0x19, 0x18, 0x17, 0x16,
+	0x15, 0x14, 0x13, 0x12, 0x11, 0x10, 0x0f, 0x0e,
+	0x0d, 0x0c, 0x0b, 0x0a, 0x09, 0x08, 0x07, 0x06,
+	0x05, 0x04, 0x03, 0x02, 0x01, 0x01, 0x01, 0x01,
+	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
+	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
+	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
+};
+
+static const u8 rtl8225_gain[] = {
+	0x23, 0x88, 0x7c, 0xa5,	/* -82dBm */
+	0x23, 0x88, 0x7c, 0xb5,	/* -82dBm */
+	0x23, 0x88, 0x7c, 0xc5,	/* -82dBm */
+	0x33, 0x80, 0x79, 0xc5,	/* -78dBm */
+	0x43, 0x78, 0x76, 0xc5,	/* -74dBm */
+	0x53, 0x60, 0x73, 0xc5,	/* -70dBm */
+	0x63, 0x58, 0x70, 0xc5,	/* -66dBm */
+};
+
+static const u8 rtl8225_threshold[] = {
+	0x8d, 0x8d, 0x8d, 0x8d, 0x9d, 0xad, 0xbd
+};
+
+static const u8 rtl8225_tx_gain_cck_ofdm[] = {
+	0x02, 0x06, 0x0e, 0x1e, 0x3e, 0x7e
+};
+
+static const u8 rtl8225_tx_power_cck[] = {
+	0x18, 0x17, 0x15, 0x11, 0x0c, 0x08, 0x04, 0x02,
+	0x1b, 0x1a, 0x17, 0x13, 0x0e, 0x09, 0x04, 0x02,
+	0x1f, 0x1e, 0x1a, 0x15, 0x10, 0x0a, 0x05, 0x02,
+	0x22, 0x21, 0x1d, 0x18, 0x11, 0x0b, 0x06, 0x02,
+	0x26, 0x25, 0x21, 0x1b, 0x14, 0x0d, 0x06, 0x03,
+	0x2b, 0x2a, 0x25, 0x1e, 0x16, 0x0e, 0x07, 0x03
+};
+
+static const u8 rtl8225_tx_power_cck_ch14[] = {
+	0x18, 0x17, 0x15, 0x0c, 0x00, 0x00, 0x00, 0x00,
+	0x1b, 0x1a, 0x17, 0x0e, 0x00, 0x00, 0x00, 0x00,
+	0x1f, 0x1e, 0x1a, 0x0f, 0x00, 0x00, 0x00, 0x00,
+	0x22, 0x21, 0x1d, 0x11, 0x00, 0x00, 0x00, 0x00,
+	0x26, 0x25, 0x21, 0x13, 0x00, 0x00, 0x00, 0x00,
+	0x2b, 0x2a, 0x25, 0x15, 0x00, 0x00, 0x00, 0x00
+};
+
+static const u8 rtl8225_tx_power_ofdm[] = {
+	0x80, 0x90, 0xa2, 0xb5, 0xcb, 0xe4
+};
+
+static const u32 rtl8225_chan[] = {
+	0x085c, 0x08dc, 0x095c, 0x09dc, 0x0a5c, 0x0adc, 0x0b5c,
+	0x0bdc, 0x0c5c, 0x0cdc, 0x0d5c, 0x0ddc, 0x0e5c, 0x0f72
+};
+
+static void rtl8225_rf_set_tx_power(struct ieee80211_hw *dev, int channel)
+{
+	struct rtl8187_priv *priv = dev->priv;
+	u8 cck_power, ofdm_power;
+	const u8 *tmp;
+	u32 reg;
+	int i;
+
+	cck_power = priv->channels[channel - 1].val & 0xF;
+	ofdm_power = priv->channels[channel - 1].val >> 4;
+
+	cck_power = min(cck_power, (u8)11);
+	ofdm_power = min(ofdm_power, (u8)35);
+
+	rtl818x_iowrite8(priv, &priv->map->TX_GAIN_CCK,
+			 rtl8225_tx_gain_cck_ofdm[cck_power / 6] >> 1);
+
+	if (channel == 14)
+		tmp = &rtl8225_tx_power_cck_ch14[(cck_power % 6) * 8];
+	else
+		tmp = &rtl8225_tx_power_cck[(cck_power % 6) * 8];
+
+	for (i = 0; i < 8; i++)
+		rtl8225_write_phy_cck(dev, 0x44 + i, *tmp++);
+
+	mdelay(1); // FIXME: optional?
+
+	/* anaparam2 on */
+	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, RTL818X_EEPROM_CMD_CONFIG);
+	reg = rtl818x_ioread8(priv, &priv->map->CONFIG3);
+	rtl818x_iowrite8(priv, &priv->map->CONFIG3, reg | RTL818X_CONFIG3_ANAPARAM_WRITE);
+	rtl818x_iowrite32(priv, &priv->map->ANAPARAM2, RTL8225_ANAPARAM2_ON);
+	rtl818x_iowrite8(priv, &priv->map->CONFIG3, reg & ~RTL818X_CONFIG3_ANAPARAM_WRITE);
+	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, RTL818X_EEPROM_CMD_NORMAL);
+
+	rtl8225_write_phy_ofdm(dev, 2, 0x42);
+	rtl8225_write_phy_ofdm(dev, 6, 0x00);
+	rtl8225_write_phy_ofdm(dev, 8, 0x00);
+
+	rtl818x_iowrite8(priv, &priv->map->TX_GAIN_OFDM,
+			 rtl8225_tx_gain_cck_ofdm[ofdm_power / 6] >> 1);
+
+	tmp = &rtl8225_tx_power_ofdm[ofdm_power % 6];
+
+	rtl8225_write_phy_ofdm(dev, 5, *tmp);
+	rtl8225_write_phy_ofdm(dev, 7, *tmp);
+
+	mdelay(1);
+}
+
+void rtl8225_rf_init(struct ieee80211_hw *dev)
+{
+	struct rtl8187_priv *priv = dev->priv;
+	int i;
+
+	rtl8225_write(dev, 0x0, 0x067); mdelay(1);
+	rtl8225_write(dev, 0x1, 0xFE0); mdelay(1);
+	rtl8225_write(dev, 0x2, 0x44D); mdelay(1);
+	rtl8225_write(dev, 0x3, 0x441); mdelay(1);
+	rtl8225_write(dev, 0x4, 0x486); mdelay(1);
+	rtl8225_write(dev, 0x5, 0xBC0); mdelay(1);
+	rtl8225_write(dev, 0x6, 0xAE6); mdelay(1);
+	rtl8225_write(dev, 0x7, 0x82A); mdelay(1);
+	rtl8225_write(dev, 0x8, 0x01F); mdelay(1);
+	rtl8225_write(dev, 0x9, 0x334); mdelay(1);
+	rtl8225_write(dev, 0xA, 0xFD4); mdelay(1);
+	rtl8225_write(dev, 0xB, 0x391); mdelay(1);
+	rtl8225_write(dev, 0xC, 0x050); mdelay(1);
+	rtl8225_write(dev, 0xD, 0x6DB); mdelay(1);
+	rtl8225_write(dev, 0xE, 0x029); mdelay(1);
+	rtl8225_write(dev, 0xF, 0x914); mdelay(100);
+
+	rtl8225_write(dev, 0x2, 0xC4D); mdelay(200);
+	rtl8225_write(dev, 0x2, 0x44D); mdelay(200);
+
+	if (!(rtl8225_read(dev, 6) & (1 << 7))) {
+		rtl8225_write(dev, 0x02, 0x0c4d);
+		mdelay(200);
+		rtl8225_write(dev, 0x02, 0x044d);
+		mdelay(100);
+		if (!(rtl8225_read(dev, 6) & (1 << 7)))
+			printk(KERN_WARNING "%s: RF Calibration Failed! %x\n",
+			       wiphy_name(dev->wiphy), rtl8225_read(dev, 6));
+	}
+
+	rtl8225_write(dev, 0x0, 0x127);
+
+	for (i = 0; i < ARRAY_SIZE(rtl8225bcd_rxgain); i++) {
+		rtl8225_write(dev, 0x1, i + 1);
+		rtl8225_write(dev, 0x2, rtl8225bcd_rxgain[i]);
+	}
+
+	rtl8225_write(dev, 0x0, 0x027);
+	rtl8225_write(dev, 0x0, 0x22F);
+
+	for (i = 0; i < ARRAY_SIZE(rtl8225_agc); i++) {
+		rtl8225_write_phy_ofdm(dev, 0xB, rtl8225_agc[i]);
+		mdelay(1);
+		rtl8225_write_phy_ofdm(dev, 0xA, 0x80 + i);
+		mdelay(1);
+	}
+
+	mdelay(1);
+
+	rtl8225_write_phy_ofdm(dev, 0x00, 0x01); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x01, 0x02); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x02, 0x42); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x03, 0x00); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x04, 0x00); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x05, 0x00); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x06, 0x40); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x07, 0x00); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x08, 0x40); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x09, 0xfe); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x0a, 0x09); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x0b, 0x80); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x0c, 0x01); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x0e, 0xd3); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x0f, 0x38); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x10, 0x84); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x11, 0x06); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x12, 0x20); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x13, 0x20); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x14, 0x00); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x15, 0x40); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x16, 0x00); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x17, 0x40); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x18, 0xef); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x19, 0x19); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x1a, 0x20); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x1b, 0x76); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x1c, 0x04); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x1e, 0x95); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x1f, 0x75); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x20, 0x1f); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x21, 0x27); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x22, 0x16); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x24, 0x46); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x25, 0x20); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x26, 0x90); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x27, 0x88); mdelay(1);
+
+	rtl8225_write_phy_ofdm(dev, 0x0d, rtl8225_gain[2 * 4]);
+	rtl8225_write_phy_ofdm(dev, 0x1b, rtl8225_gain[2 * 4 + 2]);
+	rtl8225_write_phy_ofdm(dev, 0x1d, rtl8225_gain[2 * 4 + 3]);
+	rtl8225_write_phy_ofdm(dev, 0x23, rtl8225_gain[2 * 4 + 1]);
+
+	rtl8225_write_phy_cck(dev, 0x00, 0x98); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x03, 0x20); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x04, 0x7e); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x05, 0x12); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x06, 0xfc); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x07, 0x78); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x08, 0x2e); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x10, 0x9b); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x11, 0x88); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x12, 0x47); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x13, 0xd0);
+	rtl8225_write_phy_cck(dev, 0x19, 0x00);
+	rtl8225_write_phy_cck(dev, 0x1a, 0xa0);
+	rtl8225_write_phy_cck(dev, 0x1b, 0x08);
+	rtl8225_write_phy_cck(dev, 0x40, 0x86);
+	rtl8225_write_phy_cck(dev, 0x41, 0x8d); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x42, 0x15); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x43, 0x18); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x44, 0x1f); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x45, 0x1e); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x46, 0x1a); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x47, 0x15); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x48, 0x10); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x49, 0x0a); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x4a, 0x05); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x4b, 0x02); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x4c, 0x05); mdelay(1);
+
+	rtl818x_iowrite8(priv, &priv->map->TESTR, 0x0D);
+
+	rtl8225_rf_set_tx_power(dev, 1);
+
+	/* RX antenna default to A */
+	rtl8225_write_phy_cck(dev, 0x10, 0x9b); mdelay(1);	/* B: 0xDB */
+	rtl8225_write_phy_ofdm(dev, 0x26, 0x90); mdelay(1);	/* B: 0x10 */
+
+	rtl818x_iowrite8(priv, &priv->map->TX_ANTENNA, 0x03);	/* B: 0x00 */
+	mdelay(1);
+	rtl818x_iowrite32(priv, (__le32 *)0xFF94, 0x3dc00002);
+
+	/* set sensitivity */
+	rtl8225_write(dev, 0x0c, 0x50);
+	rtl8225_write_phy_ofdm(dev, 0x0d, rtl8225_gain[2 * 4]);
+	rtl8225_write_phy_ofdm(dev, 0x1b, rtl8225_gain[2 * 4 + 2]);
+	rtl8225_write_phy_ofdm(dev, 0x1d, rtl8225_gain[2 * 4 + 3]);
+	rtl8225_write_phy_ofdm(dev, 0x23, rtl8225_gain[2 * 4 + 1]);
+	rtl8225_write_phy_cck(dev, 0x41, rtl8225_threshold[2]);
+}
+
+static const u8 rtl8225z2_tx_power_cck_ch14[] = {
+	0x36, 0x35, 0x2e, 0x1b, 0x00, 0x00, 0x00, 0x00
+};
+
+static const u8 rtl8225z2_tx_power_cck[] = {
+	0x36, 0x35, 0x2e, 0x25, 0x1c, 0x12, 0x09, 0x04
+};
+
+static const u8 rtl8225z2_tx_power_ofdm[] = {
+	0x42, 0x00, 0x40, 0x00, 0x40
+};
+
+static const u8 rtl8225z2_tx_gain_cck_ofdm[] = {
+	0x00, 0x01, 0x02, 0x03, 0x04, 0x05,
+	0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b,
+	0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11,
+	0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
+	0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d,
+	0x1e, 0x1f, 0x20, 0x21, 0x22, 0x23
+};
+
+static void rtl8225z2_rf_set_tx_power(struct ieee80211_hw *dev, int channel)
+{
+	struct rtl8187_priv *priv = dev->priv;
+	u8 cck_power, ofdm_power;
+	const u8 *tmp;
+	u32 reg;
+	int i;
+
+	cck_power = priv->channels[channel - 1].val & 0xF;
+	ofdm_power = priv->channels[channel - 1].val >> 4;
+
+	cck_power = min(cck_power, (u8)15);
+	cck_power += priv->txpwr_base & 0xF;
+	cck_power = min(cck_power, (u8)35);
+
+	ofdm_power = min(ofdm_power, (u8)15);
+	ofdm_power += priv->txpwr_base >> 4;
+	ofdm_power = min(ofdm_power, (u8)35);
+
+	if (channel == 14)
+		tmp = rtl8225z2_tx_power_cck_ch14;
+	else
+		tmp = rtl8225z2_tx_power_cck;
+
+	for (i = 0; i < 8; i++)
+		rtl8225_write_phy_cck(dev, 0x44 + i, *tmp++);
+
+	rtl818x_iowrite8(priv, &priv->map->TX_GAIN_CCK,
+			 rtl8225z2_tx_gain_cck_ofdm[cck_power]);
+	mdelay(1);
+
+	/* anaparam2 on */
+	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, RTL818X_EEPROM_CMD_CONFIG);
+	reg = rtl818x_ioread8(priv, &priv->map->CONFIG3);
+	rtl818x_iowrite8(priv, &priv->map->CONFIG3, reg | RTL818X_CONFIG3_ANAPARAM_WRITE);
+	rtl818x_iowrite32(priv, &priv->map->ANAPARAM2, RTL8225_ANAPARAM2_ON);
+	rtl818x_iowrite8(priv, &priv->map->CONFIG3, reg & ~RTL818X_CONFIG3_ANAPARAM_WRITE);
+	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, RTL818X_EEPROM_CMD_NORMAL);
+
+	rtl8225_write_phy_ofdm(dev, 2, 0x42);
+	rtl8225_write_phy_ofdm(dev, 5, 0x00);
+	rtl8225_write_phy_ofdm(dev, 6, 0x40);
+	rtl8225_write_phy_ofdm(dev, 7, 0x00);
+	rtl8225_write_phy_ofdm(dev, 8, 0x40);
+
+	rtl818x_iowrite8(priv, &priv->map->TX_GAIN_OFDM,
+			 rtl8225z2_tx_gain_cck_ofdm[ofdm_power]);
+	mdelay(1);
+}
+
+static const u16 rtl8225z2_rxgain[] = {
+	0x0400, 0x0401, 0x0402, 0x0403, 0x0404, 0x0405, 0x0408, 0x0409,
+	0x040a, 0x040b, 0x0502, 0x0503, 0x0504, 0x0505, 0x0540, 0x0541,
+	0x0542, 0x0543, 0x0544, 0x0545, 0x0580, 0x0581, 0x0582, 0x0583,
+	0x0584, 0x0585, 0x0588, 0x0589, 0x058a, 0x058b, 0x0643, 0x0644,
+	0x0645, 0x0680, 0x0681, 0x0682, 0x0683, 0x0684, 0x0685, 0x0688,
+	0x0689, 0x068a, 0x068b, 0x068c, 0x0742, 0x0743, 0x0744, 0x0745,
+	0x0780, 0x0781, 0x0782, 0x0783, 0x0784, 0x0785, 0x0788, 0x0789,
+	0x078a, 0x078b, 0x078c, 0x078d, 0x0790, 0x0791, 0x0792, 0x0793,
+	0x0794, 0x0795, 0x0798, 0x0799, 0x079a, 0x079b, 0x079c, 0x079d,
+	0x07a0, 0x07a1, 0x07a2, 0x07a3, 0x07a4, 0x07a5, 0x07a8, 0x07a9,
+	0x03aa, 0x03ab, 0x03ac, 0x03ad, 0x03b0, 0x03b1, 0x03b2, 0x03b3,
+	0x03b4, 0x03b5, 0x03b8, 0x03b9, 0x03ba, 0x03bb, 0x03bb
+};
+
+static const u8 rtl8225z2_gain_bg[] = {
+	0x23, 0x15, 0xa5, /* -82-1dBm */
+	0x23, 0x15, 0xb5, /* -82-2dBm */
+	0x23, 0x15, 0xc5, /* -82-3dBm */
+	0x33, 0x15, 0xc5, /* -78dBm */
+	0x43, 0x15, 0xc5, /* -74dBm */
+	0x53, 0x15, 0xc5, /* -70dBm */
+	0x63, 0x15, 0xc5  /* -66dBm */
+};
+
+void rtl8225z2_rf_init(struct ieee80211_hw *dev)
+{
+	struct rtl8187_priv *priv = dev->priv;
+	int i;
+
+	rtl8225_write(dev, 0x0, 0x2BF); mdelay(1);
+	rtl8225_write(dev, 0x1, 0xEE0); mdelay(1);
+	rtl8225_write(dev, 0x2, 0x44D); mdelay(1);
+	rtl8225_write(dev, 0x3, 0x441); mdelay(1);
+	rtl8225_write(dev, 0x4, 0x8C3); mdelay(1);
+	rtl8225_write(dev, 0x5, 0xC72); mdelay(1);
+	rtl8225_write(dev, 0x6, 0x0E6); mdelay(1);
+	rtl8225_write(dev, 0x7, 0x82A); mdelay(1);
+	rtl8225_write(dev, 0x8, 0x03F); mdelay(1);
+	rtl8225_write(dev, 0x9, 0x335); mdelay(1);
+	rtl8225_write(dev, 0xa, 0x9D4); mdelay(1);
+	rtl8225_write(dev, 0xb, 0x7BB); mdelay(1);
+	rtl8225_write(dev, 0xc, 0x850); mdelay(1);
+	rtl8225_write(dev, 0xd, 0xCDF); mdelay(1);
+	rtl8225_write(dev, 0xe, 0x02B); mdelay(1);
+	rtl8225_write(dev, 0xf, 0x114); mdelay(100);
+
+	rtl8225_write(dev, 0x0, 0x1B7);
+
+	for (i = 0; i < ARRAY_SIZE(rtl8225z2_rxgain); i++) {
+		rtl8225_write(dev, 0x1, i + 1);
+		rtl8225_write(dev, 0x2, rtl8225z2_rxgain[i]);
+	}
+
+	rtl8225_write(dev, 0x3, 0x080);
+	rtl8225_write(dev, 0x5, 0x004);
+	rtl8225_write(dev, 0x0, 0x0B7);
+	rtl8225_write(dev, 0x2, 0xc4D);
+
+	mdelay(200);
+	rtl8225_write(dev, 0x2, 0x44D);
+	mdelay(100);
+
+	if (!(rtl8225_read(dev, 6) & (1 << 7))) {
+		rtl8225_write(dev, 0x02, 0x0C4D);
+		mdelay(200);
+		rtl8225_write(dev, 0x02, 0x044D);
+		mdelay(100);
+		if (!(rtl8225_read(dev, 6) & (1 << 7)))
+			printk(KERN_WARNING "%s: RF Calibration Failed! %x\n",
+			       wiphy_name(dev->wiphy), rtl8225_read(dev, 6));
+	}
+
+	mdelay(200);
+
+	rtl8225_write(dev, 0x0, 0x2BF);
+
+	for (i = 0; i < ARRAY_SIZE(rtl8225_agc); i++) {
+		rtl8225_write_phy_ofdm(dev, 0xB, rtl8225_agc[i]);
+		mdelay(1);
+		rtl8225_write_phy_ofdm(dev, 0xA, 0x80 + i);
+		mdelay(1);
+	}
+
+	mdelay(1);
+
+	rtl8225_write_phy_ofdm(dev, 0x00, 0x01); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x01, 0x02); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x02, 0x42); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x03, 0x00); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x04, 0x00); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x05, 0x00); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x06, 0x40); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x07, 0x00); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x08, 0x40); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x09, 0xfe); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x0a, 0x08); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x0b, 0x80); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x0c, 0x01); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x0d, 0x43);
+	rtl8225_write_phy_ofdm(dev, 0x0e, 0xd3); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x0f, 0x38); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x10, 0x84); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x11, 0x07); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x12, 0x20); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x13, 0x20); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x14, 0x00); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x15, 0x40); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x16, 0x00); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x17, 0x40); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x18, 0xef); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x19, 0x19); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x1a, 0x20); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x1b, 0x15); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x1c, 0x04); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x1d, 0xc5); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x1e, 0x95); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x1f, 0x75); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x20, 0x1f); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x21, 0x17); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x22, 0x16); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x23, 0x80); mdelay(1); //FIXME: not needed?
+	rtl8225_write_phy_ofdm(dev, 0x24, 0x46); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x25, 0x00); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x26, 0x90); mdelay(1);
+	rtl8225_write_phy_ofdm(dev, 0x27, 0x88); mdelay(1);
+
+	rtl8225_write_phy_ofdm(dev, 0x0b, rtl8225z2_gain_bg[4 * 3]);
+	rtl8225_write_phy_ofdm(dev, 0x1b, rtl8225z2_gain_bg[4 * 3 + 1]);
+	rtl8225_write_phy_ofdm(dev, 0x1d, rtl8225z2_gain_bg[4 * 3 + 2]);
+	rtl8225_write_phy_ofdm(dev, 0x21, 0x37);
+
+	rtl8225_write_phy_cck(dev, 0x00, 0x98); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x03, 0x20); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x04, 0x7e); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x05, 0x12); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x06, 0xfc); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x07, 0x78); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x08, 0x2e); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x10, 0x9b); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x11, 0x88); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x12, 0x47); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x13, 0xd0);
+	rtl8225_write_phy_cck(dev, 0x19, 0x00);
+	rtl8225_write_phy_cck(dev, 0x1a, 0xa0);
+	rtl8225_write_phy_cck(dev, 0x1b, 0x08);
+	rtl8225_write_phy_cck(dev, 0x40, 0x86);
+	rtl8225_write_phy_cck(dev, 0x41, 0x8d); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x42, 0x15); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x43, 0x18); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x44, 0x36); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x45, 0x35); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x46, 0x2e); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x47, 0x25); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x48, 0x1c); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x49, 0x12); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x4a, 0x09); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x4b, 0x04); mdelay(1);
+	rtl8225_write_phy_cck(dev, 0x4c, 0x05); mdelay(1);
+
+	rtl818x_iowrite8(priv, (u8 *)0xFF5B, 0x0D); mdelay(1);
+
+	rtl8225z2_rf_set_tx_power(dev, 1);
+
+	/* RX antenna default to A */
+	rtl8225_write_phy_cck(dev, 0x10, 0x9b); mdelay(1);	/* B: 0xDB */
+	rtl8225_write_phy_ofdm(dev, 0x26, 0x90); mdelay(1);	/* B: 0x10 */
+
+	rtl818x_iowrite8(priv, &priv->map->TX_ANTENNA, 0x03);	/* B: 0x00 */
+	mdelay(1);
+	rtl818x_iowrite32(priv, (__le32 *)0xFF94, 0x3dc00002);
+}
+
+void rtl8225_rf_stop(struct ieee80211_hw *dev)
+{
+	u8 reg;
+	struct rtl8187_priv *priv = dev->priv;
+
+	rtl8225_write(dev, 0x4, 0x1f); mdelay(1);
+
+	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, RTL818X_EEPROM_CMD_CONFIG);
+	reg = rtl818x_ioread8(priv, &priv->map->CONFIG3);
+	rtl818x_iowrite8(priv, &priv->map->CONFIG3, reg | RTL818X_CONFIG3_ANAPARAM_WRITE);
+	rtl818x_iowrite32(priv, &priv->map->ANAPARAM2, RTL8225_ANAPARAM2_OFF);
+	rtl818x_iowrite32(priv, &priv->map->ANAPARAM, RTL8225_ANAPARAM_OFF);
+	rtl818x_iowrite8(priv, &priv->map->CONFIG3, reg & ~RTL818X_CONFIG3_ANAPARAM_WRITE);
+	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, RTL818X_EEPROM_CMD_NORMAL);
+}
+
+void rtl8225_rf_set_channel(struct ieee80211_hw *dev, int channel)
+{
+	struct rtl8187_priv *priv = dev->priv;
+
+	if (priv->rf_init == rtl8225_rf_init)
+		rtl8225_rf_set_tx_power(dev, channel);
+	else
+		rtl8225z2_rf_set_tx_power(dev, channel);
+
+	rtl8225_write(dev, 0x7, rtl8225_chan[channel - 1]);
+	mdelay(10);
+}
diff --git a/drivers/net/wireless/rtl8187_rtl8225.h b/drivers/net/wireless/rtl8187_rtl8225.h
new file mode 100644
index 0000000..ed28118
--- /dev/null
+++ b/drivers/net/wireless/rtl8187_rtl8225.h
@@ -0,0 +1,30 @@
+#ifndef RTL8187_RTL8225_H
+#define RTL8187_RTL8225_H
+
+#define RTL8225_ANAPARAM_ON	0xa0000a59
+#define RTL8225_ANAPARAM2_ON	0x860c7312
+#define RTL8225_ANAPARAM_OFF	0xa00beb59
+#define RTL8225_ANAPARAM2_OFF	0x840dec11
+
+void rtl8225_write(struct ieee80211_hw *, u8 addr, u16 data);
+u16  rtl8225_read(struct ieee80211_hw *, u8 addr);
+
+void rtl8225_rf_init(struct ieee80211_hw *);
+void rtl8225z2_rf_init(struct ieee80211_hw *);
+void rtl8225_rf_stop(struct ieee80211_hw *);
+void rtl8225_rf_set_channel(struct ieee80211_hw *, int);
+
+
+static inline void rtl8225_write_phy_ofdm(struct ieee80211_hw *dev,
+					  u8 addr, u32 data)
+{
+	rtl8187_write_phy(dev, addr, data);
+}
+
+static inline void rtl8225_write_phy_cck(struct ieee80211_hw *dev,
+					 u8 addr, u32 data)
+{
+	rtl8187_write_phy(dev, addr, data | 0x10000);
+}
+
+#endif /* RTL8187_RTL8225_H */
diff --git a/drivers/net/wireless/rtl818x.h b/drivers/net/wireless/rtl818x.h
new file mode 100644
index 0000000..e4ee946
--- /dev/null
+++ b/drivers/net/wireless/rtl818x.h
@@ -0,0 +1,212 @@
+#ifndef RTL818X_H
+#define RTL818X_H
+
+struct rtl818x_csr {
+	u8	MAC[6];
+	u8	reserved_0[2];
+	__le32	MAR[2];
+	u8	RX_FIFO_COUNT;
+	u8	reserved_1;
+	u8	TX_FIFO_COUNT;
+	u8	BQREQ;
+	u8	reserved_2[4];
+	__le32	TSFT[2];
+	__le32	TLPDA;
+	__le32	TNPDA;
+	__le32	THPDA;
+	__le16	BRSR;
+	u8	BSSID[6];
+	u8	RESP_RATE;
+	u8	EIFS;
+	u8	reserved_3[1];
+	u8	CMD;
+#define RTL818X_CMD_TX_ENABLE		(1 << 2)
+#define RTL818X_CMD_RX_ENABLE		(1 << 3)
+#define RTL818X_CMD_RESET		(1 << 4)
+	u8	reserved_4[4];
+	__le16	INT_MASK;
+	__le16	INT_STATUS;
+#define RTL818X_INT_RX_OK		(1 <<  0)
+#define RTL818X_INT_RX_ERR		(1 <<  1)
+#define RTL818X_INT_TXL_OK		(1 <<  2)
+#define RTL818X_INT_TXL_ERR		(1 <<  3)
+#define RTL818X_INT_RX_DU		(1 <<  4)
+#define RTL818X_INT_RX_FO		(1 <<  5)
+#define RTL818X_INT_TXN_OK		(1 <<  6)
+#define RTL818X_INT_TXN_ERR		(1 <<  7)
+#define RTL818X_INT_TXH_OK		(1 <<  8)
+#define RTL818X_INT_TXH_ERR		(1 <<  9)
+#define RTL818X_INT_TXB_OK		(1 << 10)
+#define RTL818X_INT_TXB_ERR		(1 << 11)
+#define RTL818X_INT_ATIM		(1 << 12)
+#define RTL818X_INT_BEACON		(1 << 13)
+#define RTL818X_INT_TIME_OUT		(1 << 14)
+#define RTL818X_INT_TX_FO		(1 << 15)
+	__le32	TX_CONF;
+#define RTL818X_TX_CONF_LOOPBACK_MAC	(1 << 17)
+#define RTL818X_TX_CONF_NO_ICV		(1 << 19)
+#define RTL818X_TX_CONF_DISCW		(1 << 20)
+#define RTL818X_TX_CONF_R8180_ABCD	(2 << 25)
+#define RTL818X_TX_CONF_R8180_F		(3 << 25)
+#define RTL818X_TX_CONF_R8185_ABC	(4 << 25)
+#define RTL818X_TX_CONF_R8185_D		(5 << 25)
+#define RTL818X_TX_CONF_HWVER_MASK	(7 << 25)
+#define RTL818X_TX_CONF_CW_MIN		(1 << 31)
+	__le32	RX_CONF;
+#define RTL818X_RX_CONF_MONITOR		(1 <<  0)
+#define RTL818X_RX_CONF_NICMAC		(1 <<  1)
+#define RTL818X_RX_CONF_MULTICAST	(1 <<  2)
+#define RTL818X_RX_CONF_BROADCAST	(1 <<  3)
+#define RTL818X_RX_CONF_DATA		(1 << 18)
+#define RTL818X_RX_CONF_CTRL		(1 << 19)
+#define RTL818X_RX_CONF_MGMT		(1 << 20)
+#define RTL818X_RX_CONF_BSSID		(1 << 23)
+#define RTL818X_RX_CONF_RX_AUTORESETPHY	(1 << 28)
+#define RTL818X_RX_CONF_ONLYERLPKT	(1 << 31)
+	__le32	INT_TIMEOUT;
+	__le32	TBDA;
+	u8	EEPROM_CMD;
+#define RTL818X_EEPROM_CMD_READ		(1 << 0)
+#define RTL818X_EEPROM_CMD_WRITE	(1 << 1)
+#define RTL818X_EEPROM_CMD_CK		(1 << 2)
+#define RTL818X_EEPROM_CMD_CS		(1 << 3)
+#define RTL818X_EEPROM_CMD_NORMAL	(0 << 6)
+#define RTL818X_EEPROM_CMD_LOAD		(1 << 6)
+#define RTL818X_EEPROM_CMD_PROGRAM	(2 << 6)
+#define RTL818X_EEPROM_CMD_CONFIG	(3 << 6)
+	u8	CONFIG0;
+	u8	CONFIG1;
+	u8	CONFIG2;
+	__le32	ANAPARAM;
+	u8	MSR;
+#define RTL818X_MSR_NO_LINK		(0 << 2)
+#define RTL818X_MSR_ADHOC		(1 << 2)
+#define RTL818X_MSR_INFRA		(2 << 2)
+	u8	CONFIG3;
+#define RTL818X_CONFIG3_ANAPARAM_WRITE	(1 << 6)
+	u8	CONFIG4;
+#define RTL818X_CONFIG4_POWEROFF	(1 << 6)
+#define RTL818X_CONFIG4_VCOOFF		(1 << 7)
+	u8	TESTR;
+	u8	reserved_9[2];
+	__le16	PGSELECT;
+	__le32	ANAPARAM2;
+	u8	reserved_10[12];
+	__le16	BEACON_INTERVAL;
+	__le16	ATIM_WND;
+	__le16	BEACON_INTERVAL_TIME;
+	__le16	ATIMTR_INTERVAL;
+	u8	reserved_11[4];
+	u8	PHY[4];
+	__le16	RFPinsOutput;
+	__le16	RFPinsEnable;
+	__le16	RFPinsSelect;
+	__le16	RFPinsInput;
+	__le32	RF_PARA;
+	__le32	RF_TIMING;
+	u8	GP_ENABLE;
+	u8	GPIO;
+	u8	reserved_12[10];
+	u8	TX_AGC_CTL;
+#define RTL818X_TX_AGC_CTL_PERPACKET_GAIN_SHIFT		(1 << 0)
+#define RTL818X_TX_AGC_CTL_PERPACKET_ANTSEL_SHIFT	(1 << 1)
+#define RTL818X_TX_AGC_CTL_FEEDBACK_ANT			(1 << 2)
+	u8	TX_GAIN_CCK;
+	u8	TX_GAIN_OFDM;
+	u8	TX_ANTENNA;
+	u8	reserved_13[16];
+	u8	WPA_CONF;
+	u8	reserved_14[3];
+	u8	SIFS;
+	u8	DIFS;
+	u8	SLOT;
+	u8	reserved_15[5];
+	u8	CW_CONF;
+#define RTL818X_CW_CONF_PERPACKET_CW_SHIFT	(1 << 0)
+#define RTL818X_CW_CONF_PERPACKET_RETRY_SHIFT	(1 << 1)
+	u8	CW_VAL;
+	u8	RATE_FALLBACK;
+	u8	reserved_16[25];
+	u8	CONFIG5;
+	u8	TX_DMA_POLLING;
+	u8	reserved_17[2];
+	__le16	CWR;
+	u8	RETRY_CTR;
+	u8	reserved_18[5];
+	__le32	RDSAR;
+	u8	reserved_19[18];
+	u16	TALLY_CNT;
+	u8	TALLY_SEL;
+} __attribute__((packed));
+
+static const struct ieee80211_rate rtl818x_rates[] = {
+	{ .rate = 10,
+	  .val = 0,
+	  .flags = IEEE80211_RATE_CCK },
+	{ .rate = 20,
+	  .val = 1,
+	  .flags = IEEE80211_RATE_CCK },
+	{ .rate = 55,
+	  .val = 2,
+	  .flags = IEEE80211_RATE_CCK },
+	{ .rate = 110,
+	  .val = 3,
+	  .flags = IEEE80211_RATE_CCK },
+	{ .rate = 60,
+	  .val = 4,
+	  .flags = IEEE80211_RATE_OFDM },
+	{ .rate = 90,
+	  .val = 5,
+	  .flags = IEEE80211_RATE_OFDM },
+	{ .rate = 120,
+	  .val = 6,
+	  .flags = IEEE80211_RATE_OFDM },
+	{ .rate = 180,
+	  .val = 7,
+	  .flags = IEEE80211_RATE_OFDM },
+	{ .rate = 240,
+	  .val = 8,
+	  .flags = IEEE80211_RATE_OFDM },
+	{ .rate = 360,
+	  .val = 9,
+	  .flags = IEEE80211_RATE_OFDM },
+	{ .rate = 480,
+	  .val = 10,
+	  .flags = IEEE80211_RATE_OFDM },
+	{ .rate = 540,
+	  .val = 11,
+	  .flags = IEEE80211_RATE_OFDM },
+};
+
+static const struct ieee80211_channel rtl818x_channels[] = {
+	{ .chan = 1,
+	  .freq = 2412},
+	{ .chan = 2,
+	  .freq = 2417},
+	{ .chan = 3,
+	  .freq = 2422},
+	{ .chan = 4,
+	  .freq = 2427},
+	{ .chan = 5,
+	  .freq = 2432},
+	{ .chan = 6,
+	  .freq = 2437},
+	{ .chan = 7,
+	  .freq = 2442},
+	{ .chan = 8,
+	  .freq = 2447},
+	{ .chan = 9,
+	  .freq = 2452},
+	{ .chan = 10,
+	  .freq = 2457},
+	{ .chan = 11,
+	  .freq = 2462},
+	{ .chan = 12,
+	  .freq = 2467},
+	{ .chan = 13,
+	  .freq = 2472},
+	{ .chan = 14,
+	  .freq = 2484}
+};
+
+#endif /* RTL818X_H */
diff --git a/include/linux/eeprom_93cx6.h b/include/linux/eeprom_93cx6.h
new file mode 100644
index 0000000..4b9be59
--- /dev/null
+++ b/include/linux/eeprom_93cx6.h
@@ -0,0 +1,77 @@
+/*
+	Copyright (C) 2004 - 2006 rt2x00 SourceForge Project
+	<http://rt2x00.serialmonkey.com>
+
+	This program is free software; you can redistribute it and/or modify
+	it under the terms of the GNU General Public License as published by
+	the Free Software Foundation; either version 2 of the License, or
+	(at your option) any later version.
+
+	This program is distributed in the hope that it will be useful,
+	but WITHOUT ANY WARRANTY; without even the implied warranty of
+	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+	GNU General Public License for more details.
+
+	You should have received a copy of the GNU General Public License
+	along with this program; if not, write to the
+	Free Software Foundation, Inc.,
+	59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ */
+
+/*
+	Module: eeprom_93cx6
+	Abstract: EEPROM reader datastructures for 93cx6 chipsets.
+	Supported chipsets: 93c46 & 93c66.
+ */
+
+/*
+ * EEPROM operation defines.
+ */
+#define PCI_EEPROM_WIDTH_93C46	6
+#define PCI_EEPROM_WIDTH_93C66	8
+#define PCI_EEPROM_WIDTH_OPCODE	3
+#define PCI_EEPROM_WRITE_OPCODE	0x05
+#define PCI_EEPROM_READ_OPCODE	0x06
+#define PCI_EEPROM_EWDS_OPCODE	0x10
+#define PCI_EEPROM_EWEN_OPCODE	0x13
+
+/**
+ * struct eeprom_93cx6 - control structure for setting the commands
+ * for reading the eeprom data.
+ * @data: private pointer for the driver.
+ * @register_read(struct eeprom_93cx6 *eeprom): handler to
+ * read the eeprom register, this function should set all reg_* fields.
+ * @register_write(struct eeprom_93cx6 *eeprom): handler to
+ * write to the eeprom register by using all reg_* fields.
+ * @width: eeprom width, should be one of the PCI_EEPROM_WIDTH_* defines
+ * @reg_data_in: register field to indicate data input
+ * @reg_data_out: register field to indicate data output
+ * @reg_data_clock: register field to set the data clock
+ * @reg_chip_select: register field to set the chip select
+ *
+ * This structure is used for the communication between the driver
+ * and the eeprom_93cx6 handlers for reading the eeprom.
+ */
+struct eeprom_93cx6 {
+	void *data;
+
+	void (*register_read)(struct eeprom_93cx6 *eeprom);
+	void (*register_write)(struct eeprom_93cx6 *eeprom);
+
+	int width;
+
+	char reg_data_in;
+	char reg_data_out;
+	char reg_data_clock;
+	char reg_chip_select;
+};
+
+extern void eeprom_93cx6_read(struct eeprom_93cx6 *eeprom,
+	const u8 word, u16 *data);
+extern void eeprom_93cx6_multiread(struct eeprom_93cx6 *eeprom,
+	const u8 word, __le16 *data, const u16 words);
+
+extern void eeprom_93cx6_write(struct eeprom_93cx6 *eeprom,
+	const u8 word, u16 data);
+extern void eeprom_93cx6_multiwrite(struct eeprom_93cx6 *eeprom,
+	const u8 word, __le16 *data, const u16 words);
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
